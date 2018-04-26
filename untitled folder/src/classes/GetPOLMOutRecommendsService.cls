/**
* Service class for handle Update Reccommendations in POLM: 
* Eric Fishman
* taskid PLR-878
* @class GetPOLMOutRecommendsService
* @module Lead 
*/
public with sharing class GetPOLMOutRecommendsService{
    
    /**
    * Get Reccommendations 
    * Eric Fishman
    * @method getOutReccommendations    
    * @param {Boolean} objectName
    * @param {String} recordTypeName
    * @return {}
    * @static
    */
    public Lead getOutReccommendations(Map<String,Object> inputMap) {       
        Lead lead;
        try{
            System.debug(Logginglevel.INFO, 'GetOutReccommendations.invokeMethod - inputMap: ' + inputMap);
            // build Body JSON
            polmOutRecommnendationsBuilder request = new polmOutRecommnendationsBuilder(inputMap);
            OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00684');
            //Append Body tp Request JSON  
            ctrlRequest.body.setRequestNode(request);
            system.debug(Logginglevel.INFO,'REQUEST: ' + ctrlRequest.serialize());
            
            System.debug(Logginglevel.INFO, 'POLM userid = .' + user.Id);  
            
            Map<String,Object> response = ctrlRequest.sendRequestWithErrorCheck('OSB', 'api/services/rest/00684_osb_getrecommends_dwh');                                  
            if(!isValideResponse(response))
                return null;
                 
            map<String,Object> bodyMap = (map<String,Object>)response.get('Body');
            map<String,Object> responseMap = (map<String,Object>)bodyMap.get('Response');
            map<String,Object> recommendationsMap = (map<String,Object>)responseMap.get('Recommendations');
            list<Object> treatList = (list<Object>)recommendationsMap.get('TREAT');
            map<String,Object> treatMap = (Map<String,Object>)treatList[0];
            list<Object> treatRecommendList = (list<Object>)treatMap.get('Recommendation');
            map<String,Object> recommendMap = (map<String,Object>)treatRecommendList[0];
            String agentAllDet = (String)treatMap.get('AGENT_ALL_DET');
            String agentShortDet = (String)treatMap.get('AGENT_SHORT_DET');
            
            lead = LeadAssignmentService.getPOLMOffer(recommendMap, agentAllDet, agentShortDet, null, null, true);
        }
        catch (Exception e) {
            System.debug(Logginglevel.ERROR, '>>>> 30 Get Reccommends Exception: ' + e + ' from: ' + e.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(e));
        }  
        return lead;
    }
    
    private Boolean isValideResponse(Map<String,Object> response){
        
        //validate response
        if(response == null){
            System.debug(Logginglevel.ERROR, 'The service returned null response.');
            return false;
        }
        
        //validate header
        map<String,Object> headerMap = (map<String,Object>)response.get('Header');
        if(headerMap == null){
            System.debug(Logginglevel.ERROR, 'The service returned null header.');
            return false;
        }
        if((String)headerMap.get('ReturnCode') != '00'){
            System.debug(Logginglevel.ERROR, 'Service error: ' + (String)headerMap.get('ReturnCodeMessage'));
            return false;
        }
        
        //validate body 
        map<String,Object> bodyMap = (map<String,Object>)response.get('Body');
        if(bodyMap == null){
            System.debug(Logginglevel.ERROR, 'The service returned null body.');
            return false;
        }
        
        //validate response
        map<String,Object> responseMap = (map<String,Object>)bodyMap.get('Response');
        if(responseMap == null){
            System.debug(Logginglevel.ERROR, 'The service returned null response.');
            return false;
        }
        if((Integer)responseMap.get('P_RETURN_CODE') != 0){
            System.debug(Logginglevel.ERROR, 'Service error: ' + (String)responseMap.get('P_RETURN_MESSAGE'));
            return false;
        }
        
        //validate Recommendations
        map<String,Object> recommendationsMap = (map<String,Object>)responseMap.get('Recommendations');
        if(recommendationsMap == null){
            System.debug(Logginglevel.ERROR, 'The service returned null Recommendations.');
            return false;
        }
        
        //validate TREAT
        list<Object> treatList = (list<Object>)recommendationsMap.get('TREAT');
        if(treatList == null){
            System.debug(Logginglevel.ERROR, 'The service did not returned treat.');
            return false;
        }
        if(treatList.size() != 1){
            System.debug(Logginglevel.ERROR, 'The service did not returned one treat.');
            return false;
        }
        
        //validate Treat Recommendation
        list<Object> treatRecommendList = (list<Object>)((map<String,Object>)treatList[0]).get('Recommendation');
        if(treatRecommendList == null){
            System.debug(Logginglevel.ERROR, 'The service did not returned treat recommendation list.');
            return false;
        }
        if(treatRecommendList.size() != 1){
            System.debug(Logginglevel.ERROR, 'The service did not returned one treat recommendation.');
            return false;
        }
        
        return true;
    }
     
    /**
    * Class helper for creating and populating Json Header request for UpdatePOLM Recommendations callouts
    * Eric Fishman
    * taskid PLR-878
    * @class polmRecommnendationsBuilder
    * @constructor
    * @param {String} funcCode
    * @module Lead
    */     
    public class polmOutRecommnendationsBuilder extends OSBCalloutBuilder.RequestBuilder { 
        public outRecommendations  Recommendations; 
        
        public polmOutRecommnendationsBuilder(Map<String,Object> inputMap){
            Recommendations = new outRecommendations(inputMap);    
        }
    }
     
    public class outRecommendations {
        public String direction;
        public String userName;
        public RecommendOutbound outbound;
        
      
    
        public outRecommendations(Map<String,Object> inputMap){
            this.userName = [select FederationIdentifier from User where Id =: (Id)inputMap.get('user_id')].FederationIdentifier;//'DORONKE'
            this.direction = 'OUTBOUND';
            this.outbound = new RecommendOutbound(inputMap);
        }
    }
     
    public class RecommendOutbound{
        public String company_focus;
        public String area;
        public AgentLanguges agent_languges;
        public AgentProduct agent_products;        
        
        public RecommendOutbound (Map<String,Object> inputMap){         
            this.company_focus = (String)inputMap.get('company_focus'); // inConsumerfocus;
            
            User currentUser = [Select id, Spoken_Languages__c, Area__c from User where id =:  (Id)inputMap.get('user_id') limit 1];
            list<String> langsList = new list<String>();
            if(String.isNotBlank(currentUser.Spoken_Languages__c))
            	for(String lang : currentUser.Spoken_Languages__c.split(';'))
            		langsList.add(lang);
            this.agent_languges = new AgentLanguges(langsList);
            this.area = String.isNotBlank(currentUser.Area__c) ? currentUser.Area__c : '#';
            
            //use the current user for UserSkill
            list<UserSkill__c> userSkillList = new list<UserSkill__c>( [select Id, (select Product__r.ProductCode from User_Skill_Products__r) 
                                                                        from UserSkill__c 
                                                                        where User__c =: (Id)inputMap.get('user_id') limit 1]);
            //preper the products list
            list<String> productsList = new list<String>();
            if(!userSkillList.isEmpty() && !userSkillList[0].User_Skill_Products__r.isEmpty()){
                for(UserSkillProduct__c usProd : userSkillList[0].User_Skill_Products__r)
                    if(usProd.Product__r.ProductCode != null)
                        productsList.add(usProd.Product__r.ProductCode);
            }
            this.agent_products = new AgentProduct(productsList);
        }
    }
                
    public class AgentLanguges {
        public String[] languge;
        public AgentLanguges(String[] inLanguge) {              
            this.languge = (inLanguge != null) ? inLanguge :  new string[]{} ;
        }
    }
    
    public class AgentProduct {
        public String[] product;
        public AgentProduct(String[] inProducts) {              
            this.product = (inProducts != null ) ? inProducts : new string[]{};
        }
    }
}