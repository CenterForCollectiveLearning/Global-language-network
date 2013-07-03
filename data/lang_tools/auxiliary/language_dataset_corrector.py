import sys
sys.path.append('../mappings')
from lang_two_code_to_three_code_mapping import LANG_TWO_TO_THREE

fin_pop = open('speakers_all_families.tsv')
fin_pop.readline()
fin = open('language_codes_gdp_pop.tsv')
fin.readline()
fout = open('language_codes_gdp_popcorrected.tsv', 'w')
fout.write('language\tgdp_per_capita\tpopulation\n')

pop_dict = dict()

for line in fin_pop:
    line_list = line.split('\t')
    lang_three, num_speakers = line_list[0], 1000000 * float(line_list[2])
    pop_dict[lang_three] = num_speakers

for line in fin:
    lang_two, gdp, old_pop, _, _ = line.split('\t')
    lang_three = LANG_TWO_TO_THREE[lang_two]
    pop = pop_dict[lang_three]
    gdp = (float(gdp) * float(old_pop)) / pop
    fout.write('%s\t%.3f\t%s\n' % (lang_three, gdp, int(pop)))

fout.close()
