#' getLakeIDs
#' 
#' This function retrieves the lake IDs for each of the rf objects
#' 
#' @param indVar independent variables
#' @param depVar dependent variable
#' @param id vector of IDS, same length and order as indVar and 
#' 
#' @examples
#' data(LakeTrophicModelling)
#' x2<-iterVarSelRF(ltmData[predictors_gis],ltmData$TS_CHLA_4,10,4,ntree=10,ntreeIterat=5,
#' vars.drop.frac=NULL,vars.drop.num=1,time=FALSE)
#' x2_vars<-unique(unlist(x2))
#' gis_ts4_rf<-runRandomForest(ltmData[x2_vars],ltmData$TS_CHLA_4)
#' @export
#' 
getLakeIDs <- function(indVar, depVar, id) {
  
  # Only Pass Complete Cases
  comp_case <- complete.cases(indVar, depVar)
  if (length(indVar) > 1) {
    indVar <- indVar[comp_case, ]
  } else {
    indVar <- indVar[comp_case]
  }
  depVar <- depVar[comp_case]
  
  
  return(id[comp_case])
  
} 
