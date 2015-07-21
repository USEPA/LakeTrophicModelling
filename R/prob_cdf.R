#' Function to create CDFs of probability for each trophic state prediction
#' 
#' 
#' This functions produces CDF plots from predicted trophic state probabilities   
#' 
#' 
#' @param probs the continuous Variable such as-'sumBioV','CHLA', 'NTL', 'PTL', etc.  Of same 
#'                length as contVar 
#' @param cdf_colors colors for CDF plots and median line -should equal # of categories in catVar + 1
#' @param ... pass additional parameters to labs (e.g. set titles, axis labels, etc.)
#' 
#' @examples
#' devtools::install_github('wesanderson','karthik')
#' library(wesanderson)
#' data(LakeTrophicModelling)
#' 
#' @export
#' @import ggplot2

prob_cdf <- function(probs cdf_colors = 1:length(catVar), ...) {

    options(scipen = 5)  #tell r not to use scientific notation on axis labels
    
    keep<-complete.cases(catVar,contVar)
    cdf_df<-data.frame(catVar,contVar)[keep,]
    x <- ggplot(cdf_df,aes(contVar,colour=catVar)) +
          stat_ecdf(size=2)+scale_color_manual(values=cdf_colors)+
          scale_x_log10()+
          theme(text = element_text(family="Times"),
                panel.background = element_blank(), panel.grid = element_blank(), 
                panel.border = element_rect(fill = NA), 
                plot.title  = element_text(family="sans",size=12,face="bold",vjust=1.1),
                legend.position = c(0.15,0.75), legend.key = element_rect(fill = 'white'),
                legend.text = element_text(family="sans",size=15), legend.title = element_text(family="sans",size=11),
                axis.title.x = element_text(family="sans",vjust = -0.5, size = 12),
                axis.title.y = element_text(family="sans",vjust = 1.5, size = 12),
                axis.text.x = element_text(family="sans",size = 11),
                axis.text.y = element_text(family="sans",size = 11)) + 
          geom_hline(linetype = 3, size = 1, colour = "gray", 
                     yintercept = c(0,0.5,1)) +
          labs(...)
    return(x)        
} 
