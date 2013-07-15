# Percolation: size of largest component vs. ranking of connectivity (by degree)
# Basic network analysis, following:
# http://www.slideshare.net/ianmcook/social-network-analysis-in-r

library(igraph)
library(calibrate)

PERCOL.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Fig3-Hierarchical/Percolation/"
DATA.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Data/"

TWITTER.IN <- "twitter_langlang_std.tsv"
WIKIPEDIA.IN <- "wikipedia_langlang_std.tsv"
BOOKS.IN <- "books_langlang_std.tsv"

#percolation.figure <- function(infile, outfile, min.weight=0, conn.type="total") {
  # Create a network from infile, plot a percolation analysis
  # figure and save to outfile; outfile="" to plot to screen.
  infile <-   TWITTER.IN
  outfile <- "twitter_0_percol.tsv"
  conn.type <- "total"
  min.weight<-100

  # load data
  setwd(DATA.DIR)
  edgelist <- read.csv(infile, sep = "\t", header=T)
  setwd(PERCOL.DIR)
  
  # Create the graph
  print(names(edgelist))
  lgn.graph <- graph.data.frame(
    edgelist[edgelist$common.num>=min.weight,],
    directed=TRUE)
  
  # Find the matrix 
#   lgn.metrics <- data.frame(
#     total.deg=degree(lgn.graph),
#     out.deg=degree(lgn.graph, mode="out"),
#     in.deg=degree(lgn.graph, mode="in"),
#     bet=betweenness(lgn.graph),
#     clo=closeness(lgn.graph),
#     eig=evcent(lgn.graph)$vector,
#     cor=graph.coreness(lgn.graph)
#   )
  

  # For later use
  vertices.full.graph <- length(V(lgn.graph))
  
#   # sort by decreasing degree
#   if (conn.type=="total") {
#     lgn.metrics.by.connectivity <- 
#       lgn.metrics[order(lgn.metrics$total.deg, decreasing=TRUE), ]  
#   }
#   else if (conn.type=="out") {
#     lgn.metrics.by.connectivity <- 
#       lgn.metrics[order(lgn.metrics$out.deg, decreasing=TRUE), ]
#   }
#   else if (conn.type=="in") {
#     lgn.metrics.by.connectivity <- 
#       lgn.metrics[order(lgn.metrics$in.deg, decreasing=TRUE), ]
#   }
#   else {
#     lgn.metrics.by.connectivity <- 
#       lgn.metrics[order(lgn.metrics$bet, decreasing=TRUE), ]
#   }
  
  lgn.graph.chopped <- lgn.graph
  lgn.giant.comp.sizes <-  c() # vector to hold sizes
  
  # find size of largest component in each scenario
  #for(i in 1:length(V(lgn.graph))) {
for(i in 1:5) {
    # add size of current largest component (first on the returned list)
    # we're looking for a strongly connected component (i.e., direct path)
    current.giant.comp.size = max(clusters(lgn.graph.chopped, mode="strong")$csize)
    print(current.giant.comp.size)
    lgn.giant.comp.sizes = c(lgn.giant.comp.sizes, current.giant.comp.size)
    
    # debug: print current degree and size of giant component
    #print(c(lgn.metrics.by.connectivity$total.deg[i], ":", current.giant.comp.size))
    
    # remove the most connected language at given time
    # print(row.names(lgn.metrics.by.connectivity)[i])
  
    #lgn.graph.chopped <- delete.vertices(lgn.graph.chopped, 
    #                                    row.names(lgn.metrics.by.connectivity)[i])
    # Find most connected vertex and remove it.
    total.deg=degree(lgn.graph.chopped, mode="total")
    df <- data.frame(total.deg=total.deg, name=names(total.deg))
    df <- df[order(df$total.deg, decreasing=TRUE), ]
    print(c(rownames(df[1,]),":", df[1,1]))
    most.connected <- rownames(df[1,])
    lgn.graph.chopped <- delete.vertices(lgn.graph.chopped, most.connected )
    df <-df[!rownames(df)==most.connected,]

    l <- layout.fruchterman.reingold(lgn.graph.chopped,
                                     #seed="eng",
                                     niter=1000,
                                     area=vcount(lgn.graph)^2.3,
                                     repulserad=vcount(lgn.graph)^3 )
    
    #plot graph
    par(pty="s")
    tkplot(lgn.graph.chopped, layout = l, 
           #vertex.size = 20*evcent(lgn.graph)$vector, # size as evcent
           vertex.frame.color = NA,
           #vertex.size = (log(lgn.metrics$num+1)*4.0), # discrete sizes?
           edge.color = rgb(.2, .2, .7, E(lgn.graph.chopped)$exposure),
           edge.width=E(lgn.graph)$exposure*5,
           vertex.label = as.character(rownames(df)),
           #vertex.label.cex = log(lgn.metrics$num+1)/2,
           #vertex.color = rgb(.2, .2, .7, degree(lgn.graph, mode="out")$vector/degree(lgn.graph, mode="in")$vector),
           vertex.color = 5,
           edge.curved = T, # to show reciprocal edges
           edge.arrow.size =  0.5) #(lgn.graph)$exposure*5) #0.8 )
    #edge.label=round(E(lgn.graph)$exposure,2)
    title(main=sprintf("will remove: %s, giant comp.: %s", most.connected, current.giant.comp.size ),)
    
    #
    #lgn.metrics <-lgn.metrics[!(rownames(lgn.metrics)=="eng"),]
  }
  
