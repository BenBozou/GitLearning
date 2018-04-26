/**
*   Test class for AccountLogViewController
*   
*   @class AccountLogViewControllerTest
*   author Liron Cohen
*   @module TestClass 
*   @constructor
*/
@isTest
private class AccountLogViewControllerTest{

    static testMethod void accountLogViewTest() {
      
      	Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1};
    	
    	Account acc = 
            (Account ) new testFramework('Account', 
                                         new map<String, Object> {	'Name' => 'TestAccount',
                                         							'CellcomExternalID__c' => '1234',
                                         							'RecordTypeId' => RecordTypeService.getRecordTypeIdByName('Account','Consumer')}, 
                                         settings).createObject();
        insert acc;
    	
    	EnvironmentSettings__c envSettings = 
            (EnvironmentSettings__c ) new testFramework('EnvironmentSettings__c', 
                                                        new map<String, Object> {'Log_Levels__c' => 'INFO;DEBUG;WARNING;ERROR;FATAL;'}, 
                                                        settings).createObject();
         
        insert envSettings;
        
        Test.startTest();
        //Comment...
        AccountLogViewController accountLogController = 
            new AccountLogViewController(new ApexPages.StandardController(acc));
        accountLogController.logAccount();
        
        list<Log__c> logList = [select id from Log__c where record_Id__c = :acc.id];
        
        system.assertEquals(logList.size() == 1 , true);
        
        Test.stopTest();
    
    }
}