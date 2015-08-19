#' Scatterplot for hkm2014esa poster
#' 
#' Produces a scatterplot via ggplot
#' 
#' @examples
#' devtools::install_github("wesanderson","jhollist")
#' library('wesanderson')
#' data(LakeTrophicModelling)
#' mydf<-data.frame(chla=ltmData[["CHLA"]],biovp1=ltmData[["sumBioV"]]+1)
#' zissou2<-wes.palette(5,"Zissou2")
#' scatterPlot(mydf,xvar="chla",yvar="biovp1",zissou2[3],zissou2[2],zissou2[1],
#'             title="Chlorophyll and Cyanobacterai Relationship",
#'             x=expression(paste('Log10(Chl ', italic("a"),')')),
#'             y="Log10(Cyanobaterial Abundance + 1)")
#' @export
#' @import ggplot2

scatterPlot<-function(df,xvar,yvar,pt_col,ln_col,cl_col,...){
  options(scipen=5)
  xdf<-data.frame(xvar=df[[xvar]],yvar=df[[yvar]])
  xdf<-xdf[complete.cases(xdf),]
  xlm<-summary(lm(log10(yvar+1)~log10(xvar+1),data=xdf))
  xlm_r<-paste0("Adj. R-squared = ", round(xlm$adj.r.squared,2))
  xlm_p<-paste0("p-value = ", format(pf(xlm$fstatistic[1],
                                         xlm$fstatistic[2],
                                         xlm$fstatistic[3],lower.tail=FALSE),
                                      scientific=TRUE))              
  
  
  x <- ggplot(xdf,aes(xvar,yvar))+
    geom_point(size=3,colour=pt_col) +
    scale_x_log10() +
    scale_y_log10() +
    #stat_smooth(method="lm",fill=cl_col,
    #            colour=ln_col,size=2) + 
    #annotate("text", x = 0.25, y = 100000000, label = xlm_r) +
    #annotate("text", x = 0.285, y = 20000000, label = xlm_p) +
    theme(text = element_text(family="sans"),
          panel.background = element_blank(), panel.grid = element_blank(), 
          panel.border = element_rect(fill = NA), 
          plot.title  = element_text(family="sans",size=12,face="bold",vjust=1.1),
          legend.position = "none", legend.key = element_rect(fill = 'white'),
          legend.text = element_text(family="sans",size=15), legend.title = element_text(size=11),
          axis.title.x = element_text(family="sans",vjust = -0.5, size = 12),
          axis.title.y = element_text(family="sans",vjust = 1.5, size = 12),
          axis.text.x = element_text(family="sans",size = 11),
          axis.text.y = element_text(family="sans",size = 11)) + 
    labs(...)
    
  return(x)
}