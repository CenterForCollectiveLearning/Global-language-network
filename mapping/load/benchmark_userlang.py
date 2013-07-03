import cProfile
from load import usertable

failed = 0
if __name__ == '__main__':

    infile = '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/wikipedia/datasets/userlang/wikipedia_userlang_full.dat'
    outfile = '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/results/2012-07-22_11/preprocessed/wikipedia_userlang_filtered.txt'
    line_count = '38304979'
    paths = {'load': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/load', 'visualize': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/visualize', 'extracted': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/results/2012-07-22_11/extracted', 'process': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/process', 'twitter': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/twitter/datasets/userlang/may_90_userlang_full.dat', 'wikipedia': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/wikipedia/datasets/userlang/wikipedia_userlang_full.dat', 'results': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/results/2012-07-22_11/', 'analysis': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis', 'preprocessed': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/results/2012-07-22_11/preprocessed', 'books': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/books_UNESCO/UNESCO_processed_directed.dat', 'net-langs': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs', 'processed': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/results/2012-07-22_11/processed', 'visualizations': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/results/2012-07-22_11/visualizations', 'final': '/Users/whoiskevinhu/Documents/Current/MacroConnections/net-langs/analysis/results/2012-07-22_11/final'}
    major_delim = ','
    minor_delim = None
    inheader = None
    outheader = None
    langs_to_merge = []
    langs_to_remove = ['tokipona', 'kj', 'mus', 'ho', 'ii', 'kr', 'hz', 'cho', 'mh', 'mo', 'aa', 'ng', 'srn', 'ny', 'pnt', 'pi', 'ts', 'tum', 'sg', 'rn', 've', 'ks', 'lg', 'ti', 'sn', 'ss', 'pag', 'tw', 'ki', 'ik', 'xh', 'chy', 'mdf', 'om', 'ff', 'kaa', 'ty', 'dz', 'kg', 'fj', 'st', 'lbe', 'za', 'myv', 'ha', 'bxr', 'tn', 'rw', 'cdo', 'mhr', 'sm', 'tet', 'to', 'pih', 'mzn', 'ch', 'bug', 'ig', 'got', 'kab', 'sd', 'xal', 'nov', 'av', 'rmy', 'bh', 'bm', 'bi', 'iu', 'cr', 'roa_tara', 'ee', 'zu', 'or', 'na', 'ak', 'haw', 'ln', 'stq', 'wo', 'zea', 'chr', 'glk', 'hak', 'udm', 'pap', 'kv', 'pa', 'ie', 'jbo', 'nrm', 'ce', 'as', 'kl', 'lo', 'arc', 'fiu_vro', 'cbk_zam', 'bcl', 'gn', 'tpi', 'ab', 'roa_rup', 'nv', 'ilo', 'frp', 'mi', 'ug', 'gan', 'crh', 'ay', 'cu', 'ext', 'diq', 'eml', 'lij', 'dsb', 'map_bms', 'ps', 'dv', 'mg', 'new', 'ba', 'kw', 'tk', 'pdc', 'sah', 'gv', 'pam', 'hif', 'bo', 'se', 'fur', 'rm', 'sc', 'csb', 'bpy', 'ky', 'yo', 'szl', 'my', 'so', 'co', 'sa', 'wa', 'nah', 'ksh', 'am', 'bat_smg', 'os', 'nds_nl', 'mt']
    min_per_language = 20
    min_per_user = 5

    cProfile.runctx(usertable.filter_userlang_network(
        infile, outfile, line_count, paths, major_delim, minor_delim, inheader, outheader,
        langs_to_merge, langs_to_remove, min_per_language, min_per_user
    ),globals())
        