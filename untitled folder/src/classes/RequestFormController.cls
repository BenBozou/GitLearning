/**
* controller class for RequestForm page.
* Mohammad G.
* taskid
* @class RequestFormController
* @module Leads
* @constructor RequestFormController
*/
public without sharing class RequestFormController {

    private ApexPages.StandardController sc;
    public Request__c request {get;set;}
    private Opportunity opp;
    private Case c;
    public String step {get;set;}
    public list<controllingFieldWrapper> controllingFieldsList {get;set;}
    public list<requestDetailsWrapper> requestDetailsWrapList {get;set;}
    public String dependenciesJSON {get;set;}
    private integer firstPicklistIndex;
    public String sourceObjType {get;set;}
    public String cont1Val {get;set;}
    public String cont2Val {get;set;}
    public String cont3Val {get;set;}
    public String urlBan {get;set;}
    public Boolean isURL {get;set;}

    public list<Request__c> childRequestsList {get;set;}
    public Integer requestIndexToDelete {get;set;}
    public list<SelectOption> productsList{get;set;}
    public Boolean isOli{get;set;}

    public RequestFormController(ApexPages.StandardController sc) {
        this.sc = sc;
        map<String,String> pageParamsMap = ApexPages.currentPage().getParameters();
        request = new Request__c();
        //request.OwnerId = UserInfo.getUserId();
        productsList = new list<SelectOption>();
        isOli = false;
        String oliId = pageParamsMap.get('oliId');
        if(String.isNotBlank(oliId)){
            //the source is oli
            isOli = true;
            request.ProductLineItemId__c = oliId;
            OpportunityLineItem oli = [select id, Product2.Name, OpportunityId, OppProductId__c from OpportunityLineItem where Id =: oliId limit 1];
            request.OpportunityId__c = oli.OpportunityId;
            request.Source__c = 'Opportunity';
            sourceObjType = 'Opportunity';
            request.Product__c = oli.Product2.Name;
            request.OppProductId__c  = oli.OppProductId__c;
        }
        else{
            //Find the request source object, Case or Opportunity
            for(String param : pageParamsMap.keySet()){
                if(param.endsWithIgnoreCase('_lkid') && pageParamsMap.get(param).startsWithIgnoreCase('006')){
                    //opportunity Id was found
                    request.OpportunityId__c = pageParamsMap.get(param);
                    request.Source__c = 'Opportunity';
                    sourceObjType = 'Opportunity';
                    initProducts();
                    break;
                }
                if(param.endsWithIgnoreCase('_lkid') && pageParamsMap.get(param).startsWithIgnoreCase('500')){
                    //case Id was found
                    request.CaseId__c = pageParamsMap.get(param);
                    request.Source__c = 'Case';
                    sourceObjType = 'Case';
                    break;
                }
            }
        }
        if(request.OpportunityId__c != null){
            opp = [select Id, AccountId, Account.BANPSID__c, Account.Cell_Ind__c from Opportunity where Id =: request.OpportunityId__c];
            request.Account__c = opp.AccountId;
        }
        if(request.CaseId__c != null){
            c = [select Id, AccountId, Account.BANPSID__c, Account.Cell_Ind__c, Opportunity__r.Id from Case where Id =: request.CaseId__c];
            request.Account__c = c.AccountId;
        }
        step = '1';
    }
    public void updateProductLineItemId(){
        list<OpportunityLineItem> oliList = [select id, Product2.Name, OppProductId__c from OpportunityLineItem where id =: request.ProductLineItemId__c limit 1];
        if(!oliList.isEmpty()){
            request.OppProductId__c = oliList[0].OppProductId__c;
        }
    }

    public void initProducts(){
        productsList.add(new SelectOption('',''));
        list<OpportunityLineItem> oliList = [select id, Product2.Name, OppProductId__c from OpportunityLineItem where OpportunityId =: request.OpportunityId__c];
        for(OpportunityLineItem oli : oliList)
            productsList.add(new SelectOption(oli.Id,oli.Product2.Name));
    }

    /**
    * Mohammad G.
    * taskid
    * @method retreiveControllingMetadata
    * @return {Pagereference} current request form page with the request controlling fields
    */
    public PageReference retreiveControllingMetadata(){

        firstPicklistIndex = null;

        system.debug(Logginglevel.ERROR,'>>> sourceObjType: ' + sourceObjType);

        list<RequestConfig__c> reqConfigList = [select FieldOrder__c, FieldLabel__c, FieldType__c, PicklistOptions__c, FieldSourceObject__c, FieldSourcePath__c,
                                                       FieldSourceIdentifier__c, FieldSourceCriteria__c
                                                from RequestConfig__c
                                                where RequestType__c =: request.Type__c and (ObjectType__c =: sourceObjType or ObjectType__c = '') Order by FieldOrder__c ASC];
        system.debug(Logginglevel.ERROR,'>>> reqConfigList: ' + reqConfigList.size());

        if(reqConfigList.isEmpty() || reqConfigList.size() > 3){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,reqConfigList.isEmpty() ? Label.RequesNoFieldsError : Label.RequesMoreThan3FieldsError));
            return null;
        }

        controllingFieldsList = new list<controllingFieldWrapper>();

        try{
            Integer i = 0;
            for(RequestConfig__c rConfig : reqConfigList){

                system.debug('>>> rConfig.FieldLabel__c: ' + rConfig.FieldLabel__c);
                if(!isValidConfig(rConfig)){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.RequestConfigMistakes));
                    return null;
                }

                controllingFieldWrapper cWrap = new controllingFieldWrapper(rConfig,i+1);
                if(rConfig.FieldType__c == 'Picklist' && firstPicklistIndex == null){
                    firstPicklistIndex = i;
                    cWrap.picklistValues.add(new SelectOption('',''));
                }

                if(isValidSource(rConfig)){
                    //the values will be taken from the specified source (Picklist: look for values from list of records. Output: look for a field in one record)
                    list<String> pathList = rConfig.FieldSourcePath__c.split('\\.');
                    Schema.DescribeFieldResult fieldDescribe = getFieldResult(rConfig.FieldSourceObject__c, pathList);
                    Boolean isPicklist = String.valueOf(fieldDescribe.getType()).equalsIgnoreCase('PICKLIST');

                    String query = 'select id, ' + rConfig.FieldSourcePath__c + ' from ' + rConfig.FieldSourceObject__c;
                    if(!String.isEmpty(rConfig.FieldSourceCriteria__c))
                        query += ' where ' + rConfig.FieldSourceCriteria__c + ' = \'' + (String)request.get(rConfig.FieldSourceIdentifier__c) + '\'';
                    system.debug(Logginglevel.ERROR,'>>> query: ' + query);
                    list<SObject> sourceList = Database.query(query);
                    for(SObject sObj : sourceList){
                        //get the field value from the query results
                        for(Integer j=0 ; j < pathList.size()-1 ; j++)
                            sObj = sObj.getSobject(pathList[j]);

                        //if picklist, go over all the records
                        if(rConfig.FieldType__c == 'Picklist'){
                            //cWrap.picklistValues.add(new SelectOption((String)sObj.get(pathList[pathList.size()-1]), (String)sObj.get(pathList[pathList.size()-1])));
                            if(!cWrap.picklistValuesSet.contains((String)sObj.get(pathList[pathList.size()-1])))
                                cWrap.picklistValuesSet.add((String)sObj.get(pathList[pathList.size()-1]));
                        }
                        //if output, it suppose to be one record, so break after the first record
                        else if(rConfig.FieldType__c == 'Output'){
                            cWrap.fieldValue = (String)sObj.get(pathList[pathList.size()-1]);
                            cWrap.fieldValueLabel = cWrap.fieldValue;
                            //if picklist, get the label
                            if(isPicklist){
                                for(Schema.PicklistEntry entry : fieldDescribe.getPickListValues()){
                                    if(entry.getValue() != cWrap.fieldValue)    continue;
                                    cWrap.fieldValueLabel = entry.getLabel();
                                }
                            }
                            break;
                        }
                        system.debug(Logginglevel.ERROR,'>>> cWrap.picklistValuesSet: ' + cWrap.picklistValuesSet);
                    }
                }
                controllingFieldsList.add(cWrap);
                i++;
            }

            //build Dependencies JSON
            dependenciesJSON = buildDependenciesJSON();
            system.debug('JSON: ' + dependenciesJSON);
            if(dependenciesJSON == ''){
                //there are no available details fields...
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no available details fields.'));
                return null;
            }
            step = '3';
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() + ' ---  ' + ex.getStackTraceString()));
        }
        return null;
    }

    /**
    * Mohammad G.
    * taskid
    * @method buildDependenciesJSON
    * @return {String}
    */
    private String buildDependenciesJSON(){
        //get exisintg values from the RequestDetailsConfig__c
        String Query = 'select id, ControllingValue1__c, ControllingValue2__c, ControllingValue3__c ' +
                       'from RequestDetailsConfig__c ' +
                       'where RequestType__c = \'' + request.Type__c + '\'' +
                       (controllingFieldsList[0].rConfig.FieldType__c == 'Output' ? ' and ControllingValue1__c = \'' + controllingFieldsList[0].fieldValue + '\'' : '') +
                       ((controllingFieldsList.size() > 1) && (controllingFieldsList[1].rConfig.FieldType__c == 'Output') ? ' and ControllingValue2__c = \'' + controllingFieldsList[1].fieldValue + '\'' : '') +
                       ((controllingFieldsList.size() > 2) && (controllingFieldsList[2].rConfig.FieldType__c == 'Output') ? ' and ControllingValue3__c = \'' + controllingFieldsList[2].fieldValue + '\'' : '');

        system.debug(Logginglevel.ERROR,'>>> details Query: ' + Query);

        list<RequestDetailsConfig__c> RequestDetailsConfigList = Database.Query(Query);
        system.debug(Logginglevel.ERROR,'>>> RequestDetailsConfigList size: ' + RequestDetailsConfigList.size());
        if(RequestDetailsConfigList.isEmpty())
            return '';

        map<String,map<String,set<String>>> picklistsDependenciesMap = new map<String,map<String,set<String>>>();

        for(RequestDetailsConfig__c rdConfig : RequestDetailsConfigList){

            String cValue1,cValue2,cValue3;
            system.debug(Logginglevel.ERROR,'>>> picklist set[0]: ' + controllingFieldsList[0].picklistValuesSet);
            if(!controllingFieldsList[0].picklistValuesSet.isEmpty() && !controllingFieldsList[0].picklistValuesSet.contains(rdConfig.ControllingValue1__c))
                continue;
            cValue1 = controllingFieldsList[0].rConfig.FieldType__c == 'Output' ? controllingFieldsList[0].fieldValueLabel : rdConfig.ControllingValue1__c;
            if(!picklistsDependenciesMap.containsKey(cValue1)){
                picklistsDependenciesMap.put(cValue1,new map<String,set<String>>());

                if(firstPicklistIndex == 0)
                    controllingFieldsList[0].picklistValues.add(new SelectOption(cValue1, cValue1));
            }

            if(controllingFieldsList.size() > 1){
                system.debug(Logginglevel.ERROR,'>>> picklist set[1]: ' + controllingFieldsList[1].picklistValuesSet);
                if(!controllingFieldsList[1].picklistValuesSet.isEmpty() && !controllingFieldsList[1].picklistValuesSet.contains(rdConfig.ControllingValue2__c))
                    continue;

                cValue2 = controllingFieldsList[1].rConfig.FieldType__c == 'Output' ? controllingFieldsList[1].fieldValueLabel : rdConfig.ControllingValue2__c;
                if(!picklistsDependenciesMap.get(cValue1).containsKey(cValue2)){
                    picklistsDependenciesMap.get(cValue1).put(cValue2,new set<String>());

                    if(firstPicklistIndex == 1)
                        controllingFieldsList[1].picklistValues.add(new SelectOption(cValue2, cValue2));
                }
            }

            if(controllingFieldsList.size() > 2){
                system.debug(Logginglevel.ERROR,'>>> picklist set[2]: ' + controllingFieldsList[2].picklistValuesSet);
                if(!controllingFieldsList[2].picklistValuesSet.isEmpty() && !controllingFieldsList[2].picklistValuesSet.contains(rdConfig.ControllingValue3__c))
                    continue;

                cValue3 = controllingFieldsList[2].rConfig.FieldType__c == 'Output' ? controllingFieldsList[2].fieldValueLabel : rdConfig.ControllingValue3__c;
                if(!picklistsDependenciesMap.get(cValue1).get(cValue2).contains(cValue3)){
                    picklistsDependenciesMap.get(cValue1).get(cValue2).add(cValue3);

                    if(firstPicklistIndex == 2)
                        controllingFieldsList[2].picklistValues.add(new SelectOption(cValue3, cValue3));
                }
            }
        }
        return JSON.serialize(picklistsDependenciesMap);
    }

    /**
    * Mohammad G.
    * taskid
    * @method getFieldResult
    * @return {Schema.DescribeFieldResult}
    */
    private Schema.DescribeFieldResult getFieldResult(String strObject, list<String> pathList){
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(strObject).getDescribe();
        Schema.DescribeFieldResult fieldDescribe;
        for(integer k = 0 ; k < pathList.size() - 1 ; k++){
            String fieldStr = pathList[k];
            if(fieldStr.endsWith('__r'))
                fieldStr = fieldStr.replace('__r','__c');
            else
                fieldStr += 'Id';
            fieldDescribe = objDescribe.fields.getMap().get(fieldStr).getDescribe();
            objDescribe = fieldDescribe.getReferenceTo()[0].getDescribe();
        }
        fieldDescribe = objDescribe.fields.getMap().get(pathList[pathList.size()-1]).getDescribe();
        return fieldDescribe;
    }

    /**
    * Mohammad G.
    * taskid
    * @method isValidConfig
    * @return {Boolean} if request config is valid
    */
    private Boolean isValidConfig(RequestConfig__c rConfig){
        if( String.isEmpty(rConfig.FieldLabel__c) ||
            (rConfig.FieldType__c == 'Picklist' && isContainSource(rConfig) && !isValidSource(rConfig)) ||
            (rConfig.FieldType__c == 'Output' && !isValidSource(rConfig))
          )
            return false;
        return true;
    }

    /**
    * Mohammad G.
    * taskid
    * @method isContainSource
    * @return {Boolean} if request config contains source
    */
    private Boolean isContainSource(RequestConfig__c rConfig){
        if(String.isNotEmpty(rConfig.FieldSourceObject__c) || String.isNotEmpty(rConfig.FieldSourcePath__c) || String.isNotEmpty(rConfig.FieldSourceIdentifier__c) || String.isNotEmpty(rConfig.FieldSourceCriteria__c))
            return true;
        return false;
    }

    /**
    * Mohammad G.
    * taskid
    * @method isValidSource
    * @return {Boolean} if request config source is valid
    */
    private Boolean isValidSource(RequestConfig__c rConfig){
        if(String.isEmpty(rConfig.FieldSourceObject__c) || String.isEmpty(rConfig.FieldSourcePath__c) || String.isEmpty(rConfig.FieldSourceIdentifier__c) || String.isEmpty(rConfig.FieldSourceCriteria__c))
            return false;
        return true;
    }

    /**
    * Mohammad G.
    * taskid
    * @method startFlowBasedOnCategory
    * @return {PageReference}
    */
    public PageReference startFlowBasedOnCategory(){
        if(String.isBlank(request.Category__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.RequestCategoryMissing));
            return null;
        }

        if(request.ProductLineItemId__c != null){
            for(SelectOption so : productsList)
                if(so.getValue() == request.ProductLineItemId__c){
                    request.Product__c = so.getLabel();
                    break;
                }
        }
        else
            request.Product__c = '';

        //Commercial, Operative
        if(request.Category__c == 'Operative'){
            //standard flow with one request
            step = '2';
        }
        else{
            //parent request with number of requests
            childRequestsList = new list<Request__c>();
            childRequestsList.add(new Request__c(Order__c = 1, Type__c = 'Approval Request', Category__c = 'Commercial', OpportunityId__c = request.OpportunityId__c, CaseId__c = request.CaseId__c));
            step = '100';
        }
        return null;
    }

    /**
    * Mohammad G.
    * taskid
    * @method addRequest
    * @return {PageReference}
    */
    public PageReference addRequest(){
        childRequestsList.add(new Request__c(Order__c = childRequestsList.size() + 1, Type__c = 'Approval Request', Category__c = 'Commercial', OpportunityId__c = request.OpportunityId__c, CaseId__c = request.CaseId__c, Account__c = request.Account__c));
        return null;
    }

    /**
    * Mohammad G.
    * taskid
    * @method deleteRequest
    * @return {PageReference}
    */
    public PageReference deleteRequest(){
        system.debug(Logginglevel.ERROR,'>>> requestIndexToDelete: ' + requestIndexToDelete);
        childRequestsList.remove(requestIndexToDelete-1);
        integer i = 1;
        for(Request__c req : childRequestsList){
            req.Order__c = i;
            i++;
        }
        return null;
    }

    /**
    * Mohammad G.
    * taskid
    * @method retreiveFieldsMetadata
    * @return {PageReference} current request form page with the request dynamic fields
    */
    public PageReference retreiveFieldsMetadata(){
        system.debug('>>> retreiveFieldsMetadata: ' + request.OwnerId + ' -- ' + cont1Val + ' -- ' + cont2Val + ' -- ' + cont3Val);
        alignControllingFieldsParams();

        requestDetailsWrapList = new list<requestDetailsWrapper>();
        String Query = 'select id, FieldLabel__c, FieldType__c, FieldOrder__c, PicklistOptions__c, IsMandatory__c, URL__c, SLA__c, QueueSFDCID__c, OldRequestCode__c ' +
                       'from RequestDetailsConfig__c ' +
                       'where RequestType__c = \'' + request.Type__c + '\' and ' +
                       'ControllingValue1__c = \'' + controllingFieldsList[0].fieldValue + '\' and ' +
                       'ControllingValue2__c = ' + (controllingFieldsList.size() > 1 ? '\'' + controllingFieldsList[1].fieldValue + '\'' : 'null') + ' and ' +
                       'ControllingValue3__c = ' + (controllingFieldsList.size() > 2 ? '\'' + controllingFieldsList[2].fieldValue + '\'' : 'null') +
                       ' Order by FieldOrder__c ASC';

        system.debug(Logginglevel.ERROR,'>>> fields Query : ' + Query);

        list<RequestDetailsConfig__c> RequestDetailsConfigList = Database.Query(Query);
        if(RequestDetailsConfigList.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.RequestNoFields));
        }
        else{
            isURL = false;
            for(RequestDetailsConfig__c rdConfig : RequestDetailsConfigList){
                if(rdConfig.FieldType__c == 'Data'){
                    request.SLA__c = rdConfig.SLA__c != null ? rdConfig.SLA__c : request.SLA__c;
                    if(String.isNotBlank(rdConfig.QueueSFDCID__c)){
                        list<Group> queueList = [select Id, DeveloperName from Group where DeveloperName =: rdConfig.QueueSFDCID__c and Type = 'Queue' limit 1];
                        if(!queueList.isEmpty())
                            request.OwnerId = queueList[0].Id;
                    }
                    //select Id from Group where Name = 'My Group' and Type = 'Queue'
                    //request.OwnerId = !String.isBlank(rdConfig.QueueSFDCID__c) ? rdConfig.QueueSFDCID__c : request.OwnerId;
                    request.OldRequestCode__c = !String.isBlank(rdConfig.OldRequestCode__c) ? rdConfig.OldRequestCode__c : request.OldRequestCode__c;
                    continue;
                }
                if(rdConfig.FieldType__c == 'URL'){
                    requestDetailsWrapList.clear();
                    requestDetailsWrapList.add(new requestDetailsWrapper(rdConfig));
                    //get the account ban
                    /*
                    String ban = null;
                    if(opp != null && opp.Account.Cell_Ind__c && String.isNotBlank(opp.Account.BANPSID__c))
                        ban = opp.Account.BANPSID__c;
                    else if(c != null && c.Account.Cell_Ind__c && String.isNotBlank(c.Account.BANPSID__c))
                        ban = c.Account.BANPSID__c;
                    //else{
                    //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.AccountCannotBeOpenedInAmdocs));
                    //    return null;
                    //}
                    //get the user federation Id
                    String fedId = [select FederationIdentifier from User where Id =: UserInfo.getUserId() limit 1].FederationIdentifier;
                    requestDetailsWrapList[0].rDetails.FieldValue__c = 'AMDOCS/request.aspx?user_id='+fedId+'&app_code=CSM&act_code=31&fu_type=' + request.OldRequestCode__c + (String.isNotBlank(ban) ? '&ban='+ban : '');
                    */
                    isURL = true;
                    continue;
                }
                if(!isURL)
                    requestDetailsWrapList.add(new requestDetailsWrapper(rdConfig));
            }

            if(isURL)
            	step = '3.5';
            else
            	step = '4';
        }
        return null;
    }
    
    
    public void buildBaseURL(){
    	String fedId = [select FederationIdentifier from User where Id =: UserInfo.getUserId() limit 1].FederationIdentifier;
        requestDetailsWrapList[0].rDetails.FieldValue__c = 'AMDOCS/request.aspx?user_id='+fedId+'&app_code=CSM&act_code=31&fu_type=' + request.OldRequestCode__c + (String.isNotBlank(urlBan) ? '&ban='+urlBan : '');
        step = '4';
        //return null;
    }

    /**
    * Mohammad G.
    * taskid
    * @method alignControllingFieldsParams
    * @return {void}
    */
    public void alignControllingFieldsParams(){
        if(controllingFieldsList.size() > 0){
            if(controllingFieldsList[0].rConfig.FieldType__c == 'Picklist'){
                controllingFieldsList[0].fieldValue = cont1Val;
                controllingFieldsList[0].fieldValueLabel = cont1Val;
            }
            else
                cont1Val = controllingFieldsList[0].fieldValueLabel;
        }
        if(controllingFieldsList.size() > 1){
            if(controllingFieldsList[1].rConfig.FieldType__c == 'Picklist'){
                controllingFieldsList[1].fieldValue = cont2Val;
                controllingFieldsList[1].fieldValueLabel = cont2Val;
            }
            else
                cont2Val = controllingFieldsList[1].fieldValueLabel;
        }
        if(controllingFieldsList.size() > 2){
            if(controllingFieldsList[2].rConfig.FieldType__c == 'Picklist'){
                controllingFieldsList[2].fieldValue = cont3Val;
                controllingFieldsList[2].fieldValueLabel = cont3Val;
            }
            else
                cont3Val = controllingFieldsList[2].fieldValueLabel;
        }
    }

    /**
    * Mohammad G.
    * taskid
    * @method createRequest
    * @return {PageReference} request view or to the URL from the request details config.
    */
    public PageReference createRequest(){
        request.Status__c = 'In Process';
        for(Integer i=0 ; i < controllingFieldsList.size() ; i++){
            controllingFieldWrapper controllingField = controllingFieldsList[i];
            request.put('FieldLabel' + String.valueOf(i+1) + '__c', controllingField.rConfig.FieldLabel__c);
            request.put('FieldValue' + String.valueOf(i+1) + '__c', controllingField.fieldValueLabel);
        }

        if(request.SLA__c != null)
            request.DueDate__c = addWorkingMinutes(Datetime.now(), Integer.valueOf(request.SLA__c));

        if(request.OwnerId == null && !Test.isRunningTest()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.RequestOwnershipError));
            return null;
        }

        insert request;

        list<RequestDetails__c> rDetailsList = new list<RequestDetails__c>();
        for(requestDetailsWrapper detailsField : requestDetailsWrapList){
            detailsField.rDetails.RequestId__c=request.Id;
            if(detailsField.rDetails.DateInput__c != null)
                detailsField.rDetails.FieldValue__c = detailsField.rDetails.DateInput__c.format();//String.valueOf(detailsField.rDetails.DateInput__c);
            else if(detailsField.rDetails.NumberInput__c != null){
                detailsField.rDetails.FieldValue__c = String.valueOf(detailsField.rDetails.NumberInput__c);
            }
            rDetailsList.add(detailsField.rDetails);
        }
        insert rDetailsList;
        shareRequestToCurrentUser();
        shareOppCaseToOwners();
        PageReference retPage = null;
        ////if(!isURL)
        ////    retPage = new PageReference('/' + request.Id);
        /*else{
            retPage = new PageReference(rDetailsList[0].FieldValue__c);
        }
        */
        //retPage = new PageReference('/' + request.Id);
        //retPage.setRedirect(true);
        //return retPage;
        return retPage;
    }

    /**
    * Mohammad G.
    * taskid
    * @method createCommercialRequest
    * @return {PageReference} parent request view
    */
    public PageReference createCommercialRequest(){
        if(childRequestsList.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.RequestMissingChilds));
            return null;
        }

        String queryStr = 'select ControllingValue1__c, ControllingValue2__c, SLA__c, QueueSFDCID__c from RequestDetailsConfig__c where RequestType__c = \'Approval Request\' and (';
        
        request.Type__c = 'Approval Request';
        for(Request__c req : childRequestsList)
            queryStr += ' (ControllingValue1__c = \'' + req.Approver__c + '\' and ControllingValue2__c = \'' + req.ApprovalType__c + '\') or';
        queryStr = queryStr.removeEndIgnoreCase(' or');
        queryStr += ')';

        list<RequestDetailsConfig__c> RequestDetailsConfigList = Database.Query(queryStr);

        map<Request__c,String> requestQueuesDevNamesMap = new map<Request__c,String>();
        map<String,Id> queuesIdsMap = new map<String,Id>();

        User currentUser = [select Id, ManagerId, Manager.ManagerId from User where Id =: UserInfo.getUserId() limit 1];

        //set the SLA for the first child, and collect the queues DEV name
        Boolean firstChild = true;
        for(Request__c req : childRequestsList){
            req.Status__c = 'Hold';
            req.Account__c = request.Account__c;
            req.OppProductId__c = request.OppProductId__c;
            req.OpportunityId__c = request.OpportunityId__c;
            req.Product__c = request.Product__c;
            req.ProductLineItemId__c = request.ProductLineItemId__c;
            req.Source__c = request.Source__c;
            
            if(req.Approver__c == 'Direct Manager' && currentUser.ManagerId != null)
                req.OwnerId = currentUser.ManagerId;
            else if(req.Approver__c == 'Indirect Manager' && currentUser.Manager.ManagerId != null)
                req.OwnerId = currentUser.Manager.ManagerId;

            for(RequestDetailsConfig__c rdConf : RequestDetailsConfigList){
                if(req.Approver__c == rdConf.ControllingValue1__c && req.ApprovalType__c == rdConf.ControllingValue2__c){
                    req.SLA__c = rdConf.SLA__c;
                    if(firstChild && req.SLA__c != null)
                        req.DueDate__c = addWorkingMinutes(Datetime.now(), Integer.valueOf(req.SLA__c));
                    //req.OwnerId = rdConf.QueueSFDCID__c;
                    if(req.Approver__c != 'Direct Manager' && req.Approver__c != 'Indirect Manager' && String.isNotBlank(rdConf.QueueSFDCID__c))
                        requestQueuesDevNamesMap.put(req,rdConf.QueueSFDCID__c);
                    break;
                }
            }
            firstChild = false;
        }

        //get the queues Ids
        if(!requestQueuesDevNamesMap.isEmpty()){
            list<Group> queueList = [select Id, DeveloperName from Group where DeveloperName IN: requestQueuesDevNamesMap.values() and Type = 'Queue'];
            for(Group q : queueList)
                queuesIdsMap.put(q.DeveloperName,q.Id);
        }

        //assigne the childs
        if(!queuesIdsMap.isEmpty()){
            for(Request__c req : childRequestsList){
                if(!requestQueuesDevNamesMap.containsKey(req))    continue;
                if(queuesIdsMap.containsKey(requestQueuesDevNamesMap.get(req)))
                    req.OwnerId = queuesIdsMap.get(requestQueuesDevNamesMap.get(req));
            }
        }

        //validate childs ownership
        for(Request__c req : childRequestsList){
            if(req.OwnerId == null && !Test.isRunningTest()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.RequestOwnershipError));
                return null;
            }
        }

        childRequestsList[0].Status__c = 'In Process';
        request.Status__c = 'In Process';
        request.Type__c = 'Approval Request';
        if(childRequestsList[0].OwnerId != null)
            request.OwnerId = childRequestsList[0].OwnerId;
        
        Savepoint sp = Database.setSavepoint();
        DatabaseManager.DatabaseResult parentResult = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION,new list<Request__c>{request},true);
        if(!parentResult.isSuccess())
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to create parent request: \n' + parentResult.getAllErrorMessages('\n')));
        else{
            for(Request__c req : childRequestsList)
                req.ParentRequestId__c = request.Id;
            DatabaseManager.DatabaseResult childResult = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION,childRequestsList,true);
            if(!childResult.isSuccess()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to create child requests: \n' + childResult.getAllErrorMessages('\n')));
                Database.rollback(sp);
                request.Id = null;
            }
            else{
                if(String.isNotBlank(request.ProductLineItemId__c)){
                    DatabaseManager.DatabaseResult oliResult = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,new list<OpportunityLineItem>{new OpportunityLineItem(Id=request.ProductLineItemId__c,CommercialRequestStatus__c = request.Status__c)},true);
                    if(!oliResult.isSuccess()){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to update product status: \n' + oliResult.getAllErrorMessages('\n')));
                        Database.rollback(sp);
                        request.Id = null;
                        return null;
                    }
                }
                shareRequestToCurrentUser();
                shareOppCaseToOwners();
                PageReference retPage = new PageReference('/' + request.Id);
                retPage.setRedirect(true);
                ////return retPage;
                return null;
            }
        }
        return null;
    }
    
    
    /**
    * Mohammad G.
    * taskid
    * @method shareRequestToCurrentUser
    * @return {void} 
    */
    private void shareRequestToCurrentUser(){
        list<Request__Share> rShareList = new list<Request__Share>();
        
        //share parent
        rShareList.add(new Request__Share(ParentId = request.Id, UserOrGroupId = UserInfo.getUserId(), AccessLevel = 'Read', RowCause = Schema.Request__Share.RowCause.RequestCreator__c));
        
        //share childs
        if(childRequestsList != null && childRequestsList.size() > 0)
        	for(Request__c r : childRequestsList)
        		rShareList.add(new Request__Share(ParentId = r.Id, UserOrGroupId = UserInfo.getUserId(), AccessLevel = 'Read', RowCause = Schema.Request__Share.RowCause.RequestCreator__c));
        
        list<Database.SaveResult> srList = Database.insert(rShareList,false);
        for(Database.SaveResult sr : srList){
	        if(!sr.isSuccess()){
	            Database.Error err = sr.getErrors()[0];
	            // Check if the error is related to trival access level.
	            // Access level must be more permissive than the object's default.
	            // These sharing records are not required and thus an insert exception is acceptable.
	            if(err.getStatusCode() != StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION || !err.getMessage().contains('AccessLevel'))
	                system.debug(Logginglevel.ERROR,'Faild to share the Request to the creator: ' + err.getMessage());
	        }
    	}
    }
    
    
    /**
    * Mohammad G.
    * taskid
    * @method shareOppCaseToOwners
    * @return {void} 
    */
    private void shareOppCaseToOwners(){
        system.debug('>>> RequestFormController.shareOppCaseToOwners started...');
        list<Id> queueIdsList = new list<Id>();
        list<GroupMember> groupMembersList = new list<GroupMember>();
        set<Id> idsToShareWith = new set<Id>();
        //list<OpportunityShare> oppShareList = new list<OpportunityShare>();
        list<SObject> sharingRecordsList = new list<SObject>();
        
        //the first child has the same owner like the parent, so no need to get the parent owner
        if(childRequestsList != null && childRequestsList.size() > 0){
        	for(Request__c r : childRequestsList){
        		if(r.OwnerId != null && String.valueOf(r.OwnerId).startsWith('00G'))
        			queueIdsList.add(r.OwnerId);
        		else if(!idsToShareWith.contains(r.OwnerId))
        			idsToShareWith.add(r.OwnerId);
        	}
        }
        else{
        	system.debug('>>> RequestFormController.shareOppCaseToOwners request.OwnerId: ' + request.OwnerId);
        	if(request.OwnerId != null && String.valueOf(request.OwnerId).startsWith('00G'))
        		queueIdsList.add(request.OwnerId);
        	else
        		idsToShareWith.add(request.OwnerId);
        }
        
        if(!queueIdsList.isEmpty())
        	groupMembersList = [select UserOrGroupId from GroupMember where GroupId IN: queueIdsList];
        
        for(GroupMember gm : groupMembersList)
        	if(!idsToShareWith.contains(gm.UserOrGroupId))
        		idsToShareWith.add(gm.UserOrGroupId);
        
        system.debug('>>> RequestFormController.shareOppCaseToOwners idsToShareWith: ' + idsToShareWith);
        
        for(Id idToShare : idsToShareWith){
        	if(request.OpportunityId__c != null){
	        	OpportunityShare oppShare = new OpportunityShare();
	        	oppShare.UserOrGroupId = idToShare;
	        	oppShare.OpportunityId = request.OpportunityId__c;
	        	oppShare.OpportunityAccessLevel = 'Edit';
	        	oppShare.RowCause = 'Manual';
	        	sharingRecordsList.add(oppShare);
        	}
        	else if(request.CaseId__c != null){
        		CaseShare caseShare = new CaseShare();
        		caseShare.UserOrGroupId = idToShare;
	        	caseShare.CaseId = request.CaseId__c;
	        	caseShare.CaseAccessLevel = 'Read';
	        	caseShare.RowCause = 'Manual';
	        	sharingRecordsList.add(caseShare);
	        	
	        	if(c.Opportunity__r.Id != null){
    	        	OpportunityShare oppShare = new OpportunityShare();
    	        	oppShare.UserOrGroupId = idToShare;
    	        	oppShare.OpportunityId = c.Opportunity__r.Id;
    	        	oppShare.OpportunityAccessLevel = 'Edit';
    	        	oppShare.RowCause = 'Manual';
    	        	sharingRecordsList.add(oppShare);
	        	}
        	}
        }
        
        if(!sharingRecordsList.isEmpty()){
        	list<Database.SaveResult> resultsList = Database.insert(sharingRecordsList,false);
        	for(Database.SaveResult result : resultsList){
	        	if(!result.isSuccess()){
	            	Database.Error err = result.getErrors()[0];
	            	// Check if the error is related to trival access level.
	            	// Access level must be more permissive than the object's default.
	            	// These sharing records are not required and thus an insert exception is acceptable.
	            	if(err.getStatusCode() != StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION || !err.getMessage().contains('AccessLevel'))
	                	system.debug(Logginglevel.ERROR,'Faild to share the Request to the creator: ' + err.getMessage());
	        	}
        	}
        }
    }

    /**
    * Mohammad G.
    * taskid
    * @method back
    * @return {PageReference} current request form prev step.
    */
    public PageReference back(){
        if(step == '4'){
            request.OwnerId = null;//UserInfo.getUserId();
            if(isURL)
            	step = '3.5';
            else
            	step = '3';
        }
        else if(step == '3.5'){
        	urlBan = '';
        	step = '3';
        }
        else if(step == '3'){
            step = '2';
        }
        else{
            step = '1';
        }
        return null;
    }

    /**
    * Mohammad G.
    * taskid
    * @method cancel
    * @return {PageReference}
    */
    public PageReference cancel(){
        if(request.OpportunityId__c == null && request.CaseId__c == null)
            return sc.cancel();
        String returnId = request.CaseId__c != null ? request.CaseId__c : request.OpportunityId__c;
        PageReference returnPage = new PageReference('/' + returnId);
        returnPage.setRedirect(true);
        return returnPage;
    }

    public Static Datetime addWorkingMinutes(Datetime dt, Integer minutes){

        Integer startWorkingHour = 8;
        Integer endWorkingHour = 18;

        Integer dailyMinutes = (endWorkingHour - startWorkingHour) * 60;

        Date today = Date.today();

        Datetime todayStart = Datetime.newInstance(today.year(), today.month(), today.day(), startWorkingHour, 0, 0);
        Datetime todayEnd = Datetime.newInstance(today.year(), today.month(), today.day(), endWorkingHour, 0, 0);

        Integer dayOfWeek = math.mod(date.newinstance(1900,7,1).daysBetween(today) + 1, 7);

        Datetime dueDatetime;

        system.debug('>>> todayStart: ' + todayStart);
        system.debug('>>> todayEnd: ' + todayEnd);
        system.debug('>>> dt: ' + dt);
        system.debug('>>> dayOfWeek: ' + dayOfWeek);
        system.debug('>>> dailyMinutes: ' + dailyMinutes);

        if(dayOfWeek > 5){
            //Weekend
            dueDatetime = dayOfWeek == 6 ? todayStart.addDays(2) : todayStart.addDays(1);
        }
        else{
            if(dt < todayStart){
                dueDatetime = todayStart;
            }
            else if(dt < todayEnd){
                Integer todayMinutes = Integer.valueOf((todayEnd.getTime() - dt.getTime())/60000);
                system.debug('>>> todayMinutes: ' + todayMinutes);
                //check if the dueDatetime is today.
                if(todayMinutes >= minutes){
                    dueDatetime = dt.addMinutes(minutes);
                    return dueDatetime;
                }
                //dueDatetime is not today, calc the extra minutes
                minutes -= todayMinutes;
                dueDatetime = todayStart.addDays(1);
            }
            else{
                dueDatetime = todayStart.addDays(1);
            }
        }

        dayOfWeek = math.mod(date.newinstance(1900,7,1).daysBetween(date.newinstance(dueDatetime.year(),dueDatetime.month(),dueDatetime.day())) + 1, 7);

        while(minutes > 0){
            //if weekend, move to the start of the week
            if(dayOfWeek > 5){
                dueDatetime = dayOfWeek == 6 ? dueDatetime.addDays(2) : dueDatetime.addDays(1);
                dayOfWeek = 1;
                continue;
            }
            if(minutes > dailyMinutes){
                dueDatetime = dueDatetime.addDays(1);
                minutes -= dailyMinutes;
            }
            else{
                dueDatetime = dueDatetime.addMinutes(minutes);
                minutes = 0;
            }
        }

        return dueDatetime;
    }

    public Class controllingFieldWrapper{
        public RequestConfig__c rConfig{get;set;}
        public String fieldValue{get;set;}
        public String fieldValueLabel{get;set;}
        public List<SelectOption> picklistValues{get;set;}
        public set<String> picklistValuesSet{get;set;}
        public Integer rowIndex{get;set;}

        public controllingFieldWrapper(RequestConfig__c rConfig, Integer rowIndex){
            this.rConfig = rConfig;
            this.rowIndex = rowIndex;
            this.fieldValue = '';
            this.picklistValues = new List<SelectOption>();
            //this.picklistValues.add(new SelectOption('', ''));
            this.picklistValuesSet = new set<String>();
        }
    }

    public Class requestDetailsWrapper{
        public RequestDetailsConfig__c rdConfig{get;set;}
        public RequestDetails__c rDetails{get;set;}
        public list<SelectOption> picklistValues{get;set;}

        public requestDetailsWrapper(RequestDetailsConfig__c rdConfig){
            this.rdConfig = rdConfig;
            this.rDetails= new RequestDetails__c(FieldLabel__c=rdConfig.FieldLabel__c);
            //if(rdConfig.FieldType__c == 'URL')
            //    rDetails.FieldValue__c = rdConfig.URL__c;
            if(rdConfig.FieldType__c == 'Picklist'){
                this.picklistValues = new List<SelectOption>();
                this.picklistValues.add(new SelectOption('', ''));
                for(String value : rdConfig.PicklistOptions__c.split(';'))
                    this.picklistValues.add(new SelectOption(value, value));
            }
        }
    }
}