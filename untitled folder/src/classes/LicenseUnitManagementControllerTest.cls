/**
*   Test class for LicenseUnitManagementController
*   Author Nikolay Iliaev

*   taskid PLR-1430
*   @class LicenseUnitManagementControllerTest
*   @module Lead
*/
@isTest
private class LicenseUnitManagementControllerTest {
    
    /**
    * Setup method
    * Nikolay Iliaev
    * @method setupTestData	
    * @return {Void}*     
    * @module Lead
    */
    @testSetup static void setupTestData() {
        
        PermissionSet perSet = [SELECT Id, Name 
                                FROM PermissionSet 
                                WHERE Name = 'License_Referant' 
                                LIMIT 1];
        
        //Create user roles
        List<UserRole> userRoleList = TestFactory.testCreateUserRoles();
        
        userRoleList[0].Name = 'Role Test';
        userRoleList[1].Name = 'Role Test Manager';
        
        update userRoleList;
        
        //Create main User 
        User currentUser =  testFramework.createUser(null);
        currentUser.UserRoleId =  userRoleList[1].Id;
        
        insert currentUser;
        
        System.debug('User: ' + currentUser);
        
        PermissionSetAssignment perSetAss = new PermissionSetAssignment(
            	PermissionSetId = perSet.Id, AssigneeId = currentUser.Id
        	);
        
        insert perSetAss;
        
        //Create second user 
        User userItem =  testFramework.createUser(null);
        userItem.AllowedToUseSF__c = true;
        userItem.isActive = false;
        userItem.UserRoleId = userRoleList[0].Id;
        
        User userItem01 =  testFramework.createUser(null);
        userItem01.AllowedToUseSF__c = true;
		userItem01.isActive = true;
        userItem01.UserRoleId = userRoleList[0].Id;  
        
        insert userItem01;
        insert userItem;
    }
    
    /**
    * Method tests save method in controller
    * Nikolay Iliaev
    * @method saveTest	
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void saveUserTest() {
        
        UserRole userRoleTest = [SELECT Id, DeveloperName,Name 
                                FROM UserRole 
                                WHERE Name = 'Role Test'
                                LIMIT 1];
                                
        UserRole userRoleManager = [SELECT Id, DeveloperName,Name 
                                    FROM UserRole 
                                    WHERE Name = 'Role Test Manager'
                                    LIMIT 1];
        
        User currentUser = [SELECT Id,UserRoleId,AllowedToUseSF__c,IsActive,UserRole.DeveloperName 
                            FROM User 
                            WHERE UserRoleId =: userRoleManager.Id
                            LIMIT 1];
        
        
        User UserItem = [SELECT Id,UserRoleId,AllowedToUseSF__c,IsActive,UserRole.DeveloperName 
                         FROM User 
                         WHERE UserRoleId =: userRoleTest.Id
                         LIMIT 1];
        
        Id recordTypeId = RecordTypeService.getRecordTypeIdByName('Sela__c', 'Referant');
        
        Sela__c selaItem = TestFactory.createSelaObject();
        selaItem.NumberOfLicense__c = 50;
        selaItem.NumberOfUsedLicenses__c = 0;
        selaItem.OwnerId = currentUser.Id;
        selaItem.RecordTypeId = recordTypeId;
        
        insert selaItem;
		
		Sela_Role__c selaRole = new Sela_Role__c();
        selaRole.Sela__c = selaItem.Id;
        selaRole.Role_Name__c = userRoleTest.Name;
        selaRole.Name = userRoleTest.DeveloperName;
        
        insert selaRole;
		
		System.runAs(currentUser) {
		
            Test.startTest();
            
                Map < String, List < sObject >> resultMap = LicenseUnitManagementController.init(currentUser.Id);
                
                system.debug('JSON.serialize(resultMap): ' + JSON.serialize(resultMap));
                
                List<User> resultUserList = resultMap.get('Users');
            
                resultUserList[0].isActive = true;
            
             	String inputStr = JSON.serialize(resultMap).replaceAll('("Sela_Roles__r"):\\{.*?"records":(.*?\\])\\}.*?"(totalSize":1)*}','$1:$2').replace('"Testing"}}]','"Testing"}]');
                Map < String, List < sObject >> result2Map = LicenseUnitManagementController.save(inputStr, currentUser.Id, false);
             
            Test.stopTest();
        
		}
        
        User updatedUserItem = [SELECT Id,UserRoleId,AllowedToUseSF__c,isActive,UserRole.DeveloperName 
                           		FROM User WHERE Id =: UserItem.Id 
                                LIMIT 1];

        system.assertEquals(true, updatedUserItem.isActive, 'assertEquals');
    }
    
    /**
    * Method tests save method in controller
    * Nikolay Iliaev
    * @method saveSelaTest	
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void saveSelaTest() {
        
        UserRole userRoleTest = [SELECT Id, DeveloperName,Name 
                                FROM UserRole 
                                WHERE Name = 'Role Test'
                                LIMIT 1];
                                
        UserRole userRoleManager = [SELECT Id, DeveloperName,Name 
                                    FROM UserRole 
                                    WHERE Name = 'Role Test Manager'
                                    LIMIT 1];
        
        User currentUser = [SELECT Id,UserRoleId,AllowedToUseSF__c,isActive,UserRole.DeveloperName 
                            FROM User 
                            WHERE UserRoleId =: userRoleManager.Id
                            LIMIT 1];
        
        
        User UserItem = [SELECT Id,UserRoleId,AllowedToUseSF__c,isActive,UserRole.DeveloperName 
                         FROM User 
                         WHERE UserRoleId =: userRoleTest.Id
                         LIMIT 1];
        
        Id recordTypeId = RecordTypeService.getRecordTypeIdByName('Sela__c', 'Referant');
        
        Sela__c selaItem = TestFactory.createSelaObject();
        selaItem.NumberOfLicense__c = 50;
        selaItem.NumberOfUsedLicenses__c = 0;
        selaItem.OwnerId = currentUser.Id;
        selaItem.RecordTypeId = recordTypeId;
        
        insert selaItem;
		
		Sela_Role__c selaRole = new Sela_Role__c();
        selaRole.Sela__c = selaItem.Id;
        selaRole.Role_Name__c = userRoleTest.Name;
        selaRole.Name = userRoleTest.DeveloperName;
        
        insert selaRole;
		
		System.runAs(currentUser) {
		
            Test.startTest();
            
                Map < String, List < sObject >> resultMap = LicenseUnitManagementController.init(currentUser.Id);
                
                system.debug('JSON.serialize(resultMap): ' + JSON.serialize(resultMap));
                
                List<User> resultUserList = resultMap.get('Users');
            	
            	System.debug('resultUserList: ' + resultUserList);
            	
                resultUserList[0].isActive = true;
             	resultUserList[1].isActive = false;
            
             	String inputStr = JSON.serialize(resultMap).replaceAll('("Sela_Roles__r"):\\{.*?"records":(.*?\\])\\}.*?"(totalSize":1)*}','$1:$2').replace('"Testing"}}]','"Testing"}]');
                Map < String, List < sObject >> result2Map = LicenseUnitManagementController.save(inputStr, currentUser.Id, true);
             	System.debug('result2Map: ' + result2Map);
            Test.stopTest();
        
		}
        
        User updatedUserItem = [SELECT Id,UserRoleId,AllowedToUseSF__c,isActive,UserRole.DeveloperName 
                           		FROM User WHERE Id =: UserItem.Id 
                                LIMIT 1];

        //system.assertEquals(true, updatedUserItem.isActive, 'assertEquals');
    }
}