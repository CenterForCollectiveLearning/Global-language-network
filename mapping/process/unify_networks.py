import codecs, csv
from collections import Counter
from collections import defaultdict

INFILE_TWITTER = 'input/v6_langlang.txt'
INFILE_WIKI = 'input/v7_wiki_langlang.txt'
INFILE_BOOKS = 'input/UNESCO_langlang.txt'
INFILE_LANG_MAPPER = 'output/TranslationSummary.txt'
OUTFILE = 'output/v4_total_langlang_std_min_common_no_bonferroni_for_wiki.txt'

TWITTER_WIKI_DELIM = '\t'
BOOKS_DELIM = '|'
OUTPUT_DELIM = '\t'

SRC_BOOKS = "Books"
SRC_WIKI = "Wiki"
SRC_TWITTER = "Twitter"
NUM_SRC = "NumSources"

# Filters
MIN_SOURCES = 3  # Min. number of sources required to include a language links
ALL_SOURCES = 3  # Total number of sources

# Adding another filters... connecting languages based on a single common user
# is a bit audacious!
MIN_COMMON_TWITTER_USERS = 10
MIN_COMMON_WIKI_EDITORS = 10
MIN_COMMON_TRANSLATIONS = 5

LANG_MAPPER = {}

'''
- Algorithm:
    X Create a central langlang file
    X For each medium's langlang file:
        X Read line, convert language names according to TranslationSummary.TXT, add to Counter
        X Treat books as undirected (e.g., "Dutch-English" would also include "English-Dutch" translations)
        X Count number of sources for each link.
    X Write file.
    X Use only links that appear in two out of three sources.
    - Think of a ranking system: how to average/filter the links? for the time being I require them to appear on ALL three sources with a minimum number of expressions per each sources (changes from source to source)
    - Wikipedia is a problem: too many auto-edits. Maybe we should get only edits that change at least X bytes?
- Draw in CytoScape: Size by number of speakers/users, Color by Language family http://en.wikipedia.org/wiki/File:Human_Language_Families_Map.PNG . Classify the languages manually for now.
- Add Pinterest diffusion
'''

def create_lang_mapper(trans_map):
    '''
    Create a helper dictionary for converting language names/codes to standard form
    Use passed file as input
    '''
    lang_mapper = defaultdict()
    fmap = codecs.open(trans_map, 'rU')

    # find the standard lang code/names and the possible language names
    for line in fmap:
        splt = line[:-1].split(OUTPUT_DELIM)
        splt = [value for value in splt if value!=''] # remove empty items
        std_lang_code = splt[0] # always the first item
        std_lang_name = splt[1] # always the second

        # separates the standard names from the possible names
        all_lang_name = splt[splt.index("INCLUDES")+1:]
        for possible_name in all_lang_name:
            lang_mapper[possible_name] = {'code':std_lang_code, 'name':std_lang_name}
            #print possible_name, lang_mapper[possible_name]

    return lang_mapper


def update_langlang_from_source(langlang, fname, srcname):
    '''
    Add language links from passed source to passed language links dictionary,
    classified under key "srcname". Harmonize language names.
    '''
    fin = codecs.open(fname, 'rU')

    if srcname!=SRC_BOOKS:
        fin.readline() # skip header

    for line in fin:
        vals = line[:-1].split(TWITTER_WIKI_DELIM)

        # Only interested in first three values: lang1, lang2, number of links
        if srcname==SRC_BOOKS:
            # UNESCO file separates lang1 and lang2 using a different separator
            lang1, lang2 = vals[0].split(BOOKS_DELIM)
            common = vals[1]
        else:
            lang1, lang2, common = vals[:3]

        # Standardize language names:

        try:
            lang1_std = LANG_MAPPER[lang1]['code']
        except KeyError:
            lang1_std = lang1 # use original lang code
            #print lang1
        try:
            lang2_std = LANG_MAPPER[lang2]['code']
        except KeyError:
            lang2_std = lang2 # use original lang code
            #print lang2

        # Add to dictionary
        if srcname==SRC_BOOKS and lang1>lang2:
            # Treat as undirected: tuples are alphabetically ordered, so swap
            # if necessary to make sure (lang2,lang1) is added to (lang1,lang2)
            lang2_std, lang1_std = lang1_std, lang2_std
        #print lang1, lang2, srcname, common
        langlang[(lang1_std,lang2_std)][srcname] += int(common)

    return langlang


def write_langlang(langlang, fname):
    '''
    Print the dictionary with stats for each link to a file
    '''
    # Convert dictionary to a data structure that's easier to augment and write
    links_to_write = []

    for (lang1, lang2), stats in langlang.iteritems():
        link_row =  {'Lang1': lang1, 'Lang2': lang2} #"%s%s%s"%(lang1,OUTPUT_DELIM,lang2)}
        link_row.update(stats)

        # Pad with '0' to indicate a source doesn't have a link--
        # Otherwise the columns will be mixed; Also, count number
        # of sources
        num_sources = ALL_SOURCES
        if SRC_BOOKS not in stats.keys():
            link_row.update({SRC_BOOKS: 0})
            num_sources -= 1
        if SRC_WIKI not in stats.keys():
            link_row.update({SRC_WIKI: 0})
            num_sources -= 1
        if SRC_TWITTER not in stats.keys():
            link_row.update({SRC_TWITTER: 0})
            num_sources -= 1
        link_row.update({NUM_SRC: num_sources})
        links_to_write.append(link_row)

    hdr = ["Lang1", "Lang2", SRC_TWITTER, SRC_WIKI, SRC_BOOKS, NUM_SRC]
    dw = csv.DictWriter(codecs.open(fname, 'w'), delimiter=OUTPUT_DELIM, fieldnames=hdr)

    # Write only links that appear in at least MIN_SOURCES sources
    dw.writeheader()
    for lang_pair_row in links_to_write:
        #print lang_pair_row
        if lang_pair_row[NUM_SRC] >= MIN_SOURCES and \
            lang_pair_row[SRC_TWITTER]>MIN_COMMON_TWITTER_USERS and \
            lang_pair_row[SRC_WIKI]>MIN_COMMON_WIKI_EDITORS and \
            lang_pair_row[SRC_BOOKS]>MIN_COMMON_TRANSLATIONS:
            #print lang_pair_row # debug
            dw.writerow(lang_pair_row)

if __name__ == "__main__":
    print "Using the following settings:"
    print "*****************************"
    print "MIN_SOURCES:", MIN_SOURCES
    print "MIN_COMMON_TWITTER_USERS:", MIN_COMMON_TWITTER_USERS
    print "MIN_COMMON_WIKI_EDITORS:", MIN_COMMON_WIKI_EDITORS
    print "MIN_COMMON_TRANSLATIONS:", MIN_COMMON_TRANSLATIONS

    LANG_MAPPER = create_lang_mapper(INFILE_LANG_MAPPER)

    # Format: { "lang1,lang2": {"Twitter": num, "Wiki": num, "Books": num, "Src": number of sources, "Avg.": ?} }
    langlang = defaultdict(Counter)
    langlang = update_langlang_from_source(langlang, INFILE_TWITTER, SRC_TWITTER)
    langlang = update_langlang_from_source(langlang, INFILE_WIKI, SRC_WIKI)
    langlang = update_langlang_from_source(langlang, INFILE_BOOKS, SRC_BOOKS)

    # Write to file
    write_langlang(langlang, OUTFILE)
