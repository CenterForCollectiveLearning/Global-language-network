LANG_CONNECTIONS_HEADER = ['Lang1', 'Lang2', 'NumOfCommonUsers', \
                           'NumOfUsersLang1', 'NumOfUsersLang2',\
                           'NumOfPolysLang1', 'NumOfPolysLang2', \
                           'TotalNumOfUsers', 'TotalNumOfPolyglots']

LANG_INFO_HEADER = ['Language', \
                    'NumOfExps', 'NumOfUsers', 'AvgExpsPerUser', \
                    'NumOfExpsByPolys', 'NumOfPolyglots', 'AvgExpsPerPoly', \
                    'TotalNumUsers', 'TotalNumOfPolys']

BOOKS_LANG_CONNECTIONS_HEADER = ['Lang1, Lang2', 'NumOfTranslations']
BOOKS_INFO_HEADER = ['Language', 'TranslatedFrom', 'TranslatedTo', 'OutDegree',
                     'InDegree']

LANG_DEGREE_HEADER = ['Language', 'NumOfConnectedLanguages']

LANGS_TO_REMOVE = {

# xxx is IGNORE; most other langs have fewer than 100 users in the full dataset;
# last six languages have fewer than 100 users after applying all other thresholds
'twitter': ['xxx', 'am', 'bo', 'dv', 'iu', 'km', 'mn', 'or', 'syr', 'xx-Copt', 'xx-Dsrt', 'xx-Glag', 'xx-Nkoo', 'xx-Ogam', 'xx-Phnx', 'xx-Runr', 'xx-Tale', 'xx-Tfng', 'xx-Yiii', 'yi', 'lo', 'kn', 'chr', 'my', 'gu', 'te'],

# The following languages have fewer than 100 users after filtering out languages
# with fewer than 5 edits by single user and users with fewer than user and users
# with fewer than 20 edits total
#WIKI_LANGS_TO_REMOVE = [ 'mus', 'kj', 'ii', 'ho', 'kr', 'hz', 'cho', 'mh', 'ng', 'ks', 'ny', 'srn', 'pi', 'aa', 'tum', 'pag', 'sg', 'ts', 'ti', 'sn', 'lg', 'ik', 'kaa', 'om', 'ki', 'dz', 'rn', 've', 'lbe', 'ss', 'tw', 'ty', 'fj', 'pnt', 'chy', 'ff', 'tn', 'st', 'xh', 'kg', 'rw', 'ha', 'cdo', 'mdf', 'glk', 'sd', 'za', 'ch', 'bxr', 'mzn', 'rmy', 'pih', 'myv', 'bm', 'to', 'xal', 'bh', 'nov', 'haw', 'bi', 'iu', 'sm', 'tet', 'av', 'ln', 'bug', 'hak', 'mhr', 'mo', 'zu', 'pa', 'ak', 'ee', 'got', 'nrm', 'roa_tara', 'arc', 'cr', 'ig', 'or', 'udm', 'gan', 'stq', 'map_bms', 'kab', 'bcl', 'nv', 'fiu_vro', 'na', 'chr', 'pap', 'ilo', 'lo', 'new', 'ps', 'ce', 'ie', 'cbk_zam']

# The following languages have fewer than 1000 users after filtering using the
# above settings (5 + 20)
#WIKI_LANGS_TO_REMOVE = ['mus', 'kj', 'ii', 'ho', 'kr', 'hz', 'cho', 'mh', 'ng', 'ks', 'ny', 'srn', 'pi', 'aa', 'tum', 'pag', 'sg', 'ts', 'ti', 'sn', 'lg', 'ik', 'kaa', 'om', 'ki', 'dz', 'rn', 've', 'lbe', 'ss', 'tw', 'ty', 'fj', 'pnt', 'chy', 'ff', 'tn', 'st', 'xh', 'kg', 'rw', 'ha', 'cdo', 'mdf', 'glk', 'sd', 'za', 'ch', 'bxr', 'mzn', 'rmy', 'pih', 'myv', 'bm', 'to', 'xal', 'bh', 'nov', 'haw', 'bi', 'iu', 'sm', 'tet', 'av', 'ln', 'bug', 'hak', 'mhr', 'mo', 'zu', 'pa', 'ak', 'ee', 'got', 'nrm', 'roa_tara', 'arc', 'cr', 'ig', 'or', 'udm', 'gan', 'stq', 'map_bms', 'kab', 'bcl', 'nv', 'fiu_vro', 'na', 'chr', 'pap', 'ilo', 'lo', 'new', 'ps', 'ce', 'ie', 'cbk_zam', 'kv', 'ay', 'zea', 'wo', 'ug', 'diq', 'eml', 'kl', 'as', 'jbo', 'mi', 'gn', 'dv', 'cu', 'ab', 'lij', 'ext', 'pam', 'roa_rup', 'dsb', 'mg', 'frp', 'hif', 'crh', 'bpy', 'gv', 'sah', 'bo', 'kw', 'so', 'yo', 'tk', 'tpi', 'fur', 'pdc', 'my', 'sc', 'ba', 'am', 'rm', 'csb', 'se', 'ky', 'os', 'nah', 'bat_smg', 'ksh', 'wa', 'ne', 'nds_nl', 'co', 'szl', 'su', 'gu', 'wuu', 'war', 'sa', 'mt', 'ht', 'cv', 'tg', 'hsb', 'vls', 'zh_min_nan', 'ceb', 'nap', 'pms', 'ang', 'qu', 'tt', 'uz', 'km', 'gd', 'li', 'vec', 'fo', 'lmo', 'io', 'mn', 'ia', 'zh_classical', 'jv', 'vo', 'kn', 'sco', 'scn', 'arz', 'ku', 'fy', 'ur', 'sw', 'yi', 'bar', 'nds', 'ast', 'an', 'si', 'ga', 'mr', 'oc', 'te', 'als', 'hy', 'br', 'kk', 'tl', 'sh', 'lb', 'bn', 'cy', 'be', 'zh_yue', 'be_x_old', 'ta', 'af']

# The following languages have fewer than 1000 users before filtering using
# the above settings (5 + 20)
'wikipedia': ['tokipona', 'kj', 'mus', 'ho', 'ii', 'kr', 'hz', 'cho', 'mh', 'mo', 'aa', 'ng', 'srn', 'ny', 'pnt', 'pi', 'ts', 'tum', 'sg', 'rn', 've', 'ks', 'lg', 'ti', 'sn', 'ss', 'pag', 'tw', 'ki', 'ik', 'xh', 'chy', 'mdf', 'om', 'ff', 'kaa', 'ty', 'dz', 'kg', 'fj', 'st', 'lbe', 'za', 'myv', 'ha', 'bxr', 'tn', 'rw', 'cdo', 'mhr', 'sm', 'tet', 'to', 'pih', 'mzn', 'ch', 'bug', 'ig', 'got', 'kab', 'sd', 'xal', 'nov', 'av', 'rmy', 'bh', 'bm', 'bi', 'iu', 'cr', 'roa_tara', 'ee', 'zu', 'or', 'na', 'ak', 'haw', 'ln', 'stq', 'wo', 'zea', 'chr', 'glk', 'hak', 'udm', 'pap', 'kv', 'pa', 'ie', 'jbo', 'nrm', 'ce', 'as', 'kl', 'lo', 'arc', 'fiu_vro', 'cbk_zam', 'bcl', 'gn', 'tpi', 'ab', 'roa_rup', 'nv', 'ilo', 'frp', 'mi', 'ug', 'gan', 'crh', 'ay', 'cu', 'ext', 'diq', 'eml', 'lij', 'dsb', 'map_bms', 'ps', 'dv', 'mg', 'new', 'ba', 'kw', 'tk', 'pdc', 'sah', 'gv', 'pam', 'hif', 'bo', 'se', 'fur', 'rm', 'sc', 'csb', 'bpy', 'ky', 'yo', 'szl', 'my', 'so', 'co', 'sa', 'wa', 'nah', 'ksh', 'am', 'bat_smg', 'os', 'nds_nl', 'mt'],

'books': []
}

LANGS_TO_MERGE = {
    # Merging Twitter: merge zh and zh-TW to "zh" to comply with Macrolanguage conversion
    'twitter': [],
    'wikipedia': [],
    'books': []
}