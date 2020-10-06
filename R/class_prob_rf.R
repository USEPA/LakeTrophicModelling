#' Get Class Prediction Probabilities
#' 
#' This function takes a regression randomForest and returns class probabilities
#' for a provided classifcation.  These probabilities are based on a full, new dataset.  
#' If using the dataset used to build the random forest these are not out of
#' bag estimates.  The predicted classes that are output are directly from the random forest object, 
#' thus they are predictions resulting from the out of bag esimates.
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
  
  get_oob_predictions <- function(rf_obj, newdata){
    if(!"inbag" %in% names(rf_obj)){stop("The in bag matrix is not present.  Try re-running random forest with keep.inbag = T.")}
    rf_pred <- predict(rf_obj, newdata = newdata, predict.all = TRUE)
    rf_inbag <- rf_obj$inbag
    rf_inbag[rf_inbag != 0] <- NA
    rf_pred$individual + rf_inbag
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
  class_prob$max <- apply(class_prob[,1:4],1,max)
  class_prob$pred_class_oob <- cut(rf_obj$predicted,breaks,labels)
  class_prob$pred_class <- cut(predict(rf_obj,newdata=newdata), breaks, labels)
  class_prob$obs_class <- cut(rf_obj$y,breaks,labels)
  row.names(class_prob)<-as.character(1:nrow(class_prob))
  oob_pred <- data.frame(get_oob_predictions(rf_obj,newdata))
  oob_class_prob <- apply(oob_pred,2, function(x) cut(x,breaks,labels))
  row.names(oob_class_prob)<-row.names(oob_pred)
  if(type=="probs"){
    oob_class_prob <- apply(oob_class_prob,1, function(x)
      table(factor(x,levels=labels, ordered=ordered))/length(na.omit(oob_class_prob[1,])))
  } else {
    oob_class_prob <- apply(oob_class_prob,1, function(x)
      table(factor(x,levels=labels, ordered=ordered)))
  }
  oob_class_prob<-data.frame(t(oob_class_prob))
  oob_class_prob$nla_id<-row.names(oob_class_prob)
  names(oob_class_prob)[1:4] <- c("oligo_oob", "meso_oob", "eu_oob", 
                                  "hyper_oob")
  class_prob <- left_join(class_prob, oob_class_prob)
  return(class_prob)  
}  