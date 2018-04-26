@isTest
private class AccountStructureTest{

    static testMethod void AccountStructureTest(){

       // AccountHierarchyTestData.createTestHierarchy();
   
       // Account topAccount      = [ Select id, name from account where name = 'HierarchyTest0' limit 1 ];
       // Account middleAccount   = [ Select id, parentID, name from account where name = 'HierarchyTest4' limit 1 ];
       // Account bottomAccount   = [ Select id, parentID, name from account where name = 'HierarchyTest9' limit 1 ];
       // Account[] accountList   = [ Select id, parentID, name from account where name like 'HierarchyTest%' ];
       
        Account bottomAccount = TestFactory.testCreateBusinessAccounts();
        Account middleAccount = [ Select id, parentID, name from account where id =: bottomAccount.ParentId limit 1 ];
        Account topAccount = [ Select id, parentID, name from account where id =: middleAccount.ParentId limit 1 ]; 
        /*List <Account> accountList   = new List <Account>();
        accountList.add(topAccount);
        accountList.add(middleAccount);
        accountList.add(bottomAccount);*/
        test.startTest();
        
	        PageReference AccountHierarchyPage = Page.AccountHierarchyPage;
	        Test.setCurrentPage( AccountHierarchyPage );
	        ApexPages.currentPage().getParameters().put( 'id', topAccount.id );
	    
	        // Instanciate Controller
	        String JSON1 = AccountStructure.getAccounts(topAccount.id);
	        String JSON2 = AccountStructure.getAccounts(middleAccount.id);
	        String JSON3 = AccountStructure.getAccounts(bottomAccount.id);
	        // Call Methodes for top account
	        system.assertequals(JSON1,JSON2);
	        system.assertequals(JSON2,JSON3);
        test.stopTest();
    }
}