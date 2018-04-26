/**
* Class batch to copy Account share to Lead share
* Nikolay Iliaev
* taskid PLR-1385
* @class AccShareToLeadShareBatch
* @module Leads
*/
global class AccShareToLeadShareBatch implements Database.Batchable<sObject> {
    
	private Set<Id> accIdSet = new Set<Id>();
	private List<LeadShare> leadShareList = new List<LeadShare>();
   	private List<Lead> leadIdList;
   	private Map<Id,List<Lead>> accIdLeadIdMap = new Map<Id,List<Lead>>();
    
    /**
	* Start method
	* Nikolay Iliaev
	* taskid PLR-1385
	* @class start
	* @module Leads
	*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator('Select id, Name, AccountId__c, OwnerId   from lead WHERE (Status = \'LST01\') AND (LeadSource = \'LSO14\') AND (RecordType.DeveloperName=\'Offer\') AND (AccountId__c <> NULL)');
   }
   
    /**
	* Execute method
	* Nikolay Iliaev
	* taskid PLR-1385
	* @class execute
	* @module Leads
	*/
   global void execute(Database.BatchableContext info, List<Lead> scope) {
   	
   		for (Lead leadItem : scope) {
   			accIdSet.add(leadItem.AccountId__c);
   		}
   		
   		for (Id IdItaem : accIdSet) {
   			leadIdList = new List<Lead>();
   			for (Lead leadItem : scope) {
   				if(IdItaem == leadItem.AccountId__c) {
   					leadIdList.add(leadItem);
   				}
   			}
   			accIdLeadIdMap.put(IdItaem,leadIdList);
   		}
   		
   		
   		List<AccountShare> accShareList = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel,
   											 CaseAccessLevel, ContactAccessLevel, RowCause, LastModifiedDate, LastModifiedById,
   											 IsDeleted 
   											 FROM AccountShare
   											 WHERE AccountId =: accIdSet AND (RowCause  = 'Manual')];
   										 
   		for (AccountShare accShareItem : accShareList) {
   			
   			for(Lead LeadItem : accIdLeadIdMap.get(accShareItem.AccountId)) {
   				
   				if(!(LeadItem.OwnerId == accShareItem.UserOrGroupId)) {
	   				leadShareList.add(new LeadShare(LeadId = LeadItem.Id, 
									   				UserOrGroupId = accShareItem.UserOrGroupId,
   									   				LeadAccessLevel = (accShareItem.RowCause=='Owner') ? 'Edit' : accShareItem.AccountAccessLevel,
									   				RowCause = 'Manual'));
   				}
   			}
   		}
   		
   		DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION, leadShareList,false);
   }
   
   global void finish(Database.BatchableContext BC) {}
       
}