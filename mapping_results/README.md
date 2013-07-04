Notes about the different result folders
===

- settings.py: stores the settings used for each processing.

The following folder is the one that interests us: 

- Normalized: exposure score for each pair of languages (directed for all datasets)

These are also interesting:

- Preprocessed: original user-language table after filtering; statistics by language/node (langinfo); and by language connection/link (langlang)

- Extracted: number of common users for each pair of languages (Twitter and Wikipedia, undirected), or of translations between languages (book translations, directed). Note that this is the absolute number although the column header says "exposure".

The following folders are not used at all:

- Processed: the average exposure scores of all datasets.

- Final: the average exposure scores of all datasets, after some filtering.  
