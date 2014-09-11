
```{r nla_map,echo=FALSE,fig.cap=cap_num('Map of 2007 National Lake Assessment Sample Locations','figure')}
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
#ggsave("figure/nla_map.jpg",nlaMap(state,lakes_dd,mycolor),
#       width=18,units="in",dpi=600)
```
**Predicting Trophic State with Random Forests**
  
  Random forest is a machine learning algorithm that aggregates numerous decision trees in order to obtain a consensus prediction of the response categories [@breiman2001random].  Bootstrapped sample data is recursively partitioned according to a given random subset of predictor variables and completely grown without pruning.   With each new tree, both the sample data and predictor variable subset is randomly selected.  

While random forests are able to handle numerous correlated variables without a decrease in prediction accuracy, unusually large numbers of related variables can reduce accuracy and increase the chances of over-fitting the model.  This is a problem often faced in gene selection and in that field, a variable selection method based on random forest has been succesfully applied [@diaz2006gene].  We use varselRF in R to initially examine the importance of the water quality and GIS derived variables and select a subset, the reduced model, to then pass to random forest[@diaz-uriarte2010varSelRF]. 

Using R’s randomForest package, we pass the reduced models selected with varSelRF and calculate confusion matrices, overall accuracy and kappa coeffecient [@liaw2002randomForest]. From the reduced model random forests we collect a consensus prediction and calculate a confusion matrix and summary stats.

**Model Details**
  
  Using a combination of the `varSelRF` and `randomForest` we ran models for six combinations of variables and trophic state classifications.  These combinations included different combinations of the Chlorphyll *a* trophic states (Table 2) along with all variables and the GIS only variables (i.e. no *in situ* infromation).  The six model combinations were:
  
  1. Chlorophyll *a* trophic state - 4 class = All variables (*in situ* water quality, lake morphometry, and landscape)
2. Chlorophyll *a* trophic state - 3 class = All variables (*in situ* water quality, lake morphometry, and landscape)
3. Chlorophyll *a* trophic state - 2 class = All variables (*in situ* water quality, lake morphometry, and landscape)
4. Chlorophyll *a* trophic state - 4 class = All variables (lake morphometry, and landscape)
5. Chlorophyll *a* trophic state - 3 class = All variables (lake morphometry, and landscape)
6. Chlorophyll *a* trophic state - 2 class = All variables (lake morphometry, and landscape)

```{r trophicStateTable, results='asis', echo=FALSE, fig.cap="Table 2. Chlorphyll a based trophic state cut-offs"}
ts_4<-c("oligo","meso","eu","hyper")
ts_3<-c("oligo","meso/eu","meso/eu","hyper")
ts_2<-c("oligo/meso","oligo/meso","eu/hyper","eu/hyper")
co<-c("<= 0.2",">2-7",">7-30",">30")
xdf<-data.frame(ts_4,ts_3,ts_2,co)
names(xdf)<-c("Trophic State (4)","Trophic State (3)","Trophic State (2)","Cut-off")
kable(xdf)
#dfToImage(xdf,style="css/texttable.css",file="figure/ts_classes_table.jpg")
```

##Results

```{r figSetup,echo=FALSE,eval=T,cache=TRUE}
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
```

###Model 1: 4 Trophic States ~ All Variables

```{r ALL_TS4, echo=FALSE, eval=FALSE, cache=TRUE}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
all_ts4<-iterVarSelRF(hkm2014Data[predictors_all],hkm2014Data$TS_CHLA_4,numCore=4,100,
                      ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
                      vars.drop.num=1,outStr="all_ts4",time=TRUE)
```

```{r ALL_TS4_rf,echo=FALSE,eval=FALSE,cache=T}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
all_ts4_vars<-unique(unlist(all_ts4[1:100]))
all_ts4_rf<-runRandomForest(hkm2014Data[all_ts4_vars],hkm2014Data$TS_CHLA_4, ntree=10000,importance=TRUE,proximity=TRUE)
```


