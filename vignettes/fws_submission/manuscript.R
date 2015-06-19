## ----setup, include=FALSE, echo=FALSE------------------------------------
if(!require(LakeTrophicModelling)){
  devtools::install_github("USEPA/LakeTrophicModelling",quick=TRUE)
}
if(!require(wesanderson)){
devtools::install_github("jhollist/wesanderson")
}
if(!require(condprob2)){
devtools::install_github("jhollist/condprob2")
}
if(!require(tidyr)){
  install.packages("tidyr")
}
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

## ----analysis , eval=FALSE, include=FALSE, echo=FALSE, cache=FALSE-------
#  ################################################################################
#  #All analysis in here, that way all bits of paper have access to final objects
#  #Tables, figures, and numerical results placed at end of paper.
#  #Included for completeness.  Results already run in another project
#  #Those results loaded via lazyLoad in setup chunk
#  #This chunk takes several days to complete - DO NOT EDIT!!!
#  ################################################################################
#  #Model 1: All Variables, 4 Trophic State Classes
#    #Variable Selction
#    #all_ts4<-iterVarSelRF(ltmData[predictors_all],ltmData$TS_CHLA_4,numCore=4,100,
#    #      								ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    #  											vars.drop.num=1,outStr="all_ts4",time=TRUE)
#    #all_ts4_rf_full<-runRandomForest(ltmData[predictors_all],ltmData$TS_CHLA_4,
#    #                          ntree=10000,importance=TRUE,proximity=TRUE)
#    #Random Forest
#    all_ts4_vars<-unique(unlist(all_ts4[1:100]))
#    all_ts4_rf<-runRandomForest(ltmData[all_ts4_vars],ltmData$TS_CHLA_4,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 2: All Variables, 3 Trophic State Classes
#    #Variable Selction
#    #all_ts3<-iterVarSelRF(ltmData[predictors_all],ltmData$TS_CHLA_3,numCore=4,100,
#    #    									ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    #  											vars.drop.num=1,outStr="all_ts3",time=TRUE)
#    # all_ts3_rf_full<-runRandomForest(ltmData[predictors_all],ltmData$TS_CHLA_3,
#    #                            ntree=10000,importance=TRUE,proximity=TRUE)
#    #Random Forest
#    all_ts3_vars<-unique(unlist(all_ts3[1:100]))
#    all_ts3_rf<-runRandomForest(ltmData[all_ts3_vars],ltmData$TS_CHLA_3,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 3: All Variables, 2 Trophic State Classes
#    #Variable Selction
#    #all_ts2<-iterVarSelRF(ltmData[predictors_all],ltmData$TS_CHLA_2,numCore=4,100,
#    #    									ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    #											vars.drop.num=1,outStr="all_ts2",time=TRUE)
#    #all_ts2_rf_full<-runRandomForest(ltmData[predictors_all],ltmData$TS_CHLA_2,
#    #                           ntree=10000,importance=TRUE,proximity=TRUE)
#    #Random Forest
#    all_ts2_vars<-unique(unlist(all_ts2[1:100]))
#    all_ts2_rf<-runRandomForest(ltmData[all_ts2_vars],ltmData$TS_CHLA_2,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 4: GIS Only Variables, 4 Trophic State Classes
#    #Variable Selction
#    #gis_ts4<-iterVarSelRF(ltmData[predictors_gis],ltmData$TS_CHLA_4,numCore=4,100,
#    #        							ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    #											vars.drop.num=1,outStr="gis_ts4",time=TRUE)
#    #gis_ts4_rf_full<-runRandomForest(ltmData[predictors_gis],ltmData$TS_CHLA_4,
#    #                            ntree=10000,importance=TRUE,proximity=TRUE)
#    #Random Forest
#    gis_ts4_vars<-unique(unlist(gis_ts4[1:100]))
#    gis_ts4_rf<-runRandomForest(ltmData[gis_ts4_vars],ltmData$TS_CHLA_4,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 5: GIS Only Variables, 3 Trophic State Classes
#    #Variable Selction
#    #gis_ts3<-iterVarSelRF(ltmData[predictors_gis],ltmData$TS_CHLA_3,numCore=4,100,
#    #      								ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    #											vars.drop.num=1,outStr="gis_ts3",time=TRUE)
#    #gis_ts3_rf_full<-runRandomForest(ltmData[predictors_gis],ltmData$TS_CHLA_3,
#    #                            ntree=10000,importance=TRUE,proximity=TRUE)
#    #Random Forest
#    gis_ts3_vars<-unique(unlist(gis_ts3[1:100]))
#    gis_ts3_rf<-runRandomForest(ltmData[gis_ts3_vars],ltmData$TS_CHLA_3,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  ################################################################################
#  #Model 6: GIS Only Variables, 2 Trophic State Classes
#    #Variable Selction
#    #gis_ts2<-iterVarSelRF(ltmData[predictors_gis],ltmData$TS_CHLA_2,numCore=4,100,
#    #    									ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
#    #											vars.drop.num=1,outStr="gis_ts2",time=TRUE)
#    #gis_ts2_rf_full<-runRandomForest(ltmData[predictors_gis],ltmData$TS_CHLA_2,
#    #                            ntree=10000,importance=TRUE,proximity=TRUE)
#    #Random Forest
#    gis_ts2_vars<-unique(unlist(gis_ts2[1:100]))
#    gis_ts2_rf<-runRandomForest(ltmData[gis_ts2_vars],ltmData$TS_CHLA_2,
#                                ntree=10000,importance=TRUE,proximity=TRUE)
#  

