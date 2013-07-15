# Generate a standardized format for Twitter/Wiki/Books tables,
# and compute exposure score and significance measures (phi-coefficient).

BOOKS.TOTAL.TRANSLATIONS <- 2231920 # Not in the original table

INPUT.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Data/Orig"
OUTPUT.DIR <- "~/Documents/MIT/Research/LangGroupNetwork/Paper/Figures/Data"


library(psych)
library(stats)

comp.signif <- function(lang1,lang2,common,total) {
  # Get four equally-long vectors of dichotomous predictors and 
  # return vectors of their phi-coefficinet, t-test, and p-valuess 
  
  # Create vectors representing the phi 2x2 variabies
  # (http://en.wikipedia.org/wiki/Phi_coefficient)
  phi.vars <- phi.matrix(lang1, lang2, common, total)
  num.observ <- nrow(phi.vars) # number of observations
  
  phi.coefs <- vector("numeric",num.observ) # consider Yule?
  ttests <- vector("numeric", num.observ)
  p.vals <- vector("numeric", num.observ)
  
  for (i in 1:num.observ) {
    # find phi
    vec <- c(phi.vars$A[i],phi.vars$B[i],phi.vars$C[i],phi.vars$D[i])
    phi.coefs[i] <- phi(vec, digits=15)
    
    # compute t-test
    # T-Test: =J2*SQRT(MAX(D2,E2)-2)/SQRT(1-J2*J2)
    more.spoken <- max(lang1[i], lang2[i])
    #print(more.spoken)
    ttests[i] <- phi.coefs[i] * sqrt(more.spoken-2) / sqrt(1-phi.coefs[i]^2)
    
    # find p-values
    p.vals[i] <- pt(-abs(ttests[i]), df=more.spoken)
  }
  # Return the three vectors through one data frame
  return(data.frame(phi=phi.coefs, ttest=ttests, pval=p.vals))
}

phi.matrix <- function(lang1, lang2, common, total) {
  # Return the phi-correaltion 2x2 matrix as a vector,
  # given the two dichotmuous vars and helper vars: 
  
  # population speaking neither language
  a <- total - (lang1 + lang2 - common)
  # Pop. speaking only Lang1
  b <- lang1 - common
  # Pop. speaking only Lang2
  c <- lang2 - common
  # Pop. speaking both languages
  d <- common
  
  return(data.frame(A=a,B=b,C=c,D=d))
}

format.tables <- function(infile, outfile, is.books=F) {
  # Read original table, rename columns, and duplicate links for Wikipedia and Twitter
  # so they can be used to calculate the asymmetric exposure score
  setwd(INPUT.DIR)
  orig.table <- read.csv(infile, sep = "\t", header = T)
  #attach(orig.table)
  
  if (is.books==F) {
    # Twitter and Wikipedia datasets
    names(orig.table)[names(orig.table)=="Lang1"] <- "src.name"
    names(orig.table)[names(orig.table)=="Lang2"] <- "tgt.name"
    names(orig.table)[names(orig.table)=="NumOfCommonUsers"] <- "common.num"
    names(orig.table)[names(orig.table)=="NumOfUsersLang1"] <- "src.num"
    names(orig.table)[names(orig.table)=="NumOfUsersLang2"] <- "tgt.num"
    names(orig.table)[names(orig.table)=="TotalNumOfUsers"] <- "total.num"
    
    # Select only the columns that interest us
    std.table <- subset(orig.table,
                        select=c('src.name','tgt.name','common.num',
                                 'src.num', 'tgt.num', 'total.num') )
    
    # Reverse a copy of the table and concatenate to original,
    # to create a table with switched source and target  
    rev.table <- std.table
    rev.table[ , c(1,2)] <- rev.table[ , c(2,1)]
    rev.table[ , c(4,5)] <- rev.table[ , c(5,4)] 
    
    # now bind the two and use the standard column order
    new.table <- rbind(std.table,rev.table)    
    new.table <- new.table[c("src.name", "tgt.name", "common.num", 
                             "src.num", "tgt.num", "total.num")]
  }
  else {
    # Books dataset: rename and add totals
    names(orig.table)[names(orig.table)=="Lang1"] <- "src.name"
    names(orig.table)[names(orig.table)=="Lang2"] <- "tgt.name"
    names(orig.table)[names(orig.table)=="NumOfTransSrcToTgt"] <- "common.num"
    names(orig.table)[names(orig.table)=="NumTransFromSrc"] <- "src.num"
    names(orig.table)[names(orig.table)=="NumTransToTgt"] <- "tgt.num"
    orig.table$total.num <- BOOKS.TOTAL.TRANSLATIONS
    # Standard column order
    new.table <- orig.table[c("src.name", "tgt.name", "common.num", 
                              "src.num", "tgt.num", "total.num")]
  }
  
  # add exposre
  new.table$exposure <- new.table$common.num / new.table$tgt.num
  
  # add signifiance
  sig.measures <- comp.signif(new.table$src.num, new.table$tgt.num,
                             new.table$common.num, new.table$total.num)
  
  # Add the data frame of significant measures to the original one
  new.table <- cbind(new.table, sig.measures)
  
  # Write tables
  setwd(OUTPUT.DIR)
  write.table(new.table, file=outfile, sep="\t", 
              quote=F, row.names=F)
  return(new.table)
  
}

format.tables("twitter_langlang.tsv", "twitter_langlang_std2.tsv")
print("T DONE")
format.tables("wikipedia_langlang.tsv", "wikipedia_langlang_std2.tsv")
print("W DONE")
format.tables("books_langlang_dir.tsv", "books_langlang_std2.tsv", is.books=T)
print("B DONE")

setwd(orig.dir)