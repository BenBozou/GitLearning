@isTest
public class B2BOpenRecommendLeadTest {
    
    /**
    *   method for testing B2BOpenRecomLeadBanTest
    *   Elad Iflah
    *   taskId bug fix
    *   @method B2BOpenRecomLeadBanTest
    *   @private
    *   @return void
    */

    @isTest static void B2BOpenRecomLeadBanTest () {
        
        try
        {    
            
            Lead L = TestFactory.testCreateLeadWithAccountAndContact();
            
            apexpages.currentpage().getparameters().put('LeadId', L.Id);
            
            vlocity_cmt__VlocityAction__c recomAction = TestFactory.testCreateVlocityAction();
            
            Test.startTest();
            
            B2BOpenRecommendLead createB2BLeadRecom = new B2BOpenRecommendLead();      
            PageReference pageRef = createB2BLeadRecom.b2bOpenRecommLead();
                                    
            Test.stopTest();
        }
        catch(Exception exc) {
            System.debug(Logginglevel.ERROR,'B2BOpenRecommendLeadTest.B2BOpenRecomLeadBanTest - Error in test, details :' + exc.getMessage());
        }
        
    }
    
    /**
    *   method for testing B2BOpenRecomLeadSubTest
    *   Elad Iflah
    *   taskId bug fix
    *   @method B2BOpenRecomLeadSubTest
    *   @private
    *   @return void
    */
    
    @isTest static void B2BOpenRecomLeadSubTest () {
        
        try
        {    
            
            Lead L = TestFactory.testCreateLeadWithAccountAndContact();
            L.TreatId__c = 'FGDGDHFGHFGJH';
            update L;
            
            apexpages.currentpage().getparameters().put('LeadId', L.Id);
            apexpages.currentpage().getparameters().put('AccountId', L.AccountId__c);
            apexpages.currentpage().getparameters().put('TreatId', 'FGDGDHFGHFGJH');
  
            vlocity_cmt__VlocityAction__c recomAction = TestFactory.testCreateVlocityAction();
            recomAction.Name = 'B2B Recommendations Open Subscriber Lead';
            update recomAction;
            
            Test.startTest();
            
            B2BOpenRecommendLead createB2BLeadRecom = new B2BOpenRecommendLead();      
            PageReference pageRef = createB2BLeadRecom.b2bOpenRecommLead();
                                    
            Test.stopTest();
        }
        catch(Exception exc) {
            System.debug(Logginglevel.ERROR,'B2BOpenRecommendLeadTest.B2BOpenRecomLeadSubTest - Error in test, details :' + exc.getMessage());
        }
        
    }
    

    
}