## ----summaryStats, eval=TRUE, echo=FALSE, cache=FALSE, warning=FALSE-----
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
var_importance<-rbind(varImportance(all_ts4_rf,"Model 1"),
                           varImportance(all_ts3_rf,"Model 2"),
                           varImportance(all_ts2_rf,"Model 3"),
                           varImportance(gis_ts4_rf,"Model 4"),
                           varImportance(gis_ts3_rf,"Model 5"),
                           varImportance(gis_ts2_rf,"Model 6"))
#var_importance$variable_names<-factor(var_importance$variable_names)
#var_importance$model_id<-factor(var_importance$model_id)
var_importance<-inner_join(var_importance,data_def[c("variable_names","description")],"variable_names")
var_importance<-var_importance[order(var_importance$model_id,-var_importance$mean_decrease_gini, decreasing=FALSE),]                     

#Example Votes
lakeVotes<-data.frame(all_ts4_rf$y,all_ts4_rf$predicted,all_ts4_rf$votes)
lakeVotes<-data.frame(lakeVotes,max_prob=apply(lakeVotes[,3:6],1,max))
lakeVotes$all_ts4_rf.predicted<-factor(lakeVotes$all_ts4_rf.predicted,ordered=T)
lakeVotes<-data.frame(lakeVotes,correct_binary=lakeVotes$all_ts4_rf.y==lakeVotes$all_ts4_rf.predicted)
lakeVotes<-data.frame(COMID=getLakeIDs(ltmData[all_ts4_vars],ltmData$TS_CHLA_4,ltmData$Comid),lakeVotes)
lakeVotes<-na.omit(lakeVotes)

## ----figSetup,echo=FALSE,eval=TRUE,cache=FALSE---------------------------
#create list of all selected variables and assign a color
vars<-ls(pattern="_vars")
all_vars<-vector()
for(i in vars){
  all_vars<-c(all_vars,get(i))
}
all_vars<-unique(all_vars)

#all_movies_palette<-vector()
#for(i in 1:dim(namelist)[1]){
#  all_movies_palette<-c(all_movies_palette,wes.palette(namelist[i,2],
#                                                       namelist[i,1]))
#}
#all_movies_palette<-unique(all_movies_palette)
#zissou<-c(wes.palette(5,"Zissou"),wes.palette(5,"Rushmore"))
#col_lu<-data.frame(variables=all_vars,hexcode=sample(all_movies_palette,length(all_vars)))

## ----nlaMap, echo=FALSE, fig.cap="Map of the distribution of National Lakes Assesment Sampling locations\\label{fig:nlaMap}",cache=FALSE----
state<-map_data('state')
lakes_alb<-data.frame(ltmData[["AlbersX"]],ltmData[["AlbersY"]])
p4s<-"+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
ll<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
lakes_alb_sp<-SpatialPoints(coordinates(lakes_alb),proj4string=CRS(p4s))
lakes_dd<-spTransform(lakes_alb_sp,CRS=CRS(ll))
lakes_dd<-data.frame(coordinates(lakes_dd))
#mycolor<-wes.palette(5,"Rushmore")
#mycolor<-c(mycolor[1],mycolor[2],mycolor[4])
mycolor<-c("grey25","white","black")
names(lakes_dd)<-c("long","lat",c())
nlaMap(state,lakes_dd,mycolor)

## ----Importance_Model1,results="asis",echo=FALSE, fig.cap="Importance plot for Model 1, shows mean descrease gini and proportion of times a variable was selected for inclusion in the model.  Higher values of mean decrease gini indicate higher importance.  \\label{fig:Importance_Model1}",cache=FALSE----
#all_ts4_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts4_vars]
importancePlot(all_ts4_rf,sumTable(all_ts4[1:100]), data_def=data_def,'gini',size=5)#,aes(colour=all_ts4_color))

