# Code for generating SI Table 5: GDP+Pop per language, 
# and SI table 6: Language EV centrality

source("../load.R", chdir=T)
library(igraph)

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
                            classif # language classification table file
                            ) {
  # Get EV values and round them
  the.metrics <- get.lgn.metrics(in.file, src.name)
  the.metrics$eig <- round(the.metrics$eig, 2)
  
  # Add full lang names
  output.table <- merge(the.metrics, classif[,c('Lang_Code','Lang_Name')], 
                        all.x=T, # Keep value without a matching language name
                        by.x="row.names", by.y="Lang_Code") 
  colnames(output.table) <- c("Code", "EV Centrality", "Language")
  return(output.table)
}

# Get the full names of the languages and their number of speakers
lang.classif.table <- read.csv(SPEAKER.STATS.FILE, sep="\t", header=T)

##
##
#### EV CENTRALITY ####

# Now get each language's EV cent vals
a <- get.ev.tables(in.file=TWIT.STD.LANGLANG,
                   src.name="twit", 
                   classif=lang.classif.table)

b <- get.ev.tables(in.file=WIKI.STD.LANGLANG,
                   src.name="wiki", 
                   classif=lang.classif.table)

c <- get.ev.tables(in.file=BOOKS.STD.LANGLANG,
                   src.name="book", 
                   classif=lang.classif.table)

# Now merge...
temp <- merge(a,b, by=c("Language", "Code"), all=T, 
              suffixes=c(".twit", ".wiki"))
ev.langs.table <- merge(temp,c, by=c("Language", "Code"), all=T,
               suffixes=c("", ".book"))

# Remove some languages
ev.langs.table <- ev.langs.table[ ! ev.langs.table$Code %in% DISCARD.LANGS, ]

# and write!
write.table(ev.langs.table, file="table6_ev_cent_for_glns.tsv", 
            sep="\t", quote=F, row.names=F, na="")
rm(a); rm(b); rm(c); rm(temp)

print("TABLE 6 DONE - look for NA values")

##
##
### POPULATION AND GDP ####


# Re-use the EV table to get all the languages used, add population stats
# from the classification table (which has more languages than the GDP/pop
# table)
pop.table <- merge(ev.langs.table[, c("Language", "Code")],
                       #lang.classif.table[, c("lang", "gdp_pc", "actual_speakers_m")], 
                       lang.classif.table[, c("Lang_Code", "Num_Speakers_M")], 
                       by.x="Code", by.y="Lang_Code", 
                       all.x=T) # keep languages without population stats

# add GDP from the demographics table
lang.demog.table <- read.table(LANG.STATS.FILE, header=T)
pop.gdp.table <- merge(pop.table,
                       lang.demog.table[, c("lang", "gdp_pc")],
                       by.x="Code", by.y="lang", all.x=T)

pop.gdp.table$gdp_pc <- round(pop.gdp.table$gdp_pc, 0)
names(pop.gdp.table) <- c("Code", "Language", 
                          "Number of Speakers (millions)", "GDP per capita ($)")
rm(pop.table)
rm(lang.demog.table)
rm(lang.classif.table)

# Remove some languages, if necessary
pop.gdp.table <- pop.gdp.table[ ! pop.gdp.table$Code %in% DISCARD.LANGS, ]

write.table(pop.gdp.table, file="table5_lang_pop_gdp.tsv", 
            sep="\t", quote=F, row.names=F, na="")

print("TABLE 5 DONE - compare to the other GDP table at data/lang_demog/language_three_code_gdp_pop.tsv")
print(paste("Languages removed:", DISCARD.LANGS))