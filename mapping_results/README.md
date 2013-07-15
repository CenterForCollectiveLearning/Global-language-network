Notes about the different result folders
===

- settings.py: stores the settings used for each processing.


The folder we're interested in is this one:
- Preprocessed: original user-language table after filtering; statistics by language/node (langinfo); and by language connection/link (langlang).

Run data/gln_sources/prep_langinfo_tables.R and data/gln_sources/prep_langlang_tables.R to get the desired statistics for this file. Make sure to use the update the path at the beginning of the R scripts to the results folder you want to use.

NOTE: The results will be saved to data/gln_sources -- move them to the respective folder under analysis so they're not overwritten.

* * *

The following folders contain post-proccessed table, made redundant by the above procedure:

- Normalized: exposure score for each pair of languages (directed for all datasets)

- Extracted: number of common users for each pair of languages (Twitter and Wikipedia, undirected), or of translations between languages (book translations, directed). Note that this is the absolute number although the column header says "exposure".

The following folders are not used at all:

- Processed: the average exposure scores of all datasets.

- Final: the average exposure scores of all datasets, after some filtering.  
