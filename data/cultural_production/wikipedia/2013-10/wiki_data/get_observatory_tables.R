library("RSQLite")

# Read table
conn <- dbConnect(SQLite(), dbname="wiki_data/l26_observatory_manualcleaning3.sqlite3")
people.table1 <- dbReadTable(conn, "culture3")
cat("\nOriginal table:", nrow(people.table1))

# Correct a couple of country codes:
people.table1[people.table1$countryCode=="EW",]$countryCode <- "EE"
people.table1[people.table1$countryCode=="UK",]$countryCode <- "UA"

# Clean up a little: remove missing or unresolved POB 
people.table2 <- subset(people.table1, birthcity!="Missing" & countryCode!="")

# And remove entries wrongly attributed to new world locations
early.new.worlders <- subset(people.table2, birthyear<1700 & 
                          (continentName=="North America" | 
                             continentName=="South America" | continentName=="Oceania"))
people.table3 <- people.table2[!(people.table2$fb_name %in% early.new.worlders$fb_name ),]
cat("\nClean table:", nrow(people.table3))

# update as needed
people.table <- subset(people.table3, 
                       select=c("fb_name", "birthyear", "countryName", 
                                "countryCode", "numlangs")
                       )

# Rename columns
colnames(people.table)[1] <- "Name"
colnames(people.table)[2] <- "Birth"
colnames(people.table)[3] <- "BirthCountry"
colnames(people.table)[4] <- "BirthCountryCode"

# Write raw table to file
write.table(people.table, file="wiki_data/wiki_observ_langs26.tsv", sep='\t', quote=F, row.names=F)

# Aggregate by country, all years
agg.all <- data.frame(table(people.table$BirthCountryCode))
colnames(agg.all) <- c("country_code", "total_exports")
agg.all <- agg.all[order(agg.all$total_exports, decreasing=T),]
write.table(agg.all, file="wiki_observ_langs26_all_country_exports.tsv", sep='\t', quote=F, row.names=F)

# Aggregate by country, 1800-1850
people.table.1800 <- subset(people.table, Birth>=1800 & Birth<=1950)
agg.1800 <- data.frame(table(people.table.1800$BirthCountryCode))
colnames(agg.1800) <- c("country_code", "total_exports")
agg.1800 <- agg.1800[order(agg.1800$total_exports, decreasing=T),]
write.table(agg.1800, file="wiki_observ_langs26_1800_1950_country_exports.tsv", sep='\t', quote=F, row.names=F)