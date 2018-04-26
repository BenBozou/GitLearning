/**
 *  AccountConsoleSidebar - test class
 *
 *  @class AccountSidebarCardsServiceTest
 *  author Dmitry Rivlin
 *  @module {Test}
 *  @constructor
 */
@isTest
public class AccountSidebarCardsServiceTest {
    
    static {
        prepareTests();
    }
    
    private static void prepareTests() {
        EnvironmentSettings__c E = TestFactory.testCreateEnvSettForCurrentEnv();  
        mockHttpOutboundResponse globalMock =  new mockHttpOutboundResponse();
        HttpResponse mockHttpResponse = new HttpResponse();
        mockHttpResponse.setBody('{"status":"success"}');                
        String endPoint1 = OutboundCalloutService.getEndPoint('api/services/rest/00682_osb_retrievecustomerindicators_bp','OSB');
        String endPoint2 = OutboundCalloutService.getEndPoint('api/services/rest/00689_osb_b2ccustomerassetsindicators_k2view','OSB');
        String endPoint3 = OutboundCalloutService.getEndPoint('api/services/rest/00681_osb_retrievecustomerflags_k2view','OSB');
        String endPoint4 = OutboundCalloutService.getEndPoint('api/services/rest/00667_osb_calculatecurrentrisk_bp','OSB');
        globalMock.addResponse(endPoint1 ,mockHttpResponse);
        globalMock.addResponse(endPoint2 ,mockHttpResponse);
        globalMock.addResponse(endPoint3 ,mockHttpResponse);
        globalMock.addResponse(endPoint4 ,mockHttpResponse);        
        Test.setMock(HttpCalloutMock.class, globalMock);
    }
    
    @isTest static void testAccountConsoleSidebar() {

        Map < String, Object > inMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();

        Account acc = TestFactory.testCreateAccountAndContact();        

        inMap.put('accountId', acc.Id);
                
        Group testGroup = TestFactory.testCreateGroup();        
        User teamUser = TestFactory.testCreateUser();                     
        TestFactory.testCreateAccTeamMemb( UserInfo.getUserId(), acc.Id );                        
        AccountShare accShare = TestFactory.testCreateAccShare( acc.Id, testGroup.Id );                 
        
        //TestFactory.testCreateGroupMember( teamUser.Id, testGroup.Id );   
        
        /* Elad Iflah - START - Add test for Product and First Indicators */
        Map < String, Object > inMapTwo = new Map < String, Object > ();        
                      
        Account A = TestFactory.testCreateAccountWithBillingAccs();
        Contact C = [SELECT Id, Name FROM Contact WHERE AccountId = :A.Id];
                
        inMapTwo.put('accountId',A.Id);
        inMapTwo.put('contactId',C.Id);                
        /* END - Add test for Product and First Indicators */

        Test.startTest();

            AccountSidebarCardsService ctrl = new AccountSidebarCardsService();
        
            system.debug('inMap before calling method' + inMap);

            Boolean result = ctrl.invokeMethod('B2BAccountSidebar', inMap, outMap, optionMap);
            system.assertEquals(true, result);

            result = ctrl.invokeMethod('B2BAccountSidebar', null, outMap, optionMap);
            
            Boolean resultB2CProdInd = ctrl.invokeMethod('getProductIndicators', inMapTwo, outMap, optionMap);
            system.assertEquals(true, resultB2CProdInd);

            resultB2CProdInd = ctrl.invokeMethod('getProductIndicators', null, outMap, optionMap);
        
            Boolean resultB2CFirstInd = ctrl.invokeMethod('getAccessibilityFirstIndicators', inMapTwo, outMap, optionMap);
            system.assertEquals(true, resultB2CFirstInd);

            resultB2CFirstInd = ctrl.invokeMethod('getAccessibilityFirstIndicators', null, outMap, optionMap);                                
            
        Test.stopTest();
    }   
    
    
    @isTest 
    static void testAccountConsoleCreditControl() {

        Map < String, Object > inMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();

        Account acc = TestFactory.testCreateAccountAndContact();        
        acc.recordTypeId = RecordTypeService.getRecordTypeIdByName('Account', 'Consumer');
        update acc;

        inMap.put('accountId', acc.Id);
        
        /* Elad Iflah - START - Add test for Product and First Indicators */
        Map < String, Object > inMapTwo = new Map < String, Object > (); 
        Map < String, Object > inMap3 = new Map < String, Object > (); 
        
              
        //Account A = TestFactory.testCreateAccountWithBillingAccs();
        Account A = TestFactory.testCreateAccAndContConsumer();
        Contact C = [SELECT Id, Name,vlocity_cmt__SSN__c FROM Contact WHERE AccountId = :A.Id];
                
        inMapTwo.put('accountId',A.Id);
        inMapTwo.put('contactId',C.Id);
        
        inMap3.put('accountId',A.Id);
        inMap3.put('contactId',C.Id);
        inMap3.put('SSN',C.vlocity_cmt__SSN__c);
        
        /* END - Add test for Product and First Indicators */

        Test.startTest();

            AccountSidebarCardsService ctrl = new AccountSidebarCardsService();
        
            system.debug('inMap before calling method' + inMap);

            Boolean result = ctrl.invokeMethod('B2BAccountSidebar', inMap, outMap, optionMap);
            system.assertEquals(true, result);

            result = ctrl.invokeMethod('B2BAccountSidebar', null, outMap, optionMap);
            
            Boolean resultB2CProdInd = ctrl.invokeMethod('getProductIndicators', inMapTwo, outMap, optionMap);
            system.assertEquals(true, resultB2CProdInd);

            resultB2CProdInd = ctrl.invokeMethod('getProductIndicators', null, outMap, optionMap);
        
            Boolean resultB2CFirstInd = ctrl.invokeMethod('getAccessibilityFirstIndicators', inMapTwo, outMap, optionMap);
            system.assertEquals(true, resultB2CFirstInd);
            

            resultB2CFirstInd = ctrl.invokeMethod('getAccessibilityFirstIndicators', null, outMap, optionMap);
            
            Boolean resultB2CcustomerExposure = ctrl.invokeMethod('B2CCustomerExposure', inMap3, outMap, optionMap);
            system.assertEquals(true, resultB2CcustomerExposure);
            
        Test.stopTest();
    } 

}