

#function to download the NLA2007 phytoplankton data and calculate the abundance (cells/ml) of cyanobacteria by lake
#returns a data.frame with two fields
  # SITE_ID=the NLA site id for the lake
  # cyanoCellsPerML=for each SITE_ID the sum of abundance (cells/ml) of all phytoplankton for Division='Cyanophyta'
  getCyanoAbund<-function(){
    #read the raw data from the EPA website
      Raw<-read.csv('http://water.epa.gov/type/lakes/assessmonitor/lakessurvey/upload/NLA2007_Phytoplankton_SoftAlgaeCount_20091023.csv')
    #subset data-VISIT_NO==1 and Taxonomic Division=='Cyanophyta'
      Cyano<-subset(Raw[,c('SITE_ID','DIVISION','OTU','ABUND')],Raw$VISIT_NO==1 & Raw$DIVISION=='Cyanophyta')
    #Sum cyano abundance across taxa by NLA SITE_ID
      cyanoAbund<-aggregate(Cyano$ABUND,by=list(Cyano$SITE_ID),sum)
    #rename fields and round to 1 decimal place
      names(cyanoAbund)<-c('SITE_ID','cyanoCellsPerML')
      cyanoAbund$cyanoCellsPerML<-round(cyanoAbund$cyanoCellsPerML,1)
    #output data
      return(cyanoAbund)
  }
  
  
  cyanoAbund<-getCyanoAbund()
