/* 
 * Purpose      : This is helper class for Vlocity tools
 * Created On   : 15/03/2017
 * Author : Yuval Vardi
 */

global with sharing class OSUtils implements vlocity_cmt.VlocityOpenInterface2
{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) 
    {
        Boolean result = true;

        //System.debug(methodName);
        //System.debug(JSON.serialize(inputMap));
        //System.debug(outMap);
        //System.debug(options);

        try
        {
            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('contextObjectType')) {
                 findObjectType(inputMap, outMap);
            }
            else if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getAccountsByRecordType')) {
                 getAccountsByRecordType(inputMap, outMap, options);
            }
            else if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getRTByObjectAndDevName')) {
                 getRTByObjectAndDevName(inputMap, outMap);
            }
            
        } 
        catch(Exception e)
        {
            result = false;
        }
        return result;
    }

   public static void getRTByObjectAndDevName(Map<String,Object> inputMap, Map<String,Object> outMap) {
        
        String objectType;
        String recordTypeDevName;
        Id recordTypeId;
        
        if(inputMap.containsKey('objectType')) {
            objectType = String.valueOf(inputMap.get('objectType'));
        }
        
        if(inputMap.containsKey('recordTypeDevName')) {
            recordTypeDevName = String.valueOf(inputMap.get('recordTypeDevName'));
        }
           
        try {
	        recordTypeId = RecordTypeService.getRecordTypeIdByName(objectType,recordTypeDevName);
	        outMap.put('objectRecordTypeId', recordTypeId); 
        }
        catch (Exception ex) {
       	    outMap.put('Exception', ex.getMessage());           
        }
   }
   
   public static void findObjectType(Map<String,Object> inputMap, Map<String,Object> outMap) {
        Id contextId;
        String objectType;
        outMap.put('objectType', 'None');
        if(inputMap.containsKey('ContextId')) {
            contextId = Id.valueOf(String.valueOf(inputMap.get('ContextId')));
           
            if(String.isNotBlank(contextId)) {
            objectType = contextId.getSObjectType().getDescribe().getName();
            outMap.put('objectType', objectType);
            }
            
         
        }
        else 
        outMap.put('objectType', 'Unknown');
                    
           
   }
   
   /**
    * Mohammed G.
    * taskid 
    * @method getAccountsByRecordType
    * @param {Map<String,Object>} inputMap
    * @param {Map<String,Object>} outMap
    * @param {Map<String,Object>} options
    * @return {void} accounts added to the outMap.
    */
   public static void getAccountsByRecordType(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        String recordTypeDevName;
        String chosenFamilyName;
        Map<String,Object> competitorInfoStep = new Map<String,Object>();
        String queryStr;
        
        list<map<String,String>> accountsResultsList = new list<map<String,String>>();
         
        if(!inputMap.containsKey('recordType')){
            accountsResultsList.add(new map<String,String>{'name'=>'missingRT'});
            accountsResultsList.add(new map<String,String>{'value'=>'missing record type'});
            return;
        }
        
        recordTypeDevName = String.valueOf(inputMap.get('recordType'));
        Id accountRecordTypeId = RecordTypeService.getSelectiveRecordTypeIdByName('Account',recordTypeDevName);
        competitorInfoStep = (Map<String,Object>)inputMap.get('stpCompetitorInfo');
       
        chosenFamilyName = String.valueOf(competitorInfoStep.get('finalFamily'));
        
       if(accountRecordTypeId != null)
       queryStr = 'select id, RelatedProductFamily__c, Name from Account where RecordTypeId = \''+ accountRecordTypeId + '\'';
       
        try {   
            for(Account acc : Database.query(queryStr)){
	            if (acc.RelatedProductFamily__c != null && acc.RelatedProductFamily__c.contains(chosenFamilyName)) {
    	            accountsResultsList.add(new map<String,String>{'name'=>acc.Id,'value'=>acc.Name});
	            }
	        }
        }
        catch(Exception e) {
            //TODO: write to log
            System.debug(Logginglevel.ERROR, '>>>> getAccountsByRecordType Exception: ' + e + ' from: ' + e.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(e));
        }
        
        if(accountsResultsList.isEmpty()){
        	accountsResultsList.add(new map<String,String>{'name'=>'missing'});
            accountsResultsList.add(new map<String,String>{'value'=>System.Label.NoRecordsFound});
        }
        
	    outMap.put('options', accountsResultsList);
	    system.debug('>>> outMap: ' + outMap);
   }
   
   
   
}