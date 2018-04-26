public with sharing class AccountContactRelationshipsHandler implements triggerHandler.triggerInterface {	
/**
*   Class to handle AccountContactRelationshipsHandler object trigger.
*   Tal sabati
*   @module AccountContactRelationshipsHandler 
*/
	
	public static Boolean allowAccountContactRelation = false;
	
	public void insertRecords() {
        if(Trigger.IsBefore){
            checkWritePermissions(trigger.New, null);
        }
    }
        
	public void deleteRecords() {
        if(Trigger.IsBefore){checkWritePermissions(null, trigger.Old);}
    }
	
	public void updateRecords() {
        if(Trigger.IsBefore){
			checkWritePermissions(trigger.New, null);
        }
    }
    
	public void undeleteRecords() {}

	public void checkWritePermissions(list<AccountContactRelation> newAccountContactRelationList, list<AccountContactRelation> oldAccountContactRelationList){
		 
		  //   WritePermissionsObject__c.getInstance().WriteAccountContactRelationships__c
    		 if(!CustomPermissionService.getCustomPermissionByName('Write_AccountContactRelationships') && 
    		    !allowAccountContactRelation) {
			 	if(newAccountContactRelationList != null){
			 		for(AccountContactRelation relation: newAccountContactRelationList) { relation.addError(Label.errorWritePermissions);}
			 	}
			 	else{
			 		for(AccountContactRelation relation: oldAccountContactRelationList) { relation.addError(Label.errorWritePermissions);}
			 	}
    		 }
		 
	}
}