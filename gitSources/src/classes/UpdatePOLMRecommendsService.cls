public with sharing class UpdatePOLMRecommendsService implements Queueable, Database.AllowsCallouts{ 
/**
* Service class for handle Update Reccommendations in POLM: 
* Eric Fishman
* taskid PLR-872
* @class UpdatePOLMRecommendsService
* @module Lead 
*/
       
    public List<Lead> leadList = new List<Lead>();      
           
    public UpdatePOLMRecommendsService(List<Lead> leadList){
        this.leadList = leadList;
    }
       
       /**
    * Execute method
    * Eric Fishman
    * @method execute   
    * @return {void}*     
    * @module Lead 
    */
    public void execute(QueueableContext context){
        updateReccommends();
    }
    
    
    /**
    * updateReccommends 
    * Eric Fishman
    * @method updateReccommends 
    * @param {List} objectName
    * @param {String} recordTypeName
    * @return {}
    * @static
    */
    
     public void updateReccommends() {
        
        try{
            // build Body JSON
            polmRecommendUpdateBuilder request = new polmRecommendUpdateBuilder(leadList[0]);
                                    
            OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00690');
            ctrlRequest.body.setRequestNode(request);           
            
            system.debug('#### REQUEST: ' + request.status);
           
            
            
            // Append Body tp Request JSON
            ctrlRequest.body.setRequestNode(request);           
            String requestJSON = ctrlRequest.serialize();          
            system.debug(Logginglevel.INFO,'REQUEST: ' + requestJSON);
                    
            OutboundCalloutService.RestResponse res = ctrlRequest.sendRequest('OSB', 'api/services/rest/00690_osb_updaterecommends_dwh');                     
            if(res == null || res.statusCode == 90){
                system.debug(Logginglevel.INFO,'Invoke OSB faled: ' + res);
            }
            
        }
        catch (Exception e) {
            System.debug(Logginglevel.ERROR, '>>>> 30 updateReccommends Exception: ' + e + ' from: ' + e.getStackTraceString());
        }  

        
     }
 
 
 
 /**
    * Class helper for creating and populating Json Header request for UpdatePOLM Recommendations callouts
    * Eric Fishman
    * taskid PLR-
    * @class CalloutHeader
    * @constructor
    * @param {String} funcCode
    * @module Lead
    */
            
        public class polmRecommendUpdateBuilder extends OSBCalloutBuilder.RequestBuilder {          
            public String COMM_CODE {get;set;}  //1
            public String STATUS {get;set;} //1
            public String SUB_STATUS {get;set;} //1
            
            public polmRecommendUpdateBuilder(Lead inLead){
                if (inLead != null){
                    this.COMM_CODE = inLead.CommCode__c;
                    this.STATUS = inLead.Status;
                    this.SUB_STATUS = inLead.SubStatus__c;
                }
            }
         }
         
        public class Status {
            public string STATUS_ITEM;
            public Status(String inStatus) {
                this.STATUS_ITEM = inStatus;
            }
        }   
            
        public class SubStatus {
            public string SUB_STATUS_ITEM;
            
            public SubStatus(String inSubStatus){
                this.SUB_STATUS_ITEM = inSubStatus;
            }
            
        }   

    }