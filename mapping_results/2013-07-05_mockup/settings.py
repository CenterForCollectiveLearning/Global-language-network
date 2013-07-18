"""
Automated Analysis Settings
"""

SETTINGS = {

    'general': {
        'datasets_to_use': ['twitter', 'wikipedia', 'facebook', 'books'],
        'merge_first': False  # Merge first or extract first.
        },

    # Location of datasets relative to net-langs directory
    'dataset_locations': {
        'twitter': 'data/gln_sources/twitter/gold/twitter_20120505_90_userlang_stripped_full_iso639-3_sample.dat',
        'wikipedia': 'data/gln_sources/wikipedia_edits/gold/wikipedia_20120612_userlang_full_nosuffix_iso639-3_sample.dat',
        'facebook': 'data/gln_sources/facebook/gold/fb_iso639-3_sample.dat',
        'books': 'data/gln_sources/books_UNESCO/gold/unesco_langlang_20120722_iso639-3.txt',
        },

    # Dataset delimiters
    'delimiters': {
        'userlang_major_delim': {
            'twitter': '\t',
            'wikipedia': '\t',
            'facebook': '\t',
            'books': '\t'
            },

        'userlang_minor_delim': {
            'twitter': ",",
            'wikipedia': ",",
            'facebook': ',',
            },

        'langlang_delim': {
            'twitter': '\t',
            'wikipedia': '\t',
            'facebook': '\t',
            'books': '\t'
            },
        },

    # Cutoffs before merge + extract
    'pre-filtering': {
        # NOTE: pre-filtering settings are applied by usertable / langtable scripts,
        # and the produced "pre-processsed" files already reflect them.
        # Maximum languages per user
        'twitter_max_langs_per_user': 5,
        'wikipedia_max_langs_per_user': 5,
        'facebook_max_langs_per_user': 5,

        # Minimum tweets/edits per user
        'twitter_min_per_user': 5,
        'wikipedia_min_per_user': 5,
        'facebook_min_per_user': 5,

        # Minimum expressions per language per user
        'twitter_min_degree': 2,
        'wikipedia_min_degree': 2, # was 20 becasue of hypermultilingualism; max_langs_per_user hopefully handles it better
        'facebook_min_degree': 2,
        #'books_min_degree': 0, # N/A for books

        # Minimum weight per link
        # TODO: not used? -- check
        'twitter_min_weight': 0,
        'wikipedia_min_weight': 0,
        'facebook_min_weight': 0,
        'books_min_weight': 0,
        },

    'weight_cutoffs': {
        # Minimum number of common speakers/books for a pair of languages
        # NOTE: settings apply to "extracted" file; "pre-processed" aren't affected. 
        'twitter': 0, # was 100
        'wikipedia': 0, # was 100
        'facebook': 0, # was 100
        'books': 0, # was 25
        },

    'extraction': {
        # correlation or vespignani or probability or None
        'extraction': 'probability', #'vespignani',

        # Correlation Extraction
        'correlation_cutoff': 0.05,

        # Vespignani Extraction
        'cutoff_before': False,
        'vespignani_cutoff': 0.05,

        # probability cutoff
        'probability_cutoff': 0.00,
        'weight_cutoff': 0,
        },

    'merging': {
        # Normalization
        'normalize_to_one': True,

        # How many networks a node should be present in to keep
        'in_common': 2, #3, # 2, # 3, 2, 1
        },

    'post-filtering': {
        # Degree cutoffs after merge + extract
        'in_degree_cutoff': 0,
        'out_degree_cutoff': 0,

        # Weight cutoffs after merge + extract (network is normalized to three
        # if analyzing all three datasets!)
        'weight_cutoff': 0.0,
        'speaker_cutoff': 1

        },
    }

VISUAL_SETTINGS = {

        # Use "True" to produce a Gephi visualiation of the network
        # NOTE: Gephi visualization is not working properly, leave False for now
        'visualize': False, 

        'num_speakers_per_lang_file': 'data/lang_demog/population/gold/speakers_iso639-3_all.txt', # OR speakers_iso639-3_native.txt

        # Layout
        'layout': 'forceAtlas2', # forceAtlas, forceAtlas2, fruchterman, yifanHu, multilevel, random
        'layout_scale': 200.0,
        'barnes_hutt_optimize': True,
        'adjust_sizes': True,
        'layout_iterations': 10000,
        'threads_count': 6,

        # Degree Filtering
        'degree-top-cutoff': None,
        'degree-bottom-cutoff': None,

        # Ranking
        'rank_color': 'degree',
        'rank_size': 'centrality',

        # Min and max node and label size
        'min_node_size': 5, # 5 for books
        'max_node_size': 40, # 30 for books

        'min_label_size': 1,
        'max_label_size': 3,

        # Preview Properties
        'node_labels': True,
        'edge_curved': False,
        'arrow_size': 5.0, # changed from 7.0 (Shahar)
        'edge_color': 'GRAY',
        'edge_opacity': 100.,
        'node_border_width': 1.0,
        'margin': 15,

        # Export
        'export_image_formats': ['gexf', 'pdf', 'png', 'svg'],
        }

