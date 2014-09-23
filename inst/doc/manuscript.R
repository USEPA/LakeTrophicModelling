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

## ----analysis , eval=FALSE, include=FALSE, echo=FALSE, cache=TRUE--------
#  ################################################################################
#  #All analysis in here, that way all bits of paper have access to final objects
#  #Tables, figures, and numerical results placed at end of paper.
#  #Included for completeness.  Results already run in another project
#  #Those results loaded via lazyLoad in setup chunk
#  #This chunk takes several days to complete - DO NOT EDIT!!!
#  ################################################################################
#  #Model 1: All Variables, 4 Trophic State Classes
#    #Variable Selction
#    all_ts4<-iterVarSelRF(ltmData[predictors_all],ltmData$TS_CHLA_4,numCore=4,100,
#          								ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    											vars.drop.num=1,outStr="all_ts4",time=TRUE)
#    #Random Forest
#    all_ts4_vars<-unique(unlist(all_ts4[1:100]))
#    all_ts4_rf<-runRandomForest(ltmData[all_ts4_vars],ltmData$TS_CHLA_4,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 2: All Variables, 3 Trophic State Classes
#    #Variable Selction
#    all_ts3<-iterVarSelRF(ltmData[predictors_all],ltmData$TS_CHLA_3,numCore=4,100,
#        									ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    											vars.drop.num=1,outStr="all_ts3",time=TRUE)
#    #Random Forest
#    all_ts3_vars<-unique(unlist(all_ts3[1:100]))
#    all_ts3_rf<-runRandomForest(ltmData[all_ts3_vars],ltmData$TS_CHLA_3,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 3: All Variables, 2 Trophic State Classes
#    #Variable Selction
#    all_ts2<-iterVarSelRF(ltmData[predictors_all],ltmData$TS_CHLA_2,numCore=4,100,
#        									ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    											vars.drop.num=1,outStr="all_ts2",time=TRUE)
#  
#    #Random Forest
#    all_ts2_vars<-unique(unlist(all_ts2[1:100]))
#    all_ts2_rf<-runRandomForest(ltmData[all_ts2_vars],ltmData$TS_CHLA_2,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 4: GIS Only Variables, 4 Trophic State Classes
#    #Variable Selction
#    gis_ts4<-iterVarSelRF(ltmData[predictors_gis],ltmData$TS_CHLA_4,numCore=4,100,
#            							ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    											vars.drop.num=1,outStr="gis_ts4",time=TRUE)
#  
#    #Random Forest
#    gis_ts4_vars<-unique(unlist(gis_ts4[1:100]))
#    gis_ts4_rf<-runRandomForest(ltmData[gis_ts4_vars],ltmData$TS_CHLA_4,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 5: GIS Only Variables, 3 Trophic State Classes
#    #Variable Selction
#    gis_ts3<-iterVarSelRF(ltmData[predictors_gis],ltmData$TS_CHLA_3,numCore=4,100,
#          								ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    											vars.drop.num=1,outStr="gis_ts3",time=TRUE)
#  
#    #Random Forest
#    gis_ts3_vars<-unique(unlist(gis_ts3[1:100]))
#    gis_ts3_rf<-runRandomForest(ltmData[gis_ts3_vars],ltmData$TS_CHLA_3,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 6: GIS Only Variables, 2 Trophic State Classes
#    #Variable Selction
#    gis_ts2<-iterVarSelRF(ltmData[predictors_gis],ltmData$TS_CHLA_2,numCore=4,100,
#        									ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    											vars.drop.num=1,outStr="gis_ts2",time=TRUE)
#    #Random Forest
#    gis_ts2_vars<-unique(unlist(gis_ts2[1:100]))
#    gis_ts2_rf<-runRandomForest(ltmData[gis_ts2_vars],ltmData$TS_CHLA_2,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  

## ----summaryStats, echo=FALSE, cache=TRUE, warning=FALSE-----------------
acc_results<-data.frame(model_number=c("Model 1","Model 2","Model 3","Model 4","Model 5","Model 6"),
                        total_accuracy=c(classAgreement(all_ts4_rf$confusion[,1:4])$diag,
                                         classAgreement(all_ts3_rf$confusion[,1:3])$diag,
                                         classAgreement(all_ts2_rf$confusion[,1:2])$diag,
                                         classAgreement(gis_ts4_rf$confusion[,1:4])$diag,
                                         classAgreement(gis_ts3_rf$confusion[,1:3])$diag,
                                         classAgreement(gis_ts2_rf$confusion[,1:2])$diag),
                        kappa_coeff=c(classAgreement(all_ts4_rf$confusion[,1:4])$kappa,
                                         classAgreement(all_ts3_rf$confusion[,1:3])$kappa,
                                         classAgreement(all_ts2_rf$confusion[,1:2])$kappa,
                                         classAgreement(gis_ts4_rf$confusion[,1:4])$kappa,
                                         classAgreement(gis_ts3_rf$confusion[,1:3])$kappa,
                                         classAgreement(gis_ts2_rf$confusion[,1:2])$kappa))
