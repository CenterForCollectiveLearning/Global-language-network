'''
Breakdown of languages in each country accoding to CIA World Fact Book, or, if missing, from Wikipedia articles.

-Percentages may not add to 100, and may be missing altogehter in certain cases. I wouldn't trust it with my life...
'''

import sys
import operator # for sorting dictionary by values

LGN_HOME = '../../../' # fix this path to work for you!!!!
sys.path.append(LGN_HOME+'mapping/load/')
import convert_lang

LANG_CONVERSION_FILE = LGN_HOME+\
  "/data/lang_tools/lang_conversion/gold/iso-639-3-20120726_conversion_nogeneric.txt"


# Print the dictionary: leave blank to print to screen, or pass a filename
OUTPUT_FILENAME = "" 

COUNTRY_THREE_CODE_TO_LANG_TWO = {
    u'ABW': {'en': 7.7, 'es': 12.6, 'nl': 5.8},
    u'AFG': {'fa': 50},
    u'AGO': {'pt': 80},
    u'AIA': {'en': 100},
    u'ALB': {'ro': 5, 'sq': 95},
    u'AND': {'ca': 50, 'es': 40, 'fr': 10},
    u'ANT': {},
    u'ARE': {'ar': 100},
    u'ARG': {'es': 85, 'it': 3.8},
    u'ARM': {'hy': 97.7, 'ru': 0.9},
    u'ASM': {'en': 2.9},
    u'ATA': {},
    u'ATG': {'en': 100},
    u'AUS': {'ar': 1.2, 'el': 1.3, 'en': 78.5, 'it': 1.6, 'zh-zh-TW': 2.5},
    u'AUT': {'de': 88.6, 'hr-sr': 2.2, 'tr': 2.3},
    u'AZE': {'az': 90.3, 'hy': 1.5, 'ru': 1.8},
    u'BDI': {'fr': 0.02},
    u'BEL': {'fr': 40, 'nl': 60},
    u'BEN': {'fr': 40},
    u'BFA': {'fr': 100},
    u'BGD': {'bn': 98, 'en': 2},
    u'BGR': {'bg': 84.5, 'tr': 9.6},
    u'BHR': {'ar': 100},
    u'BHS': {'en': 100},
    u'BIH': {'hr-sr': 33.2},
    u'BLR': {'be': 36.7, 'ru': 62.8},
    u'BLZ': {'en': 3.9, 'es': 46, 'ht': 32.9},
    u'BMU': {'en': 91.8, 'pt': 4},
    u'BOL': {'ay': 14.6, 'es': 60.7, 'qu': 21.2},
    u'BRA': {'pt': 100},
    u'BRB': {'en': 100},
    u'BRN': {'en': 20, 'id-ms': 80},
    u'BTN': {},
    u'BWA': {'en': 2.1},
    u'CAF': {'fr': 100},
    u'CAN': {'en': 65, 'fr': 35},
    u'CHE': {'de': 66.7, 'en': 1, 'fr': 23.4, 'it': 8.9},
    u'CHL': {'en': 100},
    u'CHN': {'zh-zh-TW': 100},
    u'CIV': {'fr': 100},
    u'CMR': {'en': 50, 'fr': 50},
    u'COD': {'fr': 100},
    u'COG': {'fr': 100},
    u'COK': {},
    u'COL': {'es': 100},
    u'COM': {'ar': 100},
    u'CPV': {'pt': 100},
    u'CRI': {'es': 100},
    u'CUB': {'es': 100},
    u'CYM': {'en': 95, 'es': 5},
    u'CYP': {'el': 50, 'fr': 50},
    u'CZE': {'cs': 100},
    u'DEU': {'de': 100},
    u'DJI': {'ar': 50, 'fr': 50},
    u'DMA': {'en': 100},
    u'DNK': {'da': 100},
    u'DOM': {'es': 100},
    u'DZA': {'ar': 73, 'fr': 5},
    u'ECU': {'es': 100},
    u'EGY': {'ar': 100},
    u'ERI': {},
    u'ESH': {'ar': 100},
    u'ESP': {'ca': 17, 'es': 74, 'eu': 2, 'gl': 7},
    u'EST': {'et': 70, 'ru': 30},
    u'ETH': {'am': 32.7, 'ar': 7.5, 'en': 7.5, 'om': 31.6},
    u'FIN': {'fi': 95, 'sv': 5},
    u'FJI': {'en': 50, 'hi': 50},
    u'FLK': {'en': 100},
    u'FRA': {'fr': 100},
    u'FSM': {'en': 100},
    u'GAB': {'en': 100},
    u'GBR': {'cy': 1.2, 'en': 96.3, 'gd': 2.5},
    u'GEO': {'hy': 10, 'ka': 80, 'ru': 10},
    u'GHA': {'en': 100},
    u'GIB': {'en': 100},
    u'GIN': {'fr': 100},
    u'GLP': {},
    u'GMB': {'en': 100},
    u'GNB': {'pt': 100},
    u'GNQ': {'es': 75, 'fr': 25},
    u'GRC': {'el': 100},
    u'GRD': {'en': 100},
    u'GRL': {'da': 13.7},
    u'GTM': {'es': 100},
    u'GUF': {'fr': 100},
    u'GUM': {'ch': 22.2, 'en': 38.3, 'fil': 22.2},
    u'GUY': {'en': 100},
    u'HKG': {'en': 2.8, 'zh-zh-TW': 91.7},
    u'HND': {'es': 100},
    u'HRV': {'hr-sr': 100},
    u'HTI': {'fr': 25.2, 'ht': 74.8},
    u'HUN': {'hu': 93.6},
    u'IDN': {'id-ms': 100},
    u'IND': {'bn': 8.1,
             'hi': 41,
             'ml': 3.2,
             'mr': 7,
             'pa': 2.8,
             'ta': 5.9,
             'te': 7.2,
             'ur': 5},
    u'IRL': {'en': 95, 'ga': 5},
    u'IRN': {'ar': 5, 'fa': 75, 'ku': 20},
    u'IRQ': {'ar': 80, 'ku': 20},
    u'ISL': {'is': 100},
    u'ISR': {'ar': 20, 'he': 80},
    u'ITA': {'it': 100},
    u'JAM': {'en': 100},
    u'JOR': {'ar': 100},
    u'JPN': {'ja': 100},
    'JTN': {},
    u'KAZ': {'kk': 60, 'ru': 40},
    u'KEN': {'en': 20, 'sw': 80},
    u'KGZ': {'ky': 64.7, 'ru': 12.5, 'uz': 13.6},
    u'KHM': {'en': 2.5, 'fr': 2.5, 'km': 95},
    u'KIR': {},
    u'KNA': {'en': 100},
    u'KOR': {'ko': 100},
    u'KWT': {'ar': 50, 'en': 50},
    u'LAO': {'lo': 100},
    u'LBN': {'ar': 100},
    u'LBR': {'en': 20},
    u'LBY': {'ar': 90, 'en': 5, 'it': 5},
    u'LCA': {'en': 100},
    u'LKA': {'si': 74, 'ta': 18},
    u'LSO': {'en': 10},
    u'LTU': {'lt': 80, 'pl': 10, 'ru': 10},
    u'LUX': {'de': 4, 'en': 1, 'fr': 6, 'lb': 77},
    u'LVA': {'lt': 4.3, 'lv': 58.2, 'ru': 37.5},
    u'MAC': {'en': 1.5, 'fil': 1.3, 'zh-zh-TW': 97},
    u'MAR': {'ar': 100},
    u'MCO': {},
    u'MDA': {'bg': 1.14, 'ro': 75.17, 'ru': 15.99, 'uk': 3.85},
    u'MDG': {'fr': 100},
    u'MDV': {'dv': 95, 'en': 5},
    u'MEX': {'es': 100},
    u'MHL': {'en': 100},
    u'MKD': {'mk': 66.5, 'sq': 25.1, 'tr': 8.4},
    u'MLI': {'bm': 80},
    u'MLT': {'en': 6, 'mt': 90.2},
    u'MMR': {'my': 66.7},
    u'MNG': {'mn': 100},
    u'MNP': {},
    u'MOZ': {'pt': 10.7},
    u'MRT': {'ar': 100},
    u'MTQ': {'fr': 100},
    u'MUS': {'en': 1, 'fr': 3.5, 'ht': 80.5},
    u'MWI': {'en': 100},
    u'MYS': {'id-ms': 100},
    u'MYT': {'fr': 100},
    u'NAM': {'af': 4.4, 'de': 32, 'en': 7},
    u'NCL': {'fr': 100},
    u'NER': {'fr': 100},
    u'NFK': {'en': 100},
    u'NGA': {'en': 100},
    u'NIC': {'es': 97.5},
    u'NIU': {},
    u'NLD': {'nl': 100},
    u'NOR': {'nb': 100},
    u'NPL': {},
    u'NRU': {},
    u'NZL': {'en': 91.2},
    u'OMN': {'ar': 100},
    u'PAK': {'pa': 48, 'ur': 8},
    u'PAN': {'en': 14, 'es': 86},
    u'PER': {'es': 84.1},
    u'PHL': {'en': 4, 'fil': 55},
    u'PLW': {'en': 9.4, 'fil': 13.5, 'ja': 1.5, 'zh-zh-TW': 5.7},
    u'PNG': {'en': 1},
    u'POL': {'pl': 97.8},
    u'PRI': {'en': 2.5, 'es': 87},
    u'PRK': {'ko': 100},
    u'PRT': {'pt': 100},
    u'PRY': {'es': 3.1},
    u'PSE': {'ar': 100},
    u'PYF': {'fr': 61.1},
    u'QAT': {'ar': 50, 'en': 50},
    u'REU': {'fr': 100},
    u'ROU': {'hu': 6.7, 'ro': 91},
    u'RUS': {'ru': 100},
    u'RWA': {'en': 20, 'fr': 20},
    u'SAU': {'ar': 100},
    u'SDN': {'ar': 50, 'en': 50},
    u'SEN': {'fr': 100},
    u'SGP': {'en': 23, 'id-ms': 14.1, 'zh-zh-TW': 40.7},
    u'SHN': {'en': 100},
    u'SLB': {'en': 2},
    u'SLE': {'en': 100},
    u'SLV': {'es': 100},
    u'SOM': {'ar': 10, 'en': 5, 'it': 5, 'so': 80},
    u'SPM': {'fr': 100},
    u'SRB': {'hr-sr': 95, 'hu': 5},
    u'SSD': {'ar': 50, 'en': 50},
    u'STP': {'pt': 100},
    u'SUR': {'nl': 100},
    u'SVK': {'hu': 10, 'sk': 90},
    u'SVN': {'sl': 100},
    u'SWE': {'sv': 100},
    u'SWZ': {'en': 100},
    u'SYC': {'en': 5, 'ht': 95},
    u'SYR': {'ar': 100},
    u'TCA': {'en': 100},
    u'TCD': {'ar': 50, 'fr': 50},
    u'TGO': {'fr': 100},
    u'THA': {'th': 100},
    u'TJK': {'tg': 100},
    u'TKM': {'ru': 12, 'tk': 72, 'uz': 9},
    u'TON': {},
    u'TTO': {'en': 100},
    u'TUN': {'ar': 100},
    u'TUR': {'ar': 1.2, 'ku': 6, 'tr': 90},
    u'TUV': {},
    u'TWN': {'zh-zh-TW': 100},
    u'TZA': {'en': 10, 'sw': 90},
    u'UGA': {'en': 20, 'sw': 80},
    u'UKR': {'ru': 24, 'uk': 67},
    u'URY': {'es': 100},
    u'USA': {'en': 82.1, 'es': 10.7},
    u'UZB': {'ru': 14.2, 'tg': 4.4, 'uz': 74.3},
    u'VCT': {'en': 100},
    u'VEN': {'es': 100},
    u'VGB': {},
    u'VIR': {'en': 74.7, 'es': 16.8, 'fr': 6.6},
    u'VNM': {'vi': 100},
    u'VUT': {'en': 2},
    u'WLF': {'fr': 10.8},
    u'WSM': {},
    u'YEM': {'ar': 100},
    u'ZAF': {'af': 13.35, 'en': 8.2, 'nso': 9.39, 'xh': 17.64, 'zu': 23.83},
    u'ZMB': {'en': 1.7},
    u'ZWE': {'en': 100}}


