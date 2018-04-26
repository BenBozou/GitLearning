global with sharing class WrapUpSupport {


    public vlocity_cmt__CustomerInteraction__c customerInteraction{get;set;}
    
    global WrapUpSupport() { }

    global WrapUpSupport(ApexPages.StandardController stdController) { }

    global WrapUpSupport(Object stdController) { }
    
    /**
    * 
    *   method description - Allow opening wrap up from sidebar button.
    *   author Elad Iflah
    *   taskId PLR-1546
    *   @return PageReference
    *
    */
    
    // PLR-1546 Allow opening wrap up from sidebar button.
    global PageReference WrapUpPre() {
        
        try {
            string interactionId = ApexPages.currentPage().getParameters().get('id');
            if(!String.isEmpty(interactionId)){
                customerInteraction = [select vlocity_cmt__AccountId__c,vlocity_cmt__Status__c,Id 
                                        from vlocity_cmt__CustomerInteraction__c
                                        where Id =: interactionId];
                return null;
            }
            LinkEnvSupport linkEnvSupp = new LinkEnvSupport();
            String accountId = apexpages.currentpage().getparameters().get('accountId');
            system.debug('111222 account id :' + accountId );
            
            customerInteraction = linkEnvSupp.getCustomerInteraction(accountId);
            system.debug('111222 customerInteraction :' + customerInteraction);
            
            if (customerInteraction == null){
                customerInteraction = new vlocity_cmt__CustomerInteraction__c (vlocity_cmt__AccountId__c=accountId,vlocity_cmt__Status__c='In Progress');
                system.debug('111222 before insert');
                insert customerInteraction;
            }else{
                system.debug('111222 before insert');
                update customerInteraction;
            }

        }
        catch(Exception exc) {
            system.debug(LoggingLevel.Error, 'Exception=: '+ exc.getMessage() +' StackTraceString :'+ exc.getStackTraceString());
        }
        
        return null;
    }    

}