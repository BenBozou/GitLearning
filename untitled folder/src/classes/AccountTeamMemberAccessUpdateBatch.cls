/**
* Batch updating the Account Tema Members access permission
* @author
* @class AccountTeamMemberPErmissionUpdate
* @module
*/
global class AccountTeamMemberAccessUpdateBatch implements DataBase.Batchable<sObject>
{    
 /**
  * Method preparing the data necessary for the batch
  * @method start
  * @param  {Database.BatchableContext} BC
  * @return {Database.QueryLocator}*     
  */
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
        String query = 'SELECT Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel FROM AccountTeamMember WHERE AccountAccessLevel != \'Edit\' OR ContactAccessLevel != \'Edit\' OR OpportunityAccessLevel != \'Edit\''; 
        return Database.getQueryLocator(query);
   }
   
  /**
  * Method execute 
  * @method execute
  * @param  {Database.BatchableContext info} info
  * @param  {List<AccountTeamMember>} scope
  * @return {void}*  
  */     
   global void execute(Database.BatchableContext info, List<AccountTeamMember> accountTeamMemberList)
   {
        for(AccountTeamMember atm : accountTeamMemberList)
        {
            atm.AccountAccessLevel      = 'Edit';
            atm.ContactAccessLevel      = 'Edit';
            atm.OpportunityAccessLevel  = 'Edit';
            atm.CaseAccessLevel         = 'Read';
        }
        DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,accountTeamMemberList,false);
   } 
   
  /**
  * Method execute 
  * @method finish
  * @param  {Database.BatchableContext info} info
  * @return {void}*     
  */      
   global void finish(Database.BatchableContext info){}
}