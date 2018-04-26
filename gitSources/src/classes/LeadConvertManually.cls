/**
 * Web service class to invoke lead convert logic: 
 * Nikolay Iliaev
 * taskid PLR-897
 * @class LeadConvertManually
 * @module Lead
 */
global class LeadConvertManually {
    private String succsess;
    /**
     * Method get lead id then check if the lead relevant to convert 
     * Nikolay Iliaev
     * @method convertLead	
     * @return {Void}*     
     * @module Lead
     */
    webservice static String convertLead(ID leadId) {
        List < Lead > leadList = new List < Lead > ();
        Id oppId = null;
        Lead leadItem = [SELECT Id, CellcomExternalID__c, Name, LeadRecordType__c, Status, ContactId__c, AccountId__c, ContactId__r.CellcomExternalID__c, ContactId__r.AccountId
			            FROM Lead
			            WHERE Id =: leadId];
		// Convert Offer Lead type 	            
        if (leadItem.LeadRecordType__c == 'Offer') {
            if (leadItem.Status == 'LST05' || leadItem.Status == 'LST06') {
                if (leadItem.ContactId__c != null && leadItem.AccountId__c != null) {
                    LeadConvertB2BService leadConvertService = new LeadConvertB2BService();
                    oppId = leadConvertService.convertLeadTypeOffer(leadItem);
                    System.debug('oppId :' + oppId);
                    if (oppId != null) {
                        return System.Label.success_message + '#$' + oppId;
                    }
                    return System.Label.errorManagerScreen;
                } else {
                    return System.Label.NoAccountOrContact;
                }
            } else {
                return System.Label.status;
            }
		} 
        
		System.debug(LoggingLevel.ERROR,'leadItem: ' + leadItem);
		
		// Convert leads B2B and RFP types
        if (leadItem.LeadRecordType__c == 'B2B' || leadItem.LeadRecordType__c == 'RFP' ) {
            if ((leadItem.CellcomExternalID__c != null && checkCompanyNum(leadItem.CellcomExternalID__c))) {
                if (leadItem.Status == 'LST05' || leadItem.Status == 'LST06') {
                    if (leadItem.ContactId__c != null && leadItem.AccountId__c != null) {
                        System.debug('>>>> leadItem.LeadRecordType__c ' + leadItem.LeadRecordType__c);
                        System.enqueueJob(new LeadConvertB2CService(new List < Contact > {
                            leadItem.ContactId__r
                        }));
                        /*
                        System.enqueueJob(new LeadConvertB2CService(new List<Contact>(new Contact(ID=leadItem.ContactId__c, 
                        																AccountId=leadItem.AccountId__c,
                        																CellcomExternalID__c = leadItem.ContactId__r.CellcomExternalID__c))));
                        																*/
                    } else {
                        leadList.add(leadItem);
                        LeadConvertB2BService leadConvertService = new LeadConvertB2BService(leadList);
                    }
                } else {
                    return System.Label.status;
                }
            } else {
                return System.Label.missing;
            }
        } else {
            System.debug('B2B');
            return System.Label.incorect_type;
        }
        return System.Label.success_message;
    }
    /**
     * Method checks if company number is exist in the ODATA
     * Nikolay Iliaev
     * @method checkCompanyNum	
     * @return {Boolean}*     
     * @module Lead
     */
    webservice static Boolean checkCompanyNum(String cellExtId) {
        
        if(Test.isRunningTest()){
            Leads__x leadX = new Leads__x(company_number__c = '5555');
            System.debug(LoggingLevel.ERROR,'LeadX: ' + leadX);
        
            if(leadX != null && leadX.company_number__c != null) {
                return true;
        	}
        } else {
            Leads__x leadX = [SELECT Id, ExternalId, company_number__c
				            FROM Leads__x
				            WHERE ExternalId =: cellExtId
				            limit 1];
            System.debug(LoggingLevel.ERROR,'LeadX: ' + leadX);
        
            if(leadX != null && leadX.company_number__c != null) {
                return true;
        	}
        }
        return false;
    }
}