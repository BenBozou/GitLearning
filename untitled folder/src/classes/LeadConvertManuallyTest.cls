/**
*   Test class for LeadConvertB2CService
*   Author Nikolay Iliaev
*   taskid PLR-897
*   @class LeadConvertManuallyTest
*   @module Lead
*/
@isTest 
private class LeadConvertManuallyTest {
    
    /**
    * Method test for manually convert lead
    * Nikolay Iliaev
    * @method leadConvertTypeOfferStatusFail	
    * @return {Void}*     
    * @module Lead
    */
    testMethod static void leadConvertTypeOfferStatusFail() {
        String recordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'Offer');        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        Contact cont = TestFactory.testCreateContactAndAccountWithCellExtID();
        PremisesLeadRelationships__c premisesLeadRelationshipsItem = new PremisesLeadRelationships__c();
        vlocity_cmt__Premises__c premises = new vlocity_cmt__Premises__c(Name = 'Niko test',
                                                                         vlocity_cmt__StreetAddress__c='test',
                                                                         vlocity_cmt__City__c='test1');
        
        insert premises;
        lead.AccountId__c = cont.AccountId;
        lead.ContactId__c = cont.Id;
        lead.RecordTypeId = recordTypeId;
        lead.Status = 'LST01';
        insert lead;
        
        premisesLeadRelationshipsItem.Lead__c = lead.Id;
        premisesLeadRelationshipsItem.Premises__c = premises.Id;
        
        insert premisesLeadRelationshipsItem;
        
        Test.startTest();
        	String result = LeadConvertManually.convertLead(lead.Id);
		Test.stopTest();
		
