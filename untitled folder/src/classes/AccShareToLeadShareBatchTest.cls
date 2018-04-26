/**
*   Test class for AccShareToLeadShareBatch
*   Author Nikolay Iliaev
*   taskid PLR-1385
*   @class AccShareToLeadShareBatchTest
*   @module Lead
*/
@isTest
private class AccShareToLeadShareBatchTest {
	
    /**
    * Method get relevant data
    * Nikolay Iliaev
    * @method setupTestData	
    * @return {Void}*     
    * @module Lead
    */
    @testSetup
    static void setupTestData() {
    	
        List<Lead> leadList =  new List<Lead>();

        id neededRecordTypeId = RecordTypeService.getRecordTypeIdByName('Lead','Offer');

        Account acc = TestFactory.testCreateAccountAndContact();
        
        Lead leadClone = TestFactory.testCreateLeadWithCellExtID();
        
        leadClone.Status = 'LST01';
        leadClone.LeadSource = 'LSO14';
        leadClone.AccountId__c = acc.Id;
        leadClone.RecordTypeId = neededRecordTypeId;
        leadList.add(leadClone);

    	Database.insert(leadList);
		
    }
    
    /**
    * Method copy account share to lead share 
    * Nikolay Iliaev
    * @method copyAccShareToLeadShare	
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void copyAccShareToLeadShare() {
    	
    	Lead lead = [SELECT id, Status, LeadSource ,AccountId__c, RecordTypeId 
    				FROM Lead];
    	 	
    	Test.startTest();
    		AccShareToLeadShareBatch batch = new AccShareToLeadShareBatch();
			ID batchprocessid = Database.executeBatch(batch);
    	Test.stopTest();
        
        List<AccountShare> accShareList = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause
   											 FROM AccountShare
   											 WHERE AccountId =: lead.AccountId__c];
        
        List<LeadShare> leadShareList = [SELECT id, UserOrGroupId, RowCause, LeadId, LeadAccessLevel 
                               FROM leadshare 
                               WHERE LeadId =: lead.id];
        
        System.assertEquals(accShareList.size(), leadShareList.size());
		
    }
}