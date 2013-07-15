# Generate a standardized format for Twitter/Wiki/Books expression tables.

INPUT.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Data/Orig"
OUTPUT.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Data"

library(psych)
library(stats)

format.tables <- function(infile, outfile, is.books=F) {
  # Read original table and rename columns so names are identical across sources
  setwd(INPUT.DIR)
  orig.table <- read.csv(infile, sep = "\t", header = T)
  #attach(orig.table)
  
  if (is.books==F) {
    # Twitter and Wikipedia datasets
    names(orig.table)[names(orig.table)=="Language"] <- "lang.code"
    names(orig.table)[names(orig.table)=="NumOfExps"] <- "num.exp"
    
    # Select only the columns that interest us
    new.table <- orig.table[c('lang.code', 'num.exp')]
  }
  else {
    # Books dataset: rename and add totals
    names(orig.table)[names(orig.table)=="Language"] <- "lang.code"
    names(orig.table)[names(orig.table)=="TranslatedFrom"] <- "num.exp"
    # Standard column order
    new.table <- orig.table[c("lang.code", "num.exp")]
  }
  
  # Write tables
  setwd(OUTPUT.DIR)
  write.table(new.table, file=outfile, sep="\t", 
              quote=F, row.names=F)
  return(new.table)
  
}

format.tables("twitter_langinfo.tsv", "twitter_langinfo_std.tsv")
print("T DONE")
format.tables("wikipedia_langinfo.tsv", "wikipedia_langinfo_std.tsv")
print("W DONE")
format.tables("books_langinfo_dir.tsv", "books_langinfo_std.tsv", is.books=T)
print("B DONE")