/**
*   Test class for all Asset 1st Level Card Service
*   Gili Yehuda
*	taskId PLR 978 Integration 1st Level 
* 
*   @class Asset1stLevelCardServiceTest
*   @module TestClass
*   @constructor
*/
@isTest
private class Asset1stLevelCardServiceTest{

	static testMethod void Asset1stLevelTest() {
		
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
		
		String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00703_osb_b2ccardslayoutlevel1_k2view','OSB');
		String endPoint1 = OutboundCalloutService.getEndPoint('api/services/rest/00747_osb_b2bassetcardslayoutlevel1_k2view','OSB');
		
		mock.addResponse(endPoint ,mockHttpResponse);  
		mock.addResponse(endPoint1 ,mockHttpResponse);
		
		Test.setMock(HttpCalloutMock.class, mock);
		
		Test.startTest();
		
		Contact con = [select id from contact where accountId = :account.id limit 1];

		Asset1stLevelCardService Asset1stLevel= new Asset1stLevelCardService();

		//call without parameters for getting error        
		Boolean result = Asset1stLevel.invokeMethod('get1stLevelAsset', 
				new map<String, object>{},
				new map<String, object>(),
				new map<String, object>());
		
		system.assertEquals(false, result);
		
		//call without parameters for getting error        
		result = Asset1stLevel.invokeMethod('getWrong1stLevelAsset', 
				new map<String, object>{},
				new map<String, object>(),
				new map<String, object>());
		
		system.assertEquals(true, result);
		
		//call with parameters
		result = Asset1stLevel.invokeMethod('get1stLevelAsset', 
				new map<String, object>{'accountId' => account.id, 'contactId' => con.id},
				new map<String, object>(),
				new map<String, object>());

		system.assertEquals(true, result);
	
		//call without parameters for getting error        
		result = Asset1stLevel.invokeMethod('B2Bget1stLevelAsset', 
				new map<String, object>{},
				new map<String, object>(),
				new map<String, object>());
		
		system.assertEquals(false, result);
		Account acc =  [SELECT RecordType.DeveloperName, CellcomExternalID__c, (Select id_number__c From AccountKeys__r)
		           FROM Account WHERE Id =: account.Id];
		           system.debug('acc '+acc);
		           update acc;
		           
		
		
		//call with parameters
		result = Asset1stLevel.invokeMethod('B2Bget1stLevelAsset', 
				new map<String, object>{'accountId' => account.id, 'contactId' => con.id},
				new map<String, object>(),
				new map<String, object>());

		system.assertEquals(true, result);
		
		
		Test.stopTest();
	}
}