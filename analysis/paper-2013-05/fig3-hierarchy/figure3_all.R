# Plot figure 3 using Degree, Percolation, and Clustering
# Run the degree separately for better values on the y-scale - need to figure this out. 

source("../../figures/load.R", chdir=T)
source("degree/Degree2.R", chdir=T)
source("clustering/Clustering7.R", chdir=T)
source("percolation/Percolation_analysis7.R", chdir=T)

HIERARCHY.DIR <- paste0(FIGURES.ROOT.DIR, "fig3-hierarchy/")
COMP.CONN.MODE <- "weak"
OUTFILE <- "figure3_users500_trans300_exp0.001_v22.eps"
OUTFILE2 <- "figure3_users500_trans300_exp0.001_degreedist_v22.eps"

if (OUTFILE!="") {
  postscript(OUTFILE)
}

par(mfcol=c(3,3), mar=c(0,0,0,0),
    oma=c(1.5,1.5,1.5,1.5), # outer margins)
    pty="s"
    )

# 
### Degree rank
degree.figure(TWIT.STD.LANGLANG, "", 
              min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, max.pval=DESIRED.P.VAL,comp.conn.mode = COMP.CONN.MODE, 
              deg.type="total", 
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")
degree.figure(WIKI.STD.LANGLANG, "", 
              min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE,
              max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE,
              deg.type="total", 
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")
degree.figure(BOOKS.STD.LANGLANG, "",
              min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
              max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE, 
              deg.type="total", 
              user.langs.to.display=25, user.langs.to.label=25,
              src.color="black")
#
### Clustering
clustering.figure(TWIT.STD.LANGLANG, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="n",
                  deg.type="total")
clustering.figure(WIKI.STD.LANGLANG, 
                  min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  plot.x.axis="n",
                  deg.type="total")
clustering.figure(BOOKS.STD.LANGLANG, 
                  min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                  max.pval=DESIRED.P.VAL, plot.xlim=c(0,55),
                  plot.x.axis="s",
                  #x.lab="Connectivity (k)", y.lab="Clustering coefficient (C)",
                  deg.type="total")
# 
### Percolation
percolation.figure(TWIT.STD.LANGLANG, "", 
                   min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE, 
                   max.pval=DESIRED.P.VAL,comp.conn.mode = COMP.CONN.MODE, 
                   deg.type="total", 
                   user.langs.to.display=25, user.langs.to.label=20,
                   plot.x.axis="n",
                   src.color="black")
percolation.figure(WIKI.STD.LANGLANG, "", 
                   min.common=MIN.COMMON.USERS, min.exposure=MIN.EXPOSURE,
                   max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE,
                   deg.type="total", 
                   user.langs.to.display=25, user.langs.to.label=20,
                   plot.x.axis="n",
                   src.color="black")
percolation.figure(BOOKS.STD.LANGLANG, "",
                   min.common=MIN.COMMON.TRANS, min.exposure=MIN.EXPOSURE, 
                   max.pval=DESIRED.P.VAL, comp.conn.mode = COMP.CONN.MODE, 
                   deg.type="total", 
                   user.langs.to.display=25, user.langs.to.label=24,
                   src.color="black")

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