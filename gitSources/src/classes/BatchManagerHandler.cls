public with sharing class BatchManagerHandler implements triggerHandler.triggerInterface{
/**
* Class to handle BatchManager object trigger:  
* Eric Fishman
* taskid PLR-
* @class BatchManager
* @module Lead
*/


 public void insertRecords() {
        if (!Trigger.isAfter) return;
        
        RunPostETLProcess();
    }
public void updateRecords() {}
public void deleteRecords() {}
public void undeleteRecords() {}
    



/**
    * Class to invoke batch processes as part of post install
    * Eric Fishman
    * taskid PLR-871
    * @class 
    * @module Lead 
    */
    
private void RunPostETLProcess() {
	//Call to future class to invoke OSB service
List<BatchManager__c> bmList = new List<BatchManager__c>(); 	
    
    for(BatchManager__c bmItem : (List<BatchManager__c>)Trigger.new){
		if(bmItem.Action__c != null){
				bmList.add(bmItem);
		}
	}
	system.debug('### bmList>>>'+bmList);
	if(!bmList.isEmpty()){	
		
		for (BatchManager__c bm :bmList) {
		    if (bm.Action__c == 'BM01') {
			//BM01  excecute AssignmentLeadsBatch batch apex (Potentials Leads) 
				AssignmentLeadsBatch batch = new AssignmentLeadsBatch(bm);				
				ID batchprocessid = Database.executeBatch(batch,1);
			}
			
			if (bm.Action__c == 'BM02') {
				//BM02  excecute AccShareToLeadShareBatch batch apex (Offers for existing customers)
				AccShareToLeadShareBatch batch = new AccShareToLeadShareBatch();
				ID batchprocessid = Database.executeBatch(batch,200);
			}
			
			if (bm.Action__c == 'BM03') {
				//BM02  excecute AccountTeamMemberAccessUpdateBatch batch apex
				AccountTeamMemberAccessUpdateBatch batch = new AccountTeamMemberAccessUpdateBatch();
				ID batchprocessid = Database.executeBatch(batch,200);
			}
			
			if (bm.Action__c == 'BM04') {
				//BM04  excecute apex to update SELA objct with Number of Active usees per Referant
				ID queueprocessid = System.enqueueJob(new CalculateSelaSummaryService());
			}
			
			
		}		
    	
    	//System.enqueueJob(new LeadConvertB2CService(contactList));
    	
    	
    	
    	
	}
	
}


    
}