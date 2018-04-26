@isTest
public class UrlLinksUtilTest {
    
    /**
*   method for testing getUrlLinkByEnv
*   Elad Iflah
*   taskId POC
*   @method testgetUrlLinkByEnv
*   @private
*   @return void
*/
    @isTest static void testgetUrlLinkByEnv() {
        
        try
        {
            EnvironmentSettings__c envSetting = new EnvironmentSettings__c();
            envSetting.Name = 'Test Env';
            envSetting.CurrentEnvironment__c = 'Dev';
            envSetting.SetupOwnerId = Userinfo.getOrganizationId();
            insert(envSetting);
            
            Map<String,String> outputLinkList = new Map<String,String>();
            
            Test.startTest();        
            outputLinkList = UrlLinksUtil.getUrlLinkByEnv();
            Test.stopTest();
        }
        catch(Exception exc) {
            System.debug(Logginglevel.ERROR,'UrlLinksUtilTest.testgetUrlLinkByEnv - Error in test, details :' + exc.getMessage());
        }
        
    }
    
}