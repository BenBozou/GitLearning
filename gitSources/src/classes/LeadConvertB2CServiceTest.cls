/**
*   Test class for LeadConvertB2CService
*   Author Nikolay Iliaev
*   taskid PLR-42
*   @class LeadConvertB2CServiceTest
*   @module Contact
*/
@isTest 
private class LeadConvertB2CServiceTest {
    
    /**
    * Method get relevant data
    * Nikolay Iliaev
    * @method setupTestData	
    * @return {Void}*     
    * @module Lead
    */
    @testSetup static void setupTestData(){
    	Lead lead = TestFactory.testCreateLeadWithCellExtID();
    	
    	system.debug(LoggingLevel.ERROR, 'Lead >>>> ' + lead);
    }
    
    /**
    * Method tests lead convert
    * Nikolay Iliaev
    * @method LeadConvertB2CServiceTest	
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void LeadConvertB2CServiceTest(){

		Test.startTest();
			Contact contact = TestFactory.testCreateContactAndAccountWithCellExtID();
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
    	
    		String[] Ctrls = new String[]{'Contact'};
			for (String Item : Ctrls) {
				Type handlerType = Type.forName(Item + 'Handler');
				triggerHandler.triggerInterface CTRL = (triggerHandler.triggerInterface) handlerType.newInstance();
				//system.debug(LoggingLevel.ERROR,'INTR_' + Item);
				//Ctrl.updateRecords();
				Ctrl.deleteRecords();
				Ctrl.undeleteRecords();
				//Ctrl.updateRecords();
			}
			
		Test.stopTest();
    }
}