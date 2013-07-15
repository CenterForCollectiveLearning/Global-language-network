# From http://spatialanalysis.co.uk/2013/02/mapped-twitter-languages-york/

source("../../figures/load.R", chdir=T)
library("RSQLite")
library(plyr)
library(ggplot2)
library(gridExtra)

DB.PATH <- paste0(WIKI.PRODUCTION.DIR, "wiki_data/culture.sqlite3")

MIN.LANGS <- 0

cumsumfromright <- function(x) {
  # calculate the cumulative sum of vector x from the tail and 
  # not from the head 
  rev(cumsum(rev(x)))
}

# Read table
conn <- dbConnect(SQLite(), dbname=DB.PATH)
people.table <- dbReadTable(conn, "ranking")

# filter languages and DOB
people.table <- subset(people.table, 
                       numlangs>=MIN.LANGS,
                       select=c(fb_name, birthyear, countryName, numlangs))

# Rename columns
colnames(people.table)[1] <- "Name"
colnames(people.table)[2] <- "Birth"
colnames(people.table)[3] <- "BirthCountry"

notability.dist <- ddply(people.table, 'numlangs', .progress = "text", 
                         function(x) people.per.num=nrow(x) )
colnames(notability.dist) <- c("numlangs", "people.per.num")
notability.dist$cum.people.per.num <- 
  cumsumfromright(notability.dist$people.per.num)

# We use these values to add the red lines
THRES <- 20
PEOPLE.OVER.THRES <- notability.dist[notability.dist$numlangs==THRES, c("cum.people.per.num")]

notability.plot <- ggplot(notability.dist, aes(x=numlangs, y=cum.people.per.num)) +
  geom_point(shape=16, size=3) + theme_bw() + 
  scale_x_continuous(breaks=c(0,20,50,100,150,200)) + 
  scale_y_log10(breaks=c(1e+01, 1e+03, PEOPLE.OVER.THRES ,1e+05),
                labels=c("1e+01", "1e+03", PEOPLE.OVER.THRES ,"1e+05")) +
  labs(x="Number of Wikipedia language editions", y="log10(Number of people)") +
  geom_vline(xintercept=c(THRES), linetype="dotted", color="red") +
  geom_hline(yintercept=c(PEOPLE.OVER.THRES), linetype="dotted", color="red")
print(notability.plot)

# plot
postscript("si-fig3-num-editions-dist.eps")
grid.arrange(notability.plot, ncol=1, 
             widths=unit(c(13), "cm"),
             heights=unit(c(12), "cm") )
dev.off()