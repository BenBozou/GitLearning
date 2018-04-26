/**
*	Test class for testing ContactCardService
*	@class ContactCardServiceTest
*	Elad Iflach
*   taskid PLR-462
*	@module 360
*/
@isTest
private class ContactCardServiceTest {

	/**
	*	method for testing ContactCardService
	*	author Elad Iflach
	*	taskId PLR-462	
	*	@method	cardSvcTest
	*	@return	void	
	*/
	static testMethod void cardSvcTest() {
        
        Account acc = TestFactory.testCreateAccountAndContact();
        
		test.startTest();
		/*Account acc = new Account();
		acc.Name = 'Test acc';				
		insert acc;*/
		
		Map<String,Object> inMap = new Map<String,Object>();
		Map<String,Object> errorInMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();
		inMap.put('accountId', acc.Id);       

		ContactCardService contSvc = new ContactCardService();

		// check for success
		Boolean result = contSvc.invokeMethod('getContactDetails', inMap, outMap, optionMap);
		system.assertEquals(true, result);

		// check for error, no accountId sent
		Boolean failResult = contSvc.invokeMethod('getContactDetails', errorInMap, outMap, optionMap);
		system.assertEquals(true, result);
                
        errorInMap.put('accountId', '454454545445');
        // check for error, invalid accountId sent
		Boolean failResult2 = contSvc.invokeMethod('getContactDetails', errorInMap, outMap, optionMap);
		system.assertEquals(true, result);
        

		test.stopTest();
	}

}