# Bump chart following instructions at:
# http://learnr.wordpress.com/2009/05/06/ggplot2-bump-chart/

source("../load.R", chdir=T)
  
library(ggplot2)
library(reshape)

load.ev.values <- function(ev.table.filename) {
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
  
  
  # Use only langs that are in the top 10 in either source
  rf.dfm <- subset(ranked.dfm, eig.rank<=10)
  # rf.dfm <- subset(ranked.dfm, ave(eig.rank, Language) < 20) # Use only langs whose avg. rank is <20
  return(rf.dfm)
}

load.expr.table <- function(table.filename, src.name) {
  # Load the num of expressions for given source from given file
  
  table.expressions <- read.table(table.filename, header=T, sep="\t", quote="")
  table.expressions <- table.expressions[ ,c("name", "num.exp") ]
  names(table.expressions) <- c("Code", "num.exp")
  table.expressions$src <- src.name
  return(table.expressions)
}

plot.top10.bump.chart <- function(viz.df) {
  # Returns a ggplot showing the top 10 languages by EV centrality 
  # in each source, with number of expressions as market size.
  
  p <- ggplot(viz.df, aes(factor(src), eig.rank, #eig
                          group=Language, colour=Language, label=Language)) +
    geom_line() +
    geom_point(shape=15, aes(size=log10(num.exp))) + 
    scale_size(range = c(7, 18)) +
    geom_text(data = viz.df,
              size = 6, hjust = 0.5, vjust=2.5) + # language names
    geom_text(aes(label = viz.df$eig),
              size = 4, hjust = 0.5, vjust=0.5, color="white") # ev cent. values
  
  labels <- c("Twitter", "Wiki", "Trans","")
  
  p <- p + theme(#legend.position = "none",
    panel.border = element_blank()) +
    scale_x_discrete(breaks = c(levels(viz.df$src), ""), labels = labels) +
    scale_y_continuous(breaks = NULL, trans = "reverse") +
    xlab(NULL) + ylab(NULL)
  
  return(p)
}

# Load the EV centralities for each language in all sources
ev.table <- load.ev.values("../si-table5-6-ev-pop-gdp/V30/table6_ev_cent_for_glns.tsv")

# Find the expressions for each language in each source.
# We use it as marker size.
twit.exp <- load.expr.table(TWIT.STD.LANGINFO, "Twitter")
wiki.exp <- load.expr.table(WIKI.STD.LANGINFO, "Wikipedia")
trans.exp <- load.expr.table(BOOKS.STD.LANGINFO, "Translations")
all.exp <- rbind(twit.exp, wiki.exp, trans.exp)

# Augment EV cent table with number of expressions for each lang,
# and plot it.
viz.df <- merge(ev.table, all.exp, all.x=T)
p <- plot.top10.bump.chart(viz.df)

postscript("gln_ranking.eps")
print(p)
dev.off()