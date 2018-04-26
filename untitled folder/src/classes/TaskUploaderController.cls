/**
* controller class for TaskUploader page.
* Eric Fishman
* taskid PLR-501
* @class TaskUploaderController
* @module Leads
* @constructor TaskUploaderController
*/

public with sharing class TaskUploaderController {

    transient public Blob filebody { get; set; }
    transient public String csvFile { get; set; }    
    public string fileType { get; set; }
    public Map<string, string> cellcomExternalIdsMap { get; set; }
    //public List<TaskWrapper> taskWrapeerLst {get;set;}
    public Map<Id, String> recordTypeMap { get; set; }
    public Task inputDataFromVF { get; set; }   
    
    public List <Map<String, Object>> wrapperMap;    
	public Map<String, String> columnHeaderMap = new Map<String, String>
		{
			'Owner' => 'OwnerId',			 
			'Secondary Owner' => 'SecondaryOwner__c',
			'ID' => 'ID__c',			
			'Communication Type' => 'CommunicationType__c',
			'Collector' => 'Collector__c',									
			'Paying Customer' => 'PayingCustomer__c',
			'Actions That Need To Be Made' => 'ActionsThatNeedToBeMade__c',
			'Customer Type' => 'CustomerType__c',
			'The Level Of Customer Commitment' => 'TheLevelOfCustomerCommitment__c',
			'Additional Details' => 'AdditionalDetails__c'
		} ;   
    
    
    
    public TaskUploaderController() {
    	recordTypeMap = new Map<Id, String>();
    	inputDataFromVF = new Task();
    }
    
    
    /**
	* Get Csv file from VF  
	* Eric Fishman
	* @method catchCsvFile	
	* @return {void}
	*/
    public void catchCsvFile() {
        if(inputDataFromVF.ActivityDate < Date.today()){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.DateInputError));
        	return;
        }
        
        System.debug(LoggingLevel.ERROR,'CSV File' + csvFile);                
        Set<String> ownerNtSet = new Set<String>();
        Set<String> companyNumberSet = new Set<String>();        
        OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
        
        //for(Schema.PicklistEntry entry : fieldDescribe.getPickListValues())
        //    system.debug('---> ' + entry.getLabel() + '  --  ' + entry.getValue());
        
        try {        	
        	// Get the sObject describe result for the Task object
			Schema.DescribeSObjectResult dsr = Task.sObjectType.getDescribe();
     		Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
			// Deserialize JSON came from Client side        
	        wrapperMap = (List <Map<String, Object>>) JSON.deserialize(csvFile,List<Map<String,String>>.class);
	        
	        //Loop all file rows
	        for (Map<String, Object> item : wrapperMap) {	        	        	        	
	        	System.debug(LoggingLevel.ERROR,'item:  ' + item); 
	        	
	        	for(String fieldColumn : item.keyset()) {	        		
	        		String fieldName = columnHeaderMap.get(fieldColumn);        		
	        		Schema.SObjectField field = fieldMap.get(fieldName);
	        		// Collect Federation Ids in order to get Saelsforce Ids        		
	        		if ((fieldName == 'OwnerId' || fieldName == 'SecondaryOwner__c') && (!ownerNtSet.contains((String)item.get(fieldColumn)))) { 
	        			ownerNtSet.add ((String)item.get(fieldColumn));
	        		}
	        		// Collect Company Numbers in order to get Salesforce Account Ids from ODATA
	        		if ((fieldName == 'ID__c' && !companyNumberSet.contains((String)item.get(fieldColumn)))) { 
	        			companyNumberSet.add ((String)item.get(fieldColumn));
	        		}
	        		
	        		// Debug 
	        		/* System.debug(LoggingLevel.ERROR,'fieldColumn: ' + fieldColumn);  	// Communication Type	
	        		System.debug(LoggingLevel.ERROR,'fieldName ' + fieldName);			// CustomerType__c
	        		System.debug(LoggingLevel.ERROR,'field ' + field);       		
	        		//System.debug(LoggingLevel.ERROR,'field.getDescribe().getType ' + field.getDescribe().getType()); */
	        	}
	        }
	        
	        
	        // Get Users IDs        
	        Map<String, Id> userFIdMap  = getUserIds(ownerNtSet);
	        // Get Account Ids
	        cellcomExternalIdsMap = searchAccountData(companyNumberSet);        
	        
	        // Debug 
	        System.debug(LoggingLevel.ERROR,'ownerNtSet ' + ownerNtSet);
	        System.debug(LoggingLevel.ERROR,'ownerSFSet ' + userFIdMap);	        
	      	System.debug(LoggingLevel.ERROR,'companyNumberSet ' + companyNumberSet);
	      	System.debug(LoggingLevel.ERROR,'Account IDs ' + cellcomExternalIdsMap);
	      	
	      	List<Task> taskList = new List<Task>();
	      	
	      	Integer lineNum = 1;
	      	
	      	// Loop items to preapre list of Tasks
	      	for (Map<String, Object> item : wrapperMap) {	      		
	      		lineNum++;
	      		System.debug(LoggingLevel.ERROR,'item:  ' + item);
	      		
	      		Task task = new Task();
	      		task.Subject = inputDataFromVF.CallDisposition; //'File Upload';
	      		task.RecordTypeId = fileType;
	      		task.ActivityDate = inputDataFromVF.ActivityDate;
	      		task.Description =  inputDataFromVF.Description;
	      		
	      		for(String fieldColumn : item.keyset()) {		      		
		      		String fieldName = columnHeaderMap.get(fieldColumn.trim());        		
		        	Schema.SObjectField field = fieldMap.get(fieldName);  
		    
		    		
		    		if ((fieldName == 'OwnerId') || (fieldName == 'SecondaryOwner__c')) {
		    		    String ownerId = (String)item.get(fieldColumn);
		    		    	   
	    		      // to allow secondary owner empty 
		    		   if ((fieldName == 'OwnerId' && !userFIdMap.containsKey(ownerId)) ||		    		   		 
		    		      (fieldName == 'SecondaryOwner__c' && !String.isBlank(ownerId) && !userFIdMap.containsKey(ownerId))) 		    		    
						 {  
							//add error with number, the owner does not exist in SFDC
		    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Line + ' ' + lineNum + ' - ' + Label.MissingOnwer));
						}
		    			else {
							task.put(fieldName, userFIdMap.get((String)item.get(fieldColumn)));
							continue;
						}
		    		    /*
		    			task.put(fieldName, userFIdMap.get((String)item.get(fieldColumn)));
		    			continue;
		    			*/
		    		}
		    		if (fieldName == 'ID__c') {
		    			String extId = (String)item.get(fieldColumn);
		    			if(String.isBlank(extId)){
		    				//add error with number, the id is missing
		    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Line + ' ' + lineNum + ' - ' + Label.MissingExtID));
		    			}
		    			else if(!cellcomExternalIdsMap.containsKey(extId)){
		    				//add error with number, the id does not exist in SFDC
		    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Line + ' ' + lineNum + ' - ' + Label.ExtIDNotInSFDC));
		    			}
		    			else{
			        		task.put('WhatId', cellcomExternalIdsMap.get(extId));
		    			}
		    			continue;
		   		   	}		   		   	
		   		   	
		   		   	// Debug
	        		System.debug(LoggingLevel.ERROR,'fieldColumn: ' + fieldColumn);  	// Communication Type	
	        		System.debug(LoggingLevel.ERROR,'fieldName ' + fieldName);			// CustomerType__c
	        		//System.debug(LoggingLevel.ERROR,'fieldItem ' + item.get(fieldColumn));
		   		   	
		   		   	/*
		   		   	if (field != null && field.getDescribe().getType() == Schema.DisplayType.Date) {
		   		   		Date dt = Date.valueof(item.get(fieldColumn.trim()));
		   		   		task.put(fieldName, dt);
		   		   	}
		   		   	*/		   		   	
		   			task.put(fieldName, item.get(fieldColumn));
		      	}
		      		
		      	taskList.add(task);	
	      	}
	      	
	      	system.debug('>>> ' + ApexPages.getMessages());
	      	if(!ApexPages.getMessages().isEmpty())
	      		return;
	      	
	      	System.debug(LoggingLevel.ERROR,'taskList: ' + taskList);
	        	
	        // Create Tasks in salesforce	       
	       DatabaseManager.DatabaseResult result = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION,taskList,true);
	       
	       System.debug(LoggingLevel.ERROR,'>>>>result: ' + result);
	       
	       
           if(!result.isSuccess()){
	           System.debug(Logginglevel.ERROR, 'Failed to create Tasks: \n' + result.getAllErrorMessages('\n'));
	           //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,result.getAllErrorMessages('\n')));
	           //for(Database.SaveResult[])//saveResults
	           for(Integer index = 0; index < result.saveResults.size(); index ++){
                    if(!result.saveResults.get(index).isSuccess()){
                        for(Database.Error err : result.saveResults.get(index).getErrors()){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.GeneralError));
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Line ' + (index + 1) + err.getMessage()));
                        }
                    }
                }	
           }
           else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,Label.savedSuccessfully +' ' +  taskList.size() + '\n records'));
           }
	       
        }  	
      	catch(Exception ex){
            system.debug('Exception: Failed to upload file: ' + ex.getMessage() + ':' + ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.GeneralError));
	        ApexPages.Message mss = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage() + ':' + ex.getStackTraceString());
	        ApexPages.addMessage(mss);
    	}      	
      	//return null;   
    }
    
    
    /*
     public PageReference Upload() {     	
     	return null;     	
     }*/
    
     /**
        *   Method for getting user based on his federation Id
        *   author Eric Fishman
        *   @method getUserFederationId
        *   @param {List String} federationId
        *   @return {Map}
        */
        private Map<String, Id> getUserIds(Set<String> federationIdLst){
            Map<String, Id> returnMap = new Map<String, Id>();
                        
            for (User user : [select Id, FederationIdentifier  
                                    from User
                                    where FederationIdentifier in :federationIdLst]) {
            	
            	returnMap.put(user.FederationIdentifier, user.Id);	                        	
			}
            return returnMap;
        }
    
    
    /**
        *   Method for getting Account based on cellcomexternal ID
        *   author Eric Fishman
        *   @method searchAccountData
        *   @param {List String} accKeyList
        *   @return {Map}
        */
      
        private Map<String, Id> searchAccountData(Set<String> accKeyList){
            Map<String, Id> returnMap = new Map<String, Id>();
                        
            for (Account acc : [select Id, CellcomExternalID__c  
                                    from Account
                                    where CellcomExternalID__c in :accKeyList]) {
            	
            	 system.debug('acc : ' + acc); 
            	returnMap.put(acc.CellcomExternalID__c, acc.Id);	                        	
			}
            return returnMap;
        }
   
    /**
    * Eric Fishman
    * taskid PLR-
    * @method cancel
    * @return {Pagereference}  page
    */
    public Pagereference Cancel(){
        return null; //new PageReference(retURL);
     }
    
    /**
	* Get List 
	* Eric Fishman
	* @method createLead	
	* @param {String} objectName
	* @param {String} recordTypeName
	* @return {Id}
	* @static
	*/
    public list<SelectOption> getTaskRecordTypes() {
		list<SelectOption> fileTypeOptionslst = new list<SelectOption>();
		
		OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
		
		String taskRecordTypeOrg = orgSettings.TaskUploadRecordTypes__c;
		List<String> rtList = new List<String>();
		rtList = taskRecordTypeOrg.split(',');		
		 
		
        list<RecordType> taskRecordTypes = new list<RecordType>([select Id, DeveloperName, toLabel(Name) 
        from RecordType where sObjectType='Task' and isActive=true and DeveloperName in :rtList ]);
        
        for(RecordType rt : taskRecordTypes){
            fileTypeOptionslst.add(new SelectOption(rt.Id,rt.Name));
            recordTypeMap.put(rt.Id, rt.Name);
        }	
        	
        return fileTypeOptionslst;
        }        
	
      
    
    
    
        public class  TaskWrapper{
    	// COMMON
    	public String ownerId; // {get;set;}
    	public String ownerSecondary; // {get;set;}
    	public String companyId; // {get;set;}
    	public String Description; // {get;set;}    	    	
    	public String communicationType; // {get;set;}    	
    	public String customerType; // {get;set;}    	
    	public String Status; // {get;set;}
    	//public String inConversationEndCustomerSatisfied; // {get;set;}
    	
    	// GENERAL    	    	
    	//public String isDone; // {get;set;}    	        
        
        // Collector        
        public String collector; // {get;set;}
        public String payingCustomer; // {get;set;}
        public String actionsThatNeedToBeMade; 
        //public String updatePaymentMethod {get;set;}        
        
        // Introduction Call
        /*        
        public String subjectsAreOpenToCustomer{get;set;}
        public String carriedOverlapWithMATAL {get;set;}
        public String welcomeCallMadeToTheCustomer {get;set;}
        public String customerReceivedTheFirstInvoice {get;set;}
        public String customerRreceivedExplanationInvoice {get;set;}        
        public String strengthenRelationshipWithCustomer {get;set;}
        */       
        
        //Service Satisfaction        
        public String teamName; // {get;set;}
        /*
        public String factorThatDoesTheCommunication {get;set;}
        public String incomingRequestOrRequestOutbound {get;set;}
        public String whatActionHasBeenPerformed {get;set;}
        public String taskClosingDate {get;set;}
        */
        
        //Customer Commitment
        /*
        public String theLevelOfCustomerCommitment {get;set;}
        public String HadContactWithTheCustomer {get;set;}
        public String IsCarriedEligibilityForMobility {get;set;}
        public String TheAmountOfProductMixTobelow3 {get;set;}
        public String IsPerformeMobileSatisfactionSurvey {get;set;}
        public String NumberOfTechnicalProblems {get;set;}
        public String ApplianceRepairs {get;set;}
        public String WerePriorityReservation {get;set;}
        public String TheContactWasPerformFromBeginning {get;set;}        
        ///public String whatActionHasBeenPerformed {get;set;}        
        */
        
    }        
    
   
    
}