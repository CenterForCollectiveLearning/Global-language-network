## <root>/correlation.py

import csv
import sys
import datetime
import os
from collections import defaultdict
from collections import Counter
import itertools
import time 

LGN_HOME = '/Users/shahar/LangsDev/net-langs/'  # TODO: replace with env. var?
sys.path.append(LGN_HOME)  # fix this path to work for you!!!!
from common_utils import *
from langtable import LANG_CONNECTIONS_HEADER

'''
Module get lang_connections table as info and calculates the correlation
for each language pair
'''

def extract_correlation(network, cutoff):
    num_users = defaultdict(float)
    for lang_pair, weight in network.iteritems():
        lang1, lang2 = lang_pair
        

def language_group_correlation(lang1, lang2, common, total):
    '''
    NOTE: Currently not used - we analyze significance using R.
    lang1, lang2: expressions for each language;
    common: expressions common to both languges
    total: total expressions in source
    '''

    # calculate values for phi-correlation:
    a = total - (lang1 + lang2 - common) # population in neither
    b = lang1 - common # pop. speaking lang1 only
    c = lang2 - common # pop. speaking lang2 only
    d = common # pop. speaking both

    phico = phicoeff(a, b, c, d)

    return phico


def phicoeff(a, b, c, d):
    """
    author  Dr. Ernesto P. Adorio
    """

    """
    a, b, c, d are frequency counts for the various paired levels of dichotomous variables.
        |     X
     Y  |  0     1
    ---------------
     0  |  a     b
     1  |  c     d
    """

    #print a, b, c, d
    phi = (a * d - b * c) / math.sqrt((a + b) * (c + d) * (a + c) * (b + d))
    #print phi
    return phi
    

if __name__ == "__main__":
    infile = sys.argv[1]
    outfile = append_to_filename(infile, 'correlation')

    # Init reader: use a delimiter
    fin = open(infile, 'rU')

    headerline = fin.readline() # skip LANG_CONNECTIONS_HEADER header

    # Init writer and write header
    fout = open(outfile, 'w')
    CORR_HEADER = ['Lang1', 'Lang2', 'L1', 'L2', 'L', '!L1_AND_!L2', 'L1_AND_!L2', '!L1_AND_L2', 'L1_AND_L2', 'Correlation']
    fout.write(' '.join(CORR_HEADER) + '\n')

    for lang in fin:
        lang1, lang2, num_users_biling, num_users_lang1, num_users_lang2, \
            num_polys_lang1, num_polys_lang2, \
            total_users, total_polys = lang[:-1].split(' ')
        num_users_biling = int(num_users_biling)
        total_users = int(total_users)
        num_users_lang1 = int(num_users_lang1)
        num_users_lang2 = int(num_users_lang2)

        # calculate values for phi-correlation:
        a = total_users - (num_users_lang1 + num_users_lang2 - num_users_biling)
        b = num_users_lang1 - num_users_biling
        c = num_users_lang2 - num_users_biling
        d = num_users_biling

        phico = phicoeff(a, b, c, d)
        
        fout.write(' '.join([lang1, lang2, str(num_users_lang1), str(num_users_lang2), str(total_polys), str(a), str(b), str(c), str(d), str(phico)]) + '\n')

    fout.close()
