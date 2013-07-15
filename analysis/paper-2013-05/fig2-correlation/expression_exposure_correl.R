# TODO: use all links, not just common links. 
# TODO: ADD EXPRESSIONS CORRELATION PLOTS!
# assign '0' if a link doesnt exist.

source("../../figures/load.R", chdir=T)
library(ggplot2)
library(gridExtra)

OUTFILE <- "express_correl.eps"
OUTFILE2 <- "exposure_correl.eps"

plot.scatter.and.fit <- function(x.val, y.val, 
                                 limxy, # limits for X and Y
                                 x.axt="s", # line shouldn't go beyond plot area
                                 print.settings="", # show passed settings on top figure
                                 x.lab.text="", y.lab.text="",
                                 plot.color="black") {
  # Scatterplot the values
  plot(x.val, y.val, xlab=x.lab.text, ylab=y.lab.text, 
       xlim=limxy, ylim=limxy,
       pch=16, cex=2, col=plot.color, xaxt=x.axt)
  
  # Get regression summary and fit line
  reg.lm <- lm(y.val ~ x.val)
  reg.sum <- summary(reg.lm)
  print(reg.sum) # debug printout
  abline(reg.lm)
  # Add R-sq 
  legend("bottomright", bty="n", legend=paste("R\U0B2=", round(reg.sum$adj.r.sq,3)))
  
  # Add title
  legend("topleft", bty="n", legend=print.settings)
}

ggplot.scatter.and.fit <- function(all.data, x.val, y.val, reg.lm, limxy, plot.color="black") {
  # TODO: adjusted limits!!!!
  
  r.sq <- round(summary(reg.lm)$adj.r.squared,3)
  
  ggp <- ggplot(all.data, aes_string(x=x.val, y=y.val, aes(label=row.names))) + 
    geom_point(color="black", size=4) + # data point line color
    geom_smooth(method="lm", se=FALSE, color=plot.color) + # regression line
    #geom_text(hjust=sizes, vjust=sizes, color="black", size=3.2) + # data point label: position and color
    #labs(list(x=x.title, y=y.title, title=src.name)) +
    geom_text(aes(1e7, 0.5, label=sprintf("R\UB2 =%s",r.sq)),
              data.frame(r.sq))+
    scale_x_log10(limits=limxy) + scale_y_log10(limits=limxy) +
    geom_vline(xintercept = 15) +
    theme_bw() + 
    theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank()) + # remove gridlines
    theme(plot.margin = unit(c(0.2,0.2,0.2,0.2), "cm")) + # change margins
    theme(legend.position="none") # + # Remove legend
    #coord_fixed(ratio=0.3) # maintain a square aspect ratio: make sure the squares are of the same size though
  
  return(ggp)
}

plot.corrlation.fig <- function(twit.df, wiki.df, books.df,limxy=c(1.3,8.3)) {
  # merge the three tables
  all.df <<- merge(twit.df, wiki.df, by.x=0, by.y=0)
  rownames(all.df) <<- all.df$Row.names
  all.df$Row.names <<- NULL
  all.df <<- merge(all.df, books.df, by.x=0, by.y=0)
  rownames(all.df) <<- all.df$Row.names
  all.df$Row.names <<- NULL
  
  # plot
  par(mfrow=c(1,3), pty="s", oma=c(2,2,2,2), mar=c(0,0,0,0))
  plot.scatter.and.fit(log10(all.df$val.twit),
                       log10(all.df$val.wiki),
                       lim=limxy,
                       x.axt="s", y.lab.text="T-W",
                       print.settings=sprintf("exp>=%s pval<%s comm=%s-%s",
                                              MIN.EXPOSURE, DESIRED.P.VAL, 
                                              MIN.COMMON.USERS, MIN.COMMON.TRANS))
  
  plot.scatter.and.fit(log10(all.df$val.twit),
                       log10(all.df$val.books),
                       lim=limxy,
                       x.axt="s", y.lab.text="T-B")
  plot.scatter.and.fit(log10(all.df$val.wiki),
                       log10(all.df$val.books),
                       lim=limxy,
                       y.lab.text="W-B")
  
  ## TODO: ggplot code for future use!
#   print(ggplot.scatter.and.fit(all.df, "val.twit", "val.wiki", tw.lm, limxy=c(0.1,1e8)))
#   
#   PLOT.SIDE.SIZE = 9
#   sidebysideplot <- grid.arrange(p.twit, p.wiki, p.book, ncol=3,
#                                  widths=unit(c(PLOT.SIDE.SIZE,PLOT.SIDE.SIZE,PLOT.SIDE.SIZE), "cm"),
#                                  heights=unit(c(PLOT.SIDE.SIZE,PLOT.SIDE.SIZE,PLOT.SIDE.SIZE), "cm") )
#   
}

#### MAIN ####

# load data
if (OUTFILE!="") {
  postscript(OUTFILE)
}

# EXPRESSIONS:
# Read data using default filters, get only the num of expressions column,
# and give it a standard name
twitter.nodes <- read.nodelist(TWIT.STD.LANGINFO, 
                               col.select=c("num.exps"))
colnames(twitter.nodes) <- "val.twit" # there's only one column!
wikipedia.nodes <- read.nodelist(WIKI.STD.LANGINFO, 
                                 col.select=c("num.exps"))
colnames(wikipedia.nodes) <- "val.wiki"
books.nodes <- read.nodelist(BOOKS.STD.LANGINFO, 
                             col.select=c("trans.from"))
colnames(books.nodes) <- "val.books"

plot.corrlation.fig(twitter.nodes, wikipedia.nodes, books.nodes)

if (OUTFILE2!="") {
  dev.off()
}

# EXPOSURE:
# Read data using default filters, get only the num of expressions column,
# and give it a standard name
# load data
if (OUTFILE2!="") {
  postscript(OUTFILE2)
}

twitter.links <- read.filtered.edgelist(TWIT.STD.LANGLANG, 
                                        min.common=MIN.COMMON.USERS,
                                        col.select=c("exposure"))
colnames(twitter.links) <- "val.twit" # there's only one column!
wikipedia.links <- read.filtered.edgelist(WIKI.STD.LANGLANG, 
                                          min.common=MIN.COMMON.USERS,
                                          col.select=c("exposure"))
colnames(wikipedia.links) <- "val.wiki"
books.links <- read.filtered.edgelist(BOOKS.STD.LANGLANG, 
                                      min.common=MIN.COMMON.TRANS,
                                      col.select=c("exposure"))
colnames(books.links) <- "val.books"

plot.corrlation.fig(twitter.links, wikipedia.links, books.links, limxy=c(-3,0))

if (OUTFILE2!="") {
  dev.off()
}