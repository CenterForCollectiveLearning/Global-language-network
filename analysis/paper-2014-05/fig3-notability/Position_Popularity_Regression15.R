source("../load.R", chdir=T)

# info on graph structure: http://igraph.sourceforge.net/doc/R/structure.info.html
# manipulate structure: http://igraph.sourceforge.net/doc/R/graph.structure.html
library(igraph)
library(gridExtra)
library(ggplot2)
library(memisc)

POPULARITY.DIR <- paste0(ANALYSIS.ROOT.DIR, "/fig3-notability/")

ALLOW.UNCOMMON.LANGS <- F # "True" to include languages that do not appear in ALL datasets.

# Note: if you use Shahar's files, need to comment out the PopFrom regressions
TWIT.CENT.FILE <- paste0(ANALYSIS.ROOT.DIR, "/EigTwitterNetwork.tsv")
WIKI.CENT.FILE <- paste0(ANALYSIS.ROOT.DIR, "/EigWikiNetwork.tsv")
BOOKS.CENT.FILE <- paste0(ANALYSIS.ROOT.DIR, "/EigBookNetwork.tsv")

prep.lgn.df <- function(twitter.ev.file, wiki.ev.file, books.ev.file,
                        lang.stats.file,
                        cultural.exports.file,
                        min.exports=0,
                        langs.to.remove=NULL) {
  
  # Load the eigenvector centralities from the different sources, and add population
  # GDP, and "cultural exports" for each language
  
  # Start with EV centralities - remove some unnecessary columns.
  # Use rownames as key for future merges
  twitter.metrics <- read.table(twitter.ev.file, header=T)
  names(twitter.metrics) <- c("language", "eig", "popfrom", "popto")
  rownames(twitter.metrics) <- twitter.metrics$language
  twitter.metrics <- twitter.metrics[ ,c("language", "eig", "popfrom")] 

  wiki.metrics <- read.table(wiki.ev.file, header=T)
  names(wiki.metrics) <- c("language", "eig", "popfrom", "popto")
  rownames(wiki.metrics) <- wiki.metrics$language
  wiki.metrics <- wiki.metrics[ ,c("language", "eig", "popfrom")]
  
  books.metrics <- read.table(books.ev.file, header=T)
  names(books.metrics) <- c("language", "eig", "popfrom", "popto")
  rownames(books.metrics) <- books.metrics$language
  books.metrics <- books.metrics[ ,c("language", "eig", "popfrom")]
  
  # Merge the tables
  tmp <- merge(twitter.metrics, wiki.metrics, by=0, all=ALLOW.UNCOMMON.LANGS)
  rownames(tmp) <- tmp$Row.names # Row.names is created unwillingly, rename...
  tmp$Row.names <- NULL # ...and remove
  graph.metrics <- merge(tmp, books.metrics,  by=0, all=ALLOW.UNCOMMON.LANGS)
  rownames(graph.metrics) <- graph.metrics$Row.names # Repeat...
  graph.metrics$Row.names <- NULL
  
  # Rename the table
  graph.metrics<-graph.metrics
  all.metrics <- graph.metrics[ ,c("eig.x", "popfrom.x",
                                   "eig.y", "popfrom.y",
                                   "eig", "popfrom")] # keep only EV columns (not extra language columns)
  names(all.metrics) <- c("twit.eig", "twit.popfrom",
                          "wiki.eig", "wiki.popfrom",
                          "book.eig", "book.popfrom")
  rm(graph.metrics)
  rm(tmp)

  # Add population and GDP per capita
  lang.demog <- read.table(lang.stats.file, sep = "\t", header=T)
  rownames(lang.demog) <- lang.demog$lang
  all.metrics$gdp.pc <-
    lang.demog[match(rownames(all.metrics),
                       rownames(lang.demog)),"gdp_pc"]
  all.metrics$pop <-
    lang.demog[match(rownames(all.metrics),
                     rownames(lang.demog)),"actual_speakers_m"]
  
  # Add cultural exports
  lang.exports <- read.table(cultural.exports.file, sep = "\t", header=T)
  rownames(lang.exports) <- lang.exports$lang
  all.metrics$cultexp <-
    lang.exports[match(rownames(all.metrics),
                      rownames(lang.exports)),"total_exports"]
  
  # Remove languages without listed cultural exports
  all.metrics <- subset(all.metrics, !is.na(cultexp))
  
  # Remove specific languages if defined
  all.metrics <- all.metrics[!(row.names(all.metrics) %in% langs.to.remove),]
  
  #all.metrics <<- all.metrics
  
  # Remove language with fewer than min.exports
  all.metrics <- all.metrics[all.metrics$cultexp > min.exports,]
  
  #all.metrics2 <<- all.metrics
  return(all.metrics)
}

