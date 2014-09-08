#' sumTable
#' 
#' Function to summarize the output of iterVarSelRF into a percentage of the time a given
#' variable was selected by varSelRF.  Outputs md via kable
#' 
#' @param tsList  list of just the selected variable (i.e. truncate list by 5 if time=T in 
#'                iterVarSelRF)
#' 
#' @export

sumTable <- function(tsList) {
    summDF <- data.frame()
    uniqueVar <- unique(unlist(tsList))
    for (i in uniqueVar) {
        summDF <- rbind(summDF, data.frame(Variable = i, 
            Percent = sum(unlist(tsList) %in% i)/length(tsList)))
    }
    summDF <- summDF[order(summDF$Percent, decreasing = T), 
        ]
    return(summDF)
} 
