/**
*   Test class for LoggerService
*   
*   @class LoggerServiceTest
*   author Liron Cohen
*   @module TestClass
*   @constructor
*/
@isTest
private class LoggerServiceTest {

    static testMethod void loggerTest() {
        
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
         EnvironmentSettings__c envSettings = 
            (EnvironmentSettings__c ) new testFramework('EnvironmentSettings__c', 
                                                        new map<String, Object> {'Log_Levels__c' => 'INFO;DEBUG;WARNING;ERROR;FATAL;'}, 
                                                        settings).createObject();
        insert envSettings;
        
        Account acc = (Account) new testFramework('Account', 
                                                        new map<String, Object> {'Name' => 'TestAccount', 'CellcomExternalID__c' => '1234', 'RecordTypeId' => RecordTypeService.getRecordTypeIdByName('Account','Consumer')}, 
                                                        settings).createObject();
        insert acc;
        
        Test.startTest();
        
        LoggerService.writeViewMessage(
            acc.id, 
            new LoggerService.ViewMessage(LoggerService.ViewMessageType.View, acc.id, acc.CellcomExternalID__c)); 
        
        LoggerService.writeOutboundMessage(
            new LoggerService.IntegrationMessage('my service', new httpRequest(), new OutboundCalloutService.RestResponse(new httpResponse()))); 
        
        LoggerService.writeInboundMessage(
            new LoggerService.IntegrationMessage(new restRequest(), new inboundWebservice.InboundRestResponse('TestService', 'POST')));
        
        //get intentionally exception, for writing it to log
        try{
            list<String> emptyList = new list<String>();
            
            String firstValue = emptyList.get(1);
        }
        catch(Exception ex){
            system.assertEquals(ex.getTypeName() == 'System.ListException', true);
            
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
        
        //Write to log without inserting immediatelly
        LoggerService.writeOutboundMessage(
            new LoggerService.IntegrationMessage('my service', new httpRequest(), new OutboundCalloutService.RestResponse(new httpResponse())), false, new Map<String, object>{'Elapsed_Time__c' => 5.0, 'Function_Code__c' => '534'});
            
        Integer numLogs = LoggerService.commitAllLogs();
        
        system.assertEquals(true, numLogs == 1);
        
        Test.stopTest();
    }
}