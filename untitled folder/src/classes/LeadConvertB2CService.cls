public with sharing class LeadConvertB2CService implements Queueable{
/**
* Queueable service class for handle create convert logic: 
* To check if Lead / Contact alrady exists in Salesforce and ODATA
* To convert lead in SalesForce and update status in ODATA
* Nikolay Iliaev
* taskid PLR-42
* @class LeadConvertB2CService
* @module Contact 
*/  
    List<Contact> contactList = new List<Contact>();
    List<String> contactExternalIDList = new List<String>();
    List<String> leadSsnList = new List<String>();
    List<String> leadSequenceIdList = new List<String>();
    Map<Id, String> leadIdLeadSsnMap = new Map<Id, String>();
    Map<String, Id> leadExternalIdLeadIdMap = new Map<String, Id>();
    Map<String,Id> conExternalIdConIdMap = new Map<String,Id>();
    Map<String,Id> conSsnConIdMap = new Map<String,Id>();
    Map<Id,Id> conIdAccountIDMap = new Map<Id,Id>();
    List<Leads__x> leadXToUpdateList = new List<Leads__x>();
	
	public LeadConvertB2CService(List<Contact> contactList){
		this.contactList = contactList;
	}
	
	/**
    * Execute method
    * Nikolay Iliaev
    * @method execute	
	* @return {void}*     
    * @module Contact 
    */
	public void execute(QueueableContext context){
		convertAndUpdateLeads();
	}
	
	/**
    * Method to check if conatct exist in ODATA
    * Find relevant leads in external object then convetr them
    * Nikolay Iliaev
    * @method convertAndUpdateLeads	
	* @return {void}*      
    * @module Contact 
    */
	private void convertAndUpdateLeads(){
		
		for(Contact conItem : this.contactList){
            conIdAccountIDMap.put(conItem.Id, conItem.AccountId);
            conExternalIdConIdMap.put(conItem.CellcomExternalID__c,conItem.Id);
            contactExternalIDList.add(conItem.CellcomExternalID__c);
        }
        try{
        	
            // get contacts from external object
            List<ContactKeys__x> contactKeysList = [SELECT Id, cellcom_id__c, id_number__c
                                                    FROM ContactKeys__x
                                                    WHERE cellcom_id__c IN: contactExternalIDList];
            if(Test.isRunningTest()){
        		ContactKeys__x contactKeys = new ContactKeys__x();
        		
        		contactKeys.cellcom_id__c = 'OB000001';
        		contactKeys.id_number__c = '123';
        		
        		contactKeysList.add(contactKeys);
        	}
        	
            
            // populate conSsnConIdMap with SSN and Contact
            for(ContactKeys__x contactKeysItem : contactKeysList){
                conSsnConIdMap.put(contactKeysItem.id_number__c,conExternalIdConIdMap.get(contactKeysItem.cellcom_id__c));
            }
            
            if(!contactKeysList.isEmpty()){
                for(ContactKeys__x contKeysItem : contactKeysList){
                    leadSsnList.add(contKeysItem.id_number__c);
                }
                // get all leads from external object
                List<Leads__x> leadXList = [SELECT Id, sequence_id__c, ssn__c
                                            FROM Leads__x
                                            WHERE ssn__c IN: leadSsnList];
                
                 if(Test.isRunningTest()){
	        		Leads__x leadX = new Leads__x();
	        		
	        		leadX.sequence_id__c = 'OB0000025';
	        		leadX.ssn__c = '123';
	        		
	        		leadXList.add(leadX);
        		}
                
                for(Leads__x leadItem : leadXList){
                    leadSequenceIdList.add(leadItem.sequence_id__c);
                }
                // get all leads
                List<Lead> leadList = [SELECT id,CellcomExternalID__c,Name 
                                       FROM Lead
                                       WHERE CellcomExternalID__c IN: leadSequenceIdList];
                                       
                system.debug(LoggingLevel.ERROR, 'leadList >>>> ' + leadList);
                
                for(Lead leadItem : leadList){
                    leadExternalIdLeadIdMap.put(leadItem.CellcomExternalID__c,leadItem.Id);
                }
                
                for(Leads__x leadsXItem : leadXList){
                    leadIdLeadSsnMap.put(leadExternalIdLeadIdMap.get(leadsXItem.sequence_id__c),leadsXItem.ssn__c);
                }
                // convert all leads
                list<Database.LeadConvertResult> lst_leadConvertsResults = Database.convertLead(createLeadConvertList(leadList));
                
                // collect all ExternarId of relevat lead 
                for(Database.LeadConvertResult leadConvertResultItem : lst_leadConvertsResults){
                    if(!leadConvertResultItem.getErrors().isEmpty()){
                        leadIdLeadSsnMap.remove(leadConvertResultItem.getLeadId());
                    }
                }
                List<String> leadSsnToUpdateList = leadIdLeadSsnMap.values();
                
                system.debug(LoggingLevel.ERROR, 'leadSsnToUpdateList >>>> ' + leadSsnToUpdateList);
                
                if(!leadIdLeadSsnMap.isEmpty()){
                    // get all relevat lead from external object
                    for(Leads__x leadXItem : leadXList){
                        for(String leadSsnItem : leadSsnToUpdateList){
                            if(leadXItem.ssn__c == leadSsnItem){
                                leadXToUpdateList.add(leadXItem);
                            }
                        }
                    }
                    
                    //Update oData
                    updateOdataLeads(leadXToUpdateList);
                }
            }
            else{
                System.debug('contactKeysList is empty');
            }
        } catch (Exception ex){
            system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
	} 
	
	/**
    * Method create list of leads that need to convert
    * Nikolay Iliaev
    * @method createLeadConvert	
    * @param  {List<Lead>} leadListToConvert
    * @return {List<Database.LeadConvert>}*     
    * @module Contacts
    */
    //Max 100 leads can be converted	
	private List<Database.LeadConvert> createLeadConvertList(List<Lead> leadListToConvert){
		LeadStatus convertStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1];
        list<Database.LeadConvert> lst_leadConverts = new list<Database.LeadConvert>();
        Database.LeadConvert lc = new Database.LeadConvert();
        
        for(Lead leadItem : leadListToConvert){
            String oppName;
            oppName = leadItem.Name;
            lc.setLeadId(leadItem.Id);
            lc.setContactId(conSsnConIdMap.get(leadIdLeadSsnMap.get(leadItem.Id)));
            if((conIdAccountIDMap.get(conSsnConIdMap.get(leadIdLeadSsnMap.get(leadItem.Id))) != null)){
                lc.setAccountId(conIdAccountIDMap.get(conSsnConIdMap.get(leadIdLeadSsnMap.get(leadItem.Id))));
            }
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lst_leadConverts.add(lc);
        }
        return lst_leadConverts;
	}
	
	/**
    * Method updates lead status in oData
    * Nikolay Iliaev
    * @method updateOdataLeads	
    * @param {List<Leads__x>} leadXList
    * @return {void}*     
    * @module Contacts 
    */	
	private void updateOdataLeads(List<Leads__x> leadXList){
		OdataLeadUpdateCallBackService callback = new OdataLeadUpdateCallBackService();
        for(Leads__x leadsXItem : leadXList){
            leadsXItem.status__c = 'A';
        }
        List<Database.SaveResult> sr = Database.updateAsync(leadXList, callback);
	}
}