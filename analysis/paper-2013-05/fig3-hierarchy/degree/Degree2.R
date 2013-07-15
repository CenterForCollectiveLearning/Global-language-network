# Percolation: size of largest component vs. ranking of connectivity (by degree)
# Basic network analysis, following:
# http://www.slideshare.net/ianmcook/social-network-analysis-in-r

# uncomment main() to run as script.

source("../../../figures/load.R", chdir=T)

library(igraph)
library(calibrate)

DEGREE.DIR <- paste0(FIGURES.ROOT.DIR, "/fig3-hierarchy/degree/")

OUTPUT.FILE <- "figure3_users500_trans300_exp0.001_degreedist_v22.eps"

degree.distribution.figure <- function(lgn.graph, 
                                       cumul=T, # T for cumulative
                                       log.scale="", # "xy" for log-log, "" for normal-normal
                                       plot.xlim=plot.xlim,
                                       plot.ylim=plot.ylim, 
                                       src.type="") # source type
  {
  # Draw a degree distribution plot.
  
  # Start with some settings  
  NUMS <- 9 # Number of bins
  BASE <- sqrt(2) # sizes
  TAIL.START <- 3 # index of the first bin to include in power-law fitting
  
  # Logarithmically bin the degrees: bin k is 2^k wide.
  bin.sizes <- BASE^c(0:NUMS)
  bins1 <- hist(degree(lgn.graph), breaks=c(0, cumsum(bin.sizes)), plot=F)
  probs <- (bins1$counts / bin.sizes) / sum(bins1$counts / bin.sizes)
   
  y.label <- "Fraction of nodes P(k) with connectivity k" # for non-cumulative
  fig.type <- "" # Add this note to the figure
  
  if (cumul==T) {
    # Find the cumulative probability for each bin: i.e., the probability
    # of a degree to be equal to or greater of those in the bin
    probs <- cumsum(probs[length(probs):1])
    probs <- probs[length(probs):1]
    # Update y-axis label
    y.label <- "Fraction of nodes P(k) with\n connectivity k or greater"
    fig.type <- "cumulative"
  }
  
  # Plot the values, using bin centers as x-values and probabliities as y-values
  fig.title <- sprintf("%s %s\n", src.type, fig.type)
  print(fig.title)
  
  plot(bins1$mids, probs, 
       log=log.scale, xlim=plot.xlim, ylim=plot.ylim,
       main=fig.title, pch=16, cex=2, ylab=y.label)
  
  # Find the power-law fit for the tail (starting from the START.TAILth bin).
  # Put all data in a DF...
  vals.df <- data.frame(bins1$mids[TAIL.START:length(probs)],
                        probs[TAIL.START:length(probs)] )
  colnames(vals.df) <- c("x.vals", "y.vals.actual")
  
  # ...Remove rows with zeros so they don't screw the regression...
  vals.df <- subset(vals.df, vals.df$y.vals.actual!=0) 
  
  # ...Compute the model and add it to the DF to
  lm.power <- lm(log(y.vals.actual) ~ log(x.vals), data=vals.df)
  r.sq <- summary(lm.power)$adj.r.squared  
  lm.power.coefs <- coef(lm.power)
  alpha <- round(lm.power.coefs[2], 3)
  beta <- round(exp(lm.power.coefs[1]), 3)
  vals.df$y.vals.expected <- beta*((vals.df$x.vals)^alpha)
  
  # Debug
  print("mids")
  print(bins1$mids)
  print("probs")  
  print(probs)
  print("x.vals")
  print(vals.df$x.vals)
  print("actual y.vals")  
  print(vals.df$y.vals.actual)
  print("expected y.vals")
  print(vals.df$y.vals.expected)
  
  # Plot the power-law fit line and print its equation and R-sq
  with(vals.df, lines(x.vals, y.vals.expected, col="blue"))
  mtext(bquote(y == .(beta)*k^.(alpha)),
        side=3, adj=1, padj=0, col="blue", cex=0.6, line=-1.25) # display equation
  mtext(sprintf("R\U00B2=%s", round(r.sq,3)), 
        side=3, adj=1, padj=0, col="blue", cex=0.6, line=-2.25) # display adj. R-sq
}


