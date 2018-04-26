/**
*   Test class for ConsoleService
*   Author Tal Sabati
*   Taskid PLR-634
*   @class ConsoleServiceTest
*   @module Leads
*/
@isTest
private class ConsoleServiceTest {
    /**
    *   Method for testing GetNextLeadController
    *   Author Tal Sabati
    *   taskid PLR-633
    *   @method GetNextLeadTest
    *   @return void
    */
    static testMethod void ConsoleServiceTest() {
        User currentuser = [Select Id,FederationIdentifier from User where Id=:userinfo.getuserId()];      
        Lead newLead = TestFactory.testCreateLeadWithCellExtID();
        
        Test.startTest();
        ConsoleService console = new ConsoleService(currentuser, '/' +newLead.id, 'testTab');
        console.setSubTab('/' +newLead.id, 'testTab');
        console.setInboundInformation(null, null, newLead.id, 'leadScreen', false, 'callOrigin','paymentIdentifierRelatedEntity', 'paymentIdentifier', 'customerSegment','phone', false,'callPurpose');
        console.setOutboundInformation(newLead.id, 'testLead');
        string openScreenName = console.getOpenScreenName();
        string interactionEventId = console.getInteractionEventId();
        console.openUrl();
        Test.stopTest();
    }
}