## ----Importance_Model2,results="asis",echo=FALSE, fig.cap="Importance plot for Model 2, shows mean descrease gini and proportion of times a variable was selected for inclusion in the model.  Higher values of mean decrease gini indicate higher importance. \\label{fig:Importance_Model2}",cache=FALSE----
#all_ts3_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts3_vars]
importancePlot(all_ts3_rf,sumTable(all_ts3[1:100]), data_def=data_def,'gini',size=5)#,aes(colour=all_ts3_color))

## ----Importance_Model3,results="asis",echo=FALSE, fig.cap="Importance plot for Model 3, shows mean descrease gini and proportion of times a variable was selected for inclusion in the model.  Higher values of mean decrease gini indicate higher importance. \\label{fig:Importance_Model3}",cache=FALSE----
#all_ts2_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts2_vars]
importancePlot(all_ts2_rf,sumTable(all_ts2[1:100]), data_def=data_def,'gini',size=5)#,aes(colour=all_ts2_color))

## ----Importance_Model4,results="asis",echo=FALSE, fig.cap="Importance plot for Model 4, shows mean descrease gini and proportion of times a variable was selected for inclusion in the model.  Higher values of mean decrease gini indicate higher importance. \\label{fig:Importance_Model4}",cache=FALSE----
#gis_ts4_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts4_vars]
importancePlot(gis_ts4_rf,sumTable(gis_ts4[1:100]), data_def=data_def,'gini',size=5)#,aes(colour=gis_ts4_color))

## ----Importance_Model5,results="asis",echo=FALSE, fig.cap="Importance plot for Model 5, shows mean descrease gini and proportion of times a variable was selected for inclusion in the model.  Higher values of mean decrease gini indicate higher importance. \\label{fig:Importance_Model5}",cache=FALSE----
#gis_ts3_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts3_vars]
importancePlot(gis_ts3_rf,sumTable(gis_ts3[1:100]), data_def=data_def,'gini',size=5)#,aes(colour=gis_ts3_color))

## ----Importance_Model6,results="asis",echo=FALSE, fig.cap="Importance plot for Model 6, shows mean descrease gini and proportion of times a variable was selected for inclusion in the model.  Higher values of mean decrease gini indicate higher importance. \\label{fig:Importance_Model6}",cache=FALSE----
#gis_ts2_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts2_vars]
importancePlot(gis_ts2_rf,sumTable(gis_ts2[1:100]), data_def=data_def,'gini',size=5)#,aes(colour=gis_ts2_color))

## ----condProbFig,echo=FALSE, fig.width=7, fig.cap="Comparison of certainity of trophic state prediction and total accuracy\\label{fig:condProbFig}",cache=FALSE----
condAccuracy(gis_ts4_rf,xImpair=0,R=1,xlab="Maximum Vote Probability")

## ----ts_4_cyano_cdf, echo=FALSE, fig.width=7, fig.cap="Cumulative distribution function of cyanobacetria abundance for 4 trophic state classes\\label{fig:ts_4_cyano_cdf}",cache=FALSE----
plotCdf(ltmData$TS_CHLA_4,ltmData$cyanoCellsPerML+1,cdf_colors=c("black","grey75","grey50","grey25"),
        y='Percent',x='Log10(Cyanobacteria Abundance (cells/ml) + 1)',
        color="Trophic State\nCategories")

## ----ts_3_cyano_cdf, echo=FALSE, fig.width=7, fig.cap="Cumulative distribution function of cyanobacetria abundance for 3 trophic state classes\\label{fig:ts_3_cyano_cdf}",cache=FALSE----
plotCdf(ltmData$TS_CHLA_3,ltmData$cyanoCellsPerML+1,cdf_colors=c("black","grey75","grey50"),
       y='Percent',x='Log10(Cyanobacteria Abundance (cells/ml) + 1)', 
       color="Trophic State\nCategories")

## ----ts_2_cyano_cdf, echo=FALSE, fig.width=7, fig.cap="Cumulative distribution function of cyanobacetria abundance for 2 trophic state classes\\label{fig:ts_2_cyano_cdf}",cache=FALSE----
plotCdf(ltmData$TS_CHLA_2,ltmData$cyanoCellsPerML+1,cdf_colors=c("black","grey50"),
       y='Percent',x='Log10(Cyanobacteria Abundance (cells/ml) + 1)',
       color="Trophic State\nCategories")

