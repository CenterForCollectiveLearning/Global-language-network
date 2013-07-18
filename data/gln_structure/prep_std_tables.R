# Generate a standardized format for the node and edge tables processed by the 
# mapping pipeline, store them in a dedicated location, and compute exposure 
# score and significance measures (phi-coefficient) for edge tables.
  
BOOKS.TOTAL.TRANSLATIONS <- 2231920 # Not in the original table

RESULTS.DIR <- "../../mapping_results/2013-07-18_2/"
INPUT.DIR <- paste0(RESULTS.DIR, "preprocessed/")
OUTPUT.DIR <- paste0(RESULTS.DIR, "standard/")

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

format.edge.table <- function(dataset.name, is.books=F) {
  # Read original edge table, table, rename columns, and duplicate links for
  # Wikipedia and Twitter so they can be used to calculate the asymmetric 
  # exposure score.
  # Write results to a file names <dataset.name>_langinfo_std.tsv under folder
  # <dataset.name>
  
  # Assume the target directory already exist. TODO: check for dir and create if necessary.
  
  if (is.books==F) {
    path.to.infile <- paste0(INPUT.DIR, sprintf("%s_langlang.tsv",dataset.name))
  } else {
    # Book filename is a bit different
    path.to.infile <- paste0(INPUT.DIR, sprintf("%s_langlang_dir.tsv",dataset.name))
  }
  
  if (is.books==F) {
    path.to.outfile <- paste0(OUTPUT.DIR, sprintf("%s/%s_langlang_std.tsv", 
                                                  dataset.name, dataset.name))
  } else {
    # Book filename is a bit different -- folder named "translations" and not
    # "books" for backward compat.
    path.to.outfile <- paste0(OUTPUT.DIR, sprintf("%s/%s_langlang_std.tsv", 
                                                  "translations", dataset.name))
  }
  
  orig.table <- read.csv(path.to.infile, sep = "\t", header = T)
  
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
    names(orig.table)[names(orig.table)=="Source"] <- "src.name"
    names(orig.table)[names(orig.table)=="Target"] <- "tgt.name"
    names(orig.table)[names(orig.table)=="NumOfTransSrcToTgt"] <- "common.num"
    names(orig.table)[names(orig.table)=="NumTransFromSrc"] <- "src.num"
    names(orig.table)[names(orig.table)=="NumTransToTgt"] <- "tgt.num"
    orig.table$total.num <- BOOKS.TOTAL.TRANSLATIONS
    # Standard column order
    new.table <- orig.table[c("src.name", "tgt.name", "common.num", 
                              "src.num", "tgt.num", "total.num")]
  }
  
  # add exposure
  new.table$exposure <- new.table$common.num / new.table$tgt.num
  
  # add signifiance
  sig.measures <- comp.signif(new.table$src.num, new.table$tgt.num,
                             new.table$common.num, new.table$total.num)
  
  # Add the data frame of significant measures to the original one
  new.table <- cbind(new.table, sig.measures)
  
  # Write tables
  #setwd(OUTPUT.DIR)
  write.table(new.table, file=path.to.outfile, sep="\t", 
              quote=F, row.names=F)
  
  return(new.table)
  
}

format.node.table <- function(dataset.name, is.books=F) {
  # Read original table and rename columns so names are identical across sources
  # Write results to a file names <dataset.name>_langinfo_std.tsv under folder
  # <dataset.name>
  
  # Assume the target directory already exist. TODO: check for dir and create if necessary.
  
  if (is.books==F) {
    path.to.infile <- paste0(INPUT.DIR, sprintf("%s_langinfo.tsv",dataset.name))
  } else {
    # Book filename is a bit different
    path.to.infile <- paste0(INPUT.DIR, sprintf("%s_langinfo_dir.tsv",dataset.name))
  }
  
  if (is.books==F) {
    path.to.outfile <- paste0(OUTPUT.DIR, sprintf("%s/%s_langinfo_std.tsv", 
                                                  dataset.name, dataset.name))
  } else {
    # Book filename is a bit different -- folder named "translations" and not
    # "books" for backward compat.
    path.to.outfile <- paste0(OUTPUT.DIR, sprintf("%s/%s_langinfo_std.tsv", 
                                                  "translations", dataset.name))
  }
  
  orig.table <- read.csv(path.to.infile, sep = "\t", header = T)
  
  if (is.books==F) {
    # Twitter and Wikipedia datasets
    names(orig.table)[names(orig.table)=="Language"] <- "name"
    names(orig.table)[names(orig.table)=="NumOfExps"] <- "num.exp"
    names(orig.table)[names(orig.table)=="NumOfUsers"] <- "num.users"
    names(orig.table)[names(orig.table)=="AvgExpsPerUser"] <- "avg.exp.per.user"
    names(orig.table)[names(orig.table)=="NumOfExpsByPolys"] <- "num.exp.by.polys"
    names(orig.table)[names(orig.table)=="NumOfPolyglots"] <- "num.polys"
    names(orig.table)[names(orig.table)=="AvgExpsPerPoly"] <- "avg.exp.per.poly"
    names(orig.table)[names(orig.table)=="TotalNumUsers"] <- "total.users"
    names(orig.table)[names(orig.table)=="TotalNumOfPolys"] <- "total.polys"
    
    # Select only the columns that interest us
    new.table <- orig.table[c('name', 
                              'num.exp', 'num.users', 'avg.exp.per.user', 
                              'num.exp.by.polys', 'num.polys', 'avg.exp.per.poly', 
                              'total.users', 'total.polys')]
  }
  else {
    # Books dataset: rename and add totals
    names(orig.table)[names(orig.table)=="Language"] <- "lang.code"
    names(orig.table)[names(orig.table)=="TranslatedFrom"] <- "num.exp"
    names(orig.table)[names(orig.table)=="TranslatedTo"] <- "trans.to"
    names(orig.table)[names(orig.table)=="OutDegree"] <- "degree.from"
    names(orig.table)[names(orig.table)=="InDegree"] <- "degree.to"
    # Standard column order
    new.table <- orig.table[c("lang.code", "num.exp", "trans.to", 
                              "degree.from", "degree.to")]
  }
  
  # Write table
  write.table(new.table, file=path.to.outfile, sep="\t", 
              quote=F, row.names=F)
  return(new.table)
  
}

### MAIN ####

dir.create(OUTPUT.DIR)
dir.create(file.path(OUTPUT.DIR, "twitter"))
dir.create(file.path(OUTPUT.DIR, "wikipedia"))
dir.create(file.path(OUTPUT.DIR, "translations"))
dir.create(file.path(OUTPUT.DIR, "facebook"))


format.edge.table("twitter")
format.node.table("twitter")
print("T DONE")
format.edge.table("wikipedia")
format.node.table("wikipedia")
print("W DONE")
# format.edge.table("facebook")
# format.node.table("facebook")
# print("F DONE")
format.edge.table("books", is.books=T)
format.node.table("books", is.books=T)
print("B DONE")
