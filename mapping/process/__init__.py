"""
Module used in automated analysis pipeline that handles the processing of the
network, including filtering, extraction, and merging.
"""
import logging
import pickle
# import correlation
from vespignani import extract_vespignani
from common_utils import tree
from collections import defaultdict
from common_utils import *
from settings import SETTINGS
from pprint import pprint


def simple_write_langlang_network_to_file(network, outfile, statsfile=None, langlang_delim='\t'):
    """
    Preliminary method for writing network to file without the information needed
    in the following method. Default tab delimited.
    """
    # Init writer and write header -- edge table
    fout = open(outfile, 'w')
    fout.write(langlang_delim.join(['source','target', 'exposure']) +'\n')

    nodes = set()
    edges = set()

    # Write list to file
    for pair, num_of_common_users in network.iteritems():
        source, target = pair
        nodes.add(source)
        nodes.add(target)
        edges.add(pair)
        fout.write(langlang_delim.join([source, target, \
                                        str(num_of_common_users)]) + '\n')

    if statsfile:
        fstats = open(statsfile, 'w')
        fstats.write('Number of nodes:' + str(len(nodes)) + '\n')
        fstats.write('Number of edges:' + str(len(edges)))
        fstats.close()
    fout.close()


def merge(langinfos, networks, args, paths, merge_by='edge'):
    '''
    Merge the network from the different sources into a single network using
    the given criteria. TODO: explain these criteria here.
    The weight of edge is the average of weights from the different sources.

    Currently merges on edge count, which preserves more nodes
    '''

    # How many networks a node or edge must be in in order to merge
    in_common = SETTINGS['merging']['in_common']

    print "\n\tMerging with %s networks with threshold of %s" % \
        (len(networks), in_common)

    merged_network = defaultdict(float)
    final_merged_network = defaultdict(float)
    occurences = defaultdict(int)

    i_nodes = set([])
    i_edge_count = 0
    o_nodes = set([])
    o_edge_count = 0

    for dataset, network in networks.iteritems():
        norm_network = normalize(langinfos[dataset], network, dataset, args, paths)
        for pair, weight in norm_network.iteritems():
            i_nodes.add(pair[0])
            i_nodes.add(pair[1])
            merged_network[pair] += weight
            occurences[pair] += 1
            i_edge_count +=1

    for pair, count in occurences.iteritems():
        if count >= in_common:
            #if merged_network[pair]==0: # no need to add non-connected nodes
            #    print pair, weight
            #    continue
            o_nodes.add(pair[0])
            o_nodes.add(pair[1])
            final_merged_network[pair] = merged_network[pair] / len(networks) # float(count) # avg. weight
            o_edge_count += 1

    print "\t\tInput nodes: ", len(i_nodes)
    print "\t\tInput edges: ", i_edge_count
    print "\t\tOutput nodes: ", len(o_nodes)
    print "\t\tOutput edges: ", o_edge_count

    return final_merged_network


def extract_probability(network, dataset, args, langinfos, paths):
    """
    Function used to extract backbone of network using a probability cutoff as well as a weight cutoff.

    In this sense, this is more of a filtering than an extraction, but fits into the pipeline as an alternative
    to vespignani or correlation extraction)
    """

    # Network with edge weights that are used in the filtering criteria
    # (merging first is different from extracting first for probability extraction)
    comparison_network = network

    if not SETTINGS['general']['merge_first']:
        comparison_network = normalize(langinfos[dataset], network, dataset, args, paths)

    probability_cutoff = SETTINGS['extraction']['probability_cutoff']

    weight_cutoff = SETTINGS['extraction']['weight_cutoff']
    if not weight_cutoff:
        weight_cutoff = SETTINGS['weight_cutoffs'][dataset]
    print "WEIGHT CUTOFF", weight_cutoff, dataset

    print "\t%s network probability Extraction with a probability cutoff =" % dataset.capitalize(), probability_cutoff #, \
    # "and weight cutoff = ", weight_cutoff

    # Counters
    i_edge_count = 0
    o_edge_count = 0

    # Data structures to hold relevant values
    input_nodes = set([])
    kept_nodes = set([])
    kept_edges = []
    extracted_network = tree()

    # Iterate through network, apply filter, and populate extracted network
    for (lang1, lang2), weight in comparison_network.iteritems():
        i_edge_count += 1
        input_nodes.add(lang1)
        input_nodes.add(lang2)
        unnorm_weight = network[(lang1, lang2)]

        if weight > probability_cutoff and unnorm_weight > weight_cutoff:
            kept_nodes.add(lang1)
            kept_nodes.add(lang2)
            kept_edges.append((lang1, lang2))
            extracted_network[(lang1, lang2)] = unnorm_weight
            o_edge_count += 1

    i_node_count = len(input_nodes)
    o_node_count = len(kept_nodes)

    print "\t\tInput nodes: ", i_node_count
    print "\t\tInput edges: ", i_edge_count
    print "\t\tOutput nodes: ", o_node_count
    print "\t\tOutput edges: ", o_edge_count

    return extracted_network