## ----scatterplot,echo=FALSE, fig.width=7, fig.cap="Cholorphyll *a* and cyanobacteria abundance scatterplot\\label{fig:scatterplot}",cache=FALSE----
scp_df<-data.frame(chla=ltmData[["CHLA"]],abundp1=ltmData[["cyanoCellsPerML"]]+1)
scatterPlot(scp_df,xvar="chla",yvar="abundp1",zissou[8],zissou[7],zissou[6],
             x=expression(paste('Log10(Chl ', italic("a"),'(',mu,'g/L))')),
             y="Log10(Cyanobaterial Abundance (cells/ml) + 1)")

## ----trophicStateTable, results='asis', echo=FALSE, tab.cap="Chlorophyll a based trophic state cut-offs with total number of possible observations.\\label{tab:trophicStateTable}",cache=FALSE----
ts_4<-c("oligotrophic","mesotrophic","eutrophic","hypereutrophic")
ts_3<-c("oligotrophic","mesotrophic/eutrophic","mesotrophic/eutrophic","hypereutrophic")
ts_2<-c("oligotrophic/mesotrophic","oligotrophic/mesotrophic","eutrophic/hypereutrophic","eutrophic/hypereutrophic")
co<-c("<= 0.2",">2-7",">7-30",">30")
xdf<-data.frame(ts_4,ts_3,ts_2,co)
names(xdf)<-c("Trophic State (4 class)","Trophic State (3 class)","Trophic State (2 class)",
              "Concentration Cut-off")
kable(xdf)

## ----Confusion_Model1,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 1. Columns show predicted values and rows show observed values.  Agreement indicated on diagonal and accuracy for each trophic state indicated in 'Class Accuracy' column. \\label{tab:Confusion_Model1}",cache=FALSE----
cm1<-round(all_ts4_rf$confusion,2)
cm1[,5]<-paste0((1-cm1[,5])*100,"%")
dimnames(cm1)[[2]][5]<-'Class Accuracy'
kable(cm1,row.names=T)

## ----Confusion_Model2,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 2. Columns show predicted values and rows show observed values.  Agreement indicated on diagonal and accuracy for each trophic state indicated in 'Class Accuracy' column.  \\label{tab:Confusion_Model2}",cache=FALSE----
cm2<-round(all_ts3_rf$confusion,2)
cm2[,4]<-paste0((1-cm2[,4])*100,"%")
dimnames(cm2)[[2]][4]<-'Class Accuracy'
kable(cm2,row.names=T)

## ----Confusion_Model3,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 3. Columns show predicted values and rows show observed values.  Agreement indicated on diagonal and accuracy for each trophic state indicated in 'Class Accuracy' column. \\label{tab:Confusion_Model3}",cache=FALSE----
cm3<-round(all_ts2_rf$confusion,2)
cm3[,3]<-paste0((1-cm3[,3])*100,"%")
dimnames(cm3)[[2]][3]<-'Class Accuracy'
kable(cm3,row.names=T)

## ----Confusion_Model4,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 4. Columns show predicted values and rows show observed values.  Agreement indicated on diagonal and accuracy for each trophic state indicated in 'Class Accuracy' column. \\label{tab:Confusion_Model4}",cache=FALSE----
cm4<-round(gis_ts4_rf$confusion,2)
cm4[,5]<-paste0((1-cm4[,5])*100,"%")
dimnames(cm4)[[2]][5]<-'Class Accuracy'
kable(cm4,row.names=T)

## ----Conufsion_Model5,results="asis",echo=FALSE, tab.cap="Random Forest confusion matrix for Model 5. Columns show predicted values and rows show observed values.  Agreement indicated on diagonal and accuracy for each trophic state indicated in 'Class Accuracy' column. \\label{tab:Confusion_Model5}",cache=FALSE----
cm5<-round(gis_ts3_rf$confusion,2)
cm5[,4]<-paste0((1-cm5[,4])*100,"%")
dimnames(cm5)[[2]][4]<-'Class Accuracy'
kable(cm5,row.names=T)

## ----Confusion_Model6,results="asis",echo=FALSE, tab.cap="Random forest confusion matrix for Model 6. Columns show predicted values and rows show observed values.  Agreement indicated on diagonal and accuracy for each trophic state indicated in Class Accuracy' column. \\label{tab:Confusion_Model6}",cache=FALSE----
cm6<-round(gis_ts2_rf$confusion,2)
cm6[,3]<-paste0((1-cm6[,3])*100,"%")
dimnames(cm6)[[2]][3]<-'Class Accuracy'
kable(cm6,row.names=T)

## ----data_def, results="asis",echo=FALSE,cache=FALSE---------------------
kable(data_def,row.names=FALSE)

