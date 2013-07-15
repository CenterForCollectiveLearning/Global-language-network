# Basic network analysis, following:
# http://www.slideshare.net/ianmcook/social-network-analysis-in-r

# Percolation: size of largest component vs. ranking of connectivity (by degree)
library(igraph)
# info on graph structure: http://igraph.sourceforge.net/doc/R/structure.info.html
# manipulate structure: http://igraph.sourceforge.net/doc/R/graph.structure.html

# load data
setwd("~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Data/")
edgelist <- read.csv("merged_langlang.tsv", sep = "\t", header=T)
setwd("~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Fig3-Hierarchical/Percolation/")

lgn_graph <- graph.data.frame(edgelist, directed=TRUE)

lgn_metrics <- data.frame(
  deg=degree(lgn_graph),
  bet=betweenness(lgn_graph),
  clo=closeness(lgn_graph),
  eig=evcent(lgn_graph)$vector,
  cor=graph.coreness(lgn_graph)
)

# sort by decreasing degree
lgn_metrics_by_deg <- lgn_metrics[order(lgn_metrics$deg, decreasing=TRUE), ]
lgn_graph_chopped <- lgn_graph
#lgn_giant_comp_sizes <-  vcount(lgn_graph) # vector to hold sizes, start with size of full graph
lgn_giant_comp_sizes <-  c() # vector to hold sizes

for(i in 1:length(lgn_metrics_by_deg$deg)) {
  # add size of current largest component (first on the returned list)
  current_giant_comp_size = clusters(lgn_graph_chopped)$csize[1]
  lgn_giant_comp_sizes = c(lgn_giant_comp_sizes, current_giant_comp_size)
  
  # debug: print current degree and size of giant component
  #print(c(lgn_metrics_by_deg$deg[i], current_giant_comp_size))
  
  # remove the most connected language at given time
  lgn_graph_chopped = delete.vertices(lgn_graph_chopped, 
                                      row.names(lgn_metrics_by_deg)[i])
}

par(mar=c(4,4,2,5)+.1)

num.langs.to.display = 25
num.langs.to.label = 15

plot(c(1:num.langs.to.display), 
     lgn_giant_comp_sizes[1:num.langs.to.display],
     xlab = "Degree rank of language group", 
     ylab = "Size of largest connected component",
     main = "LGN Percolation Analysis", 
     type = "p", pch = 16, cex = 0.6,
     cex.lab=1.2) # set point shape and size

# add text labels to the top num.langs.to.label
library(calibrate)
textxy(c(1:num.langs.to.label),
       lgn_giant_comp_sizes,
       rownames(lgn_metrics_by_deg),
       cx = 0.65, dcol = "black" )

# add another y-axis w/ percentages 
par(new=TRUE)
plot(c(1:num.langs.to.display),
     lgn_giant_comp_sizes[1:num.langs.to.display]/141*100,
     type="n",col="blue",xaxt="n",yaxt="n",xlab="",ylab="")
axis(4)
mtext("Percentage of largest component",side=4,line=3,cex=1.2)
