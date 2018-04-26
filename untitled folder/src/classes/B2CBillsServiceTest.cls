/**
*   Test class for all B2CBills2LevelService 
*   
*   @class B2CBills2LevelServiceTest
*   author Liron Cohen
*   @module TestClass
*   @constructor
*/
@isTest
private class B2CBillsServiceTest {        
    
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
        
        //Account account = TestFactory.testCreateAccountWithBillingAccs();
        
    }
    
    
    static testMethod void b2CBills1LevelTest() {
        
        mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        
        HttpResponse mockHttpResponse = new HttpResponse();
        //mockHttpResponse.setBody('{"status":"success"}');                
        mockHttpResponse.setBody('{"Header":{"From":"string","To":"string","ProcessID":"string","MessageID":"string","ActionID":"string", "ReturnCode":"0","ReturnCodeMessage":"0","UserName":"string","OptionalReturnAddress":"string","InterchangeID":"string","ActivityID":"string","InvokerActivityID":"string","UseInvokerActivityIDInd":"string","FunctionCode":"string","NextTryIndex":"string"},"Body":{"Response":{"Customer":{"Consumer":"string","Contact":"anyType","ShareDataInd":"anyType","FinData":{"billing_account":[{"company_id":"string","ban":100,"psid":"anyType","ar_balance":10517320,"total_due_amt":10517320,"prd_cvrg_strt_date":"string","prd_cvrg_end_date":"string","bill_cycle":100,"debt_amount":10517320,"collection_ind":"string","bill_due_date":"string","dep_charges_amt":10517320,"bill_method":"string","bill_url_type":"string","bill_url":"string","invoice_no":100}]}}}}}');
        
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00797_osb_getfinanceinfo_k2view','OSB');
        
        mock.addResponse(endPoint ,mockHttpResponse);  
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        //Account acc = [select id from Account where CellcomExternalID__c = 'OB1488151'];//TestFactory.testCreateAccountWithBillingAccs();
        Account acc = TestFactory.testCreateAccountWithBillingAccs();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];
        
        Test.startTest();                
        
        B2CBillsService b2CBills= new B2CBillsService();

        //call without parameters for getting error        
        Boolean result = b2CBills.invokeMethod('getBills1Level', 
                new map<String, object>{},
                new map<String, object>(),
                new map<String, object>());
        
        system.assertEquals(false, result);
        
        //call with parameters
        result = b2CBills.invokeMethod('getBills1Level', 
                new map<String, object>{'accountId' => acc.id, 'contactId' => con.id},
                new map<String, object>(),
                new map<String, object>());
        system.debug('==>' + result);
        system.assertEquals(true, result);                
        
        Test.stopTest();
        
    }
    
    static testMethod void b2CBills2LevelTest() {
        
        mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        
        HttpResponse mockHttpResponse = new HttpResponse();
        mockHttpResponse.setBody('{"status":"success"}');                        
        
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/osb_getcustomersinvoices_bp_00664','OSB');
        
        mock.addResponse(endPoint ,mockHttpResponse);  
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();        
        
        B2CBillsService b2CBills= new B2CBillsService();
            
        //call without parameters for getting error        
        Boolean result = b2CBills.invokeMethod('getBills2Level', 
                new map<String, object>{},
                new map<String, object>(),
                new map<String, object>());
        
        system.assertEquals(false, result);
        
        //call with parameters
        result = b2CBills.invokeMethod('getBills2Level', 
                new map<String, object>{'banId' => 'banId', 'psId' => 'psId'},
                new map<String, object>(),
                new map<String, object>());
        
        system.assertEquals(true, result);                
        
        Test.stopTest();
        
    }
    
    static testMethod void b2CBills2LevelAccTest() {
        
        mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        
        HttpResponse mockHttpResponse = new HttpResponse();
        mockHttpResponse.setBody('{"status":"success"}');                        
        
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/osb_getcustomersinvoices_bp_00664','OSB');
        
        mock.addResponse(endPoint ,mockHttpResponse);  
        
        Test.setMock(HttpCalloutMock.class, mock);
                
        Account acc = TestFactory.testCreateAccountWithBillingAccs();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];
        
        Test.startTest();                
        
        B2CBillsService b2CBills= new B2CBillsService();
        
        //call without parameters for getting error        
        Boolean result = b2CBills.invokeMethod('getBills2LevelAcc', 
                                               new map<String, object>{},
                                               new map<String, object>(),
                                               new map<String, object>());
        
        system.assertEquals(false, result);
        
        //call with parameters
        result = b2CBills.invokeMethod('getBills2LevelAcc', 
                                       new map<String, object>{'accountId' => acc.id, 'contactId' => con.id},
                                       new map<String, object>(),
                                       new map<String, object>());
        
        system.assertEquals(true, result);                
        
        Test.stopTest();
        
    }
}