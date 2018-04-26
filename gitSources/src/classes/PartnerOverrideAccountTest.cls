/**
*  Test class for testing PartnerOverideAccount
*  @class partnerOverrideAccount
*  Kennedy Nyaga
*/ 
@isTest
private class PartnerOverrideAccountTest {
    @testSetup static void prepareData(){
        TestFactory.testCreateAccountWithBillingAccsCollab();
    }
    
    static testMethod void OverideTest(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='Partner Community User'];
        
        test.startTest();
             
        PageReference pageRef = Page.VF_PartnerAccount;
        Test.setCurrentPage(pageRef);
        Account a = [select Id from Account limit 1];
        ApexPages.StandardController sc = new ApexPages.standardController(a);
        partnerOverrideAccount controller = new partnerOverrideAccount(sc);
        
        String nextPage = controller.redirect().getUrl();
        
        test.stopTest();
    }
    static testMethod void OverideStandardTest(){
        
        test.startTest();
            PageReference pageRef = new PageReference([SELECT Id FROM Account LIMIT 1].Id + '?test=test');
            Test.setCurrentPage(pageRef);
            Account a = [select Id from Account limit 1];
            ApexPages.StandardController sc = new ApexPages.standardController(a);
            partnerOverrideAccount controller = new partnerOverrideAccount(sc);
            
            String nextPage = controller.redirect().getUrl();
            
            
        
        test.stopTest();
    }
    
}