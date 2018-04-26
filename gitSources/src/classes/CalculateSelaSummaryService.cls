public with sharing class CalculateSelaSummaryService implements Queueable{
/**
* Queueable service class for handle create convert logic: 
* To check if Lead / Contact alrady exists in Salesforce and ODATA
* To convert lead in SalesForce and update status in ODATA
* Eric Fishman
* Taskid PLR-872
* @class CalculateSelaSummaryService
* @module Lead 
*/      


/**
    * Execute method
    * Eric Fishman
    * @method execute	
	* @return {void}*     
    * @module Lead 
    */
	public void execute(QueueableContext context){
		String res = summarize();
	}
	
	 
       
   /**
    *   Method for check if the user connected to the Omni-Chennai
    *   Author Eric Fishman
    *   @method summarize
    *   @param {RequestsData} user
    *   @return {string} 
    */ 
   public string summarize () {
    	
    	AggregateResult[] userResults;    	
    	
    	userResults = 
			[SELECT Count(ID) usedCount, UserRole.DeveloperName roleName 
			FROM User 
			WHERE AllowedToUseSF__c = true AND IsActive=true							 
			GROUP BY UserRole.DeveloperName ];	
        
        	
		System.debug('userResults: ' + userResults); 
		
    	
		Map<String, Integer> roleCount = new Map<String, Integer>();
		
		for (AggregateResult ar : userResults) { 
			System.debug('Role: ' + ar.get('roleName') +  ' usedCount: ' + ar.get('usedCount')); 
			roleCount.put((String)ar.get('roleName'),(Integer) ar.get('usedCount') );	
		} 	
		
		Map<Id, Integer> selaUsed = new Map<Id, Integer>();    
			if (!roleCount.isEmpty()) {					
				for (Sela_Role__c selaRoleItem: [SELECT Id,Name, Sela__c  FROM Sela_Role__c ]) {
					if (!selaUsed.containskey(selaRoleItem.Sela__c)) {
						selaUsed.put(selaRoleItem.Sela__c, 0);
					}
					
					 
											
					Integer roleNum = (roleCount.containskey(selaRoleItem.Name) ) ? roleCount.get(selaRoleItem.Name) : 0 ;
					System.debug('userResults: ' + selaRoleItem.Name + ' ' + roleNum);						
					selaUsed.put(selaRoleItem.Sela__c, selaUsed.get(selaRoleItem.Sela__c) + roleNum);
				}
		
		
		System.debug('selaUsed: ' + selaUsed); 
		
		List<Sela__c> selaList = new List<Sela__c>();
		
		for (Id selaId : selaUsed.keyset()) {
			Sela__c sela = new Sela__c(Id=selaId, NumberOfUsedLicenses__c = selaUsed.get(selaId) );
			selaList.add(sela);
		}
		
		if (!selaList.isEmpty()) {
			DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,selaList,false);
		}
		
				
        } 	
    	
   return 'OK';
   
   }

}