# Clustering: clustering coefficient (aka transitivity) vs. degree of language group
# Basic network analysis, following:
# http://www.slideshare.net/ianmcook/social-network-analysis-in-r

library(igraph)
library(calibrate)

CLUSTER.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Fig3-Hierarchical/Clustering/"
DATA.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Data/"

clustering.figure <- function(infile, outfile, min.weight=0, conn.type="total") {
  # Create a network from infile, plot a percolation analysis
  # figure and save to outfile; outfile="" to plot to screen.
  
  # load data
  setwd(DATA.DIR)
  edgelist <- read.csv(infile, sep = "\t", header=T)
  setwd(CLUSTER.DIR)
  
  # Create the graph using the stronger links
  # TODO: the 3rd column shows num of common users / num of translations
  # Ideally we'd use a column name, but it's easier this way.
  lgn.graph <- graph.data.frame(
    edgelist[edgelist[3]>=min.weight,],
    directed=TRUE)
  
  lgn.metrics <- data.frame(
    total.deg=degree(lgn.graph),
    out.deg=degree(lgn.graph, mode="out"),
    in.deg=degree(lgn.graph, mode="in"),
    bet=betweenness(lgn.graph),
    clo=closeness(lgn.graph),
    eig=evcent(lgn.graph)$vector,
    cor=graph.coreness(lgn.graph),
    clustering=transitivity(lgn.graph, type="local", 
                            vids=V(lgn.graph), isolates="zero")
  )
    
#   if (outfile != "") {
#     postscript(outfile)
#   }
  par(mar=c(4,4,2,5)+.1, pty="s")
  
  #num.langs.to.display = 50
  #num.langs.to.label = 15
  
  if (conn.type=="total") {
    x.axis.vals <- lgn.metrics$total.deg
    xlab.text <- "Degree of language group"
  }
  else if (conn.type=="out") {
    x.axis.vals <- lgn.metrics$out.deg
    xlab.text <- "Out degree of language group"
  }
  else if (conn.type=="in") {
    x.axis.vals <- lgn.metrics$in.deg
    xlab.text <- "In degree of language group"
  }
  else if (conn.type=="bet") {
    x.axis.vals <- lgn.metrics$bet
    xlab.text <- "Betweenness of language group"
  }
  
  
  plot(x.axis.vals, 
       lgn.metrics$clustering,
       xlab = xlab.text, 
       ylab = "Clustering coefficient of language group",
       #main = "LGN Percolation Analysis", 
       type = "p", pch = 16, cex = 0.6,
       cex.lab=0.8) # set point shape and size
  
  legend("topright", legend=sprintf("%s", conn.type), bty="n")
  
  # add text labels to the top num.langs.to.label 
  textxy(x.axis.vals,
         lgn.metrics$clustering,
         rownames(lgn.metrics),
         cx = 0.65, dcol = "black" )

#   if (outfile != "") {
#     dev.off()
#   }
}

plot.quartet <- function(infile, outfile, src.name, min.weight=0) {
  # Weight threshold is the min. number of speakers/translations
  # for a language to be included
  if (outfile != "") {
    postscript(outfile)
  }
  par(mfrow=c(2,2),oma = c(0, 0, 3, 0))
  clustering.figure(infile, outfile, 
                     min.weight=min.weight, conn.type="total")
  clustering.figure(infile, outfile, 
                     min.weight=min.weight, conn.type="out")
  clustering.figure(infile, outfile, 
                     min.weight=min.weight, conn.type="in")
  clustering.figure(infile, outfile, 
                     min.weight=min.weight, conn.type="bet")
  mtext(sprintf("%s >= %s", src.name, min.weight), outer = TRUE, cex = 1)
  if (outfile != "") {
    dev.off()
  }
}

#### Main ####
par(mfrow=c(2,2),oma = c(0, 0, 3, 0))
plot.quartet("twitter_langlang.tsv", "twitter0.eps", "Twitter")
plot.quartet("twitter_langlang.tsv", "twitter20.eps", "Twitter", min.weight=20)
plot.quartet("twitter_langlang.tsv", "twitter100.eps", "Twitter", min.weight=100)

par(mfrow=c(2,2),oma = c(0, 0, 3, 0))
plot.quartet("wikipedia_langlang.tsv", "wikipedia0.eps", "Wikipedia")
plot.quartet("wikipedia_langlang.tsv", "wikipedia20.eps", "Wikipedia", min.weight=20)
plot.quartet("wikipedia_langlang.tsv", "wikipedia100.eps", "Wikipedia", min.weight=100)

par(mfrow=c(2,2),oma = c(0, 0, 3, 0))
plot.quartet("books_langlang.tsv", "books0.eps", "Books")
plot.quartet("books_langlang.tsv", "books20.eps", "Books", min.weight=20)
plot.quartet("books_langlang.tsv", "books100.eps", "Books", min.weight=100)
