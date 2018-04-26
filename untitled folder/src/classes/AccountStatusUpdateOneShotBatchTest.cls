/**
*   Test class for AccountStatusUpdateOneShotBatch process
*   Author Rosario Capasso
*   @class AccountStatusUpdateOneShotBatchTest
*/
@isTest
public class AccountStatusUpdateOneShotBatchTest{
    
    static testMethod void BatchTest(){
        
        Account acc = createDummyData();
        
        AccountStatusUpdateOneShotBatch objAccUpd = new AccountStatusUpdateOneShotBatch();
        String ObjectName = 'Account';
        String strNameSpacePrefix = 'vlocity_cmt';
        String strRtName = 'Billing';
        
        RecordType rt = Database.Query('Select Id from RecordType where SobjectType =: ObjectName and nameSpacePrefix=: strNameSpacePrefix and name =:strRtName');
        String BillingLiteralId  = String.valueof (rt.Id);

        strRtName = 'Consumer';
        
        rt = Database.Query('Select Id from RecordType where SobjectType =: ObjectName and nameSpacePrefix=: strNameSpacePrefix and name =:strRtName');
        String ConsumerLiteralId = String.valueof (rt.Id);
        
      
        strRtName = 'Business';
        
        rt = Database.Query('Select Id from RecordType where SobjectType =: ObjectName and nameSpacePrefix=: strNameSpacePrefix and name =:strRtName');
        String BusinessLiteralId = String.valueof (rt.Id);
         



String listOfRecordType = '\'' + BillingLiteralId + '\',\'' + ConsumerLiteralId +  '\',\'' + BusinessLiteralId +  '\''; 

    objAccUpd.recordTypeIdList = listOfRecordType ; //ALL

        objAccUpd.sourceStatus = 'Expired';
        objAccUpd.targetStatus = 'Inactive';
        objAccUpd.limitQuery = '10';

        Test.startTest();
        
          Id batchInstanceId = Database.executeBatch(objAccUpd, 200);
        Test.stopTest();
    }
    
    
    static Account createDummyData()
    {
    
      String ObjectName = 'Account';
        String strNameSpacePrefix = 'vlocity_cmt';
        String strRtName = 'Consumer';
        
        RecordType rt = Database.Query('Select Id from RecordType where SobjectType =: ObjectName and nameSpacePrefix=: strNameSpacePrefix and name =:strRtName');
        String BillingLiteralId = String.valueof ( rt.Id);

        strRtName = 'Billing';
        rt = Database.Query('Select Id from RecordType where SobjectType =: ObjectName and nameSpacePrefix=: strNameSpacePrefix and name =:strRtName');
        String ConsumerLiteralId = String.valueof ( rt.Id);
    
    
    
       Map<String,Object> settings = new Map<String,Object> {
      'createlookupobject' => false,
        'countObjects' => 1
        };

    Account A = (Account) new testFramework('Account', new map<String, Object> {
      'CellcomExternalID__c' => 'OB1488151',
      'RecordTypeId' => ConsumerLiteralId,
      'vlocity_cmt__Status__c' => 'Expired' 
      }, settings).createObject();

    insert A;

    Account ACell = (Account) new testFramework('Account', new map<String, Object> {
      'CELL_Ind__c' => true,
      'BANPSID__c' => '221691774',
      'ParentId' => A.Id,
      'RecordTypeId' => BillingLiteralId,
      'vlocity_cmt__Status__c' => 'Expired'
      }, settings).createObject();

       insert ACell;

    Account ANv = (Account) new testFramework('Account', new map<String, Object> {
      'NETV_Ind__c' => true,
      'BANPSID__c' => '1545757',
      'ParentId' => A.Id,
       'RecordTypeId' => BillingLiteralId,
      'vlocity_cmt__Status__c' => 'Expired'     
      }, settings).createObject();

    insert ANv;
 
     System.debug('********* Cons ' + A);
     System.debug('********* Bill 1' + ACell);
     System.debug('********* Cons ' + ANv);
     
 
    return A;   
    }
}