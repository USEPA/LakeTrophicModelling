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
#' condAccuracy(all_rf_ts_prob,gis_rf_ts_prob,xImpair=0,R=1,xlab="Xc >= Prediction Probability")
condAccuracy<-function(pred_prob1,pred_prob2,xlab="x",...){
  #devtools::install_github("jhollist/condprob2")
  max_vote<-pred_prob1$max
  obs<-pred_prob1$obs_class
  pred<-pred_prob1$pred_class
  correct<-pred==obs
  cp1<-condprob2::condprob(max_vote,correct,ProbComp="gt",Exceed="gte",...)
  max_vote<-pred_prob2$max
  obs<-pred_prob2$obs_class
  pred<-pred_prob2$pred_class
  correct<-pred==obs
  cp2<-condprob2::condprob(max_vote,correct,ProbComp="gt",Exceed="gte",...)
  #plot(cp$max_vote,cp$Raw.Data.Probability)
  cp1<-data.frame(max_vote=cp1$max_vote,Raw.Data.Probability=cp1$Raw.Data.Probability)
  cp2<-data.frame(max_vote=cp2$max_vote,Raw.Data.Probability=cp2$Raw.Data.Probability)
  ggplot(cp1,aes(x=max_vote,y=Raw.Data.Probability))+
    geom_point(size=2,color="red")+
    geom_point(data=cp2,aes(x=max_vote,y=Raw.Data.Probability),size=2,color="black") +
    theme(text = element_text(family="sans"),
          panel.background = element_blank(), #panel.grid = element_blank(), 
          panel.border = element_rect(fill = NA), 
          plot.title  = element_text(family="sans",size=15,face="bold",vjust=1.1),
          legend.position = "none", legend.key = element_rect(fill = 'white'),
          legend.text = element_text(family="sans",size=15), legend.title = element_text(size=15),
          axis.title.x = element_text(family="sans",vjust = -0.5, size = 12),
          axis.title.y = element_text(family="sans",vjust = 1.5, size = 12),
          axis.text.x = element_text(family="sans",size = 11),
          axis.text.y = element_text(family="sans",size = 11)) + 
    labs(y="Conditional Total Accuracy",x=xlab)
}