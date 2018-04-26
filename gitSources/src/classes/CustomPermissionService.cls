public class CustomPermissionService {
    
    
    public static Boolean getCustomPermissionByName(String requestedPerm) {
        
        Set<Id> permissionSetIds = new Set<Id>();
        
        for (SetupEntityAccess access : [SELECT ParentId FROM SetupEntityAccess WHERE SetupEntityId IN 
                                        ( SELECT Id FROM CustomPermission WHERE DeveloperName = :requestedPerm )] ) {
                permissionSetIds.add(access.ParentId);
            }
        
        String currUser = UserInfo.getUserId();
        
        List<PermissionSetAssignment> permSetAssList = [SELECT AssigneeId FROM PermissionSetAssignment 
                                                        WHERE PermissionSetId in :permissionSetIds AND AssigneeId =: currUser];
                                                        
        if( permSetAssList.size() > 0 ) {
            return true;
        }
        else {
            return false;
        }
    }

}