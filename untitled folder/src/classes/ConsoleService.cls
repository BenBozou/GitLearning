/**
* Service for Console
* Tal Sabati
* Taskid PLR-634
* @class ConsoleService
* @module Leads
*/
public with sharing class ConsoleService{
   
   private User u;
   public InteractionEvent__c interactionEvent;
   public String message;
    /**
    *  Constructor
    *   Author Elie Perez
    *   @param {User} user
    *   @param {string} url
    *   @param {string} tabLabel
    */
   public ConsoleService(User user, string url, string tabLabel){
        interactionEvent = new InteractionEvent__c();
        interactionEvent.URL__c = url;
        interactionEvent.Name = tabLabel;
        u = user;
        insert interactionEvent;
   }
   /**
    *   Get the screen name 
    *   Author Tal sabati
    *   @method getOpenScreenName
    *   @return {string} Open Screen Name
   */ 
   public string getOpenScreenName(){
        return interactionEvent.OpenScreen__c;
   }
   /**
    *   Get Interaction Event Id
    *   Author Tal sabati
    *   @method getInteractionEventId
    *   @return {string} Interaction Event Id
   */ 
   public string getInteractionEventId(){
        return interactionEvent.Id;
   }
    /**
    *   Set Subtab url to be opened in the console
    *   Author Elie Perez
    *   @method setSubTab
    *   @param {string} url
    *   @param {string} label
    *   @return {void}
    */ 
   public void setSubTab(string url, string label){
        interactionEvent.SubtabLabel__c = label;
        interactionEvent.SubtabURL__c = url;
   }
   
    /**
    *   Set Inbound information received from IVR
    *   Author Tal sabati
    *   @method setInboundInformation
    *   @param {string} 
    *   @return {void}
    */ 
   public void setInboundInformation(Id accountId,Id contactId, Id leadId, string openScreen, Boolean invalidRquest, string callOrigin, string paymentIdentifierRelatedEntity, string paymentIdentifier, string customerSegment, string phone, Boolean sharingAgrement, string callPurpose){
        interactionEvent.CallType__c = 'Inbound';
        interactionEvent.AccountId__c = accountId;
        interactionEvent.ContactId__c = contactId;
        interactionEvent.LeadId__c = leadId;
        interactionEvent.OpenScreen__c = openScreen;
        interactionEvent.InvalidRquest__c = invalidRquest;
        interactionEvent.CallOrigin__c = callOrigin;
        interactionEvent.PaymentIdentifierRelatedEntity__c = paymentIdentifierRelatedEntity;
        interactionEvent.PaymentIdentifier__c = paymentIdentifier;
        interactionEvent.CustomerSegment__c = customerSegment;
        interactionEvent.PhoneNumber__c = phone;
        interactionEvent.SharingAgrement__c = sharingAgrement;
        interactionEvent.CallPurpose__c = callPurpose;
   }
   /**
    *   Set Outbound information sent to CTI
    *   Author Elie Perez
    *   @method setOutboundInformation
    *   @param {Id} leadId
    *   @param {string} openScreen
    *   @return {void}
    */ 
   public void setOutboundInformation(Id leadId, string openScreen){
        interactionEvent.LeadId__c = leadId;
        interactionEvent.CallType__c = 'Outbound';
        interactionEvent.OpenScreen__c = openScreen;
        update interactionEvent;
   }
   
   /**
    *   Open the URL in the console
    *   Author Elie Perez
    *   @method openUrl
    *   {Boolean} success/failure
    */ 
   public Boolean openUrl(){
        if(interactionEvent.URL__c.contains('?')){
          interactionEvent.URL__c += '&';
        }
        else{
          interactionEvent.URL__c += '?';
        }
        interactionEvent.URL__c += 'EventId=' + interactionEvent.id;
        if(createAgentWork()){
            try{
            	if(interactionEvent.URL__c.length() < 255){
                	update interactionEvent;
            	}
                return true;
            }catch(Exception ex){
                system.debug(logginglevel.ERROR,'ConsoleService.update interactionEvent- Exception: ' + ex.getMessage() + ': ' + ex.getStackTraceString());
            }
        }
        return false;
   }
    /**
    *   Method for createing new agent work
    *   Author Tal Sabati
    *   @method createAgentWork
    *   {Boolean} success/failure
    */
    private Boolean createAgentWork(){
        ServiceChannel serviceChannel = getServiceChannel();
        if(serviceChannel != null){
            AgentWork agentWork = new AgentWork();
            agentWork.UserId= u.id;
            agentWork.ServiceChannelId= serviceChannel.id;
            agentWork.WorkItemId= interactionEvent.id;
            try{
                insert agentWork;
                return true;
            }catch(Exception ex){
                system.debug(logginglevel.ERROR,'ConsoleService.createAgentWork- Exception: ' + ex.getMessage() + ': ' + ex.getStackTraceString());
            }
        }
        return false;
    }
   
    /**
    *   Method for getting Service Channel
    *   Author Tal Sabati
    *   @method getServiceChannel
    *   @return {ServiceChannel}
    */
    private ServiceChannel getServiceChannel(){
        list<ServiceChannel> serviceChannelList = [Select Id, DeveloperName From ServiceChannel where DeveloperName='InteractionEvent' limit 1];
        if(serviceChannelList.isEmpty()){
            system.debug(logginglevel.ERROR,'ConsoleService.getServiceChannel- Error: No queue found');
            return null;        
        }
        return serviceChannelList[0];
    }
}