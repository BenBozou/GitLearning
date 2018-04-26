/**
* Class for retrieving Asset 1st level
* Gili Yehuda
* taskid PLR - 978
* @class Asset1stLevelCardService
* @module 360
*/
global with sharing class Asset1stLevelCardService implements vlocity_cmt.VlocityOpenInterface2 {

    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        system.debug(Logginglevel.INFO, '#### Asset1stLevelCardService.invokeMethod: ' + methodName );

        outMap.put('processError', 'false');

        try {
            if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('get1stLevelAsset')) {
                return get1stLevelAsset(inputMap, outMap, options);
            }
            if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('B2Bget1stLevelAsset')) {
                return B2Bget1stLevelAsset(inputMap, outMap, options);
            }
        } catch (Exception e) {
            outMap.put('EXCEPTION',methodName + ':' + e.getMessage() + ':' + e.getStackTraceString());
            system.debug(Logginglevel.ERROR, 'invokeMethod ' + methodName + ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.ErrCardIntegration.replace('{0}', methodName));

            //system.debug(Logginglevel.ERROR, 'invokeMethod ' + methodName + ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());
            //return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, e.getMessage() + ':' + e.getStackTraceString());
        }

        return true;
    }

    /**
    *   Callout to Legacy systems through the OSB to retrive 1st Level Assets
    *   author Gili Yehuda
    *
    *   @method get1stLevelAsset
    *   @param  {map<String, object>} inputMap
    *   @param  {map<String, object>} outMap
    *   @param  {map<String, object>} options
    *   @return {Boolean}
    */
    private static Boolean get1stLevelAsset(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        String inputAccId = (String)inputMap.get('accountId');
        String inputContId = (String)inputMap.get('contactId');

        if( String.isEmpty(inputAccId) || String.isEmpty(inputContId) ) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
        }

        Account acc = AccountSidebarCardsService.getAccount(inputAccId);
        Contact con = AccountSidebarCardsService.getContact(inputContId);

        // Retrieve Id number from contact and return in output map if found.
        List<AccountKeys__x> contactId = new List<AccountKeys__x> ();
        try {
            contactId = [Select id_number__c From AccountKeys__x WHERE ExternalId =: acc.CellcomExternalID__c  LIMIT 1];
        }
        catch(Exception ex) {
            system.debug(Logginglevel.ERROR, 'invokeMethod get1stLevelAsset ERROR :' + ex.getMessage() + ':' + ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
        
        boolean isNeedSet = AccountSidebarCardsService.isNeedSetBanPsIds(acc);

		if (!isNeedSet) return true;
		
        IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder(acc.RecordType.DeveloperName);
        curRequest.CustInfo.setBanPsIds(acc, con);

        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00703', outMap, Label.msgSrvErr703, Label.msgSrvWarn703);
        request.body.setRequestNode(curRequest);

        Map < String, Object > response = request.sendRequestWithErrorCheck('OSB','api/services/rest/00703_osb_b2ccardslayoutlevel1_k2view');
        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

        /*if (response == null) {
            return returnError(outMap, 'processErrorMsg', 'Response issue');
        }*/

        if(contactId.size() > 0) {
            if(response.containsKey('Body')) {
                Map<String,Object> bodyMap = (Map<String,Object>) response.get('Body');
                    if(bodyMap.containsKey('Response')) {
                        Map<String,Object> responseMap = (Map<String,Object>) bodyMap.get('Response');
                            if(responseMap.containsKey('Customer')) {
                                Map<String,Object> customerMap = (Map<String,Object>) responseMap.get('Customer');
                                    if(customerMap.containsKey('EquipmentList')) {
                                        Map<String,Object> equipmentMap = (Map<String,Object>) customerMap.get('EquipmentList');
                                        equipmentMap.put('ContactIdNumber', contactId[0].id_number__c);
                                    }
                            }
                    }
            }
        }

        outMap.put('data',response);
        return true;
    }

    private static Boolean B2Bget1stLevelAsset(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        String inputAccId = (String)inputMap.get('accountId');
        //String inputContId = (String)inputMap.get('contactId');

        if( String.isEmpty(inputAccId)) {
             return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
        }

        Account acc = AccountSidebarCardsService.getAccount(inputAccId);
        IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder(acc.RecordType.DeveloperName);
        curRequest.CustInfo.AccountIdentifier = acc.CellcomExternalID__c;

        //OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00747');
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00747', outMap, Label.msgSrvErr747, Label.msgSrvWarn747);
        request.body.setRequestNode(curRequest);

        List <AccountKeys__x> accountKeysList=[Select id_number__c, a.cellcom_id__r.Id From AccountKeys__x a where cellcom_id__r.Id =:inputAccId];

        Map < String, Object > response = request.sendRequestWithErrorCheck('OSB','api/services/rest/00747_osb_b2bassetcardslayoutlevel1_k2view');
        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

        try{
            if (!accountKeysList.isEmpty()){
                    Map < String, Object > Body_Map = (Map < String, Object > ) response.get('Body');
                    Map < String, Object > response_Map = (Map < String, Object > ) Body_Map.get('Response');
                    response_Map.put('BId',accountKeysList[0].id_number__c);
                    system.debug('BId ' + accountKeysList[0].id_number__c);
                }
        }
        catch (Exception e)  {
            system.debug(Logginglevel.ERROR, ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());
        }
        outMap.put('data',response);
        return true;
    }

    /*private static boolean returnError(Map < String, Object > outMap, String key, object msg) {
        outMap.put(key, msg);
        outMap.put('processError', 'true');
        return false;
    }*/



}