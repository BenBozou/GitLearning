/**
* Service class for handle Update Reccommendations in POLM: 
* Eric Fishman
* taskid PLR-920
* @class GetPOLMRecommendsService
* @module Lead 
*/
global with sharing class GetPOLMRecommendsService implements vlocity_cmt.VlocityOpenInterface2  {
    
    //public List<Lead> leadList = new List<Lead>();      
    

/**
    * Method implemented from interface, that will be called from vlocity card, 
    * and will call inner method according to method name.
    * Eric Fishman
    * taskid PLR-920
    * @method invokeMethod
    * @param {String} methodName
    * @param {Map} inputMap
    * @param {Map} outMap
    * @param {Map} options
    * @return {Boolean} success/failure
    */    
     global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
         System.debug(Logginglevel.INFO, 'GetPOLMRecommendsService.invokeMethod - methodName: ' + methodName);
        System.debug(Logginglevel.INFO, 'GetPOLMRecommendsService.invokeMethod - inputMap: ' + inputMap);
        
        outMap.put('processError', 'false');
        
         try {
//           return GetReccommendations(inputMap, outMap, options);
            if (String.isNotBlank(methodName)  && methodName =='GetPOLMRecommends' ) {
                return GetReccommendations(inputMap, outMap, options);
            }
            /*
            else if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('GetPOLMOutRecommends')) {
                return getOutReccommendations(inputMap, outMap, options);
            }
            */
            
                             
                
        } 
        catch (Exception e) {
            system.debug(Logginglevel.ERROR, 'invokeMethod ' + methodName + ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());             
            return returnError(outMap, 'processErrorMsg', e.getMessage() + ':' + e.getStackTraceString());
        }

        return true;
     }
    
    
    /**
    * Get Reccommendations 
    * Eric Fishman
    * @method updateReccommends 
    * @param {List} objectName
    * @param {String} recordTypeName
    * @return {}
    * @static
    */
    
     public Boolean GetReccommendations(Map<String,Object> inputMap,Map < String, Object > outMap, Map < String, Object > options) {        
        try{
            
            // check input params
            String agent = inputMap.containskey('agent') ? (String)inputMap.get('agent') : '';
            
            if (String.isEmpty(agent) )
            	return returnError(outMap,'processErrorMsg', Label.MissingParameterError);
            
            
            // build Body JSON
            polmRecommnendationsBuilder request = new polmRecommnendationsBuilder();
                                    
            OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00684');
            
                  
            
            system.debug('#### ctrlRequest: ' + ctrlRequest);            
            // Append Body tp Request JSON           
            String requestJSON = ctrlRequest.serialize();
            ctrlRequest.body.setRequestNode(request);
            system.debug('#### ctrlRequest after : ' + ctrlRequest);          
            system.debug(Logginglevel.INFO,'REQUEST: ' + requestJSON);
                    
            //OutboundCalloutService.RestResponse res = ctrlRequest.sendRequest('OSB', 'api/services/rest/00684_osb_getrecommends_dwh');
            Map<String,Object> response = ctrlRequest.sendRequestWithErrorCheck('OSB', 'api/services/rest/00684_osb_getrecommends_dwh');                                  
            if (response == null) {
                return returnError(outMap, 'processErrorMsg', 'Response issue');
            
        }
        outMap.put('data',response);     
            
        }
        catch (Exception e) {
            System.debug(Logginglevel.ERROR, '>>>> 30 Get Reccommends Exception: ' + e + ' from: ' + e.getStackTraceString());
            return false;
        }  
        
        return true;
        
     }
     
    /**
    * Class helper for creating and populating Json Header request for UpdatePOLM Recommendations callouts
    * Eric Fishman
    * taskid PLR-877
    * @class polmRecommnendationsBuilder
    * @constructor
    * @param {String} funcCode
    * @module Lead
    */     
     public class polmRecommnendationsBuilder extends OSBCalloutBuilder.RequestBuilder { 
        public Recommendations  Recommendations; 
        
        public polmRecommnendationsBuilder(){
            Recommendations = new Recommendations();    
        }
     }
     
     
     public class Recommendations {
        public String agent;
        public String direction;
        public RecommendInbound inbound = new RecommendInbound('56665', '3','PRODUCT1');
        
        public Recommendations(){
            this.agent = '1';
            this.direction = 'INBOUND';
        }
        
     }
     
     public class RecommendInbound{
        public String consumer_account; 
        public String treat_count;
        public String product; 
        
        public RecommendInbound (String inConsumerAccount, String inTreatCount, String inProduct ){
            this.consumer_account = inConsumerAccount;
            this.treat_count = inTreatCount;
            this.product = inProduct;            
        }
        
     }
     
     
     private static boolean returnError(Map < String, Object > outMap, String key, object msg) {
        outMap.put(key, msg);
        outMap.put('processError', 'true');
        return false;
    }
        
       
    
}