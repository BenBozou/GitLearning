/**
* controller for SearchScreen page.
* Author Tal Sabati
* Taskid PLR-683
* @class SearchScreenController 
* @module 360
* @constructor SearchScreenController
*/

public with sharing class SearchScreenController{ 
    public Map<id, AccountWithContactsList> accountMap {get;set;} 
    public integer accountMapSize {get;set;} 
    public Map<id, ContactWithAccountsList> contactMap {get;set;}
    public integer contactMapSize {get;set;} 
    public List<Lead> leadList {get;set;}
    public string searchValue {get;set;}  
    public Map<string, List<SearchScreenCategory__mdt>> categoriesMap {get;set;}  
    public String mapCategoriesJSON {get;set;}
    public string subCategory {get;set;}
    public Map<string, string> cellcomExternalIdsMap {get;set;}
    public string urlSubTab{get;set;}
    private Map<string, string> subCategoryAndParameterCodeMap;
    public string errorMessage {get;set;} 
    private integer limitSearchResulte {get;set;} 
    public Boolean isThereCurrentCustomer {get;set;} 
    public Boolean isThereHistoricalCustomer {get;set;}
    /**
    *  Constructor
    *  @method SearchScreenController
    */
    public SearchScreenController() {
        initSearchResults();
        setVariablesByUrl();
        getCategories();
    }
    /**
    *   Select search categories from Custom Metadata Types - Search Screen Category  
    *   @method getCategories
    *   @return {void}
    */
    private void getCategories(){
        boolean isPartner = checkPartnerUser();
        categoriesMap = new Map<string,List<SearchScreenCategory__mdt>>();
        subCategoryAndParameterCodeMap = new Map<string,string>();
        list<SearchScreenCategory__mdt> SearchScreenCategoryList = [Select Label, Category__c, Parameter__c, ParameterCode__c, AvailableForPartner__c, Order__c From SearchScreenCategory__mdt order by Order__c];
        for(SearchScreenCategory__mdt c : SearchScreenCategoryList){
            if( !isPartner || (isPartner && c.AvailableForPartner__c)){
                subCategoryAndParameterCodeMap.put(c.Parameter__c, c.ParameterCode__c);
                if(categoriesMap.containskey(c.Category__c)){
                    categoriesMap.get(c.Category__c).add(c);
                }
                else{
                    categoriesMap.put(c.Category__c, new List<SearchScreenCategory__mdt>{c});
                }
            }
        }
        mapCategoriesJSON = JSON.serialize(categoriesMap);
    }
    /**
    *   Check if the current user is partner user
    *   @method checkPartnerUser
    *   @return {Boolean} isPartner
    */
    private Boolean checkPartnerUser(){
        User currentUser = [SELECT Id, ContactId FROM user WHERE id = :UserInfo.getUserId()];
        if(currentUser.ContactId == null){
            return false;
        }
        return true;
    }
    /**
    *   Select search action method, returns an error if no category selected
    *   @method search
    *   @return {void}
    */
    public void search(){  
       try{
            searchValue = searchValue.normalizeSpace();
            initSearchResults(); 
            Boolean isInternalSearch = getAccountsAndContactBySubCategory();
            if(isInternalSearch && contactMap.isEmpty() && accountMap.isEmpty()){   
                Map<String,Object> response = calloutOSB('00713', 'api/services/rest/00713_osb_searchnoresultmanagment_k2view');
                setErrorMessageBasedOnResponse(response);
            } 
            LoggerService.commitAllLogs();
            
        } catch(Exception e) {
            system.debug(Logginglevel.ERROR, 'Exception:' +e.getMessage() +' StackTraceString :'+ e.getStackTraceString());            
            errorMessage = 'שגיאה בחיפוש';
        }
    }
    /**
    *   Method for set error message based on response from external systems
    *   @method setErrorMessageBasedOnResponse
    *   @param {Map<String,Object>} response
    *   @return {void}
    */
    private void setErrorMessageBasedOnResponse(Map<String,Object> response){
        if(response != null){
            if(response.containsKey('Body')){
                Map<String,Object> bodyMap = (Map<String,Object>) response.get('Body');
                if(bodyMap != null && bodyMap.containsKey('Response')){
                    Map<String,Object> responsetMap = (Map<String,Object>) bodyMap.get('Response');
                    if(responsetMap != null && responsetMap.containsKey('existInd')){
                        if(responsetMap.get('existInd') == 'true'){
                            errorMessage = 'יש לבצע חיפוש במערכות המקור';
                        }
                    }
                }
            }
        }
    }
    /**
    *   Method for initialization Variables
    *   @method initSearchResults
    *   @return {void}
    */
    private void initSearchResults(){  
        isThereCurrentCustomer = false;
        isThereHistoricalCustomer = false;
        errorMessage = '';
        urlSubTab = ''; 
        leadList = new List<Lead>();
        contactMap = new Map<id, ContactWithAccountsList>();
        accountMap = new Map<id, AccountWithContactsList>();
        cellcomExternalIdsMap = new Map<string,string>();
        contactMapSize = 0;
        accountMapSize = 0; 
        if(limitSearchResulte == null){
            limitSearchResulte = Integer.valueOf(CustomMetadataTypeService.getCrmVariable('LimitSearchResulte'));
        }
    }
    /**
    *   Set contacts, accounts and leads by the category and the entered value
    *   @method getAccountsAndContactBySubCategory
    *   @return {Boolean} Internal search, inside salesforce
    */
    private Boolean getAccountsAndContactBySubCategory(){ 
        if(subCategory == 'Ban' || subCategory == 'NV' || subCategory == 'PsId'){
            searchBiliingAcc(new set<String>{searchValue}, subCategory, null);
            if(subCategory == 'Ban' ||subCategory == 'PsId'){
                return true;
            }
        }
        if(subCategory == 'PrivateCompany'){ 
            searchByPrivateCompany();
            return true;
        }
        if(subCategory == 'Id' || subCategory == 'Passport'){  
            searchBySSN();
            return true;
        }
        if(subCategory == 'AccountName'){
            searchByAccount();
        }
        if(subCategory == 'ContactName'){
            searchByContact();
        }
        if(subCategory == 'SubscriberNumber' || subCategory == 'MAC' || subCategory == 'IMEI' || subCategory == 'CaseNumber' || subCategory == 'DataLine'){
            Map<String,Object> response = calloutOSB('00710', 'api/services/rest/00710_osb_searchbyparameters_k2view');
            retrieveDataFromSF(response);
        }
        return false;
    }
    
    /**
    *   Search AccountContactRelation by account name 
    *   @method searchByAccount
    *   @return {void}
    */
    private void searchByAccount(){
        List<Account> accountList = searchAccountByName();
        set<string> accountIdsSet = new set<string>();
        for(Account acc : accountList){
            accountIdsSet.add(acc.id);
        } 
        list<AccountContactRelation> accConRelationList = searchAccountContactRelation(accountIdsSet, 'Account.Id', new set<String>{'Consumer', 'Business'});
        buildAccountMap(accConRelationList, null, null); 
    }
    
    /**
    *   Search AccountContactRelation by contact name 
    *   @method searchByContact
    *   @return {void}
    */
    private void searchByContact(){
        List<Contact> contactList = searchContact(subCategory);
        set<string> contactIdsSet = new set<string>();
        for(Contact con : contactList){
            contactIdsSet.add(con.id);
        } 
        list<AccountContactRelation> accConRelationList = searchAccountContactRelation(contactIdsSet, 'Contact.Id', new set<String>{'Consumer', 'Business'});
        buildContactMap(accConRelationList);
    }
    /**
    *   Search AccountContactRelation by Private Company in AccountKeys
    *   @method searchByPrivateCompany
    *   @return {void}
    */
    private void searchByPrivateCompany(){
        searchInOdata(new set<String>{searchValue}, 'id_number__c', 'AccountKeys__x');
        if(!cellcomExternalIdsMap.isEmpty()){
            list<AccountContactRelation> accConRelationList = searchAccountContactRelation(cellcomExternalIdsMap.keySet(), 'Account.CellcomExternalID__c', new set<String>{'Consumer', 'Business'});
            buildAccountMap(accConRelationList, null, null); 
        }
    }
    /**
    *   Search AccountContactRelation by SSN in contact or lead
    *   @method searchBySSN
    *   @return {void}
    */
    private void searchBySSN(){
        searchInOdata(new set<String>{searchValue}, 'id_number__c', 'ContactKeys__x');
        if(!cellcomExternalIdsMap.isEmpty()){
            list<AccountContactRelation> accConRelationList = searchAccountContactRelation(cellcomExternalIdsMap.keySet(), 'Contact.CellcomExternalID__c', new set<String>{'Consumer', 'Business'});
            buildContactMap(accConRelationList);
        }
        if(contactMap.isEmpty()){
            initSearchResults();
            searchLeadInOdata(new set<String>{searchValue}, 'ExternalId');
            if(!cellcomExternalIdsMap.isEmpty()){ 
                searchLead(null);
            }
        }
    }
    /**
    *  Set variables by the url params 
    *  @method setVariablesByUrl
    *  @return {void}
    */
    private void setVariablesByUrl(){
        string eventId = apexpages.currentpage().getparameters().get('EventId');
        if(eventId != null){
            list<InteractionEvent__c> interactionEventList = [Select id, AccountId__c, AccountId__r.CellcomExternalID__c, ContactId__c, ContactId__r.CellcomExternalID__c, LeadId__c, LeadId__r.CellcomExternalID__c, PhoneNumber__c, CustomerSegment__c, InvalidRquest__c from InteractionEvent__c where id=:eventId];
            if(interactionEventList != null && !interactionEventList.isEmpty() && !interactionEventList[0].InvalidRquest__c){
                setDataByInteractionEvent(interactionEventList[0]);
            }
        }    
    }
    /**
    *   Set contacts, accounts and leads by the url params
    *   @method setDataByInteractionEvent
    *   @param {InteractionEvent__c} interactionEvent
    *   @param {string} screenType
    *   @return {void}
    */
    private void setDataByInteractionEvent(InteractionEvent__c interactionEvent){
        try{
            set<String> accountRecordtypeSet = new set<String>{'Consumer', 'Business'};
            if(interactionEvent.CustomerSegment__c == 'B2B'){
                accountRecordtypeSet = new set<String>{'Business'};
            }
            else if(interactionEvent.CustomerSegment__c == 'B2C'){
                accountRecordtypeSet = new set<String>{'Consumer'};
            }
        
            if(interactionEvent.ContactId__c != null){
                list<AccountContactRelation> accConRelationList = searchAccountContactRelation(new set<String>{interactionEvent.ContactId__c}, 'Contact.Id', accountRecordtypeSet);
                buildContactMap(accConRelationList);
            }   
            else if(interactionEvent.AccountId__c != null){
                list<AccountContactRelation> accConRelationList = searchAccountContactRelation(new set<String>{interactionEvent.AccountId__c}, 'Account.Id', accountRecordtypeSet);
                buildAccountMap(accConRelationList, null, null); 
            } 
            else if(interactionEvent.PhoneNumber__c != null){
                searchLead(interactionEvent.PhoneNumber__c);
            }
        } catch(Exception e) {
            system.debug(Logginglevel.ERROR, '## ERROR :' +e.getMessage() +' StackTraceString :'+ e.getStackTraceString());
            errorMessage = 'שגיאה בחיפוש';
        }

    }
    
    /**
    *   Callout to Legacy systems through the OSB to retrive search results
    *   @method calloutOSB
    *   @return {Map<String,Object>} response
    */
    private Map<String,Object> calloutOSB(string functionCode, string endpoint){
        Map<String,Object> response;
        if(subCategoryAndParameterCodeMap.containsKey(subCategory)){
            SearchRequestBuilder curRequest = new SearchRequestBuilder(subCategoryAndParameterCodeMap.get(subCategory), searchValue);
            OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest(functionCode);
            request.body.setRequestNode(curRequest);
            response = request.sendRequestWithErrorCheck('OSB',endpoint, false);
        }
        return response;
    }
    /**
    *   Dserialize the Response through inner class
    *   @method retrieveDataFromSF
    *   @param {Map<String,Object>} response
    *   @return {void}
    */
    private void retrieveDataFromSF(Map<String,Object> response){
        if(response != null) {
            if(response.containsKey('Body')){
                Map<String,Object> bodyMap = (Map<String,Object>) response.get('Body');
                if(bodyMap != null && bodyMap.containsKey('Response')){
                    Map<String,Object> responsetMap = (Map<String,Object>) bodyMap.get('Response');
                    if(responsetMap != null && responsetMap.containsKey('accountList')){
                        Map<String,Object> accountList = (Map<String,Object>) responsetMap.get('accountList');
                        if(accountList != null && accountList.containsKey('account')){
                            String accountJSON = JSON.serialize(accountList.get('account'));
                            accountJSON = accountJSON.replaceAll('"type":', '"itemName":');                              
                            AccountResponse[] accountResponseList = (AccountResponse[]) System.JSON.deserialize(accountJSON , AccountResponse[].class);
                            setIntegrationAccountMap(accountResponseList);
                        }
                    }
                }
            }
        }

    }
    /**
    *   Set map from the response of integration
    *   @method setIntegrationAccountMap
    *   @param {AccountResponse[]} accountResponseList
    *   @return {void}
    */
    private void setIntegrationAccountMap(AccountResponse[] accountResponseList){
        set<String> billingExternalIdSet = new set<String>();
        map<string, AccountResponse> integrationAccountMap = new map<string, AccountResponse>();
        for(Integer i = 0 ; i < accountResponseList.size() ; i++){
            AccountResponse account = accountResponseList[i];
            if(account.billingAccountId != null && account.accountID != null){
                if(subCategory == 'SubscriberNumber'){
                    account.Subscriber = searchValue;
                }
                integrationAccountMap.put(account.accountID, account);
                billingExternalIdSet.add(account.billingAccountId);  
            }
        }
        system.debug('## billingExternalIdSet: ' + billingExternalIdSet);
        if(!billingExternalIdSet.isEmpty()){
            searchBiliingAcc(billingExternalIdSet, 'CellcomExternalID__c', integrationAccountMap);
        }
        else{
            errorMessage = 'יש לבצע חיפוש במערכות המקור';
        }
    }
    /**
    *   Collect all CellcomExternalId to view fields from the odata
    *   @method retrieveOdataValues
    *   @param {list<AccountContactRelation>} accConRelationList
    *   @return {void}
    */
    private void retrieveOdataValues(list<AccountContactRelation> accConRelationList){
        set<string> accountExternalIdSet = new set<string>();
        set<string> contactExternalIdSet = new set<string>();
        for(AccountContactRelation relation : accConRelationList){
            if(relation.Account.CellcomExternalID__c != null && relation.AccountRecordTypeName__c != 'Billing'){
                accountExternalIdSet.add(relation.Account.CellcomExternalID__c);
            }
            if(relation.Contact.CellcomExternalID__c != null){
                contactExternalIdSet.add(relation.Contact.CellcomExternalID__c);
            }
        }
        if(!accountExternalIdSet.isEmpty()){
            searchInOdata(accountExternalIdSet, 'ExternalId', 'AccountKeys__x');
        }
        if(!contactExternalIdSet.isEmpty()){
            searchInOdata(contactExternalIdSet, 'ExternalId', 'ContactKeys__x');
        }
    }
    /**
    *   Method for searching data from odata
    *   @method searchInOdata
    *   @param {set<String>} valuesSet
    *   @param {string} fieldName
    *   @param {string} tableName
    *   @return {void}
    */
    private void searchInOdata(set<String> valuesSet, string fieldName, string tableName){        
        string query = 'Select id_number__c, ExternalId ' +
                'From ' + tableName +
                ' where ' + fieldName + ' in: valuesSet';
                
        system.debug('## valuesSet: ' + valuesSet);
        system.debug('## query: ' + query);
        for(sObject s : Database.query(query)){
            cellcomExternalIdsMap.put(string.valueOf(s.get('ExternalId')), string.valueOf(s.get('id_number__c')));
        }              
    }
    /**
    *   Search AccountContactRelation based on account parameter 
    *   @method searchAccountContactRelation
    *   @param {set<String>} valuesSet
    *   @param {string} fieldName
    *   @param {set<string>} recordTypeSet
    *   @return {list<AccountContactRelation>} accConRelationList     
    */
    private list<AccountContactRelation> searchAccountContactRelation(set<String> valuesSet, string fieldName, set<string> recordTypeSet){
        list<AccountContactRelation> accConRelationList = new list<AccountContactRelation>();
        string query = 'Select toLabel(RoleFunction__c), Contact.CellcomExternalID__c, Contact.Name, Contact.Id, ContactId, Account.NVID__c, Account.BANPSID__c, Account.CellcomExternalID__c, Account.Parent.Name, Account.Name, Account.Id, AccountId, IsActive, toLabel(Account.RecordType.Name), AccountRecordTypeName__c, Account.ConsumerTypeEnglish__c ' +
                        'From AccountContactRelation where IsActive = true ' +
                        'and AccountRecordTypeName__c in: recordTypeSet ' +
                        'and ' + fieldName + ' in: valuesSet';
                        
        system.debug('## query : ' + query);
        accConRelationList = Database.query(query);
        system.debug('## accConRelationList: ' + accConRelationList);
        return accConRelationList;
    }
    
    /**
    *   Search data based on billing account parameter 
    *   @method searchBiliingAcc
    *   @param {set<String>} valuesSet
    *   @param {map<string, AccountResponse>} integrationAccountMap
    *   @return {void}
    */
    private void searchBiliingAcc(set<String> valuesSet, string fieldName, map<string, AccountResponse> integrationAccountMap){
        list<Account> biliingAccList = searchAccount(valuesSet, fieldName); 
        if(biliingAccList.isEmpty()){
            return;
        }
        set<string> consumerIdSet = new set<string>();
        set<string> biliingIdSet = new set<string>();
        set<string> businessIdSet = new set<string>();
        list<AccountContactRelation> accConRelationList = new list<AccountContactRelation>();
        for(Account biliingAcc : biliingAccList){
            if(biliingAcc.Parent.RecordTypeId == RecordTypeService.getRecordTypeIdByName('Account', 'Business')){   
                businessIdSet.add(biliingAcc.ParentId);
            }
            else if(biliingAcc.Parent.RecordTypeId == RecordTypeService.getRecordTypeIdByName('Account', 'Consumer')){   
               biliingIdSet.add(biliingAcc.id);
               consumerIdSet.add(biliingAcc.ParentId);
            }
        }
        if(!businessIdSet.isEmpty()){
            searchByBusinessAcc(businessIdSet , integrationAccountMap);
        }
        if(!biliingIdSet.isEmpty()){
            searchByConsumerAcc(biliingIdSet, consumerIdSet, integrationAccountMap);
        }
    }
    /**
    *   Search data based on business account parameter 
    *   @method searchByBusinessAcc
    *   @param {set<string>} businessIdSet
    *   @param {map<string, AccountResponse>} integrationAccountMap
    *   @return {void}
    */
    private void searchByBusinessAcc(set<string> businessIdSet, map<string, AccountResponse> integrationAccountMap){
        list<AccountContactRelation> accConRelationList = searchAccountContactRelation(businessIdSet, 'Account.Id', new set<String>{'Consumer', 'Business'});
        buildAccountMap(accConRelationList, integrationAccountMap, null); 
    }
    /**
    *   Search data based on business account parameter 
    *   @method searchByConsumerAcc
    *   @param {set<String>} biliingIdSet
    *   @param {set<String>} consumerIdSet 
    *   @param {map<string, AccountResponse>} integrationAccountMap
    *   @return {void}
    */
    private void searchByConsumerAcc(set<String> biliingIdSet, set<String> consumerIdSet , map<string, AccountResponse> integrationAccountMap){
        map<string, Account> consumerMap = new map<string, Account>();
        list<AccountContactRelation> biliingAccountConRelationList = searchAccountContactRelation(biliingIdSet, 'Account.Id', new set<String>{'Billing'});
        list<Account> consumerAccList = searchAccount(consumerIdSet , 'id');
        set<string> consumerExternalIdSet = new set<string>();
        for(Account acc : consumerAccList){
            consumerMap.put(acc.id, acc);
            consumerExternalIdSet.add(acc.CellcomExternalID__c);
        }   
        if(!consumerExternalIdSet.isEmpty()){
            searchInOdata(consumerExternalIdSet, 'ExternalId', 'AccountKeys__x');
        }     
        buildAccountMap(biliingAccountConRelationList, integrationAccountMap, consumerMap);
    }
    /**
    *   Method select contact based on parameters
    *   @method searchContact
    *   @param {String} fieldName
    *   @return {List<Contact>} contactList
    */
    private List<Contact> searchContact(string fieldName){
        List<Contact> contactList = new List<Contact>();
        if(fieldName == 'ContactName'){
           String searchQuery = 'FIND \'' + searchValue.replace('\'','\\\'') + '\' IN Name FIELDS RETURNING Contact(id, Name LIMIT ' + limitSearchResulte + ' )';
           List<List <sObject>> searchList = search.query(searchQuery);
           for(Contact con : (List<Contact>)searchList[0]){
                if(con.Name == searchValue){
                    contactList.add(con);
                }
            }
        }
        system.debug('## contactList: ' + contactList);
        return contactList;
    }
    /**
    *   Method select account based on name 
    *   @method searchAccountByName
    *   @return {List<Account>} accountList
    */
    private List<Account> searchAccountByName(){
        List<Account> accountList = new List<Account>();
        String searchQuery = 'FIND \'' + searchValue.replace('\'','\\\'') + '\' IN Name FIELDS RETURNING Account(NETV_Ind__c, CELL_Ind__c, Name, ConsumerTypeEnglish__c, CellcomExternalID__c, BANPSID__c, toLabel(RecordType.Name), ParentId, Parent.RecordTypeId , Parent.CellcomExternalID__c LIMIT ' + limitSearchResulte + ' )';
        List<List <sObject>> searchList = search.query(searchQuery);
        for(Account acc : (List<Account>)searchList[0]){
            if(acc.Name == searchValue){
                accountList.add(acc);
            }
        }
        system.debug('## accountList: ' + accountList);
        return accountList;
    }
    /**
    *   Method select account based on parameters
    *   @method searchAccount
    *   @param {set<String>} valueSet
    *   @param {String} fieldName
    *   @return {List<Account>} accountList
    */
    private List<Account> searchAccount(set<string> valuesSet, string fieldName){
        List<Account> accountList = new List<Account>();
        string query = 'Select NETV_Ind__c, CELL_Ind__c, Name, ConsumerTypeEnglish__c, CellcomExternalID__c, BANPSID__c, toLabel(RecordType.Name), ParentId, Parent.RecordTypeId , Parent.Name, Parent.CellcomExternalID__c from Account where ';
        if(fieldName == 'NV'){
            query += 'NVID__c =: searchValue';
        }
        else if(fieldName == 'Ban'){ 
            query += 'BANPSID__c in: valuesSet and CELL_Ind__c = true';
        }
        else if(fieldName == 'PsId'){
            query += 'BANPSID__c in: valuesSet and NETV_Ind__c = true';
        }
        else{
            query += fieldName + ' in: valuesSet';
        }
        system.debug('## query: ' + query);
        accountList = Database.query(query);
        system.debug('## accountList: ' + accountList);
        return accountList;
    }
    /**
    *   Method builds the structure to display multi-select contacts
    *   @method buildAccountMap
    *   @param {list<AccountContactRelation>} accConRelationList
    *   @param {map<string, AccountResponse>} integrationAccountMap
    *   @param {map<string, account>} consumerMap
    *   @return {void}
    */
    private void buildAccountMap(list<AccountContactRelation> accConRelationList, map<string, AccountResponse> integrationAccountMap, map<string, account> consumerMap){
        RelatedContact newRelation;
        retrieveOdataValues(accConRelationList);
        for(AccountContactRelation relation : accConRelationList){
            if(relation.AccountRecordTypeName__c == 'Billing' && consumerMap.containsKey(relation.Account.ParentId)){
                Account consumerAccount = consumerMap.get(relation.Account.ParentId);
                newRelation = getNewRelation(consumerAccount, relation, integrationAccountMap);
                if(accountMap.containskey(consumerAccount.Id)){
                    accountMap.get(consumerAccount.Id).relatedContactList.add(newRelation);
                }
                else{
                    add2AccountWithContactsList(consumerAccount, integrationAccountMap, newRelation, consumerAccount.RecordType.Name);
                }
            }
            else if(relation.AccountRecordTypeName__c != 'Billing'){
                newRelation = getNewRelation(relation.Account, relation, integrationAccountMap);
                if(accountMap.containskey(relation.Account.Id)){
                    accountMap.get(relation.Account.Id).relatedContactList.add(newRelation);
                }
                else{
                    add2AccountWithContactsList(relation.Account, integrationAccountMap, newRelation, relation.Account.RecordType.Name);
                }
            }
        }
        system.debug('## accountMap: ' + accountMap); 
        accountMapSize = accountMap.size();
    }
    /**
    *   Method for add account to AccountWithContactsList
    *   @method add2AccountWithContactsList
    *   @param {Account} acc
    *   @param {map<string, AccountResponse>} integrationAccountMap
    *   @param {RelatedContact} newRelation
    *   @param {string} accRecordTypeName
    *   @return {void}
    */
    private void add2AccountWithContactsList(Account acc, map<string, AccountResponse> integrationAccountMap, RelatedContact newRelation, string accRecordTypeName){
        boolean isCurrentAccount = false;
        string privateCompany = '';
        string split = '';
        if(integrationAccountMap != null && integrationAccountMap.containsKey(acc.CellcomExternalID__c)){
            if(integrationAccountMap.get(acc.CellcomExternalID__c).productStatus != 'C'){
                isCurrentAccount = true;
                isThereCurrentCustomer = true; 
            }
            else{  
                isThereHistoricalCustomer = true;
            }
        }
        if(cellcomExternalIdsMap.containsKey(acc.CellcomExternalID__c)){
            privateCompany = cellcomExternalIdsMap.get(acc.CellcomExternalID__c);
        }
        if(acc.ConsumerTypeEnglish__c == 'Business Consumer'){
            split = 'מפוצל - ' + acc.Parent.Name;
        }
        AccountWithContactsList newAccount = new AccountWithContactsList(acc.Id, acc.Name, accRecordTypeName, split, isCurrentAccount, newRelation, privateCompany);
        accountMap.put(acc.Id, newAccount);
    }
    /**
    *   Method for set new Related Contact
    *   @method getNewRelation
    *   @param {AccountContactRelation} relation
    *   @param {map<string, AccountResponse>} integrationAccountMap
    *   @return {RelatedContact} newRelation
    */
    private RelatedContact getNewRelation(Account acc, AccountContactRelation relation, map<string, AccountResponse> integrationAccountMap){
        string SSN = '';
        string productId = '';
        string layout= '';
        string subscriber = '';
        string lineCode = '';
        string itemName = '';
        string banId = '';
        if(integrationAccountMap != null && integrationAccountMap.containsKey(acc.CellcomExternalID__c)){
            AccountResponse integrationAccount = integrationAccountMap.get(acc.CellcomExternalID__c);
            if(integrationAccount.productStatus != 'C'){
                if(subCategory == 'SubscriberNumber' || subCategory == 'IMEI'){
                    productId = integrationAccount.productId;
                    layout = 'AssetCellular2ndLevel';
                    subscriber = integrationAccount.Subscriber;
                    banId = integrationAccount.banId;
                }
                else if(subCategory == 'DataLine'){
                    lineCode = searchValue;
                    layout = 'B2BTransmissionData';
                    itemName = integrationAccount.itemName;
                }
            }
        }
        if(cellcomExternalIdsMap.containsKey(relation.Contact.CellcomExternalID__c)){
            SSN = cellcomExternalIdsMap.get(relation.Contact.CellcomExternalID__c);
        }
        RelatedContact newRelation = new RelatedContact(relation.Contact.Id, SSN, relation.Contact.Name, relation.RoleFunction__c, productId, layout, subscriber, lineCode, itemName, banId);
        return newRelation;
    }
    /**
    *   Method builds the structure to display multi-select accounts
    *   @method buildContactMap
    *   @param {list<AccountContactRelation>} accConRelationList
    *   @return {void}
    */
    private void buildContactMap(list<AccountContactRelation> accConRelationList){
        retrieveOdataValues(accConRelationList);
        for(AccountContactRelation relation : accConRelationList){
            string privateCompany = '';
            string split = '';
            if(cellcomExternalIdsMap.containsKey(relation.Account.CellcomExternalID__c)){
                privateCompany = cellcomExternalIdsMap.get(relation.Account.CellcomExternalID__c);
            }
            if(relation.Account.ConsumerTypeEnglish__c == 'Business Consumer'){
                split = 'מפוצל - ' + relation.Account.Parent.Name;
            }
            RelatedAccount newRelation = new RelatedAccount(relation.Account.Id, relation.Account.Name, relation.Account.RecordType.Name, split, relation.RoleFunction__c, privateCompany); 
            if(contactMap.containskey(relation.Contact.Id)){
                contactMap.get(relation.Contact.Id).relatedAccountList.add(newRelation);
            }
            else{
                string SSN = '';
                if(cellcomExternalIdsMap.containsKey(relation.Contact.CellcomExternalID__c)){
                    SSN = cellcomExternalIdsMap.get(relation.Contact.CellcomExternalID__c);
                }
                ContactWithAccountsList newContact = new ContactWithAccountsList(relation.Contact.Id, SSN, relation.Contact.Name, newRelation);
                contactMap.put(relation.Contact.Id, newContact);
            }
        }
        system.debug('## contactMap: ' + contactMap);
        contactMapSize = contactMap.size();
    }
    /**
    *   Method for searching data from odata
    *   @method searchLeadInOdata
    *   @param {set<String>} valuesSet
    *   @param {string} fieldName
    *   @return {void}
    */
    private void searchLeadInOdata(set<String> valuesSet, string fieldName){
        string query = 'Select ssn__c, ExternalId From Leads__x where ' + fieldName + ' in: valuesSet';      
        system.debug('## query: ' + query);
        list<Leads__x> leadKeysList = Database.query(query);
        cellcomExternalIdsMap = new Map<string,string>();
        for(Leads__x key : leadKeysList){
            if(key.ssn__c != null ){
                cellcomExternalIdsMap.put(key.ExternalId, key.ssn__c);
            }
        }
    }
    /**
    *   Search data based on lead parameter 
    *   @method searchLead
    *   @param {string} searchValue
    *   @return {void}
    */ 
    public void searchLead(string searchValue){
        if(subCategory == 'SSN'){
            leadList = [Select CellcomExternalID__c, Name, Id, Phone, CampaignName__c From Lead where CellcomExternalID__c in: cellcomExternalIdsMap.keySet()];
        }
        else{
           string phoneNumber = searchValue.replaceAll('\\D','');
           String searchQuery = 'FIND \'' + phoneNumber  + '\' IN PHONE FIELDS RETURNING Lead(Name, FirstName, LastName, Phone, toLabel(RecordType.Name), CampaignName__c, CellcomExternalID__c LIMIT 50 )';
           List<List <sObject>> searchList = search.query(searchQuery);
           for(Lead l : (List<Lead>)searchList[0]){
               if(l.Phone.replaceAll('\\D','') == phoneNumber){
                    leadList.add(l);
                    if(l.CellcomExternalID__c != null){
                       cellcomExternalIdsMap.put(l.CellcomExternalID__c, '');
                   }
               }
           }
           if(!cellcomExternalIdsMap.isEmpty()){
               searchLeadInOdata(cellcomExternalIdsMap.keyset(), 'ExternalId');
           }
        }
        system.debug('## leadList : ' + leadList );
    }
    
    public class AccountResponse {
        public String accountID;    
        public String contactId;
        public String billingAccountId;
        public String banId;   
        public String psid;
        public String Subscriber;
        public String productId;   
        public String productType;  
        public String productStatus;    
        public string itemName;
        public boolean isFirstAccount;
    }
    public class ContactWithAccountsList{
        public Id id {get;set;}
        public String SSN {get;set;}
        public String name {get;set;}
        public List<RelatedAccount> relatedAccountList {get;set;}
        
        public ContactWithAccountsList(){
            relatedAccountList = new List<RelatedAccount>();
        }
        public ContactWithAccountsList(string id, string SSN, string name, RelatedAccount newRelation){
            this.id = id;
            this.SSN = SSN;
            this.name = name;
            this.relatedAccountList = new List<RelatedAccount>{newRelation};
        } 
    } 
    public class RelatedAccount{  
        public Id id {get;set;}
        public String name {get;set;}
        public string recordType {get;set;}
        public string split {get;set;}
        public String roleFunction {get;set;}
        public string privateCompany {get;set;}
        
        public RelatedAccount(string id, string name, string recordType, string split, string roleFunction, string privateCompany){
            this.id = id;
            this.name = name;
            this.recordType = recordType;
            this.split = split;
            this.roleFunction = roleFunction;
            this.privateCompany = privateCompany;
        } 
    } 
    
    public class AccountWithContactsList{
        public Id id {get;set;}
        public String name {get;set;}
        public string recordType {get;set;}
        public string split {get;set;}
        public boolean isCurrentAccount {get;set;}
        public string privateCompany{get;set;}
        public List<RelatedContact> relatedContactList {get;set;}
        
        public AccountWithContactsList(){
            relatedContactList = new List<RelatedContact>();
        }
        public AccountWithContactsList(string id, string name, string recordType, string split, boolean isCurrentAccount, RelatedContact newRelation, string privateCompany){
            this.id = id;
            this.name = name;
            this.recordType = recordType;
            this.split = split;
            this.isCurrentAccount = isCurrentAccount;
            this.privateCompany = privateCompany;
            this.relatedContactList = new List<RelatedContact>{newRelation};
        }  
    }
    public class RelatedContact{ 
        public Id id {get;set;}
        public String SSN {get;set;}
        public String name {get;set;}
        public String roleFunction {get;set;}
        public String productId {get;set;}
        public String layout {get;set;}
        public String subscriber {get;set;}
        public String lineCode {get;set;}
        public String itemName {get;set;}
        public String banId {get;set;}
        
        public RelatedContact(string id, string SSN, string name, string roleFunction, string productId, string layout, string subscriber, string lineCode, string itemName, string banId){
            this.id  = id;
            this.SSN = SSN;
            this.name = name;
            this.roleFunction = roleFunction;
            this.productId = productId;
            this.layout = layout;
            this.subscriber = subscriber;
            this.lineCode = lineCode;
            this.itemName = itemName;
            this.banId = banId;
        }
    } 
    public class SearchRequestBuilder extends OSBCalloutBuilder.RequestBuilder{
        public ServiceInfoBuilder ServiceInfo;
        public SearchRequestBuilder(String searchType, String searchValue) {
            this.ServiceInfo = new serviceInfoBuilder(searchType, searchValue);
        }
    }
    
    public class ServiceInfoBuilder {
        public String searchType;
        public String searchValue;
        public ServiceInfoBuilder(String sType, String sValue) {
            searchType = sType;
            searchValue = sValue;
        }
    }
}