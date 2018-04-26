/**
*   Test class for LeadConvertB2BService Automatic
*   Author Nikolay Iliaev
*   taskid PLR-798
*   @class LeadConvertAutomaticTest
*   @module Leads
*/
@isTest 
private class LeadConvertAutomaticTest {
    
    /**
    * Method test automatic convert lead
    * Nikolay Iliaev
    * @method leadConvertTest	
    * @return {Void}*     
    * @module Lead
    */
    testMethod static void leadConvertTest(){
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        	lead.AutoConvert__c = false;
    		insert lead;
    	Test.startTest();
    		lead.AutoConvert__c = true;
    		update lead;
        Lead LeadItem = [SELECT Id, AutoConvert__c FROM Lead WHERE Id =:lead.Id];
        System.debug('LeadItem: ' + LeadItem);
		Test.stopTest();
    }
    
    /**
    * Method invokes unsued methods in lead handler
    * Nikolay Iliaev
    * @method unusedTestMethod	
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void unusedTestMethod(){
    	
    	Test.startTest();
    	
    		String[] Ctrls = new String[]{'Lead'};
			for (String Item : Ctrls) {
				Type handlerType = Type.forName(Item + 'Handler');
				triggerHandler.triggerInterface CTRL = (triggerHandler.triggerInterface) handlerType.newInstance();
				Ctrl.deleteRecords();
				Ctrl.undeleteRecords();
				//Ctrl.insertRecords();
			}
			
		Test.stopTest();
    }
}