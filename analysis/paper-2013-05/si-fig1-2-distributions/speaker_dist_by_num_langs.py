## <root>/speakers_dist_by_num_langs.py

import sys, os
from collections import Counter

LGN_HOME = os.path.abspath(os.path.relpath(os.path.join(__file__, '../../../../')))
GLN_SOURCES_HOME = os.path.join(LGN_HOME, 'data/gln_sources')

sys.path.append(os.path.join(GLN_SOURCES_HOME, "twitter"))
import lang_id

TWITTER_USERLANG_FILE = os.path.join(GLN_SOURCES_HOME, 
     "twitter/gold/twitter_20120505_90_userlang_stripped_full_iso639-3.dat")

WIKIPEDIA_USERLANG_FILE = os.path.join(GLN_SOURCES_HOME, 
    "wikipedia_edits/gold/wikipedia_20120612_userlang_full_nosuffix_iso639-3.dat")
# For showing number of tweets for a given certainty
TWITTER_SAMPLE_TWEETS_FILE = os.path.join(GLN_SOURCES_HOME, "twitter/orig/twitter_data/1m.tweets.txt")

WIKI_DELIM = TWITTER_DELIM = OUTPUT_DELIM = '\t'

#import plots # Done in R now.

def get_speakers_dist_by_num_langs(infile, outfile, indelim):
    # Init reader: use a delimiter
    fin = open(infile, 'rU')
    fout = open(outfile, 'w')
    # headerline = fin.readline() # skip header if exists

    # Find out how many users speak any given number of languages
    num_langs_used = Counter()
    for i, row in enumerate(fin):
        if i%1000000==0: print "Processing line %s" % i

        splt = row[:-1].split(indelim) # remove EOL and split

        # user is the first value
        user = splt[0]
        # num of langs used is the number of items on list, excluding username
        num_langs = len(splt)-1

        num_langs_used[num_langs] += 1

    fin.close()

    # print the results
    for num_langs, num_users in num_langs_used.iteritems():
        fout.write( "%s%s%s\n" % (num_langs, OUTPUT_DELIM, num_users) )
    fout.close()


if __name__ == "__main__":    

    # Get userlang file as input, output a table showing how many editors edit
    # in a given number of Wikiepdia languages
    print "***WIKIPEDIA***"
    get_speakers_dist_by_num_langs(WIKIPEDIA_USERLANG_FILE,
         'dist_langs_spoken_wiki.txt', WIKI_DELIM)
    #plot_dist('dist_langs_spoken_wiki.txt', 'dist_langs_spoken_wiki.eps', 'Wikipedia')

    # Same for Twitter
    print "***TWITTER***"
    get_speakers_dist_by_num_langs(TWITTER_USERLANG_FILE,
         'dist_langs_spoken_twitter.txt', TWITTER_DELIM)
    #plot_dist('dist_langs_spoken_twitter.txt', 'dist_langs_spoken_twitter.eps', 'Twitter')
    
    # Get a file containing tweets (in Bruno's format), detect their languages,
    # and output a table listing the identified language, certaintly, and length
    # (before and after cleaning) for each tweet) 
    print "Detecting Tweets from %s" % (TWITTER_SAMPLE_TWEETS_FILE)
    lang_id.create_user_lang_table_file(TWITTER_SAMPLE_TWEETS_FILE,
     "identified_tweets_table.txt", 
     clean_artifacts=True, threshold=0, write_certainty=True)
    print "DONE"




