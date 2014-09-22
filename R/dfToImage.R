#' dfToImage
#' 
#' This function will take a data.frame, convert it to a table, style it with 
#' CSS (optional) and save as an image file.
#' 
#' @param df the data.frame to convert 
#' @param file the output image file to save to include file type in the 
#'        extension.  Have tested , 'png', and 'jpg'
#' @param style the path/name for the style sheet.
#' @param width width of output image.  defaults to 1024.
#' @param include.rownames logical to print or not the row names.
#' @param format.args list of formatC paramaters to control formating of text
#' @param keepHTML Logical if html file should be saved (best for troubleshooting
#'                  the css styling)
#' @param ... parameters passed through to \code{\link{xtable}}.  For instance,
#'            allows use of \code{caption} option. 
#' 
#' @examples
#' dfToImage(head(mtcars),'test.jpg')
#' 
#' @export
dfToImage <- function(df, file, style = NULL, width = 1024, 
    include.rownames = FALSE, keepHTML = FALSE, ...) {
    tmpfile <- paste(tempfile(, tmpdir = getwd()), 
        ".html", sep = "")
    print(xtable(df, ...), type = "html", file = tmpfile, 
        include.rownames = include.rownames)
    if (!is.null(style)) {
        csslink <- paste("<link rel='stylesheet' href='", 
            style, "' type='text/css' />\n", sep = "")
        fileConn <- file(tmpfile, open = "r+")
        Lines <- readLines(fileConn)
        writeLines(c(csslink, Lines), con = fileConn)
        close(fileConn)
    }
    system(paste("wkhtmltoimage --quality 100 --width", 
        width, tmpfile, file, sep = " "))
    if (!keepHTML) {
        system(paste("rm", tmpfile))
    }
} 
