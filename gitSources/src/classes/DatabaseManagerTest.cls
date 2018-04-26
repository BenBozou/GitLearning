/**
*   Test class for DatabaseManager
*   
*   @class DatabaseManagerTest
*   author Liron Cohen
*   @module TestClass
*   @constructor
*/
@isTest
private class DatabaseManagerTest {

    static testMethod void DatabaseActionTest() {
        Account account = new Account(name='testAccount', CellcomExternalID__c = '123');
        
        
        Test.StartTest();
        
        list<Account> accountList = new list<Account>{account};
        
        DatabaseManager.DatabaseResult dbResult;
        
        dbResult = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION, accountList);
        
        System.assertEquals(dbResult.isSuccess(), true);
        System.assertEquals(dbResult.getAllErrorMessages('\n') == '', true);

        dbResult = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION, accountList);
        
        System.assertEquals(dbResult.isSuccess(), true);
        
        dbResult = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPSERT_ACTION, accountList, true, 'ACCOUNT', 'CellcomExternalID__c');
        
        System.assertEquals(dbResult.isSuccess(), true);
        
        dbResult = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.DELETE_ACTION, accountList);
        
        System.assertEquals(dbResult.isSuccess(), true);
        
        //Try insert without Id to get exception
        list<Account> account2List = new list<Account>{new Account()};
        
        dbResult = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.DELETE_ACTION, account2List);

        System.assertEquals(!dbResult.isSuccess(), true);
        
        
        Test.StopTest();
    }
}