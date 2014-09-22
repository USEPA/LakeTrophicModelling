#' plotCDF Function to create CDFs of chla, ts, and cyano
#' 
#' 
#' This functions produces CDF plots from the hkm2014Data.  The implementation may be used more 
#' widely though to create cumulative distribution functions for multiple categories   
#' 
#' @param catVar the categorical Variable such as-'bvCat', 'TS_CHLA_2', 'TS_CHLA_3', 'TS_CHLA_4'.  
#'               Of same length as contVar 
#' @param contVar the continuous Variable such as-'sumBioV','CHLA', 'NTL', 'PTL', etc.  Of same 
#'                length as contVar 
#' @param cdf_colors colors for CDF plots and median line -should equal # of categories in catVar + 1
#' @param ... pass additional parameters to labs (e.g. set titles, axis labels, etc.)
#' 
#' @examples
#' devtools::install_github('wesanderson','karthik')
#' library(wesanderson)
#' data(hkm2014Data)
#' plotCdf(hkm2014Data$bvCat,hkm2014Data$CHLA,cdf_colors=wes.palette(3,'Royal1'),y='Percent',
#'         x=expression(paste('Log10(Chl ', italic("a"),')')),title='CDF for category bvCat',
#'         color="Biovolume\nCategories")
#' plotCdf(hkm2014Data$TS_CHLA_3,hkm2014Data$sumBioV+1,cdf_colors=wes.palette(3,'FantasticFox'),
#'         y='Percent',x='Log10(Cyanobacterial Biovolume)',
#'         title=expression(paste('CDF for Chlorophyll ', italic("a"),' Trophic States (3 Categories)')),
#'         color="Trophic State\nCategories")
#' 
#' @export
#' @import ggplot2

plotCdf <- function(catVar, contVar, cdf_colors = 1:length(catVar), ...) {

    options(scipen = 5)  #tell r not to use scientific notation on axis labels
    
    keep<-complete.cases(catVar,contVar)
    cdf_df<-data.frame(catVar,contVar)[keep,]
    x <- ggplot(cdf_df,aes(contVar,colour=catVar)) +
          stat_ecdf(size=2)+scale_color_manual(values=cdf_colors)+
          scale_x_log10()+
          theme(text = element_text(family="Times"),
                panel.background = element_blank(), panel.grid = element_blank(), 
                panel.border = element_rect(fill = NA), 
                plot.title  = element_text(family="serif",size=22,face="bold",vjust=1.1),
                legend.position = c(0.11,0.8), legend.key = element_rect(fill = 'white'),
                legend.text = element_text(family="serif",size=15), legend.title = element_text(family="serif",size=15),
                axis.title.x = element_text(family="serif",vjust = -0.5, size = 20),
                axis.title.y = element_text(family="serif",vjust = 1.5, size = 20),
                axis.text.x = element_text(family="serif",size = 15),
                axis.text.y = element_text(family="serif",size = 15)) + 
          geom_hline(linetype = 3, size = 1, colour = "gray", 
                     yintercept = c(0,0.5,1)) +
          labs(...)
    return(x)        
} 
