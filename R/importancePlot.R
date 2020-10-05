#' Random Forest Variable Importance Plotting
#' 
#' @param rf a randomForest object
#' @param type the type of importance to plot "acc" for Mean Decrease Accuracy, and 
#'              "gini for Mean Decrease Gini.
#' @param ... any items that can be passed to geom_point.  Mostly used to control size
#'            and color of points.
#' 
#' @export
#' @import ggplot2
#' @examples
#' require(wesanderson)
#' data(iris)
#' iris_rf<-randomForest(iris[,1:4],iris[,5],importance=T,proximity=T)
#' importancePlot(iris_rf,'acc',size=10,aes(colour=wes.palette(4, 'GrandBudapest')))
#' importancePlot(iris_rf,'gini',size=10,aes(colour=wes.palette(4, 'GrandBudapest')))

importancePlot <- function(rf, sumtbl=NULL, data_def = NULL, type = c("acc", "gini"), ...) {
    
    idf<-importance(rf)
    browser()
    # set up data.frame for ggplot
    if (type == "gini") {
        imp_df <- data.frame(variables = names(idf[,dim(idf)[2]]), 
                             Mean_Decrease = idf[,dim(idf)[2]])
        o <- order(imp_df$Mean_Decrease, decreasing = FALSE)
        imp_df$variables <- factor(imp_df$variables, 
            levels = imp_df$variables[o], ordered = T)
        label <- "Mean Decrease Gini"
    } else if (type == "acc") {
        imp_df <- data.frame(variables = names(idf[,dim(idf)[2]-1]), 
                             Mean_Decrease = idf[,dim(idf)[2]-1])
      o <- order(imp_df$Mean_Decrease, decreasing = FALSE)
      imp_df$variables <- factor(imp_df$variables, 
                                 levels = imp_df$variables[o], ordered = T)
        label <- "Percent Increase in Mean Square Error"
    } else {
        stop("Type not specificed correctly")
    }
    if(!is.null(sumtbl)){
      imp_df<-merge(imp_df,sumtbl,by.x="variables",by.y="Variable")
    } 
    if (!is.null(data_def)){
      imp_df$variables<-data_def$description[match(imp_df$variables,data_def$variable_names)]
      o <- order(imp_df$Mean_Decrease, decreasing = FALSE)
      imp_df$variables <- factor(imp_df$variables, 
                                 levels = imp_df$variables[o], ordered = T)
      ylabels <- as.character(imp_df$variables[o])
      ylabels[19] <- expression(paste("Total Phosphorus (", mu, "g/L)",sep=""))
      ylabels[18] <- expression(paste("Total Nitrogen (", mu, "g/L)",sep=""))
    }
    
    x <- ggplot(imp_df, aes(Mean_Decrease, variables)) + 
         geom_point(...) +   
         geom_hline(linetype = 3, size = 1, colour = "gray", 
                 yintercept = 1:nlevels(imp_df$variables)) + 
         geom_point(...) +
         theme(text = element_text(family="Times"),
               panel.background = element_blank(), panel.grid = element_blank(), 
               panel.border = element_rect(fill = NA), legend.position = "none", 
               axis.title.x = element_text(family="sans",face = "bold", vjust = -0.5, size = 12), 
               axis.text = element_text(family="sans",size = 11,color = "black")) + 
         ylab("") + 
         xlab(label) +
         scale_y_discrete(labels=ylabels)
      
    return(x)
} 
