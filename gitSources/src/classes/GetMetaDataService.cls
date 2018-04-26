@RestResource(urlMapping='/GetMetaData/*')
global class GetMetaDataService{

    @HttpGet
    global static String getMetaData() {
    
        map<String, object> retValues = new map<string, object>();
         
        try{
    
            String metadataType = RestContext.request.params.get('type'); //Type: objects
             
            
            if(metadataType == 'objects'){
                
                map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                
                list<String> l_objNames = new list<String>();
                
                for(Schema.SObjectType schemaType : schemaMap.values()){
                    
                    Schema.DescribeSObjectResult ds = schemaType.getDescribe();
                    
                    if(ds.isCreateable())
                        l_objNames.add(ds.getName());
                }
                
                retValues.put('values', l_objNames);
                retValues.put('status', 'ok');
                retValues.put('msg', '');
            }
            else if(metadataType == 'fields'){
            
                String objectName = RestContext.request.params.get('objectName');
                
                map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                
                list<String> l_fieldsNames = new list<String>();
                
                for(String fieldName : schemaMap.get(objectName).getDescribe().fields.getMap().keySet()){
                    
                    l_fieldsNames.add(fieldName);
                }
                
                retValues.put('values', l_fieldsNames);
                retValues.put('status', 'ok');
                retValues.put('msg', '');            
            }
            else if(metadataType == 'page'){
                list<String> l_pages = new list<String>();
                
                for(ApexPage aPage : [select id, name from ApexPage where NamespacePrefix = null]){
                    l_pages.add(aPage.name);
                }
                
                retValues.put('values', l_pages);
                retValues.put('status', 'ok');
                retValues.put('msg', '');   
            }
            else if(metadataType == 'class'){
                list<String> l_classes = new list<String>();
                
                for(ApexClass aClass : [select id, name from ApexClass where NamespacePrefix = null]){
                    l_classes.add(aClass.name);
                }
                
                retValues.put('values', l_classes);
                retValues.put('status', 'ok');
                retValues.put('msg', '');   
            }
            else if(metadataType == 'recordType'){
                String objectName = RestContext.request.params.get('objectName');
            
                list<String> l_recordType = new list<String>();
                
                for(RecordType recordType : [select id, developername from RecordType where sObjectType = :objectName]){
                    l_recordType.add(recordType.developername);
                }
                
                retValues.put('values', l_recordType);
                retValues.put('status', 'ok');
                retValues.put('msg', '');   
            }
            else if(metadataType == 'reportFolder'){
                list<String> l_folder = new list<String>();
                
                for(Folder reportFolder : [select id, name, developerName from Folder where type = 'Report' and developerName != null]){
                    l_folder.add(reportFolder.name + ':' + reportFolder.developerName);
                }
                
                retValues.put('values', l_folder);
                retValues.put('status', 'ok');
                retValues.put('msg', '');   
            }
            else if(metadataType == 'reports'){
                String objectName = RestContext.request.params.get('objectName');
            
                list<String> l_report = new list<String>();
                
                for(Report report : [select id, developername from Report where FolderName = :objectName.subStringBefore(':')]){
                    l_report.add(report.developername);
                }
                
                retValues.put('values', l_report);
                retValues.put('status', 'ok');
                retValues.put('msg', '');   
            }
        }
        catch(Exception ex){
            retValues .put('status', 'error');
            retValues .put('msg', ex.getMessage());
        }
            
        return JSON.serialize(retValues );
    }
}