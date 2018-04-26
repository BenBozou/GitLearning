public with sharing class AccountHandler implements triggerHandler.triggerInterface {
/**
* Class to handle Account object trigger:  
*   Tal sabati
*   taskid PLR-1329
*   @module Account 
*/
    public void insertRecords() {
        if(Trigger.IsAfter){
            setParentAccountsList(trigger.new, null);
        }
    }
        
	public void deleteRecords() {
        if(Trigger.isAfter){
			setParentAccountsList(null, trigger.oldMap);
        }
    }
	
	public void updateRecords() {
        if(Trigger.isAfter){
			setParentAccountsList(trigger.new, trigger.oldMap);
        }
    }
    
	public void undeleteRecords() {}
    
    private void setParentAccountsList(list<Account> newAccountList, map<id, SObject> oldAccountMap){
    	id billingRecordTypeId = RecordTypeService.getRecordTypeIdByName('Account','Billing');
		set<string> fieldNamesSet = new set<string>{'ParentId', 'vlocity_cmt__Status__c', 'NETV_Ind__c', 'CELL_Ind__c'};
		set<id> parentIdsSet = new set<id>();
		if(oldAccountMap == null){
		    for(Account newAccount: newAccountList){
		        if(newAccount.RecordTypeId == billingRecordTypeId && newAccount.ParentId != null){
                    parentIdsSet.add(newAccount.ParentId);
		        }
		    }
		}
		else if(newAccountList == null){
		    for(string accountId : oldAccountMap.keySet()){
		        Account oldAccount = (Account) oldAccountMap.get(accountId);
		        if(oldAccount.RecordTypeId == billingRecordTypeId && oldAccount.ParentId != null){
                    parentIdsSet.add(oldAccount.ParentId);
		        }
		    }
		}
		else{
		    for(Account newAccount: newAccountList){
    		    Account oldAccount = (Account) oldAccountMap.get(newAccount.id);
    		    for(String field: fieldNamesSet) {
    		        if(newAccount.RecordTypeId == billingRecordTypeId && oldAccount.get(field) != newAccount.get(field)){
                        if(newAccount.ParentId != null){
    						parentIdsSet.add(newAccount.ParentId);
    					}
    					if(oldAccount.ParentId != null){
    						parentIdsSet.add(oldAccount.ParentId);
    					}
    					break;
    		        }
    		    }
		    }
		}
		if(!parentIdsSet.isEmpty()){
	    	list<Account> parentAccountsList = [SELECT Id, vlocity_cmt__Status__c,NETV_Ind__c, CELL_Ind__c,
					    						(SELECT Id, vlocity_cmt__Status__c, NETV_Ind__c, CELL_Ind__c FROM ChildAccounts) 
					    						FROM Account 
					    						WHERE Id IN :parentIdsSet];
			if(!parentAccountsList.isEmpty()){
		    	updateParent(parentAccountsList);
			}
		}
    }
    
    private void updateParent(list<Account> parentAccountsList){ 
		for(Account parentAccount : parentAccountsList) {
            Integer cntActive = 0;
            Integer cntSuspended = 0;
            Boolean isNetvInd = false;
            Boolean isCellInd = false;
            
            for(Account childAcc : parentAccount.ChildAccounts) {
                if(childAcc.vlocity_cmt__Status__c == 'Active'){
                	cntActive++;
                }
                if(childAcc.vlocity_cmt__Status__c == 'Suspended'){
                	cntSuspended++;
                }
                if(childAcc.NETV_Ind__c && (childAcc.vlocity_cmt__Status__c == 'Active' || childAcc.vlocity_cmt__Status__c == 'Suspended') ){
                	isNetvInd = true;
                }
                if(childAcc.CELL_Ind__c && (childAcc.vlocity_cmt__Status__c == 'Active' || childAcc.vlocity_cmt__Status__c == 'Suspended') ){
                	isCellInd = true;
                }
            }
            parentAccount.vlocity_cmt__Status__c = (cntActive > 0) ? 'Active' : (cntSuspended > 0) ? 'Suspended' : 'Inactive';
            parentAccount.vlocity_cmt__Active__c = (parentAccount.vlocity_cmt__Status__c == 'Inactive') ? 'No' : 'Yes';
            parentAccount.NETV_Ind__c = isNetvInd;      
            parentAccount.CELL_Ind__c = isCellInd;      
        }
        update parentAccountsList;
    }
}