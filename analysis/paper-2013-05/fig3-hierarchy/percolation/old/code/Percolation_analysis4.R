# Percolation: size of largest component vs. ranking of connectivity (by degree)
# Basic network analysis, following:
# http://www.slideshare.net/ianmcook/social-network-analysis-in-r

# TODO: fix folder settings. 
# uncomment main() to run as script.

library(igraph)
library(calibrate)

PERCOL.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Fig3-Hierarchical/Percolation/"
DATA.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Data/"

TWITTER.IN <- "twitter_langlang_std.tsv"
WIKIPEDIA.IN <- "wikipedia_langlang_std.tsv"
BOOKS.IN <- "books_langlang_std.tsv"

percolation.figure <- function(infile, 
                               outfile="", # "" plots to screen
                               min.weight=0, # discard links with lower weights
                               min.exposure=0, # discard links with lower exposure
                               deg.type="total", # total/out/in
                               user.langs.to.display=50, # number of removal iterations
                               user.langs.to.label=15, # label in final plot
                               #plot.size.y.axis="s", # left y axis: "s" to plot, "n" to not
                               #plot.percent.y.axis="s" # right y axis: ditto
                               plot.ylim=NULL, # ylim for the plot
                               src.color="black" # color for each source
                               ) {
  # Percolation analysis: create a network from infile, 
  # remove the most connect language in each iteration, 
  # and plot size of largest connected component vs. degree rank

  # load data
  setwd(DATA.DIR)
  edgelist <- read.csv(infile, sep = "\t", header=T)
  setwd(PERCOL.DIR)
  
  # Create the graph
  lgn.graph <- graph.data.frame(
    edgelist[edgelist$common.num>=min.weight,],
    directed=TRUE)
  vertices.full.graph <- length(V(lgn.graph))
  
  num.langs.to.display <- min(vertices.full.graph, user.langs.to.display)
  num.langs.to.label <- min(num.langs.to.display, user.langs.to.label)

  # This is the graph we remove vertices from
  lgn.graph.chopped <- lgn.graph
  giant.comp.sizes.ordered <-  c() # vector to hold sizes
  most.connected.langs.ordered <-  c() # vector to hold language names
  
  # find size of largest component in each scenario
  for(i in 1:num.langs.to.display) {
    # add size of largest current connected component
    # NOTE: we're after strongly connected component (i.e., directed graph)
    # but there won't be a difference on Twitter and Wikipedia, since the links
    # are always reciprocal
    giant.comp.size = max(clusters(lgn.graph.chopped, mode="strong")$csize)
    giant.comp.sizes.ordered = c(giant.comp.sizes.ordered, giant.comp.size)
    
    # Find most connected vertex and remove it.
    # TODO: might be a simpler way, by converting to DF, sorting by degree,
    # then finding the first name works.
    deg.measure= degree(lgn.graph.chopped, mode=deg.type)
    df <- data.frame(deg=deg.measure, name=names(deg.measure))
    df <- df[order(df$deg, decreasing=TRUE), ]
    most.connected <- rownames(df[1,])
    lgn.graph.chopped <- 
      delete.vertices(lgn.graph.chopped, most.connected ) # remove from graph
    df <-df[!rownames(df)==most.connected,] # update DF accordingly
    # Ordered list of most connected languages
    most.connected.langs.ordered <- c(most.connected.langs.ordered, most.connected)
  }
  
  if (outfile != "") {
    postscript(outfile)
  }
  # par(mar=c(4,4,2,5)+.1, pty="s")

  # Print source, deg.type, and min. weight
  #title.text <- sprintf("%s/%s degree/%s", 
  #                      gsub("_.*$", "", x=infile),
  #                      deg.type, min.weight)
  
  # Plot!
  plot(c(1:num.langs.to.display), 
       giant.comp.sizes.ordered[1:num.langs.to.display],
       #xlab = "Degree rank of language group",
       #ylab = "Size of largest connected component",
       xlab="", ylab="", # TODO: hack, add it manually later
       ylim=plot.ylim,
       #main = title.text,
       type = "p", pch = 16, cex = 1.2, col=src.color,
       cex.lab=1) # set point shape and size
  
  # Not working with small figures
  # legend("topright", legend=title.text, bty="o")

  # add text labels to the top num.langs.to.label 
  textxy(c(1:num.langs.to.label),
         giant.comp.sizes.ordered[1:num.langs.to.label],
         most.connected.langs.ordered[1:num.langs.to.label],
         cx = 1, dcol = "black" )

  # add another y-axis w/ percentages 
  par(new=TRUE)
  plot(c(1:num.langs.to.display),
       giant.comp.sizes.ordered[1:num.langs.to.display]/vertices.full.graph*100,
       type="n",col="blue",xlab="",ylab="",
       xaxt="n",yaxt="n")
  axis(4)
  # TODO: hide label for now
  # mtext("Percentage of largest component",side=4,line=3,cex=0.6)
  
if (outfile != "") {
    dev.off()
  }
}

contact.sheet <- function(edgelist.file, outfile="", is.books=F) {
  # Plot combinatons of min.weight and degree type for given source
  # For Twitter and Wikipedia, total=in=out, because all links are reciprocal
  # (e.g., link indicates common users per language) 
  setwd(PERCOL.DIR)
  if (outfile!="") {
    postscript(outfile)
  }
  op <- par(mfrow=c(3,3), mar=c(4,0,1.5,0), oma=c(0,0,0.5,0), pty="s")
  
  percolation.figure(edgelist.file, "", min.weight=0, min.exposure=0, 
                     deg.type="total", user.langs.to.display=50, user.langs.to.label=40)
  percolation.figure(edgelist.file, "", min.weight=20, min.exposure=0, 
                     deg.type="total", user.langs.to.display=50, user.langs.to.label=20)
  percolation.figure(edgelist.file, "", min.weight=100, min.exposure=0, 
                     deg.type="total", user.langs.to.display=50, user.langs.to.label=15)
  if (is.books==T) {
    percolation.figure(edgelist.file, "", min.weight=0, min.exposure=0, 
                       deg.type="out", user.langs.to.display=50, user.langs.to.label=40)
    percolation.figure(edgelist.file, "", min.weight=20, min.exposure=0, 
                       deg.type="out", user.langs.to.display=50, user.langs.to.label=20)
    percolation.figure(edgelist.file, "", min.weight=100, min.exposure=0, 
                       deg.type="out", user.langs.to.display=50, user.langs.to.label=15)
    percolation.figure(edgelist.file, "", min.weight=0, min.exposure=0, 
                       deg.type="in", user.langs.to.display=50, user.langs.to.label=40)
    percolation.figure(edgelist.file, "", min.weight=20, min.exposure=0, 
                       deg.type="in", user.langs.to.display=50, user.langs.to.label=20)
    percolation.figure(edgelist.file, "", min.weight=100, min.exposure=0, 
                       deg.type="in", user.langs.to.display=50, user.langs.to.label=15)
  }
  if (outfile!="") {
    dev.off()
  }
  par(op)
}

main <- function() {
#   contact.sheet(TWITTER.IN, outfile="twitter_percolation.eps")
#   contact.sheet(WIKIPEDIA.IN, outfile="wikipedia_percolation.eps")
#   contact.sheet(BOOKS.IN, outfile="books_percolation.eps", is.books=T) 
  contact.sheet(TWITTER.IN)
  contact.sheet(WIKIPEDIA.IN)
  contact.sheet(BOOKS.IN, is.books=T)
}

main()