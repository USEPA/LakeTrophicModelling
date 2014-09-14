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

## ----nlaMap, echo=FALSE, fig.cap="Map of the distribution of National Lakes Assesment Sampling locations\\label{fig:nlaMap}"----
state<-map_data('state')
lakes_alb<-data.frame(hkm2014Data[["AlbersX"]],hkm2014Data[["AlbersY"]])
p4s<-"+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
ll<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
lakes_alb_sp<-SpatialPoints(coordinates(lakes_alb),proj4string=CRS(p4s))
lakes_dd<-spTransform(lakes_alb_sp,CRS=CRS(ll))
lakes_dd<-data.frame(coordinates(lakes_dd))
mycolor<-wes.palette(5,"Zissou2")
mycolor<-c(mycolor[1],mycolor[2],mycolor[4])
names(lakes_dd)<-c("long","lat",c())
nlaMap(state,lakes_dd,mycolor)

## ----trophicStateTable, results='asis', echo=FALSE, tab.cap="Chlorophyll a based trophic state cut-offs\\label{tab:trophicStateTable}"----
ts_4<-c("oligo","meso","eu","hyper")
ts_3<-c("oligo","meso/eu","meso/eu","hyper")
ts_2<-c("oligo/meso","oligo/meso","eu/hyper","eu/hyper")
co<-c("<= 0.2",">2-7",">7-30",">30")
xdf<-data.frame(ts_4,ts_3,ts_2,co)
names(xdf)<-c("Trophic State (4)","Trophic State (3)","Trophic State (2)","Cut-off")
kable(xdf)

## ----VarSel_Model1,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 1\\label{tab:VarSel_Model1}"----
kable(sumTable(all_ts4[1:100]),row.names=F)

## ----Confusion_Model1,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 1\\label{tab:Confusion_Model1}"----
kable(formatC(round(all_ts4_rf$confusion,2)),row.names=F)

## ----Importance_Model1,results="asis",echo=FALSE, fig.cap="Importance plot for Model 1\\label{fig:Importance_Model1}"----
all_ts4_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts4_vars]
importancePlot(all_ts4_rf,'gini',size=10,aes(colour=all_ts4_color))

## ----VarSel_Model2,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 2"----
kable(sumTable(all_ts3[1:100]),row.names=F)

## ----Confusion_Model2,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 2"----
kable(formatC(round(all_ts3_rf$confusion,2)),row.names=F)

## ----Importance_Model2,results="asis",echo=FALSE, fig.cap="Importance plot for Model 2"----
all_ts3_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts3_vars]
importancePlot(all_ts3_rf,'gini',size=10,aes(colour=all_ts3_color))

## ----VarSel_Model3,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 3"----
kable(sumTable(all_ts2[1:100]),row.names=F)

## ----Confusion_Model3,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 3"----
kable(formatC(round(all_ts2_rf$confusion,2)),row.names=F)

## ----Importance_Model3,results="asis",echo=FALSE, fig.cap="Importance plot for Model 3"----
all_ts2_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts2_vars]
importancePlot(all_ts2_rf,'gini',size=10,aes(colour=all_ts2_color))

## ----VarSel_Model4,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 4"----
kable(sumTable(gis_ts4[1:100]),row.names=F)

## ----Confusion_Model4,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 4"----
kable(formatC(round(gis_ts4_rf$confusion,2)),row.names=F)

## ----Importance_Model4,results="asis",echo=FALSE, tab.cap="Importance plot for Model 4"----
gis_ts4_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts4_vars]
importancePlot(gis_ts4_rf,'gini',size=10,aes(colour=gis_ts4_color))

## ----VarSel_Model5,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 5"----
kable(sumTable(gis_ts3[1:100]),row.names=F)

## ----Conufsion_Model5,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 5"----
kable(formatC(round(gis_ts3_rf$confusion,2)),row.names=F)

## ----Importance_Model5,results="asis",echo=FALSE, fig.cap="Importance plot for Model 5"----
gis_ts3_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts3_vars]
importancePlot(gis_ts3_rf,'gini',size=10,aes(colour=gis_ts3_color))

## ----VarSel_Model6,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 6"----
kable(sumTable(gis_ts2[1:100]),row.names=F)

## ----Confusion_Model6,results="asis",echo=FALSE, tab.cap="Random forest confusion matrix for Model 6"----
kable(formatC(round(gis_ts2_rf$confusion,2)),row.names=F)

## ----Importance_Model6,results="asis",echo=FALSE, fig.cap="Importance plot for Model 6"----
gis_ts2_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts2_vars]
importancePlot(gis_ts2_rf,'gini',size=10,aes(colour=gis_ts2_color))

## ----ts_4_biov, echo=FALSE, fig.width=7, fig.cap="Cumulative distribution function of cyanobacetria biovolume for 4 trophic state classes"----
plotCdf(hkm2014Data$TS_CHLA_4,hkm2014Data$sumBioV+1,cdf_colors=zissou[6:9],
        y='Percent',x='Log10(Cyanobacteria Biovolume)',
        title=expression(paste('CDF for Chlorophyll ', 
                                italic("a"),' Trophic States (4 Categories)')),
        color="Trophic State\nCategories")

## ----ts_3_biov_cdf, echo=FALSE, fig.width=7, fig.cap="Cumulative distribution function of cyanobacetria biovolume for 3 trophic state classes"----
plotCdf(hkm2014Data$TS_CHLA_3,hkm2014Data$sumBioV+1,cdf_colors=zissou[6:8],
       y='Percent',x='Log10(Cyanobacteria Biovolume)', 
       title=expression(paste('CDF for Chlorophyll ', 
                              italic("a"),' Trophic States (3 Categories)')),
       color="Trophic State\nCategories")

## ----ts_2_biov_cdf, echo=FALSE, fig.width=7, fig.cap="Cumulative distribution function of cyanobacetria biovolume for 2 trophic state classes"----
plotCdf(hkm2014Data$TS_CHLA_2,hkm2014Data$sumBioV+1,cdf_colors=zissou[6:7],
       y='Percent',x='Log10(Cyanobacteria Biovolume)',
       title=expression(paste('CDF for Chlorophyll ', 
                              italic("a"),' Trophic States (2 Categories)')),
       color="Trophic State\nCategories")

## ----scatterplot,echo=FALSE, fig.width=7, fig.cap="Cholorphyll *a* and cyanobacteria biovolume scatterplot"----
scp_df<-data.frame(chla=hkm2014Data[["CHLA"]],biovp1=hkm2014Data[["sumBioV"]]+1)
scatterPlot(scp_df,xvar="chla",yvar="biovp1",zissou[8],zissou[7],zissou[6],
             title=expression(paste("Chlorophyll ", 
                                    italic("a")," and Cyanobacteria Relationship")),
             x=expression(paste('Log10(Chl ', italic("a"),')')),
             y="Log10(Cyanobaterial Biovolumes + 1)")

