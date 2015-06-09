#' Cross Validate Random Forests to get Categorical Accuracy
#'
#' Funtion to cross-validate categorical prediction accuracy from 
#' resultant chl a.  A Random forest of forests...  Used to get categorical
#' accuracy.  Also returns a cross-validated accuracy of % var explained.
#' 
#' @param y response a vector 
#' @param x predictors a data.frame
#' @param breaks numeric vector of cut points
#' @param cat categories of response
#' @param split proportion to include in training datset.  test set to inverse.
#' @param n number of iterations
#' @import broom party
#' @export
#' @examples
#' data(LakeTrophicModelling)
#' predictors_all <- predictors_all[predictors_all!="DATE_COL"]
#' all_cf_dat <- data.frame(ltmData[predictors_all],LogCHLA=log10(ltmData$CHLA))
#' all_cf_dat <- all_cf_dat[complete.cases(all_cf_dat),]
#' ts_brks <- c(min(all_cf_dat$LogCHLA),log10(2),log10(7),log10(30),max(all_cf_dat$LogCHLA))
#' ts_cats <- c("oligo","meso","eu","hyper")
#' x<-crossval_rf(all_cf_dat$LogCHLA,all_cf_dat[,names(all_cf_dat)!="LogCHLA"],
#'             ts_brks,ts_cats,0.8,100,100)
crossval_rf <- function(y,x, breaks, cat=NULL, split, n, ntree){
  out <- list(summary=NULL,acc=NULL,all=list())
  dat <- data.frame(y=y,x)
  for(i in 1:n){
    train_idx <- sample(1:nrow(dat),split*nrow(dat))
    test_idx <-!1:nrow(dat)%in%train_idx
    dat_train <-dat[train_idx,] 
    dat_test <-dat[test_idx,]
    cf_train <- cforest(y~., dat=dat_train,
                        control=cforest_unbiased(ntree=ntree,
                                                 mtry=ncol(dat_train)/3))
    cf_pred_test <- as.numeric(predict(cf_train,newdata=dat_test))
    cf_orig_test <- dat_test$y
    cf_pred_test_cat <- cut(cf_pred_test,breaks,cat)
    cf_orig_test_cat <- cut(dat_test$y,breaks,cat)
    out$acc$rmse[[i]]<-glance(lm(cf_pred_test~cf_orig_test))$sigma
    out$acc$adjrsq[[i]]<-glance(lm(cf_pred_test~cf_orig_test))$adj.r.squared
    out$acc$tot_acc[[i]]<-classAgreement(table(cf_pred_test_cat,cf_orig_test_cat))$diag
    out$acc$kappa[[i]]<-classAgreement(table(cf_pred_test_cat,cf_orig_test_cat))$kappa
    out$all[[i]]<-list(cf_pred_test=cf_pred_test,
                   cf_orig_test=cf_orig_test,
                   cf_pred_test_cat=cf_pred_test_cat,
                   cf_orig_test_cat=cf_orig_test_cat)
  }
  out$summary <- list(mean_rmse = mean(out$acc$rmse),
                      mean_adjrs = mean(out$acc$adjrsq),
                      mean_tot_acc = mean(out$acc$tot_acc),
                      mean_kappa = mean(out$acc$kappa))
  return(out)
}