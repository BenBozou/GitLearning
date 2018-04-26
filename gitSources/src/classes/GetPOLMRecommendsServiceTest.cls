/**
 *	GetPOLMRecommendsService - test class
 *
 *	@class GetPOLMRecommendsServiceTest
 *	Eric Fishman
 *	@module {Test}
 *	@constructor
 */
@isTest
public class GetPOLMRecommendsServiceTest {

	@isTest static void testGetRecommendation() {

		Map < String, Object > inMap = new Map < String, Object > ();
		Map < String, Object > outMap = new Map < String, Object > ();
		Map < String, Object > optionMap = new Map < String, Object > ();
		
		Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
         EnvironmentSettings__c envSettings = 
            (EnvironmentSettings__c ) new testFramework('EnvironmentSettings__c', 
                                                        new map<String, Object> {'CurrentEnvironment__c' => 'Test'}, 
                                                        settings).createObject();
         
        insert envSettings;
        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        
        mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        
        HttpResponse mockHttpResponse = new HttpResponse();
        mockHttpResponse.setBody('{"status":"success"}');                
        
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00684_osb_getrecommends_dwh','OSB');
        
        mock.addResponse(endPoint ,mockHttpResponse);  
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
			
			GetPOLMRecommendsService ctrl = new GetPOLMRecommendsService();
			
			///call without input 
        	Boolean result = ctrl.invokeMethod('GetPOLMRecommends', 
                new map<String, object>{},
                new map<String, object>(),
                new map<String, object>());
        	system.assertEquals(false, result);
			
        	///call with correct method name parameters
        	result = ctrl.invokeMethod('GetPOLMRecommends', 
                new map<String, object>{'agent' => '1'},
                new map<String, object>(),
                new map<String, object>());
        	system.assertEquals(true, result);      

						
		Test.stopTest();
	}

}