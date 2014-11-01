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
#' scatterPlot(mydf,xvar="chla",yvar="biovp1",zissou2[3],zissou[2],zissou[1],
#'             title="Chlorophyll and Cyanobacterai Relationship",
#'             x=expression(paste('Log10(Chl ', italic("a"),')')),
#'             y="Log10(Cyanobaterial Biovolumes + 1)")
#' @export
#' @import ggplot2

scatterPlot<-function(df,xvar,yvar,pt_col,ln_col,cl_col,...){
  options(scipen=5)
  xdf<-data.frame(xvar=df[[xvar]],yvar=df[[yvar]])
  xdf<-xdf[complete.cases(xdf),]

  x <- ggplot(xdf,aes(xvar,yvar))+
    geom_point(size=2,colour=pt_col) +
    scale_x_log10() +
    scale_y_log10() +
    stat_smooth(method="lm",fill=cl_col,
                colour=ln_col,size=2) +
    theme(text = element_text(family="serif"),
          panel.background = element_blank(), panel.grid = element_blank(), 
          panel.border = element_rect(fill = NA), 
          plot.title  = element_text(family="serif",size=12,face="bold",vjust=1.1),
          legend.position = "none", legend.key = element_rect(fill = 'white'),
          legend.text = element_text(family="serif",size=15), legend.title = element_text(size=11),
          axis.title.x = element_text(family="serif",vjust = -0.5, size = 12),
          axis.title.y = element_text(family="serif",vjust = 1.5, size = 12),
          axis.text.x = element_text(family="serif",size = 11),
          axis.text.y = element_text(family="serif",size = 11)) + 
    labs(y="log10(Cyanobacteria Biovolume + 1)",...)
  return(x)
}