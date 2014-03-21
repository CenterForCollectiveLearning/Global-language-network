# Percolation: size of largest component vs. ranking of connectivity (by degree)
# Basic network analysis, following:
# http://www.slideshare.net/ianmcook/social-network-analysis-in-r

# uncomment main() to run as script.

source("../../load.R", chdir=T)

library(igraph)
library(calibrate)

PERCOL.DIR <- paste0(ANALYSIS.ROOT.DIR, "/fig3-hierarchy-null-model/percolation/")

percolation.figure <- function(infile, 
                               outfile="", # "" plots to screen
                               convert.to.undirected=T, # directed/undirected
                               comp.conn.mode="weak", # are we looking for strongly or weakly connected components?
                                                        # only relevant if graph is directed
                               min.common=0, # discard links with lower weights
                               min.exposure=0, # discard links with lower exposure
                               max.pval=9999, # discard links with a higher p-value
                               deg.type="total", # total/out/in
                               user.langs.to.display=50, # number of removal iterations
                               user.langs.to.label=15, # label in final plot
                               plot.x.axis = "s", # x-axis: "s" to plot, "n" to not
                               plot.size.y.axis="s", # left y axis: "s" to plot, "n" to not
                               plot.percent.y.axis="s", # right y axis: ditto
                               x.lab="", y.lab="", y.lab2="", # axis titles
                               title.text="",
                               plot.xlim=NULL, plot.ylim=NULL, # xlim, ylim for the plot
                               src.color="black" # color for each source
                               ) {
  # Percolation analysis: create a network from infile, 
  # remove the most connect language in each iteration, 
  # and plot size of largest connected component vs. degree rank
  # NOTE: percentage values on the second Y-axis may not look nice if
  # the largest strongly connected component of network does not contain 
  # all of its nodes.
  
  # load data
  edgelist <- read.filtered.edgelist(infile,
                                     min.common=min.common, # common speakers/books
                                     min.exposure=min.exposure, # exposure score
                                     desired.p.val=max.pval,
                                     weighted.graph=T) # max p-val
    
  # Create the graph
  lgn.graph.directed <- graph.data.frame(edgelist)
  
  # use directed or undirected graph. Note that the directed= instruction in
  # graph.data.frame only tells whether the edgelist is directed or not (which
  # in our case it is), not the graph.
  if (convert.to.undirected==T) {
    lgn.graph <- as.undirected(lgn.graph.directed, mode="collapse")
  }
  else {
    lgn.graph <- lgn.graph.directed
  }
  
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
    # Links on Twitter and Wikipedia are reciprocal, but depending on the filters
    # used there may be differences in directions, hence the "strong" or "weak" option.
    giant.comp.size = max(clusters(lgn.graph.chopped, mode=comp.conn.mode)$csize)
    giant.comp.sizes.ordered = c(giant.comp.sizes.ordered, giant.comp.size)
    
    # Find most connected vertex and remove it.
    # TODO: might be a simpler way, by converting to DF, sorting by degree,
    # then finding the first name works.
    deg.measure <- degree(lgn.graph.chopped, mode=deg.type)
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
  if (title.text=="") {
    title.text <- sprintf("%s/%s degree/undir=%s/%s",
                          basename(infile),
                          deg.type, convert.to.undirected,comp.conn.mode)  
  }
  
  # Plot!
  plot(c(1:num.langs.to.display), 
       giant.comp.sizes.ordered[1:num.langs.to.display],
       xlab=x.lab, ylab=y.lab,
       xaxt=plot.x.axis, yaxt=plot.size.y.axis,
       xlim=plot.xlim, ylim=plot.ylim,
       main = title.text,
       type = "p", pch = 16, cex = 1, col=src.color,
       cex.lab=1.5) # set point shape and size
  
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
  if (y.lab2!="") { # "Percentage of largest component"
    mtext(y.lab2,side=4,line=3,cex=0.6)
  }
  
  # Perecentage lines
  abline(xpd=F, h=50, col="red", lty=2) # scattered
  abline(xpd=F, h=10, col="red", lty=3) # even more scattered
  
if (outfile != "") {
    dev.off()
  }
}

contact.sheet <- function(edgelist.file, min.common, outfile="") {
  # Plot combinatons of min.common and degree type for given source
  # For Twitter and Wikipedia, total=in=out, because all links are reciprocal
  # (e.g., link indicates common users per language) 
  
  if (outfile!="") {
    postscript(outfile)
  }
  
  percolation.figure(edgelist.file, "", 
                     min.common=min.common, min.exposure=MIN.EXPOSURE, 
                     max.pval=DESIRED.P.VAL, deg.type="total", 
                     user.langs.to.display=50, user.langs.to.label=15)
  percolation.figure(edgelist.file, "", convert.to.undirected=F, 
                     min.common=min.common, min.exposure=MIN.EXPOSURE,
                     max.pval=DESIRED.P.VAL, deg.type="total",
                     user.langs.to.display=50, user.langs.to.label=15)  
  percolation.figure(edgelist.file, "", convert.to.undirected=F, 
                     min.common=min.common, min.exposure=MIN.EXPOSURE, 
                     max.pval=DESIRED.P.VAL, deg.type="total",comp.conn.mode="weak",
                     user.langs.to.display=50, user.langs.to.label=15)  
  if (outfile!="") {
    dev.off()
  }
}

main <- function(output.dir, output.file="") {
  orig.dir <- setwd(output.dir)
  
  if (output.file!="") {
    postscript(output.file)
  }
  op <- par(mfrow=c(3,3), mar=c(4,4,4,4), oma=c(0,4,0.5,4), pty="s")
  
  contact.sheet(TWIT.STD.LANGLANG, min.common=MIN.COMMON.USERS)
  contact.sheet(WIKI.STD.LANGLANG, min.common=MIN.COMMON.USERS)
  contact.sheet(BOOKS.STD.LANGLANG, min.common=MIN.COMMON.TRANS) # only total degree
  
  if (output.file!="") {
    dev.off()
  }
  par(op)
  setwd(orig.dir)
  
}

#main(PERCOL.DIR, "")