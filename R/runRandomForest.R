#' runRandomForest
#' 
#' This function takes the output of iterVarSelRF and runs a random forest. 
#' 
#' @param indVar independent variables
#' @param depVar dependent variable
#' @param ntree to be passed to randomForest.  Had trouble getting ... to work with the snowfall wrapper 
#'              function.  This was a quick hack.
#' @param importance  to be passed to randomForest.  Had trouble getting ... to work with the snowfall wrapper 
#'                    function.  This was a quick hack.
#' @param proximity to be passed to randomForest.  Had trouble getting ... to work with the snowfall wrapper 
#'                  function.  This was a quick hack.
#' 
#' @examples
#' data(hkm2014Data)
#' x2<-iterVarSelRF(hkm2014Data[predictors_gis],TS_CHLA_4,10,4,ntree=10,ntreeIterat=5,
#' vars.drop.frac=NULL,vars.drop.num=1,time=FALSE)
#' x2_vars<-unique(unlist(x2))
#' gis_ts4_rf<-runRandomForest(hkm2014Data[x2_vars],TS_CHLA_4, ntree=10,importance=TRUE,proximity=TRUE)
#' @export
runRandomForest <- function(indVar, depVar, ntree = 100, 
    importance = TRUE, proximity = TRUE) {
    
    # Only Pass Complete Cases
    comp_case <- complete.cases(indVar, depVar)
    if (length(indVar) > 1) {
        indVar <- indVar[comp_case, ]
    } else {
        indVar <- indVar[comp_case]
    }
    depVar <- depVar[comp_case]
    
    
    return(randomForest(indVar, depVar, ntree = ntree, 
        importance = importance, proximity = proximity))
    
} 