var_importance<-rbind_list(varImportance(all_ts4_rf,"Model 1"),
                           varImportance(all_ts3_rf,"Model 2"),
                           varImportance(all_ts2_rf,"Model 3"),
                           varImportance(gis_ts4_rf,"Model 4"),
                           varImportance(gis_ts3_rf,"Model 5"),
                           varImportance(gis_ts2_rf,"Model 6"))
var_importance$variable_names<-factor(var_importance$variable_names)
#var_importance$model_id<-factor(var_importance$model_id)
var_importance<-inner_join(var_importance,data_def[c("variable_names","description")],"variable_names")
var_importance<-var_importance[order(var_importance$model_id,-var_importance$mean_decrease_gini, decreasing=FALSE),]                     
                        

## ----figSetup,echo=FALSE,eval=TRUE,cache=TRUE----------------------------
#create list of all selected variables and assign a color
vars<-ls(pattern="_vars")
all_vars<-vector()
for(i in vars){
  all_vars<-c(all_vars,get(i))
}
all_vars<-unique(all_vars)

all_movies_palette<-vector()
for(i in 1:dim(namelist)[1]){
  all_movies_palette<-c(all_movies_palette,wes.palette(namelist[i,2],
                                                       namelist[i,1]))
}
all_movies_palette<-unique(all_movies_palette)
zissou<-c(wes.palette(5,"Zissou"),wes.palette(5,"Zissou2"))
col_lu<-data.frame(variables=all_vars,hexcode=sample(all_movies_palette,length(all_vars)))

## ----nlaMap, echo=FALSE, fig.cap="Map of the distribution of National Lakes Assesment Sampling locations\\label{fig:nlaMap}",cache=TRUE----
state<-map_data('state')
lakes_alb<-data.frame(ltmData[["AlbersX"]],ltmData[["AlbersY"]])
p4s<-"+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
ll<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
lakes_alb_sp<-SpatialPoints(coordinates(lakes_alb),proj4string=CRS(p4s))
lakes_dd<-spTransform(lakes_alb_sp,CRS=CRS(ll))
lakes_dd<-data.frame(coordinates(lakes_dd))
mycolor<-wes.palette(5,"Zissou2")
mycolor<-c(mycolor[1],mycolor[2],mycolor[4])
names(lakes_dd)<-c("long","lat",c())
nlaMap(state,lakes_dd,mycolor)

## ----Importance_Model1,results="asis",echo=FALSE, fig.cap="Importance plot for Model 1\\label{fig:Importance_Model1}",cache=TRUE----
all_ts4_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts4_vars]
importancePlot(all_ts4_rf,'gini',size=10,aes(colour=all_ts4_color))

## ----Importance_Model2,results="asis",echo=FALSE, fig.cap="Importance plot for Model 2",cache=TRUE----
all_ts3_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts3_vars]
importancePlot(all_ts3_rf,'gini',size=10,aes(colour=all_ts3_color))

## ----Importance_Model3,results="asis",echo=FALSE, fig.cap="Importance plot for Model 3",cache=TRUE----
all_ts2_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts2_vars]
importancePlot(all_ts2_rf,'gini',size=10,aes(colour=all_ts2_color))

## ----Importance_Model4,results="asis",echo=FALSE, tab.cap="Importance plot for Model 4",cache=TRUE----
gis_ts4_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts4_vars]
importancePlot(gis_ts4_rf,'gini',size=10,aes(colour=gis_ts4_color))

## ----Importance_Model5,results="asis",echo=FALSE, fig.cap="Importance plot for Model 5",cache=TRUE----
gis_ts3_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts3_vars]
importancePlot(gis_ts3_rf,'gini',size=10,aes(colour=gis_ts3_color))

## ----Importance_Model6,results="asis",echo=FALSE, fig.cap="Importance plot for Model 6",cache=TRUE----
gis_ts2_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts2_vars]
importancePlot(gis_ts2_rf,'gini',size=10,aes(colour=gis_ts2_color))

