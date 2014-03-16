# Plot figure 3 using Degree, Percolation, and Clustering
# Run the degree separately for better values on the y-scale - need to figure this out. 

source("../load.R", chdir=T)
source("degree/Degree3.R", chdir=T)
source("clustering/Clustering8.R", chdir=T)
source("percolation/Percolation_analysis8.R", chdir=T)

HIERARCHY.DIR <- paste0(ANALYSIS.ROOT.DIR, "fig3-hierarchy/")
COMP.CONN.MODE <- "weak"
OUTFILE <- "figure3_users500_trans300_exp0.001_v35.eps"
OUTFILE2 <- "figure3_users500_trans300_exp0.001_degreedist_v35.eps"

compute.expected.exposures <- function(infile, src.name) {
  # Open the standard langlang tables and compute expected exposures,
  # which are the exposures we get if we assume that the 
  # number of bilinguals is N1N2/Ntotal.
  
  x.edgelist <- read.csv(infile, sep="\t",header=T)
  
  # expected number of common users / translations
  x.edgelist$common.num.exp <- as.numeric(x.edgelist$src.num)*as.numeric(x.edgelist$tgt.num)/x.edgelist$total.num
  
  # expected exposure
  x.edgelist$exposure.exp <-x.edgelist$common.num.exp / x.edgelist$tgt.num
  
  # write new table
  tbl.filename <- sprintf("table3a_hierarchy_expected_exposure_%s.tsv", src.name)
  write.table(x.edgelist, file=tbl.filename,
              sep="\t", quote=F, row.names=F, na="")
  return(tbl.filename)
}

# Get expected exposures
twit.langlang.expected <- compute.expected.exposures(TWIT.STD.LANGLANG, "twit")
wiki.langlang.expected <- compute.expected.exposures(WIKI.STD.LANGLANG, "wiki")
book.langlang.expected <- compute.expected.exposures(BOOKS.STD.LANGLANG, "book")

if (OUTFILE!="") {
  postscript(OUTFILE)
}

par(mfcol=c(3,3), mar=c(0,0,0,0),
    oma=c(1.5,1.5,1.5,1.5), # outer margins)
    pty="s"
    )

# 
# ### Degree rank
# degree.figure(TWIT.STD.LANGLANG, "", 
#               min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, max.pval=DESIRED.P.VAL,comp.conn.mode = COMP.CONN.MODE, 
#               deg.type="total", 
#               user.langs.to.display=25, user.langs.to.label=25,
#               src.color="black")
# degree.figure(WIKI.STD.LANGLANG, "", 
#               min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE,
#               max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE,
#               deg.type="total", 
#               user.langs.to.display=25, user.langs.to.label=25,
#               src.color="black")
# degree.figure(BOOKS.STD.LANGLANG, "",
#               min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
#               max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE, 
#               deg.type="total", 
#               user.langs.to.display=25, user.langs.to.label=25,
#               src.color="black")

#
### Clustering
clustering.figure(twit.langlang.expected, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  weight.column="exposure.exp",
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="n",
                  deg.type="total")
clustering.figure(wiki.langlang.expected, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  weight.column="exposure.exp",
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="n",
                  deg.type="total")
clustering.figure(book.langlang.expected, 
                  min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  weight.column="exposure.exp",
                  plot.x.axis="s",
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  deg.type="total")
# 
### Percolation
# percolation.figure(TWIT.STD.LANGLANG, "", 
#                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
#                    max.pval=DESIRED.P.VAL,comp.conn.mode = COMP.CONN.MODE, 
#                    deg.type="total", 
#                    user.langs.to.display=25, user.langs.to.label=20,
#                    plot.x.axis="n",
#                    src.color="black")
# percolation.figure(WIKI.STD.LANGLANG, "", 
#                    min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE,
#                    max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE,
#                    deg.type="total", 
#                    user.langs.to.display=25, user.langs.to.label=20,
#                    plot.x.axis="n",
#                    src.color="black")
# percolation.figure(BOOKS.STD.LANGLANG, "",
#                    min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
#                    max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE, 
#                    deg.type="total", 
#                    user.langs.to.display=25, user.langs.to.label=24,
#                    src.color="black")

if (OUTFILE!="") {
  dev.off()
}

if (OUTFILE2!="") {
  postscript(OUTFILE2)
}

par(mfrow=c(3,2), mar=c(4,2,2,2),
    oma=c(1,1,1,1), # outer margins)
    pty="s"
)

# Degree distrubtion (cumulative and non-cumulative)
degree.figure(TWIT.STD.LANGLANG, "", 
              plot.rank=FALSE,
              min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
              max.pval=DESIRED.P.VAL,comp.conn.mode = COMP.CONN.MODE, 
              deg.type="total", 
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")
degree.figure(WIKI.STD.LANGLANG, "", 
              plot.rank=FALSE,
              min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE,
              max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE,
              deg.type="total", 
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")
degree.figure(BOOKS.STD.LANGLANG, "", 
              plot.rank=FALSE,
              min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
              max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE, 
              deg.type="total", 
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")

if (OUTFILE2!="") {
  dev.off()
}