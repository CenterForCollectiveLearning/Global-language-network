Set desired settings in settings.py.
- Add the names of the datasets to use under 'general'->'datasets_to_use'
- Add the path of each dataset under 'dataset_locations'; paths should be raltive to the repo root.
- The most relevant section is 'pre-filtering' and is currently configured to the same settings used for the original GLN paper.

To run, python mapping/


TODO: 
- Remove final, processed, etc. -- any folder but processed
- Write the stats to a text file in addition to the screen
- Call the prep_std_tables.R (and maybe prep_cyto_layout.R) from the Python code. Pass it the input/output path arguments.
