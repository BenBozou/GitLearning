public with sharing class vlocity_cmt_PremisesHandler implements triggerHandler.triggerInterface {
/**
* Class to handle Premises object trigger:  
* Eric Fishman
* taskid PLR-1446
* @class PremisesHandler
* @module Lead 
*/
public void updateRecords() {	        
	        
        if(trigger.isAfter){
            UpdateLeadsOwner();
        }  
}

public void insertRecords() {}
public void deleteRecords() {}
public void undeleteRecords() {}




/**
    * Method to check duplicate for Web lead if same lead already exist in with source Unica
    * Eric Fishman
    * taskid PLR-1185
    * @Method checkWebduplicateLeads
    * @return {void}*  
    */
	private void UpdateLeadsOwner( ){	
	List<Id> premisesIdList = new List<Id>();
	Map<Id,Id> premisesOwnerMap = new Map<Id,Id>();
	List<Lead> leadUpdateList = new List<Lead>();	
	
	try{
		// get Ids of records where Owner changed
		set<id> changedPremises = triggerHandler.getIdsOfChangedRecords(trigger.new, trigger.oldMap, new set<string>{'OwnerId'});
		// Collect premises records
		for (Id item : changedPremises) {
			vlocity_cmt__Premises__c premiseItem = (vlocity_cmt__Premises__c) trigger.newMap.get(item);		
			
			premisesIdList.add(item);
			premisesOwnerMap.put(item,premiseItem.OwnerId);
			
		}
		//Id ownerId = premisesOwnerMap.get(lead.vlocity_cmt__PremisesId__c);
		UpdateLeads leads = new UpdateLeads(premisesOwnerMap, premisesIdList);
		
		/*	
		OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
		String b2bLeadQueue = orgSettings.LeadB2BQueue__c;
		String b2bLeadRecType = orgSettings.LeadB2BRecordType__c;
		// Find Unassigned Leads by Record Type B2B and Queue Name b2B Leads based on custom settings
		for (Lead lead : [SELECT Id, Name, vlocity_cmt__PremisesId__c 
						 FROM Lead 
						 WHERE vlocity_cmt__PremisesId__c in: premisesIdList and 
						 RecordType.DeveloperName =:b2bLeadRecType and
						 Owner.Name =:b2bLeadQueue]) {		
			lead.OwnerId = premisesOwnerMap.get(lead.vlocity_cmt__PremisesId__c);
			leadUpdateList.add(lead);
		}			
			// Update Leads	
	    	if(!leadUpdateList.isEmpty()){    
	    		DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,leadUpdateList,false);
	    	}
	    	*/
		}
		
	catch (Exception e) {
            System.debug(Logginglevel.ERROR, '>>>> 30 UpdateLeadsOwner Exception: ' + e + ' from: ' + e.getStackTraceString());
        }  
    
}
    
 public without sharing  class UpdateLeads {
 
 	public UpdateLeads(Map<Id,Id> premisesOwnerMap, List<Id> premisesIdList) {
 		List<Lead> leadUpdateList = new List<Lead>();	
 		OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
		String b2bLeadQueue = orgSettings.LeadB2BQueue__c;
		String b2bLeadRecType = orgSettings.LeadB2BRecordType__c;
		
		// Find Unassigned Leads by Record Type B2B and Queue Name b2B Leads based on custom settings
		for (Lead lead : [SELECT Id, Name, vlocity_cmt__PremisesId__c 
						 FROM Lead 
						 WHERE vlocity_cmt__PremisesId__c in: premisesIdList and 
						 RecordType.DeveloperName =:b2bLeadRecType and
						 Owner.Name =:b2bLeadQueue]) {			
			lead.OwnerId = premisesOwnerMap.get(lead.vlocity_cmt__PremisesId__c);
			leadUpdateList.add(lead);
		}			
			// Update Leads	
	    	if(!leadUpdateList.isEmpty()){    
	    		DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,leadUpdateList,false);
	    	}
		}
 
  
 	
 }  
 
  
}