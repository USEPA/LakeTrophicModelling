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
  preds <- predict(all_rf,newdata=all_dat,predict.all=TRUE)
  class_prob <- apply(preds$individual,2,
                          function(x) cut(x,breaks,labels))
  if(type=="probs"){
    class_prob <- apply(class_prob,1, function(x)
      table(factor(x,levels=labels, ordered=ordered))/rf_obj$ntree)
  } else {
    class_prob <- apply(class_prob,1, function(x)
      table(factor(x,levels=labels, ordered=ordered)))
  }
  
  return(data.frame(t(class_prob)))  
}  