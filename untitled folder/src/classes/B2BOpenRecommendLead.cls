/**
*   Class for creating Lead 
*   author Elad Iflah
*   taskId Bug fix
*
*   @method B2BOpenRecommendLead
*   @param  {StandardController} stdController
*   @return 
*
*/

global without sharing class B2BOpenRecommendLead {
    
    global B2BOpenRecommendLead() { }
    
    global PageReference b2bOpenRecommLead() {
        
        try {
                                    
            String recomOmniscriptUrl;
            
            String leadId = apexpages.currentpage().getparameters().get('LeadId');
            String accountId = apexpages.currentpage().getparameters().get('AccountId');
            String treatId = apexpages.currentpage().getparameters().get('TreatId');
            
            String currUserId = UserInfo.getUserId();
            
            // In case of Subscriber recommendations
            if( !string.isEmpty(accountId) ) { 
                
                List<Lead> subLeadList = [Select OwnerId, Id From Lead where TreatId__c =: treatId and AccountId__c =: accountId];
                
                for( Lead currLead : subLeadList ){
                    currLead.OwnerId = currUserId;
                }
                update subLeadList;
                            
                String openLeadB2bOmniscriptUrl;            
                List<vlocity_cmt__VlocityAction__c> recomOmniscriptActionList = [select Id, vlocity_cmt__URL__c from vlocity_cmt__VlocityAction__c where name = 'B2B Recommendations Open Subscriber Lead'];
                
                if(recomOmniscriptActionList.size() > 0) {
                    recomOmniscriptUrl = recomOmniscriptActionList[0].vlocity_cmt__URL__c;
                }
                else {
                    return null;
                }  
                
                recomOmniscriptUrl = recomOmniscriptUrl.replace('{0}', leadId);
                recomOmniscriptUrl = recomOmniscriptUrl.replace('{1}', accountId);
                recomOmniscriptUrl = recomOmniscriptUrl.replace('{2}', treatId);
                recomOmniscriptUrl = recomOmniscriptUrl.replace('{3}', leadId);           
            }
            // In case of Ban recommendations
            else {
                
                List<Lead> banLeadList = [Select OwnerId, Id From Lead where Id =: leadId];
                
                if(banLeadList.size() > 0) {
                    banLeadList[0].OwnerId = currUserId;
                    update banLeadList[0];
                }
                            
                String openLeadB2bOmniscriptUrl;            
                List<vlocity_cmt__VlocityAction__c> recomOmniscriptActionList = [select Id, vlocity_cmt__URL__c from vlocity_cmt__VlocityAction__c where name ='B2B Recommendations - Open Lead'];
                
                if(recomOmniscriptActionList.size() > 0) {
                    recomOmniscriptUrl = recomOmniscriptActionList[0].vlocity_cmt__URL__c;
                }
                else {
                    return null;
                }  
                
                recomOmniscriptUrl = recomOmniscriptUrl.replace('{0}', leadId);
                recomOmniscriptUrl = recomOmniscriptUrl.replace('{1}', leadId);
                
            }

            PageReference pageRef = new PageReference(recomOmniscriptUrl);           

            return pageRef;
                                                                                    
        } catch (Exception ex) {
            system.debug(logginglevel.ERROR,'CreateLeadRecommend.createLeadRecom- Exception: ' +  ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
            return null;
        }       
    
        
    }
}