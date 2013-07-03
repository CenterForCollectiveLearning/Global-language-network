"""
Module used in automated analysis pipeline for importing and
preprocessing networks. This includes language name harmonization,
language removal, and language merging.
"""
import os
import sys
import imp
import time
import shutil
import pickle
import logging
import tempfile
import argparse
import datetime
from distutils import dir_util
from collections import Counter

import usertable
import langtable

from common_utils import *
from settings import SETTINGS, LANG_SETTINGS

LOG = logging.getLogger(__name__)


def check_previously_loaded(paths):
    """Check if an analysis has been run with the same settings. If so, just
    copy the loaded userlang and langlang files over from that run."""

    current_pre_filter_settings = SETTINGS['pre-filtering']
    current_lang_settings = LANG_SETTINGS

    lgn_results = os.path.join(paths['lgn'])

    print "\tChecking previously loaded datasets"

    for result_dir in os.listdir(lgn_results):
        result_dir = os.path.join(lgn_results, result_dir)
        if os.path.isdir(result_dir) and not \
                (result_dir.startswith('.') or \
                result_dir.endswith('-incomplete') or
                 result_dir == paths['results']):
            try:
                prev_loaded = os.listdir(os.path.join(result_dir, 'all', 'preprocessed'))
                if '.DS_Store' in prev_loaded: prev_loaded.remove('.DS_Store')
                if len(prev_loaded) == 10:  # Check that there are eight files
                    init_file = os.path.join(result_dir, '__init__.py')
                    open(init_file, 'w')
                    settings_module = imp.load_source('settings',
                        os.path.join(result_dir, 'settings.py'))

                    if current_pre_filter_settings == settings_module.SETTINGS['pre-filtering'] and \
                       current_lang_settings == settings_module.LANG_SETTINGS:

                        # Copy all files over
                        print "\tSame loading and processings settings as the analysis in directory", result_dir
                        print "\t\tCopying over userlang and langlang tables and serialized networks."
                        dir_util.copy_tree(
                            os.path.join(result_dir, 'all', 'preprocessed'),
                            os.path.join(paths['all'], 'preprocessed')
                            )
                        os.remove(init_file)
                        return True
                        break
            except OSError:
                continue
    return False


def load(args, paths):
    start_time = time.time()
    today = get_current_date_formatted()  # Make this a common_util
    populations = {} # store node inforamtion
    networks = {} # store network / edge information
    print '\nLOADING NETWORKS\n'

    # Convenience remappings
    spf = SETTINGS['pre-filtering']
    sd = SETTINGS['delimiters']
    datasets = SETTINGS['general']['datasets_to_use']

    # Check in advance that paths exist. #TODO: standard logger / exception?
    for dataset in datasets:
        if not os.path.isfile(paths[dataset]):
            print "ERROR: {} dataset not found, terminating.\n Please check the following path, fix, and re-run:\n {}\n".format(dataset, paths[dataset])
            exit()

    # Copy over userlang files if relevant settings are the same as those in a past analysis
    if not check_previously_loaded(paths):
        print "\t\tDatasets haven't been loaded before"
        for dataset in datasets:
            if dataset in SETTINGS['general']['datasets_to_use']:
                print "\t\n{}".format(dataset.upper())
                infile = paths[dataset]
                langlangfile = os.path.join(paths['preprocessed'],
                                    '{}_langlang.tsv'.format(dataset))
                langinfofile = os.path.join(paths['preprocessed'],
                                    '{}_langinfo.tsv'.format(dataset))
                filteredfile = os.path.join(paths['preprocessed'],
                                    '{}_userlang_filtered.txt'.format(dataset))

                if dataset == 'wikipedia' or dataset == 'twitter':
                    min_per_language = spf[dataset + '_min_degree']
                    min_per_user = spf[dataset + '_min_per_user']
                    max_langs_per_user = spf[dataset + '_max_langs_per_user']

                    # Filter the user-lang table and write it to a file
                    usertable.filter_userlang_network(infile, filteredfile, paths,
                                              major_delim=sd['userlang_major_delim'][dataset],
                                              minor_delim=sd['userlang_minor_delim'][dataset],
                                              langs_to_merge=LANG_SETTINGS['LANGS_TO_MERGE'][dataset],
                                              langs_to_remove=LANG_SETTINGS['LANGS_TO_REMOVE'][dataset],
                                              min_per_language=min_per_language,
                                              min_per_user=min_per_user,
                                              max_langs_per_user=max_langs_per_user)

                    # Generate the lang-lang network files and the population files:
                    # popluation by language for each dataset
                    population, network = langtable.generate_network_files_from_userlang(
                        filteredfile, langlangfile, langinfofile, paths,
                        major_delim=sd['userlang_major_delim'][dataset],
                        minor_delim=sd['userlang_minor_delim'][dataset],
                        langlang_delim=sd['langlang_delim'][dataset])

                    populations.update({dataset: population})
                    networks.update({dataset: network})

                # The book network has no 'users', so only generate langtables
                if dataset == 'books':
                    # Input file is a directed edgelist, so process is different
                    population, network = langtable.generate_network_files_from_edgelist(
                        infile, langlangfile, langinfofile, paths,
                        langlang_delim=sd['langlang_delim'][dataset],
                        langs_to_merge=LANG_SETTINGS['LANGS_TO_MERGE'][dataset],
                        langs_to_remove=LANG_SETTINGS['LANGS_TO_REMOVE'][dataset],
                        directed=True)  # TODO: Make this work

                    populations.update({dataset: population})
                    networks.update({dataset: network})

        pickle.dump(populations, open(paths['populations_pkl'], 'w'))
        pickle.dump(networks, open(paths['networks_pkl'], 'w'))

    else:
        print "\t\tDatasets have been loaded previously"
        print "\t\tLloading langlang and langinfo files from serialized versions"

        populations = pickle.load(open(paths['populations_pkl']))
        networks = pickle.load(open(paths['networks_pkl']))

    print "\n\tDone loading networks"
    print "\t\tLoad time: ", time.time() - start_time, " seconds"
    return populations, networks
