/**
 * Class for retrieving Account's Discounts and Charges
 * Gili Yehuda
 * taskid PLR - 1323
 * @class AccountDiscountsChargesCardService 
 * @module 360 
 */
global with sharing class AccountDiscountsChargesCardService implements vlocity_cmt.VlocityOpenInterface2 {

	global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

		system.debug(Logginglevel.INFO, '### AccountDiscountsChargesCardService.invokeMethod: ' + methodName);

		outMap.put('processError', 'false');

		try {
			if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getData')) {
				return getData(inputMap, outMap, options);
			}
		} catch (Exception e) {
			system.debug(Logginglevel.ERROR, 'invokeMethod ' + methodName + ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());
			return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, e.getMessage() + ':' + e.getStackTraceString());
		}

		return true;
	}

	/**
	 *   retrieving Account's Discounts and Charges From Legacy Systems through OSB
 	 *   Gili Yehuda
 	 *   taskid PLR - 1323
	 *
	 *   @method getData
	 *   @param  {map<String, object>} inputMap
	 *   @param  {map<String, object>} outMap
	 *   @param  {map<String, object>} options
	 *   @return {Boolean}
	 */
	private static Boolean getData(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
		String inputAccId = (String) inputMap.get('accountId');
		String inputContId = (String) inputMap.get('contactId');

		if (String.isEmpty(inputAccId) || String.isEmpty(inputContId)) {
			return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
		}

		Account acc = AccountSidebarCardsService.getAccount(inputAccId);
		Contact con = AccountSidebarCardsService.getContact(inputContId);
		IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder(acc.RecordType.DeveloperName);
		curRequest.CustInfo.setBanPsIds(acc, con);

		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00817');
		request.body.setRequestNode(curRequest);

		Map < String, Object > response = request.sendRequestWithErrorCheck('OSB', '/api/services/rest/00817_osb_chargesdiscounts_k2view');
		if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;
		outMap.put('data', response);
		system.debug('data response :' + outMap.get('data'));
		return true;
	}

}