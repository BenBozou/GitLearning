/**
* Scheduler class to run batch reset of the UserSKills QuantityUtilized__c of the UserSkills
* Author Mohammad Garrah
* Taskid PLR-1018
* @class UserSkillQuantityResetBatchScheduler
* @module Leads
*/
global class UserSkillQuantityResetBatchScheduler implements Database.batchable<sobject>, Schedulable {
    
	private Datetime currentRun;
	private String runMode;
	
	//System.schedule('Hourly UserSkill Quantity Reset', '0 0 * * * ?', new UserSkillQuantityResetBatchScheduler());
	//System.schedule('Daily UserSkill Quantity Reset', '0 0 0 * * ?', new UserSkillQuantityResetBatchScheduler());
	global UserSkillQuantityResetBatchScheduler(String runMode){
		this.runMode = runMode;
	}
	
	global void execute(SchedulableContext sc){
		database.executebatch(this);
	}
	
	public Database.QueryLocator start(Database.BatchableContext info){
		currentRun = Datetime.now();
		Datetime lastReset = currentRun.addHours(-1);
		String query = 'select Id from UserSkill__c';
		if(runMode == 'Hourly')
			query += ' where LastRunDate__c <: lastReset or LastRunDate__c = null';
		return Database.getQueryLocator(query);
	}
	
	
	public void execute(Database.BatchableContext info, list<UserSkill__c> userSkillsList){
    	
		for(UserSkill__c uSkill : userSkillsList){
			uSkill.LastRunDate__c = currentRun;
			uSkill.QuantityUtilizedPerHour__c = 0;
			if(runMode == 'Daily')
				uSkill.QuantityUtilized__c = 0;
		}
		
		DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,userSkillsList,false);
	}
	
	
	public void finish(Database.BatchableContext info){     
		
	}
	
}