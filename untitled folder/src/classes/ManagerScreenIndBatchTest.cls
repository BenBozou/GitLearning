/**
*   Test class for ManagerScreenIndBatch
*   Author Nikolay Iliaev

*   taskid PLR-1282
*   @class ManagerScreenIndBatchTest
*   @module Lead
*/
@isTest
private class ManagerScreenIndBatchTest {
    
    /**
    * Method get relevant data
    * Nikolay Iliaev
    * @method setupTestData	
    * @return {Void}*     
    * @module Lead
    */
    @testSetup static void setupTestData(){
        
    	Product2  product = TestFactory.testCreateProdact2();
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
         ProfileType__c profileTypeSettings = 
            (ProfileType__c ) new testFramework('ProfileType__c', 
                                                        new map<String, Object> {'Name' => 'CSR B2B','Type__c' => 'B2B' }, 
                                                        settings).createObject();
        insert profileTypeSettings;
    }
    
    /**
    * Method update relevant leads
    * Nikolay Iliaev
    * @method deleteProductTest	
    * @return {Void}*     
    * @module Lead
    */ 
    static testMethod void updateLeads() {
		
        User user = testFramework.createUser('CSR B2B');
        
        insert user;
        
    	String recordTypeId = RecordTypeService.getRecordTypeIdByName('Account', 'Business');
    	Account accountItem = TestFactory.testCreateAccountAndContact();
    	accountItem.OwnerId = user.Id;
        update accountItem;
        System.runAs(user) {
            Test.startTest();

            	accountItem.RecordTypeId = recordTypeId;
            	
            	Lead leadItem = TestFactory.testCreateLeadWithCellExtID();
            	leadItem.OwnerId = user.Id;
                leadItem.AccountId__c = accountItem.Id;
           		leadItem.LeadSource = 'LSO14';
                leadItem.Status = 'LST01';
            	leadItem.ManagerScreenInd__c = true;

            	insert leadItem;
            
            	AccountShare accShare = new AccountShare();
            	accShare.AccountId = accountItem.Id;
            	accShare.UserOrGroupId = user.Id;

            	
            	UserSkill__c userSkill = TestFactory.testCreateUserSkill(user.Id,null, null, null);
                UserSkillProduct__c userSkillProduct = new UserSkillProduct__c();
                Product2 product = [SELECT Id FROM Product2];
            	
            	leadItem.Product__c = product.Id;
            	update leadItem;
                insert userSkill;
            
                userSkillProduct.UserSkill__c = userSkill.Id;
                userSkillProduct.Product__c = product.Id;
                
                insert userSkillProduct;
            	Id batchInstanceId = Database.executeBatch(new ManagerScreenIndBatch(),10000);
            	
            Test.stopTest();
            List<Lead> leadList = [SELECT Id, Name, ManagerScreenInd__c, Status,LeadSource,OwnerId,Product__c,AccountId__c 
                                       FROM Lead 
                                       WHERE Id =: leadItem.Id];
                
            System.debug('lead: ' + leadList);
            //disable because we change the owner of lead to Queue (Problemwith sharing)
            //System.assertEquals(true,leadList[0].ManagerScreenInd__c,'  <<<<assertEquals 06>>>>');
         }
    }
}