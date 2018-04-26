global with sharing class LinkEnvSupport {

    /**
    *   method class for retrieving link list by env name
    *   author Elad Iflah
    *   taskId POC
    *
    *   @method LinkEnvSupport
    *   @param  {StandardController} stdController
    *   @return
    *
    */
    /*global LinkEnvSupport(ApexPages.StandardController stdController) {
        //don't do anything for now

    }*/

    global Boolean isLanguageRTL {
        get {
            Set < String > rtlLang = new Set < String > {
                'iw',
                'ar',
                'ur'
            };
            String language = UserInfo.getLanguage();
            return rtlLang.contains(language);
        }
        set;
    }

    global String currentLang {
        get {
            return UserInfo.getLanguage();
        }
        set;
    }
    public boolean isAdminUser {
        get {
            if (isAdminUser!=null) return isAdminUser;
            set<String> pList = new set<String>{'System Administrator', 'מנהל מערכת'};
            String profileName = [SELECT Name FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1].Name;
            return pList.contains(profileName);
        }
    }

    public boolean getInCommunity() {
        return Network.getNetworkId() != null;
        //return true;
    }

    public boolean getShowHeaderSidebar() {
        list<Lead> leadsList = null;
        String leadId = ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(leadId))
            leadsList = [select id, RecordType.DeveloperName from Lead where Id =: leadId limit 1];

        if(Network.getNetworkId() != null && (leadsList.isEmpty() || leadsList[0].RecordType.DeveloperName != 'Offer'))
            return true;
        return false;
    }

    /**
    *   method description
    *   author Elad Iflah
    *   taskId
    *
    *   @method LinkEnvSupport
    *   @param  {Object} stdController
    *   @return
    *
    */
    /*global LinkEnvSupport(Object stdController) {
        //don't do anything for now
    }*/

    /**
    *   method description
    *   author Elad Iflah
    *   taskId
    *

    *   @return
    *
    */
    global LinkEnvSupport() {

    }

    /**
    *   method description
    *   author Dmitry Rivlin
    *   taskId
    *
    *   @method retrieveLinkList
    *   @return Boolean
    *
    */

    global String urlLinkList {
        get {
            return JSON.serialize(UrlLinksUtil.getUrlLinkByEnv());
        }
        set;
    }


    @RemoteAction
    global static boolean hasTabClosed(Id accId){
        vlocity_cmt__CustomerInteraction__c[] lst = [SELECT Id, vlocity_cmt__Status__c, MoveToLegacy__c FROM vlocity_cmt__CustomerInteraction__c WHERE vlocity_cmt__AccountId__c =:accId and createdBy.Id = :UserInfo.getUserId() ORDER BY LastmodifiedDate DESC LIMIT 1];
        return (lst.size() == 0)
            ? true
            : (lst[0].MoveToLegacy__c == true || lst[0].vlocity_cmt__Status__c == 'Completed' || lst[0].vlocity_cmt__Status__c == 'Cancel');
    }
    
    @RemoteAction
    global static Boolean setCustomerInteractioinStatus(Id accId){
        vlocity_cmt__CustomerInteraction__c[] lst = [SELECT Id, vlocity_cmt__Status__c, MoveToLegacy__c FROM vlocity_cmt__CustomerInteraction__c WHERE vlocity_cmt__AccountId__c =:accId and createdBy.Id = :UserInfo.getUserId() ORDER BY LastmodifiedDate DESC LIMIT 1];
        if (lst.size() > 0){
            //customerInteractionObj.vlocity_cmt__Status__c = 'Deferred';
            vlocity_cmt__CustomerInteraction__c customerInteractionObj=lst[0];
            customerInteractionObj.MoveToLegacy__c = true;
            update customerInteractionObj;
            system.debug('RemoteAction setCustomerInteractioinStatus for Account '+accId+' Success '+customerInteractionObj.Id);
            return true;
        }
        system.debug('RemoteAction setCustomerInteractioinStatus : Customer Interaction for Account '+accId+' Not Found');
        return false;

    }

    /* FROM GetPrimaryContact */
    public String primaryContactId {get;set;}
    public Id customerInteractionId {get;set;}
    public boolean popDataSharing {get;set;}
    public Account acc{get;set;}
    public String layoutName{get;set;}

    global LinkEnvSupport(ApexPages.StandardController stdController) { }

    global LinkEnvSupport(Object stdController) {

    }

    /*global LinkEnvSupport() { }*/

    global PageReference PreLoad() {

    String accountId = apexpages.currentpage().getparameters().get('Id');
        String accContactId = apexpages.currentpage().getparameters().get('accContactId');
        system.debug(LoggingLevel.Error,'Current Id' + accountId + ':' + accContactId );
        if (string.isEmpty(accountId) || !accountId.startsWith('001')) return null;
        //acc = [select Id, Name, SidebarLayout__c  from Account where Id =: accountId];
        //system.debug('GetPrimaryContact - accountId:' + accountId);
        List<AccountContactRelation> contactList = accContactId != null
      ? [SELECT Account.CELL_Ind__c, Account.NETV_Ind__c, Account.CellcomExternalID__c, Account.RecordType.DeveloperName, Account.SidebarLayout__c, Account.CardLayout__c,Account.Name, Account.Id, ContactId, Contact.Id FROM AccountContactRelation WHERE id=: accContactId AND IsActive = true LIMIT 1]
      : [SELECT Account.CELL_Ind__c, Account.NETV_Ind__c, Account.CellcomExternalID__c, Account.RecordType.DeveloperName, Account.SidebarLayout__c, Account.CardLayout__c,Account.Name, Account.Id, ContactId, Contact.Id FROM AccountContactRelation WHERE (AccountId=:accountId AND RoleFunction__c = 'P') AND IsActive = true LIMIT 1];

    if( contactList.size() > 0 ) {
            system.debug(LoggingLevel.Error,'Current contact is : ' + contactList[0].Contact.Id + ' : ' + accountId + ' : ' + accContactId);
            primaryContactId = contactList[0].Contact.Id;
        }
        else {
            contactList = [SELECT  Account.RecordType.DeveloperName, Account.CELL_Ind__c, Account.NETV_Ind__c, Account.CellcomExternalID__c, Account.SidebarLayout__c, Account.CardLayout__c, Account.Name, Account.Id ,ContactId, Contact.Id FROM AccountContactRelation WHERE AccountId=:accountId AND IsActive = true LIMIT 1];
            if( contactList.size() > 0 ) {
                primaryContactId = contactList[0].Contact.Id;
            }
        }
        acc = (!contactList.isEmpty()) ? contactList[0].Account : [select Id, Name, CellcomExternalID__c, RecordType.DeveloperName, CELL_Ind__c, NETV_Ind__c, SidebarLayout__c, CardLayout__c  from Account where Id =: accountId];
        layoutName=acc.SidebarLayout__c;

        //system.debug('GetPrimaryContact - primaryContactId:' + primaryContactId);
        //Map<String,String> rParams = ApexPages.currentPage().getParameters();
        //Id accountId = apexpages.currentpage().getparameters().get('Id');
        //Id accountId = rParams.get('Id');

        if (getDataSharing(acc)){
            popDataSharing =  true;
            return null;
        }

        /*vlocity_cmt__CustomerInteraction__c customerInteraction = getCustomerInteraction(accountId);
        if (customerInteraction == null){
            customerInteraction = new vlocity_cmt__CustomerInteraction__c (vlocity_cmt__AccountId__c=accountId,vlocity_cmt__Status__c='In Progress');
            insert customerInteraction;
        }else{
            update customerInteraction;
        }
        customerInteractionId= customerInteraction.Id;*/

        return null;
    }

    public vlocity_cmt__CustomerInteraction__c getCustomerInteraction(Id accId){
        List<vlocity_cmt__CustomerInteraction__c> customerInteractionList=
                                                [SELECT Id ,vlocity_cmt__Status__c, MoveToLegacy__c, vlocity_cmt__AccountId__c
                                                FROM vlocity_cmt__CustomerInteraction__c
                                                WHERE vlocity_cmt__AccountId__c =: accId and vlocity_cmt__Status__c != 'Completed' 
                                                    and vlocity_cmt__Status__c != 'Cancel' AND MoveToLegacy__c = false
                                                    and createdBy.Id = :UserInfo.getUserId() 
                                                ORDER BY CreatedDate DESC Limit 1];
        if(customerInteractionList.isEmpty()){
            return null;
        }
        return customerInteractionList[0];
    }

    public boolean getDataSharing(Account inputAccount) {
      
    String recTypeDevName = inputAccount.RecordType.DeveloperName;
        system.debug(LoggingLevel.Error, 'recTypeDevName' +recTypeDevName);
        
    Boolean popUpDS = popUpDataSharing(recTypeDevName, inputAccount);
        if(recTypeDevName == 'Consumer' && inputAccount.CELL_Ind__c == true && inputAccount.NETV_Ind__c == true){
          if (popUpDS == null || popUpDS == true){
            return true;  
          }
        }
        
        return false;
    }
    
    private boolean popUpDataSharing(String recTypeDevName, Account inputAccount){
    try{
      IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder(recTypeDevName);
        
      curRequest.CustInfo.AccountIdentifier = inputAccount.CellcomExternalID__c;
          OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00720', null);
          system.debug(LoggingLevel.Error, request.body);
        request.body.setRequestNode(curRequest);
        Map<String, Object> response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00720_osb_b2cdatacollaboration_k2view');

            if(recTypeDevName == 'Consumer' && inputAccount.CELL_Ind__c == true && inputAccount.NETV_Ind__c == true){
                Map < String, Object > Body_Map = (Map < String, Object > ) response.get('Body');
                Map < String, Object > response_Map = (Map < String, Object > ) Body_Map.get('Response');
                String shareDataInd = (String) response_Map.get('shareDataInd');
                if (shareDataInd == 'N'){
                    return true;
                }
                return false;
            }

            } catch (Exception E) {
                system.debug('in popUpDataSharing. Exception=:'+ E.getMessage() +' StackTraceString :'+ E.getStackTraceString());
                return null;
            }
            return false;
      
    }

}