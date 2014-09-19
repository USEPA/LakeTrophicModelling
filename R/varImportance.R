#' Variable Importance Summary
#' 
#' @param rf Random Forest Object
#' @param label A label for the model
#' @export
varImportance<-function(rf,label=NULL){
  if(!is.null(label)){
    xdf<-data.frame(model_id=rep(label,dim(rf$importance)[1]),
             variable_names=row.names(rf$importance),
             mean_decrease_acc=data.frame(rf$importance)$MeanDecreaseAccuracy,
             mean_decrease_gini=data.frame(rf$importance)$MeanDecreaseGini)
  } else {
    xdf<-data.frame(model_id=rep(NA,dim(rf$importance)[1]),
                    variable_names=row.names(rf$importance),
                    mean_decrease_acc=data.frame(rf$importance)$MeanDecreaseAccuracy,
                    mean_decrease_gini=data.frame(rf$importance)$MeanDecreaseGini)
  }   
  return(xdf)
}