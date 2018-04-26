/**
*   Infra function for retreiving Odata.
*   Should be used by any code that querying odata, as this information cannot be,
*   queried in test classes. Therefore this handler will generate mockup data 
*   
*   @class ExternalObjectHandler
*   author Liron Cohen
*   @module Odata
*/
public class ExternalObjectHandler{

    /**
    *   method description
    *   author Liron Cohen
    *
    *   @method getXRecords
    *   @param {String} objectName
    *   @param {String} sqlQuery
    *   @param {map<String, Object>} map with values that will be created under tests. 
    *                                For any fields that not provided, function will generate dummy data
    *   @return list<sobject>
    *
    */
    public static list<sobject> getXRecords(
        String objectName, 
        String sqlQuery,
        map<String, Object> testData){
    
        list<sobject> l_sobjects = new list<sobject>();
    
        if(Test.isRunningTest()){
           
           //For test creat dummy object with testing framework
            Map<String,Object> settings = new Map<String,Object>{
                'createlookupobject' => false,
                'countObjects' => 1,
                'fillAllFields' => true
            };
        
            l_sobjects.add(new testFramework(objectName, 
                                            testData, 
                                            settings).createObject());
        }
        else{
        
            //Not test - run SQL query
            l_sobjects = database.query(sqlQuery);
        }
    
        return l_sobjects;
    }
    
    
    
   /* 
   Future enhancement: Also provide infra function for save odata
   
   //Return result for each DML Record
    public enum EXSaveResultStatus {OK, ERROR}
    
    //DML Action - support INSERT and UPDATE
    public enum DMLAction {INSERT_ACTION, UPDATE_ACTION}
    
    
    //For insert/update external objects
    public static EXSaveResult[] dmlXRecords(DMLAction action, list<Sobject> l_sobject){
        EXSaveResult[] dbXRes;
        
        if(Test.isRunningTest()){
        
            //Test - generate fake result per each record
            dbXRes = new EXSaveResult[l_sobject.size()];
            
            for(Integer index =0 ; index < l_sobject.size(); index++){
                dbXRes.add(new EXSaveResult(EXSaveResultStatus.OK, new list<Database.Error>()));
            }
        }
        else{
            
            //Not test - insert/update according to the action
            Database.SaveResult[] dbRes;
        
            if(action == DMLAction.UPDATE_ACTION){
                dbRes = database.update(l_sobject);
            }
            else if(action == DMLAction.INSERT_ACTION){
                dbRes = database.insert(l_sobject);
            }
            
            for(Database.SaveResult sr : dbRes){
                 dbXRes.add(new EXSaveResult(
                    sr.isSuccess() ? EXSaveResultStatus.OK : EXSaveResultStatus.ERROR,
                    sr.isSuccess() ? new list<Database.Error>() : sr.getErrors()));
            }
        }
        
        return dbXRes;
    }
    
    
    

    
    public class EXSaveResult{
        public String Message;
        public EXSaveResultStatus status; 
        
        public Database.Error[] dbErrors;
    
        public EXSaveResult(EXSaveResultStatus status, list<Database.Error> dbErrors){
        
            this.status = status;
            this.dbErrors = dbErrors;
        }
    }*/
}