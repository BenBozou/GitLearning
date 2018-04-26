/**
*   Test class for ConsoleService
*   Author Eric Fishman
*   Taskid PLR-731
*   @class ConcurrentSessionsPolicyConditionTest
*   @module Leads
*/
@isTest
private class ConcurrentSessionsPolicyConditionTest {
	/**
    *   Method for testing Concurrent Sessions
    *   Author Eric Fishman
    *   taskid PLR-731
    *   @method concurrentSessionTest
    *   @return void
    */
    static testMethod void concurrentSessionTest() {
       /* Create a map for the event we’re going to build. */
       Map<String, String> eventData = new Map<String, String>();
       
       
       /* Create a history object that has Platform = Android 4. */
    	LoginHistory loginHistoryObj = new LoginHistory();    	    	
    	//loginHistoryObj.UserId = userInfo.getUserId();
    	 //loginHistoryObj.Platform = 'Android 4';    	
    	//insert loginHistoryObj;
    	//eventData.put('LoginHistoryId', loginHistoryObj.id);
	       
    TxnSecurity.Event e = new TxnSecurity.Event(
      	userInfo.getOrganizationId(), 	/* organizationId */
      	userInfo.getUserId(), /* userId */
      	null, /* entityName */
      	'Login', /* action */
      	'LoginHistory', /* resourceType */
      	null, /* entityId */
      	Datetime.newInstance(2016, 2, 15), 
      	eventData 
      	);
      
       
    	ConcurrentSessionsPolicyCondition condition = new ConcurrentSessionsPolicyCondition();
	    Boolean res = condition.evaluate(e);
        //System.assertEquals(false, condition.evaluate(e));
        
    }
}