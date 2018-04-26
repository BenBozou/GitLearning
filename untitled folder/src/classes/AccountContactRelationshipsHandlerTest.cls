@isTest
public with sharing class AccountContactRelationshipsHandlerTest {
    
    static testMethod void accConRelationshipsHandlerTest() {
    	 Map<String,Object> settings = new Map<String,Object>{
        'createlookupobject' => false,
        'countObjects' => 1};
    	
    	AccountContactRelationshipsHandler.allowAccountContactRelation = true;
    	
    	Test.startTest();
        Account acc = TestFactory.testCreateAccountAndContact();
        List<AccountContactRelation> accountContactRelationList = [SELECT RoleFunction__c FROM AccountContactRelation WHERE AccountId =: acc.id limit 1];
        accountContactRelationList[0].RoleFunction__c = 'P';
        update accountContactRelationList;

        Test.stopTest();
    
    }
}