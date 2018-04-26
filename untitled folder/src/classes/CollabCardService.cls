/**
*   Retrieve ban and psid list for account and contact
*   author Elad Iflah
*
*   @class  CollabCardService
*   @param  {map<String, object>} inputMap
*   @param  {map<String, object>} outMap
*   @param  {map<String, object>} options
*   @return {Boolean}
*/
global with sharing class CollabCardService implements vlocity_cmt.VlocityOpenInterface2 {
    
    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        
        system.debug(Logginglevel.INFO, '#### B2CRecommendCardService.invokeMethod: ' + methodName );
        
        outMap.put('processError', 'false');
        
        try {
            if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getAccsForCollaboration')) {
                return getAccsForCollaboration(inputMap, outMap, options);
            }
            
        } catch (Exception e) {
            system.debug(Logginglevel.ERROR, 'invokeMethod ' + methodName + ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, e.getMessage() + ':' + e.getStackTraceString());
        }
        
        return true;
    }
    
    
    private static Boolean getAccsForCollaboration(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        String inputAccId = (String)inputMap.get('accountId');
        String inputContId = (String)inputMap.get('contactId');        
        
        if( String.isEmpty(inputAccId) || String.isEmpty(inputContId) ) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
        }
        
        Account acc = AccountSidebarCardsService.getAccount(inputAccId);
        Contact con = AccountSidebarCardsService.getContact(inputContId);
        
        Bans bans = new Bans();
        Psids psids = new Psids();
        
        
        List<AccountContactRelation> accContRelList = [SELECT AccountId ,BANPSID__c, Account.CELL_Ind__c, Account.NETV_Ind__c FROM AccountContactRelation
                                                       where ContactId = :con.Id and AccountRecordTypeName__c = 'Billing' AND AccountId IN :acc.ChildAccounts AND IsActive = true];
        
        for( AccountContactRelation currAccCont :  accContRelList) {
            if(currAccCont.Account.CELL_Ind__c && String.isNotBlank(currAccCont.BANPSID__c)) {                
                Customer currCust = new Customer();
                currCust.custId = currAccCont.BANPSID__c;
                bans.banLs.add(currCust);
            }
            else if(currAccCont.Account.NETV_Ind__c && String.isNotBlank(currAccCont.BANPSID__c)) {                
                Customer currCust = new Customer();
                currCust.custId = currAccCont.BANPSID__c;
                psids.psidLs.add(currCust);
            }
        }
        
        
        
        Boolean isPartnerUser = false;
        String currUserId = UserInfo.getUserId();
        User currUser = [ SELECT Profile.Name from User WHERE Id =: currUserId ];
        if( String.valueof(currUser.Profile.Name) == 'Vlocity Partner User' ) {
            isPartnerUser = true;
        }
        
        
        outMap.put('bans',bans);
        outMap.put('psids',psids);
        outMap.put('isPartnerUser',isPartnerUser );      
        
        return true;
    }
    
    public class Customer {
        String custId;
    }
    
    public class Bans {
        List<Customer> banLs;
        public Bans() {
            banLs = new List<Customer>();
        }
    }
    
    public class Psids {
        List<Customer> psidLs;
        public Psids() {
            psidLs = new List<Customer>();
        }
    }
    
}