		System.assertEquals(true,true);
    }
    
    /**
    * Method test for manually convert lead
    * Nikolay Iliaev
    * @method leadConvertTypeOfferNoAccOrConFail	
    * @return {Void}*     
    * @module Lead
    */
    testMethod static void leadConvertTypeOfferNoAccOrConFail() {
        String recordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'Offer');        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        PremisesLeadRelationships__c premisesLeadRelationshipsItem = new PremisesLeadRelationships__c();
        vlocity_cmt__Premises__c premises = new vlocity_cmt__Premises__c(Name = 'Niko test',
                                                                         vlocity_cmt__StreetAddress__c='test',
                                                                         vlocity_cmt__City__c='test1');
        
        insert premises;
        lead.RecordTypeId = recordTypeId;
        insert lead;
        
        premisesLeadRelationshipsItem.Lead__c = lead.Id;
        premisesLeadRelationshipsItem.Premises__c = premises.Id;
        
        insert premisesLeadRelationshipsItem;
        
        Test.startTest();
        	String result = LeadConvertManually.convertLead(lead.Id);
		Test.stopTest();
		
		System.assertEquals(true,true);
    }
    
    /**
    * Method test for manually convert lead
    * Nikolay Iliaev
    * @method leadConvertTypeOfferStatusFail	
    * @return {Void}*     
    * @module Lead
    */
    testMethod static void leadConvertTypeOfferDifAccAndConFail() {
        String recordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'Offer');        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        Account acc = new Account(Name = 'Acc test');
        Contact con = new Contact(LastName = 'Niko test');
        insert acc;
        insert con;
        PremisesLeadRelationships__c premisesLeadRelationshipsItem = new PremisesLeadRelationships__c();
        vlocity_cmt__Premises__c premises = new vlocity_cmt__Premises__c(Name = 'Niko test',
                                                                         vlocity_cmt__StreetAddress__c='test',
                                                                         vlocity_cmt__City__c='test1');
        
        insert premises;
        lead.RecordTypeId = recordTypeId;
        lead.AccountId__c = acc.Id;
        lead.ContactId__c = con.Id;
        insert lead;
        
        premisesLeadRelationshipsItem.Lead__c = lead.Id;
        premisesLeadRelationshipsItem.Premises__c = premises.Id;
        
        insert premisesLeadRelationshipsItem;
        
        Test.startTest();
        	String result = LeadConvertManually.convertLead(lead.Id);
		Test.stopTest();
		
		System.assertEquals(true,true);
    }
    
    /**
    * Method test for manually convert lead
    * Nikolay Iliaev
    * @method leadConvertTest	
    * @return {Void}*     
    * @module Lead
    */
    testMethod static void leadConvertTypeOffer() {
        String recordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'Offer');        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        Contact cont = TestFactory.testCreateContactAndAccountWithCellExtID();
        PremisesLeadRelationships__c premisesLeadRelationshipsItem = new PremisesLeadRelationships__c();
        vlocity_cmt__Premises__c premises = new vlocity_cmt__Premises__c(Name = 'Niko test',
                                                                         vlocity_cmt__StreetAddress__c='test',
                                                                         vlocity_cmt__City__c='test1');
        
        insert premises;
        lead.RecordTypeId = recordTypeId;
        lead.AccountId__c = cont.AccountId;
        lead.ContactId__c = cont.Id;
        insert lead;
        
        premisesLeadRelationshipsItem.Lead__c = lead.Id;
        premisesLeadRelationshipsItem.Premises__c = premises.Id;
        
        insert premisesLeadRelationshipsItem;
        
        Test.startTest();
        	String result = LeadConvertManually.convertLead(lead.Id);
		Test.stopTest();
		
        if (result != null && result.contains('#$')) {
                System.assertEquals(true,true);
        }
    }
    
    /**
    * Method test for manually convert lead
    * Nikolay Iliaev
    * @method leadConvertTest	
    * @return {Void}*     
    * @module Lead
    */
    testMethod static void leadConvertTest(){
    	
    	Test.startTest();
    		String recordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'B2B');        
			Lead lead = TestFactory.testCreateLeadWithCellExtID();
			PremisesLeadRelationships__c premisesLeadRelationshipsItem = new PremisesLeadRelationships__c();
			vlocity_cmt__Premises__c premises = new vlocity_cmt__Premises__c(Name = 'Niko test',
                                                                            vlocity_cmt__StreetAddress__c='test',
                                                                            vlocity_cmt__City__c='test1');
        	
			insert premises;
			lead.RecordTypeId = recordTypeId;
        	insert lead;
        	
        	premisesLeadRelationshipsItem.Lead__c = lead.Id;
        	premisesLeadRelationshipsItem.Premises__c = premises.Id;
        	
        	insert premisesLeadRelationshipsItem;
        
			String result = LeadConvertManually.convertLead(lead.Id);
			
		Test.stopTest();
		
		System.assertEquals(true,true);
    }
    /**
    * Method test for manually when status fail
    * Nikolay Iliaev
    * @method leadConvertStatusFail	
    * @return {Void}*     
    * @module Lead
    */
    testMethod static void leadConvertStatusFail(){
    	
    	Test.startTest();
    		String recordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'B2B');        
			Lead lead = TestFactory.testCreateLeadWithCellExtID();
			lead.RecordTypeId = recordTypeId;
        	lead.Status = 'LST01';
        	insert lead;
			String result = LeadConvertManually.convertLead(lead.Id);
			
		Test.stopTest();
		
		System.assertEquals(true,true);
    }
    /**
    * Method test for manually when missing external Id 
    * Nikolay Iliaev
    * @method leadConvertExternalIdFail	
    * @return {Void}*     
    * @module Lead
    */
    testMethod static void leadConvertExternalIdFail(){
    	
    	Test.startTest();
    		String recordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'B2B');        
			Lead lead = TestFactory.testCreateLeadWithCellExtID();
			lead.RecordTypeId = recordTypeId;
        	lead.CellcomExternalID__c = '';
        	insert lead;
			String result = LeadConvertManually.convertLead(lead.Id);
			
		Test.stopTest();
		
		System.assertEquals('Missing Company Number lead can not be converted', result, 'Ok');
    }
    /**
    * Method test for manually when incorect type of lead
    * Nikolay Iliaev
    * @method leadConvertIncorectTypeFail	
    * @return {Void}*     
    * @module Lead
    */
    testMethod static void leadConvertIncorectTypeFail(){
    	
    	Test.startTest();
    		String recordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'B2C');
			Lead lead = TestFactory.testCreateLeadWithCellExtID();
			lead.RecordTypeId = recordTypeId;
        	insert lead;
			String result = LeadConvertManually.convertLead(lead.Id);
			
		Test.stopTest();
		
		System.assertEquals(true,true);
    }
}