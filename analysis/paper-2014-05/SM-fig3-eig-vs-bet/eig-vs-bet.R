### Showing statistically significant languages only

prep.source.table <- function(eig.infile, bet.infile, src.name) {
  src.eigs <- read.table(eig.infile, header=T, sep="\t", quote="") # Cesar's EV
  names(src.eigs) <- c("language", "eig", "pop.from", "pop.to")
  src.bets <- read.table(bet.infile, header=T, sep="\t", quote="") # Shahar's betweenness
  names(src.bets) <- c("language", "deg", "bet", "eig")
  src.bets <- src.bets[, c("language", "bet")]
  
  src.metrics <- merge(src.eigs, src.bets)
  src.metrics$src <- src.name
  
  print("*****")
  print(src.name)
  print("*****")
  print(summary(lm(log10(eig) ~ log10(bet), data=src.metrics)))
  
  return(src.metrics)
}

twit.metrics <- prep.source.table("../EigTwitterNetwork.tsv", "CentTwitter_EigBet_Directed.tsv", "A_Twitter")
wiki.metrics <- prep.source.table("../EigWikiNetwork.tsv", "CentWiki_EigBet_Directed.tsv", "B_Wikipedia") 
book.metrics <- prep.source.table("../EigBookNetwork.tsv", "CentBooks_EigBet_Directed.tsv", "C_Books")


# yyy <- twit.metrics[rowSums(twit.metrics==0)<=0,]
# summary(lm(eig_cent ~ bet_cent, data=zzz))

all.metrics <- rbind(twit.metrics, wiki.metrics, book.metrics)

lang.names <- read.table("full_lang_names.tsv", 
                         header=T, sep="\t", quote="")
stop()
all.metrics <- merge(all.metrics, lang.names, all.x=T)
                                    
library(ggplot2)
sp <- ggplot(all.metrics, aes(x=eig, y=bet+1)) + 
  xlab("Eigenvector centrality") + ylab("Betweenness centrality + 1") +
  geom_point(shape=16, size=2, color="red") + 
  scale_y_log10() + scale_x_log10() + 
  geom_text(aes(label=full.name), size=3, vjust=-0.1, hjust=-0.1) +
  #coord_equal(ratio=1) +
  facet_wrap(~src, ncol=3) +
  theme(aspect.ratio=0.9)
ggsave("figure_s3.pdf", sp, scale=2)
print(sp)

library(reshape2)

table.eigs <- dcast(all.metrics, language + full.name ~ src, value.var = c("eig"))
table.bets <- dcast(all.metrics, language + full.name ~ src, value.var = c("bet"))
table.all <- merge(table.eigs, table.bets, by=c("language", "full.name"), suffixes=c("eig", "bet"))
names(table.all) <- c("Code", "Language", 
                      "Twitter EV", "Wikipedia EV", "Books EV",
                      "Twitter Bet", "Wikipedia Bet", "Books Bet"
                      )
write.table(table.all, file="sm_table6_ev_bet.tsv", row.names=F, col.names=T, quote=F, sep="\t")
