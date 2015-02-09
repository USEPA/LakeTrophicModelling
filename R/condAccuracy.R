#' Plot conditional accuracy
#' 
#' This function plots the total accuracy as a function of maximum probability. 
#' We determine the maximum probability for each lake for a given random forest
#' object and then plot the total accuracy for lakes at each value of x or greater
#' 
#' @param rf A random forest object
#' @param ... parameters to be passed to condprob
#' @export
#' @import ggplot2
#' @examples
#' condAccuracy(gis_ts4_rf,xImpair=0,R=1,xlab="Maximum Vote Probability")
condAccuracy<-function(rf,xlab="x",...){
  #devtools::install_github("jhollist/condprob2")
  max_vote<-apply(rf$votes,1,max)
  obs<-rf$y
  pred<-factor(rf$predicted,levels=unique(obs),ordered=is.ordered(obs))
  correct<-pred==obs
  cp<-condprob2::condprob(max_vote,correct,ProbComp="gt",Exceed="gte",...)
  #plot(cp$max_vote,cp$Raw.Data.Probability)
  cp<-data.frame(cp$max_vote,cp$Raw.Data.Probability)
  
  ggplot(cp,aes(x=cp.max_vote,y=cp.Raw.Data.Probability))+
    geom_point()+
    theme(text = element_text(family="serif"),
          panel.background = element_blank(), #panel.grid = element_blank(), 
          panel.border = element_rect(fill = NA), 
          plot.title  = element_text(family="serif",size=15,face="bold",vjust=1.1),
          legend.position = "none", legend.key = element_rect(fill = 'white'),
          legend.text = element_text(family="serif",size=15), legend.title = element_text(size=15),
          axis.title.x = element_text(family="serif",vjust = -0.5, size = 12),
          axis.title.y = element_text(family="serif",vjust = 1.5, size = 12),
          axis.text.x = element_text(family="serif",size = 11),
          axis.text.y = element_text(family="serif",size = 11)) + 
    labs(y="Conditional Total Accuracy",x=xlab)
}