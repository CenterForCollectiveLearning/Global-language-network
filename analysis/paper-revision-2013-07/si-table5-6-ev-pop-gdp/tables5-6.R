# Code for generating SI Table 5: GDP+Pop per language, 
# and SI table 6: Language EV centrality

source("../load.R", chdir=T)
library(igraph)

# TODO: For the tables used in the paper, c("gmh", "grc", "fro") were removed.
# There's actually no reason for that (though obviously we don't have GDP
# and pop. stats for these languages). Either way, the settings from 
# DISCARD.LANGS in load.R should be used instead of these.
LANGS.TO.REMOVE.FROM.GLNS <- c() 

get.lgn.metrics <- function(file.in, src.name) {
  # Table of LGN graph metrics for each language from given source
  # A different minimum is used for books!
  if (src.name!="book") {
    filtered.edgelist <- read.filtered.edgelist(file.in, MIN.COMMON.USERS)
  }
  else {
    filtered.edgelist <- read.filtered.edgelist(file.in, MIN.COMMON.TRANS)
  }
  
  lgn.graph <- graph.data.frame(filtered.edgelist, directed=TRUE)
  
  lgn.metrics <- data.frame(
    eig=evcent(lgn.graph)$vector
  )
  
  return(lgn.metrics)
}

get.ev.tables <- function(in.file, # langlang file to use
                            out.file, # file to write to
                            src.name, # twit, wiki, book - determines thresholds
                            demog # demographics table
                            ) {
  # Get EV values and round them
  the.metrics <- get.lgn.metrics(in.file, src.name)
  the.metrics$eig <- round(the.metrics$eig, 2)
  
  # Add full lang names
  output.table <- merge(the.metrics, demog[,c('Lang_Code','Lang_Name')], 
                        all.x=T, # Keep value without a matching language name
                        by.x="row.names", by.y="Lang_Code") 
  colnames(output.table) <- c("Code", "EV Centrality", "Language")
  #write.table(output.table[,c(3,1,2)], # re-order column so Lang_Name is first, then Lang_Code and EV
  #            file=out.file, 
  #            sep="\t", quote=F, row.names=F)
  return(output.table)
}


# Get the full names of the languages and their number of speakers
demog.table <- read.csv(SPEAKER.STATS.FILE, sep="\t", header=T)

##
##
#### EV CENTRALITY ####

# Now get each language's EV cent vals
a <- get.ev.tables(in.file=TWIT.STD.LANGLANG,
                src.name="twit", 
                demog=demog.table)

b <- get.ev.tables(in.file=WIKI.STD.LANGLANG,
                src.name="wiki", 
                demog=demog.table)

c <- get.ev.tables(in.file=BOOKS.STD.LANGLANG,
                src.name="book", 
                demog=demog.table)

# Now merge...
temp <- merge(a,b, by=c("Language", "Code"), all=T, 
              suffixes=c(".twit", ".wiki"))
ev.langs.table <- merge(temp,c, by=c("Language", "Code"), all=T,
               suffixes=c("", ".book"))

# Remove some languages
ev.langs.table <- ev.langs.table[ ! ev.langs.table$Code %in% LANGS.TO.REMOVE.FROM.GLNS, ]

# and write!
write.table(ev.langs.table, file="table6_ev_cent_for_glns.tsv", 
            sep="\t", quote=F, row.names=F, na="")
rm(a); rm(b); rm(c); rm(temp)

print("TABLE 5 DONE - look for NA values")

##
##
### POPULATION AND GDP ####

# Re-use the EV table for all languages used, add population stats
pop.table <- merge(ev.langs.table[, c("Language", "Code")],
              demog.table[, c("Lang_Code", "Num_Speakers_M")], 
              by.x="Code", by.y="Lang_Code", 
              all.x=T) # keep languages without population stats
pop.table[pop.table==-1] <- NA
pop.table <- pop.table[order(pop.table$Language),c(2,1,3)]

## Get GDPpc for language from here; this table also has 
# language population, but not for all languages.
gdp.table <- read.table(sprintf(WIKI.FILE.NAME, "all", "language"), header=T)
#   paste0(CULT.PRODUCTION.DIR,
#         "wikipedia/final_resolved_wiki_4-16-2013_20_1800_1950_language_exports.tsv"),
  
gdp.table$gdp_per_capita <- round(gdp.table$gdp_per_capita, 0)

# Merge
pop.gdp.table<-merge(pop.table, 
                     gdp.table[,c("lang_code", "gdp_per_capita")], all.x=T, # Keep langs without GDPpc stats
                     by.x="Code", by.y="lang_code")
rm(gdp.table); rm(pop.table)

colnames(pop.gdp.table) <- c("Code", "Language", "Number of Speakers (millions)", "GDP per capita ($)")

# Remove some languages
pop.gdp.table <- pop.gdp.table[ ! pop.gdp.table$Code %in% LANGS.TO.REMOVE.FROM.GLNS, ]

write.table(pop.gdp.table[order(pop.gdp.table$Language),c(2,1,3,4)], # rearrange columns
            file="table5_lang_pop_gdp.tsv", 
            sep="\t", quote=F, row.names=F, na="")

print("TABLE 6 DONE - compare to the other GDP table at data/lang_demog/language_three_code_gdp_pop.tsv")
print(paste("Removed:", LANGS.TO.REMOVE.FROM.GLNS))


### Original GDP table - not necessary 
# other.gdp.table <- read.csv(paste0(DATA.ROOT.DIR, "/lang_demog/language_three_code_gdp_pop.tsv"),
#                             sep="\t", header=T)
# 
# setdiff(other.gdp.table$language, pop.gdp.table$Code)
# setdiff(pop.gdp.table$Code, other.gdp.table$language)