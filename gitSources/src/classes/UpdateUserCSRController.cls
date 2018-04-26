/**
*   Controller for update user CSR data
*   
*   @class UpdateUserCSRController
*   author Liron Cohen
*   @module 360
*/
public class UpdateUserCSRController{

    //inputs for the page
    public String userIdByName {get; set;}
    
    public User selectedUser {get; set;}

    public UpdateUserCSRController(){

        
    }

       
    public PageReference findUser(){
        try{
            //If name was entered search by name, else by federation Id
            String userId = userIdByName;

            if(! String.isEmpty(userId)){
                
                selectedUser = [select id, name, FederationIdentifier, Spoken_Languages__c, Area__c, Location__c 
                                from User where Id= :userId];
            }
            else{
                selectedUser = null;
            }
            
        }
        catch(QueryException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.UpdateCSRErrorMsg + ' ' + userIdByName));
        }
        
        return null;
    }
    
      
    public PageReference updateUser(){
    
        DatabaseManager.DatabaseResult dbResult = 
            DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION, new list<User>{selectedUser});
        
        if(dbResult.isSuccess()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.UpdateCSRSuccMsg));
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dbResult.getAllErrorMessages('\n')));
        }
        
        return null;
    }
    
}