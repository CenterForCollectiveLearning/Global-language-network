this folder: processed export table for regressions, from Wikipedia

Number of ppl with >=20 langs by country that have DOB, POB, gender and occupation:
All: 13334
Born 1800-1950: 6158

wiki_data/
	culture.sqlite3: dump of people containing all 4 cultural exports criteria: DOB, POB, gender, occupation
	get_wiki_tables.R: convert the dump to TSV file after applying some filters 
	wiki_4crit_Birth_langs20.tsv: list of people with Wikipedia articles in over 20 langs
