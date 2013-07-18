## <root>/data/prep_userlang.py

'''
Module for creating the user-language that would in turn be filtered for
thresholds and used for analysis.
Input is a file containing table with the following delimited structure:
 user language num_expressions
With all entries for each user listed together.
Output is a user-language network table, listing for each user the languages
he uses and the number of expressions in each language:
 user lang1,num_expressions1 lang2,num_expressions1 lang3,num_expressions1 ...

'''

import os
import sys
from collections import defaultdict, Counter
import timeit

LGN_HOME = os.path.abspath(os.path.relpath(os.path.join(__file__, '../../')))
ANALYSIS_HOME = os.path.join(LGN_HOME, 'analysis')
sys.path.append(ANALYSIS_HOME)

import common_utils

DEFAULT_INPUT_DELIM = '\t' # This has just changed...
DEFAULT_USERLANG_DELIM = '\t'
DEFAULT_LANGEXPS_DELIM = ','


def new_cluster_user_languages(infile, outfile, in_delim=DEFAULT_INPUT_DELIM, \
    inheader=None, outheader=None):
    fin = open(infile, 'rU')
    if inheader!=None: fin.readline() # skip header if exists
    fout = open(outfile, 'w')
    if outheader!=None: fclean.write(outheader)

    user_langs = defaultdict(int)

    for i, line in enumerate(fin):
        if i % 10000000 == 0:
            print ">>> line", i
        #user, lang, num_expressions = line[:-1].split(in_delim)
        #### This was changed

        vals = line[:-1].split(in_delim)
        user, lang = vals[0], vals[1]
        num_expressions = 1

        #### till here

        num_expressions = int(num_expressions)
        if user not in user_langs:
            user_langs[user] = {}
        if lang not in user_langs[user]:
            user_langs[user][lang] = num_expressions
        else:
            user_langs[user][lang] += num_expressions

    for user, lang_count in user_langs.iteritems():
        fout.write(user)
        for lang, count in lang_count.iteritems():
            fout.write('\t%s,%s' % (lang, count))
        fout.write('\n')

    fout.close()
    return


def cluster_user_languages(infile, outfile, in_delim=DEFAULT_INPUT_DELIM, \
    inheader=None, outheader=None):
    '''
    Prepare the user-language for further filtering and analysis.
    -Input: delimited file in the format "user lang num_expressions", with all entries
     for a single user listed together.
    -Output: delimited file with list of languages for each user, in the format:
     user lang1,num_expressions1 lang2,num_expressions1 lang3,num_expressions1 ...
    '''

    # open files and write headers
    fin = open(infile, 'rU')
    if inheader!=None: fin.readline() # skip header if exists
    fout = open(outfile, 'w')
    if outheader!=None: fclean.write(outheader)

    prev_user = None
    user_langs = Counter()

    for i, line in enumerate(fin):
        if i % 10000000 == 0:
            print ">>> line", i        

        vals = line[:-1].split(in_delim)
        user, lang = vals[0], vals[1]

        if len(vals) == 2:
            # If number of expressions isn't provided, assume it's 1
            num_expressions = 1

        # If this is a new user, write data for previous user to file.
        # user_langs is empty on first iteration and when none of prev_user's
        # languages met the thresholds; in either case there's nothing to write.
        if user != prev_user and user_langs:
            ### Beginning of part to copy below ###
            lang_list = DEFAULT_USERLANG_DELIM.join([\
                DEFAULT_LANGEXPS_DELIM.join([lang_name, str(lang_exps)]) \
                for lang_name, lang_exps in user_langs.iteritems() ])
            fout.write("%s%s%s\n" % (prev_user, DEFAULT_USERLANG_DELIM, \
                lang_list))

            # init list for new user
            user_langs.clear()
            ### End of part to copy below ###

        # Read data for current user into memory
        user_langs[lang] += num_expressions

        prev_user = user # move on to the next line!

    # write last user's lines

    ### Copied from above: using inline code is faster than calling a function ###
    if user_langs:
        lang_list = DEFAULT_USERLANG_DELIM.join([ \
            DEFAULT_LANGEXPS_DELIM.join([lang_name, str(lang_exps)]) \
            for lang_name, lang_exps in user_langs.iteritems() ])
        fout.write( "%s%s%s\n" % (prev_user, DEFAULT_USERLANG_DELIM, lang_list) )

        # init list for new user
        user_langs.clear()
    ### End copied from above ###

    print ">>> Done!"

    fout.close()
    return

'''
    consider a buffered approach: also answer #2 on
    http://stackoverflow.com/questions/6335839/python-how-to-read-n-number-of-lines-at-a-time

    import time
    from itertools import islice
    N = 100000

    def test_slice(filename):
        st_time = time.time()
        with open(filename) as myfile:
            head = list(islice(myfile,N))
            #print head
        print time.time()-st_time
        return head

    def test_list_comp(filename):
        st_time = time.time()
        with open(filename) as myfile:
            head=[myfile.next() for x in xrange(N)]
            #print head
        print time.time()-st_time
        return head
'''


if __name__ == "__main__":
    if len(sys.argv)!=2:
        print "usage: python prep_userlang.py infile"
        exit()

    infile = sys.argv[1]
    cleanfile = common_utils.append_to_filename(infile, 'userlang')

    new_cluster_user_languages(infile, cleanfile)

    # clean_timer = timeit.Timer('new_cluster_user_languages(infile, cleanfile)', \
    #     'from __main__ import cluster_user_languages; infile=%r; cleanfile=%r'
    #     % (infile, cleanfile) )
    # print clean_timer.timeit(1)/1
    print ">>> Created file:", cleanfile
