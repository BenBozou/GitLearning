/**
 *  GetPOLMOutRecommendsService - test class
 *
 *  @class GetPOLMOutRecommendsServiceTest
 *  Eric Fishman
 *  @module {Test}
 *  @constructor
 */

@isTest
private class GetPOLMOutRecommendsServiceTest {

    static testMethod void testGetOutRecommendation() {
      
    string dt = string.valueOf(system.currentTimeMillis());
    Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
  	User u = new User();
  	u.Alias = 'newUser';
  	u.Email='newuser@testorg.com';
    u.LastName='Testing'; 
    u.ProfileId = prof.Id; 
    u.TimeZoneSidKey='America/Los_Angeles'; 
    u.UserName='user@testorg.com' + dt;
    u.FederationIdentifier = 'f' + dt;
  	u.EmailEncodingKey='UTF-8';
    u.LanguageLocaleKey='en_US';
    u.LocaleSidKey='en_US';
    u.Spoken_Languages__c = 'LAN01';
    insert u;
    
    
    EnvironmentSettings__c envSettings = TestFactory.testCreateEnvSettForCurrentEnv();
            
        //Lead lead = TestFactory.testCreateLeadWithCellExtID();
        
    //UserSkill__c uSkill = TestFactory.testCreateUserSkill(UserInfo.getUserId(),10,10,Datetime.now());
    UserSkill__c uSkill = TestFactory.testCreateUserSkill(u.Id,10,10,Datetime.now());
    insert uSkill;
    Product2 p = TestFactory.testCreateProdact2();
    UserSkillProduct__c uSkillProd = TestFactory.testCreateUserSkillProduct(uSkill.Id, p.Id);
    insert uSkillProd;
    
    map<String,Object> recommendMap = new map<String,Object>();
    list<Object> treatRecommendList = new list<Object>{recommendMap};
    map<String,Object> treatMap = new map<String,Object>{'Recommendation'=>treatRecommendList};
    list<Object> treatList = new list<Object>{treatMap};
    map<String,Object> recommendationsMap = new map<String,Object>{'TREAT'=>treatList};
    map<String,Object> responseMap = new map<String,Object>{'P_RETURN_CODE'=>0,'Recommendations'=>recommendationsMap};
    map<String,Object> bodyMap = new map<String,Object>{'Response'=>responseMap};
    map<String,Object> headerMap = new map<String,Object>{'ReturnCode'=>'00'};
    map<String,Object> response = new map<String,Object>{'Header'=>headerMap,'Body'=>bodyMap};
        
    mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
    HttpResponse mockHttpResponse = new HttpResponse();
    mockHttpResponse.setBody(JSON.serialize(response));                
    String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00684_osb_getrecommends_dwh','OSB');
    mock.addResponse(endPoint ,mockHttpResponse);          
    Test.setMock(HttpCalloutMock.class, mock);
    
    Map<String,Object> inputMap = new Map<String,Object>();
    inputMap.put('agent','1');
    inputMap.put('company_focus','inConsumerfocus');
    inputMap.put('user_id',u.Id);
    
    Test.startTest();
    GetPOLMOutRecommendsService ctrl = new GetPOLMOutRecommendsService();
    //call with correct method name parameters
    Lead l = ctrl.getOutReccommendations(inputMap);
    Test.stopTest();
    }
}