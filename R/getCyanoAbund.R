#' Pulls down cyano abundance from NLA website
#' 
#' This function downloads the NLA2007 phytoplankton data and calculates the 
#' abundance (cells/ml) of cyanobacteria by lake
#' @return a data.frame with four fields: SITE_ID=the NLA site id for the lake,
#'          cyanoCellsPerML=for each SITE_ID the sum of abundance (cells/ml)
#'          of all phytoplankton for Division='Cyanophyta', 
#'          cyanoCat=cyano abundance category based on quartile distribution of cyanoCellsPerML 
#'          ('LOW'<= Q1; 'MED' >Q1 and <Q4; 'HIGH' >=Q4), and
#'          mcyst_conc in ug/l 
#'          
#'          
#' @export          

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
    #add field for cyanoCat: 'LOW'<= Q1; 'MED' >Q1 and <Q4; 'HIGH' >=Q4
      cyanoAbund$cyanoCat<-'MED'
      cyanoAbund$cyanoCat[cyanoAbund$cyanoCellsPerML<=quantile(cyanoAbund$cyanoCellsPerML,.25,na.rm=T)]<-'LOW'
      cyanoAbund$cyanoCat[cyanoAbund$cyanoCellsPerML>=quantile(cyanoAbund$cyanoCellsPerML,.75,na.rm=T)]<-'HIGH'
      cyanoAbund$cyanoCat[is.na(cyanoAbund$cyanoCellsPerML)]<-NA
      cyanoAbund$cyanoCat<-factor(cyanoAbund$cyanoCat,levels=c('LOW','MED','HIGH'),ordered=TRUE)
    #get microsystin data
      nla_rec<-read.csv("http://water.epa.gov/type/lakes/assessmonitor/lakessurvey/upload/NLA2007_Recreational_ConditionEstimates_20091123.csv")
      cyanoAbund<-merge(cyanoAbund,nla_rec[,c("SITE_ID","MCYST_TL_UGL")],by="SITE_ID",all.x=T)
    #output data
      return(cyanoAbund)
  }
  
