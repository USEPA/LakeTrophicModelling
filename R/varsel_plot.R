#' Plot varsel_regression output
#' 
#' @param vs_reg_obj Object from output of \link{varsel_regression_rf}.
#' @export
#' @import ggplot2
varsel_plot <- function(vs_reg_obj){
  dat <- data.frame(num = vs_reg_obj$num_var, mse = vs_reg_obj$mse)
  plot_out<-ggplot(dat, aes(x=num,y=mse))+geom_point()
  return(plot_out)
}