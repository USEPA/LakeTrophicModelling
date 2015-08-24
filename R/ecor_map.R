#' Create map of Ecoregions
#' 
#' Function to generate Map 1 in hkm2014ESA poster
#' 
#' @param states data for states, as data.frame
#' @param lakes point locations for lake samples as data.frame
#' @param myColor vector of length 3 with colors for fill, lines, and points in that order
#' 
#' @examples
#' wsa9<-readOGR("../inst/extdata/","wsa9_low48")
#' ecor_map(wsa9)
#' @export
#' @import ggplot2
ecor_map<-function(ecor){
  #browser()
  #borrowed from: https://github.com/hadley/ggplot2/wiki/plotting-polygon-shapefiles#workaround-forced-layering-of-geom_plot
  ecor@data$id <- rownames(ecor@data)
  ecor_f <- fortify(ecor, region="WSA_9")
  names(ecor_f)[which(names(ecor_f)=="id")] = "WSA_9"
  ecor_df <- plyr::join(ecor_f, ecor@data, by="WSA_9")
  gmap<-ggplot(ecor_df, aes(long,lat,group=group,fill=id)) +
    geom_polygon(data=subset(ecor_df,WSA_9!="WMT")) +
    geom_polygon(data=subset(ecor_df,WSA_9=="WMT")) +
    geom_path(color="white") +
    coord_equal() +
    coord_map("albers", lat2 = 45.5, lat1 = 29.5)+
    theme(panel.background = element_rect(fill="white"), panel.grid = element_blank(),
          panel.border = element_blank(), #legend.position = "none",
          axis.text = element_blank(),axis.ticks = element_blank()) +
    ylab("") +
    xlab("")
  return(gmap)
}