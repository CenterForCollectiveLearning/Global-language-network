## <root>/common_utils.py

'''
Methods and values used throughout the project.
'''

import os
import math
import datetime
from collections import defaultdict
from random_sample import *
# from progressbar import ProgressBar, Percentage, Bar

BRUNO_DELIMITER = '|'
BRUNO_HEADER = ['user', 'status', 'time', 'text', 'location', 'source', \
    'followers', 'reply_status', 'reply_use', 'screen_name', 'retweet_status',\
    'retweet_user', 'latitude', 'longitude']
USERLANG_HEADER = ['user', 'language', 'num_tweets']

USERLANG_DELIMITER = '\t'
USERLANG_MAJOR_DELIM = '\t'
USERLANG_MINOR_DELIM = ','
LANGLANG_DELIM = '\t'


def append_to_filename(path, appendix):
    # Adds given appendix with a preceding underscore to the end of given path,
    # maintaining the original extension
    filename, ext = os.path.splitext(path)
    new_path = filename + '_' + appendix + ext
    return new_path


def print_percentage(value, total):
    if value == 0:
        return "(0%)"
    elif total == 0:
        return "<error!>"  # div by zero
    else:
        return "(" + "%.2f" % (value * 100.0 / total) + "%)"


def tree():
    return defaultdict(tree)

def num_digits(n):
    return int(math.log10(n)) + 1


def get_current_date_formatted():
    return format_date(floor_date(datetime.datetime.now()))


def format_date(date):
    year = date.year
    month = '0' + str(date.month) if num_digits(date.month) is \
        1 else str(date.month)
    day = '0' + str(date.day) if num_digits(date.day) is \
        1 else str(date.day)
    return '{}-{}-{}'.format(year, month, day)


def get_days_between_dates(s_date, e_date):
    if (e_date - s_date).days < 0:
        s_date, e_date = e_date, s_date
    return (e_date - s_date).days


def floor_date(dt):
    return datetime.datetime(dt.year, dt.month, dt.day, 0, 0, 0)
