/**
* Service class for handle Odata CallBack: 
* To check creation is successfull and to update Lead record
* If there is any failure in the process, Lead should be updated to some Invalid  Status or Record Type
* Eric Fishman
* taskid PLR-805
* @class OdataSaveCallBackService
* @module Lead 
*/


 
global without sharing class OdataSaveCallBackService  extends DataSource.AsyncSaveCallback{
    
    
    
/**
    * Method that implements AsyncSaveCallback interface - to check and to get external Id
    * Eric Fishman
    * @method processSave   
    * @param {SaveResult} sr
    * @return {void}*       
    * @module Lead 
*/  
    override global void processSave (Database.SaveResult sr){try{
    System.debug(LoggingLevel.ERROR,'>>>> callback  processSave: ' + sr);
    
        if (sr.isSuccess ()){           
            System.debug(LoggingLevel.ERROR,'>>>> callback  External sr: ' + sr);
            System.debug(LoggingLevel.ERROR,'>>>> callback  External SequenceID: ' + sr.getId());
            String xId = sr.getId();
            
            //String cellcomExternalId;
            // Get External record to get OSB Sequence ID
        //    Leads__x leadX =  [select sequence_id__c, transactionId__c from Leads__x where Id =:xId limit 1];
                                     
          list<sobject> lleadx = ExternalObjectHandler.getXRecords('Leads__x', 
                                      'select sequence_id__c, transactionId__c from Leads__x where Id =\''+xId+'\' limit 1',
                                      new map<String, Object>{'sequence_id__c' => '123'});
               
                                             
             Leads__x leadx = (Leads__x) lleadx.get(0);
                                     
            System.debug(LoggingLevel.ERROR,'>>>> callback  leadX: ' + leadX);
            
            if (leadX !=null){                  
                // Update Lead record with Cellcom External ID
                updateLeadCellcomId(leadX);
            }         
        }
        else{
            // Lead should be update to Not Validated (recommended - new record type)
            /*
            TBD
            */
            System.debug(LoggingLevel.ERROR,'>>>> callback Failed: ' + sr);
        }}
        catch(exception e){
            system.debug('###' + e);
        }
    }
    
    
    
    /**
    * Method to update Lead with Cellcom external Id
    * Eric Fishman
    * @method updateLeadCellcomId   
    * @param {SaveResult} sr
    * @return {void}*     
    * @module Lead 
*/      
    public void updateLeadCellcomId(Leads__x leadX){
        
        List<Lead> leadList = new List<Lead>();
        System.debug(LoggingLevel.ERROR,'>>>> callback leadX: ' + leadX );
        Lead lead = [select Id, CellcomExternalID__c from Lead where ID =:leadX.transactionId__c limit 1];
        
        if (lead != null){
            lead.CellcomExternalID__c =  leadX.sequence_id__c;          
            update lead;            
        }
        else{
            // Lead should be update to Not Validated (recommended - new record type)
                /*
            TBD
            */
        
        }
        
        
    }
    
    
 
}