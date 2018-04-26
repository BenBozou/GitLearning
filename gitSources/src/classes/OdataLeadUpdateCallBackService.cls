global with sharing class OdataLeadUpdateCallBackService extends DataSource.AsyncSaveCallback{

    override global void processSave (Database.SaveResult sr){
    	if (sr.isSuccess ()){ 			
    		System.debug(LoggingLevel.ERROR,'>>>> callback  External sr: ' + sr);
 		}
 		else{
            System.debug(LoggingLevel.ERROR,'>>>> callback  External sr: ' + sr);
 		}
    }
}