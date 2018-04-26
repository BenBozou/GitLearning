public class Batch_DeleteLog implements Database.batchable<sobject>, Database.stateful{ 
	
    private Integer hours;
    
    public Batch_DeleteLog(Integer hours){
        this.hours = hours;
    }
    
    public Database.QueryLocator start(Database.BatchableContext info){ 
       Datetime creationDate = Datetime.now().addHours(hours);
       return Database.getQueryLocator([select Id from Log__c where createddate <: creationDate]);
   }     
    
   public void execute(Database.BatchableContext info, List<sobject> scope){
       delete scope;
   }
    
   public void finish(Database.BatchableContext info){     
   } 
}