```{r Figure_Model1,results="asis",echo=FALSE, dev="jpeg", fig.width=8, fig.height=8}
#dfToImage(sumTable(all_ts4[1:100]),file="figure/all_ts4_table.jpg",
#         style="css/sumtable.css",width=8,include.rownames=FALSE)
#dfToImage(formatC(round(all_ts4_rf$confusion,2)),file="figure/all_ts4_confusion.jpg",
#          style="css/confusiontable.css",width=8,include.rownames=TRUE)
kable(sumTable(all_ts4[1:100]),row.names=F)
kable(formatC(round(all_ts4_rf$confusion,2)),row.names=F)


all_ts4_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts4_vars]
importancePlot(all_ts4_rf,'acc',size=10,aes(colour=all_ts4_color))
importancePlot(all_ts4_rf,'gini',size=10,aes(colour=all_ts4_color))
```

Total accuracy for Model 1 is `r round(classAgreement(all_ts4_rf$confusion[,1:4])$diag,3)`% and the Cohen's Kappa is `r round(classAgreement(all_ts4_rf$confusion[,1:4])$kappa,3)`.


###Model 2: 3 Trophic States ~ All Variables

```{r ALL_TS3, echo=FALSE, eval=FALSE, cache=TRUE}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
all_ts3<-iterVarSelRF(hkm2014Data[predictors_all],hkm2014Data$TS_CHLA_3,numCore=4,100,
ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
vars.drop.num=1,outStr="all_ts3",time=TRUE)
```


```{r all_TS3_rf,echo=FALSE,eval=FALSE,cache=T}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
all_ts3_vars<-unique(unlist(all_ts3[1:100]))
all_ts3_rf<-runRandomForest(hkm2014Data[all_ts3_vars],hkm2014Data$TS_CHLA_3, ntree=10000,importance=TRUE,proximity=TRUE)
```

```{r Figure_Model2,results="asis",echo=FALSE, dev="jpeg", fig.width=8, fig.height=8}
#dfToImage(sumTable(all_ts3[1:100]),file="figure/all_ts3_table.jpg",
#          style="css/sumtable.css",width=8,include.rownames=FALSE)
#dfToImage(formatC(round(all_ts3_rf$confusion,2)),file="figure/all_ts3_confusion.jpg",
#          style="css/confusiontable.css",width=8,include.rownames=TRUE)
kable(sumTable(all_ts3[1:100]),row.names=F)
kable(formatC(round(all_ts3_rf$confusion,2)),row.names=F)

all_ts3_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts3_vars]
importancePlot(all_ts3_rf,'acc',size=10,aes(colour=all_ts3_color))
importancePlot(all_ts3_rf,'gini',size=10,aes(colour=all_ts3_color))
```


Total accuracy for Model 2 is `r round(classAgreement(all_ts3_rf$confusion[,1:3])$diag,3)`% and the Cohen's Kappa is `r round(classAgreement(all_ts3_rf$confusion[,1:3])$kappa,3)`.

###Model 3: 2 Trophic States ~ All Variables

```{r ALL_TS2, echo=FALSE, eval=FALSE, cache=TRUE}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
all_ts2<-iterVarSelRF(hkm2014Data[predictors_all],hkm2014Data$TS_CHLA_2,numCore=4,100,
                      ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
                      vars.drop.num=1,outStr="all_ts2",time=TRUE)
```


```{r all_TS2_rf,echo=FALSE,eval=FALSE,cache=T}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
all_ts2_vars<-unique(unlist(all_ts2[1:100]))
all_ts2_rf<-runRandomForest(hkm2014Data[all_ts2_vars],hkm2014Data$TS_CHLA_2, ntree=10000,importance=TRUE,proximity=TRUE)
```

```{r Figure_Model3,results="asis",echo=FALSE, dev="jpeg", fig.width=8, fig.height=8}
#dfToImage(sumTable(all_ts2[1:100]),file="figure/all_ts2_table.jpg",
#          style="css/sumtable.css",width=8,include.rownames=FALSE)
#dfToImage(formatC(round(all_ts2_rf$confusion,2)),file="figure/all_ts2_confusion.jpg",
#          style="css/confusiontable.css",width=8,include.rownames=TRUE)
kable(sumTable(all_ts2[1:100]),row.names=F)
kable(formatC(round(all_ts2_rf$confusion,2)),row.names=F)

all_ts2_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%all_ts2_vars]
importancePlot(all_ts2_rf,'acc',size=10,aes(colour=all_ts2_color))
importancePlot(all_ts2_rf,'gini',size=10,aes(colour=all_ts2_color))
```

