#' Kolmogrov-Smirnoff CIs for a ecdf
#' 
#' Code from sfsmisc::ecdf.KSci. Ammended here to simply output the xy for both upper and 
#' lower for use as input to ggplot
#' @export
#' @examples
#' ecdf_ks_ci(all_pred_prob)
ecdf_ks_ci <- function(x){
  n <- length(x)
  ec <- ecdf(x)
  xx <- get("x", envir = environment(ec))
  yy <- get("y", envir = environment(ec))
  D <- sfsmisc::KSd(n)
  yyu <- pmin(yy + D, 1)
  yyl <- pmax(yy - D, 0)
  ecu <- stepfun(xx, c(yyu, 1))
  ecl <- stepfun(xx, c(yyl, yyl[n]))
  return(list(x=x, upper=ecu(x),lower=ecl(x)))
}