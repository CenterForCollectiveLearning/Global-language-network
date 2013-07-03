
# analysis/load/usertable.py

'''
Module for filtering the user-language network based on the following
pre-defined thresholds, in the following order:
- Merge similar languages
- Discard languages without enough users, and language XXX (these languages
  are hard-coded based on each analysis, thus named "blacklisted")
- For each user, discard languages he/she rarely tweets in
- Discard users without enough tweets, after above criteria were applied
'''

import re
import sys
import mmap
from collections import Counter
from collections import defaultdict

import multiprocessing
from multiprocessing import Pool
import time
from common_utils import *
from common_utils.progressbar import ProgressBar, Percentage, Bar, Counter, Timer
import convert_lang

from settings import LANG_SETTINGS

failures = 0

def get_chunks(infile, inheader, size=50*1024*1024):
    fin = open(infile)
    if inheader is not None:
        infile.readline()
    while True:
        start = fin.tell()
        fin.seek(size, 1)
        s = fin.readline()
        yield start, fin.tell() - start
        if not s:
            break


def process_chunk(infile, chunk, outfile, total_line_count,
                  major_delim, minor_delim,
                  inheader, outheader,
                  langs_to_merge, langs_to_remove,
                  min_per_language, min_per_user):
    "Process one chunk"
    fin = open(infile, 'rU')
    if inheader != None:
        fin.readline()  # skip header if exists

    fout = open(outfile, 'a')
    global failures

    pbar = ProgressBar(widgets=['                        Processed ',
                       Counter(), ' lines (', Timer(),')'],
                       maxval=chunk[1]).start()

    fin.seek(chunk[0])

    line_count = 0
    chunk_failures = 0

    # Initialize conversion table
    iso3_table, code_to_name = \
        convert_lang.init_conversion_table_iso3(LANG_SETTINGS['lang_conversion_file'])
    langs_not_converted = set() # for storing failed conversions

    for line in fin.read(chunk[1]).splitlines():
        line_count += 1
        if line_count % 20000 == 0: pbar.update(line_count)# print "\t\t\tLine", line_count

        splt = line.split(major_delim)
        user = splt[0]
        try:
            # load languages that are not blacklisted (keys) and respective number
            # of tweets (values) into a dictionary
            orig_lang_list = dict([(lang, int(num)) for (lang, num) in \
                                   (langinfo.split(minor_delim) for langinfo in splt[1:]) \
                                   if (lang not in langs_to_remove)])
        except ValueError:
            print ">>> Fail"
            print line
            failures += 1 # TODO: should this be chunk_failures? Shahar
            continue

        user_langs = defaultdict(int)    # user_langs = Counter() defaultdict(int) is faster
        for lang, num in orig_lang_list.iteritems():
            #normalized_lang = \
            #                  lang if lang not in langs_to_merge else langs_to_merge[lang]
            #user_langs[normalized_lang] += num
            try:
                normalized_lang = iso3_table[lang]
                #print lang, normalized_lang
                user_langs[normalized_lang] += num
            except KeyError:
                #print "Language \'%s\' not found!" % (lang)
                langs_not_converted.add(lang)

        total_user_num = 0
        for lang, num in user_langs.items():
            # Discard languages that don't meet the threshold.
            # Using items() instead of iteritems() allows removing items from
            # dictionary while iterating on it (actually iterating on a copy)
            if num < min_per_language:
                user_langs.pop(lang)
            else:
                total_user_num += num

        # Write user and languages if user meets the minimum tweets requirement,
        # preserving the original format
        if total_user_num >= min_per_user:
            final_lang_list = major_delim.join([ \
                        minor_delim.join([lang_name, str(lang_tweets)]) \
                        for lang_name, lang_tweets in user_langs.iteritems()])
            fout.write(major_delim.join([user, final_lang_list]) + '\n')

    failures += chunk_failures
    print "Languages not converted:", langs_not_converted
    pbar.finish()
    fout.close()


