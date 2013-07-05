lang_demog: tables with population, GDP, etc.

lang_tools: language conversion tools: merging macrolanguages, conversion to ISO 639-3, etc.

gln_sources: sample user-language files for Twitter and Wikipedia, and input files from UNESCO's Index Translationum. 
- twitter/prep_twitter.py: creates a user-language table from our Twitter input, after stripping tweets from @-mentions, hashtags, URLs, etc.

gln_structure: post-processed langinfo (=node tables) and langlang (=edge tables) for each source. These are the actual files used for the original GLN paper. 