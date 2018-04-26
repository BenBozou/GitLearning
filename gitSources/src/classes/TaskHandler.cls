public with sharing class TaskHandler implements triggerHandler.triggerInterface {
/**
* Class to handle Task object trigger:  
* Nikolay Iliaev
* taskid PLR-1363
* @class TaskHandler
* @module Task 
*/
    public void insertRecords() {
       
    }
        
	public void updateRecords() {
		
        if(Trigger.isAfter) {
            updateStatus();
        }
    }
	
	public void deleteRecords() {}
	
	public void undeleteRecords() {}
	
	/**
	*	Method updates lead status 
	*	author Nikolay Iliaev / fixed by Eric
	*	@method	updateStatus
	*   @return {void}* 
	*/
	private void updateStatus() {
		list<Lead> leadsList = new list<Lead>();
		id neededRecordTypeId = RecordTypeService.getRecordTypeIdByName('Task','Get_Next_Lead_Task');				
		String prefix = Lead.sobjecttype.getDescribe().getKeyPrefix();
		
		set<id> changedTasks = triggerHandler.getIdsOfChangedRecords(trigger.new, trigger.oldMap, new set<string>{'CallStatusInd__c'});
    	
    	for (Id item : changedTasks){
	        Task taskItem = (Task) trigger.newMap.get(item);        
	        
	        if( (taskItem.CallStatusInd__c == 'TCSI02' || taskItem.CallStatusInd__c == 'TCSI03') && taskItem.RecordTypeId == neededRecordTypeId) {
	    			 if(taskItem.WhoId != null && ((String)taskItem.WhoId).startsWith(prefix)) {
	    				leadsList.add(new lead(Id=taskItem.WhoId,Status='LST02'));
	    			 }
	    		}
    	}		
		
    	try {
    		if (!leadsList.isEmpty()){
    			DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,leadsList,false);    			
    		}
    	} catch(Exception ex) {
    		system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
    	}
	}
}