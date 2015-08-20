#' density plot for lake trophic modeling paper
#' 
#' Produces a density plot via ggplot
#' 
#' @examples
#' density_plot(gis_rf_ts_prob,xvar="max",x="Predicted Probability")
#' @export
#' @import ggplot2

density_plot<-function(df,xvar,...){
  options(scipen=5)
  xdf<-data.frame(xvar=df[[xvar]])
  x <- ggplot(xdf,aes(x=xvar))+
    geom_density() +
    theme(text = element_text(family="sans"),
          panel.background = element_blank(),
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