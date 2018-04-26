public with sharing class LeadConvertB2BService {
    
/**
* Service class for convert logic: 
* To convert lead and create Account and Contact in ODATA
* Nikolay Iliaev
* taskid PLR-791
* @class LeadConvertB2BService
* @module Lead
* @constructor 
*/  
    List<Lead> leadList = new List<Lead>();
    List<ID> leadIdlist = new list<ID>();
    List<AccountKeys__x> accountKeysXList = new List<AccountKeys__x>();
    List<Account> accountList = new List<Account>();
    List<ContactKeys__x> contactKeysXList = new List<ContactKeys__x>();
    List<Contact> contactList = new List<Contact>();
    List<Lead> convertedLeadList = new List<Lead>();
    List<vlocity_cmt__PremisesPartyRelationship__c> premisesPartyRelationship = new List<vlocity_cmt__PremisesPartyRelationship__c>();
    Set<Id> accIdSet = new Set<Id>();
    Map<ID,Lead> leadIdLeadObject;
    Map<ID,Leads__x> lieadIdLeadXObject = new Map<ID,Leads__x>();
    Map<Id,String> leadIdPartyIdMap = new Map<Id,String>();
    Map<Id,Id> accIdLeadIdMap = new Map<Id,Id>();
    
    
    public LeadConvertB2BService(){}
    
    public LeadConvertB2BService(List<Lead> leadList){
    	this.leadList = leadList;
    	// get all converted leads in SF
		leadIdLeadObject = new map<ID, Lead>([SELECT Id, CellcomExternalID__c, Name, LeadRecordType__c, FirstName, LastName,
										(SELECT Id, company_name__c, company_number__c, /*first_name__c, last_name__c,*/ 
										sequence_id__c, ssn__c, id_type_sf__c 
                                    	FROM Leads__r)
										FROM Lead
		 				 				WHERE  Id IN : this.leadList]);
		
    	
    	convertLeadsAndCreateOdata();
    }
    
    /**
    * Method convert lead type Offer
    * Nikolay Iliaev
    * @method convertLeadTypeOffer	
    * @return {Void}*     
    * @module Lead
    */
    public Id convertLeadTypeOffer(Lead leadItem) {
        
        try {
            Database.LeadConvertResult leadConvertsResults = Database.convertLead(createLeadConvertOffer(leadItem));
            
            Lead updatedLead = [SELECT id, ConvertedOpportunityId
                                FROM Lead
                                WHERE id = : leadItem.Id];
                                
            return updatedLead.ConvertedOpportunityId;
            
        } catch (Exception ex) {
            system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
            
            return null;
        }
    }
    
    /**
    * Method convert leads and create ODATA
    * Nikolay Iliaev
    * @method leadsConvert	
    * @return {Void}*     
    * @module Lead
    */
    private void convertLeadsAndCreateOdata(){
    	
    	try{
    		System.Savepoint entryPoint = Database.setSavepoint();
    		
    		AccountContactRelationshipsHandler.allowAccountContactRelation = true;
    		
	    	list<Database.LeadConvertResult> lst_leadConvertsResults = Database.convertLead(createLeadConvertList(this.leadList));
	    	
	    	for(Database.LeadConvertResult leadConvertResItem : lst_leadConvertsResults){
	    		if(!leadConvertResItem.getErrors().isEmpty()){
                        leadIdLeadObject.remove(leadConvertResItem.getLeadId());
                }
	    	}
	        
	        // get all conveted leads
	        convertedLeadList = leadIdLeadObject.values();
	        
	        if(!Test.isRunningTest()){
	        	for(Lead leadItem : convertedLeadList){
	        		lieadIdLeadXObject.put(leadItem.Id,leadItem.Leads__r[0]);
	        	}
	        }
	        
	        List<CompetitorAsset__c> compertList = new List<CompetitorAsset__c>();
	        
	        List<Lead> leadWithAccIdAndConIdList = [SELECT Id, ConvertedAccountId, ConvertedContactId, 
	        										(SELECT Id, CustomerAccountId__c FROM Competitor_Asset__r )
	        										FROM Lead
	        										WHERE Id = : convertedLeadList];
	        
	        // get all conveted leads
	        convertedLeadList = leadIdLeadObject.values();
	        
	        System.debug(LoggingLevel.ERROR,'>>>> convertedLeadList : ' + convertedLeadList);
	        
	        for(Lead leadItem : leadWithAccIdAndConIdList){
	        	
	        	accIdSet.add(leadItem.ConvertedAccountId);
	        	accIdLeadIdMap.put(leadItem.ConvertedAccountId,leadItem.Id);
	        	
	        	AccountKeys__x accountKeaysX = new AccountKeys__x();
	        	ContactKeys__x contactKeaysX = new ContactKeys__x();
	        	
	        	//update CompetitorAsset__c object with account id
	        	if (leadItem.Competitor_Asset__r.size() > 0) {
	        		for(CompetitorAsset__c comItem : leadItem.Competitor_Asset__r) {
	        			compertList.add(new CompetitorAsset__c(Id=comItem.Id,CustomerAccountId__c=leadItem.ConvertedAccountId));
	        		}
	        		
	        	}
	        	
	        	if (Test.isRunningTest()) {
	        		//accountKeaysX.company_name__c = 'Test';
		        	accountKeaysX.customer_id__c = '123';
		        	accountKeaysX.id_number__c = '123';
		        	accountKeaysX.id_type_sf__c = 'l';
		        	
		        	/*contactKeaysX.first_name__c = 'Niko';
		        	contactKeaysX.last_name__c = 'Iliaev';*/
		        	contactKeaysX.id_number__c = '123';
		        	contactKeaysX.id_type_sf__c = 'l';
	        	} else {
	        		accountKeaysX.company_name__c = leadIdLeadObject.get(leadItem.Id).Leads__r[0].company_name__c;
		        	//accountKeaysX.customer_id__c = leadIdLeadObject.get(leadItem.Id).Leads__r[0].company_number__c;
		        	accountKeaysX.id_number__c = leadIdLeadObject.get(leadItem.Id).Leads__r[0].company_number__c;
		        	accountKeaysX.id_type_sf__c = 'B';
		        	accountKeaysX.account_type_sf__c = 'B';
		        	accountKeaysX.customer_id_type__c = 'C';
		        	
		        	/*
		        	contactKeaysX.first_name__c = leadIdLeadObject.get(leadItem.Id).Leads__r[0].first_name__c;
		        	contactKeaysX.last_name__c = leadIdLeadObject.get(leadItem.Id).Leads__r[0].last_name__c;*/
		        	contactKeaysX.id_number__c = leadIdLeadObject.get(leadItem.Id).Leads__r[0].ssn__c;
		        	contactKeaysX.id_type_sf__c = leadIdLeadObject.get(leadItem.Id).Leads__r[0].id_type_sf__c;
	        	}
	        	accountKeaysX.transactionId__c = leadItem.ConvertedAccountId;
	        	contactKeaysX.transactionId__c = leadItem.ConvertedContactId;
	        	
	        	accountKeysXList.add(accountKeaysX);
	        	contactKeysXList.add(contactKeaysX);
	        }
	        
	        
	        System.debug(LoggingLevel.ERROR,'>>>> accountKeysXList : ' + accountKeysXList);
	        System.debug(LoggingLevel.ERROR,'>>>> contactKeysXList : ' + contactKeysXList);
	        
	        // create Accounts in ODATA
	        createOdataAccounts(accountKeysXList, entryPoint);
	        // create Contact in ODATA
	        createOdataContacts(contactKeysXList, entryPoint);
	        // update Lead ODATA status
	        updateOdataLeads(lieadIdLeadXObject.values());
	        
	        Database.update(compertList);
	        
	        // PLR-1409 Start
	        // Change on Lead convert code
	        insertPremisesPartyRelationship(accIdSet,leadWithAccIdAndConIdList);
	        
    	}catch (Exception ex){
            system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
    }
    
    /**
    * Method find all PremisesLeadRelationships__c insert party id and premisis id then delete PremisesLeadRelationships
    * Nikolay Iliaev
    * taskid PLR-1409
    * @method insertPremisesLeadRelationships	
    * @param  {Set<accId>} leadListToConvert
    * @param  {List<Lead>} leadWithAccIdAndConIdList
    * @return {Void}*     
    * @module Lead
    */
    public void insertPremisesPartyRelationship(Set<Id> accIdSet, List<Lead> leadWithAccIdAndConIdList) {
    	
	     accountList = [SELECT Id, vlocity_cmt__PartyId__c
	        			 FROM Account
	         			 WHERE Id IN: accIdSet];
	     
	     
	     //Populate Map Lead id and Party Id				
	     for (Account accItem: accountList) {
	         leadIdPartyIdMap.put(accIdLeadIdMap.get(accItem.Id), accItem.vlocity_cmt__PartyId__c);
	     }
	     
	     
	     //Find all Premises Lead Relationships whith lead id and Premises id			
	     List < PremisesLeadRelationships__c > PremisesLeadRelationshipsList = [SELECT Id, Lead__c, Premises__c, PremisesType__c, Name
																		         FROM PremisesLeadRelationships__c
																		         WHERE Lead__c IN: leadWithAccIdAndConIdList];
	     
	        
	     //Create new PremisesLeadRelationships__c															
	     for (PremisesLeadRelationships__c PremisesLeadRelationshipsItem : PremisesLeadRelationshipsList) {
	          premisesPartyRelationship.add(new vlocity_cmt__PremisesPartyRelationship__c(vlocity_cmt__PartyId__c = leadIdPartyIdMap.get(PremisesLeadRelationshipsItem.Lead__c),
	             vlocity_cmt__PremisesId__c = PremisesLeadRelationshipsItem.Premises__c, Name=PremisesLeadRelationshipsItem.Name,
	             PremisesType__c = PremisesLeadRelationshipsItem.PremisesType__c));
	     }
	     
	     
	     DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION, premisesPartyRelationship,false);
	     DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.DELETE_ACTION, PremisesLeadRelationshipsList,false);
 	}
    
    /**
    * Method create list of leads that need to convert
    * Nikolay Iliaev
    * @method createLeadConvertList	
    * @param  {List<Lead>} leadListToConvert
    * @return {List<Database.LeadConvert>}*     
    * @module Lead
    */
    //Max 100 leads can be converted
    private List<Database.LeadConvert> createLeadConvertList(List<Lead> leadListToConvert){
		LeadStatus convertStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1];
        list<Database.LeadConvert> lst_leadConverts = new list<Database.LeadConvert>();
        
        
        for(Lead leadItem : leadListToConvert){
        	Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadItem.Id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lst_leadConverts.add(lc);
        }
        System.debug(LoggingLevel.ERROR,'>>>> lst_leadConverts : ' + lst_leadConverts);
        return lst_leadConverts;
	}
	
	/**
    * Method prepare lead  that need to convert
    * Nikolay Iliaev
    * @method createLeadConvertOffer	
    * @param  {Lead} leadItem
    * @return {Database.LeadConvert}*     
    * @module Lead
    */
    //Max 100 leads can be converted
    private Database.LeadConvert createLeadConvertOffer(Lead leadItem){
		LeadStatus convertStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1];
        Database.LeadConvert convertedLead = new Database.LeadConvert();
        
        
    	Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadItem.Id);
        lc.setAccountId(leadItem.AccountId__c);
        lc.setContactId(leadItem.ContactId__c);
        
        lc.setConvertedStatus(convertStatus.MasterLabel);
        convertedLead = lc;
        
        System.debug(LoggingLevel.ERROR,'ConvertedLead : ' + convertedLead);
        return convertedLead;
	}
	
	/**
    * Method creat Accounts in oData
    * Nikolay Iliaev
    * @method createOdataAccounts	
    * @param {List<AccountKeys__x>} accounKeysXtList
    * @return {void}*     
    * @module Lead 
    */	
	private void createOdataAccounts(List<AccountKeys__x> accounKeysXtList, System.Savepoint entryPoint){
		OdataAccountCallBackService callback = new OdataAccountCallBackService();
		OdataAccountCallBackService.entryPoint = entryPoint;
        Database.insertAsync(accounKeysXtList, callback);
	}
	
	/**
    * Method creat Contacts in oData
    * Nikolay Iliaev
    * @method createOdataContacts	
    * @param {List<ContactKeys__x>} contactKeysXtList
    * @return {void}*     
    * @module Lead 
    */	
	private void createOdataContacts(List<ContactKeys__x> contactKeysXtList, System.Savepoint entryPoint){
        OdataContactCallBackService callback = new OdataContactCallBackService();
        OdataContactCallBackService.entryPoint = entryPoint;
        Database.insertAsync(contactKeysXtList, callback);
	}
	
	/**
    * Method updates lead status in oData
    * Nikolay Iliaev
    * @method updateOdataLeads	
    * @param {List<Leads__x>} leadXList
    * @return {void}*     
    * @module Lead 
    */	
	private void updateOdataLeads(List<Leads__x> leadXList){
		OdataLeadUpdateCallBackService callback = new OdataLeadUpdateCallBackService();
        for(Leads__x leadsXItem : leadXList){
            leadsXItem.status__c = 'Converted';
        }
        Database.updateAsync(leadXList, callback);
	}
}