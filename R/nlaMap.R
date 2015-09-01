#' Create map of NLA samples
#' 
#' Function to generate Map 1 in hkm2014ESA poster
#' 
#' @param states data for states, as data.frame
#' @param lakes point locations for lake samples as data.frame
#' @param cats plot ts categories?
#' @param myColor vector of length 3 with colors for fill, lines, and points in that order
#' 
#' @examples
#' state<-map_data('state')
#' lakes_alb<-data.frame(ltmData[["AlbersX"]],ltmData[["AlbersY"]])
#' p4s<-"+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" 
#' ll<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" 
#' lakes_alb_sp<-SpatialPoints(coordinates(lakes_alb),proj4string=CRS(p4s))
#' lakes_dd<-spTransform(lakes_alb_sp,CRS=CRS(ll))
#' lakes_dd<-data.frame(coordinates(lakes_dd))
#' names(lakes_dd)<-c("long","lat")
#' nlaMap(state,lakes_dd)
#' @export
#' @import ggplot2
nlaMap<-function(states,lakes,cats=F,myColor=1:3,catColor=NULL){
  #Color Blind Friendly Palette
  if(cats){
    gmap<-ggplot(states,aes(x=long,y=lat))+
      geom_polygon(aes(group=group),fill=myColor[2],colour=myColor[1])+
      geom_point(data=lakes,aes(x=long,y=lat,color=factor(data)),size=2.5)+
      scale_color_manual(values=catColor,
                         name="Trophic\nState",
                         breaks=c("Oligo", "Meso", "Eu","Hyper"),
                         labels=c("Oligotrophc", "Mesotrophic", "Eutrophic","Hypereutrophic"))+
      coord_map("albers", lat2 = 45.5, lat1 = 29.5) +
      theme(panel.background = element_rect(fill="white"), panel.grid = element_blank(), 
            panel.border = element_blank(),
            axis.text = element_blank(),axis.ticks = element_blank(),
            legend.key.width=unit(2, "line"), 
            legend.key.height=unit(0.5, "line"),
            legend.position="bottom", legend.direction="horizontal") + 
      ylab("") + 
      xlab("")
  } else {
  gmap<-ggplot(states,aes(x=long,y=lat))+
               geom_polygon(aes(group=group),fill=myColor[2],colour=myColor[1])+
               geom_point(data=lakes,aes(x=long,y=lat),size=2.5,colour=myColor[3])+
               coord_map("albers", lat2 = 45.5, lat1 = 29.5)+
               theme(panel.background = element_rect(fill="white"), panel.grid = element_blank(), 
                     panel.border = element_blank(), legend.position = "none", 
                     axis.text = element_blank(),axis.ticks = element_blank()) + 
               ylab("") + 
               xlab("")
  }
  return(gmap)
}