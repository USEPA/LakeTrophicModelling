#' Function to create CDFs of probability for each trophic state prediction
#' 
#' 
#' This functions produces CDF plots from predicted trophic state probabilities   
#' 
#' 
#' @param probs1 prediction probabilities for one of the models
#' @param probs2 prediction probabilities for the other model
#' @param ... pass additional parameters to labs (e.g. set titles, axis labels, etc.)
#' 
#' @examples
#' devtools::install_github('wesanderson','karthik')
#' library(wesanderson)
#' data(LakeTrophicModelling)
#' prob_cdf(all_rf_ts_prob, gis_rf_ts_prob,x="Prediction Probability",y="Proportion of Samples")
#' @export
#' @import ggplot2

prob_cdf <- function(probs1, probs2, ...) {
  df<-rbind(probs1,probs2)
  df <- na.omit(data.frame(df))
  options(scipen = 5)  #tell r not to use scientific notation on axis labels
  x <- ggplot(df,aes(x=max,colour=model)) +
    stat_ecdf(size=2) +
    geom_ribbon(aes(ymin = lower,ymax = upper,fill=model),alpha = 0.4) +
    theme(text = element_text(family="sans"),
          panel.background = element_blank(), #panel.grid = element_blank(), 
          panel.border = element_rect(fill = NA), 
          plot.title  = element_text(family="sans",size=15,face="bold",vjust=1.1),
          legend.key = element_rect(fill = 'white'),
          legend.text = element_text(family="sans",size=15), legend.title = element_text(size=15),
          axis.title.x = element_text(family="sans",vjust = -0.5, size = 12),
          axis.title.y = element_text(family="sans",vjust = 1.5, size = 12),
          axis.text.x = element_text(family="sans",size = 11),
          axis.text.y = element_text(family="sans",size = 11)) + 
    geom_hline(linetype = 3, size = 1, colour = "gray", 
               yintercept = c(0,0.5,1)) +
    labs(...) + 
    scale_colour_manual(name='',values = viridis(2)) +
    scale_fill_manual(name='',values = viridis(2))
    return(x)        
}                 
