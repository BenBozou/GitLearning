/*
*
*    endpoint : /services/apexrest/inboundWebservice/CustomerStory/getCustomerStory
*    Request Body:
*   {
		"banId" : "string",
		"psId" : "string"
*   }
*/
public with sharing class InboundWebserviceCustomerStory implements inboundWebservice.InboundWebserviceInterface{

	public void handle(RestRequest requestClass, inboundWebservice.InboundRestResponse result) {
			try {

				if(result.requestedAction == 'getCustomerStory'){
						customerStoryRequest request = (customerStoryRequest) JSON.deserialize(requestClass.requestBody.toString(), customerStoryRequest.class);

						if (string.isEmpty(request.banId) && string.isEmpty(request.psId)) {
							setResultError('Please provide banId OR psId', 2, result);
							return;
						}
						if (!string.isEmpty(request.banId) && !string.isEmpty(request.psId)) {
							setResultError('Please provide only ONE parameter. banId OR psId', 4, result);
							return;
						}

						String banPsId = string.isEmpty(request.banId)
							? request.psId
							: request.banId;

						String condition = string.isEmpty(request.banId)
							? 'NETV_Ind__c=true'
							: 'Cell_Ind__c=true';

						String SQL = 'SELECT ParentId, Id, NETV_Ind__c, Cell_Ind__c FROM Account WHERE BANPSID__c =:banPsId AND RecordType.DeveloperName=\'Billing\' ' + ' AND ' + condition + ' LIMIT 1';
						Account[] accLst = database.query(sql);
						if (accLst.size() == 0) {
							setResultError('Please provide correct banId OR psId', 5, result);
							return;
						}

						if (banPsId == request.banId && accLst[0].Cell_Ind__c== false) {
							setResultError('Please check banId', 6, result);
							return;
						}

						if (banPsId == request.psId && accLst[0].NETV_Ind__c== false) {
							setResultError('Please check psId', 7, result);
							return;
						}
						if (accLst[0].ParentId == null) {
							setResultError('Account with taken ban/psId don\'t have correct Parent Account', 8, result);
							return;
						}

						Account Acc = [SELECT Id,(SELECT Id, ContactId FROM AccountContactRelations) FROM Account WHERE Id=:accLst[0].ParentId];


						Map < String, Object > inputMap = new Map <String, Object>{'accountId' =>acc.Id,'contactId' => (acc.AccountContactRelations.size()>0) ? acc.AccountContactRelations[0].ContactId : null};
						Map < String, Object > outMap = new Map <String, Object>();
						Map < String, Object > options = new Map <String, Object>();

						CustomerStory Ctrl = new CustomerStory();
						Boolean res = Ctrl.invokeMethod(result.requestedAction, inputMap, outMap, options);
						result.response = outMap;
				} else {
					setResultError('Incorrect Service Name', 2, result);
				}
			} catch(Exception ex) {
				//result.response = requestClass.requestBody.toString();
				setResultError('Exception ' + ex.getStackTraceString(),99,result);
			}
		}

		private void setResultError(String errorMessage, Integer errorCode, inboundWebservice.InboundRestResponse result){
			result.statusCode = errorCode;
			result.statusCodeAsString = '0' + string.valueOf(result.statusCode);
			result.statusMessage = errorMessage;
			result.response = '';
		}

		private class customerStoryRequest {
			String banId;
			String psId;
		}
}