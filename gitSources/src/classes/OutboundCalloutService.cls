/**
*   Main OUTBOUND WebService callout
*   
*   @class OutboundCalloutService
*   author Liron Cohen
*   @module WebService
*   @constructor
*
*   Usage example:
*
*       map<String, String> headerMap = new map<String, String>();
*       headerMap.put('Content-Type', 'application/json;charset=UTF-8');
*       headerMap.put('Accept', 'application/json');
*
*       map<String, object> paramsMap = new map<String, object>();
*       paramsMap.put('timeout', 100000);
*
*       String endPointPrefix = 'OSB';
*       String serviceName = 'requestedService';
*       String methodName = 'POST';
*       String body = 'post body...';
*
*       OutboundCalloutService.RestResponse res = outboundCalloutService.sendRestRequest(paramsMap, headerMap, endPointPrefix, serviceName, methodName, body);
*/
public with sharing class OutboundCalloutService {
    
    private static httpRequest request;
    public static NamedCredential namedCredintialFound;
    public static void setNamedCredintialFound(String endPointPrefix){
        getEndPoint('', endPointPrefix);
    }
    
    /**
    *   method for outbound callouts
    *   author Liron Cohen
    *   taskId PLR-639
    *
    *   @method sendRestRequest
    *   @param  {map<String, object>}   paramMap        default time out is: 120000
    *   @param  {map<String, String>}   headerMap
    *   @param  {String}                endPointPrefix
    *   @param  {String}                serviceName
    *   @param  {String}                methodName      default will be set to 'POST'
    *   @param  {String}                body            mandatory only for 'POST')
    *   @return {RestResponse} Method return RestResponse object
    *
    */
    public static RestResponse sendRestRequest(
        map<String,object> paramsMap, 
        map<String,String> headerMap,
        String endPointPrefix,
        String serviceName, 
        String methodName, 
        String body) {
        
        return sendRestRequest(paramsMap, headerMap, endPointPrefix, serviceName, methodName, body, true);
    }
    
    
    /**
    *   method for outbound callouts additional signature for making the callout without insert to log immediate
    *   author Liron Cohen
    *   taskId PLR-639
    *
    *   @method sendRestRequest
    *   @param  {map<String, object>}   paramMap        default time out is: 120000
    *   @param  {map<String, String>}   headerMap
    *   @param  {String}                endPointPrefix
    *   @param  {String}                serviceName
    *   @param  {String}                methodName      default will be set to 'POST'
    *   @param  {String}                body            mandatory only for 'POST')
    *   @param  {Boolean}               insertLogImmediate
    *   @return {RestResponse} Method return RestResponse object
    *
    */
    public static RestResponse sendRestRequest(
        map<String,object> paramsMap, 
        map<String,String> headerMap,
        String endPointPrefix,
        String serviceName, 
        String methodName, 
        String body,
        Boolean insertLogImmediate) {
        
        double timeElapse;
        Datetime startDate, endDate;
        
        if (String.isEmpty(methodName) || (String.isEmpty(serviceName))){
            throw new applicationException(null, Label.errMsgOutboundMissingParams, applicationException.ExceptionType.OUTBOUND, false);
        }
        
        if ((methodName == 'POST' || String.isEmpty(methodName)) && String.isEmpty(body) && !paramsMap.containsKey('bodyBlob') ){
            throw new applicationException(null, Label.errMsgOutboundMissingBody, applicationException.ExceptionType.OUTBOUND, false);
        }
        
        RestResponse restRes = null;
        
        request = new httpRequest();
        setRequestParams(paramsMap, endPointPrefix, serviceName, body, methodName);
        setRequestHeader(headerMap);
        try {
            Http http = new Http();
            startDate = system.now(); 
            HTTPResponse httpRes = http.send(request);
            endDate = system.now();
            timeElapse = ((double)endDate.getTime() - startDate.getTime())/ 1000;
            restRes = new RestResponse(httpRes);
            system.debug('###header Key: ' + httpres.getHeaderKeys());
            system.debug('###body: ' + httpres.getBody());
        } catch(Exception ex) {
        	endDate = system.now();
        	timeElapse = ((double)endDate.getTime() - startDate.getTime())/ 1000;
        	
            //new applicationException(ex, '', applicationException.ExceptionType.OUTBOUND);
            if(restRes != null){
                restRes.statusCode = 90;
                restRes.status = ex.getMessage() + ' : ' + ex.getStackTraceString();
            }
        }
        
        
        
        //Write the request & response to log  
        LoggerService.writeOutboundMessage(
                new LoggerService.IntegrationMessage(serviceName, request, restRes), 
                insertLogImmediate,
                new map<String, object>{
                        'Elapsed_Time__c' => timeElapse, 
                        'Function_Code__c' => paramsMap!=null && paramsMap.containsKey('FunctionCode') ? paramsMap.get('FunctionCode') : ''});
        
        
        return restRes;
    }
    
    
    /**
    *   set request params
    *   author Liron Cohen
    *   taskId PLR-639
    *
    *   @method setRequestParams
    *   @param  {map<String, object>}   paramMap
    *   @param  {String}                endPointPrefix
    *   @param  {String}                serviceName
    *   @param  {String}                methodName
    *   @param  {String}                body
    */
    private static void setRequestParams(
        map<String,object> paramsMap, 
        String endPointPrefix,
        String serviceName, 
        String body, 
        String methodName){
            
        //set end point
        request.setEndpoint(getEndPoint(serviceName, endPointPrefix));
        
        //request.setBody((String)paramsMap.get('body'));
        //setBodyAsBlob(Blob);
        //setBodyDocument(Dom.Document);
        request.setTimeout(paramsMap != null && paramsMap.containsKey('timeout') 
            ? (Integer)paramsMap.get('timeout') 
            : 120000);//max is 120000 = 2 minutes

        //request.setMethod(paramsMap.containsKey('method') 
        //  ? (String)paramsMap.get('method') 
        //  : 'POST');
        
        setRequestBody(paramsMap, body);
        
        request.setMethod(methodName);

        //options: DELETE, GET, HEAD, POST, PUT, TRACE
        if (paramsMap != null && paramsMap.containsKey('certificate')) {
            request.setClientCertificateName((String)paramsMap.get('certificate'));
        }

        if (paramsMap != null && paramsMap.containsKey('compressed')) {
            request.setClientCertificateName((String)paramsMap.get('compressed'));
        }
    }
    /**
    *   set request body
    *   author Liron Cohen
    *
    *   @method setRequestBody
    *   @param {map<String, String>} paramsMap
    *   @param {String} body
    */
    
    private static void setRequestBody(map<String,object> paramsMap, String body){
         if(body != null){
            request.setBody(body);
         }
         else if(paramsMap.containsKey('bodyBlob')){
            Blob bodyBlob = (Blob) paramsMap.get('bodyBlob');
            request.setBodyAsBlob(bodyBlob);
         }
    }
    /**
    *   set request header
    *   author Liron Cohen
    *   taskId PLR-639
    *
    *   @method setRequestParams
    *   @param  {map<String, String>}   headerMap
    */
    private static void setRequestHeader(map<String,String> headerMap){
        //set defaults
        if (headerMap == null || !headerMap.containsKey('Accept')) {
            request.setHeader('Accept','application/json');
        }

        if (headerMap == null || !headerMap.containsKey('Content-Type')) { 
            request.setHeader('Content-Type','application/json');
        }
        
        //set values from headerMap
        if (headerMap != null){
            for(String h : headerMap.keySet()) {
                request.setHeader(h, headerMap.get(h));
            }
        }
    }
    
    /**
    *   get end point
    *   author Liron Cohen
    *   taskId PLR-639
    *
    *   @method getEndPoint
    *   @param  {String}    serviceName
    *   @param  {String}    endPointPrefix
    */
    public static String getEndPoint(String serviceName, String endPointPrefix){
        String environmentType =  EnvironmentSettings__c.getInstance().CurrentEnvironment__c;
        
        if(String.isEmpty(environmentType)){
            throw new applicationException(null, Label.errMsgOutboundMissingEnvironment, applicationException.ExceptionType.OUTBOUND);
        }
        
        //validation if it's sandbox, it shouldn't use producstion end point, and vice verca
        if(isSandBox() || Test.isRunningTest()){    //checking if running test, so we won't get different coverage in production
            if(environmentType.toLowerCase() == 'prod'){
                throw new applicationException(null, Label.errMsgOutboundWrongEnvironment   , applicationException.ExceptionType.OUTBOUND);
            }
        }
        else{
            if(environmentType.toLowerCase() != 'prod'){
                throw new applicationException(null, Label.errMsgOutboundWrongEnvironment   , applicationException.ExceptionType.OUTBOUND);
            }
        }
        
        String namedCredintial = endPointPrefix + '_' + environmentType;
        
        list<NamedCredential> namedCredntialList = [SELECT Id, DeveloperName, Endpoint FROM NamedCredential where DeveloperName = :namedCredintial];
            
        if(namedCredntialList.isEmpty()){
            if(Test.isRunningTest())
                namedCredintial = 'test';
            else
                throw new applicationException(null, Label.errMsgOutboundMissingCredintial, applicationException.ExceptionType.OUTBOUND);
        }
        else{
            namedCredintial = namedCredntialList.get(0).DeveloperName;
            namedCredintialFound = namedCredntialList[0];
        }
        
        //callout:My_Named_Credential/some_path
        return 'callout:' + namedCredintial + '/' + serviceName;
    }
    
    
    //ToDo: Should move this function to util class
    private static boolean isSandbox(){
        //Can this be done without query ?? possible UserInfo.getOrganizationId() == 'productionId'
        return [SELECT IsSandbox FROM Organization limit 1].IsSandbox;
    }
    
    public class RestResponse{
        public String status;
        public Integer statusCode;
        public String body;
        
        public RestResponse(HttpResponse response){
            status = response.getStatus();
            statusCode = response.getStatusCode();
            body = response.getBody();
        }
    }
}