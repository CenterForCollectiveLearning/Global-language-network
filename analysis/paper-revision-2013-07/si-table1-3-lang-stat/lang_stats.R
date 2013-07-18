# Generate tables with number of expressions, users, etc. for each languge
# in the final GLN

source("../load.R", chdir=T)

LANG.STATS.DIR <- paste0(ANALYSIS.ROOT.DIR, "/si-table1-3-lang-stat/")

final.lang.stats <- function(final.lang.file, # List of langs in GLN
                             lang.info.file, # Stats for all langs in dataset
                             output.file, # file to write table to
                             is.books=F) { # "True" for books
  # Augment the table of final languages with stats for each language  
  
  # Read tables
  final.lang.tbl <- read.table(final.lang.file, header=T, sep = "\t")  
  final.lang.tbl <- final.lang.tbl[order(final.lang.tbl$full.name),] # sort by full name
  lang.stats.tbl <- read.table(lang.info.file, header=T, sep = "\t")  
  
  # Merge, but don't re-sort -- we want to keep sorting by full name, not code
  final.tbl <- merge(final.lang.tbl, lang.stats.tbl, sort=F)
  
  if (is.books==F) {
    # Find some additional stats
    final.tbl$avg.exp.per.user <- round(final.tbl$avg.exp.per.user, 2)
    final.tbl$percent.of.total.users <- round(final.tbl$num.users/final.tbl$total.users*100, 2)
    # Discard unnecessary column and re-order column positions
    final.tbl <- subset(final.tbl, select=c(full.name, name, num.exps, 
                                            num.users, avg.exp.per.user,
                                            percent.of.total.users))
  }
  else {
    # is.books=T. Select and re-order column positions
    final.tbl <- subset(final.tbl, select=c(full.name, name, 
                                            trans.from, trans.to))
  }

  # final.tbl <<- format(final.tbl, big.mark=",") # add thousand separators
  # Write to file: col.name=NA leaves a blank column header for the numbers
  write.table(final.tbl, file=output.file, quote=F, sep="\t", col.names=NA)
  cat("Written table: ", output.file, "\n")
}

final.lang.stats(TWIT.LANGS.FINAL, TWIT.STD.LANGINFO, 
                 paste0(LANG.STATS.DIR, "twitter_stats_table.tsv") )
final.lang.stats(WIKI.LANGS.FINAL, WIKI.STD.LANGINFO, 
                 paste0(LANG.STATS.DIR, "wikipedia_stats_table.tsv") )
final.lang.stats(BOOKS.LANGS.FINAL, BOOKS.STD.LANGINFO, 
                 paste0(LANG.STATS.DIR, "translations_stats_table.tsv"),
                 is.books=T)
