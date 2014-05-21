# Code for generating SI Table 5: GDP+Pop per language, 
# and SI table 6: Language EV centrality

source("../load.R", chdir=T)
library(igraph)

get.lgn.metrics <- function(file.in, src.name) {
  # Table of LGN graph metrics for each language from given source
  # A different minimum is used for books!
  if (src.name!="book") {
    filtered.edgelist <- read.filtered.edgelist(file.in, MIN.COMMON.USERS)
  }
  else {
    filtered.edgelist <- read.filtered.edgelist(file.in, MIN.COMMON.TRANS)
  }
  #filtered.edgelist <<-filtered.edgelist 
  
  ## measure EV and betweenness centralities in three ways: (1) unweighted,
  ## (2) exposure as weight, (3) num common as weight
  
  # unweighted
  print(filtered.edgelist[1:2,])
  lgn.graph <- graph.data.frame(filtered.edgelist, directed=TRUE)
  lgn.metrics <- data.frame(
    unw.eig=evcent(lgn.graph)$vector,
    unw.bet=betweenness(lgn.graph)
  )
  
  # weighted by exposure
  names(filtered.edgelist)[names(filtered.edgelist) == 'exposure'] <- 'weight'
  print(filtered.edgelist[1:2,])
  lgn.graph <- graph.data.frame(filtered.edgelist, directed=TRUE)
  lgn.metrics$exposure.eig <- evcent(lgn.graph)$vector
  lgn.metrics$exposure.bet <- betweenness(lgn.graph)
  
  # weighted by common users/translations
  names(filtered.edgelist)[names(filtered.edgelist) == 'weight'] <- 'exposure'
  names(filtered.edgelist)[names(filtered.edgelist) == 'common.num'] <- 'weight'
  print(filtered.edgelist[1:2,])
  lgn.graph <- graph.data.frame(filtered.edgelist, directed=TRUE)
  lgn.metrics$common.eig <- evcent(lgn.graph)$vector
  lgn.metrics$common.bet <- betweenness(lgn.graph)
 
  return(lgn.metrics)
}

get.cent.tables <- function(in.file, # langlang file to use
                            out.file, # file to write to
                            src.name, # twit, wiki, book - determines thresholds
                            classif # language classification table file
                            ) {
  # Get all values
  the.metrics <- get.lgn.metrics(in.file, src.name)
  
  # Add full lang names
  output.table <- merge(the.metrics, classif[,c('Lang_Code','Lang_Name')], 
                        all.x=T, # Keep value without a matching language name
                        by.x="row.names", by.y="Lang_Code") 
  # Rename column for future merging
  colnames(output.table)[1] <- "Code"
  
  return(output.table)
}

# Get the full names of the languages and their number of speakers
lang.classif.table <- read.csv(SPEAKER.STATS.FILE, sep="\t", header=T)

##
##
#### CENTRALITY ####

# Now get each language's cent vals
twit.cent <- get.cent.tables(in.file=TWIT.STD.LANGLANG,
                   src.name="twit", 
                   classif=lang.classif.table)

wiki.cent <- get.cent.tables(in.file=WIKI.STD.LANGLANG,
                   src.name="wiki", 
                   classif=lang.classif.table)

book.cent  <- get.cent.tables(in.file=BOOKS.STD.LANGLANG,
                   src.name="book", 
                   classif=lang.classif.table)

# Remove some languages and write
twit.cent <- twit.cent[ ! twit.cent$Code %in% DISCARD.LANGS, ]
write.table(twit.cent, file="table6a_cent_twit.tsv", 
            sep="\t", quote=F, row.names=F, na="")

wiki.cent <- wiki.cent[ ! wiki.cent$Code %in% DISCARD.LANGS, ]
write.table(wiki.cent, file="table6a_cent_wiki.tsv", 
            sep="\t", quote=F, row.names=F, na="")

book.cent <- book.cent[ ! book.cent$Code %in% DISCARD.LANGS, ]
write.table(book.cent, file="table6a_cent_book.tsv", 
            sep="\t", quote=F, row.names=F, na="")

# merge the tabels into one
all.cent <- merge(twit.cent[,c("Code", "Lang_Name", "unw.eig", "unw.bet")], 
                  wiki.cent[,c("Code", "Lang_Name", "unw.eig", "unw.bet")], 
                  by=c("Code", "Lang_Name"), suffixes=c(".twit", ".wiki"), all=T )
all.cent <- merge(all.cent, 
                  book.cent[,c("Code", "Lang_Name", "unw.eig", "unw.bet")], 
                  by=c("Code", "Lang_Name"), suffixes=c("", ".book"), all=T )
all.cent <- all.cent[ , c("Lang_Name", "Code", 
                          "unw.eig.twit", "unw.eig.wiki", "unw.eig",
                          "unw.bet.twit", "unw.bet.wiki", "unw.bet") ]
names(all.cent) <- c("Language", "Code", 
                     "ev.Twitter", "ev.Wikipedia", "ev.Book translations",
                     "bet.Twitter", "bet.Wikipedia", "bet.Book translations")
all.cent <- all.cent[with(all.cent, order(Language, decreasing=F)), ]
all.cent[,c(-1,-2)] <- round(all.cent[, c(-1, -2)], digits=2)
write.table(all.cent, file="table_s6_pnas_cent_full.tsv", 
            sep="\t", quote=F, row.names=F, na="")

print("TABLE 6 DONE - look for NA values")
