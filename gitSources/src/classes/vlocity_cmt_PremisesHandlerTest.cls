/**
*   Test class for vlocity_cmt_PremisesHandler
*   
*   @class vlocity_cmt_PremisesHandlerTest
*   author Eric Fishman
*   @module TestClass
*   @constructor
*/
@isTest
private class vlocity_cmt_PremisesHandlerTest{
	
	@testSetup 
    static void setupTestData(){    	
    	
    	 Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
    	
    	//Lead lead = TestFactory.testCreateLeadWithCellExtID();    	
    	User currentUser = [SELECT Id, ContactId FROM user WHERE id = :UserInfo.getUserId()];
    	
    	//Group groupQ = [Select g.Type, g.Name, g.Id, g.Email From Group g where g.Type = 'Queue' and g.Name = 'B2B Leads'];
						
		QueueSObject groupQ = [Select Queue.Id, Queue.name from QueueSObject where Queue.name = 'B2B Leads'];
						system.debug ('>>>>> groupQ ' + groupQ);
    	String queueId = (groupQ != null) ? groupQ.Queue.Id : currentUser.Id;
    	
    	system.debug ('>>>>> queueId ' + queueId);
    	
    	Lead lead = TestFactory.testCreateLead(queueId);
    	//Lead lead = TestFactory.testCreateLeadWithCellExtID();
		PremisesLeadRelationships__c premisesLeadRelationshipsItem = new PremisesLeadRelationships__c();
		vlocity_cmt__Premises__c premises = new vlocity_cmt__Premises__c(Name = 'Niko test',
                                                                        vlocity_cmt__StreetAddress__c='test',
                                                                        vlocity_cmt__City__c='test1');
    	
		insert premises;		
    	    	
    	premisesLeadRelationshipsItem.Lead__c = lead.Id;
    	premisesLeadRelationshipsItem.Premises__c = premises.Id;
    	
    	insert premisesLeadRelationshipsItem;
    	
		
    	OrgSettings__c orgSettings = 																							
            (OrgSettings__c ) new testFramework('OrgSettings__c', 
                                                        new map<String, Object> {'Name' => 'Org Settings','LeadB2BQueue__c' => 'B2B Leads', 'LeadB2BRecordType__c' => 'B2B' }, 
                                                        settings).createObject();
        insert orgSettings;
        
        
        List<Lead> leadList = [select vlocity_cmt__PremisesId__c, RecordType.Name, Owner.Name from Lead where Id =: lead.Id];
        
        system.debug ('>>>>> leadList ' + leadList);
        
        
        if (leadList.size() > 0) {
        	leadList[0].vlocity_cmt__PremisesId__c = premises.Id;
        	update leadList;
        }
        
         system.debug ('>>>>> leadList after ' + leadList);
        
    }
    
    
    static testMethod void PremisesOwnerChangeTest() {
    	
    	User admintuser = [Select Id, ProfileId, Profile.Name from User where Profile.Name = 'System Administrator'  limit 1];
    	
    	 system.debug ('>>>>> admintuser ' + admintuser);
    	
    	List<vlocity_cmt__Premises__c> premisesList = [select Id, OwnerId from vlocity_cmt__Premises__c]; 
    	for (vlocity_cmt__Premises__c premise : premisesList) {
    		system.debug ('>>>>> premise ' + premise);
    		premise.OwnerId = admintuser.Id;	
    	}
    	
    	
    	Test.startTest();
    	
    		update premisesList;
    	
    	Test.stopTest();
    	
    	
    }
    
    
    /**
    * Method invokes unsued methods in lead handler
    * Eric Fishman
    * @method unusedTestMethod	
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void unusedTestMethod(){
    	
    	Test.startTest();
    	
	    	vlocity_cmt_PremisesHandler Ctrl = new vlocity_cmt_PremisesHandler();		
			Ctrl.insertRecords();
			Ctrl.deleteRecords();
			Ctrl.undeleteRecords();				
					
		Test.stopTest();
    }
    
    
    
	
	
}