/**
*   Test class for CalculateLeadStatusChangeBatch process
*   Author Eric Fishman
*   taskid PLR-
*   @class CalculateLeadStatusChangeBatchTest
*   @module Contact
*/
@isTest
private class CalculateLeadStatusChangeBatchTest {
    
     /**
    *   Method for setup test data
    *   Author Eric Fishman
    *   @method setupTestData
    *   @return void
    */
    @testSetup 
    static void setupTestData(){
    	
    	User u = TestFactory.testCreateUser();
        
        //Lead lead = TestFactory.testCreateLeadWithCellExtID();
        //insert lead;  
        //system.debug('LEad 1: ' + lead);        
        
        
        
        Lead lead2 = TestFactory.testCreateLead(u.Id);        
        system.debug('LEad 2: ' + lead2);
		
    }
    
    
    static testMethod void CalculateLeadStatusTest() {
        
        Date date1 = Date.newInstance(2006, 3, 16);
		Date date2 = Date.newInstance(2006, 3, 18);
        
        Test.StartTest();
        
        Id batchJobId = Database.executeBatch(new CalculateLeadStatusChangeBatch(), 10);
        
		Integer result = CalculateLeadStatusChangeBatch.daysOff(date1,date2);        
        
        Test.StopTest();
         
         //Leadhistory lh = [select Field from Leadhistory];
         //system.debug('lh 1: ' + lh);
    }

}