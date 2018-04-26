public class AccountControllerTest {
    public Account temp {get;set;}
    public AccountControllerTest(ApexPages.StandardController controller) {
        string accountId = controller.getId();
         temp = [select id,income__c from account where id=:accountId limit 1];
        
        
    }
}