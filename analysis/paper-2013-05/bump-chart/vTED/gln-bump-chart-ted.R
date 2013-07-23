# Bump chart following instructions at:
# http://learnr.wordpress.com/2009/05/06/ggplot2-bump-chart/

source("../load.R", chdir=T)
  
library(ggplot2)
library(reshape)

TOPN = 40 # number of langs to show

load.ev.values <- function(ev.table.filename, top.n=10) {
  # Load table of centralities.
  df <- read.table(ev.table.filename,header=T, sep="\t", quote="",
                   colClasses=c("character","character","numeric","numeric","numeric"))
  names(df) <- c("Language", "Code", "Twitter", "Wikipedia", "Translations")
  
  dfm <- melt(df)
  names(dfm) <- c("Language", "Code", "src", "eig") # give columns meaningful names
  
  # Find the ranks and store in a ranked df, following:
  # http://stackoverflow.com/questions/15170777/add-a-rank-column-to-a-data-frame
  ranked.dfm <- transform(dfm, eig.rank = ave(eig, src, 
                                              FUN = function(x) rank(-x, ties.method = "first")))
  
  
  # Use only langs that are in the top N in either source
  rf.dfm <- subset(ranked.dfm, eig.rank<=top.n)
  # rf.dfm <- subset(ranked.dfm, ave(eig.rank, Language) < 20) # Use only langs whose avg. rank is <20
  return(rf.dfm)
}

load.pop.table <- function(table.filename) {
  table.pop <- read.table(table.filename, header=T, sep="\t", quote="", comment="")
  table.pop <- table.pop[ ,c("Lang_Code", "Num_Speakers_M") ]
  names(table.pop) <- c("Code", "popul")
  return(table.pop)
}

load.expr.table <- function(table.filename, src.name) {
  # Load the num of expressions for given source from given file
  
  table.expressions <- read.table(table.filename, header=T, sep="\t", quote="")
  table.expressions <- table.expressions[ ,c("name", "num.exp") ]
  names(table.expressions) <- c("Code", "num.exp")
  table.expressions$src <- src.name
  return(table.expressions)
}

plot.topn.bump.chart <- function(viz.df, top.n=10) {
  # Returns a ggplot showing the top N languages by EV centrality 
  # in each source, with number of expressions as market size.
  
  p <- ggplot(viz.df, aes(factor(src), eig, #eig.rank, #eig
                          group=Code, colour=Code, label=toupper(Code))) +
    geom_line() +
    #geom_point(shape=16, aes(size=popul)) + 
    scale_size(range = c(12, 35)) +
    geom_text(data = viz.df, angle=45, aes(size=popul, color=Code),
              hjust = 0.5, vjust=0.5) #+ # language names
    #geom_text(aes(label = viz.df$eig),
    #          size = 4, hjust = 0.5, vjust=0.5, color="white") # ev cent. values
  
  labels <- c("Twitter", "Wiki", "Trans","")
  
  p <- p + theme(legend.position = "none",
    axis.text.y=element_blank(), axis.ticks=element_blank(),
    axis.text.x=element_blank(),
    panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank(), # remove X gridlines
    panel.grid.minor.y=element_blank(), panel.grid.major.y=element_blank(), # remove Y gridlines
    panel.background = element_rect(fill="black"),
    panel.border = element_blank()) +
    scale_x_discrete(breaks = c(levels(viz.df$src), "")) +
    scale_y_continuous(breaks = NULL, trans = "reverse") +
    xlab(NULL) + ylab(NULL) +
    coord_flip() # flip X and Y
  
  return(p)
}

# Load the EV centralities for each language in all sources
ev.table <- load.ev.values("../si-table5-6-ev-pop-gdp/V30/table6_ev_cent_for_glns.tsv", 
                           top.n=TOPN)

# Find the expressions for each language in each source.
# We use it as marker size.
pop.stats <- load.pop.table(SPEAKER.STATS.FILE)

twit.exp <- load.expr.table(TWIT.STD.LANGINFO, "Twitter")
wiki.exp <- load.expr.table(WIKI.STD.LANGINFO, "Wikipedia")
trans.exp <- load.expr.table(BOOKS.STD.LANGINFO, "Translations")
all.exp <- rbind(twit.exp, wiki.exp, trans.exp)

# Augment EV cent table with number of expressions for each lang,
# and plot it.
viz.df <- merge(ev.table, all.exp, all.x=T)
viz.df <- merge(viz.df, pop.stats, by="Code", all.x=T)
p <- plot.topn.bump.chart(viz.df, top.n=TOPN)

#postscript("gln_ranking.eps")
print(p)
#dev.off()