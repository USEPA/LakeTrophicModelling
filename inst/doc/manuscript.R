## ----setup, include=FALSE, echo=FALSE------------------------------------
#devtools::install_github("LakeTrophicModelling","USEPA",quick=TRUE,
 #                        auth_token="8742a8c1c2207393659a1de1bd53527fa56ea0d7")
#devtools::install_github("wesanderson","jhollist")
library("wesanderson")
library("LakeTrophicModelling")
library("knitr")
library("ggplot2")
library("sp")
library("rgdal")
library("xtable")
library("e1071")
opts_chunk$set(dev = 'pdf', fig.width=6, fig.height=4.3)
data(hkm2014Data_all)

#Checks for existing cache (from another project)
if(file.exists("cache")){
  for(i in gsub(".rdb","",list.files("cache",".rdb",full.names=T))){
    lazyLoad(i)
  }
}

# Table Captions from @DeanK on http://stackoverflow.com/questions/15258233/using-table-caption-on-r-markdown-file-using-knitr-to-use-in-pandoc-to-convert-t

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

## ----analysis , include=FALSE, echo=FALSE--------------------------------
#All analysis in here, that way all bits of the paper have access to the final objects
#Place tables and figures and numerical results where they need to go.

## ----Variables, results='asis', eval=FALSE, echo=FALSE-------------------
#  #tab.cap="Definition of all variables considered"
#  translation<-c("Percent Impervious","Percent Water","Percent Ice/Snow","Percent Developed Open Space","Percent Low Intensity Development","Percent Medium Intensity Development", "Percent High Intensity Development","Percent Barren","Percent Decidous Forest","Percent Evergreen Forest","Percent Mixed Forest","Precent Shrub/Scrub","Percent Grassland", "Percent Pasture", "Percent Cropland", "Percent Woody Wetland", "Percent Herbaceuos Wetland","Longitude","Latitude","Lake Surface Area", "Lake Perimeter","Shoreline Development Index","Date Samples Collected", "Ecoregion", "Watershed Area","Maximum Depth","Elevation","Dissolved Oxygen","pH","Conductivity","Acid Neutralizing Capacity","Turbidity","Total Organic Carbon","Dissolved Organic Carbon","Ammonium","Nitrate/Nitrite", "Total Nitrogen","Total Phosphorus","Chloride","Nitrate","Sulfate","Calcium","Magnesium","Sodium","Potassium","Color","Silica","Hydrogen Ions","Hydroxide","Calculate Ammonium","Cation Sum","Anion Sum","Anion Deficit","Base Cation Sum","Ion Balance","Estimate Organic Anions","Calculated Conductivity","D-H-O Calculated Conductivity","Mean Profile Water Temperature","Growing Degree Days","Maximum Lake Length","Maximum Lake Width","Mean Lake Width","Fetch from North", "Fetch form Northeast","Fetch from East", "Fetch from Southeast","Estimated Maximum Lake Depth","Estimated Lake Volume","Estimated Mean Lake Depth","Nitrogen:Phophorus Ratio")
#  wq<-!predictors_all%in%predictors_gis
#  type<-vector("character",length(predictors_all))
#  type[wq]<-"Water Quality"
#  type[!wq]<-"GIS"
#  data_def<-data.frame(Variables=predictors_all,Description=translation,Type=type)
#  # This is an unbelievably silly table... It is life sized!
#  kable(data_def)
#  #dfToImage(data_def,style="css/texttable.css",file="figure/data_def_table.jpg")

