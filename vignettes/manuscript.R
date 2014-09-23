## ----setup, include=FALSE, echo=FALSE------------------------------------
#devtools::install_github("USEPA/LakeTrophicModelling",quick=TRUE,
#                        auth_token="8742a8c1c2207393659a1de1bd53527fa56ea0d7")
#devtools::install_github("jhollist/wesanderson")
library("wesanderson")
library("LakeTrophicModelling")
library("knitr")
library("ggplot2")
library("sp")
library("rgdal")
library("e1071")
library("dplyr")
library("tidyr")
opts_chunk$set(dev = 'pdf', fig.width=6, fig.height=4.3)
data(LakeTrophicModelling)

#Checks for existing cache (from another project)
if(file.exists("prior_cache")){
  for(i in gsub(".rdb","",list.files("prior_cache",".rdb",full.names=T))){
    lazyLoad(i)
  }
}

# Table Captions from @DeanK on 
#http://stackoverflow.com/questions/15258233/using-table-caption-on-r-markdown-file-using-knitr-to-use-in-pandoc-to-convert-t

knit_hooks$set(tab.cap = function(before, options, envir) {
                  if(!before) { 
                    paste('\n\n:', options$tab.cap, sep='') 
                  }
                })
default_output_hook = knit_hooks$get("output")
knit_hooks$set(output = function(x, options) {
  if (is.null(options$tab.cap) == FALSE) {
    x
  } else
    default_output_hook(x,options)
})

