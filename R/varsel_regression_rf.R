#' Variable Selection with Regression RF
#' 
#' Similar approach to varSelRF, but for regresssion.  Use full model to rank
#' variables based on %IncMSE.  Step through that list with most important first
#' run RF, store variables and %MSE of model.
#' @param y response a vector 
#' @param x predictors a data.frame
#' @param ... options to pass to randomForest
#' @export
#' @import randomForest
#' @examples
#' data(LakeTrophicModelling)
#' predictors_all <- predictors_all[predictors_all!="DATE_COL"]
#' all_dat <- data.frame(ltmData[predictors_all],LogCHLA=log10(ltmData$CHLA))
#' all_dat <- all_cf_dat[complete.cases(all_cf_dat),]
#' x<-varsel_regression_rf(all_dat$LogCHLA,all_cf_dat[,names(all_cf_dat)!="LogCHLA"])
varsel_regression_rf <- function(y,x,...){
  out <- list()
  dat <- data.frame(y=y,x)
  init_rf <- randomForest(y~.,data=dat,...)
  init_imp <- importance(init_rf)
  browser()
  for(i in 1:n){
  }
}