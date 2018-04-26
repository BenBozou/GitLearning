/**
* test class to NewLeadController
* Nikolay Iliaev
* Taskid PLR-1451
* @class NewLeadControllerTest
* @module Leads
*/
@isTest
private class NewLeadControllerTest {
    
    /**
    * test method without RecordType paramter in url 
    * Nikolay Iliaev
    * Taskid PLR-1451
    * @class leadControllerTest
    * @module Leads
    */
    static testMethod void leadControllerTest() {
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Lead());
        
        NewLeadController controller = new NewLeadController(sc);
        
        Test.startTest();
            controller.getRedirect();
        Test.stopTest();
    }
    
    /**
    * test method with RecordType paramter in url 
    * Nikolay Iliaev
    * Taskid PLR-1451
    * @class leadControllerWithRecordtypeTest
    * @module Leads
    */
    static testMethod void leadControllerWithRecordtypeTest() {
        
        PageReference pageRef = Page.NewLeadOmni;
        pageRef.getParameters().put('RecordType', 'B2B');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Lead());
        
        NewLeadController controller = new NewLeadController(sc);
        
        Test.startTest();
            PageReference pageR = controller.getRedirect();
        Test.stopTest();
        
         System.assert(pageR != null);
    }
}