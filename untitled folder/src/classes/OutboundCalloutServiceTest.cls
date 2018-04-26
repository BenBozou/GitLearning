/**
*   Test class for all OutboundCalloutService
*   
*   @class OutboundCalloutServiceTest
*   author Liron Cohen
*   @module TestClass
*   @constructor
*/
@isTest
private class OutboundCalloutServiceTest {

    static testMethod void otuboundCalloutTest() {
        //Organization org = [SELECT IsSandbox FROM Organization limit 1]; 
        EnvironmentSettings__c envSettings = new EnvironmentSettings__c(CurrentEnvironment__c = 'testEnv');
        insert envSettings;
        
        mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        
        map<String, String> headerMap = new map<String, String>();
        headerMap.put('Content-Type', 'application/json;charset=UTF-8');
        headerMap.put('Accept', 'application/json');

        map<String, object> paramsMap = new map<String, object>();
        paramsMap.put('timeout', 100000);
        String endPointPrefix = 'OSB';
        String serviceName = '/testService';
        String methodName = 'GET';
        String body = '{"test" : "test"}';
        
        OutboundCalloutService.RestResponse res;
        try{
            res = OutboundCalloutService.sendRestRequest(paramsMap, null, endPointPrefix, serviceName, methodName, body);
        }
        catch(applicationException ex){
            system.assertEquals(ex.eType == applicationException.ExceptionType.OUTBOUND, true);
        }
        
        OutboundCalloutService.RestResponse resErrorMissingParams;
        try{
            resErrorMissingParams = OutboundCalloutService.sendRestRequest(null, headerMap, endPointPrefix, serviceName, methodName, body);
        }
        catch(applicationException ex){
            system.assertEquals(ex.eType == applicationException.ExceptionType.OUTBOUND, true);
        }
        
        //Call outbound without service name
        OutboundCalloutService.RestResponse resErrorMissingServicename;
        try{
            resErrorMissingServicename = OutboundCalloutService.sendRestRequest(null, headerMap, endPointPrefix, null, methodName, body);
        }
        catch(applicationException ex){
            system.assertEquals(ex.eType == applicationException.ExceptionType.OUTBOUND, true);
        }
        
        //Call outbound with POST method but no body
        OutboundCalloutService.RestResponse resErrorNoBody;
        try{
            resErrorNoBody = OutboundCalloutService.sendRestRequest(paramsMap, headerMap, endPointPrefix, serviceName, 'POST', null);
        }
        catch(applicationException ex){
            system.assertEquals(ex.eType == applicationException.ExceptionType.OUTBOUND, true);
        }
        
        //switch to wrong setup, in order to get exception
        envSettings.CurrentEnvironment__c = 'Prod';
        update envSettings;
        
        OutboundCalloutService.RestResponse resErrorEnvSetup;
        try{
            resErrorEnvSetup = OutboundCalloutService.sendRestRequest(paramsMap, headerMap, endPointPrefix, serviceName, methodName, body);
        }
        catch(applicationException ex){
            system.assertEquals(ex.eType == applicationException.ExceptionType.OUTBOUND, true);
        }
        
        
        test.stopTest();
    }
    
    
}