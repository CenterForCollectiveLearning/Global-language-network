# Clustering: plot clustering coefficient (aka transitivity) 
# vs. degree of language group, add power and exponential fit lines. 
# Note: vertices with degree=0 or clustering=0 are removed from the plot.

source("../../figures/load.R", chdir=T)

# TODO: fix folder settings. 
# uncomment main() to run as script.

library(igraph)
library(calibrate)
library(combinat)

#FIGURES.ROOT.DIR <- "~/LangsDev/net-langs/figures/"

#DATA.DIR <- paste0(FIGURES.ROOT.DIR, "Data/")
CLUSTER.DIR <- paste0(FIGURES.ROOT.DIR, "/fig2-hierarchy/")

triangles <- function(orig.g) {
  # Count number of triangles for each vertex.
  # Turns out this produces the same results as triangle counting for
  # transitivity(), so no need to use it.
  
  # Convert to undirected graph; from docs:
  # One undirected edge will be created for each pair of vertices which 
  # are connected with at least one directed edge, no multiple edges 
  # will be created.
  g <- as.undirected(orig.g, mode="collapse")
  
  triangle.list <- c()
  for(vertex.id in 1:vcount(g)) {
    
    # find neighbors of a vertex.id
    neighbors.for.vertex <- neighbors(g, vertex.id)
    
    if (length(neighbors.for.vertex)==0) {
      # no neighbors, skip to next vertex
      triangle.list <- c(triangle.list, 0)
      next
    }
    
    # get all possible links between neighbors. c() passes a list even
    # if there's only a single number, otherwise combn() runs differently 
    neigh.combinations <- combn2(c(neighbors.for.vertex))
    
    if (nrow(neigh.combinations)==0) {
      # no links means no potential triangles, skip to next vertex
      triangle.list <- c(triangle.list, 0)
      next
    }
    
    links.between.neighbors <- 0
    for(potential.edge.num in 1:nrow(neigh.combinations)) {
      # check if a pair is linked in the graph. Linked neighbors
      # for a linked with tested vertrx.
      if (T==are.connected(g, 
                           neigh.combinations[potential.edge.num, 1], 
                           neigh.combinations[potential.edge.num, 2])) {
        links.between.neighbors <- links.between.neighbors+1
      }
    }
    
    # update number of triangles for node
    triangle.list <- c(triangle.list, links.between.neighbors)
    msg <- sprintf("***ID: %s | num_neigh: %s | neigh_combins: %s | num_tri: %s ***",
                   vertex.id, 
                   length(neighbors.for.vertex), 
                   nrow(neigh.combinations),
                   triangle.list[vertex.id])
    print(msg)
  }
  
  return(triangle.list)
}

