#[Ref2:Q1] Measure of eigenvector centrality for different thresholds of the exposure. 
# I can analyze this if you give me a file with each language as a row, and each column 
# as its measure of eigenvector centrality for a different exposure threshold. Here, 
# consider a wide range of exposures and a relatively fine sampling. My intuition would 
# be something like a log spaced vector from ~10-5 to ~10-1 (i.e 0.00001 0.00002 0.00004
# 0.00008 0.00016 0.0032 ... )

MIN.EXPOSURE.EXP <- -5
MAX.EXPOSURE.EXP <- -1
NUM.SAMPLES <- 50

source("../load.R", chdir=T)
library(igraph)
library(rdetools) # for logspace

get.lgn.metrics <- function(file.in, src.name) {
  # Table of LGN graph EV for each language from given source,
  # using the given threshold for the graph
  # A different minimum is used for books!
  
  if (src.name!="book") {
    filtered.edgelist <- read.filtered.edgelist(file.in, 
                                                MIN.COMMON.USERS, 
                                                min.exposure=0)
  }
  else {
    filtered.edgelist <<- read.filtered.edgelist(file.in, 
                                                MIN.COMMON.TRANS, 
                                                min.exposure=0)
  }
  
  # Populate a DF with codes of all languages
  nodes <- graph.data.frame(filtered.edgelist, directed=TRUE)
  main.df <- data.frame(V(nodes)$name)
  names(main.df) <- "Lang"
  
  for (expo.threshold in logspace(MIN.EXPOSURE.EXP, MAX.EXPOSURE.EXP, NUM.SAMPLES)) {
      # create a graph from edgelist filtered by this exposure
      lgn.graph <- graph.data.frame( 
        filtered.edgelist[filtered.edgelist$exposure>=expo.threshold,], 
        directed=TRUE)
    
      # get a DF the EV centrality for each lang in that graph
      lgn.metrics <- data.frame(eig=evcent(lgn.graph)$vector)
      lgn.metrics$Lang <- row.names(lgn.metrics)
      
      # give the column the proper name
      names(lgn.metrics)[names(lgn.metrics) == 'eig'] <- toString(expo.threshold)
    
      # merge the DF with main DF
      main.df <- merge(main.df, lgn.metrics, by="Lang",all=T)
    }
  
  return(main.df)
}

get.cent.tables <- function(in.file, # langlang file to use
                            out.file, # file to write to
                            src.name, # twit, wiki, book - determines thresholds
                            classif # language classification table file
                            ) {
  # Get values for a given exposure
  the.metrics <- get.lgn.metrics(in.file, src.name)
  
  # Add full lang names
  output.table <- merge(the.metrics, classif[,c('Lang_Code','Lang_Name')], 
                        all.x=T, # Keep value without a matching language name
                        by.x="Lang", by.y="Lang_Code") 
  # Rename column for future merging
  colnames(output.table)[1] <- "Code"
  
  return(output.table)
}

# Get the full names of the languages and their number of speakers
lang.classif.table <- read.csv(SPEAKER.STATS.FILE, sep="\t", header=T)

# save to file
twit.cent <- get.cent.tables(in.file=TWIT.STD.LANGLANG,
                             src.name="twit",
                             classif=lang.classif.table)
twit.cent <- twit.cent[ ! twit.cent$Code %in% DISCARD.LANGS, ]
write.table(twit.cent, file="table6b_ev_by_expo_twit.tsv", 
            sep="\t", quote=F, row.names=F, na="")

wiki.cent <- get.cent.tables(in.file=WIKI.STD.LANGLANG,
                   src.name="wiki", 
                   classif=lang.classif.table)
wiki.cent <- wiki.cent[ ! wiki.cent$Code %in% DISCARD.LANGS, ]
write.table(wiki.cent, file="table6b_ev_by_expo_wiki.tsv", 
            sep="\t", quote=F, row.names=F, na="")

book.cent  <- get.cent.tables(in.file=BOOKS.STD.LANGLANG,
                   src.name="book", 
                   classif=lang.classif.table)
book.cent <- book.cent[ ! book.cent$Code %in% DISCARD.LANGS, ]
write.table(book.cent, file="table6b_ev_by_expo_book.tsv", 
            sep="\t", quote=F, row.names=F, na="")

print("TABLE 6B DONE - look for NA values")