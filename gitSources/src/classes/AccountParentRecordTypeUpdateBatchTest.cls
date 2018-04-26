/**
*   Test class for AccountParentRecordTypeUpdateBatch process
*   Author Tal sabati
*   @class AccountParentRecordTypeUpdateBatchTest
*/
@isTest
public class AccountParentRecordTypeUpdateBatchTest {
    
    static testMethod void BatchTest(){
        Account acc = TestFactory.testCreateAccountWithBillingAccs();
        
        Test.startTest();
        	Id batchInstanceId = Database.executeBatch(new AccountParentRecordTypeUpdateBatch());
        Test.stopTest();
    }
}