#' Create map of trophic state probabilities
#' 
#' This function takes the predicted class probabilites and maps them for each trophic 
#' state.
#' 
#' @param states data for states, as data.frame
#' @param lakes point locations for lake samples as data.frame with NLA ID
#' @param probs class probabilites with NLA ID
#' 
#' @examples
#' state<-map_data('state')
#' lakes_alb<-data.frame(ltmData[["AlbersX"]],ltmData[["AlbersY"]],
#'                       ltmData[["NLA_ID"]])
#' p4s<-"+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" 
#' ll<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" 
#' lakes_alb_sp<-SpatialPointsDataFrame(coordinates(lakes_alb[,1:2]),proj4string=CRS(p4s),
#'                                      data=data.frame(nla_id = as.character(lakes_alb[,3])))
#' lakes_dd<-spTransform(lakes_alb_sp,CRS=CRS(ll))
#' lakes_dd<-data.frame(coordinates(lakes_dd),lakes_dd$nla_id)
#' names(lakes_dd)<-c("long","lat","nla_id")
#' ts_prob_map(state,lakes_dd,gis_rf_ts_prob)
#' @export
#' @import ggplot2
ts_prob_map<-function(states,lakes,probs,save_sep=FALSE){
  lakes<-merge(lakes,probs,by="nla_id")
  gmap_o<-make_ts_map(states,lakes,"Oligotrophic",high=viridis(4)[1])#"#08519c")
  gmap_m<-make_ts_map(states,lakes,"Mesotrophic",high=viridis(4)[2])#"#756bb1")
  gmap_e<-make_ts_map(states,lakes,"Eutrophic", high=viridis(4)[3])#"#e6550d")
  gmap_h<-make_ts_map(states,lakes,"Hypereutrophic", high=viridis(4)[4])#"#de2d26")
  gmap_m$theme$plot.margin <- grid::unit(c(0,0,0,-2),"line")
  gmap_h$theme$plot.margin <- grid::unit(c(0,0,0,-2),"line")
  gmap_o$theme$plot.margin <- grid::unit(c(0,-2,0,0),"line")
  gmap_e$theme$plot.margin <- grid::unit(c(0,-2,0,0),"line")
  if(save_sep){
    ggsave("oligo_prob.jpg",gmap_o,width=8.5)
    ggsave("meso_prob.jpg",gmap_m,width=8.5)
    ggsave("eu_prob.jpg",gmap_e,width=8.5)
    ggsave("hyper_prob.jpg",gmap_h,width=8.5)
  }
  
  return(multiplot(gmap_o,gmap_e,gmap_m,gmap_h,cols=2))
}

#' helper function to generate each map
#' 
#' @param states the states
#' @param lake_prob merged lake and prob data
#' @param title title of map
#' @param low lower color
#' @param high higher color
#' @export
make_ts_map <- function(states,lake_prob,title,low,high){

  if(title=="Oligotrophic"){value<<-"oligo"}
  if(title=="Mesotrophic"){value<<-"meso"}
  if(title=="Eutrophic"){value<<-"eu"}
  if(title=="Hypereutrophic"){value<<-"hyper"}
  gmap<-ggplot(states,aes(x=long,y=lat))+
    geom_point(data=lake_prob,aes_string(x="long",y="lat",colour=value),size=2.5)+
    geom_polygon(aes(group=group),alpha=0,colour="grey")+
    coord_map("albers", lat2 = 45.5, lat1 = 29.5)+
    theme(panel.background = element_rect(fill="white"), panel.grid = element_blank(), 
          panel.border = element_blank(),
          axis.text = element_blank(),axis.ticks = element_blank(),
          plot.margin = grid::unit(c(0,0,0,0),"line"),
          legend.key.width=unit(2, "line"), 
          legend.key.height=unit(0.5, "line"),
          legend.position = c(0.5,-0.1), legend.direction="horizontal") + 
    ggtitle(title)+
    ylab("") + 
    xlab("") +
    scale_colour_gradient("Probability",low="white",high=high,
                          breaks=c(0.2,0.4,0.6,0.8))
  return(gmap)
}