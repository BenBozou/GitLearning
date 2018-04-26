/**
* Service class for vlocity indicators cards.
* Gili Yehuda
* taskid PLR-137
* @class IndicatorsCardsService
* @module 360
*/
global with sharing class IndicatorsCardsService implements vlocity_cmt.VlocityOpenInterface2
{
    /**
    * Method implemented from interface, that will be called from vlocity card,
    * and will call inner method according to method name.
    * Gili Yehuda
    * taskid PLR-137
    * @method invokeMethod
    * @param {String} methodName
    * @param {Map} inputMap
    * @param {Map} outMap
    * @param {Map} options
    * @return {Boolean} success/failure
    */
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

        System.debug(Logginglevel.INFO, 'IndicatorsCardsService.invokeMethod - methodName: ' + methodName);
        System.debug(Logginglevel.INFO, 'IndicatorsCardsService.invokeMethod - inputMap: ' + inputMap);

        outMap.put('processError', 'false');

        try
        {
            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getLegalDebtDetails')) {
                return getLegalDebtDetails(inputMap, outMap, options);
            }

            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getDeliveryDetails')) {
                return getDeliveryDetails(inputMap, outMap, options);
            }

            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getDeviceInRepairDetails')) {
                return getDeviceInRepairDetails(inputMap, outMap, options);
            }

            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getCellcomBezeqTechVisitsDetails')) {
                return getCellcomBezeqTechVisitsDetails(inputMap, outMap, options);
            }

            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getOpenCloseIssues')) {
                return getOpenCloseIssues(inputMap, outMap, options);
            }

            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getB2CFirstIndicators')) {
                return getB2CFirstIndicators(inputMap, outMap, options);
            }
            
            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getOpenTechSuppEvents')) {
                return getOpenTechSuppEvents(inputMap, outMap, options);
            }

        }
        catch(Exception e) {
            system.debug(Logginglevel.ERROR,'invokeMethod ' + methodName +' ERROR :'+e.getMessage() +' StackTraceString :'+ e.getStackTraceString());
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, e.getMessage() + ':' + e.getStackTraceString());
        }

        return true;
    }

    /**
    * Retrieve Debt and legal details from legacy systems.
    * Send the response back to the card by outMap
    * Gili Yehuda
    * taskid PLR-137
    * @method getLegalDebtDetails
    * @param {Map} inputMap
    * @param {Map} outMap
    * @param {Map} options
    * @return {Boolean} success/failure
    * @static
    */
    private static Boolean getLegalDebtDetails(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

        if(!inputMap.containsKey('accountId')) return false;
        if(!inputMap.containsKey('contactId')) return false;

        String accountId = String.valueOf(inputMap.get('accountId'));
        String inputContId = String.valueOf(inputMap.get('contactId'));

        if( String.isEmpty(accountId) || String.isEmpty(inputContId) ) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
        }

        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getLegalDebtDetails.accountId: '+ accountId);
        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getLegalDebtDetails.contactId: '+ inputContId);

        Account inputAccount = AccountSidebarCardsService.getAccount(accountId);
        Contact inputContact = AccountSidebarCardsService.getContact(inputContId);

        if(inputAccount == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);
        }

        if(inputContId == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountSidebarContact);
        }

        //IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder(inputAccount.RecordType.DeveloperName);
        IndicatorsCalloutBuilder.DebtsLegalRequestBuilder curRequest = new IndicatorsCalloutBuilder.DebtsLegalRequestBuilder(inputAccount.RecordType.DeveloperName, 'false','false','false','false','true','true');
        curRequest.CustInfo.ContactIdentifier = inputContact.CellcomExternalID__c;
        curRequest.CustInfo.setBanPsIds(inputAccount,inputContact);

        //OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00668');
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00668', outMap, Label.msgSrvErr668, Label.msgSrvWarn668);
        request.body.setRequestNode(curRequest);

        Map<String,Object> response = request.sendRequestWithErrorCheck('OSB','api/services/rest/osb_retrievecustomerfinancedata_bp_00668');

        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

        outMap.putAll(response);

        return true;

    }

    /**
    * Retrieve Delivery details from legacy systems.
    * Send the response back to the card by outMap
    * Gili Yehuda
    * taskid PLR-132
    * @method getDeliveryDetails
    * @param {Map} inputMap
    * @param {Map} outMap
    * @param {Map} options
    * @return {Boolean} success/failure
    * @static
    */

    private static Boolean getDeliveryDetails(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

        if(!inputMap.containsKey('accountId')) return false;
        if(!inputMap.containsKey('contactId')) return false;

        String accountId = String.valueOf(inputMap.get('accountId'));
        String inputContId = String.valueOf(inputMap.get('contactId'));

        if( String.isEmpty(accountId) || String.isEmpty(inputContId) ) {
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
        }

        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getDeliveryDetails.accountId: '+ accountId);
        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getDeliveryDetails.contactId: '+ inputContId);

        Account inputAccount = AccountSidebarCardsService.getAccount(accountId);
        Contact inputContact = AccountSidebarCardsService.getContact(inputContId);

        if(inputAccount == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);
        }

        if(inputContId == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountSidebarContact);
        }

        List<IndicatorsCalloutBuilder.StatusDateInfoBuilder> statusDateList = new List<IndicatorsCalloutBuilder.StatusDateInfoBuilder>();
        IndicatorsCalloutBuilder.StatusDateInfoBuilder statusB = new IndicatorsCalloutBuilder.StatusDateInfoBuilder('B','OpenDeliveryDaysBack','OpenDeliveryDaysForward',false);
        statusDateList.add(statusB);

        IndicatorsCalloutBuilder.DeviceInRepairCustomerDeliveryRequest curRequest = new IndicatorsCalloutBuilder.DeviceInRepairCustomerDeliveryRequest(statusDateList);

        curRequest.CustInfo.ContactIdentifier = inputContact.CellcomExternalID__c;
        curRequest.CustInfo.setBanPsIds(inputAccount,inputContact);

        //OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00790');
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00790', outMap, Label.msgSrvErr790, Label.msgSrvWarn790);
        request.body.setRequestNode(curRequest);

        Map<String,Object> response = request.sendRequestWithErrorCheck('OSB','api/services/rest/osb_getdeliveriesinfo_sap_00790');

        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

        /*if (response == null) {
            return returnError(outMap, 'processErrorMsg', 'Response issue');
        }*/

        outMap.putAll(response);

        return true;
    }


    /**
    * Retrieve Devices In Repair details from legacy systems.
    * Send the response back to the card by outMap
    * Gili Yehuda
    * taskid PLR-75
    * @method getDeviceInRepairDetails
    * @param {Map} inputMap
    * @param {Map} outMap
    * @param {Map} options
    * @return {Boolean} success/failure
    * @static
    */
    private static Boolean getDeviceInRepairDetails(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

        if(!inputMap.containsKey('accountId')) return false;
        if(!inputMap.containsKey('contactId')) return false;

        String accountId = String.valueOf(inputMap.get('accountId'));
        String inputContId = String.valueOf(inputMap.get('contactId'));

        if( String.isEmpty(accountId) || String.isEmpty(inputContId) ) {
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
        }

        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getDeviceInRepairDetails.accountId: '+ accountId);
        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getDeviceInRepairDetails.contactId: '+ inputContId);

        Account inputAccount = AccountSidebarCardsService.getAccount(accountId);
        Contact inputContact = AccountSidebarCardsService.getContact(inputContId);

        if(inputAccount == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);
        }

        if(inputContId == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountSidebarContact);
        }

        List<IndicatorsCalloutBuilder.StatusDateInfoBuilder> statusDateList = new List<IndicatorsCalloutBuilder.StatusDateInfoBuilder>();
        IndicatorsCalloutBuilder.StatusDateInfoBuilder statusB = new IndicatorsCalloutBuilder.StatusDateInfoBuilder('B','OpenNoteDaysBack','OpenNoteDaysForward', false);
        statusDateList.add(statusB);

        IndicatorsCalloutBuilder.DeviceInRepairCustomerDeliveryRequest curRequest = new IndicatorsCalloutBuilder.DeviceInRepairCustomerDeliveryRequest(statusDateList);

        curRequest.CustInfo.ContactIdentifier = inputContact.CellcomExternalID__c;
        curRequest.CustInfo.setBanPsIds(inputAccount,inputContact);

        //OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00791');
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00791', outMap, Label.msgSrvErr791, Label.msgSrvWarn791);
        request.body.setRequestNode(curRequest);

        Map<String,Object> response = request.sendRequestWithErrorCheck('OSB','api/services/rest/osb_getnotesinfo_sap_00791');

        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

        /*if (response == null) {
            return returnError(outMap, 'processErrorMsg', Label.msgResponseIssue);
        }*/

        outMap.putAll(response);

        return true;

    }


    /**
    * Retrieve Cellcom/Bezeq technician visit scheduled for Infrustructure/TV repair details from legacy systems.
    * Send the response back to the card by outMap
    * Gili Yehuda
    * taskid PLR-79
    * @method getCellcomBezeqTechVisitsDetails
    * @param {Map} inputMap
    * @param {Map} outMap
    * @param {Map} options
    * @return {Boolean} success/failure
    * @static
    */

    private static Boolean getCellcomBezeqTechVisitsDetails(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

        if(!inputMap.containsKey('accountId')) return false;
        if(!inputMap.containsKey('contactId')) return false;

        String accountId = String.valueOf(inputMap.get('accountId'));
        String inputContId = String.valueOf(inputMap.get('contactId'));

        if( String.isEmpty(accountId) || String.isEmpty(inputContId) ) {
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
        }

        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getCellcomBezeqTechVisitsDetails.accountId: '+ accountId);
        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getCellcomBezeqTechVisitsDetails.contactId: '+ inputContId);

        Account inputAccount = AccountSidebarCardsService.getAccount(accountId);
        Contact inputContact = AccountSidebarCardsService.getContact(inputContId);

        if(inputAccount == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);
        }

        if(inputContId == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountSidebarContact);
        }

        List<IndicatorsCalloutBuilder.StatusDateInfoBuilder> statusDateList = new List<IndicatorsCalloutBuilder.StatusDateInfoBuilder>();
        IndicatorsCalloutBuilder.StatusDateInfoBuilder statusO = new IndicatorsCalloutBuilder.StatusDateInfoBuilder('O','OpenTechnicianDaysBack','OpenTechnicianDaysForward',true);
        statusDateList.add(statusO);

        IndicatorsCalloutBuilder.StatusDateInfoBuilder statusC = new IndicatorsCalloutBuilder.StatusDateInfoBuilder('C','CloseTechnicianDaysBack','CloseTechnicianDaysForward',true);
        statusDateList.add(statusC);

        IndicatorsCalloutBuilder.DeviceInRepairCustomerDeliveryRequest curRequest = new IndicatorsCalloutBuilder.DeviceInRepairCustomerDeliveryRequest(statusDateList);

        curRequest.CustInfo.ContactIdentifier = inputContact.CellcomExternalID__c;
        curRequest.CustInfo.setBanPsIds(inputAccount,inputContact);

        //OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00796');
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00796', outMap, Label.msgSrvErr796, Label.msgSrvWarn796);
        request.body.setRequestNode(curRequest);

        Map<String,Object> response = request.sendRequestWithErrorCheck('OSB','api/services/rest/00796_osb_gettechnicianvisitsinfo_bp');
        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;
        /*if (response == null) {
            return returnError(outMap, 'processErrorMsg', Label.msgResponseIssue);
        }*/

        outMap.putAll(response);

        return true;
    }


    /**
     * Retrieve cases and followups from legacy systems.
     * Send the response back to the card by outMap
     * Elad Iflah
     * taskid PLR-645
     * @method getOpenCloseIssues
     * @param {Map} inputMap
     * @param {Map} outMap
     * @param {Map} options
     * @return {Boolean} success/failure
     * @static
     */
    private static Boolean getOpenCloseIssues(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

        if(!inputMap.containsKey('accountId')) return false;
        if(!inputMap.containsKey('contactId')) return false;

        String accountId = String.valueOf(inputMap.get('accountId'));
        String inputContId = String.valueOf(inputMap.get('contactId'));

        if( String.isEmpty(accountId) || String.isEmpty(inputContId) ) {
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
        }

        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getOpenCloseIssues.accountId: '+ accountId);
        system.debug(Logginglevel.INFO,'IndicatorsCardsService.getOpenCloseIssues.contactId: '+ inputContId);

        Account inputAccount = AccountSidebarCardsService.getAccount(accountId);
        Contact inputContact = AccountSidebarCardsService.getContact(inputContId);

        if(inputAccount == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);
        }

        if(inputContId == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountSidebarContact);
        }

        IndicatorsCalloutBuilder.OpenCloseCasesRequest curRequest = new IndicatorsCalloutBuilder.OpenCloseCasesRequest('A');

        curRequest.CustInfo.ContactIdentifier = inputContact.CellcomExternalID__c;
        curRequest.CustInfo.setBanPsIds(inputAccount,inputContact);

        //OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00648');
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00648', outMap, Label.msgSrvErr648, Label.msgSrvWarn648);
        request.body.setRequestNode(curRequest);

        Map<String,Object> response = request.sendRequestWithErrorCheck('OSB','api/services/rest/00648_osb_retrievecustomerfuitems_bp');

        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

        /*if (response == null) {
            return returnError(outMap, 'processErrorMsg', Label.msgResponseIssue);
        }*/

        String requestJSON = JSON.serialize(response);

        IndicatorsCalloutBuilder.osbCasesResponse casesResponse = new IndicatorsCalloutBuilder.osbCasesResponse();

        casesResponse = (IndicatorsCalloutBuilder.osbCasesResponse) System.JSON.deserialize(requestJSON, IndicatorsCalloutBuilder.osbCasesResponse.class);

        IndicatorsCalloutBuilder.casesFlatResponse newResponse = new IndicatorsCalloutBuilder.casesFlatResponse();
        List<IndicatorsCalloutBuilder.flatCaseDetails> flatCaseList = new List<IndicatorsCalloutBuilder.flatCaseDetails>();

        if( casesResponse.Body.Response != null &&
            casesResponse.Body.Response.Open != null &&
            casesResponse.Body.Response.Open.CaseDetails != null ) {

            for( IndicatorsCalloutBuilder.caseDetails openCase : casesResponse.Body.Response.Open.CaseDetails ) {
                IndicatorsCalloutBuilder.flatCaseDetails currCase = new IndicatorsCalloutBuilder.flatCaseDetails();
                currCase.status = 'O';
                //UserProvisioningcurrCase.displayStatus = 'פתוח';
                currCase.displayStatus = openCase.status;
                currCase.fuCode = openCase.fuCode;
                currCase.descriprion = openCase.descriprion;
                currCase.creationDate = openCase.creationDate;
                currCase.subscriberNumber = openCase.subscriberNumber;
                currCase.assignedTo = openCase.assignedTo;
                currCase.taskNumber = openCase.taskNumber;
                currCase.ban = openCase.ban;
                currCase.psid = openCase.psid;
                //currCase.dueDate = openCase.dueDate;
                currCase.billCycle = openCase.billCycle;
                currCase.openedBy = openCase.openedBy;
                currCase.closedBy = openCase.closedBy;                
                currCase.fuText = openCase.fuText;                
                currCase.assignedToTeam = openCase.assignedToTeam;                  
                currCase.creditTotalAmt = openCase.creditTotalAmt;                
                currCase.creditName = openCase.creditName;                                                
                currCase.sourceSystem = openCase.sourceSystem;
                currCase.statusReason = openCase.statusReason;  
                flatCaseList.add(currCase);
            }
        }

        if( casesResponse.Body.Response != null &&
            casesResponse.Body.Response.Close != null &&
            casesResponse.Body.Response.Close.CaseDetails != null ) {

            for( IndicatorsCalloutBuilder.caseDetails closeCase : casesResponse.Body.Response.Close.CaseDetails )
            {
                IndicatorsCalloutBuilder.flatCaseDetails currCase = new IndicatorsCalloutBuilder.flatCaseDetails();
                currCase.status = 'C';
                //currCase.displayStatus = 'סגור';
                currCase.displayStatus = closeCase.status;
                currCase.fuCode = closeCase.fuCode;
                currCase.descriprion = closeCase.descriprion;
                currCase.creationDate = closeCase.creationDate;
                currCase.subscriberNumber = closeCase.subscriberNumber;
                currCase.assignedTo = closeCase.assignedTo;
                currCase.taskNumber = closeCase.taskNumber;
                currCase.ban = closeCase.ban;
                currCase.psid = closeCase.psid;
                //currCase.dueDate = closeCase.dueDate;
                currCase.sourceSystem = closeCase.sourceSystem;
                currCase.billCycle = closeCase.billCycle;
                currCase.openedBy = closeCase.openedBy;
                currCase.closedBy = closeCase.closedBy;                
                currCase.fuText = closeCase.fuText;                
                currCase.assignedToTeam = closeCase.assignedToTeam; 
                currCase.sourceSystem = closeCase.sourceSystem;
                currCase.statusReason = closeCase.statusReason; 
                currCase.closedBy = closeCase.closedBy; 
                flatCaseList.add(currCase);
            }
        }

        // add list of Tasks related to AccountId
        addTasksRelatedToAccount(flatCaseList, inputAccount.id);

        newResponse.caseList = flatCaseList;
        String newResponseStr = JSON.serialize(newResponse);
        Map<String,Object> myMap =(Map<String,Object>)Json.deserializeUntyped(newResponseStr);
        outMap.putAll(myMap);

        return true;

    }

    /**
     * Retrieve list of Tasks related to AccountId.
     * Tal Sabati
     * taskid PLR-645
     * @method addTasksRelatedToAccount
     * @param {List} flatCaseList
     * @param {String} accountId
     * @return {void}
     * @static
     */
    private static void addTasksRelatedToAccount(List<IndicatorsCalloutBuilder.flatCaseDetails> flatCaseList, string accountId){
        list<Task> taskList = [Select ActivityDate, Owner.Name, WhatId, Type, toLabel(Subject), toLabel(SubjectB2C__c), toLabel(SubSubject__c),  toLabel(Status), RecurrenceType, OwnerId, Description, CreatedDate, CreatedBy.Username, DueDateB2C__c, tolabel(RecordType.Name) From Task where WhatId =: accountId and IsRecurrence = false];
        for(Task t: taskList){
            IndicatorsCalloutBuilder.flatCaseDetails newTask = new IndicatorsCalloutBuilder.flatCaseDetails();
            if(t.Status == 'סגור'){
                newTask.status = 'C';
            }
            else{
                newTask.status = 'O';
            }
            
            newTask.displayStatus = t.Status;
            
            newTask.displaySourceSys = t.RecordType.Name;
            
            newTask.fuCode = t.Subject;
            if(t.SubjectB2C__c == '' || t.SubjectB2C__c == null) {
                t.SubjectB2C__c = '';
            }
            if(t.SubSubject__c == '' || t.SubSubject__c == null) {
                t.SubSubject__c = '';
            }
            String userNameScreen;
            if(t.CreatedBy.Username != '' && t.CreatedBy.Username != null) {                
                String[] userNameArr = t.CreatedBy.Username.split('@');
                userNameScreen = userNameArr[0];                
            }           
            newTask.openedBy = userNameScreen;
            
            newTask.descriprion = t.SubjectB2C__c;
            if(t.SubSubject__c != '') {
              newTask.descriprion= newTask.descriprion +' ,'+ t.SubSubject__c;
            }
            
            newTask.fuText = t.Description;
                        
            String creationDateStr;
            if( t.CreatedDate != null ) {
                creationDateStr = DateTime.newInstance(t.CreatedDate.year(),t.CreatedDate.month(),t.CreatedDate.day(),t.CreatedDate.hour(), t.CreatedDate.minute(), t.CreatedDate.second()).format('dd/MM/YYYY kk:mm:ss');
            }
            newTask.creationDate = creationDateStr;
            newTask.assignedTo = t.Owner.Name;
            newTask.taskNumber = t.id;
            String dueDateStr;
            if( t.DueDateB2C__c != null ) {
                dueDateStr = DateTime.newInstance(t.DueDateB2C__c.year(),t.DueDateB2C__c.month(),t.DueDateB2C__c.day(), t.DueDateB2C__c.hour(), t.DueDateB2C__c.minute(), t.DueDateB2C__c.second()).format('dd/MM/YYYY kk:mm:ss');
            }
            if( t.ActivityDate != null ) {
                dueDateStr = DateTime.newInstance(t.ActivityDate.year(),t.ActivityDate.month(),t.ActivityDate.day(), 0, 0, 0).format('dd/MM/YYYY');
            }
            newTask.dueDate = t.DueDateB2C__c != null ? t.DueDateB2C__c : t.ActivityDate;//dueDateStr;
            newTask.sourceSystem = 'Salesforce';            
            flatCaseList.add(newTask);
        }
    }

    /**
     * Retrieve list of billing accounts related to consumer accountId.
     * Elad IFlah
     * taskid General
     * @method getBillingAccountList
     * @param {String} accountId
     * @return {List}
     * @static
     */
    private static List<Account> getBillingAccountList(String accountId) {
    
        return [select Id, RecordType.DeveloperName, RecordType.Name, CellcomExternalID__c, (SELECT Id FROM Tasks LIMIT 1),(Select Id, Name, BANPSID__c, CELL_Ind__c, NETV_Ind__c From ChildAccounts WHERE RecordType.DeveloperName='Billing') from Account where id = :accountId];
    }
    
    /**
     * Retrieve fields related to contactId.
     * tal sabati
     * taskid PLR-838
     * @method getContactRecord
     * @param {String} contactId
     * @return {List}
     * @static
     */

    private static List<Contact> getContactRecord(String contactId){
        list<Contact> contactList = [select Id, CellcomExternalID__c from Contact where id =: contactId];
        return contactList;
    }
    /*private static boolean returnError(Map < String, Object > outMap, String key, object msg) {
        outMap.put(key, msg);
        outMap.put('processError', 'true');
        return false;
    }*/
    /**
    * Retrieve the value of indicators from legacy systems.
    * Send the response back to the card by outMap
    * Tal sabati
    * taskid PLR-838
    * @method getB2CFirstIndicators
    * @param {Map} inputMap
    * @param {Map} outMap
    * @param {Map} options
    * @return {Boolean} success/failure
    * @static
    */
    private static Boolean getB2CFirstIndicators(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        if(!inputMap.containsKey('accountId') || !inputMap.containsKey('contactId')){
            return false;
        }
        String accountId = String.valueOf(inputMap.get('accountId'));
        String contactId = String.valueOf(inputMap.get('contactId'));

        list<Account> accountList = getBillingAccountList(accountId);
        list<Contact> contactList = getContactRecord(contactId);

        Map<String,Object> response = (!accountList.isEmpty() && !contactList.isEmpty()) ? setB2CFirstIndicatorRequestBody(accountList[0], contactList[0], outMap) : null;


        /*if (response == null) {
            return returnError(outMap, 'processErrorMsg', Label.msgResponseIssue);
        }*/
        list<flatIndicator> flatIndicatorList = (response != null) ? setIndicatorArray(response, accountList[0]) : new list<flatIndicator>(); 

        if(accountList[0].RecordType.DeveloperName == 'Business'){
            
            addCustomerEngagementToList(flatIndicatorList, accountId);
            
            // PLR-159 add tech support indicator
            addTechSupportToList(flatIndicatorList, accountId);
        }
        if(outMap == null){
            //outMap = new Map<String,Object>();
        }
        outMap.put('Response', flatIndicatorList);
        return true;
    }
    /**
     * The method add indicator of Customer Engagement from vlocity_cmt__AttributeAssignment__c
     * Tal sabati
     * taskid PLR-212
     * @method addCustomerEngagementToList
     * @param {list<flatIndicator>} flatIndicatorList
     * @param {string} accountId
     * @return {void}
     * @static
     */
    private static void addCustomerEngagementToList(list<flatIndicator> flatIndicatorList, string accountId){
        list<vlocity_cmt__AttributeAssignment__c> attributeAssignmentList = [Select vlocity_cmt__Value__c, vlocity_cmt__AttributeName__c From vlocity_cmt__AttributeAssignment__c
                                                                            WHERE vlocity_cmt__ObjectId__c =: accountId
                                                                            AND vlocity_cmt__RemovedFlag__c = false
                                                                            AND vlocity_cmt__AttributeCategoryId__r.vlocity_cmt__Code__c = 'CustomerEngagement'
                                                                            AND vlocity_cmt__AttributeId__r.vlocity_cmt__Code__c = 'CustomerEngagement'
                                                                            AND vlocity_cmt__Value__c != null limit 1];
        flatIndicator newFlatIndicator = new flatIndicator();
        newFlatIndicator.Name = 'indCustomerEngagement';
        newFlatIndicator.value = '0';
        newFlatIndicator.recordType = 'Business';

        if(!attributeAssignmentList.isEmpty()){
            Integer engagementLevel = integer.valueof(attributeAssignmentList[0].vlocity_cmt__Value__c);
            if(engagementLevel >= 1 && engagementLevel <= 3){
                newFlatIndicator.value = '1';
            }
            else if(engagementLevel >= 4 && engagementLevel <= 5){
                newFlatIndicator.value = '2';
            }
            else if(engagementLevel >= 6 && engagementLevel <= 7){
                newFlatIndicator.value = '3';
            }
        }
        flatIndicatorList.add(newFlatIndicator);
    }
    
     /**
     * The method add indicator of Customer Engagement from vlocity_cmt__AttributeAssignment__c
     * Elad Iflah
     * taskid PLR-159
     * @method addTechSupportToList
     * @param {list<flatIndicator>} flatIndicatorList
     * @param {string} accountId
     * @return {void}
     * @static
     */
    private static List<TechSupportEvent> addTechSupportToList(list<flatIndicator> flatIndicatorList, string accountId){
        
        
        List<Event> eventList = [Select Id, Subject, StartDateTime, EndDateTime, LineCode__c, Description, RecordType.DeveloperName, ShortDescription__c, toLabel(EventStatus__c) FROM Event 
                                 WHERE EndDateTime > :system.now() 
                                 AND RecordType.DeveloperName = 'Support'
                                 AND AccountId = :accountId ];
        
        String startDateStr;
        String endDateStr;                              
        
        List<TechSupportEvent> custTechSuppList = new List<TechSupportEvent>();
        
        for( Event currEvent :  eventList ) {
            
            startDateStr = DateTime.newInstance(currEvent.StartDateTime.year(),currEvent.StartDateTime.month(),currEvent.StartDateTime.day()).format('dd/MM/YYYY');
            endDateStr = DateTime.newInstance(currEvent.EndDateTime.year(),currEvent.EndDateTime.month(),currEvent.EndDateTime.day()).format('dd/MM/YYYY');
                
            TechSupportEvent currTechEvent = new TechSupportEvent(currEvent.Subject, startDateStr, endDateStr, currEvent.LineCode__c, currEvent.Description, currEvent.Id, currEvent.EventStatus__c, currEvent.ShortDescription__c);
            custTechSuppList.add(currTechEvent);
        }
                                 
        if( flatIndicatorList != null ) {
            flatIndicator newFlatIndicator = new flatIndicator();
            newFlatIndicator.Name = 'indTechSupport';
            newFlatIndicator.value = 'false';
            newFlatIndicator.recordType = 'Business';
    
            if(!eventList.isEmpty() && eventList.size() > 0) {
                newFlatIndicator.value = 'true';
            }
            
            flatIndicatorList.add(newFlatIndicator);
        }
        
        return custTechSuppList;
        
    }
    
    class TechSupportEvent {
        
        private String subject;
        private String startDate;
        private String endDate;
        private String productDesc;
        private String freeText;
        private String eventId;
        private String status;
        private String shortDesc;
        
        
        TechSupportEvent(String Subject, String StartDate, String EndDate, String ProductDesc, String FreeText, String EventId, String Status, String ShortDesc) {
            this.subject = Subject;
            this.startDate = StartDate;
            this.endDate = EndDate;
            this.productDesc = ProductDesc;
            this.freeText = FreeText;
            this.eventId = EventId;
            this.status = Status;
            this.shortDesc = ShortDesc;
        }
    }
    
    /**
    * Retrieve the value of indicators from legacy systems.
    * Send the response back to the card by outMap
    * Elad Iflah
    * taskid PLR-159
    * @method getOpenTechSuppEvents
    * @param {Map} inputMap
    * @param {Map} outMap
    * @param {Map} options
    * @return {Boolean} success/failure
    * @static
    */
    private static Boolean getOpenTechSuppEvents(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        if(!inputMap.containsKey('accountId')){
            return false;
        }
        
        List<TechSupportEvent> techSuppList = new list<TechSupportEvent>();
        
        String accountId = String.valueOf(inputMap.get('accountId'));
        list<Account> accountList = getBillingAccountList(accountId);

        if(accountList[0].RecordType.DeveloperName == 'Business'){
            techSuppList = addTechSupportToList(null, accountId);
        }

        outMap.put('Response', techSuppList);
        return true;
    }
    
    
    /**
     * The method builds a array of indicators
     * Tal sabati
     * taskid PLR-838
     * @method setIndicatorArray
     * @param {string} bodyResponse
     * @param {string} accountId
     * @return {list<flatIndicator>}
     * @static
     */
    private static list<flatIndicator> setIndicatorArray(Map<String,Object> responseMap , Account account){
        list<flatIndicator> flatIndicatorList = new list<flatIndicator>();
        boolean isRelatedTask = (account.Tasks != null && !account.Tasks.isEmpty()) ? true : false;
        if(responseMap.containsKey('Body')){
            Map<String,Object> bodyMap = (Map<String,Object>) responseMap.get('Body');
            if(bodyMap.containsKey('Response')){
                Map<String,Object> responsetMap = (Map<String,Object>) bodyMap.get('Response');
                if(responsetMap.containsKey('indicatorArray')){
                    List<object> indicatorArray = (List<object>) responsetMap.get('indicatorArray');
                    for(object indicator : indicatorArray){
                        flatIndicator newFlatIndicator = new flatIndicator();
                        newFlatIndicator.recordType = account.RecordType.DeveloperName;
                        Map<String,object> ind = (Map<String,object>) indicator;
                        for(String indName: ind.keySet()){
                            newFlatIndicator.Name = indName;
                        }
                        for(object indValue : ind.values()){
                            newFlatIndicator.value = String.valueOf(indValue);
                        }
                        if(newFlatIndicator.Name == 'indCase' && isRelatedTask){
                            newFlatIndicator.value = 'true';
                        }
                        
                        /*if(newFlatIndicator.value == 'error'){
                            //newFlatIndicator.value = 'false';
                        }*/  
                        
                        if(!(account.RecordType.DeveloperName == 'Business' && newFlatIndicator.Name == 'getReturnCustomerInd')){
                            flatIndicatorList.add(newFlatIndicator);
                        }
                    }
                }
            }
        }
        return flatIndicatorList;
    }
    /**
     * The method check whether there are tasks related to account
     * Tal sabati
     * taskid PLR-838
     * @method isRelatedTask
     * @param {string} accountId
     * @return {Boolean}
     * @static
     */
    /*private static Boolean isRelatedTask(string accountId){
        list<Task> taskList = [Select ActivityDate, Owner.Name, WhatId, Type, Subject, Status, RecurrenceType, OwnerId, Description, CreatedDate From Task where WhatId =: accountId limit 1];
        if(taskList.isEmpty()){
            return false;
        }
        return true;
    }*/
    /**
     * The method set request body for B2C First Indicators
     * Tal sabati
     * taskid PLR-838
     * @method setB2CFirstIndicatorRequestBody
     * @param {Account} account
     * @param {Contact} contact
     * @return {string} Request Body
     * @static
     */
     //LAST VERSION
    private static Map<String,Object> setB2CFirstIndicatorRequestBody(Account account, Contact contact, Map<String,Object> outMap){
        IndicatorsCalloutBuilder.B2CFirstIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.B2CFirstIndicatorsRequestBuilder();
        IndicatorsCalloutBuilder.AccessibilityFirstIndicatorsCustInfoBuilder curCustInfo = new IndicatorsCalloutBuilder.AccessibilityFirstIndicatorsCustInfoBuilder(account.RecordType.DeveloperName);
        curCustInfo.ContactIdentifier = contact.CellcomExternalID__c;
        curCustInfo.setBanPsIds(account, contact);
        curRequest.setCustInfoNode(curCustInfo);

        IndicatorsCalloutBuilder.B2CFirstIndicatorsServiceInfoBuilder curServiceInfo = new IndicatorsCalloutBuilder.B2CFirstIndicatorsServiceInfoBuilder();
        curServiceInfo.getCaseOpenInd.setDatesInfoBuilder('OpenCaseDaysBack', 'OpenCaseDaysForward');
        curServiceInfo.getNoteOpenInd.setDatesInfoBuilder('OpenNoteDaysBack', 'OpenNoteDaysForward');
        curServiceInfo.getTechVisitOpenInd.setDatesInfoBuilder('OpenTechnicianDaysBack', 'OpenTechnicianDaysForward');
        curServiceInfo.getDeliveryOpenInd.setDatesInfoBuilder('OpenDeliveryDaysBack', 'OpenDeliveryDaysForward');
        curRequest.setServiceInfoNode(curServiceInfo);


        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00682', outMap, Label.msgSrvErr682, Label.msgSrvWarn682);
        request.body.setRequestNode(curRequest);

        Map<String,Object> response = request.sendRequestWithErrorCheck('OSB','api/services/rest/00682_osb_retrievecustomerindicators_bp');
        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return null;
        return response;
    }

    public class flatIndicator{
        public String Name;
        public String value;
        public String recordType;
    }

}