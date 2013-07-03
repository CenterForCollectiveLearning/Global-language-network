#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Module used to convert country data to language data, using the mappings in /net-langs/data/mappings.
"""

import sys
sys.path.append('../mappings')
from lang_two_code_to_three_code_mapping import LANG_TWO_TO_THREE
from country_name_lang_two_code_mapping import COUNTRY_NAME_TO_LANGS_TWO
from country_three_code_to_lang_two_code_mapping import COUNTRY_THREE_CODE_TO_LANG_TWO
