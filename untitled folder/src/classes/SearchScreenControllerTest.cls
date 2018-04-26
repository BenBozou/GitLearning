/**
*   Test class for SearchScreenController
*   Author Tal Sabati
*   Taskid PLR-683
*   @class SearchScreenControllerTest
*   @module 360
*/
@isTest
private class SearchScreenControllerTest {
    /**
    *   Method for testing SearchScreenController
    *   Author Tal Sabati
    *   @method SearchScreenTest
    *   @return void
    */
    static testMethod void SearchScreenTest() {
        prepareTests();
        Test.startTest();
        searchByBiliingAcc();
        searchByPrivateCompany();
        searchBySSN();
        searchByAccount();
        searchByContact();
        searchByLead();
        searchInOSB();
        Test.stopTest();
    }
    /**
    *   Method for setup HttpResponse 
    *   Author Tal Sabati
    *   @method prepareTests
    *   @return void
    */
    private static void prepareTests() {
      TestFactory.testCreateInteractionEvent();
      TestFactory.testCreateAccountWithBillingAccsCollab();
      TestFactory.testCreateBusinessAccounts();
      
      EnvironmentSettings__c E = TestFactory.testCreateEnvSettForCurrentEnv();  
      
      mockHttpOutboundResponse globalMock =  new mockHttpOutboundResponse();
     
      HttpResponse mockHttpResponse = new HttpResponse();
      mockHttpResponse.setBody('{"Header":{},"Body":{"Response":{"accountList":{"account":[{"accountID":"BB255","contactId":"B255","billingAccountId":"C251443891","banId":"251443891","psid":null,"productId":"9911768","productType":"C","productStatus":"A"},{"accountID":"OB255","contactId":null,"billingAccountId":"C221792356","banId":"221792356","psid":null,"productId":"9911768","productType":"C","productStatus":"C"}]}}}}');
      globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00710_osb_searchbyparameters_k2view','OSB'),mockHttpResponse);                      
      
      HttpResponse mockHttpResponse1 = new HttpResponse();
      mockHttpResponse1.setBody('{"Header":{"From":"OSB","To":"SF"},"Body":{"Response":{"existInd":"true"}}}');
      globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00713_osb_searchnoresultmanagment_k2view', 'OSB'),mockHttpResponse1);    
      
      Test.setMock(HttpCalloutMock.class, globalMock);
    }
    
    private static void searchByBiliingAcc(){
        SearchScreenController controller = new SearchScreenController();
        list<Account> accountList = [select BANPSID__c, Parent.RecordType.Name from Account where BANPSID__c != null and CELL_Ind__c = True];
        for(Account acc : accountList){
            controller = new SearchScreenController();
            controller.subCategory = 'Ban';
            controller.searchValue = acc.BANPSID__c;
            controller.search();
        }
        
        accountList = [select BANPSID__c, CELL_Ind__c, Parent.RecordType.Name from Account where BANPSID__c != null and NETV_Ind__c = True];
        for(Account acc : accountList){
            controller = new SearchScreenController();
            controller.subCategory = 'PsId';
            controller.searchValue = acc.BANPSID__c;
            controller.search();
        }
        
        controller.subCategory = 'NV';
        controller.search();
    }
    
    private static void searchByPrivateCompany(){
        SearchScreenController controller = new SearchScreenController();
        controller = new SearchScreenController();
        controller.subCategory = 'PrivateCompany';
        controller.searchValue = '123';
        controller.search();
    }
    private static void searchBySSN(){
        SearchScreenController controller = new SearchScreenController();
        controller = new SearchScreenController();
        controller.subCategory = 'SSN';
        controller.searchValue = '123';
        controller.search();
    }
    private static void searchByAccount(){
        list<InteractionEvent__c> interactionEventList = [select AccountId__c from InteractionEvent__c where AccountId__c != null];
        for(InteractionEvent__c interactionEvent : interactionEventList){
            PageReference pageRef = Page.SearchScreen;
            pageRef.getParameters().put('EventId', interactionEvent.id);
            Test.setCurrentPage(pageRef);
            SearchScreenController controller = new SearchScreenController();
        }
        
        Account acc = [select Name, RecordType.Name from Account limit 1];
        SearchScreenController controller = new SearchScreenController();
        controller.subCategory = 'AccountName';
        controller.searchValue = acc.Name;
        controller.search();
    }
    private static void searchByContact(){
        list<InteractionEvent__c> interactionEventList = [select ContactId__c from InteractionEvent__c where ContactId__c != null];
        PageReference pageRef = Page.SearchScreen;
        pageRef.getParameters().put('EventId', interactionEventList[0].id);
        Test.setCurrentPage(pageRef);
        SearchScreenController controller = new SearchScreenController();
        
        Contact con = [select Name from Contact limit 1];
        controller.subCategory = 'ContactName';
        controller.searchValue = con.Name;
        controller.search();
    }
    private static void searchByLead(){
        list<InteractionEvent__c> interactionEventList = [select PhoneNumber__c from InteractionEvent__c where PhoneNumber__c != null];
        PageReference pageRef = Page.SearchScreen;
        pageRef.getParameters().put('EventId', interactionEventList[0].id);
        Test.setCurrentPage(pageRef);
        SearchScreenController controller = new SearchScreenController();
    }
    private static void searchInOSB(){
        SearchScreenController controller = new SearchScreenController();
        controller.subCategory = 'SubscriberNumber';
        controller.searchValue = '0524827837';
        controller.search();
        
        controller.subCategory = 'IMEI';
        controller.searchValue = '351989068618429';
        controller.search();
        
        controller.subCategory = 'MAC';
        controller.searchValue = '008C548C4E41';
        controller.search();
        
        controller.subCategory = 'DataLine';
        controller.searchValue = '3330000731';
        controller.search();
        
        controller.subCategory = 'CaseNumber';
        controller.searchValue = '252917503';
        controller.search();
    }
}