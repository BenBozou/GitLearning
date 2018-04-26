/**
*   Test class for LeadConsoleSideBarController
*   Author Elad Kaplan
*   @class LeadConsoleSideBarControllerTest
*   @module Leads
*/
@isTest
public class LeadConsoleSideBarControllerTest {
    
    
    static testMethod void testLead() {
        Lead testLead = TestFactory.testCreateLead(UserInfo.getUserId());
        Task testTask = TestFactory.createTask();
        insert testTask;
        ApexPages.StandardController stdLead = new ApexPages.StandardController(testLead);
        
        Test.StartTest();
        LeadConsoleSideBarController controller = new LeadConsoleSideBarController(stdLead);
        Boolean rT = controller.isLanguageRTL;
        Test.StopTest();
     }
}