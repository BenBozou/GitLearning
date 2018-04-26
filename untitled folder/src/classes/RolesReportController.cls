/**
*   Controller class - get all roles whithout referants 
*   Author Nikolay Iliaev

*   taskid PLR-1533
*   @class RolesReportController
*   @module Lead
*/
global with sharing class RolesReportController {
	
	/**
    * init method
    * Nikolay Iliaev
    * @method init	
    * @return {List <UserRole>}*     
    * @module Lead
    */
	@RemoteAction
    global static List <UserRole> init () {
	    
	    Set <String> NameSet = new Set <String>();
	    
	    for (AggregateResult item : [SELECT Name 
	                                FROM Sela_Role__c GROUP 
	                                BY Name]) {
	        NameSet.add((String) item.get('Name'));
	    }
	    
	    List <UserRole> UserRoleList = new List <UserRole>();
                	                    
        for (UserRole userRoleItem : [SELECT ID, Name, DeveloperName 
                                        FROM UserRole 
                                        WHERE PortalType = 'None']) {
            
            String tmp = userRoleItem.DeveloperName.substringBefore('_');
            if(!NameSet.contains(tmp)) {
                UserRoleList.add(userRoleItem);
            }
        }
	    
	    system.debug('UserRoleList: ' + UserRoleList);               
        return UserRoleList;
	}
}