#' Get Class Prediction Probabilities
#' 
#' This function takes a regression randomForest and returns class probabilities
#' for a provided classifcation
#' 
#' @param rf_obj a randomForest object of type regression
#' @param newdata data frame used to make predictions. Can be same as original
#'                data.  
#' @param breaks a numeric vector of values used to turn predictions into classes
#' @param labels a character vector of labels for the classes
#' @param ordered logical indicating if categories are ordered (in order specified 
#'                in labels)
#' @param type a character vector indicating whether total votes or probabilites
#'              should be returned
#' @return returns a dataframe of probabilites or number of votes for each class
#' @export
class_prob_rf <- function(rf_obj,newdata,breaks,labels,ordered=FALSE,
                             type=c("probs","votes")){
  if(rf_obj$type!="regression"){
    stop("rf_obj is not a regression randomForest object.")
  }
  type <- match.arg(type)
  preds <- predict(rf_obj,newdata=newdata,predict.all=TRUE)
  preds_df <- data.frame(preds$individual)
  class_prob <- apply(preds_df,2, function(x) cut(x,breaks,labels))
  row.names(class_prob)<-row.names(preds_df)
  if(type=="probs"){
    class_prob <- apply(class_prob,1, function(x)
      table(factor(x,levels=labels, ordered=ordered))/rf_obj$ntree)
  } else {
    class_prob <- apply(class_prob,1, function(x)
      table(factor(x,levels=labels, ordered=ordered)))
  }
  class_prob<-data.frame(t(class_prob))
  class_prob$nla_id<-row.names(class_prob)
  row.names(class_prob)<-as.character(1:nrow(class_prob))
  return(class_prob)  
}  