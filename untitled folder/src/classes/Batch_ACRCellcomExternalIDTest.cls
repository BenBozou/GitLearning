/**
*   Test class for testing Batch_ACRCellcomExternalID
*   @class Batch_ACRCellcomExternalIDTest
*   Gili Yehuda
*   taskid PLR-1134
*   @module 360
*/
@isTest
public class Batch_ACRCellcomExternalIDTest {
	static testMethod void testBatch_ACRCellcomExternalID(){
		
    	TestFactory.testCreateAccountContactRelation();
    	
    	Test.startTest();
    	
    		Batch_ACRCellcomExternalID batchACR= new Batch_ACRCellcomExternalID();
			ID batchprocessid =	Database.executeBatch(batchACR);
			
		Test.stopTest();
		
		system.assertEquals(false, batchprocessid == null);
		   
	} 
}