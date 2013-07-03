import os
import re
import glob
import shutil
import subprocess

from settings import SETTINGS, VISUAL_SETTINGS

def create_temp_files(network, paths):
    """
    Boilerplate for passing finalized network to visualization step:
    creates temporary node and edge files and adds or modifies
    attributes for both.
    """
    fnode_name = os.path.join(paths['visualize'], 'temp_node.tsv')
    fedge_name = os.path.join(paths['visualize'], 'temp_edge.tsv')
    print "\t\tWrote temporary node file", os.path.basename(fnode_name)
    print "\t\tWrote temporary edge file", os.path.basename(fedge_name)


    num_speakers_per_lang_file = paths['num_speakers_per_lang_file']
    fin = open(num_speakers_per_lang_file)
    fin.readline()

    pattern = re.compile(r' \(.*?\)')
    num_speakers_per_lang_dict = {}
    for line in fin:
        lang_code, lang_name, num_speakers = line.split('\t')
        lang_name = re.sub(pattern, '', lang_name)
        lang_name = lang_name.replace('macrolanguage', '')
        num_speakers = float(num_speakers.strip())
        num_speakers_per_lang_dict[lang_name] = num_speakers

    fnode = open(fnode_name, 'w')
    fedge = open(fedge_name, 'w')
    fnode.write('{}\t{}\t{}\n'.format('Id', 'Label', 'Num_Speakers'))
    fedge.write('{}\t{}\t{}\n'.format('Source', 'Target', 'Weight'))

    counter = 1
    id_dict = {}  # Used to number the nodes (necessary for Gephi)
    missing_langs = set([])

    num_speakers_cutoff = SETTINGS['post-filtering']['speaker_cutoff']

    for node_pair, weight in network.iteritems():
        s_node, t_node = node_pair
        if s_node in num_speakers_per_lang_dict:
            if s_node not in id_dict:
                id_dict[s_node] = counter
                counter += 1
                num_speakers = num_speakers_per_lang_dict[s_node]
                if num_speakers >= num_speakers_cutoff:
                    fnode.write('{id}\t{s_node}\t{num_speakers}\n'.format(id=id_dict[s_node],
                                                                          s_node=s_node, num_speakers = num_speakers))
                else:
                    print s_node, "less than", num_speakers
        else:
            missing_langs.add(s_node)
            continue
        if t_node in num_speakers_per_lang_dict:
            if t_node not in id_dict:
                id_dict[t_node] = counter
                counter += 1
                num_speakers = num_speakers_per_lang_dict[t_node]
                if num_speakers >= num_speakers_cutoff:
                    fnode.write('{id}\t{t_node}\t{num_speakers}\n'.format(id=id_dict[t_node],
                                                                          t_node=t_node, num_speakers = num_speakers))
                else:
                    print t_node, "less than", num_speakers
        else:
            missing_langs.add(t_node)
            continue
        fedge.write('{s_node}\t{t_node}\t{weight}\n'.format(s_node=id_dict[s_node],
                                            t_node=id_dict[t_node], weight=5 * weight))

    # Making properties file
    # fprop_name = os.path.join(paths['visualize'], 'temp.properties')
    # fprop = open(fprop_name, 'w')
    # for prop, val in VISUAL_SETTINGS.iteritems():
    #     fprop.write('%s=%s\n' % (prop, val))

    print "\tLanguages not in network because missing number of speakers:", len(missing_langs)
    #print "\t\t" + ', '.join(missing_langs)
    fnode.close()
    fedge.close()
    # fprop.close()
    return fnode_name, fedge_name #, fprop_name


def compile_and_run(paths):
    print "\t\tCompiling source file"
    subprocess.call("sh compile.sh", shell=True, cwd=paths['visualize'])
    print "\t\tRunning java class"
    subprocess.call("sh run.sh", shell=True, cwd=paths['visualize'])


def remove_temp_files(fnode_name, fedge_name):
    os.remove(fnode_name)
    os.remove(fedge_name)


def move_results(paths):
    for viz_result in glob.glob(os.path.join(paths['visualize'], 'network*')):
        shutil.move(viz_result, paths['visualizations'])
        print "\t\tMoving", os.path.basename(viz_result), "to visualizations folder"


def visualize(network, paths):
    print "\nVISUALIZATION"
    print "\n\tBoilerplate"
    fnode_name, fedge_name = create_temp_files(network, paths)
    compile_and_run(paths)
    remove_temp_files(fnode_name, fedge_name)
    print "\n\tCleaning up"
    move_results(paths)
