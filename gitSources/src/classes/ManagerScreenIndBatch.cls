/**
* Batch class for ManagerScreenService class
* Nikolay Iliaev
* taskid PLR-1282
* @class ManagerScreenIndBatch
* @module Lead
* @constructor 
*/
global class ManagerScreenIndBatch implements DataBase.Batchable<sObject>{
   
    /**
    * Method prepare data for batch
    * Nikolay Iliaev
    * @method start
    * @param  {Database.BatchableContext} BC
    * @return {Database.QueryLocator}*     
    * @module Lead
    */
   global Database.QueryLocator start(Database.BatchableContext BC) {
   		String query;
   		query = 'SELECT Id, Quantity__c, User__r.Id, User__r.Profile.Name, Owner.Id,(SELECT Id, UserSkill__c, Product__c FROM User_Skill_Products__r) FROM UserSkill__c WHERE User__r.Id <> NULL'; 
		return Database.getQueryLocator(query);
   }
   
    /**
    * Method execute 
    * Nikolay Iliaev
    * @method execute
    * @param  {Database.BatchableContext info} info
    * @param  {List<UserSkill__c>} scope
    * @return {void}*     
    * @module Lead
    */     
   global void execute(Database.BatchableContext info, List<UserSkill__c> scope) {
   	
		ManagerScreenService managerSer = new ManagerScreenService();
		Map<Id,Integer> userIdAndQuantityMap = new Map<Id,Integer>();
	    Map<Id,UserSkill__c> userIdUserSkillObjectMap = new Map<Id,UserSkill__c>();
    
		for(UserSkill__c userskillItem : scope) {
			if(ProfileTypeService.getProfileTypeByName(userskillItem.User__r.Profile.Name) == 'B2B') {
				userIdAndQuantityMap.put(userSkillItem.User__r.Id,(Integer)userSkillItem.Quantity__c);
				userIdUserSkillObjectMap.put(userSkillItem.User__r.Id,userSkillItem);
			}
		}
		
		//managerSer.updateLeads(userIdAndQuantityMap,userIdUserSkillObjectMap);
		ManagerScreenService.updateLeads(userIdAndQuantityMap, JSON.serialize(userIdUserSkillObjectMap));
   } 
   
    /**
    * Method execute 
    * Nikolay Iliaev
    * @method finish
    * @param  {Database.BatchableContext info} info
    * @return {void}*     
    * @module Lead
    */      
   global void finish(Database.BatchableContext info) {    
   	 
   } 
}