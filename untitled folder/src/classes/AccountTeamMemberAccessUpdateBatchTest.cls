/**
*   AccountTeamMemberAccessUpdateBatch Test class
*   @class AccountTeamMemberAccessUpdateBatchTest
*   @author
*   @module 360
*/
@isTest
private class AccountTeamMemberAccessUpdateBatchTest
{
    static testMethod void TestBatchWithoutAnyATM()
    {
        TestFactory.testCreateAccountAndContact();
        
        Test.startTest();
        
            Id batchJobId = Database.executeBatch(new AccountTeamMemberAccessUpdateBatch());
            
        Test.stopTest();
        
        system.assertEquals(false, batchJobId == null);
    } 
    
    static testMethod void TestBatchWithoutOneATMFillingRequisitValues()
    {
        Account acc = TestFactory.testCreateAccountAndContact();
        AccountTeamMember ATM = TestFactory.CreateAccountTeamMember(acc.Id, USerInfo.getUserId(), 'Read', true);
        
        Test.startTest();
        
            Id batchJobId = Database.executeBatch(new AccountTeamMemberAccessUpdateBatch());
            
        Test.stopTest();
        
        system.assertEquals(false, batchJobId == null);
    } 
}