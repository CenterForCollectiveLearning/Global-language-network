#!/usr/bin/env python

import sys
import json

# {u'position': {u'y': 1097.33203125, u'x': 1724.5416259765625}, u'selected': False, u'data': {u'Viz_Family_Code': u'cau', u'Viz_Family_Name': u'Caucasian', u'Reference_Name': u'Abkhazian', u'Lang_Name': u'Abkhazian', u'id': u'4905', u'Status': u'A', u'Family_Name': u'Caucasian', u'Common_Twitter_Wiki_Code': u'ab', u'Primary_Family_Name': u'Caucasian', u'SUID': 4905, u'Final_Name': u'Abkhazian', u'selected': False, u'name': u'abk', u'__1': u'ab', u'__3': u'abk', u'__2': u'abk', u'shared_name': u'abk', u'Language_Type': u'L', u'Partner_Agency': u'JAC', u'Primary_Family_Code': u'cau', u'Documentation': u'SIL', u'Twitter_CLD_Only_Code': u'', u'__2_B': u'', u'Num_Speakers_M': 0.125, u'Element_Scope': u'I', u'Wiki_Only_Code': u'', u'LogNumSpeaker': 5.096910013008056, u'Family_Code': u'cau'}}
# {u'selected': False, u'data': {u'interaction': u'pp', u'TargetPopulations': 82772, u'target': u'4904', u'TargetLanguageName': u'Russian', u'SUID': 5450, u'Tstatistic': 8.59922041, u'selected': False, u'PhiCorrelation': 0.02699584, u'source': u'4905', u'SourceLanguageName': u'Abkhazian', u'SourcePopulation': 171, u'Coocurrences': 106, u'shared_interaction': u'pp', u'shared_name': u'abk (pp) rus', u'id': u'5450', u'name': u'abk (pp) rus'}}

