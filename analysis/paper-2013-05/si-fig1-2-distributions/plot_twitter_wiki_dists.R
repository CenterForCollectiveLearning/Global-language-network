library(ggplot2)
library(plyr)

TWITTER.LANG.KNOWLEDGE.DIST <- "dist_langs_spoken_twitter.txt"
WIKI.LANG.KNOWLEDGE.DIST <- "dist_langs_spoken_wiki.txt"
TWEETS.BY.CERTAINTY.DIST <- "identified_tweets_table.txt"

make.image.filename <- function(fname, orig.ext=".txt", new.ext=".eps") {
  return(sub(orig.ext, new.ext, fname))
}

lang.knowledge.distrib.from.file <- function(in.filename, # input filename
                                             x.lab, y.lab # axis label
                                             ) {
  # Read pre-prepared distribution data from given file, plot it.
  the.data <- read.table(in.filename, sep="\t",
                         col.names=c("num.langs", "num.users"))
  the.plot <- ggplot(the.data, aes(x=num.langs, y=num.users)) +
    geom_point(shape=16, size=3) + scale_y_log10() + theme_bw() +
    labs(x=x.lab, y=y.lab)
  grid.arrange(the.plot, ncol=1, 
               widths=unit(c(13), "cm"),
               heights=unit(c(12), "cm") ) 
}

### Twitter distrib. ####
postscript(make.image.filename(TWITTER.LANG.KNOWLEDGE.DIST))
lang.knowledge.distrib.from.file(TWITTER.LANG.KNOWLEDGE.DIST,
                       x.lab="Number of languages used", 
                       y.lab="log10(Number of Twitter users)")
dev.off()

### Wiki distrib. ####
postscript(make.image.filename(WIKI.LANG.KNOWLEDGE.DIST))
lang.knowledge.distrib.from.file(WIKI.LANG.KNOWLEDGE.DIST,
                       x.lab="Number of languages used", 
                       y.lab="log10(Number of Wikipedia editors)")
dev.off()

### Certainty distrib ####
twitter.certainty <- read.table(TWEETS.BY.CERTAINTY.DIST, sep="\t", header=T)

certainty.distribution <- ddply(twitter.certainty, 'Certainty', .progress = "text", 
                   function(x) num.tweets=nrow(x) )
colnames(certainty.distribution) <- c("certainty", "num.tweets")
certainty.distribution$cum.num.tweets <- 
  cumsum(certainty.distribution$num.tweets)

certainty.plot <- ggplot(certainty.distribution, aes(x=certainty, y=cum.num.tweets)) +
  geom_point(shape=16, size=3) + scale_y_log10() + theme_bw() +
  labs(x="CLD certainty score", y="log10(Number of tweets)")

# plot
postscript(make.image.filename(TWEETS.BY.CERTAINTY.DIST))
grid.arrange(certainty.plot, ncol=1, 
             widths=unit(c(13), "cm"),
             heights=unit(c(12), "cm") )
dev.off()