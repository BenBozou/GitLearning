/*
* Service for Inboud Integrations
* author: Eric Fishman
* @class InboundWebserviceWeb2CreateLead
* Taskid PLR-24
* @module Lead
*    
*    endpoint : /services/apexrest/inboundWebservice/Lead/Web2CreateLead				
*    Request Body:   
*	{
*	  "timeStamp": "2015-07-01 07:34:45",
*	  "RequestLineList": [
*	    {      
*			"Action":"22",
*			"FirstName":"Dor",
*			"LastName":"Miron3",
*			"ssn":"45687778",
*			"phone":"0244568643",
*			"companyName":"Name MVC3",
*			"companyNumber":"1234",
*			"comments":"comments"
*	    }    
*	  ]
*	}
*/
public with sharing class InboundWebserviceLead implements inboundWebservice.InboundWebserviceInterface{
    
     /**
        *   Method for handling calls to that service
        *   author Eric Fishman
        *   @method handle
        *   @param {RestRequest} request 
        *   @param {inboundWebservice.InboundRestResponse} result 
        *   @return void
        */
    
    public void handle(RestRequest request, inboundWebservice.InboundRestResponse result) { 
            try{
	            String jsonReq = request.requestBody.toString();	            
	             
  				System.debug(Logginglevel.ERROR, '>>>> 100 createLead jsonReq ' + jsonReq);  				

	            if(result.requestedAction == 'Web2CreateLead'){
	                //createLead(jsonReq, result);	    
	                String res = CreateLeadService.createLead(jsonReq);            
	            }
	            else{
	                setResultError('Incorrect Service',2,result);
	            }
            }catch(Exception ex){
        		setResultError('Exception ' + ex.getStackTraceString(),99,result);
        	}
        }
        
        
        
        /**
        *   Method for validation data for create Lead process
        *   author Eric Fishman
        *   @method createlead
        *   @param {Map<String, Object>} objReq
        *   @param {inboundWebservice.InboundRestResponse} result 
        *   @return void
        */
        /*
        private void createlead(String objReq, inboundWebservice.InboundRestResponse result){
            
            String res = CreateLeadService.createLead(objReq);// leadService = new CreateLeadService();
        }
        
        */
        
        
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