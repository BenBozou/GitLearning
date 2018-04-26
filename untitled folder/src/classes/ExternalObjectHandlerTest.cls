/**
*   Test class for ExternalObjectHandler
*   
*   @class ExternalObjectHandlerTest
*   author Liron Cohen
*   @module Odata
*/
@isTest
private class ExternalObjectHandlerTest{

    static testMethod void testExternalHandler(){
        
        list<sobject> lleadx = ExternalObjectHandler.getXRecords('Leads__x', 
                                      'select sequence_id__c, transactionId__c from Leads__x where Id =\'123456\' limit 1',
                                      new map<String, Object>{'sequence_id__c' => '123'});
                                      
        system.assertEquals(true, lleadx.size()==1);
    }

}