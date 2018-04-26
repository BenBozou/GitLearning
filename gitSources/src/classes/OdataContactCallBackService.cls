global with sharing class OdataContactCallBackService extends DataSource.AsyncSaveCallback {
    
    public static System.Savepoint entryPoint;
    
     override global void processSave (Database.SaveResult sr){
     	
     	if (sr.isSuccess ()){ 			
    		System.debug(LoggingLevel.ERROR,'>>>> callback  External sr: ' + sr);
 			System.debug(LoggingLevel.ERROR,'>>>> callback  External SequenceID: ' + sr.getId());
 			
 			try{
 				
	 			ContactKeys__x contactKeaysX = [SELECT Id, transactionId__c, cellcom_id__c
	 											FROM ContactKeys__x
	 											WHERE Id = : sr.getId()];
	 											
	 			Contact contact = [SELECT Id, CellcomExternalID__c
	 								FROM Contact
	 								WHERE Id = : contactKeaysX.transactionId__c];
	 			
	 			contact.CellcomExternalID__c = contactKeaysX.cellcom_id__c;
	 			
	 			update contact;
	 			
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