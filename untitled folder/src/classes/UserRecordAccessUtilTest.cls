@isTest
private class UserRecordAccessUtilTest {

    static testMethod void UserRecordAccessTest() {
        
        Opportunity opp = TestFactory.testCreateOpportunity();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        
        UserRecordAccessUtil util = new UserRecordAccessUtil(sc);
        
        util = new UserRecordAccessUtil(opp.Id);
        
    }
}