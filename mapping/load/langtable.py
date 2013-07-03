# analysis/load/langtable.py

'''
This module receives a delimited text file containing for each userid and
language the number of expressions identified, and creates two tables saved in
two separate files (See LANG_CONNECTIONS_HEADER and LANG_INFO_HEADER)

Notes:
- "Users" can be Twitter users, Wikipedia editors, etc.
- "Expressions" can be tweets, Wikipedia edits, etc.
- Data are assumed to be clean and only contain information of expressions whose
 language is known.
- The node table holds, for each identified language, the number of expressions
  found in this language.
- The edge table holds, for each pair of languages, the number of unique users
  who express themselves in both languages (if more than 0).
'''

import os
import sys
import csv
import time
import itertools
import common_utils
from collections import defaultdict, Counter

try:
    from settings import LANG_SETTINGS
except ImportError:
    # If running from command line
    LGN_HOME = os.path.abspath(os.path.relpath(os.path.join(__file__, '../../../')))
    ANALYSIS_HOME = os.path.join(LGN_HOME, 'analysis')
    sys.path.append(ANALYSIS_HOME)
    from settings import LANG_SETTINGS


def read_userlang_network_from_file(infile, major_delim, minor_delim):
    '''
    Load data from infile into data structures in memory.
    NOTE: could be a very intensive on RAM: 1.5GB for the cleaned Feb
    22, 2012 dataset (~889m tweets, ~15m users, 76 langs)
    '''

    # Init reader: use a delimiter
    fin = open(infile, 'rU')
    # headerline = fin.readline() # skip header if exists

    userlang_network = defaultdict(set)
    express_per_lang = Counter()
    users_per_lang = Counter()
    # Expressions in a given language by users who express themselves in
    # at least one more language
    express_per_lang_by_polys = Counter()
    polys_per_lang = Counter()

    num_users = 0
    num_polys = 0  # No. of users who express themselves in more than one language

    for i, row in enumerate(fin):
        if i % 500000 == 0:
            print "\t\tLoading languser file into memory, line", i
        splt = row[:-1].split(major_delim)  # remove EOL and split

        user = splt[0]  # user is the first value
        langs_list = splt[1:]  # now a list of lang,#_of_expressions pairs

        # Stats for polyglot users
        is_poly = True if len(langs_list) > 1 else False
        if is_poly:
            num_polys += 1

        # Get info for each user
        for lang_info in langs_list:
            # Split the pairs
            lang, num_express = lang_info.split(minor_delim)

            # Update numbers for all users by language
            # Note that sum(users_per_lang.values()) > num_users !
            express_per_lang[lang] += int(num_express)
            users_per_lang[lang] += 1

            # Update numbers for polyglots by language
            if is_poly == True:
                express_per_lang_by_polys[lang] += int(num_express)
                polys_per_lang[lang] += 1
                # Users connect languages only if they express themselves
                # (tweet, edit Wiki, etc.) in at least two languages.
                # By adding only relevant entries I reduce memory consumption.
                userlang_network[user].add(lang)
        num_users = i + 1  # we started from 0
    fin.close()

    return num_users, express_per_lang, users_per_lang, \
        num_polys, express_per_lang_by_polys, polys_per_lang, \
        userlang_network


def create_langlang_network(userlang_network):
    '''
    Create a language-language network from a user-language network, by connecting
    languages through multilingihal users who use them.
    -Input: a delimited table, w/o header, in the format:
     userid lang1,num1 lang2,num2 lang3,num3...
    -Return: a language-language network and a set of connected languages
    '''
    # For each pair of languages, hold the no. of users who express themselves
    # in both (if >0)
    lang_connections = Counter()

    # Statistics: No. of langs that have multilingual users
    connected_langs = set()

    # Now find the languages connected by the different users,
    # in the list of users speaking more than one language
    for i, (user, langs) in enumerate(userlang_network.iteritems()):
        #langs = userlang_network[user]

        # mark languages as connected languages
        connected_langs.update(langs)

        # get all combinations of two languages for given user. Languages in
        # each pair are alphabetically sorted so they all have the same order.
        lang_sorted = sorted(list(langs))
        lang_combin = list(itertools.combinations(lang_sorted, 2))

        # Increment the counter for pair of languages used by the same user
        for lang_pair in lang_combin:
            lang_connections[lang_pair] += 1
        if i % 1000000 == 0:
            print "\t\tCreating lang connections, line", i

    return lang_connections, connected_langs


def simple_write_langlang_network_to_file(network, outfile, langlang_delim='\t'):
    """
    Preliminary method for writing network to file without the information needed
    in the following method. Default tab delimited.
    """
    # Init writer and write header -- edge table
    fout = open(outfile, 'w')
    fout.write('source\ttarget\texposure\n')

    # Write list to file
    for pair, num_of_common_users in lang_connections.iteritems():
        fout.write(langlang_delim.join([pair[0], pair[1], \
                                        str(num_of_common_users)]))
    fout.close()


