/**
*   Database Manager
*   
*   @class DatabaseManager
*   author Liron Cohen
*   @module infrastructure
*
*   Description: Used to preform DML actions - Insert/Update/Upsert/Delete
*
*   Usage examples:
*
*       //Insert accounts
*       DatabaseManager.runDMLAction(
*            DatabaseManager.DML_ACTION.INSERT_ACTION,
*            account_list,
*            true);

*
*       //Delete accounts
*       DatabaseManager.runDMLAction(
*            DatabaseManager.DML_ACTION.DELETE_ACTION,
*            account_list,
*            true);
*
*       //Upsert accounts  - Object name and external ID field should be provided as parameters
*       DatabaseManager.runDMLAction(
*            DatabaseManager.DML_ACTION.UPSERT_ACTION,
*            account_list,
*            true,
*            'Account',
*            'CellcomExternalID__c');
*/
public class DatabaseManager{

    public enum DML_ACTION { INSERT_ACTION, UPDATE_ACTION, UPSERT_ACTION, DELETE_ACTION}


    /*
    *   method to run DML Action
    *   author Liron Cohen
    *
    *   @method runDMLAction
    *   @param  {DML_ACTION}        action
    *   @param  {list<sobject>}     l_records
    *   @return {DatabaseResult}    DatabaseResult
    */
    public static DatabaseResult runDMLAction(DML_ACTION action, 
                                              list<sobject> l_records){
        
        return runDMLAction(action, l_records, true);
    }

    /*
    *   method to run DML Action
    *   author Liron Cohen
    *
    *   @method runDMLAction
    *   @param  {DML_ACTION}        action
    *   @param  {list<sobject>}     l_records
    *   @param  {Boolean }          allOrNone
    *   @return {DatabaseResult}    DatabaseResult
    */
    public static DatabaseResult runDMLAction(DML_ACTION action, 
                                              list<sobject> l_records,
                                              Boolean allOrNone){
        
        return runDMLAction(action, l_records, allOrNone, '', '');
    }
    
    /*
    *   method to run DML Action (signature for Upsert action)
    *   author Liron Cohen
    *
    *   @method runDMLAction
    *   @param  {DML_ACTION}        action
    *   @param  {list<sobject>}     l_records
    *   @param  {Boolean }          allOrNone       Note: In upsert action it will always be true, due to SF limitation
    *   @param  {String}            sObjectAPIName
    *   @return {String}            externalIdField
    */
    public static DatabaseResult runDMLAction(DML_ACTION action, 
                                              list<sobject> l_records,
                                              Boolean allOrNone,
                                              String sObjectAPIName,
                                              String externalIdField){
                                                
        DatabaseResult databaseResult = new DatabaseResult();
    
        try{
    
            if(action == DML_ACTION.DELETE_ACTION){
                databaseResult.deleteResults = Database.delete(l_records, allOrNone);
                
                if (databaseResult.deleteResults != null){
                    for(Integer index = 0; index < databaseResult.deleteResults.size(); index ++){
                        if(! databaseResult.deleteResults.get(index).isSuccess()){
                            for(Database.Error err : databaseResult.deleteResults.get(index).getErrors()){
                                databaseResult.l_errorMsg.add(err.getStatusCode() + ' - ' + err.getMessage() + 
                                    ' (Related record:' +  l_records.get(index).id + ')');
                            }
                        }
                    }
                }
            }
            else if(action == DML_ACTION.UPSERT_ACTION){
               
                Schema.SobjectType sObjectType = Schema.getGlobalDescribe().get(sObjectAPIName);

                Schema.SObjectField field  = SobjectType.getDescribe().fields.getMap().get(externalIdField);
       
                //String listType = 'List<' + sObjectType + '>';
                //List<SObject> records= (List<SObject>)Type.forName(listType).newInstance();
               // records.addAll(l_records);
               
               
                databaseResult.upsertResults = Database.upsert(l_records, field);
                
                if (databaseResult.upsertResults != null){
                    for(Integer index = 0; index < databaseResult.upsertResults.size(); index ++){
                        if(! databaseResult.upsertResults.get(index).isSuccess()){
                            for(Database.Error err : databaseResult.upsertResults.get(index).getErrors()){
                                databaseResult.l_errorMsg.add(err.getStatusCode() + ' - ' + err.getMessage() + 
                                    ' (Related record:' +  l_records.get(index).id + ')');
                            }
                        }
                    }
                }
            }
            else{
        
                if(action == DML_ACTION.INSERT_ACTION){
                    DatabaseResult.saveResults = Database.insert(l_records, allOrNone);
                }
                else if(action == DML_ACTION.UPDATE_ACTION){
                    DatabaseResult.saveResults = Database.update(l_records, allOrNone);
                }
                
                if (DatabaseResult.saveResults != null){
                    for(Integer index = 0; index < DatabaseResult.saveResults.size(); index ++){
                        if(! DatabaseResult.saveResults.get(index).isSuccess()){
                            for(Database.Error err : DatabaseResult.saveResults.get(index).getErrors()){
                                databaseResult.l_errorMsg.add(err.getStatusCode() + ' - ' + err.getMessage() +
                                    ' (Related record:' +  l_records.get(index).id + ')');
                            }
                        }
                    }
                }
            }

        }
        catch(Exception ex){
            system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            
            databaseResult.l_errorMsg.add('EXCEPTION : ' + ex.getMessage() +  ':'  +  ex.getStackTraceString());
            
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
        
        return databaseResult ;
    }
    
    
    
    
    /*
    *   ViewMessage for return result
    *   Using type : Audit
    */
    public class DatabaseResult {
        
        public Database.SaveResult[]      saveResults   {get;set;}
        public Database.DeleteResult[]    deleteResults   {get;set;}
        public Database.UpsertResult[]   upsertResults    {get; set;}
        public list<String> l_errorMsg {get; set;}
        
        public DatabaseResult() {
            
            saveResults = new Database.SaveResult[]{};
            deleteResults = new Database.DeleteResult[]{};
            upsertResults = new Database.UpsertResult[]{};
            
            l_errorMsg = new list<String>();
        }
    
        public boolean isSuccess(){
            return l_errorMsg.isEmpty();
        }
        
        public String getAllErrorMessages(String delimeter){
            String fullErrorMessage = '';
            
            for(String error : l_errorMsg)
                fullErrorMessage += error + delimeter;
                
            return fullErrorMessage;
        }
    }
}