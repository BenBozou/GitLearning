/**
*   Class for utils account sidebar
*   author Elad Iflah
*   taskId PLR-1136
*
*   @method GetPrimaryContact
*   @param  {StandardController} stdController
*   @return
*
*/

global with sharing class GetPrimaryContact {

    public String primaryContactId {get;set;}
    public Id customerInteractionId {get;set;}
    public boolean popDataSharing {get;set;}
    public Account acc{get;set;}

    global GetPrimaryContact(ApexPages.StandardController stdController) { }

    global GetPrimaryContact(Object stdController) {

        String accountId = apexpages.currentpage().getparameters().get('Id');
        acc = [select Id, Name from Account where Id =: accountId];
        system.debug('GetPrimaryContact - accountId:' + accountId);
        List<AccountContactRelation> contactList = [SELECT ContactId, Contact.Id FROM AccountContactRelation WHERE AccountId=:accountId AND RoleFunction__c = 'P' AND IsActive = true LIMIT 1];
        if( contactList.size() > 0 ) {
            primaryContactId = contactList[0].Contact.Id;
        }
        else {
            contactList = [SELECT ContactId, Contact.Id FROM AccountContactRelation WHERE AccountId=:accountId AND IsActive = true LIMIT 1];
            if( contactList.size() > 0 ) {
                primaryContactId = contactList[0].Contact.Id;
            }
        }
        system.debug('GetPrimaryContact - primaryContactId:' + primaryContactId);
    }

    global GetPrimaryContact() { }

    global PageReference PreLoad() {
        
        Map<String,String> rParams = ApexPages.currentPage().getParameters();
        //Id accountId = apexpages.currentpage().getparameters().get('Id');
        Id accountId = rParams.get('Id');
        
        if (getDataSharing(accountId)){
            popDataSharing =  true;
            return null;
        }

        vlocity_cmt__CustomerInteraction__c customerInteraction = getCustomerInteraction(accountId);
        if (customerInteraction == null){
            customerInteraction = new vlocity_cmt__CustomerInteraction__c (vlocity_cmt__AccountId__c=accountId,vlocity_cmt__Status__c='In Progress');
            insert customerInteraction;
        }else{
            update customerInteraction;
        }
        customerInteractionId= customerInteraction.Id;
        system.debug('customerInteraction '+customerInteraction+' '+customerInteractionId);

        return null;
    }

    public vlocity_cmt__CustomerInteraction__c getCustomerInteraction(Id accId){
        List<vlocity_cmt__CustomerInteraction__c> customerInteractionList=
                                                [SELECT Id ,vlocity_cmt__Status__c, MoveToLegacy__c
                                                FROM vlocity_cmt__CustomerInteraction__c
                                                WHERE vlocity_cmt__AccountId__c =: accId and vlocity_cmt__Status__c != 'Completed' and vlocity_cmt__Status__c != 'Cancel' AND MoveToLegacy__c = false
                                                ORDER BY CreatedDate DESC Limit 1];
        if(customerInteractionList.isEmpty()){
            return null;
        }
        return customerInteractionList[0];
    }
    
     public boolean getDataSharing(Id accountId) {
        try {
           
            system.debug('in getDataSharing. accountId=:'+ accountId);
            Account inputAccount = [SELECT Id, CellcomExternalID__c, RecordType.DeveloperName, CELL_Ind__c, NETV_Ind__c FROM Account WHERE Id=:accountId];
        
            IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder(inputAccount.RecordType.DeveloperName);
            curRequest.CustInfo.AccountIdentifier = inputAccount.CellcomExternalID__c;
        
            OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00720', null);
            system.debug(LoggingLevel.Error, request.body);
            request.body.setRequestNode(curRequest);
        
            Map<String, Object> response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00720_osb_b2cdatacollaboration_k2view');
              
            if(inputAccount.RecordType.DeveloperName == 'Consumer' && inputAccount.CELL_Ind__c == true && inputAccount.NETV_Ind__c == true){
                Map < String, Object > Body_Map = (Map < String, Object > ) response.get('Body');
                Map < String, Object > response_Map = (Map < String, Object > ) Body_Map.get('Response');
                String shareDataInd = (String) response_Map.get('shareDataInd');
                system.debug('shareDataInd = : '+ shareDataInd);
                if (shareDataInd == 'N'){
                    return true;
                }
                return false;
            }
              
            } catch (Exception E) {
                system.debug('in getDataSharing. Exception=:'+ E.getMessage() +' StackTraceString :'+ E.getStackTraceString());
                return true;
            }
            return false;
    }

}