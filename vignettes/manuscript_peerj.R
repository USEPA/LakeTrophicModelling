## ----setup, include=FALSE, echo=FALSE-----------------------------------------
options(repos="https://cran.rstudio.com")
if(!require(wesanderson)){
devtools::install_github("jhollist/wesanderson")
}
if(!require(edarf)){
devtools::install_github("zmjones/edarf/pkg")
}
if(!require(condprob2)){
devtools::install_github("jhollist/condprob2")
}
if(!require(pander)){
  install.packages("pander")
}
if(!require(tidyr)){
  install.packages("tidyr")
}
if(!require(party)){
  install.packages("party")
}

if(!require(broom)){
  install.packages("broom")
}

if(!require(interpretR)){
  install.packages("interpretR")
}

if(!require(doParallel)){
  install.packages("doParallel")
}
if(!require(viridis)){
  devtools::install_github("CRAN/viridis")
}

if(!require(LakeTrophicModelling)){
  devtools::install_github("USEPA/LakeTrophicModelling",quick=TRUE)
}

library("viridis")
library("wesanderson")
library("LakeTrophicModelling")
library("knitr")
library("ggplot2")
library("sp")
library("rgdal")
library("e1071")
library("dplyr")
library("tidyr")
library("condprob2")
library("party")
library("broom")
library("edarf")
#library("caret")
library("randomForest")
library("doParallel")
opts_chunk$set(dev = 'jpeg', dpi=300, fig.width=7.5, knitr.table.format="html")
data(LakeTrophicModelling)

#
#Checks for existing cache (from another project)
#Else if Repeats running chunk outside of knitr
if(file.exists("prior_cache")){
  for(i in gsub(".rdb","",list.files("prior_cache",".rdb",full.names=T))){
    lazyLoad(i)
  }
} else if(file.exists("vignettes/prior_cache")){
  for(i in gsub(".rdb","",list.files("vignettes/prior_cache",".rdb",full.names=T))){
    lazyLoad(i)
  }
} else if(file.exists("../prior_cache")){
  for(i in gsub(".rdb","",list.files("../prior_cache",".rdb",full.names=T))){
    lazyLoad(i)
  }
}
#multiple caches... silly Jeff
#
if(file.exists("manuscript_cache/latex")){
  for(i in gsub(".rdb","",list.files("manuscript_cache/latex",".rdb",full.names=T))){
    lazyLoad(i)
  }
} else if(file.exists("vignettes/manuscript_cache/latex")){
  for(i in gsub(".rdb","",list.files("vignettes/manuscript_cache/latex",".rdb",full.names=T))){
    lazyLoad(i)
  }
} else if(file.exists("../manuscript_cache/latex")){
  for(i in gsub(".rdb","",list.files("../manuscript_cache/latex",".rdb",full.names=T))){
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



## ----data_setup ,echo=FALSE, message=FALSE------------------------------------
#All Variables
#Clean Up Data - Complete Cases
predictors_all <- predictors_all[predictors_all!="DATE_COL"]
all_dat <- data.frame(ltmData[predictors_all],LogCHLA=log10(ltmData$CHLA))
row.names(all_dat)<-ltmData$NLA_ID
all_dat <- all_dat[complete.cases(all_dat),]  

#GIS Variables
#Clean Up Data - Complete Cases
gis_dat <- data.frame(ltmData[predictors_gis],LogCHLA=log10(ltmData$CHLA))
row.names(gis_dat)<-ltmData$NLA_ID
gis_dat <- gis_dat[complete.cases(gis_dat),]
#ecoregion shape
ecor_path <- system.file("extdata/", package = "LakeTrophicModelling")
wsa9<-readOGR(ecor_path,"wsa9_low48",verbose=FALSE)

