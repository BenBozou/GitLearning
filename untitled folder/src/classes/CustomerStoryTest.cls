/**
*   Test class for all CustomerStory 
*   
*   @class CustomerStory
*   author Ilana Brodsky
*   @module TestClass
*   @constructor
*/
@isTest
private class CustomerStoryTest {        
    @testSetup 
    static void setupTestData(){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        EnvironmentSettings__c envSettings = 
            (EnvironmentSettings__c ) new testFramework('EnvironmentSettings__c', 
                                                        new map<String, Object> {'CurrentEnvironment__c' => 'Test'}, 
                                                        settings).createObject();
         
        insert envSettings;
			
    }
    
    
    static testMethod void customerStory1Test() {
        
       mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        
        HttpResponse mockHttpResponse = new HttpResponse();
        //mockHttpResponse.setBody('{"status":"success"}');                
        mockHttpResponse.setBody('{"Header":{"From":"OSB","To":"SF","ProcessID":"3f4f188b-3346-4c3d-8c40-465af13c5ea4","MessageID":"fe91ec36-fd68-45b5-bd9c-34b47cc74a4a","ActionID":null,"ReturnCode":"00","ReturnCodeMessage":"הצלחה","UserName":null,"OptionalReturnAddress":null,"InterchangeID":"fe139bca-c04f-488e-af6c-3225e361ea69","ActivityID":"60bb10fc-cbaa-4a03-887c-2e94ffe22000","InvokerActivityID":null,"UseInvokerActivityIDInd":null,"FunctionCode":"00715","NextTryIndex":null},"Body":{"Response":{"Cases":{"CaseData":[{"case_id":"253671500","unit":"אדמין - שירות לקוחות          ","open_date":"24/02/2017","open_time":"12:30:53","source":"N","psid":"18486139","category":"מכירת מוצר עסקי                                   ","type":"מכירת מוצר עסקי                                   ","detail":"העברה למכירה                                      ","status":"OPEN","status_descr":"פתוחה                                             ","user_name":"kyosefi","subscriber_no":null,"csm_note":null,"update_date":"22/02/2017","update_time":"12:32:18","notes":{"note":[{"note_desc":"הערה 2","oprid":"kyosefi","date_open":"2017-02-22","time_open":"12:31:51"},{"note_desc":"הערה 1","oprid":"kyosefi","date_open":"2017-02-23","time_open":"12:31:46"},{"note_desc":"רמקולים גדולים למחשב , תאור פעולה","oprid":"kyosefi","date_open":"2017-02-24","time_open":"12:31:36"},{"note_desc":"הוספת חבילה , תאור פעולה 2","oprid":"kyosefi","date_open":"2017-02-22","time_open":"12:32:09"}]}}]}}}}');
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00715_osb_customerstorysection_k2view','OSB');
        
        mock.addResponse(endPoint ,mockHttpResponse);  
        
        Test.setMock(HttpCalloutMock.class, mock);

        Account acc = TestFactory.testCreateAccountAndContact();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];
        
        Lead L =TestFactory.testCreateLeadWithRTbyAccount(acc);
      	L.Status = 'LST04';
      	update L;
      	
      	vlocity_cmt__CustomerInteraction__c customerIntercation = new vlocity_cmt__CustomerInteraction__c(
            vlocity_cmt__AccountId__c=acc.id,
            vlocity_cmt__Status__c='Completed',
            vlocity_cmt__Comments__c='TestInteraction');
        insert customerIntercation;
        
        Test.startTest();                
        
        CustomerStory b2CcustomerStory= new CustomerStory();

        //call without parameters for getting error        
        Boolean result = b2CcustomerStory.invokeMethod('getCustomerStory', 
                new map<String, object>{},
                new map<String, object>(),
                new map<String, object>());
        
        system.assertEquals(false, result);
        
        //call with parameters
        result = b2CcustomerStory.invokeMethod('getCustomerStory', 
                new map<String, object>{'accountId' => acc.id, 'contactId' => con.id},
                new map<String, object>(),
                new map<String, object>());
        
        //system.assertEquals(true, result);                
        
        Test.stopTest();
        
    }
    
    
}