def filter_userlang_network(infile, outfile, total_line_count, paths, major_delim, minor_delim,
                            inheader=None, outheader=None, langs_to_merge=[],
                            langs_to_remove=[], min_per_language=1, min_per_user=1):
    global failures

    start_time = time.time()

    # Initializing pools
    pool_size = multiprocessing.cpu_count() * 2
    pool = Pool(processes=pool_size)

    # Distribute chunks to processes
    chunk_count = 1
    for chunk in get_chunks(infile, inheader, size=50*1024*1024):
        print "\t\tChunk:", chunk_count
        proc_outfile = outfile  # outfile.split('.')[0] + "_" + str(chunk_count) + \
                       # "." + outfile.split('.')[1]
        pool.apply(process_chunk,
                   [infile, chunk, proc_outfile, total_line_count, major_delim, minor_delim,
                    inheader, outheader, langs_to_merge, langs_to_remove,
                    min_per_language, min_per_user])
        chunk_count += 1

    pool.close()
    pool.join()
    print "TIME TO FINISH: ", time.time() - start_time
    print "\tFailed: ", failures
    print "\tDone!"

    return

"""
def filter_userlang_network(infile, outfile, line_count, paths, major_delim, minor_delim,
                            inheader=None, outheader=None, langs_to_merge=[],
                            langs_to_remove=[], min_per_language=1, min_per_user=1):
    '''
    Remove users that don't meet the number of tweets threshold and remove lines
    where number of tweets doesn't meet threshold, or language is blacklisted.
    -Input: delimited file with list of languages for each user, in the format:
     user lang1,num1 lang2,num2 lang3,num3 ...
    -Output: delimited file in the same format after applying filter criteria.
    '''
    start_time = time.time()

    # print note
    #print "\tFiltering using following settings:"
    # print "\t\tLangs to merge=%s\nLangs to remove=%s" % \
    #    (', '.join(langs_to_merge), ', '.join(langs_to_remove))
    print "\t\t\tMin. per language: %d\tMin. per user: %d\n" % \
        (min_per_language, min_per_user)

    # open files and write headers
    fin = open(infile, 'rU')
    if inheader != None:
        fin.readline()  # skip header if exists
    fout = open(outfile, 'w')
    if outheader != None:
        fout.write(outheader)

    # pbar = ProgressBar(widgets=['>>> Processed ',Counter(), ' lines (', Timer(),')'], maxval=line_count).start()

    lines = 0
    m = mmap.mmap(fin.fileno(), 0, prot=mmap.PROT_READ)
    failed = 0
    for chunk in get_chunks(infile, inheader):
        m.seek(chunk[0])
        for line in m.read(chunk[1]).splitlines():
            lines += 1
            if lines % 1000000 == 0: print "\t\t\tLine",lines
            # pbar.update(lines + 1)
            splt = line.split(major_delim)
            user = splt[0]
            try:
                # load languages that are not blacklisted (keys) and respective number
                # of tweets (values) into a dictionary
                orig_lang_list = dict([(lang, int(num)) for (lang, num) in \
                                       (langinfo.split(minor_delim) for langinfo in splt[1:]) \
                                       if (lang not in langs_to_remove)])
            except ValueError:
                failed += 1
                continue

            user_langs = defaultdict(int)    # user_langs = Counter() defaultdict(int) is faster
            for lang, num in orig_lang_list.iteritems():
                normalized_lang = \
                                  lang if lang not in langs_to_merge else langs_to_merge[lang]
                user_langs[normalized_lang] += num

            total_user_num = 0
            for lang, num in user_langs.items():
                # Discard languages that don't meet the threshold.
                # Using items() instead of iteritems() allows removing items from
                # dictionary while iterating on it (actually iterating on a copy)
                if num < min_per_language:
                    user_langs.pop(lang)
                else:
                    total_user_num += num

            # Write user and languages if user meets the minimum tweets requirement,
            # preserving the original format
            if total_user_num >= min_per_user:
                final_lang_list = major_delim.join([ \
                    minor_delim.join([lang_name, str(lang_tweets)]) \
                    for lang_name, lang_tweets in user_langs.iteritems()])
                fout.write(major_delim.join([user, final_lang_list]) + '\n')
    # pbar.finish()
    print "\tFailed: ", failed
    print "\tDone!"
    fout.close()
    return
"""

