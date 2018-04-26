global with sharing class osbint1test implements vlocity_cmt.VlocityOpenInterface2
{

	global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

		System.debug(Logginglevel.INFO, 'IndicatorsCardsService.invokeMethod - methodName: ' + methodName);
		System.debug(Logginglevel.INFO, 'IndicatorsCardsService.invokeMethod - inputMap: ' + inputMap);

		try
		{

			if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getDeliveryDetails')) {
				return getDeliveryDetails(inputMap, outMap, options);
			}
			
		}
		catch(Exception e) {
			system.debug(Logginglevel.ERROR,'invokeMethod ' + methodName +' ERROR :'+e.getMessage() +' StackTraceString :'+ e.getStackTraceString());
		}

		return true;
	}


	 private static Boolean getDeliveryDetails(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

		String requestJSON = '{"Header":{"From":"SF","To":"OSB","ProcessID":"string","MessageID":"string","ActionID":"string","ReturnCode":"string","ReturnCodeMessage":"string","UserName":"ELAADIF","OptionalReturnAddress":"string","FunctionCode":"00790","NextTryIndex":"string"},"Body":{"Request":{"CustInfo":{"BanIds":{"BanId":["246845421","323330387","319489026","323374196"]}},"ServiceInfo":{"StatusesDatesInfo":{"StatusDateInfo":[{"Status":"B","StartDate":"01/11/2016","EndDate":"31/12/2017"}]}}}}}';
		system.debug(Logginglevel.INFO,'REQUEST: ' + requestJSON);

		Map<String,Object> myMap = new Map<String,Object>();
		String bodyResponse = getCallOutBodyResponse('osb_getdeliveriesinfo_sap_00790', requestJSON, myMap);
		outMap.putAll(myMap);

		return true;
	 }

	private static String getCallOutBodyResponse(String serviceName, String requestJSON, Map<String,Object> bodyResponse)
	{
		String callOutPrefixUrl='https://sfiapi-int1.cellcom.co.il/api/services/rest/';
		String callOutUrl= callOutPrefixUrl + serviceName;

		HttpRequest req = new HttpRequest();
		req.setEndpoint(callOutUrl);
		req.setBody(requestJSON) ;
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json;charset=UTF-8');
		req.setHeader('Accept', 'application/json');

		Http http = new Http();
		HTTPResponse res = http.send(req);

		system.debug(Logginglevel.INFO,'RESPONSE: ' + res.getBody());

		bodyResponse.putAll((Map<String,Object>)Json.deserializeUntyped(res.getBody()));
		system.debug(Logginglevel.INFO,'RESPONSE MAP: ' + bodyResponse);

		return res.getBody();
	}



}