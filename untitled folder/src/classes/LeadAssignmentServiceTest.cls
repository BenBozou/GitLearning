/**
*   Test class for LeadAssignmentService
*   Author Tal Sabati
*   taskid PLR-633
*   @class GetNextLeadControllerTest
*   @module Leads
*/
@isTest
private class LeadAssignmentServiceTest {
    
     @testSetup static void setupTestData() {
       //String  SystemUser = 'User Integration';// shoud be taken from custom settings
        Id queueId = [Select QueueId from QueueSobject where SobjectType = 'Lead' and Queue.DeveloperName = 'B2CLeads' limit 1].QueueId;
        //User IntegrationUser = TestFactory.testCreateUser('User','Integration','testIntegrationUser@cellcom.co.il');
        User runUser = TestFactory.testCreateUser();
        runUser.Spoken_Languages__c = 'LAN01';
        update runUser;       
         
     }
    
    
    
    /**
    *   Method for testing GetNextLeadController
    *   Author Tal Sabati
    *   taskid PLR-633
    *   @method GetNextLeadTest
    *   @return void
    */
    static testMethod void LeadAssignmentServiceTest() {
        /*
        //String  SystemUser = 'User Integration';// shoud be taken from custom settings
        Id queueId = [Select QueueId from QueueSobject where SobjectType = 'Lead' and Queue.DeveloperName = 'B2CLeads' limit 1].QueueId;
        OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
        list<String> leadSourceHotList = orgSettings == null || String.isBlank(orgSettings.HotLeadSources__c) ? new list<String>{'LSO09'} : orgSettings.HotLeadSources__c.split(';');
        //User IntegrationUser = TestFactory.testCreateUser('User','Integration','testIntegrationUser@cellcom.co.il');
        User runUser = TestFactory.testCreateUser();
        runUser.Spoken_Languages__c = 'LAN01';
        update runUser;
*/
        Id queueId = [Select QueueId from QueueSobject where SobjectType = 'Lead' and Queue.DeveloperName = 'B2CLeads' limit 1].QueueId;
        OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
        list<String> leadSourceHotList = orgSettings == null || String.isBlank(orgSettings.HotLeadSources__c) ? new list<String>{'LSO09'} : orgSettings.HotLeadSources__c.split(';');
        
        Lead lead = TestFactory.testCreateLead(queueId);//(IntegrationUser.Id);
        lead.Status = 'LST01';
        lead.LeadSource = leadSourceHotList[0];
        lead.Language__c = 'LAN01';
        update lead;
        User runUser = [select ID, ProfileId, Spoken_Languages__c FROM User where Spoken_Languages__c = 'LAN01' limit 1];
        UserSkill__c uSkill = TestFactory.testCreateUserSkill(runUser.Id,10,10,Datetime.now().addHours(-2));
        insert uSkill;
         
        
        Test.startTest();
        LeadAssignmentService service = new LeadAssignmentService();
        ConsoleService cs = service.getInteractionEvent(runUser);    
        //cs = service.getInteractionEvent(runUser);
        Test.stopTest();
    }
}