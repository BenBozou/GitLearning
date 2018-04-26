/**
*   Test class for Asset2ndLevelCardService
*   Author Tal Sabati
*   @class Asset2ndLevelCardService
*   @module 360
*/
@isTest
private class Asset2ndLevelCardServiceTest{
    static {
        prepareTests();
    }
    
	/**
	*   Method for creating test data 
	*   Author Tal Sabati
	*   @method prepareTests
	*   @return {void}
	*/
    private static void prepareTests() {
        EnvironmentSettings__c E = TestFactory.testCreateEnvSettForCurrentEnv();  
        
        mockHttpOutboundResponse globalMock =  new mockHttpOutboundResponse();
        HttpResponse mockHttpResponse = new HttpResponse();
        mockHttpResponse.setBody('{"status":"success"}');                
        
        globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00687_osb_getproductdetails','OSB') ,mockHttpResponse);  
        globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00693_osb_tvcard_bp','OSB') ,mockHttpResponse);  
        globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00695_osb_retrieveispdata_k2view','OSB') ,mockHttpResponse);          
        globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00702_OSB_Bundles_Card_K2view_Tuxedo','OSB') ,mockHttpResponse);  
        globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00698_osb_getnvproductdetails_bp','OSB') ,mockHttpResponse);          
        globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00704_osb_internetinfrastructureasset_bp','OSB') ,mockHttpResponse);  
        Test.setMock(HttpCalloutMock.class, globalMock);
    }
    /**
	*   Method for testing Asset2ndLevelCardService
	*   Author Tal Sabati
	*   @method testAsset2ndLevelCardServiceTest
	*   @return {void}
	*/
    static testMethod void testAsset2ndLevelCardServiceTest() {       
        Test.startTest();
        
        Asset2ndLevelCardService ctrl = new Asset2ndLevelCardService();

        Boolean result = ctrl.invokeMethod('getBundleCardData', new map<String, object>{'productId' => 'productId', 'productType' => 'productType', 'bundleId' => 'bundleId', 'accountId' => 'accountId', 'contactId' => 'contactId', 'banId' => 'banId', 'psId' => 'psId'},new map<String, object>(),new map<String, object>());
        system.assertEquals(true, result);        
        
        result = ctrl.invokeMethod('getVOIPCardData', new map<String, object>{'subscriberNo' => 'subscriberNo', 'productId' => 'productId', 'banId' => 'banId', 'psId' => 'psId'},new map<String, object>(),new map<String, object>());
        system.assertEquals(true, result);        
                        
        result = ctrl.invokeMethod('getCellularCardData', new map<String, object>{'subscriberNo' => 'subscriberNo', 'productId' => 'productId', 'banId' => 'banId', 'psId' => 'psId'},new map<String, object>(),new map<String, object>());
        system.assertEquals(true, result);                

        result = ctrl.invokeMethod('getTVCardData', new map<String, object>{'subscriberNo' => 'subscriberNo', 'productId' => 'productId', 'banId' => 'banId'},new map<String, object>(),new map<String, object>());
        system.assertEquals(true, result);     
        
        result = ctrl.invokeMethod('getISPCardData', new map<String, object>{'subscriberNo' => 'subscriberNo', 'productId' => 'productId', 'banId' => 'banId'},new map<String, object>(),new map<String, object>());
        system.assertEquals(true, result);     
        
        result = ctrl.invokeMethod('getInfrastructureCardData', new map<String, object>{'subscriberNo' => 'subscriberNo', 'productType' => 'productType', 'productId' => 'productId', 'accountId' => 'accountId', 'contactId' => 'contactId', 'banId' => 'banId' , 'psId' => 'psId'},new map<String, object>(),new map<String, object>());
        system.assertEquals(true, result);     
        Test.stopTest();
    }
}