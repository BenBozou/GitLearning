/**
*   Test class for testing CollabCardService
*   @class CollabCardServiceTest
*   Gili Yehuda
*   @module 360
*/
@isTest
public class CollabCardServiceTest {
	
	/**
	*   method for testing getAccsForCollaboration
	*   Gili Yehuda
	*   @method testCollabCardService
	*   @private
	*   @return void
	*/
	
	@isTest private static void testCollabCardService() { 
		Map<String,Object> inMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();
  
        Account acc =  TestFactory.testCreateAccountWithBillingAccsCollab();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];
                
        inMap.put('accountId', acc.Id);
        inMap.put('contactId', con.Id);
		Test.startTest();
			CollabCardService ctrl = new CollabCardService();
        	system.debug('inMap before calling method' + inMap);
			Boolean result = ctrl.invokeMethod('getAccsForCollaboration', inMap, outMap, optionMap);
			system.assertEquals(true, result);                              
		Test.stopTest();
	}
}