def main():
    types = ['books', 'twitter', 'wikipedia']

    # Expressions
    books_stats_f = open('public/dataset_stats_books.tsv')
    twitter_stats_f = open('public/dataset_stats_twitter.tsv')
    wiki_stats_f = open('public/dataset_stats_wikipedia.tsv')

    books_stats_f.readline()
    twitter_stats_f.readline()
    wiki_stats_f.readline()

    books_stats_dict = {}
    for l in books_stats_f:
        x = l.strip().split('\t')
        code, num_from, num_to, out_degree, in_degree = x[1], x[2], x[3], x[4], x[5]
        books_stats_dict[code] = {
            'from': num_from, 
            'to': num_to,
            'out_degree': out_degree,
            'in_degree': in_degree,
        }

    twitter_stats_dict = {}
    for l in twitter_stats_f:
        x = l.strip().split('\t')
        code, tweets, users, avg_user, tweets_ml, ml, avg_ml  = x[1], x[2], x[3], x[4], x[5], x[6], x[7]
        twitter_stats_dict[code] = {
            'tweets': tweets,
            'users': users,
            'average': avg_user,
            'tweets_ml': tweets_ml,
            'ml': ml,
            'avg_ml': avg_ml
        }

    wiki_stats_dict = {}
    for l in wiki_stats_f:
        x = l.strip().split('\t')
        code, edits, editors, avg_editor, edits_ml, ml, avg_ml = x[1], x[2], x[3], x[4], x[5], x[6], x[7]
        wiki_stats_dict[code] = {
            'edits': edits,
            'editors': editors,
            'average': avg_editor,
            'edits_ml': edits_ml,
            'ml': ml,
            'avg_ml': avg_ml
        }

    # Create dictionaries mapping language to centrality, gdp per capita, and population
    cent_f = open('public/centralities_by_language.tsv')
    gdp_pc_pop_f = open('public/gdp_pc_population_by_language.tsv')
    lang_f = open('public/language_conversion_table_iso639-3.tsv')

    cent_f.readline()
    gdp_pc_pop_f.readline()
    lang_f.readline()

    # Centrality dictionary
    lang_code_to_cent = {}
    for l in cent_f:
        l_list = l.strip().split('\t')
        lang_name, lang_code, twitter_eig, wiki_eig, books_eig = l_list[0], l_list[1], l_list[2], l_list[3], l_list[4]
        if twitter_eig is '': twitter_eig = 0.0
        if wiki_eig is '': wiki_eig = 0.0
        if books_eig is '': books_eig = 0.0

        twitter_eig = float(twitter_eig)
        wiki_eig = float(wiki_eig)
        books_eig = float(books_eig)

        # Parsing out scientific notation
        lang_code_to_cent[lang_code] = {
            'twitter': twitter_eig,
            'wikipedia': wiki_eig,
            'books': books_eig
        }

    # Population and GDPpc dictionary
    lang_code_to_pop = {}
    lang_code_to_gdp_pc = {}
    for l in gdp_pc_pop_f:
        l_list = l.strip().split('\t')
        lang_code, gdp_pc, pop = l_list[0], float(l_list[1]), float(l_list[2])
        lang_code_to_gdp_pc[lang_code] = gdp_pc
        lang_code_to_pop[lang_code] = pop

    # Code to language name dictionary
    lang_code_to_name = {}
    for l in lang_f:
        l_list = l.strip().split('\t')
        lang_code, lang_name = l_list[0], l_list[1]
        lang_code_to_name[lang_code] = lang_name

    # Iterating through three types of networks to create final JSONs
    for type in types:
        final_data = []
        final_nodes = []
        final_edges = []

        data = json.load(open('%s_raw.json' % type))
        nodes = data['elements']['nodes']
        edges = data['elements']['edges']

        # Iterate through nodes
        for node in nodes:
            temp_node = node['position']
            id = node['data']['id']
            temp_node['id'] = id
            final_nodes.append(temp_node)

            raw_datum = node['data']
            lang_code = raw_datum['name']
            lang_name = raw_datum['Lang_Name']
            if lang_name == '':
                lang_name = lang_code_to_name[lang_code]

            pop = lang_code_to_pop.get(lang_code, '0')
            gdp_pc = lang_code_to_gdp_pc.get(lang_code, '0')
            if pop is '0':
                pop = 0
            if gdp_pc is '0':
                gdp_pc = 0

            temp_datum = {}
            temp_datum['id'] = id
            temp_datum['Language Code'] = lang_code.upper()
            temp_datum['Language Name'] = lang_name
            temp_datum['Family Name'] = raw_datum['Primary_Family_Name']
            temp_datum['Number of Speakers (millions)'] = pop
            temp_datum['GDP per Capita (dollars)'] = gdp_pc
            temp_datum['Eigenvector Centrality'] = lang_code_to_cent[lang_code][type]


            if type is "books":
                if lang_code in books_stats_dict:
                    temp_datum['Translations From'] = books_stats_dict[lang_code]['from'].replace(',', '')
                    temp_datum['Translations To'] = books_stats_dict[lang_code]['to'].replace(',', '')
                    temp_datum['Out Degree'] = books_stats_dict[lang_code]['out_degree'].replace(',', '')
                    temp_datum['In Degree'] = books_stats_dict[lang_code]['in_degree'].replace(',', '')
              
                else:
                    temp_datum['Translations From'] = 0
                    temp_datum['Translations To'] = 0
                    temp_datum['Out Degree'] = 0
                    temp_datum['In Degree'] = 0

            if type is "twitter":
                if lang_code in twitter_stats_dict:
                    temp_datum['Number of Tweets'] = twitter_stats_dict[lang_code]['tweets'].replace(',', '')
                    temp_datum['Number of Users'] = twitter_stats_dict[lang_code]['users'].replace(',', '')
                    temp_datum['Average Tweets per User'] = twitter_stats_dict[lang_code]['average'].replace(',', '')
                    temp_datum['Number of Multilinguals'] = twitter_stats_dict[lang_code]['ml'].replace(',', '')
                    temp_datum['Average Tweets per Multilingual'] = twitter_stats_dict[lang_code]['avg_ml'].replace(',', '')
                else:
                    temp_datum['Number of Tweets'] = 0
                    temp_datum['Number of Users'] = 0
                    temp_datum['Average Tweets per User'] = 0
                    temp_datum['Number of Multilinguals'] = 0
                    temp_datum['Average Tweets per Multilingual'] = 0


            if type is "wikipedia":
                if lang_code in wiki_stats_dict:
                    temp_datum['Number of Edits'] = wiki_stats_dict[lang_code]['edits'].replace(',', '')
                    temp_datum['Number of Editors'] = wiki_stats_dict[lang_code]['editors'].replace(',', '')
                    temp_datum['Average Edits per Editor'] = wiki_stats_dict[lang_code]['average'].replace(',', '')
                    temp_datum['Number of Multilinguals'] = wiki_stats_dict[lang_code]['ml'].replace(',', '')
                    temp_datum['Average Tweets per Multilingual'] = wiki_stats_dict[lang_code]['avg_ml'].replace(',', '')
                else:
                    temp_datum['Number of Edits'] = 0
                    temp_datum['Number of Editors'] = 0
                    temp_datum['Average Edits per Editor'] = 0
                    temp_datum['Number of Multilinguals'] = 0
                    temp_datum['Average Tweets per Multilingual'] = 0


            final_data.append(temp_datum)


        for edge in edges:
            temp_edge = {}
            temp_edge['source'] = edge['data']['source']  # ['SourceLanguageName']
            temp_edge['target'] = edge['data']['target'] # ['TargetLanguageName']
            temp_edge['opacity'] = edge['data']['Tstatistic']
            temp_edge['coocurrences'] = edge['data']['Coocurrences']
            final_edges.append(temp_edge)

        final_object = {'data': final_data, 'nodes': final_nodes, 'edges': final_edges}

        network_output = open('%s_network.json' % type, 'w')
        network_output.write(json.dumps(final_object))
        network_output.close()

        table_output = open('%s_table.json' % type, 'w')
        table_output.write(json.dumps(final_data))
        table_output.close()


if __name__ == '__main__':
    main()
