# Percolation: size of largest component vs. ranking of connectivity (by degree)
# Basic network analysis, following:
# http://www.slideshare.net/ianmcook/social-network-analysis-in-r

# uncomment main() to run as script.

source("../../../figures/load.R", chdir=T)

library(igraph)
library(calibrate)

DEGREE.DIR <- paste0(FIGURES.ROOT.DIR, "/fig3-hierarchy/degree/")


degree.distribution.figure <- function(lgn.graph, 
                                       cumu=T, # T for cumulative
                                       log.val="") # "xy" for log-log, "" for normal-normal
  {
  # Draw a degree distribution plot: 
  
  # choose the appropriate y-axis label
  if (cumu==T) {
    y.label <- "Fraction of nodes P(k) with connectivity k or greater"
  }
  else {
    y.label <- "Fraction of nodes P(k) with connectivity k"
  }
  
  dd <- degree.distribution(lgn.graph, cumulative=cumu)
  
  
  # Create a DF and remove vertices with probablility=0
  dd.df <- as.data.frame(cbind(1:length(dd), dd))
  colnames(dd.df) <- c("deg", "prob")
  dd.df <- dd.df[dd.df$prob!=0,]
  
  
  
  # Plot the distribution
  plot(dd.df$deg, dd.df$prob, 
       xlab="Connectivity (k)", ylab=y.label, log=log.val,
       col=1, main="", type = "p", pch = 16, cex = 1.5)
  
  # Abandoning this track...
  #d <- degree(lgn.graph, mode="all")
  #alpha.val <- power.law.fit(d, xmin=NULL)
  #lines(10:500, 10*(10:500)^(-coef(alpha.val)+1), col="green")

  #mtext(sprintf("alpha=%s", round(coef(alpha.val),3)),
  #      side=1, adj=0, padj=0, col="green", 
  #      cex=0.6, line=-1.25) # display equation
  
  # Add a power-law fit
  lm.power <- lm(log(prob+LOG.SMOOTH.ADD) ~ log(deg), data=dd.df)
  r.sq <- summary(lm.power)$adj.r.squared  
  lm.power.coefs <- coef(lm.power)
  alpha <- round(lm.power.coefs[2], 3)
  beta <- round(exp(lm.power.coefs[1]), 3)
  lines(dd.df$deg, beta*(dd.df$deg)^alpha, col="blue")
  mtext(bquote(y == .(beta)*k^.(alpha)),
        side=3, adj=1, padj=0, col="blue", cex=0.6, line=-1.25) # display equation
  mtext(sprintf("R\U00B2=%s", round(r.sq,3)), 
        side=3, adj=1, padj=0, col="blue", cex=0.6, line=-2.25) # display R-sq
}


degree.figure <- function(infile, 
                          outfile="", # "" plots to screen
                          plot.rank=TRUE, # plot rank or prob distribution
                          cumul=TRUE, # plot cumulative probability - only relevant if plot.rank==FALSE
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
      
      # Not working with small figures
      # legend("topright", legend=title.text, bty="o")
    
      # add text labels to the top num.langs.to.label 
      # textxy(c(1:num.langs.to.label),
      #        lgn.metrics$deg[1:num.langs.to.label],
      #        row.names(lgn.metrics)[1:num.langs.to.label],
      #        cx = 1, dcol = "black")
  }
  else {
    # plot the binned degree distribution
    #p <- ggplot(lgn.metrics, aes(x=deg)) + scale_x_log10() + scale_y_log10() +
    #  geom_dotplot() #+ 
    
    degree.distribution.figure(lgn.graph, 
                               cumu=cumul, # cumulative or not
                               log.val="xy") # "xy" for log-log etc.
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
  degree.figure(edgelist.file, "", plot.rank=FALSE, cumu=FALSE,
                min.common=min.common, min.exposure=MIN.EXPOSURE, 
                max.pval=DESIRED.P.VAL, deg.type="total")
  degree.figure(edgelist.file, "", plot.rank=FALSE, cumu=TRUE,
                min.common=min.common, min.exposure=MIN.EXPOSURE, 
                max.pval=DESIRED.P.VAL, deg.type="total")
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

main(DEGREE.DIR, "")