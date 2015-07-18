#' convert table to df
#' 
#' @param cm_tab a table class with confusion matrix
#' 
#' @export
table_to_df <- function(cm_tab){
  nc <- ncol(cm_tab)
  nr <- nrow(cm_tab)
  df<-data.frame(matrix(cm_tab[1:(nc*nr)],ncol=nc,nrow=nr))
  names(df)<-attributes(cm_tab)[[2]][[1]]
  row.names(df)<-names(df)
  return(df)
}
