@isTest
private class AssetB2B2ndLevelCardServiceTest {
    
    /**
*   Test class for all Asset 1st Level Card Service
*   Gili Yehuda
*	taskId PLR 978 Integration 1st Level 
* 
*   @class Asset1stLevelCardServiceTest
*   @module TestClass
*   @constructor
*/



	static testMethod void AssetB2B2ndLevelTest() {
		
		Map<String,Object> settings = new Map<String,Object>{
			'createlookupobject' => false,
			'countObjects' => 1
		};
		
		 EnvironmentSettings__c envSettings = 
			(EnvironmentSettings__c ) new testFramework('EnvironmentSettings__c', 
														new map<String, Object> {'CurrentEnvironment__c' => 'Test'}, 
														settings).createObject();
		 
		insert envSettings;
		
		Account account = TestFactory.testCreateAccountWithBillingAccs();
		
		mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
		
		HttpResponse mockHttpResponse = new HttpResponse();
		mockHttpResponse.setBody('{"status":"success"}');                
		
		
		//String endPoint = OutboundCalloutService.getEndPoint('/api/services/rest/00712_osb_b2bcellularanddatalevel2_k2view','OSB');
		String endPoint = OutboundCalloutService.getEndPoint('/api/services/rest/00714_osb_b2b_assetcardslayoutlevel2_bp','OSB');
		
		mock.addResponse(endPoint ,mockHttpResponse);  		
		
		Test.setMock(HttpCalloutMock.class, mock);
		
		Test.startTest();
		
		Contact con = [select id from contact where accountId = :account.id limit 1];

		AssetB2B2ndLevelCardService AssetB2B2ndLevel= new AssetB2B2ndLevelCardService();

		
		//call without parameters for getting error        
		Boolean result = AssetB2B2ndLevel.invokeMethod('getB2BAsset2ndLevel', 
				new map<String, object>{},
				new map<String, object>(),
				new map<String, object>());
		
		system.assertEquals(false, result);
		
		//call with parameters
		result = AssetB2B2ndLevel.invokeMethod('getB2BAsset2ndLevel', 
				new map<String, object>{'accountId' => account.id, 'itemName' => 'CELL'},
				new map<String, object>(),
				new map<String, object>());

		system.assertEquals(true, result);
		
		Test.stopTest();
	
}

}