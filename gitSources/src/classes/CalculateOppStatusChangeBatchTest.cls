/**
*   Test class for CalculateLeadStatusChangeBatch process
*   Author Eric Fishman
*   taskid PLR-
*   @class CalculateLeadStatusChangeBatchTest
*   @module Contact
*/
@isTest
private class CalculateOppStatusChangeBatchTest {
    
     /**
    *   Method for setup test data
    *   Author Eric Fishman
    *   @method setupTestData
    *   @return void
    */
    @testSetup 
    static void setupTestData(){
    	
    	User u = TestFactory.testCreateUser();       
        Opportunity opp = TestFactory.testCreateOpportunity();
			
    }
    
    static testMethod void CalculateOppStatusTest() {
        
        Test.StartTest();
        
        Id batchJobId = Database.executeBatch(new CalculateOppStatusChangeBatch(), 10);
           
         Test.StopTest();
    }
    

}