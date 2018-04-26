/**
*   Test class for all SandBoxPostCreation
*   
*   @class SandBoxPostCreationTest
*   author Liron Cohen
*   @module TestClass
*   @constructor
*/
@isTest
private class SandBoxPostCreationTest {

    static testMethod void sandBoxPostTest() {
    	
		Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
         EnvironmentSettings__c envSettings = 
            (EnvironmentSettings__c ) new testFramework('EnvironmentSettings__c', 
                                                        new map<String, Object> {'CurrentEnvironment__c' => 'Test'}, 
                                                        settings).createObject();
        insert envSettings;
		
		SandBoxType__c sandboxSetup = 
            (SandBoxType__c ) new testFramework('SandBoxType__c', 
                                                 new map<String, Object> {'name' => 'dev', 'CurrentEnvironment__c' => 'Dev'}, 
                                                 settings).createObject();
        insert sandboxSetup;
		
        Test.startTest();

		Test.testSandboxPostCopyScript(new SandBoxPostCreation(), null, null, 'devW1');
		
        Test.stopTest();
    }
}