def write_langlang_network_to_file(lang_connections, users_per_lang, \
    polys_per_lang, num_users, num_polys, outfile, langlang_delim):
    '''
    Create and a table with the columns set in
    LANG_CONNECTIONS_HEADER for each connected languge pair. Some of the values
    are identifical for all rows and are meant to facilitate calculations.
    '''

    # Init writer and write header -- edge table
    fout = open(outfile, 'w')
    fout.write(langlang_delim.join(LANG_SETTINGS['LANG_CONNECTIONS_HEADER']) + '\n')

    # Write list to file
    for pair, num_of_common_users in lang_connections.iteritems():
        fout.write(langlang_delim.join([pair[0], pair[1], \
            str(num_of_common_users),
            str(users_per_lang[pair[0]]), str(users_per_lang[pair[1]]),
            str(polys_per_lang[pair[0]]), str(polys_per_lang[pair[1]]),
            str(num_users), str(num_polys)]) + '\n')

    fout.close()


def create_language_info_table(num_users, express_per_lang, users_per_lang, \
    num_polys, express_per_lang_by_polys, polys_per_lang, langs_by_user, \
    outfile, langlang_delim):
    '''
    In: usertable file, containing for each user names of languages she uses
        and number of expressions per language.
    Out: table with info described in LANG_INFO_HEADER
    Return: the language info table, # of languages, total # of expressions
    '''

    # Init writer and write header --
    fout = open(outfile, 'w')
    fout.write(langlang_delim.join(LANG_SETTINGS['LANG_INFO_HEADER']) + '\n')

    # calculate probability distribution
    total_express = sum(express_per_lang.values())
    #langs_dist = {}
    #for lang_name, lang_express in langs.iteritems():
    #   langs_dist[lang_name] = lang_express / total_express

    for lang in express_per_lang:
        avg_express_by_user_per_lang = \
            express_per_lang[lang] / float(users_per_lang[lang])
        try:
            avg_express_by_poly_per_lang = \
                express_per_lang_by_polys[lang] / float(polys_per_lang[lang])
        except ZeroDivisionError:
            avg_express_by_poly_per_lang = 0

        fout.write(langlang_delim.join([lang,
            str(express_per_lang[lang]), str(users_per_lang[lang]), \
            str(avg_express_by_user_per_lang), \
            str(express_per_lang_by_polys[lang]), str(polys_per_lang[lang]), \
            str(avg_express_by_poly_per_lang), \
            str(num_users), str(num_polys)]) + '\n')

    # TODO: return a proper lang_info nested dictionary instead of user_per_lang,
    # holding number of expressions and polys for each language
    return users_per_lang, len(express_per_lang), sum(express_per_lang.values())


def create_language_degree_file(lang_connections, degreefile, langlang_delim):
    '''
    Use the language connections table to find the degree (=number of connected
    languages) of each language.
    Input: language connections table from memory
           (output of create_language_connections_table())
    Output: delimited file with degree for each language
    '''

    # Init writer and write header
    fout = open(degreefile, 'w')
    fout.write(langlang_delim.join(LANG_SETTINGS['LANG_DEGREE_HEADER']) + '\n')

    degree = Counter()

    for lang_pair in lang_connections.keys():
        # Graph is undirected, so each language pair appears only once.
        # 'Lang1' is always the language whose name comes first in a
        # lexigraphic order
        degree[lang_pair[0]] += 1
        degree[lang_pair[1]] += 1

    for node, deg in degree.iteritems():
        fout.write(node + langlang_delim + str(deg) + '\n')

    fout.close()

    return degree


def generate_network_files_from_userlang(userlangfile, langlangfile, langinfofile,
    paths, major_delim, minor_delim, langlang_delim):
    '''
    Calls all the above functions: given a user-language file, generates a
    language-language network file and a population file.
    '''

    # load user-language network into memory
    userlang_network_read_start = time.time()
    num_users, express_per_lang, users_per_lang, \
        num_polys, express_per_lang_by_polys, polys_per_lang, userlang_network = \
        read_userlang_network_from_file(userlangfile, major_delim, minor_delim)
    print "\t\tTime to load user-lang network info memory:", \
        time.time() - userlang_network_read_start, "seconds"

    # create language-language network table
    langlang_network_start = time.time()
    langlang_network, connected_langs = \
        create_langlang_network(userlang_network)

    # write the language-language network to file
    write_langlang_network_to_file(langlang_network, users_per_lang, \
        polys_per_lang, num_users, num_polys, langlangfile, langlang_delim)

    print "\t\tCreated file: %s" % langlangfile
    print "\t\tTime to create lang-lang network: %f seconds" % \
        (time.time() - langlang_network_start)

    # create language info table (=node table of the langlang network)
    langinfo_start = time.time()
    langinfo_table, num_langs, num_express = \
        create_language_info_table(num_users, express_per_lang, \
        users_per_lang, num_polys, express_per_lang_by_polys, polys_per_lang, \
        userlang_network, langinfofile, langlang_delim)

    # print "\t\tCreated file: %s" % langinfofile
    print "\t\tTime to calc language info table: %f\n" % \
        (time.time() - langinfo_start)

    print"\t\t# languages: %d\t# connected: %d" % (num_langs, len(connected_langs))
    print "\t\t# persons: %d\t# polyglots: %d" % (num_users, num_polys)
    print "\t\t# expressions: %d\n" % (num_express)

    return langinfo_table, langlang_network


