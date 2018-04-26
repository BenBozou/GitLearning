/**
 * Class for retrieving cellular card data
 * Liron Cohen
 * taskid PLR - 113
 * @class B2CBills2LevelService
 * @module 360
 */
global with sharing class B2CBillsService implements vlocity_cmt.VlocityOpenInterface2 {

    public Boolean invokeMethod(String methodName, map < String, object > inputMap, map < String, object > outMap, map < String, object > options) {

        try {
            system.debug('### B2CBillsService.invokeMethod: ' + methodName);

            if (methodName == 'getBills1Level') {
                return getBills1Level(inputMap, outMap);
            } else if (methodName == 'getBills2LevelAcc') {
                return getBills2LevelAcc(inputMap, outMap);
            } else if (methodName == 'getBills2Level') {
                return getBills2Level(inputMap, outMap);
            } else {
                return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.MissingParameterError);
            }
        } catch (Exception e) {
            System.debug('### Exception: ' + e + ' from: ' + e.getStackTraceString());
            String msg = e.getMessage();
            if (e.getTypeName() != 'applicationException') {
                msg += ' : ' + e.getStackTraceString();
            }
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, msg);
        }
        return true;
    }

    /**
     *   method description
     *   author Liron Cohen
     *
     *   @method getBills1Level
     *   @param  {map<String, object>} inputMap
     *   @param  {map<String, object>} outMap
     *   @return {Boolean}
     */
    public boolean getBills2Level(map < String, object > inputMap, map < String, object > outMap) {

        if (!inputMap.containsKey('banId') || !inputMap.containsKey('psId')) {
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);
        }
        if (CustomMetadataTypeService.getCrmVariable('B2CBill_NumberOfMonths') == null) {
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.B2CBills2LevelServiceError);
        }

        //Account acc = AccountSidebarCardsService.getAccount(String.valueOf(inputMap.get('accountId')));
        //Contact con = AccountSidebarCardsService.getContact(String.valueOf(inputMap.get('contactId')));

        String banId = String.valueOf(inputMap.get('banId'));
        String psId = String.valueOf(inputMap.get('psId'));

        B2CBills2LevelBuilder b2CBills2LevelBuilder = new B2CBills2LevelBuilder(
            String.valueOf(CustomMetadataTypeService.getCrmVariable('B2CBill_NumberOfMonths')));

        //b2CBills2LevelBuilder.CustInfo.setBanPsIds(acc, con);
        if (banId != '' && banId != null) {
            b2CBills2LevelBuilder.CustInfo.BanIds.BanId.add(banId);
        }

        if (psId != '' && psId != null) {
            b2CBills2LevelBuilder.CustInfo.PsIds.PsId.add(psId);
        }

        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00664', outMap, Label.msgSrvErr664, Label.msgSrvWarn664);

        request.body.setRequestNode(b2CBills2LevelBuilder);

        system.debug('### REQUEST: ' + request.serialize());

        Map < String, Object > response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/osb_getcustomersinvoices_bp_00664');
        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

        /*if (response == null) {
            return returnError(outMap, 'processErrorMsg', 'Response issue');
        }*/

        outMap.put('data', response);

        return true;

    }

    /**
     *   method description
     *   author Elad Iflah
     *
     *   @method getBills2LevelAcc
     *   @param  {map<String, object>} inputMap
     *   @param  {map<String, object>} outMap
     *   @return {Boolean}
     */
    public boolean getBills2LevelAcc(map < String, object > inputMap, map < String, object > outMap) {

        if (!inputMap.containsKey('accountId') ||
            !inputMap.containsKey('contactId')) {
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.MissingParameterError);
        }

        Account acc = AccountSidebarCardsService.getAccount(String.valueOf(inputMap.get('accountId')));
        Contact con = AccountSidebarCardsService.getContact(String.valueOf(inputMap.get('contactId')));
        
        
        B2CBills2LevelBuilder b2CBills2LevelBuilder = new B2CBills2LevelBuilder(
            String.valueOf(CustomMetadataTypeService.getCrmVariable('B2CBill_NumberOfMonths')));

        b2CBills2LevelBuilder.CustInfo.setBanPsIds(acc, con);

        //OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00664');
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00664', outMap, Label.msgSrvErr664, Label.msgSrvWarn664);

        request.body.setRequestNode(b2CBills2LevelBuilder);

        system.debug('### REQUEST: ' + request.serialize());

        Map < String, Object > response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/osb_getcustomersinvoices_bp_00664');

        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

        outMap.put('data', response);

        return true;

    }

    /**
     *   method description
     *   author Liron Cohen
     *
     *   @method getBills2Level
     *   @param  {map<String, object>} inputMap
     *   @param  {map<String, object>} outMap
     *   @return {Boolean}
     */
    public boolean getBills1Level(map < String, object > inputMap, map < String, object > outMap) {

        //validate all params was sent... otherwise return err
        if (!inputMap.containsKey('accountId') ||
            !inputMap.containsKey('contactId')) {
            return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.MissingParameterError);
        }

        Account acc = AccountSidebarCardsService.getAccount(String.valueOf(inputMap.get('accountId')));
        Contact con = AccountSidebarCardsService.getContact(String.valueOf(inputMap.get('contactId')));
        system.debug(acc);
        //String Consumertype=acc.ConsumerType__c;

    if(acc == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);
        }

        if(con == null) {
            return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountSidebarContact);
        }

        boolean isNeedSet = AccountSidebarCardsService.isNeedSetBanPsIds(acc);

		if (!isNeedSet && !test.isRunningTest()) return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR,Label.errNotFoundBillingAccounts);
		
		
        IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder(acc.RecordType.DeveloperName);
        curRequest.CustInfo.setBanPsIds(acc, con);

        //OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00797');
        OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00797', outMap, Label.msgSrvErr797, Label.msgSrvWarn797, new map<String, object>{'warningAsError' => true});
        request.body.setRequestNode(curRequest);

        Map < String, Object > response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00797_osb_getfinanceinfo_k2view');

        //if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

        // Since billing address is needed for every billing account
        // It will be retrieved from SF and added to every row in output
        Map < String, Account > banMap = new Map < String, Account > ();
        Map < String, Account > psidMap = new Map < String, Account > ();
		 system.debug('acc '+acc);
        // populate ban and psid data in maps to be used later
        for (Account currAcc: acc.ChildAccounts) {
            system.debug('currAcc '+currAcc);
            if (currAcc.CELL_Ind__c && String.isNotBlank(currAcc.BANPSID__c)) {
                banMap.put(currAcc.BANPSID__c, currAcc);

            } else if (currAcc.NETV_Ind__c && String.isNotBlank(currAcc.BANPSID__c)) {
                psidMap.put(currAcc.BANPSID__c, currAcc);
            }
        }

        // retrieve Customer area from map
        String customerRespStr;
        if (response.containsKey('Body')) {
            Map < String, Object > bodyMap = (Map < String, Object > ) response.get('Body');
            if (bodyMap != null && bodyMap.containsKey('Response')) {
                Map < String, Object > responseMap = (Map < String, Object > ) bodyMap.get('Response');
                if (responseMap.containsKey('Customer')) {
                    Map < String, Object > customerMap = (Map < String, Object > ) responseMap.get('Customer');
                    customerRespStr = JSON.serialize(customerMap);
                }
            }
        }

        // Deserialize to updated class which includes new field for billing address which will be empty
        B2CBillsServiceUpdClass billRespUpd = new B2CBillsServiceUpdClass();
        if(customerRespStr != null){
            billRespUpd = (B2CBillsServiceUpdClass) System.JSON.deserialize(customerRespStr, B2CBillsServiceUpdClass.class);

            Account tempAcc = new Account();
            String tempAddr,Consumertype;

            if (billRespUpd.FinData == null) {
                request.returnError(OSBCalloutBuilder.cardStatus.ERROR,'', 'dataCheck');
            }

			String recTypeId = RecordTypeService.getRecordTypeIdByName('Task', 'PersonalTask');

			string numberOfBillingAccount = CustomMetadataTypeService.getCrmVariable('NumberOfBillingAccountInSidebar');
			if(numberOfBillingAccount == null){
				numberOfBillingAccount = '10';
			}

            // Loop over billing accounts and add billing address to every row
            for (B2CBillsServiceUpdClass.cls_billing_account currBillAcc: billRespUpd.FinData.billing_account) {
				currBillAcc.numberOfBillingAccount = numberOfBillingAccount;

                if (currBillAcc.ban != '' && currBillAcc.ban != null) {
                    if (banMap.containsKey(currBillAcc.ban)) {
                        tempAcc = new Account();
                        tempAcc = banMap.get(currBillAcc.ban);
                        tempAddr = tempAcc.BillingStreet + ',' + tempAcc.BillingCity + ',' + tempAcc.BillingPostalCode__c;
                        currBillAcc.billing_address = tempAddr;
                        currBillAcc.name=tempAcc.Name;
                        currBillAcc.status=tempAcc.vlocity_cmt__Status__c;
                        currBillAcc.recordTypeId=recTypeId;
                        currBillAcc.nvid = tempAcc.NVID__c;
                       currBillAcc.Consumertype=acc.ConsumerTypeEnglish__c;
                       currBillAcc.PaidByName = tempAcc.PaidById__r.Name;
                       currBillAcc.Id = tempAcc.PaidById__c;
                    }
                    system.debug('currBillAcc '+currBillAcc);
                }

                if (currBillAcc.psid != '' && currBillAcc.psid != null) {
                    if (psidMap.containsKey(currBillAcc.psid)) {
                        tempAcc = new Account();
                        tempAcc = psidMap.get(currBillAcc.psid);
                        tempAddr = tempAcc.BillingStreet + ',' + tempAcc.BillingCity + ',' + tempAcc.BillingPostalCode__c;
                        currBillAcc.billing_address = tempAddr;
                        currBillAcc.name=tempAcc.Name;
                        currBillAcc.status=tempAcc.vlocity_cmt__Status__c;
                        currBillAcc.recordTypeId=recTypeId;
                        currBillAcc.nvid =  tempAcc.NVID__c;
                        currBillAcc.Consumertype=acc.ConsumerTypeEnglish__c;
                        currBillAcc.PaidByName = tempAcc.PaidById__r.Name;
                       currBillAcc.Id = tempAcc.PaidById__c;
                    }
                     system.debug('currBillAcc '+currBillAcc);
                }
            }
        }

        String newResponseStr = billRespUpd!=null ? JSON.serialize(billRespUpd) : null;

        Map < String, Object > myMap = (Map < String, Object > ) Json.deserializeUntyped(newResponseStr);
        outMap.put('data', myMap);
        return true;

    }

    /*private boolean returnError(map < String, Object > outMap, String key, object msg) {
        outMap.put(key, msg);
        outMap.put('processError', 'true');
        return false;
    }*/

    /**
     * Classes for building json body for 2 Level
     * Liron Cohen
     * taskid PLR - 113
     * @class B2CBills2LevelBuilder
     * @module 360
     */
    public class B2CBills2LevelBuilder extends IndicatorsCalloutBuilder.IndicatorsRequestBuilder {
        public ServiceInfo ServiceInfo;
        public B2CBills2LevelBuilder(String numberOfMonths) {
            this.ServiceInfo = new ServiceInfo(numberOfMonths);
        }
    }

    public class ServiceInfo {
        public String NumberOfMonth;

        public ServiceInfo(String numberOfMonth) {
            this.NumberOfMonth = numberOfMonth;
        }
    }

}