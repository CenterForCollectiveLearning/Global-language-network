this folder: processed export table for regressions, from Wikipedia

2013-05/
	Used for the May submission to Science. L>=20.
	Full country names, older country-to-lang mapping.

	wiki_data/
		culture.sqlite3: dump of people containing all 4 cultural exports criteria: DOB, POB, gender, occupation
	
		get_wiki_tables.R: convert the dump to TSV file after applying some filters 

		wiki_4crit_Birth_langs20.tsv: list of people with Wikipedia articles in AT LEAST 20 langs. 13,334 total, 6158 born 1800-1950. USED FOR MAY SUBMISSION.
	
2013-06/
	Not used. L>=20 after manual curation.


2013-10/
	Used for the November submission to Nature. L>=26 from Observatory.
	Using two-letter country codes and new country-to-lang mapping.

	wiki_data/
		l26_observatory_manualcleaning2.sqlite3: File with L>25 (not >=!) people from the Global Culture Observatory (as of 9/27/2013). The relevant table is culture3.
	
		get_observatory_tables.R: convert the observatory dump to TSV files.

		wiki_observ_langs26.tsv: list of people with Wikipedia articles in AT LEAST 26 langs. 10,163 total, X born 1800-1950. USED FOR NOV. SUBMISSION.

