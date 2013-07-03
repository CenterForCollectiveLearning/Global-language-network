"""
Module used to extract the multiscale backbone of complex weighted undirected networks
using a disparity filter as described in Serrano, Boguna, Vespignani (2008)

To run in terminal, enter 'python vespignani_backbone.py {inputnodelist} {inputedgelist}'

Input: nodelist, edgelist, weight
Outputs: pipe-delimited backbone network of form (node1, node2, edge weight)

TODO: Account for directed networks?
"""

import math
import sys
from scipy import integrate
from collections import defaultdict
from common_utils import tree
from settings import SETTINGS
import pprint

MIN_CONNECTIONS = 1  # Kevin used 10 originally
MIN_DEGREE = 1  # Kevin used 3 originally

def extract_vespignani(network, name, args):
    """
    TODO: make sure this supports directed networks

    Function used to extract multiscale backbone. Same procedure implemented in main() but with a
    network, rather than a nodelist and edgelist, as an input. Also, this function does not
    filter edges or nodes, as it is assumed that filtering is done elsewhere.

    @input network: a network represented by a dictionary with an edge
    (node pair) for a key, and a weight for a value.
    @input name: a string containing the name of the currently processed network
    @input cutoff: significance cut-off

    @output extracted_network: the final, extracted network
    @output kept_nodes: the nodes that were kept in the final network
    """

    print "\tMultiscale Backbone Extraction with alpha =", SETTINGS["extraction"]["vespignani_cutoff"]

    # Counters
    i_edge_count = 0
    o_edge_count = 0

    # Data structures to hold relevant values
    input_nodes = set([])
    input_degrees = defaultdict(int)
    input_strengths = defaultdict(float)

    # Iterate through network once to calculate degress and strengths
    for (lang1, lang2), num_connections in network.iteritems():
        print lang1, lang2, num_connections
        i_edge_count += 1
        input_nodes.add(lang1)
        input_nodes.add(lang2)
        input_degrees[lang1] += 1
        input_degrees[lang2] += 1
        input_strengths[lang1] += float(num_connections)
        input_strengths[lang2] += float(num_connections)

    # Normalize weights of edges based on node strengths
    normalized_edges = tree()
    for (lang1, lang2), num_connections in network.iteritems():
        # NOTE: original code used last lang1 value from previous loop instead
        # of value for the current lang1:
        #normalized_edges[lang_pair] = float(network[lang_pair]) / float(input_strengths[lang1])
        normalized_edges[(lang1, lang2)] = network[(lang1, lang2)] / float(input_strengths[lang1])

    cutoff = SETTINGS["extraction"]
    # Calculating significance of each edge and populating output network
    edge_probability = tree()
    kept_nodes = set([])
    kept_edges = []
    extracted_network = tree()
    for lang_pair, norm_weight in normalized_edges.iteritems():
        lang_pair_reversed = lang_pair[::-1]
        degree = input_degrees[lang1]
        # Following Vespignani's footnote regarding nodes of degree one-- they
        # are only preserved if the edge is significant to the sole neighbor
        if degree > 1:
            edge_prob = 1 - (degree - 1) * (integrate.quad(lambda x: math.pow((1 - x), (degree - 2)), 0, norm_weight))[0]
            if edge_prob < cutoff:
                if (lang_pair not in extracted_network) and (lang_pair_reversed not in extracted_network):
                    extracted_network[lang_pair] = network[lang_pair]  # Put back original weight
                    o_edge_count += 1
                    kept_nodes.add(lang_pair[0])
                    kept_nodes.add(lang_pair[1])

    i_node_count = len(input_nodes)
    o_node_count = len(kept_nodes)

    print "\t\tInput nodes: ", i_node_count
    print "\t\tInput edges: ", i_edge_count
    print "\t\tOutput nodes: ", o_node_count
    print "\t\tOutput edges: ", o_edge_count

    return extracted_network


if __name__ == "__main__":
    input_nodelist = open(sys.argv[1])
    input_edgelist = open(sys.argv[2])
    SIG_CUTOFF = float(raw_input("Significance cutoff? (e.g. 0.05 for 5%): "))
    output_file_name = 'backbone_network_{}.csv'.format(int(SIG_CUTOFF * 100))
    output_network = open(output_file_name, 'w')
    output_data = open(output_file_name, 'w')

    i_node_count = 0
    i_edge_count = 0
    o_edge_count = 0
    backbone_edge_count = 0

    print "Calculating Vespignani backbone with significance of " + str(SIG_CUTOFF)
    print "Output file: " + output_file_name

    # Populating tree with nodes and corresponding degrees
    input_degrees = tree()
    for line in input_nodelist:
        lang, degree = line.split('|')
        i_node_count += 1
        if int(degree) > MIN_DEGREE:
            input_degrees[lang] = degree

    # Input edges, calculate weights
    input_edges = tree()
    input_strengths = defaultdict(int)
    for line in input_edgelist:
        lang1, lang2, num_connections = line.split('|')
        i_edge_count += 1
        if (lang1 in input_degrees) and (lang2 in input_degrees) and (int(num_connections) > MIN_CONNECTIONS):
            i_edge_count += 1
            input_edges[lang1][lang2] = num_connections
            input_strengths[lang1] += int(num_connections)
            input_strengths[lang2] += int(num_connections)
            #print "Edge: " + lang1 + ',' + lang2 + "  Weight: " + num_connections
            i_edge_count += 1

    # Normalize weights of edges based on node strengths
    normalized_edges = tree()
    for lang1, lang2_num in input_edges.iteritems():
        for lang2 in lang2_num.iterkeys():
            normalized_edges[lang1][lang2] = float(input_edges[lang1][lang2]) / float(input_strengths[lang1])
        #   print "Normalized edge: " + lang1 + ',' + lang2 + "  Normalized Weight: " + str(normalized_edges[lang1][lang2])

    # Calculating significance of each edge
    edge_probability = tree()
    kept_nodes = []
    kept_edges = []
    for lang1, lang2_num in normalized_edges.iteritems():
        for lang2 in lang2_num.iterkeys():
            normalized_weight = normalized_edges[lang1][lang2]
            degree = int(input_degrees[lang1])
            edge_prob = 1 - (degree - 1) * (integrate.quad(lambda x: math.pow((1 - x), (degree - 2)), 0, normalized_weight))[0]
            #if edge_prob > SIG_CUTOFF:
            #   print lang1 + "," + lang2 + " Significance: " + str(edge_prob)
            if edge_prob < SIG_CUTOFF:
                backbone_edge_count += 1
            #   print lang1 + "," + lang2 + " Significance: " + str(edge_prob) + "<------------ Less than 0.10"
                if (lang1, lang2) not in kept_edges:# and ((lang2, lang1) not in kept_edges):
                    kept_edges.append((lang1, lang2))
                if lang1 not in kept_nodes:
                    kept_nodes.append(lang1)
                if lang2 not in kept_nodes:
                    kept_nodes.append(lang2)

    # Outputs network
    for tup in kept_edges:
        output_network.write(tup[0] + ',' + tup[1] + '|' + input_edges[tup[0]][tup[1]])

    output_network.close()

    print "Input Nodes: " + str(i_node_count)
    print "Input Edges: " + str(i_edge_count)
    print "Output Nodes: " + str(len(kept_nodes))
    print "Output Edges: " + str(len(kept_edges))
