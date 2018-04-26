/**
*   Test class for LoginPolicyConditionTest
*   Author Eric Fishman
*   Taskid PLR-731
*   @class LoginPolicyConditionTest
*   @module Leads
*/
@isTest
private class LoginPolicyConditionTest {
	/**
	*   method to evaluate concurrent sessions
	*   author Eric Fishman
	*   taskId PLR-731
	*   @method evaluate
	*   @param  {TxnSecurity.Event} 
	*   @return {boolean}
	*
	*/
    static testMethod void loginTest() {
         /* Create a map for the event we’re going to build. */
       Map<String, String> eventData = new Map<String, String>();
       
       
    	LoginHistory loginHistoryObj = new LoginHistory();
    	//loginHistoryObj.Platform = '';    	
    	//loginHistoryObj.UserId = userInfo.getUserId();
    	 //loginHistoryObj.Platform = 'Android 4';
    	
    	/* Insert the LoginHistoryId into the event data map. */
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
      	
      	LoginRestrictionPolicyCondition login = new LoginRestrictionPolicyCondition();
        Boolean res = login.evaluate(e);
      	//System.assertEquals(false, login.evaluate(e));
        
    }
}