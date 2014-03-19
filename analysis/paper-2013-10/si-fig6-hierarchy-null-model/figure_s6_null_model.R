# Plot figure 3 using Degree, Percolation, and Clustering
# Run the degree separately for better values on the y-scale - need to figure this out. 

source("../load.R", chdir=T)
source("clustering/Clustering8.R", chdir=T)

HIERARCHY.DIR <- paste0(ANALYSIS.ROOT.DIR, "fig3-hierarchy/")
COMP.CONN.MODE <- "weak"
OUTFILE <- "fig_s6_hierarchy_null_model_v35.eps"
#OUTFILE <- ""

compute.null.model <- function(infile, src.name, keep.orig=T) {
  # Open the standard langlang tables and compute expected exposures,
  # which are the exposures we get if we assume that the 
  # number of bilinguals is N1N2/Ntotal. 
  # Use keep.orig=T to add the expected common.num and exposure as 
  # new columns, and F to replace the original columns with the expecte
  # values
  
  x.edgelist <- read.csv(infile, sep="\t",header=T)
  
  # expected number of common users / translations
  common.expected <- as.numeric(x.edgelist$src.num)*as.numeric(x.edgelist$tgt.num)/x.edgelist$total.num
  exposure.expected <- common.expected / x.edgelist$tgt.num
  
  if (keep.orig==T) {
    x.edgelist$common.num.exp <- common.expected
    x.edgelist$exposure.exp <- as.numeric(exposure.expected)
  }
  else {
    # replace the observed values
    x.edgelist$common.num <- common.expected
    x.edgelist$exposure <- as.numeric(exposure.expected)
  }
  
  # write new table
  if (keep.orig==F) {
    tbl.filename <- sprintf("table3a_null_model_%s.tsv", src.name)
  }
  else {
    tbl.filename <- sprintf("table3a_null_model_with_orig_%s.tsv", src.name)
  }
  write.table(x.edgelist, file=tbl.filename,
              sep="\t", quote=F, row.names=F, na="")
  return(tbl.filename)
}

# compute expected common.num and exposure according to the null model
twit.langlang.expected <- compute.null.model(TWIT.STD.LANGLANG, "twit", keep.orig=F)
wiki.langlang.expected <- compute.null.model(WIKI.STD.LANGLANG, "wiki", keep.orig=F)
book.langlang.expected <- compute.null.model(BOOKS.STD.LANGLANG, "book", keep.orig=F)

# for reference, redo and keep original values -- save to disk
compute.null.model(TWIT.STD.LANGLANG, "twit", keep.orig=T)
compute.null.model(WIKI.STD.LANGLANG, "wiki", keep.orig=T)
compute.null.model(BOOKS.STD.LANGLANG, "book", keep.orig=T)


if (OUTFILE!="") {
  postscript(OUTFILE)
}

par(mfrow=c(3,3), mar=c(2,2,2,2),
    oma=c(1,1,1,1), # outer margins)
    pty="s"
    )


### Clustering
clustering.figure(TWIT.STD.LANGLANG, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="s", deg.type="total", title.text="Twitter O")
clustering.figure(WIKI.STD.LANGLANG, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="s", deg.type="total", title.text="Wiki O")
clustering.figure(BOOKS.STD.LANGLANG, 
                  min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,70),
                  plot.x.axis="s",
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  deg.type="total", title.text="Books O")

clustering.figure(twit.langlang.expected, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="s", deg.type="total", title.text="Twitter E")
clustering.figure(wiki.langlang.expected, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="s", deg.type="total", title.text="Wiki E")
clustering.figure(book.langlang.expected, 
                  min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,70),
                  plot.x.axis="s",
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  deg.type="total", title.text="Books E")

clustering.figure.diff(TWIT.STD.LANGLANG, twit.langlang.expected, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="s", deg.type="total", title.text="Twitter")
clustering.figure.diff(WIKI.STD.LANGLANG, wiki.langlang.expected, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="s", deg.type="total", title.text="Wiki")
clustering.figure.diff(BOOKS.STD.LANGLANG, book.langlang.expected, 
                  min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,70),
                  plot.x.axis="s",
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  deg.type="total", title.text="Books")


if (OUTFILE!="") {
  dev.off()
}