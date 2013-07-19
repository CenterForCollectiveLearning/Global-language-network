# TODO: use num of tweets/edits/translations from the respective files
# under net-langs/data

# Bump chart following instructions at:
# http://learnr.wordpress.com/2009/05/06/ggplot2-bump-chart/

source("../load.R", chdir=T)
  
library(ggplot2)
library(reshape)

# Load table of centralities
df <- read.table("../si-table5-6-ev-pop-gdp/V30/table6_ev_cent_for_glns.tsv", header=T, sep="\t", quote="",
                 colClasses=c("character","character","numeric","numeric","numeric"))
df$Language <- NULL # remove lang name, we'll use codes for now...
# Change names to match current code TODO: should update code to match names...
names(df) <- c("Language", "Twitter", "Wikipedia", "Translations")

dfm <- melt(df)
colnames(dfm)[2] <- "src" # give the "variable" column a meaningful name
colnames(dfm)[3] <- "eig" # give the "value" column a meaningful name

# Find the ranks and store in a ranked df, following:
# http://stackoverflow.com/questions/15170777/add-a-rank-column-to-a-data-frame
ranked.dfm <- transform(dfm, eig.rank = ave(eig, src, 
                          FUN = function(x) rank(-x, ties.method = "first")))


# Use only langs that are in the top 10 in either source
rf.dfm <- subset(ranked.dfm, eig.rank<=10)
# rf.dfm <- subset(ranked.dfm, ave(eig.rank, Language) < 20) # Use only langs whose avg. rank is <20

# Find the expressions for each language, to be used as marker size.
rfexp.dfm <- rf.dfm

twit.exp <- read.table(TWIT.STD.LANGINFO, header=T, sep="\t", quote="")
twit.exp <- twit.exp[ ,c("name", "num.exp") ]
names(twit.exp) <- c("Language", "num.exp")
twit.exp$src <- "Twitter"

wiki.exp <- read.table(WIKI.STD.LANGINFO, header=T, sep="\t", quote="")
wiki.exp <- wiki.exp[ ,c("name", "num.exp") ]
names(wiki.exp) <- c("Language", "num.exp")
wiki.exp$src <- "Wikipedia"

trans.exp <- read.table(BOOKS.STD.LANGINFO, header=T, sep="\t", quote="")
trans.exp <- trans.exp[ ,c("name", "num.exp") ]
names(trans.exp) <- c("Language", "num.exp")
trans.exp$src <- "Translations"

all.exp <- rbind(twit.exp, wiki.exp, trans.exp)

rfexp.dfm <- merge(rfexp.dfm, all.exp, all.x=T)

p <- ggplot(rfexp.dfm, aes(factor(src), eig.rank, #eig
                     group=Language, colour=Language, label=Language)) +
  geom_line() +
  geom_point(shape=15, aes(size=log10(num.exp))) + 
  scale_size(range = c(7, 18)) +
  geom_text(data = rfexp.dfm,
            size = 6, hjust = 0.5, vjust=2.5) + # language names
  geom_text(aes(label = rfexp.dfm$eig),
            size = 4, hjust = 0.5, vjust=0.5, color="white") # ev cent. values

labels <- c("Twitter", "Wiki", "Trans","")

p <- p + theme(#legend.position = "none",
               panel.border = element_blank()) +
  scale_x_discrete(breaks = c(levels(dfm$src), ""), labels = labels) +
  scale_y_continuous(breaks = NULL, trans = "reverse") +
  #scale_y_continuous(breaks = NULL) +
  xlab(NULL) + ylab(NULL)

postscript("gln_ranking.eps")
print(p)
dev.off()