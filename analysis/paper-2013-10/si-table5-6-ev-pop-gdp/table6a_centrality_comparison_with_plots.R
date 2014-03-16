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


library(ggplot2)

#\mbox{normal}(g(v)) = \frac{g(v) - \min(g)}{\max(g) - \min(g)}

#### Experimenting with EV vs. betweenness plots... half done...
norm.bet <- (a$unw.bet - min(a$unw.bet)) / (max(a$unw.bet) - min(a$unw.bet))
ggplot(a, aes(x=norm.bet, y=unw.eig, label=Code)) + geom_text()


ggplot(a, aes(x=log(unw.bet), y=unw.eig, label=Code)) + geom_text()
ggplot(a, aes(x=log(exposure.bet), y=exposure.eig, label=Code))  + geom_text()
ggplot(a, aes(x=log(common.bet), y=common.eig, label=Code)) + geom_text()



plot.ev.bet <- function(viz.df) {
  # Returns a ggplot showing EV centrality vs. Betweenness
  
  p <- ggplot(viz.df, aes(factor(src), eig, #eig.rank, #eig
                          group=Code, colour=Code, label=toupper(Code))) +
    geom_line() +
    #geom_point(shape=16, aes(size=popul)) + 
    #scale_size(range = c(12, 35)) +
    geom_text(data = viz.df, angle=45, #aes(size=popul, color=Code),
              hjust = 0.5, vjust=0.5) #+ # language names
  #geom_text(aes(label = viz.df$eig),
  #          size = 4, hjust = 0.5, vjust=0.5, color="white") # ev cent. values
  
  #labels <- c("Twitter", "Wiki", "Trans","")
  
  p <- p + theme(legend.position = "none",
                 axis.text.y=element_blank(), axis.ticks=element_blank(),
                 axis.text.x=element_blank(),
                 panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank(), # remove X gridlines
                 panel.grid.minor.y=element_blank(), panel.grid.major.y=element_blank(), # remove Y gridlines
                 panel.background = element_rect(fill="black"),
                 panel.border = element_blank()) +
    scale_x_discrete(breaks = c(levels(viz.df$src), "")) +
    scale_y_continuous(breaks = NULL, trans = "reverse") +
    #xlab(NULL) + ylab(NULL) +
    #coord_flip() # flip X and Y
  
  return(p)
}

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

print("TABLE 6 DONE - look for NA values")