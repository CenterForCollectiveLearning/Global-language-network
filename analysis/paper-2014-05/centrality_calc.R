ANALYSIS.ROOT.DIR <- normalizePath(".")

TWIT.STD.LANGLANG2 <- paste0(ANALYSIS.ROOT.DIR, "/TwitterNetwork.tsv")
WIKI.STD.LANGLANG2 <- paste0(ANALYSIS.ROOT.DIR, "/WikiNetwork.tsv")
BOOKS.STD.LANGLANG2 <- paste0(ANALYSIS.ROOT.DIR, "/BookNetwork.tsv")

MIN.OCCUR <- 5 #0 # minimum co-occurrences
MIN.TSTAT <- 2.59 #-Inf #2.59 # minimum t-statistic

# Following:
# http://stackoverflow.com/questions/7494848/standard-way-to-remove-multiple-elements-from-a-dataframe
`%notin%` <- function(x,y) !(x %in% y)

get.lgn.metrics <- function(file.in, file.out, file.out2, src.name, is.directed=F) {
  # Table of LGN graph metrics for each language from given source
  # use default minimum values
  filtered.edgelist <- read.filtered.edgelist2(file.in,
                                               weighted.graph=T, # use weighted graph
                                               weight.column="occur")
  
  lgn.graph <- graph.data.frame(filtered.edgelist, directed=is.directed)
  
  lgn.metrics <- data.frame(
    total.deg=degree(lgn.graph, mode="in"), # arbitrarily chose "in"
    bet=betweenness(lgn.graph, directed=is.directed),
    eig=evcent(lgn.graph, directed=is.directed)$vector
  )
  
  # prefix column names. TODO: automate. Watch the order!
  colnames(lgn.metrics) <- c( paste(src.name, "deg", sep = "."),
                              paste(src.name, "bet", sep = "."),
                              paste(src.name, "eig", sep = ".") )
  
  lgn.metrics$language <- rownames(lgn.metrics)
  
  # make lanugage the first column
  write.table(lgn.metrics[ , c(4,1,2,3)], file=file.out, sep="\t", quote=F, 
              col.names=T, row.names=F)
  
  # Replicate Cesar's table's format
  partial.metrics <- lgn.metrics[ ,c("language", paste0(src.name, ".eig"))]
  partial.metrics$popfrom <- 0.001 # avoid log(0) later
  partial.metrics$popto <- 0.001
  names(partial.metrics) <- c("Language", "ABS(Eigenvector)",	"Popfrom", "Popto")     
  write.table(partial.metrics, file=file.out2, sep="\t", quote=F, 
              col.names=T, row.names=F)
  
  return(lgn.metrics)
}



read.filtered.edgelist2 <- function(infile,
                                    min.occur=MIN.OCCUR, # common speakers/books
                                    min.tstat=MIN.TSTAT, # minimum t-statistic
                                    weighted.graph=USE.WEIGHTED.GRAPH, # rename a column to "weight", for graph.data.frame  
                                    discard.langs=c(), # languages to remove
                                    weight.column="occur", # if weighted.graph is TRUE, use this column for the weight
                                    col.prefix="" # add a prefix to column names
)  {
  # Read the edgelist from given file and filter it according to given values.
  edgelist <- read.csv(infile, sep="\t",header=T)
  
  # remove unnecessary columns and rename the rest
  edgelist <- edgelist[ , c("SourceLanguageCode", 
                            "TargetLanguageCode",
                            "Coocurrences",
                            "Tstatistic") ]
  names(edgelist) <- c("src.name", "tgt.name", "occur", "tstat")
  
  # Use a source_target format for row names
  row.names(edgelist) = paste0(edgelist$src.name, "_", edgelist$tgt.name)
  
  # now filter
  filtered.edgelist <- subset(edgelist,
                              occur>min.occur &
                                tstat>min.tstat &
                                src.name %notin% discard.langs &
                                tgt.name %notin% discard.langs)
  
  # igraph takes weights from a "weight" column.
  # Need to create one if we want to use it.
  if (weighted.graph==T) {
    colnames(filtered.edgelist)[colnames(filtered.edgelist)==weight.column] <- "weight"
  }
  
  # Prefix column names
  if (col.prefix!="") {
    colnames(filtered.edgelist) <- paste0(col.prefix, ".", colnames(filtered.edgelist))
  }
  
  return(filtered.edgelist)
}


# Find centrality measures for each network ---
# Not needed for May '14 as were loading the pre-calc EV centrality values.
twitter.metrics <- get.lgn.metrics(TWIT.STD.LANGLANG2, "CentTwitter_EigBet_Directed.tsv", "Shahar_EigBetTwitterNetwork_direct.tsv", "twit", is.directed=T)
wiki.metrics <- get.lgn.metrics(WIKI.STD.LANGLANG2, "CentWiki_EigBet_Directed.tsv", "Shahar_EigBetWikiNetwork.tsv", "wiki", is.directed=T)
books.metrics <- get.lgn.metrics(BOOKS.STD.LANGLANG2, "CentBooks_EigBet_Directed.tsv", "Shahar_EigBetBookNetwork_direct.tsv", "book", is.directed=T)
