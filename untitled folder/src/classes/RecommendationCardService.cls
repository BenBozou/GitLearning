/**
 * Class for retrieving recommendation data for account
 * Liron Cohen
 * taskid PLR - 121
 * @class RecommendationCardService
 * @module 360
 */
global without sharing class RecommendationCardService implements vlocity_cmt.VlocityOpenInterface2 {

    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        Boolean retResult = true;

        outMap.put('processError', 'false');

        try {
            if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getRecommandations')) {
                retResult = getRecommandations(inputMap, outMap, options);
            }

            else if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getRecommandationsForLeadsFlyout')) {
                retResult = getRecommandationsForLeadsFlyout(inputMap, outMap, options);
            }

            else if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getRecommandationsForOpportunitiesFlyout')) {
                retResult = getRecommandationsForOpportunitiesFlyout(inputMap, outMap, options);
            }

            else if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getRecommandationsForOrdersFlyout')) {
                retResult = getRecommandationsForOrdersFlyout(inputMap, outMap, options);
            }

            else if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getRecommandationPermission')) {
                retResult = getRecommandationPermission(inputMap, outMap, options);
            }
            
             else if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getRelevantOpenTasks')) {
                retResult = getRelevantOpenTasks(inputMap, outMap, options);
            }

        } catch (Exception ex) {
            system.debug(Logginglevel.ERROR, 'invokeMethod ' + methodName + ' ERROR :' + ex.getMessage() + ':' + ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, ex.getMessage() + ':' + ex.getStackTraceString());
        }

        return retResult;
    }

    /**
     *   method description
     *   author Liron Cohen
     *
     *   @method getRecommandations
     *   @param  {map<String, object>} inputMap
     *   @param  {map<String, object>} outMap
     *   @return {Boolean}
     */
    public Boolean getRecommandations(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        String inputAccId = (String) inputMap.get('accountId');

        if (String.isEmpty(inputAccId)) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.MissingParameterError);
        }

        //Need to limit the result of each subscriber type, therefore need to count them
        integer accountAdded = 0, subscriberAdded = 0;
        
        integer totalRecommendations = 0, totalOpportunities = 0, totalOpenOrders = 0;
        list < Object > reccomendation = new list < Object > ();
        list<User> userList = new list<User>();
        AccountSidebarCardsService.CoordinatorTeamList coordLst = new AccountSidebarCardsService.CoordinatorTeamList();
        
        
        //Loop over relecant leads. Note : LST05 =  Follow Up, LST01 = Open, LST02 = Not Answered
        for (Lead leadRecord: [select  Name, Product__r.Name,
            Product__r.Id, AgentShortDet__c, Subscriber__c,
            Lead_Type__c, CreatedDate,AccountId__c, tolabel(Status), CampaignId__c, TreatId__c
                from Lead
                where RecordType.developerName = 'Offer'
                and AccountId__c =: inputAccId
                and Status IN('LST01', 'LST05', 'LST02')
                order by Status DESC, Score__c DESC, CreatedDate DESC
            ]) {

            //000000 - means it not subscriber, else it is subscriber
            if (leadRecord.Subscriber__c == '0000000000' &&
                accountAdded < Integer.valueOf(CustomMetadataTypeService.getCrmVariable('RecommendationAccountLimit'))) {

                reccomendation.add(new map < String, Object > {
                    'LeadId' => leadRecord.Id,
                    'LeadType' => leadRecord.Lead_Type__c,
                    'CreartedDate' => leadRecord.createdDate,
                    'AgentShortDet' => leadRecord.AgentShortDet__c,
                    'Name' => leadRecord.Name,
                    'Status' => leadRecord.Status,
                    'ProductId' => leadRecord.Product__r.Id,
                    'Product' => leadRecord.Product__r.Name,
                    'Subscriber' => 0
                });

                accountAdded++;
            } else if (leadRecord.Subscriber__c != '0000000000' &&
                subscriberAdded < Integer.valueOf(CustomMetadataTypeService.getCrmVariable('RecommendationSubsriberLimit'))) {

                reccomendation.add(new map < String, Object > {
                    'LeadId' => leadRecord.Id,
                    'LeadType' => leadRecord.Lead_Type__c,
                    'CreartedDate' => leadRecord.createdDate,
                    'AgentShortDet' => leadRecord.AgentShortDet__c,
                    'Name' => leadRecord.Name,
                    'Status' => leadRecord.Status,
                    'ProductId' => leadRecord.Product__r.Id,
                    'Product' => leadRecord.Product__r.Name,
                    'TreatId' => leadRecord.TreatId__c,
                    'AccountId' => inputAccId,
                    'Subscriber' => 1
                });

                subscriberAdded++;
            }

            //totalRecommendations++;
        }
        AggregateResult[] leadGroupByProduct = [select Product__r.Name from Lead where RecordType.developerName = 'Offer'
            and AccountId__c =: inputAccId and Product__r.Name != null and Status IN('LST01', 'LST05', 'LST02') and Subscriber__c != '0000000000'
            GROUP BY Product__r.Name
        ];
        totalRecommendations = accountAdded + leadGroupByProduct.size();

        for (Opportunity opp: [select id, IsClosed, OrderStatus__c
                from Opportunity
                where accountID =: inputAccId
                and(OrderStatus__c = 'In Progress'
                    or IsClosed = false)
            ]) {

            if (opp.isclosed == false) {
                totalOpportunities++;
            }

            if (opp.OrderStatus__c == 'In Progress') {
                totalOpenOrders++;
            }
        }

        Map < String, Object > response = new map < String, Object > {
            'TotalRecommendations' => totalRecommendations,
            'TotalOpportunities' => totalOpportunities,
            'TotalOpenOrders' => totalOpenOrders,
            'accountId' => inputAccId,
            'Recommendations' => reccomendation,
            'UserHasFullAccess' => (AccountSidebarCardsService.handleMatalCoordData(new Account(Id = inputAccId), userList, coordLst)) ? 'y' : 'n'
        };

        outMap.put('data', response);

        return true;
    }

    /**
     *   method description
     *   author Elad Kaplan
     *
     *   @method getRecommandationsForLeadsFlyout
     *   @param  {map<String, object>} inputMap
     *   @param  {map<String, object>} outMap
     *   @return {Boolean}
     */
    public Boolean getRecommandationsForLeadsFlyout(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        String inputAccId = (String) inputMap.get('accountId');

        if (String.isEmpty(inputAccId)) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.MissingParameterError);
        }

        //Need to limit the result of each subscriber type, therefore need to count them
        integer accountAdded = 0, subscriberAdded = 0;

        integer totalRecommendations = 0, totalOpportunities = 0, totalOpenOrders = 0;
        list < Object > reccomendation = new list < Object > ();
        set<String> prductsNamesUnique_Set = new set<String>();
        //Loop over relecant leads. Note : LST05 =  Follow Up, LST01 = Open, LST02 = Not Answered
        for (Lead leadRecord: [select  Name, Product__r.Name,
            Product__r.Id, AgentShortDet__c, Subscriber__c,
            Lead_Type__c, CreatedDate,AccountId__c, tolabel(Status), CampaignId__c
                from Lead
                where RecordType.developerName = 'Offer'
                and AccountId__c =: inputAccId
                and Status IN('LST01', 'LST05', 'LST02')
                order by  Status DESC, Score__c DESC, CreatedDate ASC
            ]) {

            //000000 - means it not subscriber, else it is subscriber
            if (leadRecord.Subscriber__c == '0000000000') {

                reccomendation.add(new map < String, Object > {
                    'LeadId' => leadRecord.Id,
                    'LeadType' => leadRecord.Lead_Type__c,
                    'accountId' => leadRecord.AccountId__c,
                    'CreatedDate' => leadRecord.createdDate,
                    'AgentShortDet' => leadRecord.AgentShortDet__c,
                    'Name' => leadRecord.Name,
                    'Status' => leadRecord.Status,
                    'ProductId' => leadRecord.Product__r.Id,
                    'Product' => leadRecord.Product__r.Name,
                    'Subscriber' => 0
                });

                accountAdded++;
            } else if (leadRecord.Subscriber__c != '0000000000') {

                if (!prductsNamesUnique_Set.contains(leadRecord.Product__r.Name)) {
                    prductsNamesUnique_Set.add(leadRecord.Product__r.Name);
                    reccomendation.add(new map < String, Object > {
                        'LeadId' => leadRecord.Id,
                        'LeadType' => leadRecord.Lead_Type__c,
                        'accountId' => leadRecord.AccountId__c,
                        'CreatedDate' => leadRecord.createdDate,
                        'AgentShortDet' => leadRecord.AgentShortDet__c,
                        'Name' => leadRecord.Name,
                        'Status' => leadRecord.Status,
                        'ProductId' => leadRecord.Product__r.Id,
                        'Product' => leadRecord.Product__r.Name,
                        'Subscriber' => 1
                    });
                }

                subscriberAdded++;
            }

            //totalRecommendations++;
        }
        AggregateResult[] leadGroupByProduct = [select Product__r.Name from Lead where RecordType.developerName = 'Offer'
            and AccountId__c =: inputAccId and Product__r.Name != null and Status IN('LST01', 'LST05', 'LST02') and Subscriber__c != '0000000000'
            GROUP BY Product__r.Name
        ];
        totalRecommendations = accountAdded + leadGroupByProduct.size();

        for (Opportunity opp: [select id, IsClosed, OrderStatus__c,
            (SELECT Id FROM OpportunityLineItems)
                from Opportunity
                where accountID =: inputAccId
                and(OrderStatus__c = 'In Progress'
                    or IsClosed = false)
            ]) {

            if (opp.isclosed == false) {
                totalOpportunities++;
            }

            if (opp.OrderStatus__c == 'In Progress') {

                totalOpenOrders++;
            }
        }

        Map < String, Object > response = new map < String, Object > {
            'TotalRecommendations' => totalRecommendations,
            'TotalOpportunities' => totalOpportunities,
            'TotalOpenOrders' => totalOpenOrders,
            'accountId' => inputAccId,
            'Recommendations' => reccomendation
        };

        outMap.put('data', response);

        return true;
    }

    /**
     *   method description
     *   author Elad Kaplan
     *
     *   @method getRecommandationsForOpportunitiesFlyout
     *   @param  {map<String, object>} inputMap
     *   @param  {map<String, object>} outMap
     *   @return {Boolean}
     */
    public Boolean getRecommandationsForOpportunitiesFlyout(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        String inputAccId = (String) inputMap.get('accountId');
        AccountSidebarCardsService.CoordinatorTeamList coordLst = new AccountSidebarCardsService.CoordinatorTeamList();
        list<User> userList = new list<User>();
        
        if (String.isEmpty(inputAccId)) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.MissingParameterError);
        }

        //Need to limit the result of each subscriber type, therefore need to count them
        integer accountAdded = 0, subscriberAdded = 0;
    
        list < Object > reccomendation = new list < Object > ();
        //Loop over relecant leads. Note : LST05 =  Follow Up, LST01 = Open, LST02 = Not Answered
        for (Opportunity currentOpp : [select Name, toLabel(StageName), OrderStatus__c, isClosed,
							            Amount, CloseDate, Probability, CreatedDate, Owner.Name, 
							            (SELECT Product2.Name, ProductCanceled__c  FROM OpportunityLineItems where ProductCanceled__c = false)
							            from Opportunity WHERE AccountId =: inputAccId
							            and isClosed = false order by CreatedDate ASC
							            ]) {

                String lineItemsAgg = '';
                    for (OpportunityLineItem currentOppLI : currentOpp.OpportunityLineItems) {

                        lineItemsAgg += currentOppLI.Product2.Name + ',';
                    }

                lineItemsAgg = lineItemsAgg.removeEnd(',');
                map < String, Object > fieldMap = new map < String, Object > {
                    'Name' => currentOpp.Name,
                    'StageName' => currentOpp.StageName,
                    'Amount' => currentOpp.Amount,
                    'CreatedDate' => currentOpp.createdDate,
                    'CloseDate' => currentOpp.CloseDate,
                    'Probability' => currentOpp.Probability,
                    'Id' => currentOpp.Id,
                    'product' => lineItemsAgg,
                    'ownerName' => currentOpp.Owner.Name,
                    'UserHasFullPermissions' => 'n'
                };
                if (AccountSidebarCardsService.handleMatalCoordData(new Account(Id = inputAccId), userList, coordLst)) {
                    fieldMap.put('UserHasFullPermissions', 'y');
                }
                reccomendation.add(fieldMap);
            }
            
        Map < String, Object > response = new map < String, Object > {

            'Recommendations' => reccomendation
        };

        outMap.put('data', response);

        return true;
    }

    /**
     *   method description
     *   author Elad Kaplan
     *
     *   @method getRecommandationsForOrdersFlyout
     *   @param  {map<String, object>} inputMap
     *   @param  {map<String, object>} outMap
     *   @return {Boolean}
     */
    public Boolean getRecommandationsForOrdersFlyout(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        String inputAccId = (String) inputMap.get('accountId');

        if (String.isEmpty(inputAccId)) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.MissingParameterError);
        }

        list < Object > reccomendation = new list < Object > ();
        for (OpportunityLineItem currentOppLI : [select Product2.Name,
									            OrderStatus__c, Opportunity.Name, ProductCanceled__c
									            from OpportunityLineItem WHERE Opportunity.AccountId =: inputAccId
									            and Opportunity.OrderStatus__c = 'In Progress' and ProductCanceled__c = false order by CreatedDate ASC
            ]){

                reccomendation.add(new map < String, Object > {
                    'Name' => currentOppLI.Opportunity.Name,
                    'Status' => currentOppLI.OrderStatus__c,
                    'product' => currentOppLI.Product2.Name,
                    'Id' => currentOppLI.Opportunity.Id
                });
            }

        Map < String, Object > response = new map < String, Object > {

            'Recommendations' => reccomendation
        };

        outMap.put('data', response);
        return true;
    }

    /**
     *   method description
     *   author Tal sabati
     *
     *   @method getRecommandationPermission
     *   @param  {map<String, object>} inputMap
     *   @param  {map<String, object>} outMap
     *   @return {Boolean}
     */
    public Boolean getRecommandationPermission(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        
        Map < String, Object > recommMap = new map < String, Object >();
        //WritePermissionsObject__c.getInstance().CardB2BRecommendation__c
        if(CustomPermissionService.getCustomPermissionByName('Card_B2B_Recommendation')){
            recommMap.put('UserHasRecommPermission', 'y');
        }
        else{
            recommMap.put('UserHasRecommPermission', 'n');
        }
        outMap.put('data', recommMap);
        return true;
    }
    
    public Boolean getRelevantOpenTasks(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        
        Id currentUserId = UserInfo.getUserId();
        
        List<User> federationIdList=[SELECT FederationIdentifier 
                                     FROM User
                                     WHERE Id =: currentUserId];
        system.debug('federationIdList : ' + federationIdList);                     
                                
        map<String, list<Task>> TasksSeperated_Map = new map<String, list<Task>>();
        map<String, list<Object>> Tasks2ObjectsList_Map = new map<String, list<Object>>();
        TasksSeperated_Map.put('tasksAssignedToUser', new list<Task>());
        TasksSeperated_Map.put('tasksOpenedByUser', new list<Task>());
        TasksSeperated_Map.put('tasksAssignedToTeam', new list<Task>());
        list < Object > tasksAssignedToUser = new list < Object > ();
        list < Object > tasksOpenedByUser = new list < Object > ();
        list < Object > tasksAssignedToTeam = new list < Object > ();
        Integer DaysBack = Integer.valueOf(CustomMetadataTypeService.getCrmVariable('PersonlFolderDaysBack'));
        Map < String, Object > sampleResponse_Map = getSampleTasksJSON(federationIdList[0].FederationIdentifier,DaysBack);
        
        Map < String, Object > Body_Map = new Map < String, Object > ();
        Map < String, Object > response_Map = new Map < String, Object > ();
        Map < String, Object > open_Map = new Map < String, Object > ();
        Map < String, Object > tasksAssignedToTeam_Map = new Map < String, Object > ();
        Map < String, Object > tasksAssignedToUser_Map = new Map < String, Object > ();
        Map < String, Object > tasksOpenedByUser_Map = new Map < String, Object > ();
        Boolean isInterfaceSuccess=true;
         
        try{
            Body_Map = (Map < String, Object > ) sampleResponse_Map.get('Body');
            response_Map = (Map < String, Object > ) Body_Map.get('Response');
            open_Map = (Map < String, Object > ) response_Map.get('open');
        }
        catch (Exception exp) {
            isInterfaceSuccess=false;
        } 
            
        if (isInterfaceSuccess) {
            if (!Tasks2ObjectsList_Map.containsKey('tasksAssignedToUser')) {  
                Tasks2ObjectsList_Map.put('tasksAssignedToUser', tasksAssignedToUser);
                
                try{
                    tasksAssignedToUser_Map = (Map < String, Object > ) open_Map.get('tasksAssignedToUser');
                    list<Object> objList = (List<Object>)tasksAssignedToUser_Map.get('taskDetails');
                               
                    if(objList != null && !objList.isEmpty()){ 
                        for (Object obj : objList) {
                    
                            Tasks2ObjectsList_Map.get('tasksAssignedToUser').add(obj);
                        }
                    }
                }
                catch (Exception exp1){
                    
                }
            }

            if (!Tasks2ObjectsList_Map.containsKey('tasksOpenedByUser')) {    
                Tasks2ObjectsList_Map.put('tasksOpenedByUser', tasksOpenedByUser);
                    
                try{
                    tasksOpenedByUser_Map = (Map < String, Object > ) open_Map.get('tasksOpenedByUser');
                    list<Object> objList = (List<Object>)tasksOpenedByUser_Map.get('taskDetails');
                               
                    if(objList != null && !objList.isEmpty()){ 
                        for (Object obj : objList) {
                    
                            Tasks2ObjectsList_Map.get('tasksOpenedByUser').add(obj);
                        }
                    }
                }
                catch (Exception exp2){
                    
                }
            }

            if (!Tasks2ObjectsList_Map.containsKey('tasksAssignedToTeam')) {   
                Tasks2ObjectsList_Map.put('tasksAssignedToTeam', tasksAssignedToTeam);
                    
                try{
                    tasksAssignedToTeam_Map = (Map < String, Object > ) open_Map.get('tasksAssignedToTeam');
                    list<Object> objList = (List<Object>)tasksAssignedToTeam_Map.get('taskDetails');
                               
                    if(objList != null && !objList.isEmpty()){ 
                        for (Object obj : objList) {
                    
                            Tasks2ObjectsList_Map.get('tasksAssignedToTeam').add(obj);
                        }
                    }
                }
                catch (Exception exp3){
                    
                }
            }
        }
        
        for (Task currentTask : [SELECT Who.Name, Owner.Name, SecondaryOwner__c, OwnerId, WhoId, Type, toLabel(Subject), 
                                toLabel(Status), Description, CreatedDate, What.Name, tolabel(RecordType.Name), 
                                CreatedBy.Name, CreatedById, ActivityDate, DueDateB2C__c, ContactPhone__c, CallBack__c From Task 
                                WHERE (CreatedById =: currentUserId OR OwnerId =: currentUserId
                                OR SecondaryOwner__c =: currentUserId)
                                and createdDate >: Date.today().addDays(-DaysBack)
                                and Status!='TST01' and Status!='TST02'
                                and Status!='TST21'
                                and IsRecurrence = false]) {
            
            if (currentTask.OwnerId == currentUserId || currentTask.SecondaryOwner__c == currentUserId)  {
                TasksSeperated_Map.get('tasksAssignedToUser').add(currentTask);
                if (!Tasks2ObjectsList_Map.containsKey('tasksAssignedToUser')) {  
                    Tasks2ObjectsList_Map.put('tasksAssignedToUser', tasksAssignedToUser);
                }
            }
                
            if (currentTask.OwnerId != currentUserId && 
                currentTask.SecondaryOwner__c != currentUserId && 
                currentTask.CreatedById == currentUserId){
                TasksSeperated_Map.get('tasksOpenedByUser').add(currentTask);
                if (!Tasks2ObjectsList_Map.containsKey('tasksOpenedByUser')) {    
                    Tasks2ObjectsList_Map.put('tasksOpenedByUser', tasksOpenedByUser);
                }
            }
            
            //No Salesforce Task records will merge into tasksAssignedToTeam  
            //if (currentTask.SecondaryOwner__c == currentUserId)
            //  TasksSeperated_Map.get('tasksAssignedToTeam').add(currentTask);
           
        } 
       
        for (String key : TasksSeperated_Map.keySet()) {
            
            for (Task currentTsk : TasksSeperated_Map.get(key)) {
                DateTime dtConvert;
                Boolean bolFormat =false;
                if (currentTsk.ActivityDate != null){
                    bolFormat =true;
                    dtConvert = Datetime.newInstance((currentTsk.ActivityDate).year(), (currentTsk.ActivityDate).month(),(currentTsk.ActivityDate).day(),0,0,0);
                }
                if (currentTsk.DueDateB2C__c != null){
                    bolFormat =true;
                    dtConvert = Datetime.newInstance((currentTsk.DueDateB2C__c).year(), (currentTsk.DueDateB2C__c).month(),(currentTsk.DueDateB2C__c).day(),0,0,0);
                }
                
                /*Tasks2ObjectsList_Map.get(key).add(new map < String, Object > {
                       
                    'openDate' => currentTsk.createdDate.format('dd/MM/YYYY hh:mm:ss'),
                    //'dueDate' => currentTsk.ActivityDate,
                    'dueDate' => (bolFormat) ? dtConverted.format('dd/MM/YYYY') : '',
                    'type' => 'משימה',
                    'CreatedByUser' => currentTsk.CreatedBy.Name,
                    'customerName' => currentTsk.What.Name,
                    'CustomerNumber' => currentTsk.WhoId,
                    'taskNumber' => currentTsk.Id,
                    'subject' => currentTsk.RecordType.Name,
                    'comments' => currentTsk.Description,
                    'description' => currentTsk.subject,
                    'assignedToUserName' => (String.valueOf(currentTsk.OwnerId).StartsWith('005')) ? currentTsk.Owner.Name : '',
                    'assignedToTeamName' => (!String.valueOf(currentTsk.OwnerId).StartsWith('005')) ? currentTsk.Owner.Name : '',
                    'status' => currentTsk.Status,
                    'sourceSystem' => 'Salesforce',
                    'contactPhone' => currentTsk.ContactPhone__c,
                    'callback' => (currentTsk.CallBack__c) ? 'כן' : 'לא'
                });*/
                Tasks2ObjectsList_Map.get(key).add(new map < String, Object > {
                       
                    'openDate' => currentTsk.createdDate.format('dd/MM/YYYY kk:mm:ss'),
                    //'dueDate' => currentTsk.ActivityDate,
                    'dueDate' => (bolFormat) ? dtConvert.format('dd/MM/YYYY') : '',
                    'type' => currentTsk.RecordType.Name,
                    'CreatedByUser' => currentTsk.CreatedBy.Name,
                    'customerName' => currentTsk.What.Name,
                    'CustomerNumber' => currentTsk.WhoId,
                    'taskNumber' => currentTsk.Id,
                    'subject' => currentTsk.subject,
                    //'comments' => currentTsk.Description,
                    //'description' => currentTsk.RecordType.Name,
                    'assignedToUserName' => (String.valueOf(currentTsk.OwnerId).StartsWith('005')) ? currentTsk.Owner.Name : '',
                    'assignedToTeamName' => (!String.valueOf(currentTsk.OwnerId).StartsWith('005')) ? currentTsk.Owner.Name : '',
                    'status' => currentTsk.Status,
                    'sourceSystem' => 'Salesforce',
                    'contactPhone' => currentTsk.ContactPhone__c,
                    'callback' => (currentTsk.CallBack__c) ? 'כן' : 'לא'
                });
            }
        }
        
        Map < String, Object > response = new map < String, Object >();
            
        for (String key : Tasks2ObjectsList_Map.keySet()) {
        
            response.put(key,Tasks2ObjectsList_Map.get(key));    
        }
         
        outMap.put('data', response);
        return true;
    }
    
    private map<String, Object> getSampleTasksJSON(String UserId, Integer daysBack) {
        
        IndicatorsCalloutBuilder.PersonalFolder curRequest = new IndicatorsCalloutBuilder.PersonalFolder(UserId,daysBack);
       
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00725');
        request.body.setRequestNode(curRequest);

        Map < String, Object > response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00725_osb_personalfolderforcsr_bp');
       
        return response;
    }
}