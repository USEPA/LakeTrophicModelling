#' Create map of discrete predicted probabilities
#' 
#' This function takes the predicted class probabilites and maps them for the
#' predicted class
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
#' pred_prob_map(state,lakes_dd,gis_rf_ts_prob)
#' @export
#' @import ggplot2
pred_prob_map<-function(states,lakes,probs,save_sep=FALSE){
  lakes<-merge(lakes,probs,by="nla_id")
  value<-"max"
  title<-"Predicted Probability"
  low<-"#E0EEEE"
  high<-"#00688B"
  mid_pt<-mean(range(lakes$max))
  gmap<-ggplot(states,aes(x=long,y=lat))+
    geom_polygon(aes(group=group),fill="white",colour="grey")+
    geom_point(data=lakes,aes_string(x="long",y="lat",colour=value),size=3.5)+
    coord_map("albers", lat2 = 45.5, lat1 = 29.5)+
    theme(panel.background = element_rect(fill="white"), panel.grid = element_blank(), 
          panel.border = element_blank(), 
          axis.text = element_blank(),axis.ticks = element_blank(),
          plot.margin = grid::unit(c(0,0,0,0),"inches")) + 
    ggtitle(title)+
    ylab("") + 
    xlab("") +
    scale_colour_gradient2("Probability",midpoint = mid_pt) +
    guides(fill = guide_legend(
      title.theme = element_text(size=10),
      keywidth = 0.5, keyheight = 0.5
    ))
  return(gmap)
}
