# rating.R
# fits and plots a power-law rating curve.
# incorporates a simple method to find "good"
# starting values for the parameters
#
# NB - requires package Hmisc - must be installed prior to running
#      this script

require(Hmisc)

dat = read.csv("http://www.geog.ubc.ca/~rdmoore/08GA071.csv")
attach(dat)
logq = log10(q)

##########################################################
# determine good starting values for parameters 
# by setting h0 to a value slightly below minimum
# observed stage
##########################################################

hmin = min(stage)
hmax = max(stage)
cstart = hmin - 0.1*(hmax - hmin)
start.lm = lm( logq ~ log10(stage - cstart) )
astart = start.lm$coefficients[1]
bstart = start.lm$coefficients[2]


#####################################################
# use nls to determine optimal parameters 
#####################################################

mod.nls = nls( logq ~ a + b*log10(stage - c), start = list(a=astart,b=bstart,c=cstart) )


#######################################################
# plot rating curve with error bars (+/- 10%)
#######################################################

xmin = min(stage)
xmax = max(stage)
dx = 0.01*(xmax - xmin)
x = seq(xmin,xmax,dx)
b = coef(mod.nls)
qhat = 10^(b[1] + b[2]*log10(x - b[3]))
qplus = 1.1*q
qminus = 0.9*q
plot(stage,q,
     xlab = "Stage (m)", 
         ylab = expression("Q ("*m^3*s^{-1}*")"),
         pch = 21, bg = "black",
         main = "08GA071 Stage-Discharge Relation"
         )
lines(x,qhat,col="red")  
errbar(stage,q,qplus,qminus,add=TRUE)
