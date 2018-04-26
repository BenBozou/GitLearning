public class viewRecord{

    public String objectType {get; set;}
    public String recordName {get; set;}
    public String recordId {get; set;}
    public map <String, Schema.SObjectType> schemaMap ;
    
    public list<String> l_objects {get ;set;}
    public list<String> l_fields {get; set;}
    public list<String> l_values {get; set;}
    public sObject record {get;set;}
    
    public list<SelectOption> objectoptions{
    get{
        list<SelectOption> pOptions = new list<SelectOption>(); 
        
        for(String obj: l_objects){
            
            pOptions.add(new SelectOption(obj,obj));
        }
        
        return pOptions;
    }
    set;
    }
    
    public viewRecord(){
        schemaMap = Schema.getGlobalDescribe();
        l_objects = new list<string>();
        
        for(Schema.SObjectType schemaType : schemaMap.values()){
            
            Schema.DescribeSObjectResult ds = schemaType.getDescribe();
            
            if(ds.isCreateable())
                l_objects.add(ds.getName());
        }
        
        l_objects.sort();
    }
    
    
    
    public PageReference showRecord(){
    
    try{
        l_fields = new list<String>();
        l_values = new list<String>();
    
        String sql = 'select Id, ';
        
        for(Schema.SObjectField field : schemaMap.get(objectType).getDescribe().fields.getMap().values()){
            Schema.DescribeFieldResult dr  = field.getDescribe();
            
            if(dr.isUpdateable() && dr.isAccessible()){
                sql += dr.getName() + ',';
            
                l_fields.add(dr.getName());
            }
        }
        
        l_fields.sort();
        
        sql = sql.subString(0, sql.length()-1) + ' from ' +objectType;
        
        if(!String.isEmpty(recordId))
            sql += ' where id = \'' + recordId + '\'';
        else if(!String.isEmpty(recordName))
            sql += ' where name = \'' + recordName + '\'';
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Add Filter!'));
            return null;
        }
        
        
        system.debug('####'+ sql);
    
        list<sObject> l_obj = database.query(sql);
    
        if(l_obj.size() > 0){
            //for(String field: l_fields){
             //   l_values.add((String)l_obj.get(0).get(field));
           // }
            
            record = l_obj.get(0);
        
        }
        
     }catch(Exception ex){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bad thing happen...' + ex.getMessage() + ' : ' + ex.getStackTraceString()));
            return null;
     }
    
        return null;
    }
    
    
    
    public PageReference updateRecord(){
        try{
            if(record!=null)
                update record;
                
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Done'));
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bad thing happen...' + ex.getMessage() + ' : ' + ex.getStackTraceString()));
            return null;
        }
        return null;
    }
    
    
    
}