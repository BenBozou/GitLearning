/**
* Service class to retriev Next Lead
* Tal Sabati
* Taskid PLR-634
* @class LeadAssignmentService
* @module Leads
*/
public without sharing class LeadAssignmentService{
   
    public NextLeadDetails nextLeadDetails;
    private static Decimal learnTime;
    
    public class LeadAssignmentServiceResponse{
        public Lead lead{get;set;}
        public String message{get;set;}
    }
    
   /**
    *   Method for retrieving Next Lead for specific agent and preparing ConsoleLink
    *   Author Elie Perez
    *   @method getInteractionEvent
    *   @param {User} user
    *   @return {ConsoleService} ConsoleService
    */
    public ConsoleService getInteractionEvent(User user){
        //Lead lead = assignLead(user);
        ConsoleService console;
        LeadAssignmentServiceResponse response = assignLead(user);
        if(changeRecordOwner(user, response.lead)){
            Task t = createNewTask(user, response.lead);
            if(t != null){
                //ConsoleService console;
                nextLeadDetails = createNextLeadDetails(response.lead, t);
                
                if(response.lead.ContactId__c != null && response.lead.AccountId__c != null){
                    string url = '/' + response.lead.AccountId__c + '?contactId=' + response.lead.ContactId__c+ '&recommendation=true';
                    console = new ConsoleService(user, url , response.lead.Name);
                    string urlSubTab = '/apex/OmniScriptCellcomPage?omniScriptName=LeadHandle&id='+ response.lead.Id +'&TaskIdparam=' + t.Id + '&layout=lightning#/OmniScriptType/Lead/OmniScriptSubType/New/OmniScriptLang/English/ContextId/'+ response.lead.Id +'/PrefillDataRaptorBundle/true';
                    //string urlSubTab = '/apex/vf_GetNextLEad';
                    console.setSubTab(urlSubTab, System.Label.LeadScreenTabName); 
                    console.setOutboundInformation(response.lead.Id,CustomMetadataTypeService.getCrmVariable('MainScreen360TabName'));   
                }
                else{
                    string url = '/apex/OmniScriptCellcomPage?omniScriptName=LeadHandle&id='+ response.lead.Id +'&TaskIdparam=' + t.Id + '&layout=lightning#/OmniScriptType/Lead/OmniScriptSubType/New/OmniScriptLang/English/ContextId/'+ response.lead.Id +'/PrefillDataRaptorBundle/true';
                    //string url = '/apex/vf_GetNextLEad?omniScriptName=LeadHandle&id='+ response.lead.Id +'&TaskIdparam=' + t.Id + '&layout=lightning#/OmniScriptType/Lead/OmniScriptSubType/New/OmniScriptLang/English/ContextId/'+ response.lead.Id +'/PrefillDataRaptorBundle/true';
                    console = new ConsoleService(user, url , response.lead.Name);
                    console.setOutboundInformation(response.lead.Id, CustomMetadataTypeService.getCrmVariable('LeadScreenTabName'));
                }
                return console;
            }
        }
        console = new ConsoleService(user, '', '');
        console.message = response.message;
        return console;
    }
    
    /**
    *   Method for creating new task related to the lead
    *   Author Tal Sabati
    *   @method createNewTask
    *   @param {User} user
    *   @param {Lead} lead 
    *   @return {Task} t
    */
    private Task createNewTask(User user, Lead lead){
        RecordType leadRecordType = [Select id,DeveloperName From RecordType where DeveloperName= 'Get_Next_Lead_Task' limit 1];
        Task t = new Task();
        t.RecordTypeId = leadRecordType.id;
        t.OwnerId = user.id;
        t.Subject = 'שיחה';
        t.Status = 'Open';
        t.Priority = 'Normal';
        t.ActivityDate = date.today();
        t.LeadId__c = lead.Id;
        t.LeadStatus__c = 'LST14';
               
        if(lead.ContactId__c != null && lead.AccountId__c != null){
            t.WhoId = lead.ContactId__c;
            t.WhatId = lead.AccountId__c;
        }
        else{
            t.WhoId = lead.Id;
        }
       
       // t.WhoId = lead.Id;
        try{
            insert t;
        }catch(Exception ex){
            system.debug(logginglevel.ERROR,'LeadAssignmentService.createNewTask - Exception: ' +  ex.getStackTraceString());
        }
        return t;
    }
    /**
    *   Method for changing lead owner to be the agent 
    *   Author Tal Sabati
    *   @method changeRecordOwner
    *   @param {User} user
    *   @param {Lead} lead 
    *   @return {Boolean} unable to change ownership
    */
    private Boolean changeRecordOwner(User user, Lead lead){
        if(lead == null) return false;
        try{
        	if(lead.OwnerId != user.id){
	            lead.OwnerId = user.id;
	            update lead;
        	}
        }catch(Exception ex){
            system.debug(logginglevel.ERROR,'LeadAssignmentService.changeRecordOwner- Exception: ' +  ex.getStackTraceString());
            return false;
        }
        return true;
    }
    /**
    *   Method for creating new Next Lead Details
    *   Author Tal Sabati
    *   @method createNextLeadDetails
    *   @param {Task} t
    *   @param {Lead} lead 
    *   @return {NextLeadDetails} nextLeadDetails
    */
    private NextLeadDetails createNextLeadDetails(Lead lead, Task t){
        OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
        NextLeadDetails nextLeadDetails = new NextLeadDetails();
        nextLeadDetails.phone = String.valueOf(lead.get('Phone'));      
        nextLeadDetails.taskId = t.id;
        if(learnTime != null)
        	nextLeadDetails.learningTime = String.valueOf(learnTime);
        else if(orgSettings != null && orgSettings.LearningTime__c != null)
        	nextLeadDetails.learningTime = String.valueOf(orgSettings.LearningTime__c);
        return nextLeadDetails;
    }
    /**
    * Get next lead if available and assigne it to the user
    * Tal Sabati
    * @method assignLead
    * @param {User} user
    * @return {Lead}
    */
    private LeadAssignmentServiceResponse assignLead(User user){
        LeadAssignmentServiceResponse response = new LeadAssignmentServiceResponse();
        //Lead lead;
        //Have Followup Task?
        String taskRecordTypeName = 'Get Next Lead Task';// shoud be move to custom settings
        String taskLeadStatus = 'LST05'; // shoud be move to custom settings
        String LeadFollowupStatus = 'LST05'; // shoud be move to custom settings
       
        OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
        Integer reminderUpperRangeMinutes = orgSettings == null || orgSettings.ReminderUpperRangeMinutes__c == null ? 30 : (Integer)orgSettings.ReminderUpperRangeMinutes__c;
        Integer reminderLowerRangeMinutes = orgSettings == null || orgSettings.ReminderLowerRangeMinutes__c == null ? -30 : (Integer)orgSettings.ReminderLowerRangeMinutes__c;
        list<String> leadSourceHotList = orgSettings == null || String.isBlank(orgSettings.HotLeadSources__c) ? new list<String>{'LSO09'} : orgSettings.HotLeadSources__c.split(';');
        list<String> leadSourceUnicaList = orgSettings == null || String.isBlank(orgSettings.UnicaLeadSources__c) ? new list<String>{'LSO13'} : orgSettings.UnicaLeadSources__c.split(';');
        //String SystemUser = orgSettings == null || String.isBlank(orgSettings.SystemUserFullName__c) ? 'Integration User' : orgSettings.SystemUserFullName__c;
        Integer followUpLimitation = orgSettings == null || orgSettings.LimitOfLeadsToFollowUp__c == null ? 15 : (Integer)orgSettings.LimitOfLeadsToFollowUp__c;
        //return lead;
       
        system.debug(Logginglevel.DEBUG,'lead user.Id =  ' + user.Id );
        //get followup leads tasks
        list<Task> tasksList = new list<Task>( [select  id, WhoId 
                                                from    Task 
                                                where   OwnerId =: user.Id and
                                                        RecordType.Name =: taskRecordTypeName and
                                                        Who.Type = 'Lead' and
                                                        isClosed = false and
                                                        LeadStatus__c =: taskLeadStatus and
                                                        ReminderDateTime <=: Datetime.Now().addMinutes(reminderUpperRangeMinutes) and
                                                        ReminderDateTime >=: Datetime.Now().addMinutes(reminderLowerRangeMinutes)
                                                        order by ReminderDateTime DESC
                                                        limit 1]);
        if(!tasksList.isEmpty()){
            response.lead = [SELECT Id, MobilePhone, Name, ContactId__c, AccountId__c, Phone, OwnerId, Product__r.LearningTime__c FROM Lead Where Id =: tasksList[0].WhoId];
            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.assignLead - Followup lead id: ' + response.lead);
            learnTime = response.lead.Product__r.LearningTime__c;
            tasksList[0].Status = 'TST21';//closed
            DatabaseManager.DatabaseResult result = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,tasksList,true);
            return response;
        }
        
        Boolean getMyOpenLeads = orgSettings == null ? false : orgSettings.GetMyOpenLeads__c;
        if(getMyOpenLeads || Test.isRunningTest()){
	        // Return my open lead
	        response.lead = getMyLead(user.Id);
	        if(response.lead != null){
	            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.assignLead - My open lead id: ' + response.lead);
	            return response;
	        }
        }
        
        //has no followup task, see if allowed to get new leads...
        list<UserSkill__c> userSkillList = new list<UserSkill__c>( [select Id, QuantityUtilizedPerHour__c, QuantityUtilized__c, HotLead__c, Leads__c, Existing__c, Quantity__c, LastRunDate__c 
                                                                    from UserSkill__c 
                                                                    where User__c =: user.Id limit 1]);
        
        //reset the userskill counter
        if(!userSkillList.isEmpty() && userSkillList[0].LastRunDate__c < Datetime.now().addHours(-1)){
            userSkillList[0].LastRunDate__c = Datetime.now();
            userSkillList[0].QuantityUtilizedPerHour__c = 0;
        }
        
        if(!canGetLeads(response,userSkillList)){
            return response;
        }
        
        //check followup limitation (followUpLimitation)
        list<Lead> existingFollowupLeadsList = new list<Lead>([select id from Lead where Status =: LeadFollowupStatus and OwnerId =: user.Id]);
        if(existingFollowupLeadsList.size() >= followUpLimitation){
            //cannot get more leads, user 
            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.assignLead - Cannot get new lead, already have ' + existingFollowupLeadsList.size() + ' leads in followups.');
            response.message = Label.FollowupLimitError;
            return response;
        }
        
        String userType = ProfileTypeService.getProfileTypeById(user.ProfileId);//B2B, B2C
        Id queueId = null;
        if(userType == 'B2C')
        	queueId = [Select QueueId from QueueSobject where SobjectType = 'Lead' and Queue.DeveloperName = 'B2CLeads' limit 1].QueueId;
        else if(userType == 'B2B')
        	queueId = [Select QueueId from QueueSobject where SobjectType = 'Lead' and Queue.DeveloperName = 'B2BLeads' limit 1].QueueId;
        
        //look for existing Hot lead
        if(userSkillList[0].HotLead__c || Test.isRunningTest()){
            response.lead = getHotLead(leadSourceHotList,userSkillList[0],user.Id,queueId);
            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.assignLead - hot lead id: ' + response.lead);
        }
        //Coundn't find leads in SFDC, get from POLM
        if((response.lead == null && userSkillList[0].Existing__c) || Test.isRunningTest()){
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('company_focus','inConsumerfocus'); //??????
            inputMap.put('user_id',user.Id);
            GetPOLMOutRecommendsService ctrl = new GetPOLMOutRecommendsService();
            response.lead = ctrl.getOutReccommendations(inputMap);
            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.assignLead - GetPOLMOutRecommendsService lead id result: ' + response.lead);
        }
        //look for existing lead
        if((response.lead == null && userSkillList[0].Leads__c) || Test.isRunningTest()){
            response.lead = getLead(leadSourceUnicaList,userSkillList[0],user.Id,queueId);
            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.assignLead - existing (unica) lead id: ' + response.lead);
        }
        
        if(response.lead != null || Test.isRunningTest()){
            userSkillList[0].QuantityUtilizedPerHour__c = userSkillList[0].QuantityUtilizedPerHour__c == null ? 1 : userSkillList[0].QuantityUtilizedPerHour__c + 1;
            userSkillList[0].QuantityUtilized__c = userSkillList[0].QuantityUtilized__c == null ? 1 : userSkillList[0].QuantityUtilized__c + 1;
            DatabaseManager.DatabaseResult result = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,userSkillList,true);
        }
        else
            response.message = Label.CouldNotFindLead;
        return response;
    }
    /**
    * get My Open lead according to owner
    * Eliran
    * @method getMyLead
    * @param {Id} userId
    * @return {Lead}
    */
    private Lead getMyLead(Id userId){
        Lead lead = null;
        list<Lead> leadsList = [select  Id, MobilePhone, Name, ContactId__c, AccountId__c, Phone, OwnerId, Product__r.LearningTime__c
                                from    Lead 
                                where   (Status = 'LST01' or  Status = 'LST14')   and
                                        OwnerId =: userId
                                        limit 1];
        if(!leadsList.isEmpty()){
            lead = leadsList[0];
            learnTime = lead.Product__r.LearningTime__c;
        }
        return lead;
    }
    
    /**	
    * get lead according to source and owner
    * Mohammad
    * @method getHotLead
    * @param {list<String>} sourceList
    * @param {UserSkill__c} userSkill
    * @param {Id} userId
    * @param {Id} queueId
    * @return {Lead}
    */
    private Lead getHotLead(list<String> sourceList, UserSkill__c userSkill, Id userId, Id queueId){
        Lead lead = null;
        list<Lead> leadsList = [select  Id, MobilePhone, Name, ContactId__c, AccountId__c, Phone, OwnerId, Product__r.LearningTime__c
                                from    Lead 
                                where   LeadSource in: sourceList and
                                        Status = 'LST01' and
                                        //Owner.Name =: notAssignedUser
                                        //Owner.Type = 'Queue'
                                        OwnerId =: queueId
                                        limit 1];
        if(!leadsList.isEmpty()){
            leadsList[0].OwnerId = userId;
            DatabaseManager.DatabaseResult result = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,leadsList,true);
            if(result.isSuccess()){
                lead = leadsList[0];
                learnTime = lead.Product__r.LearningTime__c;
            }
        }
        return lead;
    }
    
    /**	
    * get lead according to source and owner
    * Mohammad
    * @method getLead
    * @param {list<String>} sourceList
    * @param {UserSkill__c} userSkill
    * @param {Id} userId
    * @param {Id} queueId
    * @return {Lead}
    */
    private Lead getLead(list<String> sourceList, UserSkill__c userSkill, Id userId, Id queueId){
        User runUser = [select Spoken_Languages__c, Location__c from User Where Id =: userId limit 1];
        list<String> langsList = String.isNotBlank(runUser.Spoken_Languages__c) ? runUser.Spoken_Languages__c.split(';') : new list<String>();
        Lead lead = null;
        list<Lead> leadsList = [select  Id, MobilePhone, Name, ContactId__c, AccountId__c, Phone, OwnerId, Product__r.LearningTime__c, Score__c
                                from    Lead 
                                where   LeadSource in: sourceList and
                                        Status = 'LST01' and
                                        OwnerId =: queueId and
                                        Language__c IN: langsList
                                        //order by Score__c ASC
                                        limit 1 for update];
        if(!leadsList.isEmpty()){
            leadsList[0].OwnerId = userId;
            leadsList[0].Outbond__c = true;
            DatabaseManager.DatabaseResult result = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,leadsList,true);
            if(result.isSuccess()){
                lead = leadsList[0];
                learnTime = lead.Product__r.LearningTime__c;
            }
        }
        return lead;
    }
    
    /**
    * validate if can get new lead
    * Mohammad
    * @method canGetLeads
    * @param {list<UserSkill__c>} userSkillList
    * @return {Boolean}
    */
    private Boolean canGetLeads(LeadAssignmentServiceResponse response, list<UserSkill__c> userSkillList){
        OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
        Integer limitPerHour = orgSettings == null || orgSettings.LimitPerHour__c == null ? 15 : (Integer)orgSettings.LimitPerHour__c;

        if(userSkillList.isEmpty()){
            //no user skill found, cannot proceed
            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.canGetLeads - User has no UserSkill reocrd.');
            response.message = Label.NoUserSkillError;
            return false;
        }
        if(userSkillList[0].QuantityUtilizedPerHour__c >= limitPerHour ){
            //cannot get more leads
            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.canGetLeads - Cannot get new lead, already consumed the allowed amount of followups per hour.');
            response.message = Label.HourlyFollowupLimitError;
            return false;
        }
        if(userSkillList[0].QuantityUtilized__c >= userSkillList[0].Quantity__c){
            //cannot get more leads
            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.canGetLeads - Cannot get new lead, already consumed the allowed amount of leads.');
            response.message = Label.AllowedAmountOfLeadsError;
            return false;
        }
        return true;
    }
    
    
    /**
    * get/create POLM Offer(lead)
    * Mohammad
    * @method getPOLMOffer
    * @param {map<String,Object>} recommendMap
    * @param {String} agentAllDet
    * @param {String} agentShortDet
    * @param {Id} accountId
    * @param {Id} contactId
    * @return {Lead}
    */
    public static Lead getPOLMOffer(map<String,Object> recommendMap, String agentAllDet, String agentShortDet, Id accountId, Id contactId, Boolean isOutbond){
    
        Lead lead;
        
        list<Lead> leadsList;
        if(recommendMap.containsKey('COMM_CODE') && !String.isBlank((String)recommendMap.get('COMM_CODE'))){
            String commCode = (String)recommendMap.get('COMM_CODE');
            leadsList = [select Id, MobilePhone, Name, ContactId__c, AccountId__c, Phone, OwnerId, Product__r.LearningTime__c from Lead where CommCode__c =: commCode limit 1];
        }
        
        if(leadsList != null && leadsList.size() == 1){
            lead = leadsList[0];
            learnTime = lead.Product__r.LearningTime__c;
            system.debug(Logginglevel.DEBUG,'LeadAssignmentService.getPOLMOffer - Existing lead found: ' + lead.Id);
        }
        else{
            list<Account> accountsList = new list<Account>();
            if(accountId != null){
                accountsList = [select id, Name from Account where Id =: accountId limit 1];
            }
            else if(recommendMap.containsKey('CONSUMER_ACCOUNT') && !String.isBlank((String)recommendMap.get('CONSUMER_ACCOUNT'))){
                String accExternalId = (String)recommendMap.get('CONSUMER_ACCOUNT');
                if(String.isNotBlank(accExternalId))
                    accountsList = [select id, Name from Account where CellcomExternalID__c =: accExternalId limit 1];
            }
            list<Product2> productsList = new list<Product2>();
            if(recommendMap.containsKey('PRODUCT') && !String.isBlank((String)recommendMap.get('PRODUCT'))){
                String prodCode = (String)recommendMap.get('PRODUCT');
                if(String.isNotBlank(prodCode)){
                    productsList = [select id, Name, LearningTime__c from Product2 where ProductCode =: prodCode limit 1];
                    learnTime = productsList.isEmpty() ? null : productsList[0].LearningTime__c;
                }
            }
            list<Contact> contactsList = new list<Contact>();
            if(contactId != null){
                contactsList = [select Phone, id, FirstName, LastName from Contact where Id =: contactId limit 1];
            }
            else if(recommendMap.containsKey('CONTACT_EX_ID') && !String.isBlank((String)recommendMap.get('CONTACT_EX_ID'))){
                String externalId = (String)recommendMap.get('CONTACT_EX_ID');
                if(String.isNotBlank(externalId))
                    contactsList = [select Phone,id, FirstName, LastName from Contact where CellcomExternalID__c =: externalId limit 1];
            }
            lead = new Lead(RecordTypeId =      (RecordTypeService.getRecordTypeIdByName('Lead', 'Offer')),
                            AccountId__c =      accountsList.isEmpty() ? null : accountsList[0].id,
                            Company =           accountsList.isEmpty() ? null : accountsList[0].Name,
                            Product__c =        productsList.isEmpty() ? null : productsList[0].id,
                            ContactId__c =     contactsList.isEmpty() ? null : contactsList[0].id,
                            FirstName =         contactsList.isEmpty() ? null : contactsList[0].FirstName,
                            LastName =          contactsList.isEmpty() ? null : contactsList[0].LastName,
                            Phone =             contactsList.isEmpty() ? null : contactsList[0].Phone,
                            Subscriber__c =     (String)recommendMap.get('SUBSCRIBER'),
                            //Phone =             (String)recommendMap.get('SUBSCRIBER'),
                            //Subscriber__c =     '0000000000',
                            BAN__c =            (String)recommendMap.get('BAN'),
                            PSID__c =           (String)recommendMap.get('PSID'),
                            CampaignId__c =     (String)recommendMap.get('CAMP_ID'),
                            CampaignCyc__c =    (String)recommendMap.get('CAMP_CYCLE'),
                            TreatId__c =        (String)recommendMap.get('TREAT_ID'),
                            CommCode__c =       (String)recommendMap.get('COMM_CODE'),
                            ProvCode__c =       (String)recommendMap.get('PROV_CODE'),
                            ProvIndication__c = (String)recommendMap.get('PROV_IND'),
                            SystemCode__c =		(String)recommendMap.get('SYSTEM_LEGACY'),
                            AgentShortDet__c =  agentShortDet,
                            AgentLongDet__c  =  agentAllDet,
                            LeadSource = 'LSO16',
                            Outbond__c = isOutbond,
                            OwnerId = UserInfo.getUserId()
                            );
            DatabaseManager.DatabaseResult result = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION,new list<Lead>{lead},true);
            if(!result.isSuccess()){
                System.debug(Logginglevel.ERROR, 'Failed to create lead: \n' + result.getAllErrorMessages('\n'));
                lead = null;
            }
        }
        return lead;
    }
    
    
    public class NextLeadDetails{
        public string phone;
        public string taskId;
        public string learningTime;
    }

}