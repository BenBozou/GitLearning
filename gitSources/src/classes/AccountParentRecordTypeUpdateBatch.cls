/**
* Batch fill the account parent recordType, use in Sharing Rules
* Author Tal sabati 
* @class AccountParentRecordTypeUpdateBatch
*/
global class AccountParentRecordTypeUpdateBatch implements DataBase.Batchable<sObject>{
    /**
    * Method prepare data for batch
    * @method start
    * @param  {Database.BatchableContext} BC
    * @return {Database.QueryLocator}*     
    */
   global Database.QueryLocator start(Database.BatchableContext BC) {
   		String query = 'Select Id, ParentAccountRecordType__c, Parent.RecordType.DeveloperName, ParentId From Account where ParentId <> NULL'; 
		return Database.getQueryLocator(query);
   }
   
    /**
    * Method execute 
    * @method execute
    * @param  {Database.BatchableContext info} info
    * @param  {List<Account>} scope
    * @return {void}*     
    */     
   global void execute(Database.BatchableContext info, List<Account> accountList) {
   		for(Account acc : accountList){
   			acc.ParentAccountRecordType__c = acc.Parent.RecordType.DeveloperName;
   		}
   		DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,accountList,false);
   } 
   
    /**
    * Method execute 
    * @method finish
    * @param  {Database.BatchableContext info} info
    * @return {void}*     
    */      
   global void finish(Database.BatchableContext info) {    
   	 
   }
}