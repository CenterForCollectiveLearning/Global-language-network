# Clustering: plot clustering coefficient (aka transitivity) 
# vs. degree of language group, add power and exponential fit lines. 
# Note: vertices with degree=0 or clustering=0 are removed from the plot.

# TODO: fix folder settings. 
# uncomment main() to run as script.

library(igraph)
library(calibrate)

CLUSTER.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Fig3-Hierarchical/Clustering/"
DATA.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Data/"

TWITTER.IN <- "twitter_langlang_std.tsv"
WIKIPEDIA.IN <- "wikipedia_langlang_std.tsv"
BOOKS.IN <- "books_langlang_std.tsv"

clustering.figure <- function(infile, 
                               outfile="", # "" plots to screen
                               min.weight=0, # discard links with lower weights
                               min.exposure=0, # discard links with lower exposure
                               deg.type="total") # total/out/in
{
  # Create a network from infile, plot a clustering vs. degree
  # figure and save to outfile; vertices with clustering=0 are removed.
  # outfile="" to plot to screen.
  
  # load data
  setwd(DATA.DIR)
  edgelist <- read.csv(infile, sep = "\t", header=T)
  setwd(CLUSTER.DIR)
  # Create the graph using the stronger links
  lgn.graph <- graph.data.frame(
    edgelist[edgelist$common.num>=min.weight,],
    directed=TRUE)
  
  lgn.metrics <- data.frame(
    deg=degree(lgn.graph, mode=deg.type),
    clustering=transitivity(lgn.graph, type="local", 
                            vids=V(lgn.graph), isolates="zero")
  )
  # Remove vertices with clustering=0 or degree=0
  # Based on http://biocodenv.com/wordpress/?p=68:
  lgn.graph <- delete.vertices( lgn.graph, 
                               which(transitivity(lgn.graph, type="local")==0 |
                                 degree(lgn.graph, mode=deg.type)) )
  # update DF accordingly
  lgn.metrics <-lgn.metrics[!(lgn.metrics$clustering==0 | lgn.metrics$deg==0),]
  # order by degree rank
  lgn.metrics <- lgn.metrics[order(lgn.metrics$deg), ]
  
  if (outfile != "") {
    postscript(outfile)
  }
  #par(mar=c(4,4,2,5)+.1, pty="s")
    
  # Print source, deg.type, and min. weight
  title.text <- sprintf("%s/%s degree/%s", 
                        gsub("_.*$", "", x=infile),
                        deg.type, min.weight)
  
  # Plot!
  plot(lgn.metrics$deg, 
       lgn.metrics$clustering,
       xlab = "Degree of lanugage group (k)", 
       ylab = "Clustering coefficient of language group",
       main = title.text, 
       type = "p", pch = 16, cex = 0.6,
       cex.lab=0.8) # set point shape and size
  
  # add text labels to the top num.langs.to.label 
  textxy(lgn.metrics$deg,
         lgn.metrics$clustering,
         rownames(lgn.metrics),
         cx = 0.65, dcol = "black" )
  
  # Following: http://med.bioinf.mpi-inf.mpg.de/netanalyzer/help/2.6.1/index.html
  # Approx. power law through lm of logs:
  # y = β(x^α) <-> ln(y) = ln(β) + αln(x)
  # in our case, x=k=degree, and y=clustering coefficient
  #print(lgn.metrics)
  lm.power <- lm(log(clustering) ~ log(deg), data=lgn.metrics) # looks better with log10()
  r.sq <- summary(lm.power)$adj.r.squared  
  lm.power.coefs <- coef(lm.power)
  alpha <- round(lm.power.coefs[2], 3)
  beta <- round(exp(lm.power.coefs[1]), 3)
  lines(lgn.metrics$deg, beta*(lgn.metrics$deg)^alpha, col="blue")
  mtext(bquote(y == .(beta)*k^.(alpha)),
        side=3, adj=1, padj=0, col="blue", cex=0.6, line=-1.25) # display equation
  mtext(sprintf("R\U00B2=%s", round(r.sq,3)), 
        side=3, adj=1, padj=0, col="blue", cex=0.6, line=-2.25) # display R-sq
  
  # Fit an exponential model: y = βe^(αx)
  lm.exp <- lm(log(clustering) ~ deg, data=lgn.metrics) # looks better with ln()
  r.sq <- summary(lm.exp)$adj.r.squared
  lm.exp.coefs <- coef(lm.exp)
  alpha <- round(lm.exp.coefs[2], 3)
  beta <- round(exp(lm.exp.coefs[1]), 3)
  lines(lgn.metrics$deg, beta*exp(1)^(alpha*lgn.metrics$deg), col="red")
  mtext(bquote(y == .(beta)*e^(.(alpha)*k)),
        side=1, at=0.2, adj=0, padj=0, col="red", cex=0.6, line=-2) # display equation
  mtext(sprintf("R\U00B2=%s", round(r.sq,3)), 
        side=1, at=0.2, adj=0, padj=0, col="red", cex=0.6, line=-1) # display R-sq

  # For fiting, also check: nls(), loess()
  
  if (outfile != "") {
    dev.off()
  }
}

clustering.contact.sheet <- function(edgelist.file, outfile="", is.books=F) {
  # Plot combinatons of min.weight and degree type for given source
  # For Twitter and Wikipedia, total=in=out, because all links are reciprocal
  # (e.g., link indicates common users per language) 
  if (outfile!="") {
    postscript(outfile)
  }
  par(mfrow=c(3,3), mar=c(4,0,1.5,0), oma=c(0,0,0.5,0), pty="s")
  
  clustering.figure(edgelist.file, min.weight=0, min.exposure=0, 
                     deg.type="total")
  clustering.figure(edgelist.file,min.weight=20, min.exposure=0, 
                     deg.type="total")
  clustering.figure(edgelist.file, min.weight=100, min.exposure=0, 
                     deg.type="total")

  if (is.books==T) {
    clustering.figure(edgelist.file, min.weight=0, min.exposure=0, 
                       deg.type="out")
    clustering.figure(edgelist.file, min.weight=20, min.exposure=0, 
                       deg.type="out")
    clustering.figure(edgelist.file, min.weight=100, min.exposure=0, 
                       deg.type="out")
    clustering.figure(edgelist.file, min.weight=0, min.exposure=0, 
                       deg.type="in")
    clustering.figure(edgelist.file, min.weight=20, min.exposure=0, 
                       deg.type="in")
    clustering.figure(edgelist.file, min.weight=100, min.exposure=0, 
                       deg.type="in")
  }
  if (outfile!="") {
    dev.off()
  }
}

main <- function() {
  # clustering.contact.sheet(TWITTER.IN, outfile="")
  # clustering.contact.sheet(WIKIPEDIA.IN, outfile="")
  # clustering.contact.sheet(BOOKS.IN, outfile="", is.books=T)
  
  clustering.contact.sheet(TWITTER.IN, outfile="twitter_clustering.eps")
  clustering.contact.sheet(WIKIPEDIA.IN, outfile="wikipedia_clustering.eps")
  clustering.contact.sheet(BOOKS.IN, outfile="books_clustering.eps", is.books=T)
}

#main()