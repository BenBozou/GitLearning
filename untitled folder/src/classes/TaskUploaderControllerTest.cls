/**
*   Test class for TaskUploaderController
*   Author Nikolay Iliaev
*   taskid PLR-501
*   @class TaskUploaderControllerTest
*   @module Lead
*/
@isTest
private class TaskUploaderControllerTest {
	
	  /**
    * Method get relevant data
    * Eric Fishman
    * @method setupTestData	
    * @return {Void}*     
    * @module Lead
    */
    @testSetup static void setupTestData(){
        
    	//Product2  product = TestFactory.testCreateProdact2();
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
         OrgSettings__c orgSettings = 
            (OrgSettings__c ) new testFramework('OrgSettings__c', 
                                                        new map<String, Object> {'Name' => 'Org Settings','TaskUploadRecordTypes__c' => 'Collection,CustomerCommitment,General,IntroductionCall,ServiceSatisfaction' }, 
                                                        settings).createObject();
        insert orgSettings;
    }
	
	
	
    testMethod static void uploadCsvFile(){
    	String csv = '[{"ID":"246813579","Collector":"Collector Example","Owner":"DANIELLC","Paying Customer":"Paying Customer1","Description":"Notes","Status":"Collected debt","Update Payment Method":"Yes"},{"ID":"975312468","Collector":"Collector Example2","Owner":"DANIELLC","Paying Customer":"Paying Customer2","Description":"Llalalala","Status":"Updated debt TA","Update Payment Method":"No"}]';
    	Test.startTest();
    		TaskUploaderController taskController = new TaskUploaderController();
    		taskController.csvFile = csv;    		
    		
    		
        	TaskUploaderController.TaskWrapper tt = new TaskUploaderController.TaskWrapper();
        	list<SelectOption> tr = taskController.getTaskRecordTypes();
        	tt.communicationType = 'fdfdfdf';        	
        	
        	taskController.catchCsvFile();
        	taskController.cancel();
		Test.stopTest();
    }
}