"""
# TODO: This function is on its way out - Shahar 2012/7/26

def randomize_preserving_user_and_lang_degrees_in_memory(userlang):
    '''
    Create a randomized version of the usertable file by randomly assigning
    each user who speaks k languages k new language according to the language
    distribution.
    Note: doesn't preserve number of tweets for either users or languages!
    -Input: a clean user-language network
    -Return: randomized user-language network
    '''

    # users_per_lang holds the number of users who tweet in each language.
    # NOW WE DO STORE THE USER-LANGUAGE DATA STRUCTURE: a data strucure with the
    # number of languages used by each user is not stored in memory becuase of its
    # potential size (tens of millions of users vs. <100 languages.
    users_per_lang = Counter()

    # Find the number of users who tweet in each language
    for i, (user, lang_codes) in enumerate(userlang.iteritems()):
        for lang in lang_codes:
            users_per_lang[lang] += 1

        # progress bar
        if i % 1000000 == 0:
            print "\tGetting # users for each language, line", i

    # Now assign each user new languages, in place, based on language distribution.
    for i, (user, lang_codes) in enumerate(userlang.iteritems()):
        # Now randomly select num_lang_for_this_user languages according to the
        # distribution of the languages calculated above
        # Add ,1 for compatability with langtable.py later
        userlang[user] = dict([(lang, 1) for lang in
            random_sample.random_weighted_sample_no_replacement( \
            users_per_lang, len(lang_codes))])

        if i % 1000000 == 0:
            print "\tAssigning each user new languages, line", i

    return userlang
"""


if __name__ == "__main__":

    # Filters used when ran from command line
    MIN_TWEETS_PER_LANGUAGE = 2
    MIN_TWEETS_PER_USER = 5

    MIN_EDITS_PER_LANGUAGE = 2
    MIN_EDITS_PER_USER = 5

    # xxx is IGNORE; most other langs have fewer than 100 users in the full dataset;
    # last six languages have fewer than 100 users after applying all other thresholds
    #LANGS_TO_REMOVE = ['xxx', 'am', 'bo', 'dv', 'iu', 'km', 'mn', 'or', 'syr', 'xx-Copt', 'xx-Dsrt', 'xx-Glag', 'xx-Nkoo', 'xx-Ogam', 'xx-Phnx', 'xx-Runr', 'xx-Tale', 'xx-Tfng', 'xx-Yiii', 'yi', 'lo', 'kn', 'chr', 'my', 'gu', 'te']
    LANGS_TO_REMOVE = [] # TODO: consider removing and use all languages -- the smaller ones will drop during merge anyway

    # Our initial analysis shown that these languages are strongly correlated.
    # Other such languages are: af-nl, da-nb, fa-ur (latter use same script but
    # sound different)
    # LANGS_TO_MERGE = {'sr': 'hr-sr', 'hr': 'hr-sr', 'zh': 'zh-zh-TW', 'zh-TW': 'zh-zh-TW', 'id': 'id-ms', 'ms': 'id-ms'}
    LANGS_TO_MERGE = {} # TODO: consider removing: languages already merged in prep stage now


    if len(sys.argv) != 2:
        print "usage: python usertable.py infile"
        exit()

    infile = sys.argv[1]
    cleanfile = append_to_filename(infile, 'filtered')

    st_time = time.time()
    filter_userlang_network(infile, cleanfile,
        major_delim=USERLANG_MAJOR_DELIM,
        minor_delim=USERLANG_MINOR_DELIM,
        langs_to_merge=LANGS_TO_MERGE, langs_to_remove=LANGS_TO_REMOVE,
        min_tweets_per_language=MIN_TWEETS_PER_LANGUAGE,
        min_tweets_per_user=MIN_TWEETS_PER_USER)
    tot_time = time.time() - st_time
    print "\tCreated file: %s in %0.2f seconds" % (cleanfile, tot_time)
