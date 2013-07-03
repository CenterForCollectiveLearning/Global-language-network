import matplotlib.pyplot as plt
import numpy as np
from scipy import stats

DATAFILE = 'output/UsersSummary.txt'
DELIM = '\t'
MISSING_DATA = ['-1', '0']


def scatter_plot(output_filename, xvals, yvals, data_labels, fig_title, xlabel, ylabel, xscale='linear', yscale='linear', output_format='eps', regression=True):
    '''
    Data point labels inspired:
    http://stackoverflow.com/questions/5147112/matplotlib-how-to-put-individual-tags-for-a-scatter-plot

    Possible customizations for scatter():
     s=<int>: sets the size of each point to <int> pixels.
     alpha=None: the alpha (transparency) value of the points. Between 0 and 1.
     linewidth=<int>: sets the width of the line around the point to <int> pixels.
     cmap = plt.get_cmap('Spectral')

    Possible customizations for annotate():
     xy=<int, int>: coords for the point to annotate
     textcoords: type of coords, e.g., pixels or offset
     xytext=<int, int> notes the distance of the label from 'xy' in 'textcoords'
     add boxes arounds labels using bbox and boxstyle, add arrows using arrowprops
    '''
    # Debug: print values to test with Excel
    #for i in xrange(len(xvals)):
    #   print xvals[i], yvals[i]


    fig = plt.figure(figsize=(10, 5))
    subplot = fig.add_subplot(111)

    # Draw the scatter plot
    #subplot.set_xlim(1e-9, 1.5e9)
    subplot.set_xscale(xscale)
    subplot.set_yscale(yscale)
    subplot.set_xlabel(xlabel)
    subplot.set_ylabel(ylabel)
    subplot.scatter( xvals, yvals, marker='.', c='red' )

    # Label the data points
    for label, x, y in zip(data_labels, xvals, yvals):
        subplot.annotate(
            label, xy = (x, y), xycoords='data', xytext = (0, 2),
            textcoords = 'offset points', ha = 'center', va = 'bottom', size="xx-small"
        )
    subplot.set_title(fig_title)

    if regression==True:
        # Plot the regression line:
        # http://baoilleach.blogspot.com/2007/12/matplotlib-tips.html
        slope, intercept, r_squared = regress(xvals, yvals)
        #print fig_title, slope, intercept, r_squared

        subplot.set_title('%s Lin. Reg.: %.4fx + %.4f, R^2=%.4f' % (fig_title,slope,intercept,r_squared) )
        min_x = min(xvals)
        max_x = max(xvals)
        print min_x, max_x
        subplot.plot((min_x, max_x), [(slope*x + intercept) for x in [min_x, max_x]])

    plt.savefig(output_filename, format=output_format)
    print ">>> Created file %s\n" % output_filename


def load_data_from_file(input_filename):
    '''
    Load data for languages listed in all three data sources
    '''
    fdata = open(input_filename, 'rU')

    xvals = []
    yvals_books = []
    yvals_wiki = []
    yvals_twitter = []
    labels = []

    fdata.readline() # Skip Header

    for line in fdata:
        # assuming EOL at end of next line!
        lcode, lname, books, wiki, twitter, speakers = line[:-1].split(DELIM)
        if speakers not in MISSING_DATA and books not in MISSING_DATA and \
            twitter not in MISSING_DATA and wiki not in MISSING_DATA:
            # Must fit a log scale, TODO: zero values should not appear in the file to begin with!
            # To remove chinese uncomment the following:
            #if lcode=='zh':
            #   continue # skip chinese
            #   print lcode, lname, books, wiki, twit, speakers, '->', updated_speakers
            updated_speakers = int(1e6*float(speakers)) # counted in millions
            xvals.append(updated_speakers)
            yvals_books.append(int(books))
            yvals_wiki.append(int(wiki))
            yvals_twitter.append(int(twitter))
            labels.append(lcode)

    return xvals, yvals_books, yvals_wiki, yvals_twitter, labels


def regress(x, y):
    '''
    Calculate linear regression and R-squared of values
    From http://docs.scipy.org/scipy/docs/scipy.stats.stats.linregress/
    '''
    slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)

    # Use r_value**2 for coefficient of determination (r_squared)
    return slope, intercept, r_value**2


if __name__ == "__main__":
    # Collect the data
    speakers_lbl = 'Number of Speakers'
    books_lbl = 'Number of Books'
    wiki_lbl = 'Number of Wikipedia Users'
    twitter_lbl = 'Number of Twitter Users'

    xvals, yvals_books, yvals_wiki, yvals_twitter, labels = load_data_from_file(DATAFILE)

    print "Num of langs:", len(xvals)

    # Draw the plots
    scatter_plot('plot/scatter_books_reg.svg', xvals, yvals_books, labels, 'Books/Speakers',\
        speakers_lbl, books_lbl, 'log', 'log', output_format='svg')

    scatter_plot('plot/scatter_wiki_reg.svg', xvals, yvals_wiki, labels, 'Wikipedia/Speakers', \
        speakers_lbl, wiki_lbl, 'log', 'log', output_format='svg')

    scatter_plot('plot/scatter_twitter_reg.svg', xvals, yvals_twitter, labels, 'Twitter/Speakers',\
        speakers_lbl, twitter_lbl, 'log', 'log', output_format='svg')

    # Correlation table
    # http://scipy.org/Numpy_Example_List_With_Doc#head-f08a3e6b178e230a18c172bbbe4c755f799a803f

    print np.corrcoef([xvals, yvals_books, yvals_wiki, yvals_twitter])
