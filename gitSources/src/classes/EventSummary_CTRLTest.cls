/**
*   Test class for all Event Summary process
*   
*   @class EventSummary_CTRLTest
*   author Eric Fishman
*   @module TestClass
*   @constructor
*/
@isTest
private class EventSummary_CTRLTest {

    /**
    * Method to prepare relevant data
    * Eric Fishman
    * @method setupTestData 
    * @return {Void}*     
    * @module Lead
    */
    @testSetup static void setupTestData(){
        
        Event event = TestFactory.testCreateEvent('Test Event');
        event.Customer_Participants__c = 'cp1;cp2';
        event.CustomerParticipantsEmails__c = 'cp1@email.com;cp2@email.com';
        event.CustomerParticipantsType__c = 'Contact;Contact';
        event.CustomerParticipantsSubType__c = 'null;null';
        event.CellcomParticipants__c = 'celp1,celp2';
        event.CellcomParticipantsEmail__c = 'celp1@email.com;celp2@email.com';
        event.CellcomParticipantsType__c = 'Cellcom Employee;Cellcom Employee';
        event.CellcomParticipantsSubType__c = 'null;null';
        event.SubcontractorsParticipants__c = 'scp1,scp2';
        event.SubcontractorsParticipantsEmail__c = 'scp1@email.com;scp2@email.com';
        event.SubcontractorsParticipantsType__c = 'Manufacturer;Manufacturer';
        event.SubcontractorsParticipantsSubType__c = 'null;null';
        event.AddtionalParticipants__c = 'ap1;ap2';
        event.AddtionalParticipantsEmails__c = 'ap1@email.com;ap2@email.com';
        event.AdditionalParticipantsType__c = 'Integrator;Distributor';
        event.AdditionalParticipantsSubType__c = 'null;null';
        insert event;
        Contact contact = TestFactory.testCreateContactAndAccountWithCellExtID();
        
        EventRelation er = new EventRelation(EventId = event.Id, RelationId = contact.Id);
        insert er;
    }

     /**
    *   Method for testing eventSummaryPage
    *   Author Eric Fishman
    *   taskid PLR-976
    *   @method eventSummarPageTest    
    *   @return {Void}*
    *   @module Lead
    */    
    static testMethod void eventSummaryPageTest() {
        Event eventTest = [select id, OwnerId, subject from Event where subject='Test Event' limit 1];
        PageReference pageRef = Page.EventSummary_VF;
        pageRef.getParameters().put('eventID', eventTest.id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
            EventSummary_CTRL controller = new EventSummary_CTRL(); 
            controller.eventToSummarize.Subject = 'test';                       
            controller.SaveEvent();                             
        Test.stopTest();
        // Check event saved succesfully
        Event eventResult = [select id, OwnerId, subject from Event where id =: eventTest.Id limit 1];        
        system.assertEquals('test', eventResult.Subject);
        
    }
    
    /**
    *   Method for testing eventSummaryPageCancelTest
    *   Author Eric Fishman
    *   taskid PLR-976
    *   @method eventSummaryPageCancelTest    
    *   @return {Void}*
    *   @module Lead
    */    
    static testMethod void eventSummaryPageCancelTest() {
        Event eventTest = [select id, subject from Event where subject='Test Event' limit 1];
        PageReference pageRef = Page.EventSummary_VF;
        pageRef.getParameters().put('eventID', eventTest.id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
            EventSummary_CTRL controller = new EventSummary_CTRL(); 
            controller.Cancel();
            system.assertEquals(false, controller.DisplayTaskCreation);
                        
            controller.GoBack();   
        Test.stopTest();        
    }
    
    
        /**
    *   Method for testing creating new Task
    *   Author Eric Fishman
    *   taskid PLR-976
    *   @method eventSummaryPageTaskTest    
    *   @return {Void}*
    *   @module Lead
    */    
    static testMethod void eventSummaryPageTaskTest() {
        Event eventTest = [select id, OwnerID from Event where subject='Test Event' limit 1];
        PageReference pageRef = Page.EventSummary_VF;
        pageRef.getParameters().put('eventID', eventTest.id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
            EventSummary_CTRL controller = new EventSummary_CTRL();
            controller.CreateTask();            
            controller.newRelatedTask.Subject = 'test Task';
            controller.newRelatedTask.Status = 'status';
            //controller.newRelatedTask.OwnerId = eventTest.OwnerID;
            controller.newRelatedTask.Priority = 'Normal';
            controller.SaveTask();
            
            system.assert(controller.NewRelatedTask != null);           
            system.assertEquals(controller.RelatedTaskList.size() == 1 , true);
        Test.stopTest();
        
    }
    
    
    /**
    *   Method for testing eventSummary vf Template
    *   Author Eric Fishman
    *   taskid PLR-976
    *   @method eventSummarCMPTest    
    *   @return {Void}*
    *   @module Lead
    */    
    static testMethod void eventSummaryCMPTest() {
        Event eventTest = [select id, OwnerID from Event where subject='Test Event' limit 1];
        Contact contact = [select Id, Name, email from Contact limit 1];
        PageReference pageRef = Page.EventSummary_VF;
        pageRef.getParameters().put('eventID', eventTest.id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
            EventSummary_CTRL controller = new EventSummary_CTRL();
            //controller.eventToSummarize.Cellcom_Manager_Participants__c = eventTest.OwnerID;            
            controller.TempEvent.SecondaryOwner__c = eventTest.OwnerID;
            //controller.AddManagerParticipant();
            //controller.AddSalesParticipant();
            //controller.AddPreSalesParticipant();
            //controller.AddIntegratorParticipant();
            //controller.AddSupplierParticipant();
            //controller.AddMarketingParticipant();
            //controller.AddCustomerParticipants();
            controller.AddAdditionalParticipants();
            controller.rowToRemove = 1;
            controller.removeRowFromParticipants();
            //controller.removeRowFromCustomerParticipants();
            controller.rowToRemove = 1;
            controller.removeRowFromAddtionalParticipants();
            controller.eventToSummarize.WhoId = contact.Id;
            //controller.contactChanged();
            controller.SendEventSummaryEmail();
            controller.logEventSummaryEmail();
         Test.stopTest();
    }
    
    
    /**
    *   Method for testing EmailSummary_CMP_CTRL
    *   Author Eric Fishman    *   
    *   @method eventTemplateTest    
    *   @return {Void}
    *   @module Lead
    */    
    static testMethod void eventTemplateTest() {
        Event eventTest = [select id, OwnerID, subject, RecordTypeID from Event where subject='Test Event' limit 1];
        
        PageReference pageRef = Page.EventSummary_VF;
        pageRef.getParameters().put('eventID', eventTest.id);
        Test.setCurrentPage(pageRef);
                
        Test.startTest();
         
        EventSummary_CTRL controller = new EventSummary_CTRL(); 
        controller.CreateTask();                    
        controller.newRelatedTask.Subject = 'test Task';
        controller.newRelatedTask.Status = 'status';
        //controller.newRelatedTask.OwnerId = eventTest.OwnerID;
        controller.newRelatedTask.Priority = 'Normal';
        
        controller.SaveTask();      
        
            EmailSummary_CMP_CTRL controllerCMP = new EmailSummary_CMP_CTRL();
                            
            controllerCMP.eventId = eventTest.Id;
            List<Task> taskList  = controllerCMP.getRetrieveRelatedTaskListVF();
            system.debug('>>> taskList' + taskList.size() );
            system.assertEquals(taskList.size() ==1 , true);               
        Test.stopTest();
        
    }
    
    
}