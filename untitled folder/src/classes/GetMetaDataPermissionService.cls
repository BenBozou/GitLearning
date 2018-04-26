@RestResource(urlMapping='/GetMetaDataPermission/*')
global class GetMetaDataPermissionService{

    @HttpGet
    global static String getMetaDataPermission() {
    
        map<String, object> retValues = new map<string, object>();
         
        try{
    
            String metadataType = RestContext.request.params.get('type'); //Type: object/field/page/class
            String permissionName = RestContext.request.params.get('pName');//Name of the permission
            
            if(metadataType == 'field'){
                
                String objectName = permissionName.subStringBefore('.');
                
                map<String, map<String, String>> l_profilePermission = new map<String, map<String, String>>();
                
                for(FieldPermissions fp : [SELECT Id, parentid, parent.Profile.name,parent.IsOwnedByProfile, 
                                                PermissionsRead, PermissionsEdit 
                                           FROM FieldPermissions 
                                           where field = :permissionName and sobjecttype = :objectName]){
                    
                    map<String, String> m_permission = new map<string, string>();
                                           
                    m_permission.put('readable', fp.PermissionsRead ? '1' : '0');
                    m_permission.put('editable', fp.PermissionsEdit ? '1' : '0');
                    m_permission.put('Profile', fp.parent.profile.name);
                    
                    l_profilePermission.put(fp.parent.profile.name, m_permission);
                }
                
                retValues.put('Permissions', l_profilePermission);
                retValues.put('status', 'ok');
                retValues.put('msg', '');
            }
            else if(metadataType == 'page'){
                String pageName = RestContext.request.params.get('pName');
                
                map<String, map<String, String>> l_profilePermission = new map<String, map<String, String>>();
                
                ApexPage pageRecord = [select id from ApexPage where name = :pageName];
                
                for(SetupEntityAccess setupEntity : [SELECT Parent.profile.name, SetupEntityid, SetupEntityType  
                                                     FROM SetupEntityAccess 
                                                     Where SetupEntityid = :pageRecord.id]){
                    
                    map<String, String> m_permission = new map<string, string>();
                                           
                    m_permission.put('enabled', '1');
                    m_permission.put('Profile', setupEntity.parent.profile.name);
                    
                    l_profilePermission.put(setupEntity.parent.profile.name, m_permission);                        
                }

                retValues.put('Permissions', l_profilePermission);
                retValues.put('status', 'ok');
                retValues.put('msg', '');
                
            }
            else if(metadataType == 'class'){
                String className = RestContext.request.params.get('pName');
                
            }
            else if(metadataType == 'recordType'){
                String objectRecordType = RestContext.request.params.get('pName');        
    
            }
            else if(metadataType == 'object'){
                String objectName = RestContext.request.params.get('pName');
                
            }
        }
        catch(Exception ex){
            retValues .put('status', 'error');
            retValues .put('msg', ex.getMessage());
        }
            
        return JSON.serialize(retValues );
    }
}