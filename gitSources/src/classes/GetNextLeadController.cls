/**
* controller class for GetNextLead and GetNextLeadConsole pages.
* Tal Sabati
* Taskid PLR-633
* @class GetNextLeadController 
* @module Leads
* @constructor GetNextLeadController
*/

public with sharing class GetNextLeadController {
    public Boolean isSoftphone {get; set;}
    public ServicePresenceStatus servicePresenceStatus {get; set;}
    public string interactionEventPrefix {get;set;}
    public string componentButtonName {get;set;}
    public Boolean isAlreadyLogged {get;set;}
    /**
    * The controller set value 
    * Tal Sabati
    * Taskid PLR-501
    * @method GetNextLeadController
    */
    public GetNextLeadController(){
        User currentuser = getCurrentuser();    
        isSoftphone = currentuser.IsSoftphone__c;
        servicePresenceStatus = [Select Id, DeveloperName, MasterLabel From ServicePresenceStatus where DeveloperName = 'Available' limit 1];
        interactionEventPrefix = InteractionEvent__c.sobjecttype.getDescribe().getKeyPrefix();
        componentButtonName = System.Label.getNextLead;
        isAlreadyLogged = ![SELECT UserId, createdDate, ServicePresenceStatusId, IsCurrentState FROM UserServicePresence where userId = :currentuser.Id and IsCurrentState = true and ServicePresenceStatusId = :servicePresenceStatus.Id].isEmpty();
    }
    
    /**
    * The method select user and call service class to get the next lead.
    * Tal Sabati
    * Taskid PLR-501
    * @method getLeadFromClient
    */
    @RemoteAction
    //public static InteractionEvent__c getLeadFromClient() {
    public static ConsoleService getLeadFromClient() {
        User currentuser = getCurrentuser();    
        LeadAssignmentService assign = new LeadAssignmentService();
        ConsoleService console = assign.getInteractionEvent(currentUser);
        return console;//.interactionEvent;
    }
    /**
    * The method select an Console URL object by id
    * Tal Sabati
    * Taskid PLR-501
    * @method GetNextLeadController
    * @return {InteractionEvent__c} interactionEvent
    */
    @RemoteAction 
    public static InteractionEvent__c getInteractionEvent(Id interactionEventId) {
        InteractionEvent__c interactionEvent = [select id, URL__c,Name, SubtabURL__c, SubtabLabel__c, OpenScreen__c, CallType__c from InteractionEvent__c where id=: interactionEventId limit 1];
        return interactionEvent;
    }
    
    /**
    * The method get feilde fron the cureent user
    * Tal Sabati
    * @method getCurrentuser
    * @return {User} currentuser
    */
    private static User getCurrentuser() {
        User currentuser = [Select Id,FederationIdentifier, IsSoftphone__c, ProfileId from User where Id=:userinfo.getuserId() limit 1];
        return currentuser;  
    }
    
    @RemoteAction 
    public static Boolean getOmniChannelLogInNecessary() {
        Boolean isOmniChannelLogInNecessary;
        ServicePresenceStatus servicePresenceStatus = [Select Id, DeveloperName, MasterLabel From ServicePresenceStatus where DeveloperName = 'Available' limit 1];
        isOmniChannelLogInNecessary = [SELECT UserId, createdDate, ServicePresenceStatusId, IsCurrentState FROM UserServicePresence where userId = :userinfo.getuserId() and IsCurrentState = true and ServicePresenceStatusId = :servicePresenceStatus.Id].isEmpty();
        return isOmniChannelLogInNecessary;
    }
}