Total accuracy for Model 3 is `r round(classAgreement(all_ts2_rf$confusion[,1:2])$diag,3)`% and the Cohen's Kappa is `r round(classAgreement(all_ts2_rf$confusion[,1:2])$kappa,3)`.

###Model 4: 4 Trophic States ~ GIS Only Variables

```{r GIS_TS4, echo=FALSE, eval=FALSE, cache=TRUE}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
gis_ts4<-iterVarSelRF(hkm2014Data[predictors_gis],hkm2014Data$TS_CHLA_4,numCore=4,100,
ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
vars.drop.num=1,outStr="gis_ts4",time=TRUE)
```

```{r GIS_TS4_rf,echo=FALSE,eval=FALSE,cache=T}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
gis_ts4_vars<-unique(unlist(gis_ts4[1:100]))
gis_ts4_rf<-runRandomForest(hkm2014Data[gis_ts4_vars],hkm2014Data$TS_CHLA_4, ntree=10000,importance=TRUE,proximity=TRUE)
```

```{r Figure_Model4,results="asis",echo=FALSE, dev="jpeg", fig.width=8, fig.height=8,fig.cap="Figure 1"}
#dfToImage(sumTable(gis_ts4[1:100]),file="figure/gis_ts4_table.jpg",
#          style="css/sumtable.css",width=8,include.rownames=FALSE)

#dfToImage(formatC(round(gis_ts4_rf$confusion,2)),file="figure/gis_ts4_confusion.jpg",
#          style="css/confusiontable.css",width=8,include.rownames=TRUE)
kable(sumTable(gis_ts4[1:100]),row.names=F)
kable(formatC(round(gis_ts4_rf$confusion,2)),row.names=F)

gis_ts4_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts4_vars]
importancePlot(gis_ts4_rf,'acc',size=10,aes(colour=gis_ts4_color))
importancePlot(gis_ts4_rf,'gini',size=10,aes(colour=gis_ts4_color))
```

Total accuracy for Model 4 is `r round(classAgreement(gis_ts4_rf$confusion[,1:4])$diag,3)`% and the Cohen's Kappa is `r round(classAgreement(gis_ts4_rf$confusion[,1:4])$kappa,3)`.

###Model 5: 3 Trophic States ~ GIS Only Variables

```{r GIS_TS3, echo=FALSE, eval=FALSE, cache=TRUE}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
gis_ts3<-iterVarSelRF(hkm2014Data[predictors_gis],hkm2014Data$TS_CHLA_3,numCore=4,100,
                      ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
                      vars.drop.num=1,outStr="gis_ts3",time=TRUE)
```

```{r GIS_TS3_rf,echo=FALSE,eval=FALSE,cache=TRUE}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
gis_ts3_vars<-unique(unlist(gis_ts3[1:100]))
gis_ts3_rf<-runRandomForest(hkm2014Data[gis_ts3_vars],hkm2014Data$TS_CHLA_3, ntree=10000,importance=TRUE,proximity=TRUE)
```

```{r Figure_Model5,results="asis",echo=FALSE, dev="jpeg", fig.width=8, fig.height=8}
#dfToImage(sumTable(gis_ts3[1:100]),file="figure/gis_ts3_table.jpg",
#          style="css/sumtable.css",width=8,include.rownames=FALSE)
#dfToImage(formatC(round(gis_ts3_rf$confusion,2)),file="figure/gis_ts3_confusion.jpg",
#          style="css/confusiontable.css",width=8,include.rownames=TRUE)
kable(sumTable(gis_ts3[1:100]),row.names=F)
kable(formatC(round(gis_ts3_rf$confusion,2)),row.names=F)

gis_ts3_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts3_vars]
importancePlot(gis_ts3_rf,'acc',size=10,aes(colour=gis_ts3_color))
importancePlot(gis_ts3_rf,'gini',size=10,aes(colour=gis_ts3_color))
```

Total accuracy for Model 5 is `r round(classAgreement(gis_ts3_rf$confusion[,1:3])$diag,3)`% and the Cohen's Kappa is `r round(classAgreement(gis_ts3_rf$confusion[,1:3])$kappa,3)`.

###Model 6: 2 Trophic States ~ GIS Only Variables