LANG_SETTINGS = {
    'lang_conversion_file': 'data/lang_tools/lang_conversion/gold/iso-639-3-20120726_conversion_nogeneric.txt',

    'lang_speakers_file': 'data/lang_demog/population/gold/speakers_iso639-3_all.txt',

    'LANG_CONNECTIONS_HEADER': ['Lang1', 'Lang2', 'NumOfCommonUsers', \
                                    'NumOfUsersLang1', 'NumOfUsersLang2',\
                                    'NumOfPolysLang1', 'NumOfPolysLang2', \
                                    'TotalNumOfUsers', 'TotalNumOfPolyglots'],

    'LANG_INFO_HEADER': ['Language', \
                             'NumOfExps', 'NumOfUsers', 'AvgExpsPerUser', \
                             'NumOfExpsByPolys', 'NumOfPolyglots', 'AvgExpsPerPoly', \
                             'TotalNumUsers', 'TotalNumOfPolys'],

    'BOOKS_LANG_CONNECTIONS_HEADER': ['Source', 'Target', 'NumTransFromSrc', 'NumTransToTgt', 'NumOfTransSrcToTgt'],

    'BOOKS_INFO_HEADER': ['Language', 'TranslatedFrom', 'TranslatedTo', 'OutDegree', 'InDegree'],

    'LANG_DEGREE_HEADER': ['Language', 'NumOfConnectedLanguages'],

    # Languages are merged through the conversion file --
    # leave the settings below blank.
    'LANGS_TO_REMOVE': {
            'twitter' : [],
            'wikipedia' : [],
            'facebook' : [],
            'twitter_old': ['xxx', 'am', 'bo', 'dv', 'iu', 'km', 'mn', 'or', 'syr', 'xx-Copt', 'xx-Dsrt', 'xx-Glag', 'xx-Nkoo', 'xx-Ogam', 'xx-Phnx', 'xx-Runr', 'xx-Tale', 'xx-Tfng', 'xx-Yiii', 'yi', 'lo', 'kn', 'chr', 'my', 'gu', 'te'],
            'wikipedia_old': ['tokipona', 'kj', 'mus', 'ho', 'ii', 'kr', 'hz', 'cho', 'mh', 'mo', 'aa', 'ng', 'srn', 'ny', 'pnt', 'pi', 'ts', 'tum', 'sg', 'rn', 've', 'ks', 'lg', 'ti', 'sn', 'ss', 'pag', 'tw', 'ki', 'ik', 'xh', 'chy', 'mdf', 'om', 'ff', 'kaa', 'ty', 'dz', 'kg', 'fj', 'st', 'lbe', 'za', 'myv', 'ha', 'bxr', 'tn', 'rw', 'cdo', 'mhr', 'sm', 'tet', 'to', 'pih', 'mzn', 'ch', 'bug', 'ig', 'got', 'kab', 'sd', 'xal', 'nov', 'av', 'rmy', 'bh', 'bm', 'bi', 'iu', 'cr', 'roa_tara', 'ee', 'zu', 'or', 'na', 'ak', 'haw', 'ln', 'stq', 'wo', 'zea', 'chr', 'glk', 'hak', 'udm', 'pap', 'kv', 'pa', 'ie', 'jbo', 'nrm', 'ce', 'as', 'kl', 'lo', 'arc', 'fiu_vro', 'cbk_zam', 'bcl', 'gn', 'tpi', 'ab', 'roa_rup', 'nv', 'ilo', 'frp', 'mi', 'ug', 'gan', 'crh', 'ay', 'cu', 'ext', 'diq', 'eml', 'lij', 'dsb', 'map_bms', 'ps', 'dv', 'mg', 'new', 'ba', 'kw', 'tk', 'pdc', 'sah', 'gv', 'pam', 'hif', 'bo', 'se', 'fur', 'rm', 'sc', 'csb', 'bpy', 'ky', 'yo', 'szl', 'my', 'so', 'co', 'sa', 'wa', 'nah', 'ksh', 'am', 'bat_smg', 'os', 'nds_nl', 'mt'],
            'books': []
            },

    'LANGS_TO_MERGE': {
        'twitter': [],
        'wikipedia': [],
        'facebook' : [],
        'books': []
        },
    }
