@isTest
private class MockupOutbond {
	
	static testMethod void outbound() {
		Test.setMock(HttpCalloutMock.class, new mockHttpOutboundResponse());
		
		Account acc = new Account(); 
		acc.Name = 'Test acc';
		insert acc;

		test.startTest();
			

			Map<String,Object> inMap = new Map<String,Object>();
			Map<String,Object> outMap = new Map<String,Object>();
			Map<String,Object> optionMap = new Map<String,Object>();
			
			inMap.put('accountId',  acc.Id);
			inMap.put('IncludeDebt', 'true');
	 		inMap.put('IncludeLegalInfo', 'true');
	 		inMap.put('IncludeCollectionInfo', 'true');       

			IndicatorsCardsService callOut =new IndicatorsCardsService();

			// check for success
			Boolean result = callOut.invokeMethod('getLegalDebtDetails', inMap, outMap, optionMap);
			system.debug(LoggingLevel.Error, result);
			system.assertEquals(true, result);
		test.stopTest();
	}
}