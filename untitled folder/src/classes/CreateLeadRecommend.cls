/**
*   Class for creating Lead 
*   author Elad Iflah
*   taskId PLR-1038
*
*   @method CreateLeadRecommend
*   @param  {StandardController} stdController
*   @return 
*
*/

global with sharing class CreateLeadRecommend {
    
    //public String primaryContactId {get;set;}
    
    
    /*global CreateLeadRecommend(ApexPages.StandardController stdController) { }
    
    global CreateLeadRecommend(Object stdController) {                                
                
    } */   
    
    global CreateLeadRecommend() { }
    
    global PageReference createLeadRecom() {
        
        try {
            
            String accountId = apexpages.currentpage().getparameters().get('Id');
            String contactId = apexpages.currentpage().getparameters().get('contactId');
            String subscriber = apexpages.currentpage().getparameters().get('subscriber');
            String ban = apexpages.currentpage().getparameters().get('ban');
            String psid = apexpages.currentpage().getparameters().get('psid');
            String campId = apexpages.currentpage().getparameters().get('campId');
            String campCycle = apexpages.currentpage().getparameters().get('campCycle');
            String treatId = apexpages.currentpage().getparameters().get('treatId');
            String commCode = apexpages.currentpage().getparameters().get('commCode');
            String provCode = apexpages.currentpage().getparameters().get('provCode');
            String provInd = apexpages.currentpage().getparameters().get('provInd');
            String sysLegacy = apexpages.currentpage().getparameters().get('sysLegacy');
            
            String agentAllDet = apexpages.currentpage().getparameters().get('agentAllDet');            
            Blob blobAgentAllDet = EncodingUtil.base64Decode(agentAllDet);
            agentAllDet = blobAgentAllDet.toString(); 
            agentAllDet = EncodingUtil.urlDecode(agentAllDet, 'UTF-8');
            
            String agentShortDet = apexpages.currentpage().getparameters().get('agentShortDet');
            Blob blobAgentShortDet = EncodingUtil.base64Decode(agentShortDet);
            agentShortDet = blobAgentShortDet.toString();
            agentShortDet = EncodingUtil.urlDecode(agentShortDet, 'UTF-8');
            
            String consAcc = apexpages.currentpage().getparameters().get('consAcc');
            String prod = apexpages.currentpage().getparameters().get('prod');
            String contExId = apexpages.currentpage().getparameters().get('contExId');
            
            map<String,Object> recommendMap = new map<String,Object>();
            recommendMap.put('SUBSCRIBER', subscriber);
            recommendMap.put('BAN', ban);
            recommendMap.put('PSID', psid);
            recommendMap.put('CAMP_ID', campId);
            recommendMap.put('CAMP_CYCLE', campCycle);
            recommendMap.put('TREAT_ID', treatId);
            recommendMap.put('PROV_CODE', provCode);
            recommendMap.put('PROV_IND', provInd);            
            recommendMap.put('COMM_CODE', commCode);   
            recommendMap.put('CONSUMER_ACCOUNT', consAcc);
            recommendMap.put('PRODUCT', prod);
            recommendMap.put('CONTACT_EX_ID', contExId);
            recommendMap.put('SYSTEM_LEGACY', sysLegacy);
                                    
            Lead recomLead = LeadAssignmentService.getPOLMOffer(recommendMap, agentAllDet , agentShortDet, accountId, contactId, false);
                        
            String recomOmniscriptUrl;            
            List<vlocity_cmt__VlocityAction__c> recomOmniscriptActionList = [select Id, vlocity_cmt__URL__c from vlocity_cmt__VlocityAction__c where name ='B2B Recommendations - Open Lead'];
            
            if(recomOmniscriptActionList.size() > 0) {
                recomOmniscriptUrl = recomOmniscriptActionList[0].vlocity_cmt__URL__c;
            }
            else {
                return null;
            }  
            
            recomOmniscriptUrl = recomOmniscriptUrl.replace('{0}', recomLead.Id);
            recomOmniscriptUrl = recomOmniscriptUrl.replace('{1}', recomLead.Id);

            PageReference pageRef = new PageReference(recomOmniscriptUrl);           

            return pageRef;
                                                                                    
        } catch (Exception ex) {
            system.debug(logginglevel.ERROR,'CreateLeadRecommend.createLeadRecom- Exception: ' +  ex.getStackTraceString());
            return null;
        }       
    
        
    }
}