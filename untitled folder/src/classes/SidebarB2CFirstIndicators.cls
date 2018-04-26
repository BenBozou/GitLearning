global with sharing class SidebarB2CFirstIndicators{
    global static Boolean getSidebarB2CFirstIndicators(Account a, Contact c, Map<String,Object> outMap) {                   
        String requestBody = setSidebarB2CFirstIndicatorRequestBody(a, c);
        Map<String,Object> responseMap = callOutboundCalloutService('api/services/rest/00681_osb_retrievecustomerflags_k2view', requestBody);
        outMap.put('Indicators', responseMap.get('Body'));
        system.debug('Indicators: ' + outMap);
        return true;
    }
    private static string setSidebarB2CFirstIndicatorRequestBody(Account account, Contact contact){
        IndicatorsCalloutBuilderNew.OSBRequest CTRL = new IndicatorsCalloutBuilderNew.OSBRequest('00681');

        list<string> BanId = new list<string>();
        list<string> PsId = new list<string>();
        for(Account billAcc : account.ChildAccounts){
            if (billAcc.CELL_Ind__c && String.isNotBlank(billAcc.BANPSID__c)) {
                BanId.add(billAcc.BANPSID__c);
            }
            else{
                if (billAcc.NETV_Ind__c && String.isNotBlank(billAcc.BANPSID__c)) {
                    PsId.add(billAcc.BANPSID__c);
                }
            }
        }  
        IndicatorsCalloutBuilderNew.RepairDeliveryCustInfoBuilder CTRLCustInfoInner = new IndicatorsCalloutBuilderNew.RepairDeliveryCustInfoBuilder(PsId, BanId);
        CTRLCustInfoInner.RecordType = account.RecordType.Name.left(1);
        CTRLCustInfoInner.AccountIdentifier = account.CellcomExternalID__c;
        CTRLCustInfoInner.ContactIdentifier = contact.CellcomExternalID__c;
        CTRL.body.Request.setCustInfoNode(CTRLCustInfoInner);
        String requestBody = CTRL.serialize();
        return requestBody;
    }
    private static Map<String,Object> callOutboundCalloutService(String serviceName, String requestBody){
        system.debug(Logginglevel.INFO,'REQUEST: ' + requestBody);
        OutboundCalloutService.RestResponse res = outboundCalloutService.sendRestRequest(null, null ,'OSB', serviceName, 'POST', requestBody);
        if(res == null || res.statusCode == 90){
            return null;
        }
        system.debug(Logginglevel.INFO,'RESPONSE: ' + res.body);
        Map<String,Object> responseMap = (Map<String,Object>)Json.deserializeUntyped(res.body);
        return responseMap;
     }
}