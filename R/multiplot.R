#' Create Mulitple Plots with ggplots (from Winston Chang)
#' 
#' This is the Multiple plot function from 
#' \href{http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)}{R-Cookbook}.  
#' I have merely cleaned up some of the params for my use, added some documentation and examples.
#' 
#' @param ... can pass ggplot objects 
#' @param plotlist alternative to ..., list of ggplot objects
#' @param cols Number of columns in layout
#' @param layout A matrix specifying the layout. If present, 'cols' is ignored.
#' If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
#' then plot 1 will go in the upper left, 2 will go in the upper right, and
#' 3 will go all the way across the bottom.
#' 
#' @examples
#' x<-rnorm(100)
#' y<-jitter(x,10000)
#' img <- readJPEG(system.file('img', 'Rlogo.jpg', package='jpeg'))
#' xdf<-data.frame(x=x,y=y)
#' firstplot<-ggplot(xdf,aes(x=x,y=y))+ geom_point()
#' secondplot<-ggplot(xdf,aes(x=x))+ geom_bar()
#' thirdplot<-ggplot(xdf, aes(x,y)) + 
#' annotation_custom(rasterGrob(img, width=unit(1,'npc'), height=unit(1,'npc')), 
#'                  -Inf, Inf, -Inf, Inf)
#' thirdplot
#' svg("test.svg",width=8)
#' multiplot(thirdplot,secondplot,firstplot,firstplot,layout=matrix(c(1,2,3,4),ncol=4,byrow=F))
#' dev.off()
#' 
#' @export
#' @import ggplot2

multiplot <- function(..., plotlist = NULL, cols = 1, 
    layout = NULL) {
    require(grid)
    
    # Make a list from the ... arguments and plotlist
    plots <- c(list(...), plotlist)
    
    numPlots = length(plots)
    
    # If layout is NULL, then use 'cols' to determine
    # layout
    if (is.null(layout)) {
        # Make the panel ncol: Number of columns of plots
        # nrow: Number of rows needed, calculated from # of
        # cols
        layout <- matrix(seq(1, cols * ceiling(numPlots/cols)), 
            ncol = cols, nrow = ceiling(numPlots/cols))
    }
    
    if (numPlots == 1) {
        print(plots[[1]])
        
    } else {
        # Set up the page
        grid.newpage()
        pushViewport(viewport(layout = grid.layout(nrow(layout), 
            ncol(layout))))
        
        # Make each plot, in the correct location
        for (i in 1:numPlots) {
            # Get the i,j matrix positions of the regions that
            # contain this subplot
            matchidx <- as.data.frame(which(layout == 
                i, arr.ind = TRUE))
            
            print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row, 
                layout.pos.col = matchidx$col))
        }
    }
} 