degree.figure <- function(infile, 
                          outfile="", # "" plots to screen
                          plot.rank=TRUE, # plot rank or prob distribution
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
                          x.lab="", y.lab="", y.lab2="", # axis titles
                          plot.xlim=NULL, plot.ylim=NULL, # xlim, ylim for the plot
                          src.color="black" # color for each source {
                          ) {
  # Plot degree rank (plot.rank=TRUE) or degree distribution
  
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
    lgn.graph <<- as.undirected(lgn.graph.directed, mode="collapse")
  }
  else {
    lgn.graph <<- lgn.graph.directed
  }
  
  vertices.full.graph <- length(V(lgn.graph))
  num.langs.to.display <- min(vertices.full.graph, user.langs.to.display)
  num.langs.to.label <- min(num.langs.to.display, user.langs.to.label)
  
  # Get degree for each language
  lgn.metrics <<- data.frame(
    deg=degree(lgn.graph, mode=deg.type)
  )
  
  # Remove vertices with degree=0 from DF
  lgn.metrics <- subset(lgn.metrics, deg!=0)
  
  # order by degree rank (high to low)
  #degrees.ordered <- lgn.metrics[with(lgn.metrics, order(-deg)), ]
  lgn.metrics$dummy <- 0  # add a dummy column so R doesn't return
                          # the sorted single-column DF as a vector
  lgn.metrics <- lgn.metrics[with(lgn.metrics, order(-deg)), ]
  lgn.metrics$dummy <- NULL
  
  if (outfile != "") {
    postscript(outfile)
  }
  # par(mar=c(4,4,2,5)+.1, pty="s")

  if(plot.rank==TRUE) {
      # plot degree by rank
    
      # Print source, deg.type, and min. weight 
      title.text <- sprintf("%s/%s degree/undir=%s\n%s/expo>=%s/pval<%sconn=%s", 
                            basename(infile),
                            deg.type, convert.to.undirected,
                            min.common, min.exposure, max.pval,comp.conn.mode)
      
      # Plot!
      plot(c(1:num.langs.to.display), 
           lgn.metrics$deg[1:num.langs.to.display],
           xlab=x.lab, ylab=y.lab,
           xaxt=plot.x.axis, yaxt=plot.size.y.axis,
           xlim=plot.xlim, ylim=plot.ylim,
           main=title.text,
           type="p", pch = 16, cex = 2, col=src.color,
           cex.lab=1.5) # set point shape and size
      
      textxy(1:length(lgn.metrics$deg),
            lgn.metrics$deg,
            rownames(lgn.metrics),
            cx = 1, dcol = "black" )
      
  }
  else {    
    degree.distribution.figure(lgn.graph, 
                               cumul=TRUE, # cumulative or not
                               log.scale="xy", # "xy" for log-log etc.
                               plot.xlim=plot.xlim, plot.ylim=plot.ylim, 
                               src.type=basename(infile) ) 
    degree.distribution.figure(lgn.graph, 
                               cumul=FALSE, # cumulative or not
                               log.scale="xy", # "xy" for log-log etc.
                               plot.xlim=plot.xlim, plot.ylim=plot.ylim, 
                               src.type=basename(infile))
  }
      
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
  
  degree.figure(edgelist.file, "", plot.rank=TRUE,
                     min.common=min.common, min.exposure=MIN.EXPOSURE, 
                     max.pval=DESIRED.P.VAL, deg.type="total", 
                     user.langs.to.display=50, user.langs.to.label=15)
  degree.figure(edgelist.file, "", plot.rank=FALSE,
                min.common=min.common, min.exposure=MIN.EXPOSURE, 
                plot.xlim=c(0.4,60), plot.ylim=c(0.001,1.1),
                max.pval=DESIRED.P.VAL, deg.type="total")
#   degree.figure(edgelist.file, "", plot.rank=FALSE, cumu=TRUE,
#                 min.common=min.common, min.exposure=MIN.EXPOSURE, 
#                 max.pval=DESIRED.P.VAL, deg.type="total")
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

main(DEGREE.DIR, OUTPUT.FILE)