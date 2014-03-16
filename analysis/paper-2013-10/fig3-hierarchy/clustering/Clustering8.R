# Clustering: plot clustering coefficient (aka transitivity) 
# vs. degree of language group, add power and exponential fit lines. 
# Note: vertices with degree=0 or clustering=0 are removed from the plot.

# uncomment main() to run as a standalone script.

source("../../load.R", chdir=T)

library(igraph)
library(calibrate)
library(combinat)

CLUSTER.DIR <- paste0(ANALYSIS.ROOT.DIR, "/fig3-hierarchy/clustering")

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
                              min.common=0, # discard links with lower weights
                              min.exposure=0, # discard links with lower exposure
                              max.pval=9999, # discard links with a higher p-value
                              weighted.graph=F,
                              weight.column="exposure", # which column to use for weight
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
  edgelist <- read.filtered.edgelist(infile,
                                     min.common=min.common, # common speakers/books
                                     min.exposure=min.exposure, # exposure score
                                     desired.p.val=max.pval, # max p-val
                                     weighted.graph=weighted.graph,
                                     weight.column=weight.column)
  print(head(edgelist))
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
  
  # Use "weighted" clustering for weighted graph or "local" for unweighted
  clustering.type <- if(weighted.graph==T) "weighted" else "local"
  
  print(lgn.graph)
  print(sprintf("Using %s clustering (if weighted, using %s for weight)",
                clustering.type,weight.column))
  
  lgn.metrics <- data.frame(
    deg=degree(lgn.graph, mode=deg.type),
    clustering=transitivity(lgn.graph, type=clustering.type, #type="local", 
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
                        basename(infile),
                        deg.type, convert.to.undirected, 
                        min.common, min.exposure, max.pval)
  
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
  
  # Plot combinatons of min.common and degree type for given source
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
                    min.common=0, min.exposure=0.01,
                    x.lab=def.xlab, y.lab=def.ylab,
                    deg.type="total")
  clustering.figure(edgelist.file, convert.to.undirected=F,
                    min.common=20, min.exposure=0.01, 
                    x.lab=def.xlab, y.lab=def.ylab,
                    deg.type="total")
  clustering.figure(edgelist.file, convert.to.undirected=F,
                    min.common=100, min.exposure=0.01, max.pval=0.001,
                    x.lab=def.xlab, y.lab=def.ylab,
                    deg.type="total")
  
  if (is.books==T) {
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.common=0, min.exposure=0.01, 
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="out")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.common=20, min.exposure=0.01, 
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="out")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.common=100, min.exposure=0.01, max.pval=0.001,
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="out")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.common=0, min.exposure=0.01,
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="in")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.common=20, min.exposure=0.01, 
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="in")
    clustering.figure(edgelist.file, convert.to.undirected=F,
                      min.common=100, min.exposure=0.01, max.pval=0.001,
                      x.lab=def.xlab, y.lab=def.ylab,
                      deg.type="in")
  }
  if (outfile!="") {
    dev.off()
  }
}

main.exposure.expected <- function(output.dir, output.file="") {  
  # This sheet shows the difference between actual exposure and expected exposure
  # Notice that the latter pulls data from a special LANGLANG file
  # (prepare in figure3_all_expected_exposures.R)
  orig.dir <- setwd(output.dir) 
  
  if (output.file!='') {
    postscript(output.file)
  }
  
  par(mfrow=c(3,3), pty="s", mar=c(1.5,1,1.5,0.5), oma=c(0.5,0.5,0.5,0.5))
  
  def.xlab = "Connectivity (k)"
  def.ylab = "Clustering coefficient (C)"
  
  clustering.figure("../table3a_hierarchy_expected_exposure_twit.tsv", outfile="", 
                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                    weighted.graph=F,
                    max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab) # unweighted
  clustering.figure("../table3a_hierarchy_expected_exposure_twit.tsv", outfile="", 
                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                    weighted.graph=T, weight.column="exposure",
                    max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab) # exposure
  clustering.figure("../table3a_hierarchy_expected_exposure_twit.tsv", 
                    outfile="",
                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                    weighted.graph=T, weight.column="exposure.exp",
                    max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab) # expected exposure
  
  clustering.figure("../table3a_hierarchy_expected_exposure_wiki.tsv", outfile="", 
                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                    weighted.graph=F,
                    max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab) # unweighted
  clustering.figure("../table3a_hierarchy_expected_exposure_wiki.tsv", outfile="", 
                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                    weighted.graph=T, weight.column="exposure",
                    max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab) # exposure
  clustering.figure("../table3a_hierarchy_expected_exposure_wiki.tsv", 
                    outfile="",
                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                    weighted.graph=T, weight.column="exposure.exp",
                    max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab) # expected exposure
  
  clustering.figure("../table3a_hierarchy_expected_exposure_book.tsv", outfile="", 
                    min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                    weighted.graph=F,
                    max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab) # unweighted
  clustering.figure("../table3a_hierarchy_expected_exposure_book.tsv", outfile="", 
                    min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                    weighted.graph=T, weight.column="exposure",
                    max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab) # exposure
  clustering.figure("../table3a_hierarchy_expected_exposure_book.tsv", 
                    outfile="",
                    min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                    weighted.graph=T, weight.column="exposure.exp",
                    max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab) # expected exposure
  
#   clustering.contact.sheet(TWIT.STD.LANGLANG, outfile="")
#   clustering.contact.sheet(WIKI.STD.LANGLANG, outfile="")
#   clustering.contact.sheet(BOOKS.STD.LANGLANG, outfile="", is.books=T)
  
#   clustering.contact.sheet(TWITTER.IN, outfile="twitter_clustering.eps")
#   clustering.contact.sheet(WIKI.STD.LANGLANG, outfile="wikipedia_clustering.eps")
#   clustering.contact.sheet(BOOKS.STD.LANGLANG, outfile="books_clustering.eps", is.books=T)
  
  if (output.file!='') {
    dev.off()
  }
  
  setwd(orig.dir)
}


main.directred.undirected <- function(output.dir, output.file="") { 
# This sheet shows the difference between convert.to.undirected T and F.   
  
  orig.dir <- setwd(output.dir) 
    
    if (output.file!='') {
      postscript(output.file)
    }
    
    par(mfrow=c(3,2), pty="s", mar=c(1.5,1,1.5,0.5), oma=c(0.5,0.5,0.5,0.5))
    
    def.xlab = "Connectivity (k)"
    def.ylab = "Clustering coefficient (C)"
  
  clustering.figure(TWIT.STD.LANGLANG, outfile="", 
                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab)
  clustering.figure(TWIT.STD.LANGLANG, outfile="", convert.to.undirected=F,
                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab)
  
  clustering.figure(WIKI.STD.LANGLANG, outfile="", weight.column="exposure.exp",
                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab)
  clustering.figure(WIKI.STD.LANGLANG, outfile="", convert.to.undirected=F,
                   min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, max.pval=DESIRED.P.VAL,
                   x.lab=def.xlab, y.lab=def.ylab)
  
  clustering.figure(BOOKS.STD.LANGLANG, outfile="", 
                    min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab)
  clustering.figure(BOOKS.STD.LANGLANG, outfile="", convert.to.undirected=F,
                    min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, max.pval=DESIRED.P.VAL,
                    x.lab=def.xlab, y.lab=def.ylab)
  
  if (output.file!='') {
    dev.off()
  }
  
  setwd(orig.dir)
}

main.exposure.expected(CLUSTER.DIR, 'clustering_comparison.pnas.eps')