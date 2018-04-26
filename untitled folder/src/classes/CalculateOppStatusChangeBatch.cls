/**
* Batch class will run on daily basis to calculate number of days since last Status field's change
* Author Eric Fishman
* Taskid PLR-1083
* @class CalculateOppStatusChangeBatch
* @module Leads
*/

global with sharing class CalculateOppStatusChangeBatch  implements Database.batchable<sobject>, Schedulable, Database.Stateful{
	global Map<Id, DateTime> oppIdDateMap = new Map<Id, DateTime>();

 public Database.QueryLocator start(Database.BatchableContext info){
    	
		String query = 'SELECT CreatedById,CreatedDate,Field,Id,OpportunityId ';	
		query += 'FROM OpportunityFieldHistory ';
		query += 'WHERE field in (\'created\', \'opportunityCreatedFromLead\') ';
		query += 'and Opportunity.StageName in (\'Opportunity\') ';
		query += 'and CreatedDate >= LAST_N_DAYS:120 ';
		query += 'and Opportunity.RecordType.Name = \'B2B\' ';		
		//query += 'and OpportunityId in( \'0064E000003oGRn\', \'0064E000003hOTR\') ';		
		query += 'order by OpportunityId, CreatedDate DESC';
		
		///query += 'WHERE field in (\'StageName\',\'Created\') ';	
		system.debug('>>> query ' + query);	
		return Database.getQueryLocator(query);
	}
	
	global void execute(SchedulableContext sc){
		database.executebatch(this);
	}
	
	public void execute(Database.BatchableContext info, list<OpportunityFieldHistory> oppHistoryList){
		system.debug('>>> oppHistoryList ' + oppHistoryList);
    	list<Opportunity> oppUpdateLst = new list<Opportunity>();
    	
    	try{    	
    	
    	// check if current opportunity history already taken in previous execute		
    	for(OpportunityFieldHistory oppHistory : oppHistoryList){    		
			Integer workingdays;
			
			if (oppIdDateMap.containskey(oppHistory.OpportunityId)){
				
				// check if current lead history record has latest date - can be when there is no order to run exceute methods
				if (oppHistory.CreatedDate > oppIdDateMap.get(oppHistory.OpportunityId)){					 
					Opportunity opp = CaclulateDays(oppHistory);
					oppUpdateLst.add (opp);
					oppIdDateMap.put(oppHistory.OpportunityId, oppHistory.CreatedDate);
				}				
			}			
			else{
				Opportunity opp = CaclulateDays(oppHistory);
				oppUpdateLst.add (opp);	
				oppIdDateMap.put(oppHistory.OpportunityId, oppHistory.CreatedDate);					
			}
			
    	}    	
    	
    	DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,oppUpdateLst,false);
    	}
    	catch(Exception e){
    		system.debug(Logginglevel.ERROR, 'CalculateOppStatusChangeBatch ' + ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());
    		LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(e)); 
    		     
    	}
        
    	
	}
	
	
	public void finish(Database.BatchableContext info){     
	
	}
	
	
	private Opportunity CaclulateDays(OpportunityFieldHistory oppHistory){
		Integer workingdays;
		Date hCreatedDate = Date.valueof(oppHistory.CreatedDate);	
		//Get the number of days between date range
		Integer totalnumberDays = hCreatedDate.daysBetween(System.today());
		system.debug('>>> totalnumberDays ' + totalnumberDays);							
		//Get number working days
		workingdays = (totalnumberDays - daysOff(oppHistory.CreatedDate, System.today()));
		system.debug('>>> workingdays ' + workingdays);
		Opportunity opp = new Opportunity (Id=oppHistory.OpportunityId, LastStatusChangeDays__c=workingdays);		
		
		return opp;
		
		
	}
	
	public static Integer daysOff(Datetime sdate, Datetime edate)
       {
         Integer i = 0;
                //&lt;
		                
         while (sdate < edate) {
         	system.debug('>>> sdateFormat ' + sdate.format('E'));      
           if (sdate.format('E') == 'Fri' | sdate.format('E') == 'Sat'){
             i = i + 1;             
           }
         sdate = sdate.addDays(1);
         system.debug('>>> i ' + i);
         system.debug('>>> sdate ' + sdate);
         
         
         
         
         }
         
         return i;
       }
	

    
}