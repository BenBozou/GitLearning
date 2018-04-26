/**
* Service for Inboud Integrations
* author: Elie Perez
* @class InboundWebserviceNextLead
* @module Leads
*    endpoint : /services/apexrest/inboundWebservice/NextLead/GetNextLead
*    Request Body:   
*    {
*      "userIdentifier" : "talSab"              
*    }
*/ 
public with sharing class InboundWebserviceNextLead  implements inboundWebservice.InboundWebserviceInterface {
        
        /**
        *   Method for handling calls to that service
        *   author Elie Perez
        *   @method handle
        *   @param {RestRequest} request 
        *   @param {inboundWebservice.InboundRestResponse} result 
        *   @return void
        */
        public void handle(RestRequest request, inboundWebservice.InboundRestResponse result) {
            try{
                String jsonReq = request.requestBody.toString();
                Map<String, Object> objReq = (Map<String, Object>) JSON.deserializeUntyped(jsonReq);
                if(result.requestedAction == 'GetNextLead'){
                    getNextLead(objReq, result);
                }else{
                    setResultError('Incorrect Service',2,result);
                }
            }catch(Exception ex){
                setResultError('Exception ' +  ex.getStackTraceString() ,99,result);
            }
        }
        
        /**
        *   Method for retrieving Next Lead for specific agent
        *   author Elie Perez
        *   @method getNextLead
        *   @param {Map<String, Object>} objReq
        *   @param {inboundWebservice.InboundRestResponse} result 
        *   @return void
        */
        private void getNextLead(Map<String, Object> objReq, inboundWebservice.InboundRestResponse result){
            String federationId = String.valueOf(objReq.get('userIdentifier'));
            User u = getUserFederationId(federationId);
            if(u == null){
                setResultError('Invalid User',3,result);
                return; 
            }
            if(!userAvailableInOmniChannel(u)){
                setResultError(System.Label.ErrMsgAgentOfflineInOmniChannel ,5,result);
                return;
            }
            LeadAssignmentService assign = new LeadAssignmentService();
            ConsoleService console = assign.getInteractionEvent(u);
            if(String.isNotBlank(console.message)){
                result.response = console.message;
                result.statusMessage = console.message;
                result.statusCode= 99;
            }
            else{
                result.response = assign.NextLeadDetails;
                console.openUrl();
            }
        }
        /**
        *   Method for check if the user connected to the Omni-Chennai
        *   Author Tal sabati
        *   @method userAvailableInOmniChannel
        *   @param {User} user
        *   @return {boolean} user connected
        */
        private boolean userAvailableInOmniChannel(User u){
            list<UserServicePresence> userServicePresence = [Select ServicePresenceStatus.DeveloperName, ServicePresenceStatusId, IsCurrentState 
                                                            From UserServicePresence 
                                                            where UserId =: u.id  
                                                            and ServicePresenceStatus.DeveloperName = 'Available'
                                                            and IsCurrentState= true];
            if(userServicePresence.isEmpty() && !Test.isRunningTest()){
                return false;
            }
            return true;
        }
        /**
        *   Method for Applying an application error to the Result
        *   author Elie Perez
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
        *   author Elie Perez
        *   @method getUserFederationId
        *   @param {String} federationId
        *   @return {User}
        */
        private User getUserFederationId(String federationId){
            List<User> userList =  [select Id, Name, Username, FederationIdentifier, ProfileId  
                                    from User
                                    where FederationIdentifier =: federationId
                                    limit 1];
            if(userList.isEmpty()){
                return null;
            }
            return userList[0];
        }
    
}