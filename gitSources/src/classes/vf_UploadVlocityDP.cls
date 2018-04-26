public class vf_UploadVlocityDP{

    public blob file {get; set;}

    public list<vlocity_cmt__VlocityUITemplate__c> l_templates {get; set;}
    
    public string jsonText {get; set;} 
    
    public vf_UploadVlocityDP(){
    
        l_templates  = new list<vlocity_cmt__VlocityUITemplate__c>();
    }
    
    
    public PageReference upload(){
    
        jsonText= file.toString();
        
        map<String, object> mJson = (map<String, object>) json.deserializeUntyped(jsonText);
        
        list<String> l_templatename = new list<String>();
        
        if(mJson.containsKey('dataPacks')){
            
            list<object> datapacks = (list<object>) mjson.get('dataPacks');
        
            for(object obj : datapacks){
                
                map<String, object> vlocityDataPacksMap = (map<String, object>) obj;
                    
                if(vlocityDataPacksMap.containsKey('VlocityDataPackData')){
                    map<String, object> mVlocityDataPackData = (map<string, object>) vlocityDataPacksMap.get('VlocityDataPackData');
                
                    list<object> lvlocity_namespace = (list<object>) mVlocityDataPackData.get('%vlocity_namespace%__VlocityUITemplate__c');
                    
                    if(lvlocity_namespace != null){
                        for(object namespaceObj : lvlocity_namespace){
                        
                            map<String, object> m_namespaceObj = (map<String, object>) namespaceObj;
                        
                            if(m_namespaceObj.containsKey('Name')){
                                l_templatename.add((String)m_namespaceObj.get('Name'));
                            }
                        }
                    }
                }
            }
        }
        
        system.debug('###'+ l_templatename ); 
        
        
        //find all relevant template
        
        l_templates = [select id, Name, vlocity_cmt__Active__c 
                                                              from vlocity_cmt__VlocityUITemplate__c
                                                              where name in :l_templatename and vlocity_cmt__Active__c=true];
        
        if(!l_templates.isEmpty()){                                                      
            for(vlocity_cmt__VlocityUITemplate__c template: l_templates){
                template.vlocity_cmt__Active__c = false;
            }
        
            //update l_templates;
        }
        
        system.debug('###' + l_templates);
        
        //upload datapack...
        
        return null;
    }
    
}