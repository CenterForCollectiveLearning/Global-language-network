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
    names(merged.table) <- c("Code", "People (all years)", "People (1800-1950 only)")  
    
    # add full country names
    country.conv.table <- read.csv(COUNTRY.CODE.CONV.FILE, sep="\t", header=T)
    country.conv.table <- country.conv.table[, c('ENTITY','ISO_3166.2')]
    names(country.conv.table) <- c("Country", "Code")
    
    merged.table <- merge(merged.table, country.conv.table, 
                          all.x=T, # Keep values without a matching language name
                          by="Code") 
    
    # Final touches:
    merged.table$Code <- NULL # country code no longer necessary
    # Sort by full country name
    merged.table <- merged.table[order(merged.table$Country),]
    merged.table$Num <- 1:nrow(merged.table) # add numbering
    # re-order columns
    merged.table <- merged.table[order(merged.table$Country), c(4,3,1,2)]
  }
  else {
    # LANGUAGE
    # The language table has two extra columns we don't need
    merged.table <- merge(all.years[,c("lang", "total_exports")], 
                           from.1800[,c("lang", "total_exports")],
                           all=T, by="lang")
    
    # Add the full language names
    demog.table <- read.csv(SPEAKER.STATS.FILE, sep="\t", header=T)
    
    merged.table <- merge(merged.table, demog.table[,c('Lang_Code','Lang_Name')], 
                          all.x=T, # Keep values without a matching language name
                          by.x="lang", by.y="Lang_Code") 
    # order by language name and reorder columns (make full language name first )
    merged.table <- merged.table[order(merged.table$Lang_Name), c(4,1,2,3)]
    merged.table$total_exports.x <- round(merged.table$total_exports.x, 2)
    merged.table$total_exports.y <- round(merged.table$total_exports.y, 2)
    
    # Remove languages not in either GLN - load the list from SI table 6: the EV centrality table
    # NOTE: We assume its generated!!!
    legit.langs <- read.csv(file="../si-table5-6-ev-pop-gdp/V31/table6_ev_cent_for_glns.tsv", 
                            header=T, sep="\t")
    
    names(merged.table) <- c("Language", "Code", "People (all years)", "People (1800-1950 only)")  
    
    merged.table <- merged.table[merged.table$Code %in% legit.langs$Code, ]
    
    # Finally, add numbering as first column
    merged.table$Num <- 1:nrow(merged.table)
    merged.table <- merged.table[, c(5,1,2,3,4)]
  }
  
  write.table(merged.table, file=out.file, na="", # write NA as blank
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