regress.one.indep <- function(plot.vars,
                              src.name="", # For debug mostly: Twitter/Wikipedia/Books
                              x.title="", # title for X axis
                              y.title="", # title for Y axis
                              plot.y.axis='s', # or 'n'
                              plot.color='black')
  {
  ## bi-variate plot, with two extra dimensions through size and color
  ## plot.vars is a dataframe with the following columns:
  ##  (row.names): used for data point label
  ##  indeps: x-axis: regressor / independent variable of the regression
  ##  deps: y-axis: dependent variable
  ##  size: sizes of the plotted data points
  ##  color: colors of the plotted data points

  # Find the coefficients and intercept.
  s <- with(plot.vars, summary(lm(deps ~ indeps)))
  icept <- s$coefficients[1,1]
  indep.coef <- s$coefficients[2,1]
  r.squared <- s$adj.r.squared
  # How to get the p-value (not stored in the summary), based on (scroll down):
  # http://r.789695.n4.nabble.com/Extract-p-value-from-lm-for-the-whole-model-td1470479.html
  p.val <- pf(s$fstatistic[1], s$fstatistic[2], s$fstatistic[3], lower.tail=F)
  p.val.cat <- classify.p.val(p.val)

  plot.vars$labels <- rownames(plot.vars)
  plot.vars$x.title <- x.title
  plot.vars$y.title <- y.title
  plot.vars$src.name <- src.name

  #### GGPLOT ####
  
  plot.vars$labels <- rownames(plot.vars)
  ggp <- ggplot(plot.vars, aes(x=indeps, y=deps, label=labels)) + 
    geom_point(aes(size=sizes, color=colors)) + # data point fill color
    geom_smooth(method="lm", se=FALSE, color=plot.color) + # regression line
    geom_text(hjust=sizes, vjust=sizes, color="black", size=3.2) + # data point label: position and color
    scale_size(
      limits=c(0.05,1600), # Standardize population scale across plots: 50k to 1.6B ## CHANGE UNLOGGED
      #limits=c(-0.5,3.2), # Standardize population scale across plots: 50k to 1.6B ## CHANGE LOGGED
      range=c(4, 15), 
      name="Millions of Speakers") + 
    scale_color_gradient(
      limits=c(1000,60000), # Standardize GDPpc scale across plots: 1k to 60k
      low="grey91", high=plot.color, name="GDP per Capita") + 
    # axis ranges
    #scale_y_log10() + scale_x_log10(limits=c(0.001,1)) + ## CHANGE UNLOGGED
    scale_y_continuous(limits=c(0,3.5)) + scale_x_continuous(limits=c(-6,0)) + ## CHANGE LOGGED
    labs(list(x=x.title, y=y.title, title=src.name)) +
    geom_text(aes(-1, 0.5, ## CHANGE 
                  label=sprintf("R\UB2 =%s\np-value < %s",
                                round(r.squared, 3),
                                round(p.val.cat, 3))),
              data.frame(r.squared, p.val.cat)) +
    theme_bw() + 
    theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank()) + # remove gridlines
    theme(plot.margin = unit(c(0.2,0.2,0.2,0.2), "cm")) + # `change margins
    theme(legend.position="none") #+ # Remove legend
    #coord_fixed(ratio=0.3) # maintain a square aspect ratio: make sure the squares are of the same size though 
  
  #cat("DONE", src.name, s$adj.r.squared, "\n")
  return(ggp)
}


prep.plot.vars <- function(df.all.metrics,
                           indep, dep, # column names for dep and indep vars, as strings
                           with.na="omit")  { # "omit": remove NA, "zero": change to 0, "nothing": leave as-is) {
  
  plot.vars <- with(df.all.metrics, 
                    data.frame(
                      # get converts a variable's value to a variable's name
                      indeps=get(indep),  # indep. variable
                      deps=get(dep),# dep. variable
                      sizes=  10^pop, #pop, # 10^pop # data point size is population: reversing the log to show the population distribution ## CHANGE
                      colors= 10^gdp.pc,# gdp.pc # 10^gdp.pc  # data point color is GDP pc: reversing the log too ## CHANGE
                      row.names=row.names(df.all.metrics)
                      )
                    )  

  if (with.na=="omit") {
    # Remove NA values
    plot.vars <- na.omit(plot.vars)
  }
  else if (with.na=="zero") {
    # Change NA values to zero
    plot.vars[is.na(plot.vars)] <- 0
  }
  return(plot.vars)
}

