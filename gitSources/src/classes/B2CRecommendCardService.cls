/**
* Class for retrieving Asset 1st level
* Elad Iflah
* taskid PLR-1038
* @class B2CRecommendCardService
* @module 360
*/
global with sharing class B2CRecommendCardService implements vlocity_cmt.VlocityOpenInterface2 {

	global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

		system.debug(Logginglevel.INFO, '#### B2CRecommendCardService.invokeMethod: ' + methodName );

		outMap.put('processError', 'false');

		try {
			if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getRecommendations')) {
				return getRecommendations(inputMap, outMap, options);
			}

		} catch (Exception e) {
			system.debug(Logginglevel.ERROR, 'invokeMethod ' + methodName + ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());
			return AccountSidebarCardsService.returnError(outMap, AccountSidebarCardsService.cardStatus.ERROR, e.getMessage() + ':' + e.getStackTraceString());
		}

		return true;
	}

	/**
	*   Callout to Legacy systems through the OSB to retrieve B2C recommendations
	*   author Elad Iflah
	*
	*   @method getRecommendations
	*   @param  {map<String, object>} inputMap
	*   @param  {map<String, object>} outMap
	*   @param  {map<String, object>} options
	*   @return {Boolean}
	*/
	private static Boolean getRecommendations(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
		String inputAccId = (String)inputMap.get('accountId');
		String inputContId = (String)inputMap.get('contactId');		
		String inputTreatCount = (String)inputMap.get('treatCount');

		if( String.isEmpty(inputAccId) || String.isEmpty(inputContId) || String.isEmpty(inputTreatCount)) {
			return AccountSidebarCardsService.returnError(outMap,AccountSidebarCardsService.cardStatus.ERROR, Label.GoldIndicatorsError);
		}
        
        
		User userData = [Select FederationIdentifier From User where Id=:userinfo.getuserId() limit 1];
		string uName = userData.FederationIdentifier;

		Account acc = AccountSidebarCardsService.getAccount(inputAccId);
		Contact con = AccountSidebarCardsService.getContact(inputContId);
        
        // user that works 'DORONKE'
		IndicatorsCalloutBuilder.RecommendationsBuilder curRequest = new IndicatorsCalloutBuilder.RecommendationsBuilder( uName, '', 'INBOUND', inputTreatCount, '3');
		curRequest.CustInfo.setBanPsIds(acc, con);

		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00684');
		request.body.setRequestNode(curRequest);

		Map < String, Object > response = request.sendRequestWithErrorCheck('OSB','api/services/rest/00684_osb_getrecommends_dwh');
		if (AccountSidebarCardsService.isError(outMap,request, Label.msgResponseIssue)) return false;

		/*if (response == null) {
			return returnError(outMap, 'processErrorMsg', 'Response issue');
		}*/
		outMap.put('data',response);
		return true;
	}



}