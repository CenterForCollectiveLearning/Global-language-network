All user-language (userlang) have the following format for each line:
<userid>\t<lang1_name,lang1_num_expressions>\t<lang2_name,lang2_num_expressions>\t...

where userid is the username on Twitter/Wikipedia/Facebook, lang1_name is the ISO 639-3 identifier for a language used by the user (e.g., "eng" for English or "fra" for French) and num_expressions is the number of expressions for each languages. The userlang files may list any number of languages per a single user--some Wikiepdia users edited in over 200 languages (!)--but we did discard users with more than 5 lanugages in the mapping pipeline.

facebook: mock sample file for Facebook -- basically a copy of the Twitter file.

twitter: first 10,000 rows of the actual Twitter userlang file. The full file includes ~1 billion (10^9) tweets by ~40 million users, collected through the Twitter garden hose between Dec 6, 2011 and Feb 12, 2012.

wikipedia: first 10,000 rows of the actual Wikipedia edits userlang file. The full file includes a list of registered users and their edit languages in all Wikipedia editions between 2001-2011.

prep_userlang.py: merges all the languages of one user to a single line (assuming all languages for a user are already listed contiguously)

* * *

books_UNESCO: full, actual data files from UNESCO's Index Translationum .