plot.regressions <- function(df.all.metrics, outfile="") {
  if (outfile!="") {
    postscript(sprintf("%s.eps", outfile))
  }

  par(mfrow=c(1,3),
      mar=c(0,0,0,0), # margins
      oma=c(0,2.5,0,2.5), # outer margins
      pty="s") # square plotting region
  
  plot.vars.twit <- prep.plot.vars(df.all.metrics,
                                   indep="twit.eig", dep="cultexp",
                                   with.na="omit")
  p.twit <- regress.one.indep(plot.vars.twit,
                    src.name="Twitter",
                    x.title="log10(Twitter EV cent.)", y.title="log10(Popularity)", ## CHANGE
                    plot.y.axis='s', plot.color="red")

  plot.vars.wiki <- prep.plot.vars(df.all.metrics,
                                   indep="wiki.eig", dep="cultexp",
                                   with.na="omit")  
  p.wiki <- regress.one.indep(plot.vars.wiki,
                    src.name="Wikipedia",
                    x.title="log10(Wikipedia EV cent.)", y.title="log10(Popularity)", ## CHANGE
                    plot.y.axis='n', plot.color="forestgreen")

  plot.vars.book <- prep.plot.vars(df.all.metrics,
                                   indep="book.eig", dep="cultexp",
                                   with.na="omit")
  p.book <- regress.one.indep(plot.vars.book,
                    src.name="Books",
                    x.title="log10(Books EV cent.)", y.title="log10(Popularity)", ## CHANGE
                    plot.y.axis='n', plot.color="blue")
  
  PLOT.SIDE.SIZE = 9
  sidebysideplot <- grid.arrange(p.twit, p.wiki, p.book, ncol=3,
                                 widths=unit(c(PLOT.SIDE.SIZE,PLOT.SIDE.SIZE,PLOT.SIDE.SIZE), "cm"),
                                 heights=unit(c(PLOT.SIDE.SIZE,PLOT.SIDE.SIZE,PLOT.SIDE.SIZE), "cm") )
  
  
  if (outfile!="") {
    dev.off()
  }
}

my.ftest <- function(lmA, lmB) {
  # A is the restricted model, B is the unrestriced
  # Calculation done following http://en.wikipedia.org/wiki/F-test#Regression_problems.
  # Reporting done following http://my.ilstu.edu/~jhkahn/apastats.html,
  # e.g.: F(1, 225) = 42.64, p < .001.
  # F-distributions are available here:
  # http://www.itl.nist.gov/div898/handbook/eda/section3/eda3673.htm
  
  # Get the values
  N <- N1 <- nrow(lmA$model); N2 <- nrow(lmB$model)
  p1 <- lmA$rank-1; p2 <- lmB$rank-1
  rsq1 <- summary(lmA)$r.squared; rsq2 <- summary(lmB)$r.squared;
  num.df <- p2-p1 # degrees of freedom - numerator
  denom.df <- N-p2 # degrees of freedom - denominator

  if (N1!=N2) {
    # compare number of observations (I think...) {
    print(c("Number of observations not equal:",N1, N2,"aborting."))
    return(NA)
  }
  
  f.stat <- ((rsq2-rsq1)*(N-p2))/((p2-p1)*(1-rsq2))
  # Get upper-tail probability, i.e., P[X>x]. Equivalent of 1-pf(..)
  p.val <- pf(f.stat, num.df, denom.df, lower.tail=FALSE)
  f.string <- sprintf("F(%s,%s) = %s, p=%s\n", num.df, denom.df, 
                      round(f.stat,2), round(p.val,2))
  # Add debug params
  f.string <- sprintf("%s N=%s p1=%s p2=%s Rsq1=%s Rsq2=%s margin=%s\n",
                    f.string, N, p1, p2, round(rsq1, 3), round(rsq2, 3), round(rsq2-rsq1, 3))
  
  return(f.string)
}

