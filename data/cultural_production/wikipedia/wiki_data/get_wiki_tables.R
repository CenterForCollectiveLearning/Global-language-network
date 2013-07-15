# From http://spatialanalysis.co.uk/2013/02/mapped-twitter-languages-york/

library("RSQLite")

MIN.LANGS <- 20
# Filtered -- not used now...
MIN.YEAR <- 1800
MAX.YEAR <- 99999

# Read table
conn <- dbConnect(SQLite(), dbname="culture.sqlite3")
people.table <- dbReadTable(conn, "ranking")

# filter languages and DOB
people.table <- subset(people.table, 
                       numlangs>=MIN.LANGS,
                       #& birthyear>=MIN.YEAR, # Year filtering done in Python later... 
                       #& birthyear<=MAX.YEAR,
                       select=c(fb_name, birthyear, countryName, numlangs))

# Rename columns
colnames(people.table)[1] <- "Name"
colnames(people.table)[2] <- "Birth"
colnames(people.table)[3] <- "BirthCountry"

# Write to file
write.table(people.table, file="wiki_11k_Birth_langs20.tsv", sep='\t', quote=F, row.names=F)