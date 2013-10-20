# Constants and common functions for figures.
# This file should be placed in analyis/paper-2013-05/

# Mapping results to use
#MAPPING_VERSION = "2013-07-18_2" 
MAPPING_VERSION = "2013-03-10_paper"

# Data like population, GDP, etc., which aren't supposed to change often
DATA.ROOT.DIR <- normalizePath("../../data/")

# This directory
ANALYSIS.ROOT.DIR <- normalizePath(".") # 

# GLN STRUCTURE -- CHANGE THIS PATH TO THE ONE YOU WANT!!
GLN.STRUCT.DIR <- normalizePath(sprintf("../../mapping_results/%s/standard", MAPPING_VERSION))
TWIT.STD.LANGLANG <- file.path(GLN.STRUCT.DIR, "twitter/twitter_langlang_std.tsv")  
WIKI.STD.LANGLANG <- file.path(GLN.STRUCT.DIR, "wikipedia/wikipedia_langlang_std.tsv")
BOOKS.STD.LANGLANG <- file.path(GLN.STRUCT.DIR, "translations/books_langlang_std.tsv")

TWIT.STD.LANGINFO <- file.path(GLN.STRUCT.DIR, "twitter/twitter_langinfo_std.tsv")  
WIKI.STD.LANGINFO <- file.path(GLN.STRUCT.DIR, "wikipedia/wikipedia_langinfo_std.tsv")
BOOKS.STD.LANGINFO <- file.path(GLN.STRUCT.DIR, "translations/books_langinfo_std.tsv")

# GLN SETTINGS
MIN.COMMON.USERS <- 500 # 60 # Was 500 in V29
MIN.COMMON.TRANS <- 300 # 40 # Was 300 in V29
MIN.EXPOSURE <- 0.001
DESIRED.P.VAL <- 99999 # A value of 99999 should not filter anything
DISCARD.LANGS <- c() # c("grc", "gmh", "fro") # Languages to drop
USE.WEIGHTED.GRAPH <- F # Default is FALSE - otherwise results are even more anglo-centric

# GLN FINAL LANGS - lists the languages we used in the final GLN
# Generated manually from CytoScape, based on the GLN settings above
TWIT.LANGS.FINAL <- file.path(GLN.STRUCT.DIR, "twitter/twitter_langs_final_gln.tsv")  
WIKI.LANGS.FINAL <- file.path(GLN.STRUCT.DIR, "wikipedia/wikipedia_langs_final_gln.tsv")  
BOOKS.LANGS.FINAL <- file.path(GLN.STRUCT.DIR, "translations/books_langs_final_gln.tsv")  

# LANGUAGE DEMOGRAPHICS SETTINGS
LANG.DEMOG.DIR <- file.path(DATA.ROOT.DIR, "lang_demog")
SPEAKER.STATS.FILE <- file.path(LANG.DEMOG.DIR, "population/gold/speakers_families_iso639-3.tsv")
LANG.STATS.FILE <- file.path(LANG.DEMOG.DIR, "language_gdp_pop.tsv")

# CULTURAL PRODUCTION SETTINGS
CULT.PRODUCTION.DIR <- file.path(DATA.ROOT.DIR, "cultural_production")
MURRAY.PRODUCTION.DIR <- file.path(CULT.PRODUCTION.DIR, "murray/2013-10")
WIKI.PRODUCTION.DIR <- file.path(CULT.PRODUCTION.DIR, "wikipedia/2013-10")

# Replace with {1} date range ("all"/"1800_1950") {2} "country"/"language"
MURRAY.FILE.NAME <- file.path(MURRAY.PRODUCTION.DIR,
                           #"final_resolved_murray_4-16-2013_%s_%s_exports.tsv"
                           "HA_unique_countries_resolved_%s_%s_exports.tsv")
                           
                      
# Replace with {1} date range ("all"/"1800_1950") {3} "country"/"language"
WIKI.FILE.NAME <- file.path(WIKI.PRODUCTION.DIR,
                            "wiki_observ_langs26_%s_%s_exports.tsv") # L>=26
                            # "wiki_4crit_langs20_%s_%s_exports.tsv") # L>=20

# GENERAL SETTINGS
LOG.SMOOTH.ADD <- 1e-32 # Value to add to number for preventing log(0)

# USEFUL FUNCTIONS

# Following:
# http://stackoverflow.com/questions/7494848/standard-way-to-remove-multiple-elements-from-a-dataframe
`%notin%` <- function(x,y) !(x %in% y)


read.nodelist <- function(infile,
                          col.prefix="", # add a prefix to column names - don't forget it!
                          col.select="" # select only the passed columns 
                          ) 
{
  nodelist <- read.csv(infile, sep = "\t") 

  # Use language codes for row names
  rownames(nodelist) <- nodelist$name 
  
  # select desired columns only
  if (col.select!="") {
    nodelist <- subset(nodelist, select=col.select)
  }
  
  # Prefix column names
  if (col.prefix!="") {
    colnames(nodelist) <- paste0(col.prefix, ".", colnames(nodelist))
  }
  
  return(nodelist)
}

read.filtered.edgelist <- function(infile,
                                   min.common, # common speakers/books
                                   min.exposure=MIN.EXPOSURE, # exposure score
                                   desired.p.val=DESIRED.P.VAL, # max. p-value
                                   discard.langs=DISCARD.LANGS, # languages to remove
                                   weighted.graph=USE.WEIGHTED.GRAPH, # rename "exposure" column to "weight", for graph.data.frame  
                                   col.prefix="", # add a prefix to column names; just don't you did it!
                                   col.select="" # select only the passed columns 
                                   ) 
{
  # Read the edgelist from given file and filter it according to given values.
  edgelist <- read.csv(infile, sep="\t",header=T)
  
  # Use a source_target format for row names
  row.names(edgelist) = paste0(edgelist$src.name, "_", edgelist$tgt.name)
  
  # Bonferroni correction: divide p-value by number of occurences
  p.val.thres <- desired.p.val / length(edgelist$src.name)
  filtered.edgelist <- subset(edgelist,
                              common.num>=min.common &
                                exposure>=min.exposure &
                                pval<p.val.thres &
                                src.name %notin% discard.langs &
                                tgt.name %notin% discard.langs,
                              select=c('src.name','tgt.name','exposure','common.num' ))
  
  if (weighted.graph==T) {
    # igraph takes weights from a "weight" column.
    # Need to create one if we want to use it.
    colnames(filtered.edgelist)[colnames(filtered.edgelist)=="exposure"] <- "weight"
  }
  
  # select desired columns only
  if (col.select!="") {
    filtered.edgelist <- subset(filtered.edgelist, select=col.select)
  }
  
  # Prefix column names
  if (col.prefix!="") {
    colnames(filtered.edgelist) <- paste0(col.prefix, ".", colnames(filtered.edgelist))
  }
  
  return(filtered.edgelist)
}

classify.p.val <- function(p.val) {
  ## Classify p-val as <1, <0.1, <0.05, <0.01, <0.001 ##
  p.val.cats = c(0.001,0.01,0.05,0.1,1)
  for(i in 1:length(p.val.cats)) {
    if (p.val < p.val.cats[i]) {
      return(p.val.cats[i])
    }
  }
  # not found!
  return(p.val)
}

