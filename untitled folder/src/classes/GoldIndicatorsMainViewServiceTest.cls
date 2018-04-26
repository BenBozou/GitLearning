/**
*   Test class for all GoldIndicatorsMainViewService
*   
*   @class GoldIndicatorsMainViewServiceTest
*   author Liron Cohen
*   @module TestClass
*   @constructor
*/
@isTest
private class GoldIndicatorsMainViewServiceTest{

    static testMethod void goldIndicatorTest() {
        
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
        
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00688_osb_retrievesecond_lvl_gold_invld_ind_k2view','OSB');
        
        mock.addResponse(endPoint ,mockHttpResponse);  
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        
        Contact con = [select id from contact where accountId = :account.id limit 1];

        GoldIndicatorsMainViewService goldIndicator= new GoldIndicatorsMainViewService();

        //call without parameters for getting error        
        Boolean result = goldIndicator.invokeMethod('getData', 
                new map<String, object>{},
                new map<String, object>(),
                new map<String, object>());
        
        system.assertEquals(false, result);
        
        //call without parameters for getting error        
        result = goldIndicator.invokeMethod('getWrongData', 
                new map<String, object>{},
                new map<String, object>(),
                new map<String, object>());
        
        system.assertEquals(true, result);
        
        //call with parameters
        result = goldIndicator.invokeMethod('getData', 
                new map<String, object>{'accountId' => account.id, 'contactId' => con.id},
                new map<String, object>(),
                new map<String, object>());

        system.assertEquals(true, result);                
        
        Test.stopTest();
    }
}