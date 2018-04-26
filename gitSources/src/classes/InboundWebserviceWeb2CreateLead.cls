/*
* Service for Inboud Integrations
* author: Eric Fishman
* @class InboundWebserviceWeb2CreateLead
* Taskid PLR-24
* @module Lead
*    
*    endpoint : /services/apexrest/inboundWebservice/Lead/Web2CreateLead
*    Request Body:   
*    {
*    }
*/
public with sharing class InboundWebserviceWeb2CreateLead implements inboundWebservice.InboundWebserviceInterface{	
    
    
    
    public void handle(RestRequest request, inboundWebservice.InboundRestResponse result) { 
            try{
	            String jsonReq = request.requestBody.toString();	            
	             
  				System.debug(Logginglevel.ERROR, '>>>> 100 createLead jsonReq ' + jsonReq);
  				
	            //Map<String, Object> objReq = (Map<String, Object>) JSON.deserializeUntyped(jsonReq);
	            if(result.requestedAction == 'Web2CreateLead'){
	                createLead(jsonReq, result);	                
	            }
	            else{
	                setResultError('Incorrect Service',2,result);
	            }
            }catch(Exception ex){
        		setResultError('Exception ' + ex.getStackTraceString(),99,result);
        	}
        }
        
        
        
        /**
        *   Method for create Lead
        *   author Eric Fishman
        *   @method createlead
        *   @param {Map<String, Object>} objReq
        *   @param {inboundWebservice.InboundRestResponse} result 
        *   @return void
        */
        private void createlead(String objReq, inboundWebservice.InboundRestResponse result){
            //String federationId = String.valueOf(objReq.get('userIdentifier'));
            //User user = getUserFederationId(federationId);
            /*
            if(user == null){
                setResultError('Invalid User', 3, result);
                return; 
            }
            */
            
            String res = CreateLeadService.createLead(objReq);// leadService = new CreateLeadService();
            //String res = leadService.createLead(objReq);
            
            //result.response = leadDetail;
            
            
            
            
        }
        
        
		/**
        *   Method for Applying an application error to the Result
        *   author Eric Fishman
        *   @method setResultError
        *   @param {String} errorMessage
        *   @param {inboundWebservice.InboundRestResponse} result 
        *   @return void
        */
        private void setResultError(String errorMessage, Integer errorCode, inboundWebservice.InboundRestResponse result){
            result.statusCode = errorCode;
            result.statusMessage = errorMessage;
        }  
        /**
        *   Method for getting user based on his federation Id
        *   author Eric Fishman
        *   @method getUserFederationId
        *   @param {String} federationId
        *   @return {User}
        */
        /*
        private User getUserFederationId(String federationId){
            List<User> userList =  [select Id, Name, Username, FederationIdentifier  
                                    from User
                                    where FederationIdentifier =: federationId
                                    limit 1];
            if(userList.isEmpty()){
                return null;
            }
            return userList[0];
        } 
        */       
}