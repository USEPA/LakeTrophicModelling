% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scatterPlot.R
\name{scatterPlot}
\alias{scatterPlot}
\title{Scatterplot for hkm2014esa poster}
\usage{
scatterPlot(df, xvar, yvar, pt_col, ln_col, cl_col, ...)
}
\description{
Produces a scatterplot via ggplot
}
\examples{
devtools::install_github("wesanderson","jhollist")
library('wesanderson')
data(LakeTrophicModelling)
mydf<-data.frame(chla=ltmData[["CHLA"]],biovp1=ltmData[["sumBioV"]]+1)
zissou2<-wes.palette(5,"Zissou2")
scatterPlot(mydf,xvar="chla",yvar="biovp1",zissou2[3],zissou2[2],zissou2[1],
            title="Chlorophyll and Cyanobacterai Relationship",
            x=expression(paste('Log10(Chl ', italic("a"),')')),
            y="Log10(Cyanobaterial Abundance + 1)")
}
