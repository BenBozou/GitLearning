global with sharing class OdataAccountCallBackService extends DataSource.AsyncSaveCallback{
    
    public static System.Savepoint entryPoint;
    
    override global void processSave (Database.SaveResult sr){
    	
    	if (sr.isSuccess ()){ 			
    		System.debug(LoggingLevel.ERROR,'>>>> callback  External sr: ' + sr);
 			System.debug(LoggingLevel.ERROR,'>>>> callback  External SequenceID: ' + sr.getId());
 			
 			try{
 				
	 			AccountKeys__x accountKeaysX = [SELECT Id, transactionId__c, cellcom_id__c
	 											FROM AccountKeys__x
	 											WHERE Id = : sr.getId()];
	 											
	 			Account account = [SELECT Id, CellcomExternalID__c
	 								FROM Account
	 								WHERE Id = : accountKeaysX.transactionId__c];
	 			
	 			account.CellcomExternalID__c = accountKeaysX.cellcom_id__c;
	 			
	 			update account;
	 			
 			}catch (Exception ex){
            	system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            	LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
            	if(entryPoint != null){
            		Database.rollback(entryPoint);
            	}
        	}
    	}else{
    		System.debug(LoggingLevel.ERROR,'>>>> callback Failed: ' + sr);
    		if(entryPoint != null){
            		Database.rollback(entryPoint);
            }
    	}
    }
}