regression.table.multi.source <- function(reg.metrics,
                                          src.name,
                                          outfile="") #
{
  # Create a regression table and save it to a file
  # Combines several different sources
  
  lm1 <<- lm(cultexp ~ pop + gdp.pc, reg.metrics)
  lm2 <<- lm(cultexp ~ twit.eig, reg.metrics)
  lm3 <<- lm(cultexp ~ wiki.eig, reg.metrics)
  lm4 <<- lm(cultexp ~ book.eig, reg.metrics)
  lm5 <<- lm(cultexp ~ pop + gdp.pc + twit.eig, reg.metrics)
  lm6 <<- lm(cultexp ~ pop + gdp.pc + wiki.eig, reg.metrics)
  lm7 <<- lm(cultexp ~ pop + gdp.pc + book.eig, reg.metrics)
#   lm8 <<- lm(cultexp ~ twit.popfrom, reg.metrics)
#   lm9 <<- lm(cultexp ~ wiki.popfrom, reg.metrics)
#   lm10 <<- lm(cultexp ~ book.popfrom, reg.metrics)
#   lm11 <<- lm(cultexp ~ pop + gdp.pc + twit.popfrom, reg.metrics)
#   lm12 <<- lm(cultexp ~ pop + gdp.pc + wiki.popfrom, reg.metrics)
#   lm13 <<- lm(cultexp ~ pop + gdp.pc + book.popfrom, reg.metrics)
#   lm14 <<- lm(cultexp ~ pop + gdp.pc + twit.eig + twit.popfrom, reg.metrics)
#   lm15 <<- lm(cultexp ~ pop + gdp.pc + wiki.eig + wiki.popfrom, reg.metrics)
#   lm16 <<- lm(cultexp ~ pop + gdp.pc + book.eig + book.popfrom, reg.metrics)
  
  mtable123 <<- mtable("Pop+GDPpc"=lm1,
                      "Twit.EV"=lm2, "Wiki.EV"=lm3, "Book.EV"=lm4,
#                       "Twit.PopFrom"=lm8,
#                       "Wiki.PopFrom"=lm9,
#                       "Book.PopFrom"=lm10,
                      "Pop+GDPpc+Twit.EV"=lm5,
                      "Pop+GDPpc+Wiki.EV"=lm6,
                      "Pop+GDPpc+Book.EV"=lm7,
#                       "Pop+GDPpc+Twit.PopFrom"=lm11,
#                       "Pop+GDPpc+Wiki.PopFrom"=lm12,
#                       "Pop+GDPpc+Book.PopFrom"=lm13,
#                       "Pop+GDPpc+Twit.PopFrom+Twit.EV"=lm14,
#                       "Pop+GDPpc+Wiki.PopFrom+Wiki.EV"=lm15,
#                       "Pop+GDPpc+Book.PopFrom+Book.EV"=lm16,
                      summary.stats=c("sigma","R-squared", "adj. R-squared","F","p","N"))

  ### Report results of F-tests  
  ftests.results <- c(
    "Twit.EV margin over Pop+GDPpc: Pop+GDPpc+Twit.EV vs. Pop+GDPpc", my.ftest(lm1, lm5),
    "Wiki.EV margin over Pop+GDPpc: Pop+GDPpc+Wiki.EV vs. Pop+GDPpc", my.ftest(lm1, lm6),
    "Book.EV margin over Pop+GDPpc: Pop+GDPpc+Book.EV vs. Pop+GDPpc", my.ftest(lm1, lm7),
    "Pop+GDPpc margin over Twit.EV: Pop+GDPpc+Twit.EV vs. Twit.EV", my.ftest(lm2, lm5),
    "Pop+GDPpc margin over Wiki.EV: Pop+GDPpc+Wiki.EV vs. Wiki.EV", my.ftest(lm3, lm6), 
    "Pop+GDPpc margin over Book.EV: Pop+GDPpc+Book.EV vs. Book.EV", my.ftest(lm4, lm7)#,
#     "Twit.PopFrom margin over Pop+GDPpc: Pop+GDPpc+Twit.PopFrom vs. Pop+GDPpc", my.ftest(lm1, lm11),
#     "Wiki.PopFrom margin over Pop+GDPpc: Pop+GDPpc+Wiki.PopFrom vs. Pop+GDPpc", my.ftest(lm1, lm12),
#     "Book.PopFrom margin over Pop+GDPpc: Pop+GDPpc+Book.PopFrom vs. Pop+GDPpc", my.ftest(lm1, lm13),
#     "Pop+GDPpc margin over Twit.PopFrom: Pop+GDPpc+Twit.PopFrom vs. Twit.PopFrom", my.ftest(lm8, lm11),
#     "Pop+GDPpc margin over Wiki.PopFrom: Pop+GDPpc+Wiki.PopFrom vs. Wiki.PopFrom", my.ftest(lm9, lm12),
#     "Pop+GDPpc margin over Book.PopFrom: Pop+GDPpc+Book.PopFrom vs. Book.PopFrom", my.ftest(lm10, lm13),
#     "Twit.EV margin over Pop+GDPpc+Twit.PopFrom: Pop+GDPpc+Twit.EV+Twit.PopFrom vs. Pop+GDPpc+Twit.PopFrom", my.ftest(lm11, lm14),
#     "Wiki.EV margin over Pop+GDPpc+Wiki.PopFrom: Pop+GDPpc+Wiki.EV+Wiki.PopFrom vs. Pop+GDPpc+Wiki.PopFrom", my.ftest(lm12, lm15),
#     "Book.EV margin over Pop+GDPpc+Book.PopFrom: Pop+GDPpc+Book.EV+Book.PopFrom vs. Pop+GDPpc+Book.PopFrom", my.ftest(lm13, lm16),
#     "Twit.PopFrom margin over Pop+GDPpc+Twit.EV: Pop+GDPpc+Twit.EV+Twit.PopFrom vs. Pop+GDPpc+Twit.EV", my.ftest(lm5, lm14),
#     "Wiki.PopFrom margin over Pop+GDPpc+Wiki.EV: Pop+GDPpc+Wiki.EV+Wiki.PopFrom vs. Pop+GDPpc+Wiki.EV", my.ftest(lm6, lm15),
#     "Book.PopFrom margin over Pop+GDPpc+Book.EV: Pop+GDPpc+Book.EV+Book.PopFrom vs. Pop+GDPpc+Book.EV", my.ftest(lm7, lm16)
)
  
  if (outfile!="") {
    # Write to files
    write.mtable( mtable123, paste(outfile, "all", "EV",
                                   ".txt", sep="_") )
    write(ftests.results, "ftests_results.txt", sep="\n")
  }
  else {
    # Print to screen
    print(mtable123)
    print(ftests.results)
  }
  
  return(reg.metrics)
}

