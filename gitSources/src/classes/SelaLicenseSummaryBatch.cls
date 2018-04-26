/**
* Batch class will run on daily basis to calculate number of days since kast Status field's change
* Author Eric Fishman
* Taskid PLR-1430
* @class SelaLicenseSummaryBatch
* @module Leads
*/
global with sharing class SelaLicenseSummaryBatch implements DataBase.Batchable<sObject>{
	
	public Database.QueryLocator start(Database.BatchableContext info){
    	
		String query = ''; 
		/*
		'SELECT CreatedById,CreatedDate,Field,Id,LeadId,Lead.Name, NewValue, oldvalue ';	
		query += 'FROM LeadHistory ';
		query += 'WHERE field in (\'Status\',\'Created\') ';
		query += 'and ((Lead.RecordType.Name = \'B2C\' and CreatedDate >= LAST_N_DAYS:15 )  OR (Lead.RecordType.Name = \'B2B\' and CreatedDate >= LAST_N_DAYS:60)) ';		
		query += 'order by LeadID, CreatedDate DESC';		
		*/
        return Database.getQueryLocator(query);	
	}
	
	
	public void execute(Database.BatchableContext info, List<sobject> scope){
/*
		for(sobject s : scope){
			AccountContactRelation acr = (AccountContactRelation) s;
			acr.CellcomExternalID__c = acr.Account.CellcomExternalID__c + acr.Contact.CellcomExternalID__c;
       	}

       	update scope;
       	
       	*/
   	}
   	
   	 public void finish(Database.BatchableContext info) {    
   	 
   } 
   	
    
}