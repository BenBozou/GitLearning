/**
*   Test class for GetNextLeadController
*   Author Tal Sabati
*   taskid PLR-633
*   @class GetNextLeadControllerTest
*   @module Leads
*/
@isTest
private class GetNextLeadControllerTest {

    /**
    *   Method for testing GetNextLeadController
    *   Author Tal Sabati
    *   taskid PLR-633
    *   @method GetNextLeadTest
    *   @return void
    */
    static testMethod void getNextLeadControllerTest() {   
        
        Lead newLead = TestFactory.testCreateLead(UserInfo.getUserId());
        newLead.Status = 'LST01';
        update newLead;
        
        system.debug('>>> ' + [select id, Status, Owner.Name from Lead where Id =: newLead.Id]);
        
        Test.startTest();
        GetNextLeadController.getOmniChannelLogInNecessary();
        GetNextLeadController controller = new GetNextLeadController();
        GetNextLeadController.getLeadFromClient();
        list<InteractionEvent__c> interactionEventList = [Select URL__c, OwnerId from InteractionEvent__c LIMIT 1];
        InteractionEvent__c interactionEvent = GetNextLeadController.getInteractionEvent(interactionEventList[0].id);
        Test.stopTest();
    }
}