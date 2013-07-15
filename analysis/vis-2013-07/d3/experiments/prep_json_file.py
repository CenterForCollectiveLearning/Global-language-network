import os
from csv import DictReader

LGN_HOME = os.path.abspath(os.path.relpath(os.path.join(__file__, '../../../../../')))
LINKS_HOME = os.path.join(LGN_HOME, 'paper/figures/fig1-layout/filtered_glns')

NODE_FILE = os.path.join(LGN_HOME, 'data/lang_demog/population/gold/speakers_iso639-3_all_families.txt')

TWIT_LINK_FILE = os.path.join(LINKS_HOME, 'twit_links_filtered.tsv')
WIKI_LINK_FILE = os.path.join(LINKS_HOME, 'wiki_links_filtered.tsv')
BOOK_LINK_FILE = os.path.join(LINKS_HOME, 'book_links_filtered.tsv')

# Map family to colors
LANG_FAM_COLORS = {

	
}

def prep_json(nodefile, linkfile, sourceprefix, jsonfile):
	
	lang_num_conversion = [] # list index is the lagnuage number. Assume no duplicates

	fout = open(jsonfile, "w") 

	# Start JSON
	fout.write("{\n")

	#
	# Prepare the node list
	with open(nodefile, "rU") as csvfile:
		nodereader = DictReader(csvfile, delimiter="\t")
	
		# Start node section
		fout.write("\t\"nodes\":[" + "\n")

		for lang_num, row in enumerate(nodereader):
			# read
			lang_code = row['Lang_Code']
			lang_name = row['Lang_Name']
			num_speakers = row['Num_Speakers_M']
			family_code = row['Viz_Family_Code']
			print lang_num, lang_code, lang_name, num_speakers, family_code

			# store ID for preparing the link table later on
			lang_num_conversion.append(lang_code)
			
			# write JSON
			#fout.write("\t\t{\"name\":\"%s\", \"family\":\"%s\", \"speakers\":%s},\n" 
				#% (lang_name, LANG_FAM_COLORS[family_code], num_speakers) )
			#fout.write("\t\t{\"id\":%s, \"name\":\"%s\", \"family\":\"%s\", \"speakers\":%s},\n" 
			#	% (lang_num, lang_name, "#555", num_speakers) )
			fout.write("\t\t{\"name\":\"%s\", \"full_name\":\"%s\", \"family\":\"%s\", \"speakers\":%s},\n" 
				% (lang_code, lang_name, "#555", num_speakers) )

		# End node section
		fout.write("\t],\n")
		
	# 
	# Prepare the link list
	with open(linkfile, "rU") as csvfile:
		linkreader = DictReader(csvfile, delimiter="\t")

		fout.write("\t\"links\":[" + "\n")
		
		for row in linkreader:
			# read
			src_name = row[sourceprefix + 'src.name']
			src_id = lang_num_conversion.index(src_name)
			tgt_name = row[sourceprefix + 'tgt.name']
			tgt_id = lang_num_conversion.index(tgt_name)
			common_num = row[sourceprefix + 'common.num']
			exposure = row[sourceprefix + 'weight']
			print src_name, src_id, tgt_name, tgt_id, common_num, exposure
			
			# write JSON
			fout.write("\t\t{\"source\":\"%s\",\"target\":\"%s\",\"weight\":%s,\"common_num\":%s},\n"
				% (src_name, tgt_name, exposure, common_num) )

		# End link section
		fout.write("\t]\n")

	# End JSON
	fout.write("}\n")

	fout.close()

	print "DONE! Now remove the last comma from the node and link sections"
	
			


if __name__ == "__main__":

	prep_json(NODE_FILE, TWIT_LINK_FILE, "t", "blah3.json")

#
#  "nodes":[
#    {"name":"English","group":1,"size":5},
#    {"name":"French","group":2,"size":3},
#		...
#  ]
#

# "links":[
# 	{"source":1,"target":0,"value":1,"size":1},
# 	{"source":1,"target":2,"value":1,"size":10},
# 	{"source":1,"target":3,"value":1,"size":10},
# 	{"source":2,"target":0,"value":8,"size":1},
#		...
#  ]
