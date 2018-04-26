/**
* Update the status of the Account for Migration Purpose and according to Record Type. Source Status, Target Status and Record Type are input paremeter
* Author Rosario Capasso
* @class AccountStatusUpdateOneShotBatch 
*/
global class AccountStatusUpdateOneShotBatch implements DataBase.Batchable<sObject>{
    /**
    * Method prepare data for batch
    * @method start
    * @param  {Database.BatchableContext} BC
    * @return {Database.QueryLocator}*     
    */
    public String recordTypeIdList;
    public String sourceStatus;
    public String targetStatus; 
    public String limitQuery; 
    
    
    
   global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'Select Id, vlocity_cmt__Status__c From Account where RecordTypeId in (' + recordTypeIdList + ')  and  vlocity_cmt__Status__c=\'' + sourceStatus+ '\'' ;
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
    acc.vlocity_cmt__Status__c = targetStatus;
    }
    Update accountList;
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