clustering.figure <- function(infile, 
                              outfile="", # "" plots to screen
                              convert.to.undirected=T, # directed/undirected
                              min.weight=0, # discard links with lower weights
                              min.exposure=0, # discard links with lower exposure
                              max.pval=1000, # discard links with a higher p-value
                              deg.type="total", # total/out/in
                              plot.x.axis = "s", # x-axis: "s" to plot, "n" to not
                              plot.y.axis="s", # left y axis: "s" to plot, "n" to not
                              x.lab="", y.lab="", # axis titles
                              plot.xlim=NULL, plot.ylim=NULL # xlim, ylim for the plot
                              )
{
  # Create a network from infile, plot a clustering vs. degree
  # figure and save to outfile; vertices with clustering=0 are removed.
  # outfile="" to plot to screen.
  # NOTE: transitivity() ignores direction for triangles, but (probably) not
  # for calculating the degree.
  
  # load data
  setwd(DATA.DIR)
  edgelist <- read.csv(infile, sep = "\t", header=T)
  # we want to create a weighted graph so we change "exposure" to
  # "weight" to let igraph know
  colnames(edgelist)[7] <- "weight"
  setwd(CLUSTER.DIR)
  # Create the graph using the stronger links
  lgn.graph.directed <- graph.data.frame(
    edgelist[edgelist$common.num>=min.weight 
             & edgelist$pval<max.pval
             & edgelist$weight>=min.exposure,],)
  
  # use directed or undirected graph. Note that the directed= instruction in
  # graph.data.frame only tells whether the edgelist is directed or not (which
  # in our case it is), not the graph.
  if (convert.to.undirected==T) {
    lgn.graph <- as.undirected(lgn.graph.directed, mode="collapse")
  }
  else {
    lgn.graph <- lgn.graph.directed
  }
  
  lgn.metrics <- data.frame(
    deg=degree(lgn.graph, mode=deg.type),
    clustering=transitivity(lgn.graph, type="local", 
                            vids=V(lgn.graph), isolates="zero")
  )
  
  # Remove vertices with clustering=0 or degree=0 from DF
  lgn.metrics <-lgn.metrics[!(lgn.metrics$clustering==0 | lgn.metrics$deg==0),]
  # order by degree rank
  lgn.metrics <- lgn.metrics[order(lgn.metrics$deg), ]
  
  if (outfile != "") {
    postscript(outfile)
  }
  #par(mar=c(4,4,2,5)+.1, pty="s")
    
  # Print source, deg.type, and min. weight
  title.text <- sprintf("%s/%s degree/undir=%s\n%s/min_expo=%s/p<%s", 
                        gsub("_.*$", "", x=infile),
                        deg.type, convert.to.undirected, 
                        min.weight, min.exposure, max.pval)
  
  # print the lgn.metrics to make it post-processing of figures easier.
  print(title.text)
  print(sprintf("# langs with clustering=1.0: %s", 
                nrow(lgn.metrics[lgn.metrics$clustering==1,])) )
  print(lgn.metrics[order(lgn.metrics$deg, -lgn.metrics$clustering), ])
  print("*************")
  
  # Plot!
  plot(lgn.metrics$deg, 
       lgn.metrics$clustering,
       xlab = x.lab, ylab=y.lab,
       main = title.text, 
       xlim=plot.xlim, ylim=plot.ylim,
       xaxt=plot.x.axis, yaxt=plot.y.axis,
       type = "p", pch = 16, cex = 2,
       cex.lab=2) # set point shape and size
  
  # add text labels to the top num.langs.to.label 
  textxy(lgn.metrics$deg,
         lgn.metrics$clustering,
         rownames(lgn.metrics),
         cx = 1, dcol = "black" )
  
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
  # NOTE: calculates correlation for a directed graph.
  
  # Plot combinatons of min.weight and degree type for given source
  # For Twitter and Wikipedia, total=in=out, because all links are reciprocal
  # (e.g., link indicates common users per language) 
  if (outfile!="") {
    postscript(outfile)
  }
  par(mfrow=c(3,3), mar=c(4,0,1.5,0), oma=c(0,0,0.5,0), pty="s")
  #par(mfrow=c(1,1), mar=c(4,0,1.5,0), oma=c(0,0,0.5,0), pty="s")
  
  def.xlab = "Connectivity (k)"
  def.ylab = "Clustering coefficient (C)"
  
  clustering.figure(edgelist.file, convert.to.undirected=F,
                    min.weight=0, min.exposure=0.01,
                    x.lab=def.xlab, y.lab=def.ylab,
                    deg.type="total")
  clustering.figure(edgelist.file, convert.to.undirected=F,
                    min.weight=20, min.exposure=0.01, 
                    x.lab=def.xlab, y.lab=def.ylab,
                    deg.type="total")
  clustering.figure(edgelist.file, convert.to.undirected=F,
                    min.weight=100, min.exposure=0.01, max.pval=0.001,
                    x.lab=def.xlab, y.lab=def.ylab,
                    deg.type="total")
  
  if (is.books==T) {
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.weight=0, min.exposure=0.01, 
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="out")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.weight=20, min.exposure=0.01, 
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="out")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.weight=100, min.exposure=0.01, max.pval=0.001,
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="out")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.weight=0, min.exposure=0.01,
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="in")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.weight=20, min.exposure=0.01, 
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="in")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.weight=100, min.exposure=0.01, max.pval=0.001,
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="in")
  }
  if (outfile!="") {
    dev.off()
  }
}

main <- function() {  
  
  par(mfrow=c(3,2), pty="s", mar=c(1.5,1,1.5,0.5), oma=c(0.5,0.5,0.5,0.5))
  
  def.xlab = "Connectivity (k)"
  def.ylab = "Clustering coefficient (C)"
  
  # This sheet shows the difference between convert.to.undirected T and F. 
  clustering.figure(TWITTER.IN, outfile="", 
                    min.weight=100, min.exposure=0.01, max.pval=0.001,
                    x.lab=def.xlab, y.lab=def.ylab)
  clustering.figure(TWITTER.IN, outfile="", convert.to.undirected=F,
                    min.weight=100, min.exposure=0.01, max.pval=0.001,
                    x.lab=def.xlab, y.lab=def.ylab)
  clustering.figure(WIKIPEDIA.IN, outfile="", 
                    min.weight=100, min.exposure=0.01, max.pval=0.001,
                    x.lab=def.xlab, y.lab=def.ylab)
  clustering.figure(WIKIPEDIA.IN, outfile="", convert.to.undirected=F,
                    min.weight=100, min.exposure=0.01, max.pval=0.001,
                    x.lab=def.xlab, y.lab=def.ylab)
  clustering.figure(BOOKS.IN, outfile="", 
                    min.weight=25, min.exposure=0.01, max.pval=0.001,
                    x.lab=def.xlab, y.lab=def.ylab)
  clustering.figure(BOOKS.IN, outfile="", convert.to.undirected=F,
                    min.weight=25, min.exposure=0.01, max.pval=0.001,
                    x.lab=def.xlab, y.lab=def.ylab)

#   clustering.contact.sheet(TWITTER.IN, outfile="")
#   clustering.contact.sheet(WIKIPEDIA.IN, outfile="")
#   clustering.contact.sheet(BOOKS.IN, outfile="", is.books=T)
  
#   clustering.contact.sheet(TWITTER.IN, outfile="twitter_clustering.eps")
#   clustering.contact.sheet(WIKIPEDIA.IN, outfile="wikipedia_clustering.eps")
#   clustering.contact.sheet(BOOKS.IN, outfile="books_clustering.eps", is.books=T)
}

#main()