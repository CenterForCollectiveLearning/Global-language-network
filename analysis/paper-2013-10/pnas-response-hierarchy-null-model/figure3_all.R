# Plot figure 3 using Degree, Percolation, and Clustering
# Run the degree separately for better values on the y-scale - need to figure this out. 

source("../load.R", chdir=T)
source("degree/Degree2.R", chdir=T)
source("clustering/Clustering7.R", chdir=T)
source("percolation/Percolation_analysis7.R", chdir=T)

HIERARCHY.DIR <- paste0(ANALYSIS.ROOT.DIR, "fig3-hierarchy/")
COMP.CONN.MODE <- "weak"

OUTFILE <- "figure3_null_model_ev_undirected_v35.pdf"
#OUTFILE2 <- "figure3_observed_degreedist_v35.pdf"

CONVERT.TO.UNDIRECTED <- T

twitter.langlang <- "table3a_null_model_twit.tsv"
wiki.langlang <- "table3a_null_model_wiki.tsv"
books.langlang <- "table3a_null_model_book.tsv"

# twitter.langlang <- TWIT.STD.LANGLANG
# wiki.langlang <- WIKI.STD.LANGLANG
# books.langlang <- BOOKS.STD.LANGLANG


if (OUTFILE!="") {
  pdf(OUTFILE)
}

par(mfcol=c(3,3), mar=c(3,3,3,3),
    oma=c(1.5,1.5,1.5,1.5), # outer margins)
    pty="s"
    )

# 
### Degree rank
degree.figure(twitter.langlang, "", 
              min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
              max.pval=DESIRED.P.VAL,comp.conn.mode = COMP.CONN.MODE, # change to strong?
              plot.xlim=c(0,27), plot.ylim=c(0,60),
              convert.to.undirected=CONVERT.TO.UNDIRECTED,
              deg.type="total", title.text="Twitter degree rank",
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")
degree.figure(wiki.langlang, "", 
              min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE,
              max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE,
              plot.xlim=c(0,27), plot.ylim=c(0,60),
              convert.to.undirected=CONVERT.TO.UNDIRECTED,
              deg.type="total", title.text="Wiki degree rank",
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")
degree.figure(books.langlang, "",
              min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
              max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE, 
              plot.xlim=c(0,27), plot.ylim=c(0,70),
              convert.to.undirected=CONVERT.TO.UNDIRECTED,
              deg.type="total", title.text="Books degree rank",
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")

#
### EV
ev.figure(twitter.langlang, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,70),plot.ylim=c(0.1,1),
                  convert.to.undirected=CONVERT.TO.UNDIRECTED,
                  title.text="Twitter EV-connectivity",
                  x.lab="Connectivity (k)", y.lab="EV",
                  deg.type="total")
ev.figure(wiki.langlang, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,70),plot.ylim=c(0.1,1),
                  convert.to.undirected=CONVERT.TO.UNDIRECTED,
                  title.text="Wiki EV-connectivity",
                  x.lab="Connectivity (k)", y.lab="EV",
                  deg.type="total")
ev.figure(books.langlang, 
                  min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,70),plot.ylim=c(0.1,1),
                  convert.to.undirected=CONVERT.TO.UNDIRECTED,
                  title.text="Books EV-connectivity",
                  x.lab="Connectivity (k)", y.lab="EV",
                  deg.type="total")

# #
# ### Clustering
# clustering.figure(twitter.langlang, 
#                   min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
#                   max.pval=DESIRED.P.VAL, plot.xlim=c(0,90),
#                   convert.to.undirected=CONVERT.TO.UNDIRECTED,
#                   title.text="Twitter hierarchy",
#                   x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
#                   deg.type="total")
# clustering.figure(wiki.langlang, 
#                   min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
#                   max.pval=DESIRED.P.VAL, plot.xlim=c(0,90),
#                   convert.to.undirected=CONVERT.TO.UNDIRECTED,
#                   title.text="Wiki hierarchy",
#                   x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
#                   deg.type="total")
# clustering.figure(books.langlang, 
#                   min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
#                   max.pval=DESIRED.P.VAL, plot.xlim=c(0,90),
#                   convert.to.undirected=CONVERT.TO.UNDIRECTED,
#                   title.text="Books hierarchy",
#                   x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
#                   deg.type="total")
# 
### Percolation
percolation.figure(twitter.langlang, "", 
                   min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                   max.pval=DESIRED.P.VAL,comp.conn.mode = COMP.CONN.MODE, 
                   convert.to.undirected=CONVERT.TO.UNDIRECTED, 
                   deg.type="total", title.text="Twitter percolation",
                   user.langs.to.display=25, user.langs.to.label=20,
                   src.color="black")
percolation.figure(wiki.langlang, "", 
                   min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE,
                   max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE,
                   convert.to.undirected=CONVERT.TO.UNDIRECTED, 
                   deg.type="total", title.text="Wiki percolation",
                   user.langs.to.display=25, user.langs.to.label=20,
                   src.color="black")
percolation.figure(books.langlang, "",
                   min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                   max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE,
                   convert.to.undirected=CONVERT.TO.UNDIRECTED, 
                   deg.type="total", title.text="Books percolation",
                   user.langs.to.display=25, user.langs.to.label=24,
                   src.color="black")

if (OUTFILE!="") {
  dev.off()
}

stop("skip degree distribution")

if (OUTFILE2!="") {
  pdf(OUTFILE2)
}

par(mfrow=c(3,2), mar=c(4,2,2,2),
    oma=c(1,1,1,1), # outer margins)
    pty="s"
)

# Degree distrubtion (cumulative and non-cumulative)
degree.figure(TWIT.STD.LANGLANG.NULL, "", 
              plot.rank=FALSE,
              min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
              max.pval=DESIRED.P.VAL,comp.conn.mode = COMP.CONN.MODE, 
              convert.to.undirected=F, 
              deg.type="total", 
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")
degree.figure(WIKI.STD.LANGLANG.NULL, "", 
              plot.rank=FALSE,
              min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE,
              max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE,
              convert.to.undirected=F, 
              deg.type="total", 
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")
degree.figure(BOOKS.STD.LANGLANG.NULL, "", 
              plot.rank=FALSE,
              min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
              max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE, 
              convert.to.undirected=F, 
              deg.type="total", 
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")

if (OUTFILE2!="") {
  dev.off()
}