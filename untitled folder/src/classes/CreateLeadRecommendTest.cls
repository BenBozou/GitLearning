@isTest
public class CreateLeadRecommendTest {
    
    /**
*   method for testing getUrlLinkByEnv
*   Elad Iflah
*   taskId PLR 1038
*   @method testgetUrlLinkByEnv
*   @private
*   @return void
*/
    @isTest static void CreateLeadRecomTest () {
        
        try
        {    
            
            Account acc = TestFactory.testCreateAccountAndContact();
            Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];
            
            apexpages.currentpage().getparameters().put('Id', acc.Id);
            apexpages.currentpage().getparameters().put('contactId', con.Id);
            apexpages.currentpage().getparameters().put('subscriber', '0523993008');
            apexpages.currentpage().getparameters().put('ban', '5244876');
            apexpages.currentpage().getparameters().put('psid', '12563722');
            apexpages.currentpage().getparameters().put('campId', '10026');
            apexpages.currentpage().getparameters().put('campCycle', '140');
            apexpages.currentpage().getparameters().put('treatId', '22449');
            apexpages.currentpage().getparameters().put('commCode', '12563722_10026_000369541');                      
            apexpages.currentpage().getparameters().put('provCode', '771002622449140');                      
            apexpages.currentpage().getparameters().put('provInd', '1');                      
            apexpages.currentpage().getparameters().put('agentAllDet', 'all desc');                                                          
            apexpages.currentpage().getparameters().put('agentShortDet', 'short desc');   
            
            vlocity_cmt__VlocityAction__c recomAction = TestFactory.testCreateVlocityAction();
            
            Test.startTest();
            
            CreateLeadRecommend createLeadRecom = new CreateLeadRecommend();      
            PageReference pageRef = createLeadRecom.createLeadRecom();
            //system.assertNotEquals(null, pageRef);
                                    
            Test.stopTest();
        }
        catch(Exception exc) {
            System.debug(Logginglevel.ERROR,'UrlLinksUtilTest.testgetUrlLinkByEnv - Error in test, details :' + exc.getMessage());
        }
        
    }
    
}