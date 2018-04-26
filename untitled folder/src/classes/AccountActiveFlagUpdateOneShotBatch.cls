/**
* Update the status of the Account for Migration Purpose and according to Record Type. Source value, Target Status and Record Type are input paremeter
* Author Rosario Capasso
* @class AccountActiveFlagUpdateOneShotBatch 
*/
global class AccountActiveFlagUpdateOneShotBatch implements DataBase.Batchable<sObject>{
    /**
    * Method prepare data for batch
    * @method start
    * @param  {Database.BatchableContext} BC
    * @return {Database.QueryLocator}*     
    */
    public String recordTypeIdList;
    public String sourceValueInQueryCriteria; 
    public String sourceStatus; 
    public String targetValue; 
    public String limitQuery; 
    
    
   global Database.QueryLocator start(Database.BatchableContext BC) {
    String localQuery = 'Select Id, vlocity_cmt__Active__c From Account where RecordTypeId in (' + recordTypeIdList + ') and vlocity_cmt__Active__c  =\'' + sourceValueInQueryCriteria  + '\' and  vlocity_cmt__Status__c=\'' + sourceStatus+ '\'' ;
    System.debug ('*********  '+ localQuery );
   return Database.getQueryLocator(localQuery );
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
         acc.vlocity_cmt__Active__c  = targetValue; 
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