/**
*   Logger Service
*   
*   @class LoggerService
*   author Liron Cohen
*   @module infrastructure
*
*   Description: Should be use for logging all activities/errors
*
*   Usage depend on type. Examples: 
*
*       //Audit message
*       LoggerService.writeViewMessage(
*           new LoggerService.ViewMessage('View', AccountId, externalRecordId));
*
*       //Integration Message (Inbound)
*       LoggerService.writeIntegrationMessage(
*            new LoggerService.IntegrationMessage(restRequest, new inboundWebservice.InboundRestResponse));
*
*       //Integration Message (Outbound)
*       LoggerService.writeIntegrationMessage(
*            new LoggerService.IntegrationMessage('service name', httpRequest, OutboundCalloutService.RestResponse));
*            
*       //Error Message
*       LoggerService.writeErrorMessage(
*            new LoggerService.ErrorMessage(exception));
*/
public with sharing class LoggerService {
    
    //List for holding Log__c records. Will use by processes to add several log records
    //and insert them in one DML  
    private static list<Log__c> uncomiitedLogList = new list<Log__c>(); 
    
    public enum ViewMessageType { View }
    
    /**
    *   method for commit all log records 
    *   author Liron Cohen
    *   taskId PLR-436
    *
    *   @method commitAllLogs
    *   @return {Integer}        Number of log records that were insert
    */
    public static Integer commitAllLogs(){
    	DatabaseManager.DatabaseResult dbResult = 
    		DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION,uncomiitedLogList,false);
    		
    	uncomiitedLogList.clear();
    	
    	return dbResult.saveResults.size();
    }
    
    /**
    *   method for logging view activities
    *   author Liron Cohen
    *   taskId PLR-436
    *
    *   @method writeViewMessage
    *   @param  {String}        recordID
    *   @param  {ViewMessage}   message
    *   @return {Log__c}        Log record
    */
    public static Log__c writeViewMessage(String recordId, ViewMessage message){
    	
    	Log__c logRecord = null; 
    	
        try{
            logRecord = insertLogRecord('Audit', 'INFO', recordId, message, true);
        }
        catch(Exception ex){
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
        
        return logRecord;
    }
    
    /**
    *   method for logging excpetions
    *   author Liron Cohen
    *   taskId PLR-436
    *
    *   @method writeErrorMessage
    *   @param  {String}        level
    *   @param  {ErrorMessage}  message
    *   @return {Log__c}        Log record
    */
    public static Log__c writeErrorMessage(ErrorMessage message){
        
        return insertLogRecord('Cibb', 'ERROR', '', message, true);
    }
    
    /**
    *   method for logging integration message
    *   author Liron Cohen
    *   taskId PLR-436
    *
    *   @method writeInboundMessage
    *   @param  {String}        level
    *   @param  {ErrorMessage}  message
    *   @return {Log__c}        Log record
    */
    public static Log__c writeInboundMessage(IntegrationMessage message){
       	
       	Log__c logRecord = null;
       
        try{
            logRecord = insertLogRecord('Cibb', 'INBOUND', 'DEBUG', '', message, true, null);
        }
        catch(Exception ex){
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
        return logRecord;        
    }
    
    /**
    *   method for logging integration message
    *   author Liron Cohen
    *   taskId PLR-436
    *
    *   @method writeOutboundMessage
    *   @param  {ErrorMessage}  message
    *   @return {Log__c}        Log record
    */
    public static Log__c writeOutboundMessage(IntegrationMessage message){
       
       	Log__c logRecord = null;
       	
        try{
            logRecord = insertLogRecord('Cibb', 'OUTBOUND', 'DEBUG', '', message, true, null);
        }
        catch(Exception ex){
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
        return logRecord;        
    }
    
    /**
    *   method for logging integration message
    *   author Liron Cohen
    *   taskId PLR-436
    *
    *   @method writeOutboundMessage
    *   @param  {ErrorMessage}  message
    *	@param	{Boolean}		insertImmediate
    *   @return {Log__c}        Log record
    */
    public static Log__c writeOutboundMessage(
    	IntegrationMessage message, 
    	Boolean insertImmediate,
    	map<String, object> m_additionalFields){
       
       	Log__c logRecord = null;
       	
        try{
            logRecord = insertLogRecord('Cibb', 'OUTBOUND', 'DEBUG', '', message, insertImmediate, m_additionalFields);
        }
        catch(Exception ex){
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
        return logRecord;        
    }
    
    /**
    *   method for writing to log
    *   author Liron Cohen
    *   taskId PLR-436
    *
    *   @method insertLogRecord 
    *   @param  {String}    logType
    *   @param  {String}    level
    *   @param  {String}    recordID
    *   @param  {Message}   message
    *	@param	{Boolean}	insertImmediate
    *   @return {Log__c}        Log record
    */
    private static Log__c insertLogRecord(
        String logType,
        String level,
        String recordId,
        Message message,
        Boolean insertImmediate){
            
        return insertLogRecord(
            logType, '', level, recordId, message, insertImmediate, null);
    }
    
    /**
    *   method for writing to log
    *   author Liron Cohen
    *   taskId PLR-436
    *
    *   @method insertLogRecord 
    *   @param  {String}    logType
    *   @param  {String}    logSubType
    *   @param  {String}    level
    *   @param  {String}    recordID
    *   @param  {Message}   message
    *	@param	{Boolean}	insertImmediate
    *   @return {Log__c}        Log record
    */
    private static Log__c insertLogRecord(
        String logType,
        String logSubType,
        String level,
        String recordId,
        Message message,
        Boolean insertImmediate,
        map<String, object> m_addtionalFields){
            
        if(message != null){
            system.debug('###' + String.valueof(JSON.serialize(message)));
        }
        
        String logMessage = String.valueof(JSON.serialize(message));
        
        if(! String.isEmpty(logMessage) && logMessage.length() > 131072)
            logMessage = logMessage.subString(0, 131072);
        
        Log__c logRecord = new Log__c(
                Type__c = logType,
                Sub_Type__c = logSubType,
                Level__c = level,
                User__c = UserInfo.getUserId(), 
                Record_Id__c = recordId,
                Message__c = logMessage);
        
        if(m_addtionalFields != null){
        	if(m_addtionalFields.containsKey('Elapsed_Time__c'))
        		logRecord.Elapsed_Time__c = double.valueOf(m_addtionalFields.get('Elapsed_Time__c'));
        	if(m_addtionalFields.containsKey('Function_Code__c'))
        		logRecord.Function_Code__c = String.valueOf(m_addtionalFields.get('Function_Code__c'));
        }
        
        //only if environment setup contain the log level should write it
        if (EnvironmentSettings__c.getInstance().Log_Levels__c != null
            && EnvironmentSettings__c.getInstance().Log_Levels__c.contains(Level)){
        
        	//Insert immediate the record or save it to static list
        	if(insertImmediate){
            	DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION, new list<Log__c>{logRecord}, false);
        	}
        	else{
        		uncomiitedLogList.add(logRecord);
        	}
        }
        
        return logRecord;
    }
    
    
    /*
    *   ViewMessage for audit
    *   Using type : Audit
    */
    public class ViewMessage extends Message{
        
        private ViewMessageType actionType;
        private String objectName;
        private String recordExternalId;
        private String salesforceRecordId;
        
        /*
        *   Constructor ViewMessage
        *   @param {ViewMessageType}        messageType object
        *   @param {Id}                     Salesforce record Id
        *   @param {recordExternalId}       external Id for cellcom system
        */
        public ViewMessage(ViewMessageType messageType, Id recordId, String recordExternalId){
            this.actionType = messageType;
            this.objectName = recordId != null ? (String) recordId.getsobjecttype().getDescribe().getName() : '';
            this.recordExternalId = recordExternalId;
            this.salesforceRecordId = recordId;
        }
        
    }
    
    
    
    /*
    *   ErrorMessage for Exceptions. 
    *   Using type : Cibb 
    */
    public class ErrorMessage extends Message{
        
        private String errorMessage;
        private String stackTrace;
        private String exceptionType;
        private Integer lineNumber;
        
         /*
        *   Constructor IntegrationMessage for Outbound. 
        *   @param {Exception}                              exception
        *   @param {httpRequest}                            request
        *   @param {OutboundCalloutService.RestResponse}    response   
        */
        public ErrorMessage(Exception ex){
            errorMessage = ex.getMessage();
            stackTrace = ex.getStackTraceString();
            exceptionType = ex.getTypeName();
            lineNumber = ex.getLineNumber();
        }
        
    }
    
    /*
    *   IntegrationMessage for Inbound/Outbound. 
    *   Using type : Cibb 
    */
    public class IntegrationMessage extends Message{
        private String serviceName;
        private String request;
        private String response;
        private Integer statusCode;
        
        /*
        *   Constructor IntegrationMessage for Outbound. 
        *   @param {String}                                 serviceName
        *   @param {httpRequest}                            request
        *   @param {OutboundCalloutService.RestResponse}    response   
        */
        public IntegrationMessage(
            String serviceName, httpRequest request, OutboundCalloutService.RestResponse response){
                
            this.serviceName = serviceName;
            this.request = request.getBody();
            if(response != null){
                this.response = response.body;
                this.statusCode = response.statusCode;
            }
        }
        
        
        /*
        *   Constructor IntegrationMessage for Inbound. 
        *   @param {RestRequest}                            request
        *   @param {inboundWebservice.InboundRestResponse}  response   
        */
        public IntegrationMessage(
            RestRequest request, inboundWebservice.InboundRestResponse response){
                
            this.serviceName = response.serviceName;
            this.request = request.requestBody != null ? request.requestBody.toString() : '';
            if(response != null){
                this.response = String.valueOf(response.response);
                this.statusCode = response.statusCode;
            }
        }
    }
    
    
    public virtual class Message{
        private String timestamp;
        private String userName;
        
        public Message(){
            timestamp = String.valueofGmt(system.now());
            userName = userInfo.getUserName();
        }
    } 
}