def normalize_old(langinfo, network, args):
	# Find way to pass total number of speakers per language to here
	# Pass lang info file here <-- dict
	# TODO: NORMALIZE BASED ON TOTAL WEIGHT OF ENTIRE NETWORK
    """Normalize edge weights based on summed weight of entire network.

    Algorithm:
        total_summed_weight = sum(every edge)
        normalize_weight = raw_weight / (total_summed_weight)
    """
    total_summed_weight = 0
    normalized_network = defaultdict(float)
    for pair, weight in network.iteritems():
        total_summed_weight += weight

    for pair, weight in network.iteritems():
        normalized_network[pair] = float(weight / total_summed_weight)
        assert normalized_network[pair] < 1

    return normalized_network


def normalize(langinfo, network, dataset, args, paths):
    """Normalize edge weights by probability, making them directed.
       Thus, the weight of edge (SRC, TGT) is the probability that a speaker of
       language TGT would also speak SRC, or a book in language SRC will be translated
       to language TGT: weight(A,B) = p(A|B) and weight(B,A) = p(B|A).
       We claim this indicates influence of language TGT on language SRC.
       Probability is taken from the population according to each source, not
       real world popultion.

    Algorithm:
        raw_weight = num of items (users, translations) connecting A and B
        normalized_weight(A,B) = raw_weight / (total_items_B)
        normalized_weight(B,A) = raw_weight / (total_items_A)
    """
    print "process.__init__.normalize", dataset

    total_summed_weight = 0
    normalized_network = defaultdict(float)
    for (lang1, lang2), weight in network.iteritems():
        total_summed_weight += weight

    for (lang1, lang2), weight in network.iteritems():
        if dataset in ['wikipedia', 'twitter']:
            # In this case, langinfo is a simple dictionary whose values are
            # number of expressions. # TODO: a more elegant way to pass this?
            lang1_total = langinfo[lang1]
            lang2_total = langinfo[lang2]

            norm_weight_one = weight / float(lang2_total)
            norm_weight_two = weight / float(lang1_total)
            # zero probablility indicates error as all pairs in network
            # should have common speakers and thus prob > 0

            assert 0 < norm_weight_one <= 1 and 0 < norm_weight_two <= 1

            normalized_network[(lang1, lang2)] = norm_weight_one
            # print lang1, lang1_total, lang2, lang2_total, weight, normalized_network[(lang1, lang2)] # Debug

            # make the network directed by reversing the tuple
            normalized_network[(lang2, lang1)] = norm_weight_two
            # print lang2, lang2_total, lang1, lang1_total, weight, normalized_network[(lang2, lang1)] # Debug

        else:
            # 'books' is a directed network; lang_info holds info for each
            # direction separately and is a nested dictionary.
            # lang1_total = langinfo[lang1]['translated_from'] # TODO: is this the right way? test with "merge_first=FALSE"
            # lang2_total = langinfo[lang2]['translated_from']
            lang1_total = langinfo[lang1]
            lang2_total = langinfo[lang2]
            try:
                # print lang1, lang2, weight, lang2_total
                norm_weight = weight / float(lang2_total)
                assert 0 < norm_weight <= 1
            except Exception as e:
                print e
                break

            # zero probablility indicates error as all pairs in netwwork
            # should have common speakers and thus prob>0
            normalized_network[(lang1, lang2)] = norm_weight

            # print lang1, lang1_total, lang2, lang2_total, weight, normalized_network[(lang1, lang2)] # Debug

    norm_outfile = os.path.join(paths['normalized'], dataset + '_normalized_langlang.tsv')
    simple_write_langlang_network_to_file(normalized_network, norm_outfile)
    return normalized_network


