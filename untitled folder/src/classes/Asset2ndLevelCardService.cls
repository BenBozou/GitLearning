/**
* Service class for asset 2nd level cards.
* Tal sabati
* taskid PLR-902
* @class Asset2ndLevelCardService
* @module 360
*/
global with sharing class Asset2ndLevelCardService implements vlocity_cmt.VlocityOpenInterface2 {

	/**
	* Method implemented from interface, that will be called from vlocity card,
	* and will call inner method according to method name.
	* Tal sabati
	* taskid PLR-902
	* @method invokeMethod
	* @param {String} methodName
	* @param {Map} inputMap
	* @param {Map} outMap
	* @param {Map} options
	* @return {Boolean} success/failure
	*/
	global Boolean invokeMethod(String methodName, map<String, object> inputMap, map<String, object> outMap, map<String, object> options){

		System.debug(Logginglevel.INFO, 'Asset2ndLevelCardService.invokeMethod - methodName: ' + methodName);
		System.debug(Logginglevel.INFO, 'Asset2ndLevelCardService.invokeMethod - inputMap: ' + inputMap);

		try{
			if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getCellularCardData')) {
				return getCellularCardData(inputMap, outMap);
			}
			if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getTVCardData')) {
				return getTVCardData(inputMap, outMap);
			}
			if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getISPCardData')) {
				return getISPCardData(inputMap, outMap);
			}
			if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getVOIPCardData')) {
				return getVOIPCardData(inputMap, outMap);
			}
			if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getBundleCardData')) {
				return getBundleCardData(inputMap, outMap);
			}
			if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getInfrastructureCardData')) {
				return getInfrastructureCardData(inputMap, outMap);
			}
		}
		catch(Exception e) {
			system.debug(Logginglevel.ERROR,'invokeMethod ' + methodName +' ERROR :'+e.getMessage() +' StackTraceString :'+ e.getStackTraceString());
		}
		return true;
	}

	/**
	* Tal Sabati
	* taskid PLR-988
	* @method getInfrastructureCardData
	* @param  {map<String, object>} inputMap
	* @param  {map<String, object>} outMap
	* @return {Boolean} success/failure
	*/
	private boolean getInfrastructureCardData(map<String, object> inputMap, map<String, object> outMap){
		//OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00704');
		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00704', outMap, Label.msgSrvErr704, Label.msgSrvWarn704);
		Asset2ndLevelCardBuilder.InfrastructureCardBuilder bundleCardBuilder = new Asset2ndLevelCardBuilder.InfrastructureCardBuilder(string.valueOf(inputMap.get('subscriberNo')),'39087NB',string.valueOf(inputMap.get('productId')),string.valueOf(inputMap.get('accountId')),string.valueOf(inputMap.get('contactId')),string.valueOf(inputMap.get('banId')),string.valueOf(inputMap.get('psId')));
		Request.body.setRequestNode(bundleCardBuilder);
		Map<String,Object> response = Request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00704_osb_internetinfrastructureasset_bp');

		//if (AccountSidebarCardsService.isError(outMap, ctrlRequest, Label.msgResponseIssue)) return false;
		outMap.put('data', response);
		return true;
	}

	/**
	* Tal Sabati
	* taskid PLR-946
	* @method getBundleCardData
	* @param  {map<String, object>} inputMap
	* @param  {map<String, object>} outMap
	* @return {Boolean} success/failure
	*/
	private boolean getBundleCardData(map<String, object> inputMap, map<String, object> outMap){
		//OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00702');
		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00704', outMap, Label.msgSrvErr702, Label.msgSrvWarn702);
		Asset2ndLevelCardBuilder.BundleCardBuilder bundleCardBuilder = new Asset2ndLevelCardBuilder.BundleCardBuilder(string.valueOf(inputMap.get('productId')),string.valueOf(inputMap.get('productType')),'C',string.valueOf(inputMap.get('bundleId')),string.valueOf(inputMap.get('accountId')),string.valueOf(inputMap.get('contactId')),string.valueOf(inputMap.get('banId')),string.valueOf(inputMap.get('psId')));
		Request.body.setRequestNode(bundleCardBuilder);
		Map<String,Object> response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00702_OSB_Bundles_Card_K2view_Tuxedo');

		//if (AccountSidebarCardsService.isError(outMap, ctrlRequest, Label.msgResponseIssue)) return false;
		outMap.put('data', response);
		return true;
	}

	/**
	* Tal Sabati
	* taskid PLR-554
	* @method getVOIPCardData
	* @param  {map<String, object>} inputMap
	* @param  {map<String, object>} outMap
	* @return {Boolean} success/failure
	*/
	private boolean getVOIPCardData(map<String, object> inputMap, map<String, object> outMap){
		//OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00698');
		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00698', outMap, Label.msgSrvErr698, Label.msgSrvWarn698);
		Asset2ndLevelCardBuilder.VOIPCardBuilder VOIPCardBuilder = new Asset2ndLevelCardBuilder.VOIPCardBuilder(string.valueOf(inputMap.get('subscriberNo')),'16364NB',string.valueOf(inputMap.get('productId')),string.valueOf(inputMap.get('banId')),string.valueOf(inputMap.get('psId')), 'C');
		request.body.setRequestNode(VOIPCardBuilder);
		Map<String,Object> response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00698_osb_getnvproductdetails_bp');

		//if (AccountSidebarCardsService.isError(outMap, ctrlRequest, Label.msgResponseIssue)) return false;
		outMap.put('data', response);
		return true;
	}

	/**
	* Tal Sabati
	* taskid PLR-905
	* @method getTVCardData
	* @param  {map<String, object>} inputMap
	* @param  {map<String, object>} outMap
	* @return {Boolean} success/failure
	*/
	private boolean getISPCardData(map<String, object> inputMap, map<String, object> outMap){
		//OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00695');
		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00695', outMap, Label.msgSrvErr695, Label.msgSrvWarn695);
		Asset2ndLevelCardBuilder.ISPCardBuilder ISPCardBuilder = new Asset2ndLevelCardBuilder.ISPCardBuilder(string.valueOf(inputMap.get('subscriberNo')),'4NB',string.valueOf(inputMap.get('productId')),string.valueOf(inputMap.get('banId')),string.valueOf(inputMap.get('psId')));
		request.body.setRequestNode(ISPCardBuilder);
		Map<String,Object> response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00695_osb_retrieveispdata_k2view');

		//if (AccountSidebarCardsService.isError(outMap, ctrlRequest, Label.msgResponseIssue)) return false;
		outMap.put('data', response);
		return true;
	}

	/**
	* Tal Sabati
	* taskid PLR-902
	* @method getTVCardData
	* @param  {map<String, object>} inputMap
	* @param  {map<String, object>} outMap
	* @return {Boolean} success/failure
	*/
	private boolean getTVCardData(map<String, object> inputMap, map<String, object> outMap){
		//OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00693');
		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00693', outMap, Label.msgSrvErr693, Label.msgSrvWarn693);
		Asset2ndLevelCardBuilder.TVCardBuilder tvCardBuilder = new Asset2ndLevelCardBuilder.TVCardBuilder(string.valueOf(inputMap.get('subscriberNo')), 'T',string.valueOf(inputMap.get('productId')),string.valueOf(inputMap.get('banId')));
		request.body.setRequestNode(tvCardBuilder);
		Map<String,Object> response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00693_osb_tvcard_bp');

		//if (AccountSidebarCardsService.isError(outMap, ctrlRequest, Label.msgResponseIssue)) return false;
		outMap.put('data', response);
		return true;
	}
	/**
	*   method description
	*   author Liron Cohen
	*   taskid PLR-543
	*   @method getCellularCardData
	*   @param  {map<String, object>} inputMap
	*   @param  {map<String, object>} outMap
	*   @return {Boolean} success/failure
	*/
	private boolean getCellularCardData(map<String, object> inputMap, map<String, object> outMap){

		String banId = (string) inputMap.get('banId');
		//OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00687');
		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00687', outMap, Label.msgSrvErr687, Label.msgSrvWarn687);
		Asset2ndLevelCardBuilder.CellularCardBuilder cellularCardBuilder = new Asset2ndLevelCardBuilder.CellularCardBuilder(string.valueOf(inputMap.get('subscriberNo')),'C',string.valueOf(inputMap.get('productId')),string.valueOf(inputMap.get('banId')));
		Request.body.setRequestNode(cellularCardBuilder);
		Map<String,Object> response = Request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00687_osb_getproductdetails');

        Boolean splitOrBusiness = false;
        
		list<Account> billingAcc_Lst = [SELECT Id, Parent.ConsumerType__c, Parent.RecordType.DeveloperName, Parent.Parent.RecordType.DeveloperName FROM Account WHERE BANPSID__c =: banId limit 1];
		
		if( billingAcc_Lst[0].Parent.RecordType.DeveloperName == 'Business' ||
		    (billingAcc_Lst[0].Parent.RecordType.DeveloperName == 'Consumer' && 
		     billingAcc_Lst[0].Parent.ParentId != null && 
		     billingAcc_Lst[0].Parent.Parent.RecordType.DeveloperName == 'Business') )
		{
		    splitOrBusiness = true;
		}

		if (!billingAcc_Lst.isEmpty()) {

			if (response.containsKey('Body')) {
				Map<String, Object> Body_Map = (Map<String, Object>)response.get('Body');
				if (Body_Map.containsKey('Response')) {
					Map<String, Object> response_Map = (Map<String, Object>)Body_Map.get('Response');
					if (response_Map.containsKey('WebServiceResponse')) {
						Map<String, Object> webServiceResponse_Map = (Map<String, Object>)response_Map.get('WebServiceResponse');
						if (webServiceResponse_Map.containsKey('results')) {
							Map<String, Object> results_Map = (Map<String, Object>)webServiceResponse_Map.get('results');
							if (results_Map.containsKey('Product')) {
								Map<String, Object> Product_Map = (Map<String, Object>)results_Map.get('Product');
								if (Product_Map.containsKey('ProductData')) {
								Map<String, Object> ProductData_Map = (Map<String, Object>)Product_Map.get('ProductData');
								    //ProductData_Map.put('AccType', String.valueOf(billingAcc_Lst[0].Parent.ConsumerType__c));
								    ProductData_Map.put('splitOrBusiness', String.valueOf(splitOrBusiness) );
								}
							}
						}
					}
				}
			}
		}

		//if (AccountSidebarCardsService.isError(outMap, ctrlRequest, Label.msgResponseIssue)) return false;

		outMap.put('data', response);
		return true;
	}

	/**
	*   Method set error in the output map
	*   @method returnError
	*   @param  {object} msg
	*   @param  {String} key
	*   @param  {map<String, object>} outMap
	*   @return {Boolean} failure
	*/
}