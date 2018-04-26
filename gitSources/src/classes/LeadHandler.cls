public with sharing class LeadHandler implements triggerHandler.triggerInterface {
/**
* Class to handle Lead object trigger:  
* Eric Fishman
* taskid PLR-871
* @class LeadHandler
* @module Lead 
*/
    public void insertRecords() {
        if (!Trigger.isAfter) return;
        
        checkDuplicateWebLead();
    }
    
    
    public void updateRecords() {        
        triggerHandler.isPreventLoop = false;
        
    	
    	if (Trigger.isAfter) {	        
	        UpdatePOLMRecommendations();                
	        convertLeads();
	        
	       // checkLeadOfferStatus((list<Lead>) trigger.new, (map<id, Lead>) trigger.newMap, (map<id, Lead>)trigger.oldMap);
	       TrackingEntityService.writeTrackingEntity(
	           trigger.new, trigger.newMap, trigger.oldMap, 'Lead Status');           
    	}
    }
    
    
    public void deleteRecords() {}
    
    
    
    public void undeleteRecords() {}
    
    

 /**
    * Class to invoke creating and populating Json request for UpdatePOLMRecommendations callout
    * Eric Fishman
    * taskid PLR-871
    * @class 
    * @module Lead 
    */
    
private void UpdatePOLMRecommendations() {
//Call to future class to invoke OSB service
List<Lead> leadList = new List<Lead>();
 	String offerRT = RecordTypeService.getRecordTypeIdByName('Lead','Offer');
    
    set<id> changedLeads = triggerHandler.getIdsOfChangedRecords(trigger.new, trigger.oldMap, new set<string>{'Status', 'SubStatus__c'});
    for (Id item : changedLeads){
        Lead leadItem = (Lead) trigger.newMap.get(item);
        if (leadItem.LeadRecordType__c !='Offer') continue;
        //if (String.isBlank(leadItem.CellcomExternalID__c)) continue;
        
        leadList.add(leadItem);
    }
    
    /*
    for (Lead lead : (List<Lead>) Trigger.new ){        
        Lead oldLead = (Lead)Trigger.oldMap.get(lead.Id);
        
        //getIdsOfChangedRecordsToValueMap
        if (lead.Status !=  oldLead.Status  && (!String.isBlank(lead.CellcomExternalID__c) )) {         
            leadList.add(lead);
            
        }
    }
    */
    system.debug(Logginglevel.INFO,'UpdatePOLMRecommendations leadList: ' + leadList);
    
    if (!leadList.isEmpty()){
        ID jobID = System.enqueueJob(new UpdatePOLMRecommendsService(leadList));
        system.debug(Logginglevel.INFO,'UpdatePOLMRecommendsService Queueable: ' + jobID);  
    }

}
//getIdsOfChangedRecordsToMap(Trigger.New(), )

//public static map < Id, set < String >> getIdsOfChangedRecordsToMap(sObject[] sListNew, map < Id, sObject > sMapOld, set < String > field_names) {

    /**
    * Method to invoke converting all relevat leads
    * Nikolay Iliaev
    * taskid PLR-733
    * @Method convertLeads
    * @return {void}*  
    */
    private void convertLeads(){
        List<Lead> leadList = new List<Lead>();
        
        set<id> changedLeads = triggerHandler.getIdsOfChangedRecords(trigger.new, trigger.oldMap, new set<string>{'AutoConvert__c'});
        
        System.debug(LoggingLevel.ERROR,'>>>> trigger : ' + trigger.new + '-----'+ trigger.oldMap);
        
        for (Id idItem : changedLeads){
            Lead leadItem = (Lead) trigger.newMap.get(idItem);
            
            if(leadItem.AutoConvert__c == true  && leadItem.CellcomExternalID__c != null 
                && leadItem.LeadRecordType__c == 'B2B'){
                if(leadItem.Status == 'LST05' || leadItem.Status == 'LST06'){
                    leadList.add(leadItem);
                }
            }
        }
        System.debug(LoggingLevel.ERROR,'>>>> leadList : ' + leadList);
        
        if(!leadList.isEmpty() && !System.isQueueable()){
            System.enqueueJob(new LeadConvertQueueableService(leadList));
        }
    }
    
    /**
    * Method to check duplicate for Web lead if same lead already exist in with source Unica
    * Eric Fishman
    * taskid PLR-1185
    * @Method checkWebduplicateLeads
    * @return {void}*  
    */
    private void checkDuplicateWebLead(){
        List<Lead> leadList = new List<Lead>();
        Map<String,Id> leadPhoneIdMap = new Map<String,Id>();   // Key: Phone, Value LeadId 
        
        for (Lead item : (List<Lead>)Trigger.new ){
            if(item.LeadSource == 'LSO09' && (!String.isBlank(item.Phone))){
                leadList.add(item);
                leadPhoneIdMap.put(item.Phone, item.Id);
            }   
        }
        
        if(!leadList.isEmpty()){
            CreateLeadService.FindExistingUnicaLead(leadPhoneIdMap);            
        }
    }
}