#   if (outfile != "") {
#     postscript(outfile)
#   }
  par(mar=c(4,4,2,5)+.1, pty="s")
  
  num.langs.to.display = 50
  num.langs.to.label = 15
  
  plot(c(1:num.langs.to.display), 
       lgn.giant.comp.sizes[1:num.langs.to.display],
       xlab = "Degree rank of language group", 
       ylab = "Size of largest connected component",
       #main = "LGN Percolation Analysis", 
       type = "p", pch = 16, cex = 0.6,
       cex.lab=0.8) # set point shape and size
  
  legend("topright", legend=sprintf("%s", conn.type), bty="n")
  
  # add text labels to the top num.langs.to.label 
  textxy(c(1:num.langs.to.label),
         lgn.giant.comp.sizes,
         rownames(lgn.graph),
         cx = 0.65, dcol = "black" )
  
  # add another y-axis w/ percentages 
  par(new=TRUE)
  plot(c(1:num.langs.to.display),
       lgn.giant.comp.sizes[1:num.langs.to.display]/vertices.full.graph*100,
       type="n",col="blue",xaxt="n",yaxt="n",xlab="",ylab="")
  axis(4)
  mtext("Percentage of largest component",side=4,line=3,cex=0.8)
#   if (outfile != "") {
#     dev.off()
#   }
#}

# plot.quartet <- function(infile, outfile, src.name, min.weight=0) {
#   # Weight threshold is the min. number of speakers/translations
#   # for a language to be included
#   if (outfile != "") {
#     postscript(outfile)
#   }
# #   par(mfrow=c(2,2),oma = c(0, 0, 3, 0))
#   percolation.figure(infile, outfile, 
#                      min.weight=min.weight, conn.type="total")
# #   percolation.figure(infile, outfile, 
# #                      min.weight=min.weight, conn.type="out")
# #   percolation.figure(infile, outfile, 
# #                      min.weight=min.weight, conn.type="in")
# #   percolation.figure(infile, outfile, 
# #                      min.weight=min.weight, conn.type="bet")
#   mtext(sprintf("%s >= %s", src.name, min.weight), outer = TRUE, cex = 1)
#   if (outfile != "") {
#     dev.off()
#   }
# }
# 
# #### Main ####
# op <- par(mfrow=c(2,2),oma = c(0, 0, 3, 0))
# plot.quartet(TWITTER.IN, "", src.name="Twitter", min.weight=100)
# # plot.quartet(TWITTER.IN, "twitter20.eps", src.name="Twitter", min.weight=20)
# # plot.quartet(TWITTER.IN, "twitter100.eps", src.name="Twitter", min.weight=100)
# # 
# # par(mfrow=c(2,2),oma = c(0, 0, 3, 0))
# # plot.quartet(WIKIPEDIA.IN, "wikipedia0.eps", src.name="Wikipedia")
# # plot.quartet(WIKIPEDIA.IN, "wikipedia20.eps", src.name="Wikipedia", min.weight=20)
# # plot.quartet(WIKIPEDIA.IN, "wikipedia100.eps", src.name="Wikipedia", min.weight=100)
# # 
# # par(mfrow=c(2,2),oma = c(0, 0, 3, 0))
# # plot.quartet(BOOKS.IN, "books0.eps", src.name="Books")
# # plot.quartet(BOOKS.IN, "books20.eps", src.name="Books", min.weight=20)
# # plot.quartet(BOOKS.IN, "books100.eps", src.name="Books", min.weight=100)
# 
# par(op)
