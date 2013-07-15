source("../load.R", chdir=T)

merge.exports.table <- function(src.type, # Wiki/Murray
                                ranking.type, # country/language
                                file.all, # filename of the export table for all years
                                file.1800, # filename of the 1800-1950 table
                                out.file) # file to write output table to
{
  if (src.type=="Wiki") {
    filename.template <- WIKI.FILE.NAME
  }
  else {
    # Murray
    filename.template <- MURRAY.FILE.NAME
  }
    
  all.years <- read.csv(sprintf(filename.template, "all", ranking.type), sep="\t", header=T)
  from.1800 <- read.csv(sprintf(filename.template, "1800_1950", ranking.type), sep="\t", header=T)
  
  if (ranking.type=="country") {
    # COUNTRY
    merged.table <- merge(all.years, from.1800,
                           all=T, by="country_code")
    names(merged.table) <- c("Country", "People (all years)", "People (1800-1950 only)")  
    
    # Fianlly, add numbering as first column
    merged.table$Num <- 1:nrow(merged.table)
    merged.table <- merged.table[, c(4,1,2,3)]
  }
  else {
    # LANGUAGE
    # The language table has two extra columns we don't need
    merged.table <- merge(all.years[,c("lang_code", "total_exports")], 
                           from.1800[,c("lang_code", "total_exports")],
                           all=T, by="lang_code")
    
    # Add the full language names
    demog.table <- read.csv(SPEAKER.STATS.FILE, sep="\t", header=T)
    
    merged.table <- merge(merged.table, demog.table[,c('Lang_Code','Lang_Name')], 
                          all.x=T, # Keep values without a matching language name
                          by.x="lang_code", by.y="Lang_Code") 
    # order by language name and reorder columns -)make full language name first )
    merged.table <- merged.table[order(merged.table$Lang_Name), c(4,1,2,3)]
    merged.table$total_exports.x <- round(merged.table$total_exports.x, 1)
    merged.table$total_exports.y <- round(merged.table$total_exports.y, 1)
    
    # Remove languages not in either GLN - load the list from SI table 6: the EV centrality table
    # NOTE: We assume its generated!!!
    legit.langs <- read.csv(file="../si-table5-6-ev-pop-gdp/table6_ev_cent_for_glns.tsv", 
                            header=T, sep="\t")
    
    names(merged.table) <- c("Language", "Code", "People (all years)", "People (1800-1950 only)")  
    
    merged.table <- merged.table[merged.table$Code %in% legit.langs$Code, ]
    
    # Finally, add numbering as first column
    merged.table$Num <- 1:nrow(merged.table)
    merged.table <- merged.table[, c(5,1,2,3,4)]
  }
  
  write.table(merged.table, file=out.file, 
              sep="\t", quote=F, row.names=F)
}

### LET THE MERGING BEGIN!!! ####
merge.exports.table("Wiki", "country", 
                    out.file="si-table8-wiki-country.tsv")

merge.exports.table("Wiki", "language", 
                    out.file="si-table9-wiki-lang.tsv")

merge.exports.table("Murray", "country", 
                    out.file="si-table10-murray-country.tsv")

merge.exports.table("Murray", "language", 
                    out.file="si-table11-murray-lang.tsv")
                    
print("DONE - check for duplicate country names!")