We used the September 2012 person.tsv file from Freebase (cultural-exports/freebase/match_2012-12-25_Sept in the Cultural Exports repo). The file contains 2,345,208 entries.

We matched the file with Wikipedia, getting 991,684 matches.

The Wikipedia table we used contains 216,280 people and is available in the database
(check the "ranking" table):
net-langs/data/cultural_production/wikipedia/wiki_data/culture.sqlite3. 

We use the following files for the exports tables:

Table 8: 
-net-langs/data/cultural_production/wikipedia/wiki_4crit_langs20_all_country_exports.tsv
-net-langs/data/cultural_production/wikipedia/wiki_4crit_langs20_1800_1950_country_exports.tsv

Table 9:
-net-langs/data/cultural_production/wikipedia/wiki_4crit_langs20_all_language_exports.tsv
-net-langs/data/cultural_production/wikipedia/wiki_4crit_langs20_1800_1950_language_exports.tsv

Table 10:
-net-langs/data/cultural_production/murray/HA_unique_countries_resolved_all_country_exports.tsv
-net-langs/data/cultural_production/murray/HA_unique_countries_resolved_1800_1950_country_exports.tsv

Table 11:
-net-langs/data/cultural_production/murray/HA_unique_countries_resolved_all_language_exports.tsv
-net-langs/data/cultural_production/murray/HA_unique_countries_resolved_1800_1950_language_exports.tsv