global with sharing class CardsService implements vlocity_cmt.VlocityOpenInterface2 {
	private static Contact curContact;
	private static Account curAccount;

	global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
		System.debug(Logginglevel.ERROR, 'Card Service INPUT PARAMS:\n ' + 'methodName : ' + methodName + '\ninputMap : ' + inputMap + '\noptions : ' + options);

		outMap.put('processError', 'false');
		outMap.put('_debugInput', inputMap);
		outMap.put('_debugMethodName', methodName);
		methodName = String.isNotBlank(methodName) ? methodName.trim() : null;

		if (methodName == null) return false;

		try {
			if (methodName == 'B2CCustomerEquipment2Level') {
				return B2CCustomerEquipment2Level(inputMap, outMap);
			}

		} catch (Exception e) {
			System.debug(Logginglevel.ERROR, '### Exception: ' + e + ' from: ' + e.getStackTraceString() + '\nMethod : ' + methodName);
			//String msg = e.getMessage() + (e.getTypeName() != 'applicationException' ? e.getStackTraceString() : '');
			outMap.put('EXCEPTION',methodName + ':' + e.getMessage() + ':' + e.getStackTraceString());
			return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.ErrCardIntegration.replace('{0}', methodName));
			//return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, msg);
		}

		return true;
	}

	private boolean B2CCustomerEquipment2Level(map < String, object > inputMap, map < String, object > outMap) {
		if (!checkContactAccount(inputMap, outMap)) return false;
		IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder(curAccount.RecordType.DeveloperName);
		curRequest.CustInfo.ContactIdentifier = curContact.CellcomExternalID__c;
		curRequest.CustInfo.setBanPsIds(curAccount, curContact);

		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00723', outMap, Label.msgSrvErr723, Label.msgSrvWarn723);
		request.body.setRequestNode(curRequest);

		Map < String, Object > response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00723_osb_b2cdisplaycustomerequipment_k2view');
		if (response == null) return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.msgSrvErr723);
		outMap.putAll(response);

		return true;
	}

	private boolean checkContactAccount(map < String, object > inputMap, map < String, object > outMap) {

		if (!inputMap.containsKey('accountId')) return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);
		if (!inputMap.containsKey('contactId')) return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountSidebarContact);

		String accountId = String.valueOf(inputMap.get('accountId'));
		String inputContId = String.valueOf(inputMap.get('contactId'));

		if (String.isEmpty(accountId) || String.isEmpty(inputContId)) {
			return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
		}

		Account inputAccount = AccountSidebarCardsService.getAccount(accountId);
		Contact inputContact = AccountSidebarCardsService.getContact(inputContId);

		if (inputAccount == null) {
			return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountNotFound);
		}

		if (inputContId == null) {
			return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.msgAccountSidebarContact);
		}
		curContact = inputContact;
		curAccount = inputAccount;
		return true;
	}
}