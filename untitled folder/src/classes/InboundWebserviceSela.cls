/*
* Service for Inboud Integrations
* author: Eric Fishman
* @class InboundWebserviceSela
* Taskid PLR-872
* @module Lead
*    endpoint : /services/apexrest/inboundWebservice/Sela/SummarizeSela			
*    Request Body:	   
*    { 	   
*	  "userIdentifier" : "informatica",
*	  "Roles": [
*	    {      
*			"Role":"R50111717"
*	    }   , 
*	    {      
*			"Role":"R50078331"
*	    } 
*	  ]    
*    } 

* {"userIdentifier": "informatica","Roles": ["R50111717","R50078331" ]}  
*
*/
public with sharing class InboundWebserviceSela implements inboundWebservice.InboundWebserviceInterface {
	
	 /**
        *   Method for handling calls to that service
        *   author Eric Fishman
        *   @method handle
        *   @param {RestRequest} request 
        *   @param {inboundWebservice.InboundRestResponse} result 
        *   @return void
        */
        
        public void handle(RestRequest request, inboundWebservice.InboundRestResponse result) { 
            try{
	            String jsonReq = request.requestBody.toString();
	            System.debug(Logginglevel.ERROR, '>>>> 100 jsonReq ' + jsonReq); 
                RequestsData req = new RequestsData();
                
            	//Map < String, Object > bodyMap = (Map < String, Object > ) response.get('Roles');                
                //Map<String, Object> objReq = (Map<String, Object>) JSON.deserializeUntyped(jsonReq);   
			
	            if(result.requestedAction == 'SummarizeSela'){
	            	if (jsonReq.contains('Roles')) {
            			req = (RequestsData) System.JSON.deserialize(jsonReq, RequestsData.class);
	            	}
	            	System.debug('req:' + req);
	            	
	                String res = presummarize(req, result);
	                //String res = CreateLeadService.createLead(jsonReq);            
	            }
	            else{
	                setResultError('Incorrect Service',2,result);
	            }
            }catch(Exception ex){
        		setResultError('Exception ' + ex.getStackTraceString(),99,result);
        	}
        }
        
        
        /**
        *   Method for Applying an application error to the Result
        *   author Eric Fishman
        *   @method setResultError
        *   @param {String} errorMessage
        *   @param {inboundWebservice.InboundRestResponse} result 
        *   @return void
        */
        private void setResultError(String errorMessage, Integer errorCode, inboundWebservice.InboundRestResponse result){
            result.statusCode = errorCode;
            result.statusMessage = errorMessage;
        }
        
        
       /**
        *   Method for check if the user connected to the Omni-Chennai
        *   Author Eric Fishman
        *   @method presummarize
        *   @param {User} user
        *   @return {string} user connected
        */ 
       private string presummarize (RequestsData req, inboundWebservice.InboundRestResponse result) {
       		
       		String res = summarize (req);
       		System.debug(Logginglevel.ERROR, '>>>> 200 summarize result: ' + res); 
       		if (res != 'OK') {
       			result.statusCode = 99; 
       			result.statusMessage = res;
       			result.serviceName = 'Sela';
       			return res;
       		}
       		else {
       			
       			result.statusCode = 0;       			
       			result.serviceName = 'Sela';
       			return 'OK';  
       		}		
       			
       }
        
        
       /**
        *   Method for check if the user connected to the Omni-Chennai
        *   Author Eric Fishman
        *   @method summarize
        *   @param {RequestsData} user
        *   @return {string} 
        */ 
       public string summarize (RequestsData req) {
        	
        	AggregateResult[] userResults;
        	List<String> roleNamesList = new List<String>();    
        	
        	
        	if (req.Roles !=null) {	 
        		/*       	
	        	for (RolesCode rr: req.Roles){
	        		roleNamesList.add(rr.Role); 
	        	} 
	        	
	        	userResults = 
				[SELECT Count(ID) usedCount, UserRole.DeveloperName roleName 
				FROM User 
				WHERE AllowedToUseSF__c = true AND IsActive=true
				and  UserRole.DeveloperName in :roleNamesList			 
				GROUP BY UserRole.DeveloperName ];	
	        	system.debug('roleNamesList: ' + roleNamesList );
	        	*/ 
        	}
        	else {
	        	userResults = 
					[SELECT Count(ID) usedCount, UserRole.DeveloperName roleName 
					FROM User 
					WHERE AllowedToUseSF__c = true AND IsActive=true							 
					GROUP BY UserRole.DeveloperName ];	
	        	}
	        	
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
			
			/*
					List<Sela__c> selaUpdateList = new List<Sela__c> ();
					for (Sela__c sela : [SELECT NumberOfUsedLicenses__c,	Role__c FROM Sela__c WHERE Role__c in :roleCount.keyset()]) {
						sela.NumberOfUsedLicenses__c = roleCount.get(sela.Role__c);
						selaUpdateList.add(sela);
					}
					if (!selaUpdateList.isEmpty()){
						DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,selaUpdateList,false);
					}
					
			*/		
					// Find Roles that don't exist in SELA object
					//for (Sela__c sela : [SELECT NumberOfUsedLicenses__c,	Role__c FROM Sela__c WHERE Role__c in :roleCount.keyset()]) {
					// 1. Get All Roles
					
					//2. 	
						
						//roleCount.keyset()						
					//}
					
	        } 	
        	
       return 'OK';
       
       }
       
       public class RequestsData{	       
	       public String userIdentifier;
	       public List<RolesCode> Roles;
       }
       
        public class RolesCode{
	     	 public String Role;
	     }
       
        
     
    
}