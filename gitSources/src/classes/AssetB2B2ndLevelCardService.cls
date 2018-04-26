/**
 * Service class for asset 2nd level cards.
 * Elad Iflah
 * taskid PLR-560
 * @class Asset2ndLevelCardService
 * @module 360
 */
global with sharing class AssetB2B2ndLevelCardService implements vlocity_cmt.VlocityOpenInterface2 {

	/**
	 * Method implemented from interface, that will be called from vlocity card,
	 * and will call inner method according to method name.
	 * Elad Iflah
	 * taskid PLR-560
	 * @method invokeMethod
	 * @param {String} methodName
	 * @param {Map} inputMap
	 * @param {Map} outMap
	 * @param {Map} options
	 * @return {Boolean} success/failure
	 */
	global Boolean invokeMethod(String methodName, map < String, object > inputMap, map < String, object > outMap, map < String, object > options) {

		System.debug(Logginglevel.INFO, 'AssetB2B2ndLevelCardService.invokeMethod - methodName: ' + methodName);
		System.debug(Logginglevel.INFO, 'AssetB2B2ndLevelCardService.invokeMethod - inputMap: ' + inputMap);

		try {
			if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getB2BAsset2ndLevel')) {
				return getB2BAsset2ndLevel(inputMap, outMap);
			}

		} catch (Exception e) {
			system.debug(Logginglevel.ERROR, 'invokeMethod ' + methodName + ' ERROR :' + e.getMessage() + ' StackTraceString :' + e.getStackTraceString());
			return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, e.getMessage() + ':' + e.getStackTraceString());

		}
		return true;
	}

	/**
	 * Elad Iflah
	 * taskid PLR-560
	 * @method getB2BCellular2ndLevel
	 * @param  {map<String, object>} inputMap
	 * @param  {map<String, object>} outMap
	 * @return {Boolean} success/failure
	 */
	private boolean getB2BAsset2ndLevel(map < String, object > inputMap, map < String, object > outMap) {

		String inputAccId = (String) inputMap.get('accountId');
		String inputItemName = (String) inputMap.get('itemName');
		String categoryName = (String) inputMap.get('categoryName');
		//|| String.isEmpty(inputItemName)
		if (String.isEmpty(inputAccId)) {
			return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);

		}

		Account acc = AccountSidebarCardsService.getAccount(inputAccId);

		//OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00714');
		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00714', outMap, Label.msgSrvErr714, Label.msgSrvWarn714);

		AssetB2B2ndLevelCardBuilder.B2BCellData2LevelRequestBuilder b2bCell2CardBuilder = new AssetB2B2ndLevelCardBuilder.B2BCellData2LevelRequestBuilder(acc.RecordType.DeveloperName, inputItemName, categoryName);
		b2bCell2CardBuilder.CustInfo.AccountIdentifier = acc.CellcomExternalID__c;
		b2bCell2CardBuilder.CustInfo.Ssn = null;
		b2bCell2CardBuilder.CustInfo.Psids = null;
		b2bCell2CardBuilder.CustInfo.BanIds = null;
		b2bCell2CardBuilder.CustInfo.ContactIdentifier = null;

		request.body.setRequestNode(b2bCell2CardBuilder);

		Map < String, Object > response = request.sendRequestWithErrorCheck('OSB', '/api/services/rest/00714_osb_b2b_assetcardslayoutlevel2_bp');
		//if (AccountSidebarCardsService.isError(outMap, ctrlRequest, Label.msgResponseIssue)) return false;
		outMap.put('data', response);
		return true;
	}

}