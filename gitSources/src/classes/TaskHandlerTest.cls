/**
*   Test class for TaskHandler class
*   Author Nikolay Iliaev
*   taskid PLR-1363
*   @class TaskHandlerTest
*   @module Task
*/
@isTest
private class TaskHandlerTest {
    /**
    * Method prepares data
    * Nikolay Iliaev
    * @method prepareData	
    * @return {Task}*     
    * @module Task
    */
    @Testsetup
    private static void prepareData() {
        id neededRecordTypeId = RecordTypeService.getRecordTypeIdByName('Task','Get_Next_Lead_Task');
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        insert lead;
        
        Task task = TestFactory.createTask();
        task.RecordTypeId = neededRecordTypeId;
        task.WhoId = lead.Id;
        
        insert task;
    }
    
    /**
    * Method updates lead status 
    * Nikolay Iliaev
    * @method updateLead	
    * @return {Void}*     
    * @module Task
    */
    testMethod static void updateLead() {
        Task updatedTask = [SELECT Id, CallStatusInd__c, WhoId FROM Task LIMIT 1];
        
        Test.startTest();
        	updatedTask.CallStatusInd__c = 'TCSI02';
        	update updatedTask;
        Test.stopTest();
        
        Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :updatedTask.WhoId LIMIT 1];
        System.assertEquals('LST02', updatedLead.Status, 'Assert Equals Lead Test');
    }
    
    /**
    * Method invokes unsued methods in lead handler
    * Nikolay Iliaev
    * @method unusedTestMethod	
    * @return {Void}*     
    * @module Task
    */
    static testMethod void unusedTestMethod(){
    	
    	Test.startTest();
    	
    		String[] Ctrls = new String[]{'Task'};
			for (String Item : Ctrls) {
				Type handlerType = Type.forName(Item + 'Handler');
				triggerHandler.triggerInterface CTRL = (triggerHandler.triggerInterface) handlerType.newInstance();
				
				Ctrl.deleteRecords();
				Ctrl.undeleteRecords();
				Ctrl.insertRecords();
			}
			
		Test.stopTest();
    }
}