/**
*	Test class for testing ProfileTypeService
*	@class ProfileTypeServiceTest
*	Eric Fishman
*	@module infrastructure
*/ 
@isTest
private class ProfileTypeServiceTest {
	/**
	*	method for testing ProfileTypeService
	*	Eric Fishman
	*	@method	recordTypeServicesTest
	*	@return	void
	*/
    static testMethod void profileTypeServicesTest() {
    	
    	
		Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
         ProfileType__c profileTypeSettings = 
            (ProfileType__c ) new testFramework('ProfileType__c', 
                                                        new map<String, Object> {'Name' => 'CSR B2B','Type__c' => 'B2B' }, 
                                                        settings).createObject();
        insert profileTypeSettings;
		
		
        
		
		
    	User currentuser = [Select Id, ProfileId, Profile.Name from User where Profile.Name = 'System Administrator'  limit 1];
    	
    	Test.startTest();
    		String profileTypeByName =  ProfileTypeService.getProfileTypeByName('CSR B2B');
    		system.assert(profileTypeByName !='');
    				
			String profileTypeByID =  ProfileTypeService.getProfileTypeById(currentuser.ProfileId);
			system.assert(profileTypeByID !='');
    	
    	Test.stopTest();
    }
	
    
}