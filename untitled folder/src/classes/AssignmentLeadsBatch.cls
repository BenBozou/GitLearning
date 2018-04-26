/**
* Batch to reassign PotentialLeads 
* Author Eric Fishman
* @class AssignmentLeadsBatch
*/

global class AssignmentLeadsBatch implements DataBase.Batchable<sObject>{
    public BatchManager__c bm = new BatchManager__c ();
    
    public AssignmentLeadsBatch(BatchManager__c bmETL) { 
        bm = bmETL;
    }
    
    /**
    * Method prepare data for batch
    * @method start
    * @param  {Database.BatchableContext} BC
    * @return {Database.QueryLocator}*     
    */
   public Database.QueryLocator start(Database.BatchableContext BC) {
   		datetime myDateTime = datetime.now().addHours(-12);
   		system.debug('### DateTime>>>'+myDateTime);
   		
   		String query = 'SELECT Id ';	
		query += 'FROM Lead ';
		query += 'WHERE CreatedById = \'' + bm.CreatedById  + '\'';
		query += 'and OwnerId =  \'' + bm.CreatedById + '\'';
		query += 'and CreatedDate >=:myDateTime ' ;

        system.debug('### query>>>'+query);
        
		return Database.getQueryLocator(query);
   }
   
    /**
    * Method execute 
    * @method execute
    * @param  {Database.BatchableContext info} info
    * @param  {List<Lead>} scope
    * @return {void}*     
    */     
   public void execute(Database.BatchableContext info, List<Lead> leadList) {
   			system.debug('### leadList>>>'+leadList);
   		if (!leadList.isEmpty()){
       		Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            
            for (Lead lead : leadList) {
                lead.setOptions(dmo);
            }

       		DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,leadList,false);
   		}
   		
   } 
   
    /**
    * Method execute 
    * @method finish
    * @param  {Database.BatchableContext info} info
    * @return {void}*     
    */      
   public void finish(Database.BatchableContext info) {    
   	 
   }
   
}