run.notability.regressions <- function(src.name, # "wiki" / "murray"
                                       date.range, # "all"/"1800_1950"
                                       min.exports=0, # use only langs with at least this many exports
                                       langs.to.remove=NULL, # list of language codes to remove 
                                       add.note="" # a note to add to folder name
                                       ) {
  
  # Old settings: not printed since we decided which thresholds to use.
  #scenario.settings <- sprintf("EV_%s_twcomm%s_bcomm%s_expo%s_pval%s",
  #                             SRC.NAME, MIN.COMMON.USERS, MIN.COMMON.TRANS, MIN.EXPOSURE,
  #                             DESIRED.P.VAL)
  
  # Pick the right filename template
  if (src.name=="wiki") {
    filename.template <- WIKI.FILE.NAME
  }
  else {
    # src.name="murray"
    filename.template <- MURRAY.FILE.NAME
  }
  
  # Find the appropriate files
  lang.cultural.exports.file <- sprintf(filename.template, date.range, "language")
  country.cultural.exports.file <- sprintf(filename.template, date.range, "country")
  
  # This will be used as the name of the folder and the regression table file.
  scenario.settings <- sprintf("%s_%s_ppl%s", src.name, date.range, min.exports)
  
  if (add.note!="") {
    scenario.settings <- sprintf("%s_%s", scenario.settings, add.note)
  }
  
  all.metrics <- prep.lgn.df(TWIT.CENT.FILE, 
                             WIKI.CENT.FILE, 
                             BOOKS.CENT.FILE,
                             LANG.STATS.FILE,
                             min.exports=min.exports,
                             lang.cultural.exports.file,
                             langs.to.remove=langs.to.remove)
  
  ## Prepare to write 
  if (file.exists(scenario.settings)) {
    # delete folder if exists
    unlink(scenario.settings, recursive=TRUE)
  }
  dir.create(scenario.settings)
  orig.dir <- setwd(paste0(POPULARITY.DIR, scenario.settings))
  
  # Use "" to output to screen
  outfile <- scenario.settings
  
  ### TOP 10s ###
  # Print top10 langs by cultural contribution
  top10.file <- paste("top10_", scenario.settings,".txt", sep="")
  
  write.table( subset(all.metrics[order(-all.metrics$cultexp)[1:10],], select=c(cultexp)),
               file=top10.file, append=F, quote=F, sep="\t")
  
  # Print top10 EV centralities
  write.table( subset(all.metrics[order(-all.metrics$twit.eig)[1:10],], select=c(twit.eig)),
               file=top10.file, append=T, quote=F, sep="\t")
  write.table( subset(all.metrics[order(-all.metrics$wiki.eig)[1:10],], select=c(wiki.eig)),
               file=top10.file, append=T, quote=F, sep="\t")
  write.table( subset(all.metrics[order(-all.metrics$book.eig)[1:10],], select=c(book.eig)),
               file=top10.file, append=T, quote=F, sep="\t")
  
  # write country exports
  country.exports <- read.table(country.cultural.exports.file,
                                #row.names=1, # use values from first column
                                header=T, sep="\t", quote="")
  
  # Structure of country export files: country_code  total_exports
  # Write the top 10 by cultural exports to a file
  write.table( country.exports[order(-country.exports[2])[1:11],],
               file=top10.file, append=T, 
               quote=F, sep="\t", row.names=F)
    
  ### REGRESSIONS ###
  # Adjust all metrics by logging where necessary  ### CHANGE
  all.metrics.adj <- with(all.metrics,  
                          data.frame(row.names=rownames(all.metrics),
                            log10(twit.eig), log10(twit.popfrom),
                            log10(wiki.eig), log10(wiki.popfrom), 
                            log10(book.eig), log10(book.popfrom),
                            log10(gdp.pc), log10(pop), log10(cultexp)))
  names(all.metrics.adj) <- names(all.metrics)
  
  ### OR CHANGE
#   all.metrics.adj <- with(all.metrics,  
#                           data.frame(row.names=rownames(all.metrics),
#                                      twit.eig, twit.popfrom,
#                                      wiki.eig, wiki.popfrom, 
#                                      book.eig, book.popfrom,
#                                      gdp.pc, pop, cultexp))
#   names(all.metrics.adj) <- names(all.metrics)
  
  # remove zero values ### CHANGE UNLOGGED
  # all.metrics.adj <- subset(all.metrics.adj, twit.eig!=0 & wiki.eig!=0 & book.eig!=0)

  # Or remove infinite values (log of zero) ## CHANGE LOGGED
  all.metrics.adj <- all.metrics.adj[is.finite(rowSums(all.metrics.adj)), ] 
  
  ## ALL METRICS TABLE
  all.metrics$language <- row.names(all.metrics) 
  write.table(all.metrics, file="all_metrics.tsv", quote=F, row.names=F, sep="\t" )
    
  rm(all.metrics) # remove to avoid mistakes from now on

  print(summary(all.metrics.adj))
  
  # Draw the plots.
  #all.metrics.adj <<- all.metrics.adj
  plot.regressions(all.metrics.adj, outfile)
  
  # Create a regression table for all sources
  regression.table.multi.source(all.metrics.adj, src.name=src.name, outfile=outfile)
  
  # Back to original dir
  setwd(orig.dir)
}

#### MAIN ####

#Three versions for each source (wiki/murray):
#(1) 1800-1950 (2) 1800-1950, min. 1 person (main text) 
#(3) 1800-1950 min. 1 person w/o English

## WIKI

run.notability.regressions(src.name="wiki",
                           date.range="1800_1950",
                           min.exports=0,
                           add.note="" # CHANGE
                           )
run.notability.regressions(src.name="wiki",
                           date.range="1800_1950",
                           min.exports=1,
                           add.note="" # CHANGE
                           )
run.notability.regressions(src.name="wiki",
                           date.range="1800_1950",
                           min.exports=1,
                           langs.to.remove=c("eng"),
                           add.note="noeng" # CHANGE
)


## MURRAY
run.notability.regressions(src.name="murray",
                           date.range="1800_1950",
                           min.exports=0,
                           add.note="" # CHANGE
)
run.notability.regressions(src.name="murray",
                           date.range="1800_1950",
                           min.exports=1,
                           add.note="" # CHANGE
)
run.notability.regressions(src.name="murray",
                           date.range="1800_1950",
                           min.exports=1,
                           langs.to.remove=c("eng"),
                           add.note="noeng" # CHANGE
)