def extract(network, dataset, args, langinfos, paths):
    '''
    @input network: a network represented by a dictionary with an edge
    (node pair) for a key, and a weight for a value.
    @input dataset: a string containing the dataset of the currently processed network
    @input cutoff: significance cut-off

    @output extracted_network: the final, extracted network
    '''

    if SETTINGS['extraction']['extraction'] == 'correlation':
        print 'Correlation Extraction'
        return extract_correlation(network, dataset, args)
    elif SETTINGS['extraction']['extraction'] == 'vespignani':
        print 'Vespignani Extraction'
        return extract_vespignani(network, dataset, args)
    elif SETTINGS['extraction']['extraction'] == 'probability':
        print 'Probability Extraction'
        return extract_probability(network, dataset, args, langinfos, paths)
    else: # equiv. to SETTINGS['extraction']['extraction'] == 'None'
        # Do nothing
        return network


def post_filter(network, args):
    in_degree_cutoff = SETTINGS['post-filtering']['in_degree_cutoff']
    out_degree_cutoff = SETTINGS['post-filtering']['out_degree_cutoff']
    weight_cutoff = SETTINGS['post-filtering']['weight_cutoff']

    if in_degree_cutoff or out_degree_cutoff or weight_cutoff:
        print "\tPost-processing network"
        i_nodes = set([])
        o_nodes = set([])
        i_edge_count = 0
        o_edge_count = 0
        in_degree_counter = defaultdict(int)
        out_degree_counter = defaultdict(int)

        for lang_pair, weight in network.iteritems():
            lang1, lang2 = lang_pair
            out_degree_counter[lang1] += 1
            in_degree_counter[lang2] += 1
            i_edge_count += 1
            i_nodes.add(lang1)
            i_nodes.add(lang2)

        final_network = tree()
        for lang_pair, weight in network.iteritems():
            lang1, lang2 = lang_pair
            if out_degree_counter[lang1] > out_degree_cutoff and \
               in_degree_counter[lang2] > in_degree_cutoff and \
               weight > weight_cutoff:
                final_network[lang_pair] = weight
                o_nodes.add(lang1)
                o_ndoes.add(lang2)
                o_edge_count += 1

                print "\t\tInput nodes: ", len(i_nodes)
        print "\t\tInput edges: ", i_edge_count
        print "\t\tOutput nodes: ", len(o_nodes)
        print "\t\tOutput edges: ", o_edge_count
        return final_network

    print "\n\tNo post-processing"
    return network


def process(langinfos, networks, args, paths):
    print "\nPROCESSING\n"
    if SETTINGS['general']['merge_first']:
        print "\tMerging first\n"
        int_network = merge(langinfos, networks, args, paths)
        merged_file = os.path.join(paths['merged'], 'merged_langlang.tsv')
        simple_write_langlang_network_to_file(int_network, merged_file, statsfile=paths['stats'])
        merged_extracted_network = extract(int_network, 'all', args, paths)
    else:
        print "\tExtracting first\n"
        int_networks = {}
        for dataset, network in networks.iteritems():
            int_network = extract(network, dataset, args, langinfos, paths)
            extracted_file = os.path.join(paths['extracted'],
                             '{}_extracted_langlang.tsv'.format(dataset))
            simple_write_langlang_network_to_file(int_network, extracted_file, statsfile=paths['stats'])
            int_networks.update({dataset: int_network})
        merged_extracted_network = merge(langinfos, int_networks, args, paths) # TODO: using original langinfos (not post-extraction) to extract probability weights. Consider if post-extraction values should used instead, and if so--calculate them in extract()

    merged_extracted_network_file = os.path.join(paths['processed'], 'processed_langlang.tsv')
    simple_write_langlang_network_to_file(merged_extracted_network, merged_extracted_network_file, statsfile=paths['stats'])


    final_network_file = os.path.join(paths['final'], 'final_langlang.tsv')
    final_network = post_filter(merged_extracted_network, args)
    simple_write_langlang_network_to_file(final_network, final_network_file, paths['stats'])

    return final_network