## ----ts_4_biov, echo=FALSE, fig.width=7, fig.cap="Cumulative distribution function of cyanobacetria biovolume for 4 trophic state classes",cache=TRUE----
plotCdf(ltmData$TS_CHLA_4,ltmData$sumBioV+1,cdf_colors=zissou[6:9],
        y='Percent',x='Log10(Cyanobacteria Biovolume)',
        title=expression(paste('CDF for Chlorophyll ', 
                                italic("a"),' Trophic States (4 Categories)')),
        color="Trophic State\nCategories")

## ----ts_3_biov_cdf, echo=FALSE, fig.width=7, fig.cap="Cumulative distribution function of cyanobacetria biovolume for 3 trophic state classes",cache=TRUE----
plotCdf(ltmData$TS_CHLA_3,ltmData$sumBioV+1,cdf_colors=zissou[6:8],
       y='Percent',x='Log10(Cyanobacteria Biovolume)', 
       title=expression(paste('CDF for Chlorophyll ', 
                              italic("a"),' Trophic States (3 Categories)')),
       color="Trophic State\nCategories")

## ----ts_2_biov_cdf, echo=FALSE, fig.width=7, fig.cap="Cumulative distribution function of cyanobacetria biovolume for 2 trophic state classes",cache=TRUE----
plotCdf(ltmData$TS_CHLA_2,ltmData$sumBioV+1,cdf_colors=zissou[6:7],
       y='Percent',x='Log10(Cyanobacteria Biovolume)',
       title=expression(paste('CDF for Chlorophyll ', 
                              italic("a"),' Trophic States (2 Categories)')),
       color="Trophic State\nCategories")

## ----scatterplot,echo=FALSE, fig.width=7, fig.cap="Cholorphyll *a* and cyanobacteria biovolume scatterplot",cache=TRUE----
scp_df<-data.frame(chla=ltmData[["CHLA"]],biovp1=ltmData[["sumBioV"]]+1)
scatterPlot(scp_df,xvar="chla",yvar="biovp1",zissou[8],zissou[7],zissou[6],
             title=expression(paste("Chlorophyll ", 
                                    italic("a")," and Cyanobacteria Relationship")),
             x=expression(paste('Log10(Chl ', italic("a"),')')),
             y="Log10(Cyanobaterial Biovolumes + 1)")

## ----trophicStateTable, results='asis', echo=FALSE, tab.cap="Chlorophyll a based trophic state cut-offs\\label{tab:trophicStateTable}",cache=TRUE----
ts_4<-c("oligo","meso","eu","hyper")
ts_3<-c("oligo","meso/eu","meso/eu","hyper")
ts_2<-c("oligo/meso","oligo/meso","eu/hyper","eu/hyper")
co<-c("<= 0.2",">2-7",">7-30",">30")
xdf<-data.frame(ts_4,ts_3,ts_2,co)
names(xdf)<-c("Trophic State (4)","Trophic State (3)","Trophic State (2)","Cut-off")
kable(xdf)

## ----VarSel_Model1,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 1\\label{tab:VarSel_Model1}",cache=TRUE----
kable(sumTable(all_ts4[1:100]),row.names=F)

## ----Confusion_Model1,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 1\\label{tab:Confusion_Model1}",cache=TRUE----
kable(formatC(round(all_ts4_rf$confusion,2)),row.names=F)

## ----VarSel_Model2,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 2",cache=TRUE----
kable(sumTable(all_ts3[1:100]),row.names=F)

## ----Confusion_Model2,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 2",cache=TRUE----
kable(formatC(round(all_ts3_rf$confusion,2)),row.names=F)

## ----VarSel_Model3,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 3",cache=TRUE----
kable(sumTable(all_ts2[1:100]),row.names=F)

## ----Confusion_Model3,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 3",cache=TRUE----
kable(formatC(round(all_ts2_rf$confusion,2)),row.names=F)

## ----VarSel_Model4,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 4",cache=TRUE----
kable(sumTable(gis_ts4[1:100]),row.names=F)

## ----Confusion_Model4,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 4",cache=TRUE----
kable(formatC(round(gis_ts4_rf$confusion,2)),row.names=F)

## ----VarSel_Model5,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 5",cache=TRUE----
kable(sumTable(gis_ts3[1:100]),row.names=F)

## ----Conufsion_Model5,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 5",cache=TRUE----
kable(formatC(round(gis_ts3_rf$confusion,2)),row.names=F)

## ----VarSel_Model6,results="asis",echo=FALSE, tab.cap="Variable selection results for Model 6",cache=TRUE----
kable(sumTable(gis_ts2[1:100]),row.names=F)

## ----Confusion_Model6,results="asis",echo=FALSE, tab.cap="Random forest confusion matrix for Model 6",cache=TRUE----
kable(formatC(round(gis_ts2_rf$confusion,2)),row.names=F)

