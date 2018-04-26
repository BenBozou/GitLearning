/**
* Controller related to the "Event Summary" Process.
 *       The process allows the user to summarize an event with the following information:
 *           -   The Event fields.
 *           -   The Internal/External participants.
 *           -   Create tasks according to the event.
 *           -   Send an email summarizing the event to:
 *               - The Event Owner and the Event related contact as TO addresses
 *               - The selected internal participants as CC addresses.
* Jonathan Cohen
* taskid PLR-976 Event Summary
* @class EventSummary_CTRL
* @module Lead
*/
public class EventSummary_CTRL
{
    /**
     *  @PublicMembers
     */
    public Event EventToSummarize                               {get; set;}
    public Task NewRelatedTask                                  {get; set;}
    public List<Task> RelatedTaskList                           {get; set;}
    public boolean DisplayTaskCreation                          {get; set;}    
    public boolean PageError                                    {get; set;} 
    public Event TempEvent                                      {get; set;}
    public boolean result                                       {get; set;}
    //public list<EventParticipant> customerParticipantsList      {get; set;}
    public list<EventParticipant> participantsList              {get; set;}
    public list<EventParticipant> additionalParticipantsList    {get; set;}
    public Integer rowToRemove                                  {get; set;}
    
    //public Boolean sendEmailToCellcomManager                    {get; set;}
    //public Boolean sendEmailToCellcomSales                      {get; set;}
    //public Boolean sendEmailToCellcomPreSales                   {get; set;}
    //public Boolean sendEmailToCellcomMarketing                  {get; set;}
    
    /**
     *  @PrivateMembers
     */
    private Id RecordTypeId;
    private map<String,EventParticipant> prevParticipantsMap;

    /**
     *  @FinalMembers
     */
    private final String WhoRecordType                          = 'Contact';
    private final String TaskRecordTypeName                     = 'MeetingSummery';
    private final String TaskMeetingSummaryRecordTypeName       = 'MeetingSummaryLog';
    private final String EventEmailTemplateId                   = 'Event_Summary_Email';

    
    
    /**
     *  wrapper class for managing event participants
     *  Mohammad Garrah
     *  @class EventParticipant
     *  @module Lead
     */
    public class EventParticipant{
        public String participantName               {get; set;}
        public String participantEmail              {get; set;}
        public Event tempEvent                      {get; set;}
        public Boolean participantSendEmail         {get; set;}
        //public Integer rowIndex                       {get; set;}
        
        public EventParticipant(/*Integer rowIndex*/){
            this.participantName = '';
            this.participantEmail = '';
            this.tempEvent = new Event();
            this.participantSendEmail = false;
            //this.rowIndex = rowIndex;
        }
        
