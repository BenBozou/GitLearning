/**
*   Test class for all Asset 1st Level Card Service
*   Elad Iflah
*   taskId PLR 1038 Integration 1st Level 
* 
*   @class B2CRecommendCardServiceTest
*   @module TestClass
*   @constructor
*/
@isTest
private class B2CRecommendCardServiceTest{

  static testMethod void B2CRecomSvcTest() {
    
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
    
    String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00684_osb_getrecommends_dwh','OSB');
    
    mock.addResponse(endPoint ,mockHttpResponse);  
    
    Test.setMock(HttpCalloutMock.class, mock);
    
    Test.startTest();
    
    Contact con = [select id from contact where accountId = :account.id limit 1];

    B2CRecommendCardService B2CRecomSvc = new B2CRecommendCardService ();
    
    //call without parameters for getting error        
    Boolean result = B2CRecomSvc.invokeMethod('getRecommendations', 
        new map<String, object>{},
        new map<String, object>(),
        new map<String, object>());
    
    system.assertEquals(false, result);
    
    //call with parameters
    result = B2CRecomSvc.invokeMethod('getRecommendations', 
        new map<String, object>{'accountId' => account.id, 'contactId' => con.id, 'product' => 'TVPOLM', 'treatCount' => '3'},
        new map<String, object>(),
        new map<String, object>());

    system.assertEquals(true, result);
    
    
    Test.stopTest();
  }
}