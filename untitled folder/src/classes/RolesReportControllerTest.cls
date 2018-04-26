/**
*   Test class for RolesReportController
*   Author Nikolay Iliaev

*   taskid PLR-1533
*   @class RolesReportControllerTest
*   @module Lead
*/
@isTest
private class RolesReportControllerTest {
	
    /**
    * Setup method
    * Nikolay Iliaev
    * @method setupTestData	
    * @return {Void}*     
    * @module Lead
    */
    @testSetup static void setupTestData() {
        //Create user roles
        List<UserRole> userRoleList = TestFactory.testCreateUserRoles();
        userRoleList[0].Name = 'Role Test';
        
        update userRoleList;
    }
    
    /**
    * Method tests init method in controller
    * Nikolay Iliaev
    * @method initTest	
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void initTest() {
        UserRole userRoleTest = [SELECT Id, DeveloperName,Name 
                                FROM UserRole 
                                WHERE Name = 'Role Test'
                                LIMIT 1];
        
        Id recordTypeId = RecordTypeService.getRecordTypeIdByName('Sela__c', 'Referant');
        
        Sela__c selaItem = TestFactory.createSelaObject();
        selaItem.NumberOfLicense__c = 50;
        selaItem.NumberOfUsedLicenses__c = 0;
        selaItem.RecordTypeId = recordTypeId;
        
        insert selaItem;
		
		Sela_Role__c selaRole = new Sela_Role__c();
        selaRole.Sela__c = selaItem.Id;
        selaRole.Role_Name__c = userRoleTest.Name;
        selaRole.Name = userRoleTest.DeveloperName;
        
        insert selaRole;
        
        Test.startTest();
        	List <UserRole> userRoleList = RolesReportController.init();
        
        	System.debug('userRoleList: ' + userRoleList);
        Test.stopTest();
    }
}