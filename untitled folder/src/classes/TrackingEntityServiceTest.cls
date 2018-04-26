/**
*   Test class for all TrackingEntityService
*
*   @class TrackingEntityServiceTest
*   author Liron Cohen
*   @module TestClass
*   @constructor
*/
@isTest
private class TrackingEntityServiceTest{

    static testMethod void testTrackingEntityService(){
        Account acc = TestFactory.testCreateAccountAndContact();

        Contact con = [select id from Contact where accountId = :acc.id limit 1];

        Lead newLead = new Lead(
            AccountId__c = acc.id, lastName='testLead', Status='LST01', company='MyComp',
            recordTypeId=RecordTypeService.getRecordTypeIdByName('Lead', 'Offer'));
        insert newLead;

        Test.startTest();


        vlocity_cmt__CustomerInteraction__c customerIntercation = new vlocity_cmt__CustomerInteraction__c(
            vlocity_cmt__AccountId__c=acc.id,
            vlocity_cmt__Status__c='In Progress');
        insert customerIntercation;

        triggerhandler.isPreventLoop = false;

        con.mobilephone='222';
        update con;

        newLead.status='LST02';
        update newLead;

        list<vlocity_cmt__VlocityTrackingEntry__c> trackingEvntryList =
                                    [ select id from vlocity_cmt__VlocityTrackingEntry__c
                                      where vlocity_cmt__CustomerInteractionId__c = :customerIntercation.id];

        system.debug(LoggingLevel.Error, 'COUNT ' + trackingEvntryList.size());
        system.assertEquals(true, trackingEvntryList.size()==3);

        Test.StopTest();
    }
}