*** FILES IN THIS FOLDER ***

-speakers_families_iso639-3.tsv: full names, speaker estimates (L1+L2, in millions), and language family classification for ~280 languages. Estimates from http://stats.wikimedia.org/EN/Sitemap.htm, June 30, 2012. Missing figures were taken from Wikipedia articles. Extinct languages were assigned the value 0.000001 (to avoid zero values).

-speakers_iso639-3_native: full names and speaker estimates (native only) from Ethnolgoue, 16th edition.


*** SPEAKER ESTIMATES: CASE BY CASE ***

-Wikipedia speaker stats probably already include Egyptian Arabic in Arabic, no need to add 76 million to 530 million.

-Same for Serbo-Croatian: 23M includes 12M for Serbian, 6M for Croatian, 3M for Bosnian?

-Chinese includes some dialects: Cantonese, Min-Nan, etc. Mandarin Chinese is 1.3B according to Wikipedia stats.

-Akan: 19M prob. includes Twi 

-Komi (293k): includes 94k for Komi-Perniak. 

-Punjabi / Panjabi (104M): not merged with Landa.

-Malay (300M): may include Indonesian (250M) and Javanese (80M). See http://ipll.manoa.hawaii.edu/indonesian/2012/03/10/how-many-people-speak-indonesian/. Note that according to ISO639-3, the Malay macrolanguage does not include Javanese.

-Norwegian (5M): prob. includes Nynorsk (5M), which is a new writing system for Norwegian. 

-Swiss German: listed separately from German (not merged according to ISO 639-3 macrolanguages).

-Romanian (28M according to stats.wikimedia) and Moldavian (3.5M, as the population of Moldova) are essentially the same lagnuage. The former is written in Latin script and the latter in Cyrillic. ISO 639-3 doesn't merge them and neither do we.

-Aramaic (2M according to stats.wikipedia) and Syriac (very few speakers) are not merged, though the estimate for the former is likely to include the latter and then some.


*** LANGUAGE FAMILIES *** 

The thumb rule for language families is as follows:
- Family_Name: lowest language family in the language's hierarchy that has an ISO 639-5 entry.
- Viz_Family_Name: language family to use in network visualizations. More detail for Indo-European at the expense of less-studied languages.
- Primary_Family_Name: highest language family available. North- and South-American Indian languages are merged into Amerindian languages, and some other languages merged to "Other" to reduce the number.