```{r GIS_TS2, echo=FALSE, eval=FALSE, cache=TRUE}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
gis_ts2<-iterVarSelRF(hkm2014Data[predictors_gis],hkm2014Data$TS_CHLA_2,numCore=4,100,
ntree=10000,ntreeIterat=5000,vars.drop.frac=NULL,
vars.drop.num=1,outStr="gis_ts2",time=TRUE)
```

```{r GIS_TS2_rf,echo=FALSE,eval=FALSE,cache=TRUE}
#Included for completeness.  Results already run in another project
#Those results loaded via lazyLoad in setup chunk
gis_ts2_vars<-unique(unlist(gis_ts2[1:100]))
gis_ts2_rf<-runRandomForest(hkm2014Data[gis_ts2_vars],hkm2014Data$TS_CHLA_2, ntree=10000,importance=TRUE,proximity=TRUE)
```

```{r Figure_Model6,results="asis",echo=FALSE, dev="jpeg", fig.width=8, fig.height=8}
#dfToImage(sumTable(gis_ts2[1:100]),file="figure/gis_ts2_table.jpg",
#          style="css/sumtable.css",width=8,include.rownames=FALSE)
#dfToImage(formatC(round(gis_ts2_rf$confusion,2)),file="figure/gis_ts2_confusion.jpg",
#          style="css/confusiontable.css",width=8,include.rownames=TRUE)
kable(sumTable(gis_ts2[1:100]),row.names=F)
kable(formatC(round(gis_ts2_rf$confusion,2)),row.names=F)

gis_ts2_color<-col_lu[["hexcode"]][col_lu[["variables"]]%in%gis_ts2_vars]
importancePlot(gis_ts2_rf,'acc',size=10,aes(colour=gis_ts2_color))
importancePlot(gis_ts2_rf,'gini',size=10,aes(colour=gis_ts2_color))
```

Total accuracy for Model 6 `r round(classAgreement(gis_ts2_rf$confusion[,1:2])$diag,3)`% and the Cohen's Kappa is `r round(classAgreement(gis_ts2_rf$confusion[,1:2])$kappa,3)`.

###Associating Trophic State and Cyanobacteria

```{r ts_4_biov, echo=FALSE, dev="jpeg", fig.width=8, fig.height=8}
plotCdf(hkm2014Data$TS_CHLA_4,hkm2014Data$sumBioV+1,
                                     cdf_colors=zissou[6:9],y='Percent',
                                     x='Log10(Cyanobacteria Biovolume)',
                                     title=expression(paste('CDF for Chlorophyll ', 
                                     italic("a"),' Trophic States (4 Categories)')),
                                     color="Trophic State\nCategories")
```

```{r ts_3_biov, echo=FALSE, dev="jpeg", fig.width=8, fig.height=8}
plotCdf(hkm2014Data$TS_CHLA_3,hkm2014Data$sumBioV+1,cdf_colors=zissou[6:8],
       y='Percent',x='Log10(Cyanobacteria Biovolume)',
       title=expression(paste('CDF for Chlorophyll ', italic("a"),' Trophic States (3 Categories)')),
       color="Trophic State\nCategories")
```

```{r ts_2_biov, echo=FALSE, dev="jpeg", fig.width=8, fig.height=8}
plotCdf(hkm2014Data$TS_CHLA_2,hkm2014Data$sumBioV+1,cdf_colors=zissou[6:7],
       y='Percent',x='Log10(Cyanobacteria Biovolume)',
       title=expression(paste('CDF for Chlorophyll ', italic("a"),' Trophic States (2 Categories)')),
       color="Trophic State\nCategories")
```

```{r scatterplot,echo=FALSE, dev="jpeg", fig.width=8, fig.height=8}
scp_df<-data.frame(chla=hkm2014Data[["CHLA"]],biovp1=hkm2014Data[["sumBioV"]]+1)
scatterPlot(scp_df,xvar="chla",yvar="biovp1",zissou[8],zissou[7],zissou[6],
             title=expression(paste("Chlorophyll ", italic("a")," and Cyanobacteria Relationship")),
             x=expression(paste('Log10(Chl ', italic("a"),')')),
             y="Log10(Cyanobaterial Biovolumes + 1)")
```
