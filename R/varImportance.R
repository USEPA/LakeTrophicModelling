#' Variable Importance Summary
#' 
#' @param rf_imp a Random Forest Importance Object
#' @param label A label for the model
#' @export
varImportance<-function(rf_imp,label=NULL){

  if(!is.null(label)){
    xdf<-data.frame(model_id=rep(label,nrow(rf_imp)),
             variable_names=row.names(rf_imp),
             mean_decrease_acc=rf_imp[,1],
             mean_decrease_gini=rf_imp[,2])
  } else {
    xdf<-data.frame(model_id=rep(NA,nrow(rf_imp)),
                                 variable_names=row.names(rf_imp),
                                 mean_decrease_acc=rf_imp[,1],
                                 mean_decrease_gini=rf_imp[,2])
  }   
  return(xdf)
}