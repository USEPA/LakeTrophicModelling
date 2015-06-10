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
#' all_dat <- all_dat[complete.cases(all_dat),]
#' x<-varsel_regression_rf(all_dat$LogCHLA,all_dat[,names(all_dat)!="LogCHLA"],
#'                         ntree=100)
varsel_regression_rf <- function(y,x,...){
  out <- list(mse=NULL,rsq=NULL,num_var=NULL,vars=NULL)
  dat <- data.frame(y=y,x)
  init_rf <- randomForest(y=dat$y,x=dat[,names(x)],...)
  init_imp <- importance(init_rf)
  var_sort <- rownames(init_imp)[order(init_imp[,1],decreasing = TRUE)]
  vars <- NULL
  for(i in var_sort){
    if(is.null(vars)){ 
      vars <- c(vars,i) 
      idx <- 1
    } else {
      vars <- c(vars,i)
      vars_rf <- randomForest(y=dat$y,x=dat[,vars],...)
      out$mse[[idx]] <- vars_rf$mse[length(vars_rf$mse)]
      out$rsq[[idx]] <- vars_rf$rsq[length(vars_rf$rsq)]
      out$num_var[[idx]] <- length(vars)
      out$vars[[idx]] <- vars
      idx <- idx + 1
    }
    print(paste(idx/length(var_sort),"% completed"))
  }
  return(out)
}