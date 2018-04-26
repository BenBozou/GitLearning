/**
*   Test class for AccountLogViewController
*   
*   @class AccountLogViewControllerTest
*   author Liron Cohen
*   @module TestClass
*   @constructor
*/
@isTest
private class AccountHandlerTest{

    static testMethod void accountStatus() {
      	triggerHandler.isPreventLoop = false;
      	Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1};
    	
    	Account acc = 
            (Account ) new testFramework('Account', 
                                         new map<String, Object> {	'Name' => 'TestAccount',
                                         							'CellcomExternalID__c' => '1234',
                                         							'RecordTypeId' => RecordTypeService.getRecordTypeIdByName('Account','Business')}, 
                                         settings).createObject();
        insert acc;
        Account accChild = 
            (Account ) new testFramework('Account', 
                                         new map<String, Object> {	'vlocity_cmt__Status__c' =>'Active',
                                             						'ParentId' =>acc.Id,
                                             						'Name' => 'TestAccount',
                                         							'CellcomExternalID__c' => '12345',
                                         							'RecordTypeId' => RecordTypeService.getRecordTypeIdByName('Account','Billing')}, 
                                         settings).createObject();
        	insert accChild;
        
        Test.startTest();
        	
        	
        	Account A = [SELECT Id, vlocity_cmt__Status__c FROM Account WHERE Id=:acc.Id];
        	system.assertEquals(A.vlocity_cmt__Status__c , 'Active');
        	
        	accChild.vlocity_cmt__Status__c = 'Suspended';
        	accChild.NETV_Ind__c = true;
        	accChild.CELL_Ind__c = true;
        	update accChild;
        
        	A = [SELECT Id, vlocity_cmt__Status__c FROM Account WHERE Id=:acc.Id];
        	system.assertEquals(A.vlocity_cmt__Status__c , 'Suspended');
        	
        	accChild.ParentId = null;
        	update accChild;
        
        	A = [SELECT Id, vlocity_cmt__Status__c FROM Account WHERE Id=:acc.Id];
        	system.assertEquals(A.vlocity_cmt__Status__c , 'Inactive');
			
			accChild.ParentId = acc.Id;
        	update accChild;
        	
        	delete accChild;
        Test.stopTest();
    
    }
}