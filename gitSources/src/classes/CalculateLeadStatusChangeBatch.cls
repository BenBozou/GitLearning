/**
* Batch class will run on daily basis to calculate number of days since kast Status field's change
* Author Eric Fishman
* Taskid PLR-1082
* @class CalculateLeadStatusChangeBatch
* @module Leads
*/

global with sharing class CalculateLeadStatusChangeBatch  implements Database.batchable<sobject>, Schedulable, Database.Stateful{
	global Map<Id, DateTime> leadIdDateMap = new Map<Id, DateTime>();
	
    public Database.QueryLocator start(Database.BatchableContext info){
    	
    	// New Query based on Lead object
    	String query = 'SELECT ID, ';						
			query += '(SELECT CreatedById,CreatedDate,Field,Id,LeadId,Lead.Name, NewValue, oldvalue ';	 
			query += 'FROM Histories ';	
			query += 'WHERE field in (\'Status\', \'Created\')  ';	
			query += 'and ((Lead.RecordType.Name = \'B2C\' and CreatedDate >= LAST_N_DAYS:15 ) OR (Lead.RecordType.Name = \'B2B\' and CreatedDate >= LAST_N_DAYS:60)) ';
			query += 'order by CreatedDate DESC limit 1) ' ;
		query += 'FROM LEAD ';	
		query += 'WHERE IsDeleted=false and CreatedDate >= LAST_N_DAYS:60 and ID in ' ;
		query += '(SELECT LeadId from LeadHistory where IsDeleted=false and field in (\'Status\', \'Created\') ' ;
		query += 'and ((Lead.RecordType.Name = \'B2C\' and CreatedDate >= LAST_N_DAYS:15 ) OR (Lead.RecordType.Name = \'B2B\' and CreatedDate >= LAST_N_DAYS:60))) ';
    	
    	
    	// Old Query based on Lead History object		
		/*
		String query = 'SELECT CreatedById,CreatedDate,Field,Id,LeadId,Lead.Name, NewValue, oldvalue ';	
		query += 'FROM LeadHistory ';
		query += 'WHERE field in (\'Status\',\'Created\') ';
		query += 'and ((Lead.RecordType.Name = \'B2C\' and CreatedDate >= LAST_N_DAYS:15 )  OR (Lead.RecordType.Name = \'B2B\' and CreatedDate >= LAST_N_DAYS:60)) ';		
		query += 'order by LeadID, CreatedDate DESC';		
		*/
        return Database.getQueryLocator(query);
		
	}
	
	global void execute(SchedulableContext sc){
		database.executebatch(this, 500);
	}
	
	
	public void execute(Database.BatchableContext info, list<Lead> leadList){
		//system.debug('>>> leadList ' + leadList.size());
    	list<Lead> leadUpdateLst = new list<Lead>();
    	
    	try{
    	
    		for (Lead lead : leadList) {    
				for(LeadHistory leadHistory : lead.Histories){
					//system.debug('>>> Lead  ' + lead);    		
					Integer workingdays;										
					Lead leadDays = CaclulateDays(leadHistory);
					leadUpdateLst.add(leadDays);
					break;									
				}    			
    		}
    		
    		/*
	    	for(LeadHistory leadHistory : leadList){    		
				Integer workingdays;
				
				system.debug('>>> leadIdDateMap ' + leadIdDateMap);
				
				// check if current lead history already taken in previous execute
				if (leadIdDateMap.containskey(leadHistory.LeadId)){				
					if (leadHistory.CreatedDate > leadIdDateMap.get(leadHistory.LeadId)){
						Lead lead = CaclulateDays(leadHistory);
						leadUpdateLst.add (lead);
						leadIdDateMap.put(leadHistory.LeadId, leadHistory.CreatedDate);
					}
				}
				else{
					Lead lead = CaclulateDays(leadHistory);
					leadUpdateLst.add (lead);		
					leadIdDateMap.put(leadHistory.LeadId, leadHistory.CreatedDate);					
				}
	    	} 
	    	
	    	*/   	
	    	
	    	DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,leadUpdateLst,false);
    	}
    	catch(Exception e){
    		system.debug(Logginglevel.ERROR, 'CalculateLeadStatusChangeBatch ' + ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());
    		LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(e)); 
    		     
    	}
	}
	
    /**
	* Caclulate difference between 2 dates 
	* Eric Fishman
	* @method CaclulateDays	
	* @param {LeadHistory} objectName
	* @return {object}
	* @static
	*/
	private Lead CaclulateDays(LeadHistory leadHistory){
		Integer workingdays;
		Date hCreatedDate = Date.valueof(leadHistory.CreatedDate);	
		//Get the number of days between date range
		Integer totalnumberDays = hCreatedDate.daysBetween(System.today());
							
		//Get number working days
		workingdays = (totalnumberDays - daysOff(leadHistory.CreatedDate, System.today()));
		system.debug('>>> workingdays ' + workingdays);
		Lead lead = new Lead (Id=leadHistory.LeadId, LastStatusChangeDays__c=workingdays);
		//leadIdDateMap.put(leadHistory.LeadId, leadHistory.CreatedDate);
		
		return lead;
		
		
	}
	
	public void finish(Database.BatchableContext info){     
		
	}
	
	/**
	* Caclulate how many days Off between 2 dates 
	* Eric Fishman
	* @method daysOff	
	* @param {Datetime} startDate
	* @param {Datetime} endDate
	* @return {object}
	* @static
	*/
	public static Integer daysOff(Datetime sdate, Datetime edate)
       {
         Integer i = 0;
                
         while (sdate < edate) {
           if (sdate.format('E') == 'Fri' | sdate.format('E') == 'Sat'){
             i = i + 1;
             //system.debug('>>> i ' + i);
             //system.debug('>>> sdate ' + sdate);
           }
         sdate = sdate.addDays(1);
         }
         
         return i;
       }
}