def generate_network_files_from_edgelist(edgelist, langlangfile, langinfofile, paths,
    langlang_delim=None, langs_to_merge=None, langs_to_remove=None, directed=False):
    """
    Given a directed edge list (lang1, lang2, weight), generates a directed or
    undirected lanugage-language network file and info file.
    """

    dir_or_undir = directed and '_dir' or '_undir'

    node_info = defaultdict(Counter)
    edge_tree = defaultdict(int)
    node_population = defaultdict(int)

    edgelist = open(edgelist, 'rU')
    network_file = open(langlangfile[:-4] + dir_or_undir + langlangfile[-4:], 'w')
    info_file = open(langinfofile[:-4] + dir_or_undir + langinfofile[-4:], 'w')

    # print "\t\tCreated file: %s" % (langlangfile[:-4] + dir_or_undir + langlangfile[-4:])
    # print "\t\tCreated file: %s" % (langinfofile[:-4] + dir_or_undir + langinfofile[-4:])

    edgelist_read_start = time.time()
    edgelist.readline()

    for line in edgelist:
        lang1, lang2, weight = line.split(langlang_delim)
        lang1, lang2 = LANG_SETTINGS['LANGS_TO_MERGE'].get(lang1, lang1), \
                       LANG_SETTINGS['LANGS_TO_MERGE'].get(lang2, lang2)
        if (lang1 not in LANG_SETTINGS['LANGS_TO_REMOVE']) and \
           (lang2 not in LANG_SETTINGS['LANGS_TO_REMOVE']):
            tup1 = lang1, lang2
            tup2 = lang2, lang1
            weight = int(weight.strip())

            # Update number of works for source and target languages
            node_info[lang1]['translated_from'] += weight
            node_info[lang2]['translated_to'] += weight

            # Number of works is the weight of the link between the languages
            if not directed:
                if tup2 in edge_tree:
                    edge_tree[tup2] += weight
                else:
                    edge_tree[tup1] += weight
            elif directed: # TODO: changed from "elif not directed", need to verify
                edge_tree[tup1] += weight

            node_info[lang1]['out_degree'] += 1
            node_info[lang2]['in_degree'] += 1

    print "\t\tTime to load user-lang network info memory:", \
        time.time() - edgelist_read_start, "seconds"

    # Write the lang_info file
    info_file.write(langlang_delim.join(LANG_SETTINGS['BOOKS_INFO_HEADER']) + '\n')
    langinfo_write_time = time.time()
    for lang, lang_info in node_info.iteritems():
        info_file.write(lang + langlang_delim + \
            str(lang_info['translated_from']) + langlang_delim + \
            str(lang_info['translated_to']) + langlang_delim + \
            str(lang_info['out_degree']) + langlang_delim + \
            str(lang_info['in_degree']) + '\n')
    print "\t\tTime to write lang_info file: ", \
        time.time() - langinfo_write_time, "seconds"

    # Write the lang_lang file: 
    # add # of total translations FROM source language,
    # and # of total translations TO target language, 
    # to be used for analysis, e.g., phi-correlation
    network_file.write(langlang_delim.join(LANG_SETTINGS['BOOKS_LANG_CONNECTIONS_HEADER']) + '\n')
    langlang_write_time = time.time()
    for lang_pair, weight in edge_tree.iteritems():
        network_file.write( langlang_delim.join( [lang_pair[0] ,lang_pair[1], \
            str(node_info[lang_pair[0]]['translated_from']), \
            str(node_info[lang_pair[1]]['translated_to']), \
            str(weight)]) + '\n' )

    print "\t\tTime to write lang_lang file: ", \
        time.time() - langlang_write_time, "seconds"

    info_file.close()
    network_file.close()

    # TODO: enables probability weight calculation, need to find
    # a nicer solution
    for lang, lang_info in node_info.iteritems():
        node_population[lang] = lang_info['translated_to'] # changed from translated_from to measure influence

    return node_population, edge_tree


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print "\nusage: python langtable.py userlang_network_file\n"
        exit()

    userlangfile = sys.argv[1]
    langlangfile = common_utils.append_to_filename(userlangfile, 'langlang')
    langinfofile = common_utils.append_to_filename(userlangfile, 'langinfo')

    generate_network_files_from_userlang(userlangfile, 
                                         langlangfile, 
                                         langinfofile,
                                         paths=None, # paths is not really used
                                         major_delim='\t', 
                                         minor_delim=',', 
                                         langlang_delim='\t')
