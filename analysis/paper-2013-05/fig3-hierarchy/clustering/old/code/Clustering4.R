# Clustering: plot clustering coefficient (aka transitivity) 
# vs. degree of language group, add power and exponential fit lines. 
# Note: vertices with degree=0 or clustering=0 are removed from the plot.

# TODO: fix folder settings. 
# uncomment main() to run as script.

library(igraph)
library(calibrate)
library(combinat)

FIGURES.ROOT.DIR <- "~/LangsDev/net-langs/figures/"

DATA.DIR <- paste0(FIGURES.ROOT.DIR, "Data/")
CLUSTER.DIR <- paste0(FIGURES.ROOT.DIR, "Fig3-Hierarchical/Clustering/")

TWITTER.IN <- "twitter_langlang_std.tsv"
WIKIPEDIA.IN <- "wikipedia_langlang_std.tsv"
BOOKS.IN <- "books_langlang_std.tsv"

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
                              min.weight=0, # discard links with lower weights
                              min.exposure=0, # discard links with lower exposure
                              max.pval=1000, # discard links with a higher p-value
                              deg.type="total", # total/out/in
                              x.lab="", y.lab="" # axis titles
                              )
{
  # Create a network from infile, plot a clustering vs. degree
  # figure and save to outfile; vertices with clustering=0 are removed.
  # outfile="" to plot to screen.
  
  # load data
  setwd(DATA.DIR)
  edgelist <- read.csv(infile, sep = "\t", header=T)
  setwd(CLUSTER.DIR)
  # Create the graph using the stronger links
  lgn.graph <<- graph.data.frame(
    edgelist[edgelist$common.num>=min.weight 
             & edgelist$pval<max.pval
             & edgelist$exposure>=min.exposure,],
    directed=TRUE)
  
  neighbor.table <<- neighborhood(lgn.graph, 0) 
  
  deg.undir=degree(as.undirected(lgn.graph, mode="collapse"))
  
  lgn.metrics <- data.frame(
    deg=degree(lgn.graph, mode=deg.type),
    deg2=deg.undir,
    clustering=transitivity(lgn.graph, type="local", 
                            vids=V(lgn.graph), isolates="zero"),
    tris=triangles(lgn.graph),
    my.clustering=2*triangles(lgn.graph)/(deg.undir*(deg.undir-1))
  )
  
  #all.neighbors <<- neighborhood(lgn.graph, 0)
  
  
# THIS IS NOT NECESSARY AS LGN.GRAPH ISN'T USED FURTHER, CONSIDER DELETING
  # Remove vertices with clustering=0 or degree=0
  # Based on http://biocodenv.com/wordpress/?p=68:
#   lgn.graph <- delete.vertices( lgn.graph, 
#                                which(transitivity(lgn.graph, type="local")==0 |
#                                  degree(lgn.graph, mode=deg.type)) )
  
  # Remove vertices with clustering=0 or degree=0 from DF
  lgn.metrics <-lgn.metrics[!(lgn.metrics$clustering==0 | lgn.metrics$deg==0),]
  # order by degree rank
  lgn.metrics <- lgn.metrics[order(lgn.metrics$deg), ]
  
  if (outfile != "") {
    postscript(outfile)
  }
  #par(mar=c(4,4,2,5)+.1, pty="s")
    
  # Print source, deg.type, and min. weight
  title.text <- sprintf("%s/%s degree/%s/min_expo=%s/p<%s", 
                        gsub("_.*$", "", x=infile),
                        deg.type, min.weight, min.exposure, max.pval)
  
  # print the lgn.metrics to make it post-processing of figures easier.
  print(title.text)
  print(lgn.metrics[order(lgn.metrics$deg, -lgn.metrics$clustering), ])
  print(lgn.metrics[])
  print("*************")
  
  # Plot!
  plot(lgn.metrics$deg, 
       lgn.metrics$clustering,
       xlab = x.lab, ylab=y.lab,
       main = title.text, 
       type = "p", pch = 16, cex = 1.2,
       cex.lab=0.8) # set point shape and size
  
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
  # Plot combinatons of min.weight and degree type for given source
  # For Twitter and Wikipedia, total=in=out, because all links are reciprocal
  # (e.g., link indicates common users per language) 
  if (outfile!="") {
    postscript(outfile)
  }
  #par(mfrow=c(3,3), mar=c(4,0,1.5,0), oma=c(0,0,0.5,0), pty="s")
  par(mfrow=c(1,1), mar=c(4,0,1.5,0), oma=c(0,0,0.5,0), pty="s")
  
  def.xlab = "Connectivity (k)"
  def.ylab = "Clustering coefficient (C)"
  
#   clustering.figure(edgelist.file, min.weight=0, min.exposure=0.01, 
#                      deg.type="total")
#   clustering.figure(edgelist.file,min.weight=20, min.exposure=0.01, 
#                      deg.type="total")
  clustering.figure(edgelist.file, 
                    min.weight=100, min.exposure=0.01, max.pval=0.001,
                    x.lab=def.xlab, y.lab=def.ylab,
                    deg.type="total")
  
  if (is.books==T) {
#     clustering.figure(edgelist.file, min.weight=0, min.exposure=0.01, 
#                        deg.type="out")
#     clustering.figure(edgelist.file, min.weight=20, min.exposure=0.01, 
#                        deg.type="out")
    clustering.figure(edgelist.file, 
                      min.weight=100, min.exposure=0.01, max.pval=0.001,
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="out")
#     clustering.figure(edgelist.file, min.weight=0, min.exposure=0.01, 
#                        deg.type="in")
#     clustering.figure(edgelist.file, min.weight=20, min.exposure=0.01, 
#                        deg.type="in")
    clustering.figure(edgelist.file, min.weight=100, min.exposure=0.01, 
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="in")
  }
  if (outfile!="") {
    dev.off()
  }
}

main <- function() {
  clustering.figure(BOOKS.IN, outfile="", min.weight=25, min.exposure=0.01, max.pval=0.001)
#   g <- erdos.renyi.game(5, 0.8)
#   plot(g)
#   tris <<- triangles(g)

#   clustering.contact.sheet(TWITTER.IN, outfile="")
#   clustering.contact.sheet(WIKIPEDIA.IN, outfile="")
#   clustering.contact.sheet(BOOKS.IN, outfile="", is.books=T)
  
#   clustering.contact.sheet(TWITTER.IN, outfile="twitter_clustering.eps")
#   clustering.contact.sheet(WIKIPEDIA.IN, outfile="wikipedia_clustering.eps")
#   clustering.contact.sheet(BOOKS.IN, outfile="books_clustering.eps", is.books=T)
}

main()