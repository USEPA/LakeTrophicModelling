#' Create parital dependence plot
#' 
#' This function takes the output of randomForest::paritalPlot() and
#' generates a plot via ggplot.
#' 
#' @param pd partial dependence from randomForest::partialPlot()
#' @export
partial_plot <- function(pd,xl,yl,...){
  y_scale<-c(min(pd$y),min(pd$y)+diff(range(pd$y))/2,max(pd$y))
  if(!is.factor(pd$x)){
    ggp<-ggplot(data.frame(pd),aes(x=x,y=y))+
      geom_line()+
      theme(text = element_text(family="sans"),
                        panel.background = element_blank(), panel.grid = element_blank(), 
                        panel.border = element_rect(fill = NA), 
                        plot.title  = element_text(family="sans",size=12,face="bold",
                                                   vjust=1.1),
                        legend.position = "none", legend.key = element_rect(fill = 'white'),
                        legend.text = element_text(family="sans",size=15), 
                        legend.title = element_text(size=11),
                        axis.title.x = element_text(family="sans",vjust = -0.5, size = 12),
                        axis.title.y = element_text(family="sans",vjust = 1.5, size = 12),
                        axis.text.x = element_text(family="sans",size = 10),
                        axis.text.y = element_text(family="sans",size = 10),
                        plot.margin = unit(c(1,1,1,1), "lines"),
                        ...) + 
      labs(x=xl,y=yl)+
      scale_y_continuous(breaks=y_scale,
                         label=round(y_scale,2))
  } else {
    ggp<-ggplot(data.frame(pd),aes(x=x,y=y))+
      geom_bar(stat = "identity")+
      theme(text = element_text(family="sans"),
            panel.background = element_blank(), panel.grid = element_blank(), 
            panel.border = element_rect(fill = NA), 
            plot.title  = element_text(family="sans",size=12,face="bold",
                                       vjust=1.1),
            legend.position = "none", legend.key = element_rect(fill = 'white'),
            legend.text = element_text(family="sans",size=15), 
            legend.title = element_text(size=11),
            axis.title.x = element_text(family="sans",vjust = -0.5, size = 12),
            axis.title.y = element_text(family="sans",vjust = 1.5, size = 12),
            axis.text.x = element_text(angle=50, vjust=0.5,family="sans",size = 11),
            axis.text.y = element_text(family="sans",size = 11),
            plot.margin = unit(c(1,1,1,1), "lines"),
            ...) + 
      labs(x=xl,y=yl)
    
  }
  return(ggp) 
}  

