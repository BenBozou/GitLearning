@isTest
public class AccountActiveFlagUpdateOneShotBatchTest {
    
    static testMethod void BatchTest(){
        
        Account AccBatch = TestFactory.testCreateAccountStatusInactive();
        
        AccountActiveFlagUpdateOneShotBatch  objActiveFlagUpd = new AccountActiveFlagUpdateOneShotBatch ();

        String strNameSpacePrefix = 'vlocity_cmt';
        String strRtName = 'Billing';
        String ObjectName = 'Account';
                
        RecordType rt = Database.Query('Select Id from RecordType where SobjectType =: ObjectName and nameSpacePrefix=: strNameSpacePrefix and name =:strRtName');
        String BillingLiteralId = String.valueof ( rt.Id);
        
        strRtName = 'Consumer';
        rt = Database.Query('Select Id from RecordType where SobjectType =: ObjectName and nameSpacePrefix=: strNameSpacePrefix and name =:strRtName');
        String ConsumerLiteralId = String.valueof ( rt.Id);
        
        strRtName = 'Business';
        rt = Database.Query('Select Id from RecordType where SobjectType =: ObjectName and nameSpacePrefix=: strNameSpacePrefix and name =:strRtName');
        String BusinessLiteralId = String.valueof ( rt.Id);
        
        strRtName = 'Business Aggregator';
        rt = Database.Query('Select Id from RecordType where SobjectType =: ObjectName and name =:strRtName');
        String BusinessAggLiteralId = String.valueof ( rt.Id);
        
        String listOfRecordType = '\'' + BusinessLiteralId + '\',\'' + ConsumerLiteralId +  '\',\'' + BillingLiteralId + '\',\'' + BusinessAggLiteralId + '\''; 
        
        System.debug('******* ' + listOfRecordType);
        
        objActiveFlagUpd.recordTypeIdList = listOfRecordType; //All
        
        objActiveFlagUpd.sourceStatus = 'Inactive';
        objActiveFlagUpd.sourceValueInQueryCriteria = 'Yes';
        objActiveFlagUpd.targetValue = 'No';
        objActiveFlagUpd.limitQuery = '';
        
        String localQuery = 'Select Id, vlocity_cmt__Active__c From Account where RecordTypeId in (' + listOfRecordType + ') and vlocity_cmt__Active__c  =\'' + objActiveFlagUpd.sourceValueInQueryCriteria  + '\' and  vlocity_cmt__Status__c=\'' + objActiveFlagUpd.sourceStatus+ '\'' ;

        Test.startTest();
        
          Id batchId = Database.executeBatch(objActiveFlagUpd, 1000);
          
        Test.stopTest();
    }
    
}