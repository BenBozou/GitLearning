/**
* Controller class for LicenseUnitManagement Visulal page: 
* Nikolay Iliaev
* taskid PLR-1430
* @class LicenseUnitManagementController
* @module Lead
*/  
global with sharing class LicenseUnitManagementController {
    static String PACKAGE_NAMESPACE_PREFIX = 'vlocity_cmt';
    
    /**
    * Init method 
    * Nikolay Iliaev
    * @method init
    * @param  {Id} ownerId
    * @return {Map < String, List < sObject >>}*     
    * @module Lead
    */
    @RemoteAction
    global static Map < String, List < sObject >> init(Id ownerId) {
        
        Map < String, List < sObject >> nameObjListObjMap = new Map < String, List < sObject >> ();
        
        System.debug(LoggingLevel.ERROR, 'ownerId : ' + ownerId);
        
        List < String > roleName = new List < String >();
        List < Schema.FieldSetMember > UserFields = SObjectType.User.FieldSets.Labels.getFields();
        List < Sela__c > selaList = getSelaList(ownerId);
        
        System.debug('selaList: ' + selaList);
        nameObjListObjMap.put('Sela__c', selaList);
        for (Sela__c licenseItem: selaList) {
            for (Sela_Role__c role :licenseItem.Sela_Roles__r) {
                roleName.add(role.Name);
            }
        }
        
        String query1 = 'SELECT ';
        for (Schema.FieldSetMember f: UserFields) {
            query1 += f.getFieldPath() + ', ';
        }
        query1 += 'Id,Profile.Id, UserRole.DeveloperName,UserRole.RollupDescription FROM User WHERE' +
        '((ContactId = null and RoleCode__c IN : roleName )' + 
        'OR (ContactId <> null and Profile.Name IN : roleName))AND (AllowedToUseSF__c = true)' + 
        'ORDER BY UserRole.RollupDescription, UserRole.Name,Name';
        
        List < User > userList = Database.query(query1);
        
        nameObjListObjMap.put('Users', userList);
        return nameObjListObjMap;
    }
    
    /**
    * Save method that save Sela object and users
    * Nikolay Iliaev
    * @method save
    * @param  {Id} ownerId
    * @return {Map < String, List < sObject >>}*     
    * @module Lead
    */
    @RemoteAction
    global static Map < String, List < sObject >> save(String jsonObj, Id ownerId, Boolean isUser) {
        Integer sum = 0;
        Map < String, Object > inputMap = (Map < String, Object > ) JSON.deserializeUntyped(jsonObj);
        List <User> userToUpdateList = new List<User>();
        List <User> assignVlocityLicenseList = new List <User>();
        List <User> removeVlocityLicenseList = new List <User>();
        
        System.debug(LoggingLevel.ERROR, 'inputMap: ' + inputMap);
        
        List < Sela__c > selaList = getSelaList(ownerId);
        
        List < User > userList = (List < User > ) JSON.deserialize(JSON.serialize(inputMap.get('Users')), List < User > .class);
        
        System.debug(LoggingLevel.ERROR, 'users: ' + userList);
        
        Map <Id,User> oldUsersMap = new Map <Id,User>([SELECT Id, isActive 
                                                        FROM User 
                                                        WHERE Id IN : userList]);
                                
        //find the PackageLicense Id
        PackageLicense pl = [SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, 
        					 ExpirationDate,Status 
        					 FROM PackageLicense 
        					 WHERE NamespacePrefix = :PACKAGE_NAMESPACE_PREFIX];
    	
    	List<UserPackageLicense> userPackageLicenseList = [SELECT ID,UserId
                											FROM UserPackageLicense
                											WHERE PackageLicenseId =: pl.Id 
                											AND UserId in: userList];
                											
        // populat map with user id that exist in the UserPackageLicense object       											
		Map<Id,Boolean> IdUserMap = new Map<Id,Boolean>();
		
		for(UserPackageLicense item : userPackageLicenseList) {
		    IdUserMap.put(item.UserId,true);
		}
		
		Integer totalsum = (Integer)selaList[0].NumberOfUsedLicenses__c; 
		
        //calculate all active users to update sela object
        for (Sela_Role__c selaItem: selaList[0].Sela_Roles__r) {
            sum = 0;
            for (User userItem: userList) {
                if (userItem.isActive && (userItem.UserRole.DeveloperName == selaItem.Name  
                    || userItem.Profile.Name == selaItem.Name)) {
                    // Add vlocity licenses 
                    if(!IdUserMap.containsKey(userItem.Id)) {
                        assignVlocityLicenseList.add(userItem);
                    }
                    if (userItem.isActive != oldUsersMap.get(userItem.Id).isActive) {
                        userToUpdateList.add(userItem);
                    }
                    sum++;
                } else if(!userItem.isActive && (userItem.UserRole.DeveloperName == selaItem.Name || 
                            userItem.Profile.Name == selaItem.Name)) {
                    // Remove vlocity licenses
                    if(IdUserMap.containsKey(userItem.Id)) {
                        removeVlocityLicenseList.add(userItem);
                    }
                    if (userItem.isActive != oldUsersMap.get(userItem.Id).isActive) {
                        userToUpdateList.add(userItem);
                    }
                    sum--;
                }
            }
            totalsum += sum;
        }
        
        selaList[0].NumberOfUsedLicenses__c = totalsum;
        
        System.debug(LoggingLevel.ERROR, 'userToUpdateList: ' + userToUpdateList);
        
        if(isUser) {
            DatabaseManager.DatabaseResult resultUser = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,userToUpdateList,false);
            if(!resultUser.isSuccess()) {
                System.debug(Logginglevel.ERROR, 'User Error' + resultUser.getAllErrorMessages('\n'));
                return null;
            }
            
            if(!assignVlocityLicenseList.isempty()) {
                 if(!assignVlocityLicense(assignVlocityLicenseList)) {
                     return null;
                 }
            }
            if(!removeVlocityLicenseList.isEmpty()) {
                if(!removeVlocityLicense(removeVlocityLicenseList,userPackageLicenseList)) {
                    return null;
                }
            }
        } else {
             DatabaseManager.DatabaseResult resultSela = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,selaList,false);
             if(!resultSela.isSuccess()) {
                 System.debug(Logginglevel.ERROR, 'Sela Error' + resultSela.getAllErrorMessages('\n'));
                 return null;
             }
        }   
        return init(ownerId);
    }
    
    /**
    * Method adds licenses of vilocity
    * Nikolay Iliaev
    * @method assignVlocityLicense
    * @param  {List<User> usersToAssignLicenses}
    * @return {Void}*     
    * @module Lead
    */
    public static Boolean assignVlocityLicense(List<User> usersToAssignLicenses) {
		//find the PackageLicense Id
        PackageLicense pl = [SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, 
        					 ExpirationDate,Status FROM PackageLicense WHERE 
        					 NamespacePrefix = :PACKAGE_NAMESPACE_PREFIX];
        
		List<UserPackageLicense> UserPackageLicenseList = new List<UserPackageLicense>();
        
        //create a new UserPackageLicense record for each user with the specified profile
        for (Integer i = 0; i< usersToAssignLicenses.size(); i++){
              UserPackageLicense upl = new UserPackageLicense();
              upl.PackageLicenseId = pl.Id;
              upl.UserId = usersToAssignLicenses[i].Id;
              UserPackageLicenseList.add(upl);
        }
		DatabaseManager.DatabaseResult result = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION,UserPackageLicenseList,false);
		if(!result.isSuccess()) {
		    System.debug(Logginglevel.ERROR, 'UserPackageLicense Error' + result.getAllErrorMessages('\n'));
		    return false;
		}
		
		return true;
	}
	
	/**
    * Method remove licenses of vilocity
    * Nikolay Iliaev
    * @method removeVlocityLicense
    * @param  {List<User> usersToAssignLicenses}
    * @return {Void}*     
    * @module Lead
    */
	public static Boolean removeVlocityLicense(List<User> usersToAssignLicenses,List<UserPackageLicense> userPackageLicenseList) {
	
        if (!userPackageLicenseList.isEmpty()){		
    		DatabaseManager.DatabaseResult result = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.DELETE_ACTION,UserPackageLicenseList,false);
    		if(!result.isSuccess()) {
    		    System.debug(Logginglevel.ERROR, 'UserPackageLicense Error' + result.getAllErrorMessages('\n'));
		        return false;
		    }
    	}
    	return true;
	}
	
	/**
    * Method gets list of Sela__c object
    * Nikolay Iliaev
    * @method getSelaList
    * @return {List<Sela__c> getSela}*     
    * @module Lead
    */
	public static List < Sela__c > getSelaList (Id ownerId) {
	    
	    List < Schema.FieldSetMember > selaFields = SObjectType.SelaProfile__c.FieldSets.Labels.getFields();
	    Id recordTypeId = RecordTypeService.getRecordTypeIdByName('Sela__c', 'Referant');
	    // check OwnerId parameter in url
	    Id currentUserId = ownerId == null ? UserInfo.getUserId() : ownerId;
	    
	    String query = 'SELECT ';
        for (Schema.FieldSetMember f : selaFields) {
            //query += f.getFieldPath() + ', ';
        }
        
	    query += 'Id,Name, NumberOfLicenseNew__c, NumberOfRemainingLicense__c, NumberOfUsedLicensesNew__c, UsedLicenses__c, (SELECT Id, Name,Role_Name__c from Sela_Roles__r), (SELECT Id, Name, NumberOfLicenseNew__c, NumberOfRemainingLicense__c, NumberOfUsedLicensesNew__c, UsedLicenses__c from SelaProfiles__r) FROM Sela__c WHERE OwnerId = : currentUserId AND RecordTypeId =:recordTypeId';
	    
        return Database.query(query);
	}
}