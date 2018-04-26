/**
* Service class for profile services.
* author Eric Fishman
* @class ProfileTypeService
* @module infrastructure

Usage Examples:*       
		
		String profileType =  ProfileTypeService.getProfileTypeByName('CSR B2B');
		
		
		String profileType =  ProfileTypeService.getProfileTypeById(UserInfo.getProfileId());
		
		

*/ 
public with sharing class ProfileTypeService {
	
	/**
	* Retrieves the profile type by Profile  
	* Eric Fishman
	* @method getRecordTypeNameById	
	* @param {String} profileName	
	* @return {String}
	* @static
	*/
	public static String getProfileTypeByName(String profileName){
		String profileType = 'B2C';
		if(String.isBlank(profileName))	return null;
		
		 Map<String, ProfileType__c> profilesMap = ProfileType__c.getAll();
		
		if (profilesMap.containskey(profileName)){
			profileType = profilesMap.get(profileName).Type__c;
		}
		
		return 	profileType;
	}
	
	
	/**
	* Retrieves the profile type by Profile Id
	* Eric Fishman
	* @method getRecordTypeNameById	
	* @param {String} profileId
	* @return {String}
	* @static
	*/
	public static String getProfileTypeById(Id profileId){
		String profileType = 'B2C';
		if(String.isBlank(profileId))	return null;		
		
		List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:profileId LIMIT 1];
		
		if (!profileList.isEmpty()){
			 Map<String, ProfileType__c> profilesMap = ProfileType__c.getAll();
			
			if (profilesMap.containskey(profileList[0].Name)){
				profileType = profilesMap.get(profileList[0].Name).Type__c;
			}		
		}
		
		return 	profileType;
	}
    
}