/**
* Batch Class for updating AccountContactRelationship object.
* CellcomExternalID=Account.CellcomExternalID + '_' + Contact.CellcomExternalID
* Gili Yehuda
* taskid PLR - 1134
* @class Batch_ACRCellcomExternalID 
* @module 360 
*/
public class Batch_ACRCellcomExternalID implements Database.batchable<sobject>, Database.stateful{ 
	
	public Database.QueryLocator start(Database.BatchableContext info){ 
       
       return Database.getQueryLocator([Select a.Contact.CellcomExternalID__c, a.Account.CellcomExternalID__c, a.CellcomExternalID__c
       									From AccountContactRelation a
										where a.Contact.CellcomExternalID__c != null and a.Account.CellcomExternalID__c!= null]);
	}     
    
   	public void execute(Database.BatchableContext info, List<sobject> scope){

		for(sobject s : scope){
			AccountContactRelation acr = (AccountContactRelation) s;
			acr.CellcomExternalID__c = acr.Account.CellcomExternalID__c + acr.Contact.CellcomExternalID__c;
       	}

       	update scope;
   	}
    
   	public void finish(Database.BatchableContext info){     
		// Get the ID of the AsyncApexJob representing this batch job
		// from Database.BatchableContext.
	   	// Query the AsyncApexJob object to retrieve the current job's information.
	/*	AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
	      				  FROM AsyncApexJob 
	      				  WHERE Id =: info.getJobId()];
	      				  
	   	// Send an email to the Apex job's submitter notifying of job completion.
	   	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	   	String[] toAddresses = new String[] {a.CreatedBy.Email};
	   	mail.setToAddresses(toAddresses);
	   	mail.setSubject('Apex Sharing Recalculation ' + a.Status);
	   	mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
	 	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	*/
	} 
}