        public EventParticipant(/*Integer rowIndex, */String participantName, String participantEmail, Boolean participantSendEmail, String participantType, String participantSubType){
            this.participantName = participantName;
            this.participantEmail = participantEmail;
            this.participantSendEmail = participantSendEmail;
            this.tempEvent = new Event();
            this.tempEvent.ParticipantsType__c = participantType;
            this.tempEvent.ParticipantsSubType__c = participantSubType;
            //this.rowIndex = rowIndex;
        }
    }
    
    
    /**
     *  @name        - EventSummary_CTRL()
     *  @description - Constructor.
     *  @U.S         - PLR-976.
     */
    public EventSummary_CTRL()
    {
        try{
            this.PageError = true;
            Id eventID = ApexPages.currentPage().getParameters().get('eventID');
        
            if(eventID != null){
                this.TempEvent = new Event();
                this.PageError = false;
                UpdateTaskCreationSection(false);
                RetrieveCurrentEvent(eventID);
                RetrieveTaskRecordType();
                RetrieveRelatedTaskList();
                additionalParticipantsList = RetrieveParticipantsList(EventToSummarize.AddtionalParticipants__c, EventToSummarize.AddtionalParticipantsEmails__c, EventToSummarize.AdditionalParticipantsType__c, EventToSummarize.AdditionalParticipantsSubType__c);
                
                list<EventParticipant> prevParticipantsList = new list<EventParticipant>();
                prevParticipantsList.addAll(RetrieveParticipantsList(EventToSummarize.Customer_Participants__c, EventToSummarize.CustomerParticipantsEmails__c, EventToSummarize.CustomerParticipantsType__c, EventToSummarize.CustomerParticipantsSubType__c));
                prevParticipantsList.addAll(RetrieveParticipantsList(EventToSummarize.CellcomParticipants__c, EventToSummarize.CellcomParticipantsEmail__c, EventToSummarize.CellcomParticipantsType__c, EventToSummarize.CellcomParticipantsSubType__c));
                prevParticipantsList.addAll(RetrieveParticipantsList(EventToSummarize.SubcontractorsParticipants__c, EventToSummarize.SubcontractorsParticipantsEmail__c, EventToSummarize.SubcontractorsParticipantsType__c, EventToSummarize.SubcontractorsParticipantsSubType__c));
                
                system.debug('>>> prevParticipantsList: ' + prevParticipantsList);
                
                prevParticipantsMap = new map<String,EventParticipant>();
                for(EventParticipant ep : prevParticipantsList)
                    if(String.isNotBlank(ep.participantEmail))
                        prevParticipantsMap.put(ep.participantEmail,ep);
                
                RetrieveExistingParticipantsList();
                
                system.debug('>>> participantsList size: ' + participantsList.size());
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while loading the page!'));
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while loading the page!'));
        }
    }  
    
    /**
     *  @name        - RetrieveCurrentEvent()
     *  @param       - Id.
     *  @return      - N.A.
     *  @description - Retreives the Event.
     *  @U.S         - PLR-976.
     */
    private void RetrieveCurrentEvent(Id eventID)
    {
        this.EventToSummarize = [SELECT Id,
                                            Subject,
                                            Startdatetime,
                                            Enddatetime,
                                            OwnerID,
                                            Owner.Email,
                                            WhoId,
                                            who.Type,
                                            WhatId,
                                            Type,
                                            Description, 
                                            Related_Products__c,
                                            Customer_Participants__c,
                                            CustomerParticipantsEmails__c,
                                            CustomerParticipantsType__c,
                                            CustomerParticipantsSubType__c,
                                            CellcomParticipants__c,
                                            CellcomParticipantsEmail__c,
                                            CellcomParticipantsType__c,
                                            CellcomParticipantsSubType__c,
                                            SubcontractorsParticipants__c,
                                            SubcontractorsParticipantsEmail__c,
                                            SubcontractorsParticipantsType__c,
                                            SubcontractorsParticipantsSubType__c,
                                            AddtionalParticipants__c,
                                            AddtionalParticipantsEmails__c,
                                            AdditionalParticipantsType__c,
                                            AdditionalParticipantsSubType__c,
                                            EventStatus__c
                                FROM Event
                                WHERE id=:eventID];
    }

    /**
     *  @name        - RetrieveTaskRecordType()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - Retreives the tasks "General" record type.
     *  @U.S         - PLR-976.
     */
    private void RetrieveTaskRecordType()
    {
        this.RecordTypeId = [SELECT Id
                            FROM RecordType
                            WHERE SobjectType = 'Task' AND DeveloperName = :TaskRecordTypeName limit 1].Id;
    }

    /**
     *  @name        - RetrieveRelatedTaskList()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - Retreives the tasks "related" to the Event.
     *                   - The tasks are "related" to the Event using 2 custom text fields (EventID__c, EventName__c) containing the Event Id and the Event Name.
     *  @U.S         - PLR-976.
     */
    private void RetrieveRelatedTaskList()
    {
        this.RelatedTaskList = [SELECT id,
                                            Description,
                                            ActivityDate,
                                            Subject,
                                            Ownerid,
                                            Owner.Name,
                                            Status,
                                            Priority,
                                            Whoid,
                                            Whatid
                                FROM Task
                                WHERE eventID__c = :this.EventToSummarize.Id and RecordType.DeveloperName =: TaskRecordTypeName ORDER BY CreatedDate DESC];
    }
    
    
    /**
     *  @name        - RetrieveExistingParticipantsList()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - Retreives the Participants "related" to the Event.
     *  @U.S         - PLR-976.
     */
    private void RetrieveExistingParticipantsList()
    {
        system.debug('>>> this.EventToSummarize.Id: ' + this.EventToSummarize.Id);
        participantsList = new list<EventParticipant>();
        list<EventRelation> eventInviteesList = new list<EventRelation>([Select 
                                                                                Status, 
                                                                                RelationId, 
                                                                                Relation.Name,
                                                                                Relation.Type, 
                                                                                Relation.Email 
                                                                         From 	EventRelation 
                                                                         Where 	EventId =: this.EventToSummarize.Id and
                                                                         		(Relation.Type = 'Contact' or Relation.Type = 'User' or Relation.Type = 'Lead')]);
                                                                         		
		//Since the Relation.Email field is empty for the contact, we need to query the contacts emails
		list<Id> contactsIdList = new list<Id>();
		list<id> leadIdList = new list<Id>();
		
		for(EventRelation er : eventInviteesList)
			if(er.Relation.Type == 'Contact')
				contactsIdList.add(er.RelationId);
			else if(er.Relation.Type == 'Lead')
                leadIdList.add(er.RelationId);
                
        map<Id,Contact> contactsMap = new map<Id,Contact>([select id, Email from Contact where id IN: contactsIdList]);
        map<Id,Lead> leadMap = new map<Id,Lead>([select id, Email from Lead where id IN: leadIdList]);
        
        for(EventRelation er : eventInviteesList){
        	String inviteeEmail = '';
        	if(er.Relation.Type == 'User')
        		inviteeEmail = er.Relation.Email;
        	else if (er.Relation.Type == 'Contact')
        		inviteeEmail = contactsMap.get(er.RelationId).Email;
        	else if (er.Relation.Type == 'Lead')
        		inviteeEmail = leadMap.get(er.RelationId).Email;
        	
            if(String.isNotBlank(inviteeEmail) && prevParticipantsMap.containsKey(inviteeEmail))
                participantsList.add(new EventParticipant(er.Relation.Name,inviteeEmail,false,prevParticipantsMap.get(inviteeEmail).tempEvent.ParticipantsType__c,prevParticipantsMap.get(inviteeEmail).tempEvent.ParticipantsSubType__c));
            else
                participantsList.add(new EventParticipant(er.Relation.Name,inviteeEmail,false,'',''));
        }
    }
    
    
    /**
     *  @name        - RetrieveParticipantsList()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - Retreives the participants from the Event.
     *  @U.S         - PLR-1444.
     */
    private list<EventParticipant> RetrieveParticipantsList(String names, String emails, String types, String subTypes)
    {
        list<EventParticipant> participantsList = new list<EventParticipant>();
        list<String> ParticipantNamesList = new list<String>();
        list<String> ParticipantEmailsList = new list<String>();
        list<String> ParticipantTypesList = new list<String>();
        list<String> ParticipantSubTypesList = new list<String>();
        if(String.isBlank(names) || String.isBlank(emails) || String.isBlank(types) || String.isBlank(subTypes))
            return participantsList;
        //there are participants, init the list
        try{
            ParticipantNamesList = names.split(';');
            ParticipantEmailsList = emails.split(';');
            ParticipantTypesList = types.split(';');
            ParticipantSubTypesList = subTypes.split(';');
            system.debug('>>> list sizes ' + ParticipantNamesList.size() + ' -- ' + ParticipantEmailsList.size() + ' -- ' + ParticipantTypesList.size() + ' -- ' + ParticipantSubTypesList.size());
            for(Integer i = 0 ; i < ParticipantNamesList.size() ; i++)
                participantsList.add(new EventParticipant(/*i,*/ParticipantNamesList[i] == 'null' ? '' : ParticipantNamesList[i],ParticipantEmailsList[i] == 'null' ? '' : ParticipantEmailsList[i],false,ParticipantTypesList[i] == 'null' ? '' : ParticipantTypesList[i],ParticipantSubTypesList[i] == 'null' ? '' : ParticipantSubTypesList[i]));
        }
        catch(Exception ex){
            system.debug('>>> RetrieveParticipantsList exception: ' + ex.getMessage());
        }
        return participantsList;
    }
    
    /**
     *  @name        - contactChanged()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - get the selected contact name and email.
     *  @U.S         - PLR-1444.
     */
    /*
    public void contactChanged()
    {
        this.EventToSummarize.ContactName__c = '';
        this.EventToSummarize.ContactEmail__c = '';
        if(this.EventToSummarize.WhoId != null && String.valueOf(this.EventToSummarize.WhoId).startsWith('003')) {
            Contact con = [select id, Name, Email from Contact where Id =: this.EventToSummarize.WhoId];
            this.EventToSummarize.ContactName__c = con.Name;
            this.EventToSummarize.ContactEmail__c = con.Email;
        }
    }
    */
    
    /**
     *  @name        - UpdateTaskCreationSection()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - Update the page sections that must appear or be hidden.
     *  @U.S         - PLR-976.
     */
    private void UpdateTaskCreationSection(Boolean newValue)
    {
        this.DisplayTaskCreation = newValue;
    }

    /**
     *  @name        - GoBack()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - Navigates back to the Event page.
     *  @U.S         - PLR-976.
     */
    public PageReference GoBack()
    {
        return new PageReference('/' + this.EventToSummarize.Id);
    }

    /**
     *  @name        - CreateTask()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - Open the new task section to create a new task.
     *  @U.S         - PLR-976.
     */
    public void CreateTask()
    {
      UpdateTaskCreationSection(true);
      this.NewRelatedTask = (Task)Task.sObjectType.newSObject(this.RecordTypeID, true);
      //this.NewRelatedTask = new Task();
      //this.NewRelatedTask.RecordTypeId = this.RecordTypeID;
      this.NewRelatedTask.WhoId = EventToSummarize.WhoId;
      this.NewRelatedTask.WhatId = EventToSummarize.WhatId;
    }

    /**
     *  @name        - Cancel()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - Cancel the new task creation closing the new task section.
     *  @U.S         - PLR-976.
     */
    public void Cancel()
    {
        UpdateTaskCreationSection(false);
    }

    /**
     *  @name        - SaveTask()
     *  @param       - N.A.
     *  @return      - N.A.
     *  @description - Saves the Task "related" to the Event.
     *                      The task is "related" to the Event using 2 custom text fields (EventID__c, EventName__c) containing the Event Id and the Event Name.
     *  @U.S         - PLR-976.
     */
    public void SaveTask()
    {
        try{
            this.NewRelatedTask.EventID__c      = this.EventToSummarize.id;
            this.NewRelatedTask.EventName__c    = this.EventToSummarize.Subject;
            this.NewRelatedTask.WhoId           = (this.NewRelatedTask.WhoId==null)? this.EventToSummarize.WhoId:this.NewRelatedTask.WhoId;
            this.NewRelatedTask.WhatId          = (this.NewRelatedTask.WhatId==null)? this.EventToSummarize.WhatId:this.NewRelatedTask.WhatId;
            insert this.NewRelatedTask;
            
            UpdateTaskCreationSection(false);
            RetrieveRelatedTaskList();
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while adding the task!'));
        }
   } 

   
    /**
    *   Saves the Event..    
    *   Author Jonathan Cohen
    *   @method SaveEvent
    *   @param {} 
    *   @return {} 
    */
    public void SaveEvent()
    {
        this.EventToSummarize.Customer_Participants__c = '';
        this.EventToSummarize.CustomerParticipantsEmails__c = '';
        this.EventToSummarize.CustomerParticipantsType__c = '';
        this.EventToSummarize.CustomerParticipantsSubType__c = '';
        this.EventToSummarize.CellcomParticipants__c = '';
        this.EventToSummarize.CellcomParticipantsEmail__c = '';
        this.EventToSummarize.CellcomParticipantsType__c = '';
        this.EventToSummarize.CellcomParticipantsSubType__c = '';
        this.EventToSummarize.SubcontractorsParticipants__c = '';
        this.EventToSummarize.SubcontractorsParticipantsEmail__c = '';
        this.EventToSummarize.SubcontractorsParticipantsType__c = '';
        this.EventToSummarize.SubcontractorsParticipantsSubType__c = '';
        this.EventToSummarize.AddtionalParticipants__c = '';
        this.EventToSummarize.AddtionalParticipantsEmails__c = '';
        this.EventToSummarize.AdditionalParticipantsType__c = '';
        this.EventToSummarize.AdditionalParticipantsSubType__c = '';
        this.EventToSummarize.EventStatus__c = 'Took Place';
        
        //add the customer participants names and emails to the event
        FillEventParticipants(participantsList);
        FillEventParticipants(additionalParticipantsList);
        
        system.debug('>>> additionalParticipantsList: ' + additionalParticipantsList);
        //add the additional participants names and emails to the event
        for(EventParticipant p : additionalParticipantsList){
            this.EventToSummarize.AddtionalParticipants__c += (String.isNotBlank(p.participantName) ? p.participantName : 'null') + ';';
            this.EventToSummarize.AddtionalParticipantsEmails__c += (String.isNotBlank(p.participantEmail) ? p.participantEmail : 'null') + ';';
            this.EventToSummarize.AdditionalParticipantsType__c += (String.isNotBlank(p.tempEvent.ParticipantsType__c) ? p.tempEvent.ParticipantsType__c : 'null') + ';';
            this.EventToSummarize.AdditionalParticipantsSubType__c += (String.isNotBlank(p.tempEvent.ParticipantsSubType__c) ? p.tempEvent.ParticipantsSubType__c : 'null') + ';';
        }
        
        try{
            update this.EventToSummarize;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.EventSavedSuccessfully));
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EventSavedError));
        }
    }
    
    /**
    *   Fill the event Participants fields    
    *   Author MG
    *   @method SaveEvent
    *   @param {} 
    *   @return {} 
    */
    public void FillEventParticipants(list<EventParticipant> pList)
    {
        for(EventParticipant p : pList){
            if(p.tempEvent.ParticipantsType__c == 'Contact'){
                this.EventToSummarize.Customer_Participants__c += (String.isNotBlank(p.participantName) ? p.participantName : 'null') + ';';
                this.EventToSummarize.CustomerParticipantsEmails__c += (String.isNotBlank(p.participantEmail) ? p.participantEmail : 'null') + ';';
                this.EventToSummarize.CustomerParticipantsType__c += (String.isNotBlank(p.tempEvent.ParticipantsType__c) ? p.tempEvent.ParticipantsType__c : 'null') + ';';
                this.EventToSummarize.CustomerParticipantsSubType__c += (String.isNotBlank(p.tempEvent.ParticipantsSubType__c) ? p.tempEvent.ParticipantsSubType__c : 'null') + ';';
            }
            else if(p.tempEvent.ParticipantsType__c == 'Cellcom Employee'){
                this.EventToSummarize.CellcomParticipants__c += (String.isNotBlank(p.participantName) ? p.participantName : 'null') + ';';
                this.EventToSummarize.CellcomParticipantsEmail__c += (String.isNotBlank(p.participantEmail) ? p.participantEmail : 'null') + ';';
                this.EventToSummarize.CellcomParticipantsType__c += (String.isNotBlank(p.tempEvent.ParticipantsType__c) ? p.tempEvent.ParticipantsType__c : 'null') + ';';
                this.EventToSummarize.CellcomParticipantsSubType__c += (String.isNotBlank(p.tempEvent.ParticipantsSubType__c) ? p.tempEvent.ParticipantsSubType__c : 'null') + ';';
            }
            else if(p.tempEvent.ParticipantsType__c == 'Manufacturer' || p.tempEvent.ParticipantsType__c == 'Integrator' || p.tempEvent.ParticipantsType__c == 'Distributor'){
                this.EventToSummarize.SubcontractorsParticipants__c += (String.isNotBlank(p.participantName) ? p.participantName : 'null') + ';';
                this.EventToSummarize.SubcontractorsParticipantsEmail__c += (String.isNotBlank(p.participantEmail) ? p.participantEmail : 'null') + ';';
                this.EventToSummarize.SubcontractorsParticipantsType__c += (String.isNotBlank(p.tempEvent.ParticipantsType__c) ? p.tempEvent.ParticipantsType__c : 'null') + ';';
                this.EventToSummarize.SubcontractorsParticipantsSubType__c += (String.isNotBlank(p.tempEvent.ParticipantsSubType__c) ? p.tempEvent.ParticipantsSubType__c : 'null') + ';';
            }
            else{
                /*TODO*/
                //TODO: No type selected, throw error
            }
        }
    }

    public void AddAdditionalParticipants()
    {
       additionalParticipantsList.add(new EventParticipant());
    }

    public void removeRowFromAddtionalParticipants()
    {
       additionalParticipantsList.remove(rowToRemove-1);
    }
    
    public void removeRowFromParticipants()
    {
       participantsList.remove(rowToRemove-1);
    }

    /**
    *   Add new participants names to the adequate participants string (List).    
    *   Author Jonathan Cohen
    *   @method AddParticipantMgmt
    *   @param {String} 
    *   @return {String} 
    */
    /*
    public String AddParticipantMgmt(String participantCategory, list<String> particEmailList)
    {                    
        if (this.TempEvent.SecondaryOwner__c != null) {
            User participantUser = [SELECT Id, Name, Email FROM User WHERE Id = :this.TempEvent.SecondaryOwner__c LIMIT 1];
            //this.UsersParticipantsEmailList.add(participantUser.Email);
            particEmailList.add(participantUser.Email);

            if(participantCategory == Null || participantCategory == ''){
                participantCategory = participantUser.Name;
            }
            else{
                participantCategory += participantUser.Name;
            }

            participantCategory = removeDuplicatesFromString(participantCategory);
            participantCategory += ';';
            
            }
        
        
        return participantCategory;
    }
	*/
   
    /**
    *   The method receives a string ; separated and removes the duplicates values.
    *   In - String ; separated. return- String without duplicates values.
    *   Author Jonathan Cohen
    *   @method removeDuplicatesFromString
    *   @param {String} 
    *   @return {String} 
    */
    /*
    private String removeDuplicatesFromString(String strToVerify)
    {
        String strWithoutDuplicates = strToVerify;

        if(strToVerify != Null)
        {
            List<String> valuesList = new List<String>();
            valuesList.addAll(strToVerify.split(';'));

            Set<String> valuesSet = new Set<String>(valuesList);
            strWithoutDuplicates = string.join(New List<String>(new Set<String>(valuesSet)),';');
        }

        return strWithoutDuplicates;
    }
	*/
     
    /**
    *   Send an email summarizing the event to:
    *                   - The Event Owner and the Event related contact as TO addresses
    *                   - The selected internal participants as CC addresses.
    *   Author Jonathan Cohen
    *   @method SendEventSummaryEmail
    *   @param {} 
    *   @return {} 
    */ 
    public void SendEventSummaryEmail()
    {
        try{
            EmailTemplate templateId     = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :EventEmailTemplateId];
        
            List<String> toaddressesList = new List<String>();
            toaddressesList.Add(this.EventToSummarize.Owner.Email);
            
            //add participants to the To list
            for(EventParticipant p : participantsList)
                if(p.participantSendEmail && String.isNotBlank(p.participantEmail))
                    toaddressesList.add(p.participantEmail);
                    
            //add the additional participants to the To list
            for(EventParticipant p : additionalParticipantsList)
                if(p.participantSendEmail && String.isNotBlank(p.participantEmail))
                    toaddressesList.add(p.participantEmail);
            SaveEvent();
            
            List<Messaging.SingleEmailMessage> mailsToSendList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
            mailToSend.setTemplateID(templateId.Id); 
            mailToSend.setSaveAsActivity(false);
            mailToSend.setToAddresses(toaddressesList);
            //mailToSend.setCcAddresses(this.participantsEmailList);
            mailToSend.setTargetObjectId(this.EventToSummarize.OwnerID);
            mailToSend.setWhatId(this.EventToSummarize.Id);
            mailsToSendList.add(mailToSend);
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailsToSendList);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.EventSentSuccessfully));
            
            logEventSummaryEmail();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.EventLoggedSuccessfully));
            
            result = true;
        }
        catch(Exception e){
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EventEmailSentError + '<br>Message: ' + e.getMessage()));
        }
    }
    
    public void logEventSummaryEmail(){
        //Create the meeting summary log task
        Task t = new Task();
        t.RecordTypeId = [select Id from RecordType where SobjectType = 'Task' AND DeveloperName = :TaskMeetingSummaryRecordTypeName limit 1].Id;
        t.Status = 'TST21';
        t.EventID__c = this.EventToSummarize.Id;
        t.EventName__c = this.EventToSummarize.Subject;
        t.ActivityDate = Date.today();
        t.Subject = this.EventToSummarize.Subject;
        t.OwnerId = this.EventToSummarize.OwnerID;
        t.WhoId = this.EventToSummarize.WhoId;
        t.WhatId = this.EventToSummarize.WhatId;
        t.Related_Products__c = this.EventToSummarize.Related_Products__c;
        t.Customer_Participants__c = this.EventToSummarize.Customer_Participants__c;
        t.CustomerParticipantsEmails__c = this.EventToSummarize.CustomerParticipantsEmails__c;
        t.CustomerParticipantsType__c = this.EventToSummarize.CustomerParticipantsType__c;
        t.CustomerParticipantsSubType__c = this.EventToSummarize.CustomerParticipantsSubType__c;
        t.CellcomParticipants__c = this.EventToSummarize.CellcomParticipants__c;
        t.CellcomParticipantsEmail__c = this.EventToSummarize.CellcomParticipantsEmail__c;
        t.CellcomParticipantsType__c = this.EventToSummarize.CellcomParticipantsType__c;
        t.CellcomParticipantsSubType__c = this.EventToSummarize.CellcomParticipantsSubType__c;
        t.SubcontractorsParticipants__c = this.EventToSummarize.SubcontractorsParticipants__c;
        t.SubcontractorsParticipantsEmail__c = this.EventToSummarize.SubcontractorsParticipantsEmail__c;
        t.SubcontractorsParticipantsType__c = this.EventToSummarize.SubcontractorsParticipantsType__c;
        t.SubcontractorsParticipantsSubType__c = this.EventToSummarize.SubcontractorsParticipantsSubType__c;
        t.AddtionalParticipants__c = this.EventToSummarize.AddtionalParticipants__c;
        t.AddtionalParticipantsEmails__c = this.EventToSummarize.AddtionalParticipantsEmails__c;
        t.AdditionalParticipantsType__c = this.EventToSummarize.AdditionalParticipantsType__c;
        t.AdditionalParticipantsSubType__c = this.EventToSummarize.AdditionalParticipantsSubType__c;
        t.Description =  Label.MeetingDate + ': ' + Date.valueOf(this.EventToSummarize.Startdatetime).format() + '\n\n';
        t.Description += Label.Comment + ':\n' + this.EventToSummarize.Description;
        if(!RelatedTaskList.isEmpty()){
            t.Description += '\n\n\n' + Label.TasksDetails + ':\n\n';
            for(Integer i=0; i < RelatedTaskList.size(); i++){
                t.Description += string.valueOf(i+1) + '.\n';
                t.Description += Label.Description + ': ' + RelatedTaskList[i].Description + '\n\n';
                t.Description += Label.DueDate + ': ' + RelatedTaskList[i].ActivityDate + '\n\n';
                t.Description += Label.AssignTo + ': ' + RelatedTaskList[i].Owner.Name + '\n\n\n';
            }
        }
        //Type
        insert t;
        
        //Adding a Link post
        FeedItem post = new FeedItem();
        post.ParentId = this.EventToSummarize.Id;
        post.Title = Label.LogEventSummaryEmail;
        post.LinkUrl = getURL() + '/' + t.Id;
        post.Type = 'LinkPost';
        insert post;
    }
    
    
    private String getURL() {
        return String.format(
          'https://{0}.salesforce.com',
          new String[]{
            URL.getSalesforceBaseUrl().getHost().substringAfter('.').substringBefore('.')
          });
    }
}