def print_country_to_langs_mapping(outfile=""):
  # Format the dictionary nicely and print it, to given file 
  # or to screen (outfile="")

  # Load conversion table
  iso3_table, code_to_name = \
    convert_lang.init_conversion_table_iso3(LANG_CONVERSION_FILE)

  # Hacks for non-standard two-letter codes for merged languages
  iso3_table['hr-sr'] = 'hbs' 
  iso3_table['id-ms'] = 'msa'
  iso3_table['zh-zh-TW'] = 'zho'

  header_string = "Country.Code\tLanguage\tLanguage.Percent"

  if outfile=="":
    print header_string
  else:
    fout = open(outfile, 'w')
    fout.write(header_string + "\n")

  for country, langs in COUNTRY_THREE_CODE_TO_LANG_TWO.iteritems():
    # prepare a tab-separatd string of "lang:percent"
    spoken_langs = []

    # Sort languages from most spoken to least
    sorted_langs = sorted(langs.iteritems(), 
                          key=operator.itemgetter(1),
                          reverse=True)

    for (lang_code, pcent) in sorted_langs:
        # The result is a list - format it nicely
        lang_string = "\t".join([country, iso3_table[lang_code], str(pcent)])

        if outfile=="":
            print lang_string
        else:
            #write to file
            fout.write(lang_string + "\n")

    # The result is a list - format it nicely
    # for (lang_code, pcent) in sorted_langs:
    #   spoken_langs.append(
    #     "{0}: {1}%".format(iso3_table[lang_code], pcent)) 

    # # Now add the country code 
    # langs_string = country + "\t" + ", ".join(spoken_langs)

    # if outfile=="":
    #   print langs_string
    # else:
    #   #write to file
    #   fout.write(langs_string + "\n")

  if outfile!="":
    fout.close()

    
if __name__ == "__main__":
  print_country_to_langs_mapping(outfile=OUTPUT_FILENAME)

