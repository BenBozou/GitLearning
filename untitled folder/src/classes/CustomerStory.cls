/**
 * Class for Customer Story Section.
 * Retrieving data from legacy sysems as well as salesforce data (Task\Lead\)
 * Gili Yehuda & Ilana Brodsky
 * taskid PLR - 1045
 * @class CustomerStory
 * @module 360
 */
/**
     *   Callout to Legacy systems through the OSB to Customer Story + adding data from salesforce
     *   author Gili Yehuda
     *
     *   @method getCustomerStory
     *   @param  {map<String, object>} inputMap
     *   @param  {map<String, object>} outMap
     *   @param  {map<String, object>} options
     *   @return {Boolean}
*/
global with sharing class CustomerStory implements vlocity_cmt.VlocityOpenInterface2 {

    //set of records Ids that need to hide the link button for them
    private static set<Id> s_hideButtonIds = new set<Id>();

    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        outMap.put('processError', 'false');

        try {
            if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getCustomerStory')) {
                return getCustomerStory(inputMap, outMap, options);
            }

        } catch (Exception e) {
            outMap.put('EXCEPTION',methodName + ':' + e.getMessage() + ':' + e.getStackTraceString());
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.ErrCardIntegration.replace('{0}', methodName));
        }

        return true;
    }

    
    private static Map < String, String > getMapReplacedFields(Boolean description, Boolean status, Boolean subscriber, Boolean recordtypeName, 
                                                                Boolean concateBanPSID, Boolean subject, Boolean activityDate, Boolean vlocityComments) {
        Map < String, String > fields_Map = new Map < String, String >{
        'CreatedDate' => 'open_date',
        'LastModifiedDate' => 'update_date',
        'CreatedBy.ReportRoleName__c' => 'unit',
        'Id' => 'Id',
        'CreatedBy.Name' => 'user_name'};
         
         if(description) fields_Map.put('Description', 'csm_note'); 
         if(status) fields_Map.put('Status', 'status');
         if(subscriber) fields_Map.put('Subscriber__c', 'subscriber_no');
         if(recordtypeName) fields_Map.put('Recordtype.Name', 'category');
         if(concateBanPSID) fields_Map.put('concateBanPSID__c', 'psid');
         if(subject) fields_Map.put('Subject', 'type');
         if(activityDate) fields_Map.put('activityDate', 'detail');
         //if(vlocityComments) fields_Map.put('vlocity_cmt__Comments__c', 'csm_note');
         if(vlocityComments) fields_Map.put('LongDescription__c', 'csm_note');
    
         return fields_Map;
    }
    
    private static list<Account> getAccountsWithLeadsAndBiilingAccounts(String inputAccId, DateTime StartDate, String inputRecordTypeName) {
       
        if (inputRecordTypeName == 'Consumer') {
            return [SELECT Id, Name, BillingAddress, toLabel(Segment__c), RecordType.DeveloperName, toLabel(RecordType.Name), ConsumerType__c, Phone,BANPSID__c,CellcomExternalID__c,CELL_Ind__c, NETV_Ind__c,
                    (SELECT Name, AccountNumber, RecordType.DeveloperName, CellcomExternalID__c,CELL_Ind__c, NETV_Ind__c, BANPSID__c,NVID__c, BillingStreet, BillingCity, BillingPostalCode__c, toLabel(vlocity_cmt__Status__c) 
                    FROM ChildAccounts WHERE RecordType.DeveloperName = 'Billing'),
                    (SELECT Id, name, CreatedBy.Name, CreatedDate, Description, LeadRecordType__c,toLabel(Recordtype.Name),concateBanPSID__c,
                    LastModifiedDate, OwnerId, Owner.Name, CreatedBy.ReportRoleName__c, Subscriber__c, tolabel(Status), AgentShortDet__c,RecordType.DeveloperName
                    FROM Leads__r where  RecordType.DeveloperName = 'Offer' and LastModifiedDate >: StartDate   and Status != null
                    and Status != 'LST01'),
                    (SELECT Id, tolabel(Status), tolabel(SubSubject__c), CreatedBy.Name,RecordTypeId, CreatedDate,ActivityDate,toLabel(Recordtype.Name),
                    LastModifiedDate, OwnerId, CreatedBy.ReportRoleName__c, Owner.Name, Subject,Type,RecordType.DeveloperName FROM Tasks
                    WHERE LastModifiedDate >: StartDate and recordType.DeveloperName='PersonalTask')
                    FROM Account WHERE Id =: inputAccId];
        }       
         
         
         return [SELECT Id, Name, BillingAddress, toLabel(Segment__c), RecordType.DeveloperName, toLabel(RecordType.Name), ConsumerType__c, Phone,BANPSID__c,CellcomExternalID__c,CELL_Ind__c, NETV_Ind__c,
                (SELECT Name, AccountNumber, RecordType.DeveloperName, CellcomExternalID__c,CELL_Ind__c, NETV_Ind__c, BANPSID__c,NVID__c, BillingStreet, BillingCity, BillingPostalCode__c, toLabel(vlocity_cmt__Status__c) 
                FROM ChildAccounts WHERE RecordType.DeveloperName = 'Billing'),
                (SELECT Id, name, CreatedBy.Name, CreatedDate, Description, LeadRecordType__c,toLabel(Recordtype.Name),concateBanPSID__c,
                LastModifiedDate, OwnerId, Owner.Name, CreatedBy.ReportRoleName__c, Subscriber__c, tolabel(Status), AgentShortDet__c,RecordType.DeveloperName
                FROM Leads__r where  RecordType.DeveloperName = 'Offer' and LastModifiedDate >: StartDate   and Status != null
                and Status != 'LST01'),
                (SELECT Id, CreatedBy.Name, CreatedDate,ActivityDate, LastModifiedDate,toLabel(Recordtype.Name), OwnerId, Owner.Name, CreatedBy.ReportRoleName__c,
                tolabel(Subject),tolabel(Type),RecordType.DeveloperName FROM Events
                WHERE LastModifiedDate >: StartDate)
                FROM Account WHERE Id =: inputAccId];       
    }
    
    
    
    private static Boolean getCustomerStory(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        String inputAccId = (String) inputMap.get('accountId');
        String inputContId = (String) inputMap.get('contactId');
        String inputRecordTypeName = (inputMap.get('recordTypeName') != null && inputMap.get('recordTypeName') != '') ? (String)inputMap.get('recordTypeName') : '';
         
        if (String.isEmpty(inputAccId) || String.isEmpty(inputContId)) {
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
        }

        Map < String, String > leadReplacedFeildsMap = getMapReplacedFields(true,true,true,true,true,false,false,false);
        Map < String, String > taskReplacedFeildsMap = getMapReplacedFields(false,true,false,true,false,false,false,false);
        Map < String, String > eventReplacedFeildsMap = getMapReplacedFields(false,false,false,true,false,true,true,false);
        Map < String, String > interactionReplacedFeildsMap = getMapReplacedFields(false,false,false,false,false,false,false,true);
        
        String crmVariable = (inputRecordTypeName == 'Consumer' ? 'CustomerStoryInMonths' : 'BusinessCustomerStoryInMonths');
        //String months = CustomMetadataTypeService.getCrmVariable('CustomerStoryInMonths');
        String months = CustomMetadataTypeService.getCrmVariable(crmVariable);
        DateTime StartDate = Date.Today().addMonths(-Integer.valueOf(months));
        
        Contact con = AccountSidebarCardsService.getContact(inputContId);
        
        //3 - Get Lead records
        List<Lead> newLeads = new List<lead>();

        //map of lead per name to group by name subscribers leads
        map<String, list<lead>> m_nameLeads = new map<String, list<lead>>();
        
        //1 - Get Account with related Leads and Billing Accounts
        list<Account> accWithLeads_List = getAccountsWithLeadsAndBiilingAccounts(inputAccId, StartDate, inputRecordTypeName);
                                                    
        if (accWithLeads_List.isEmpty() || con == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);        
        }
       
        Account accWithLeads =  accWithLeads_List[0];  
        system.debug('accWithLeads ++'+accWithLeads);

        for(Lead lead : accWithLeads.Leads__r){

            //For consumer show all leads, for business show in regulae mode only leads with subscriber '0000000000', other leads for business will be grouped by name
            if(accWithLeads.recordType.DeveloperName == 'Consumer'|| (accWithLeads.recordType.DeveloperName == 'Business' && lead.Subscriber__c == '0000000000')){
                newLeads.add(lead);
            }
            else{
                if(!m_nameLeads.containsKey(lead.Name)){
                    m_nameLeads.put(lead.name, new list<lead>());
                    newLeads.add(lead);
                }

                m_nameLeads.get(lead.name).add(lead);
                s_hideButtonIds.add(lead.Id);
            }
        }

        String LeadJson = replacefieldsMap(newLeads, leadReplacedFeildsMap, 'lead');

        List<Task> newTasks = (!accWithLeads.Tasks.isEmpty()) ? accWithLeads.Tasks : new List<Task>();
        List<Event> newEvents = (!accWithLeads.Events.isEmpty()) ? accWithLeads.Events : new List<Event>();
         
        String TaskJson = replacefieldsMap(newTasks, taskReplacedFeildsMap, 'task');
        String  EventJson = replacefieldsMap(newEvents, eventReplacedFeildsMap, 'event');
        //4 - Get customer interaction records
        List<vlocity_cmt__CustomerInteraction__c> newInteractions = new List<vlocity_cmt__CustomerInteraction__c>();
        String leadsId=accWithLeads.Id;
        for(vlocity_cmt__CustomerInteraction__c customerInteraction :
                    [ SELECT Id, CreatedBy.Name, CreatedBy.ReportRoleName__c, CreatedDate,LastModifiedDate,Owner.Name,vlocity_cmt__Comments__c,LongDescription__c,
                      tolabel(Subject__c), tolabel(vlocity_cmt__Status__c), tolabel(InteractionSubject__c),vlocity_cmt__AccountId__c,
                      (select id, vlocity_cmt__Data__c from vlocity_cmt__VlocityTrackingEntries__r)
                      FROM vlocity_cmt__CustomerInteraction__c where vlocity_cmt__AccountId__c =:leadsId
                      and LastModifiedDate >: StartDate and vlocity_cmt__Status__c='Completed']){

            if(!customerInteraction.vlocity_cmt__VlocityTrackingEntries__r.isEmpty() || customerInteraction.LongDescription__c!=null)
                newInteractions.add(customerInteraction);
                system.debug('customerInteraction=> '+customerInteraction);
                system.debug('accWithLeads.Id=>> '+accWithLeads.Id);
        }

        String InteractionJson = replacefieldsMap(newInteractions, interactionReplacedFeildsMap, 'customerInteraction');
         system.debug('InteractionJson=> '+InteractionJson);
 
        IndicatorsCalloutBuilder.CustomerStoryRequestBuilder curRequest = new IndicatorsCalloutBuilder.CustomerStoryRequestBuilder(accWithLeads.RecordType.DeveloperName, months);
        curRequest.CustInfo.setBanPsIds(accWithLeads, con);
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00715', outMap, Label.msgSrvErr715, Label.msgSrvWarn715, null);

        request.body.setRequestNode(curRequest);
        Map < String, Object > response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00715_osb_customerstorysection_k2view');

        Boolean errorInd = AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue);

        Map < String, Object > Body_Map = new Map < String, Object > ();
        Map < String, Object > response_Map = new Map < String, Object > ();
        Map < String, Object > cases_Map = new Map < String, Object > ();
        List < Object > caseDataList = new List < Object > ();

        try {
            Body_Map = (Map < String, Object > ) response.get('Body');
            response_Map = (Map < String, Object > ) Body_Map.get('Response');
            cases_Map = (Map < String, Object > ) response_Map.get('Cases');
            caseDataList = (List < Object > ) cases_Map.get('CaseData');

        } catch (Exception ex) {
            response = new Map < String, Object > {
                'Body' => new Map < String,
                Object > {
                    'Response' => new Map < String,
                    Object > {
                        'Cases' => new Map < String,
                        Object > {
                            'CaseData' => new List < Object > ()
                        }
                    }
                }
            };

            Body_Map = (Map < String, Object > ) response.get('Body');
            response_Map = (Map < String, Object > ) Body_Map.get('Response');
            cases_Map = (Map < String, Object > ) response_Map.get('Cases');
            caseDataList = (List < Object > ) cases_Map.get('CaseData');
        }

        mergeLists(caseDataList, TaskJson);
        mergeLists(caseDataList, EventJson);
        mergeLists(caseDataList, LeadJson);
        mergeLists(caseDataList, InteractionJson);

        String arr = Json.serialize(caseDataList);
        system.debug('caseDataList '+caseDataList);
        outMap.put('data', response);
        return true;
    }

    private static String replacefieldsMap(List < sObject > objectList, Map < String, String > replacedFeildsMap, String objType) {
        List < Map < string, string >> newList = new List < Map < string, string >> ();
        for (sObject so: objectList) {
            Map < string, string > newObj = new Map < String, String > ();
            newObj.put('source', 'salesforce');
            newObj.put('showLink', s_hideButtonIds.contains(String.valueOf(so.get('Id'))) ? 'N' : 'Y');

            if(objType == 'customerInteraction'){
                newObj.put('category', 'תיעוד שיחה');//Customer Interaction
                String subjects = String.valueOf(so.get('InteractionSubject__c'));
                newObj.put('type', subjects != null ? subjects.replace(';', ', ') : '');

                //For interaction event add as detail concatenation of all the automatic updates
                String interactionDetails = '';

                for(vlocity_cmt__VlocityTrackingEntry__c trackingEntry : so.getSObjects('vlocity_cmt__VlocityTrackingEntries__r')){

                    map<string, object> mjson = (Map < String, Object > ) Json.deserializeUntyped(trackingEntry.vlocity_cmt__Data__c);

                    if(mjson!=null && mjson.containsKey('SummaryLabel'))
                        interactionDetails += mjson.get('SummaryLabel') + '<br>';
                }

                newObj.put('detail', interactionDetails);
            }
            else if(objType == 'task'){

                //In Task record add as type concatenation of "Status: X. Subject: Y, SubStatus
                newObj.put('type', Label.CustomerStoryTaskType.replace('{0}', String.valueOf(so.get('Status') !=null ? so.get('Status') : '')).
                                                            replace('{1}', String.valueOf(so.get('Subject') != null ? so.get('Subject') : '')).
                                                            replace('{2}', String.valueOf(so.get('SubSubject__c') != null ? so.get('SubSubject__c') : '')));
                DateTime dueDate = (DateTime) so.get('ActivityDate');

                newObj.put('detail', Label.CustomerStoryTaskDate.replace('{0}', dueDate != null ? (dueDate).format('dd/MM/yyyy') : ''));
            }
            else if(objType == 'lead'){

                newObj.put('type', Label.CustomerStoryLeadType.replace('{0}', String.valueOf(so.get('Status') != null ? so.get('Status') : '')).
                                                            replace('{1}', String.valueOf(so.get('AgentShortDet__c') != null ? so.get('AgentShortDet__c') : '')));
            }


            for (String key: replacedFeildsMap.keySet()) {
                string newField = replacedFeildsMap.get(key);
                sobject currentSobj = so;
                while (key.contains('.')) {
                    Integer indexPoint = key.indexOf('.');
                    string objField = key.substring(0, indexPoint);
                    currentSobj = currentSobj.getSobject(objField);
                    key = key.substring(indexPoint + 1);
                }
                string value = '';
                if (currentSobj != null && currentSobj.get(key) != null) {
                    if (key == 'CreatedDate' || key == 'LastModifiedDate') {
                        value = Datetime.valueOf(currentSobj.get(key)).format('dd/MM/yyyy kk:mm:ss');
                    } else {
                        value = String.valueOf(currentSobj.get(key));
                    }
                }
                newObj.put(newField, value);
            }
            newList.add(newObj);
        }
        return JSON.serialize(newList);

    }
    
    
    
    private static void mergeLists(List < Object > mainList, String innerJson) {
        List < Object > objectList = (List < Object > ) JSON.deserializeUntyped(innerJson);
        for (Object o: objectList) {
            mainList.add(o);
        }
    }
    

}