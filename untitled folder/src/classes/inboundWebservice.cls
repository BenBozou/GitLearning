/**
*   Main INBOUND WebService dispatcher
*
*   @class inboundWebservice
*   author Dmitry Rivlin
*   @module WebService
*   @constructor
*
*   endpoint : /services/apexrest/inboundWebservice[YOUR NAME]
*   Usage : need create a class inboundWebservice[YOUR NAME] like this
*
*
*   public with sharing class InboundWebserviceNextLead  implements inboundWebservice.InboundWebserviceInterface {
*
*
*           public InboundWebserviceNextLead() {
*
*           }
*
*           public void handle(RestRequest request, inboundWebservice.InboundRestResponse result) {
*               // Your logic
*           }
*
*   }
*/
@RestResource(urlMapping='/inboundWebservice/*')
global with sharing class inboundWebservice {


	// Interface Declaration
	public interface InboundWebserviceInterface {
		void handle(RestRequest request, InboundRestResponse result);
	}

	@HttpGet
	/**
	*   method GET
	*   author Dmitry Rivlin
	*   taskId PLR-627
	*
	*   @method inboundWebserviceGet
	*   @return void
	*
	*/
	global static void inboundWebserviceGet() {
		inboundWebserviceInit();
	}

	@HttpPost
	/**
	*   method POST
	*   author Dmitry Rivlin
	*   taskId  PLR-627
	*
	*   @method inboundWebservicePost
	*   @return void
	*
	*/
	global static void inboundWebservicePost() {
		inboundWebserviceInit();
	}

	/**
	*   method main webservice method for dynamic invoke interfaces
	*   author Dmitry Rivlin
	*   taskId  PLR-627
	*
	*   @method inboundWebserviceInit

	*   @return void
	*
	*/
	private static void inboundWebserviceInit() {
		String[] path = RestContext.request.requestURI.split('/');
		InboundRestResponse result;

		try {
			system.debug(LoggingLevel.ERROR,'InboundWebservice URI : ' + RestContext.request.requestURI);
			if (RestContext.request.httpMethod == 'POST') system.debug(LoggingLevel.ERROR,'InboundWebservice BODY : ' + RestContext.request.requestBody.toString());

			if (path.size()<2) throw new applicationException(null, Label.errMsgInboundExceptionParams, applicationException.ExceptionType.INBOUND);

			String serviceName = path[2];
			String requestedAction = path.size()>2 ? path[3] : null;

			result = new InboundRestResponse(serviceName, requestedAction);

			Type handlerType = Type.forName('InboundWebservice' + serviceName);

			if (handlerType == null) throw new applicationException(null, Label.errMsgInboundException.replace('{0}', serviceName).replace('{1}', requestedAction), applicationException.ExceptionType.INBOUND);

			inboundWebserviceInterface connectorInstance = (inboundWebserviceInterface) handlerType.newInstance();
			connectorInstance.handle(RestContext.request, result);
		} catch (Exception E) {
			string errorMsg = e.getMessage() + ' : ' + e.getStackTraceString();
			system.debug(LoggingLevel.ERROR,'EXCEPTION : ' + errorMsg);
			result.statusCode = 90;
			result.statusMessage = errorMsg;
			result.response = RestContext.request.requestBody.toString();
		}
		system.debug(LoggingLevel.ERROR,'RESULT ' + result);
		RestContext.response.responseBody = blob.valueOf(JSON.serialize(result));
		RestContext.response.addHeader('Content-Type', 'application/json;charset=utf-8');

		//Write the request & response to log
		LoggerService.writeInboundMessage(
				new LoggerService.IntegrationMessage(RestContext.request, result));
	}

	// Response class declaration
	public class InboundRestResponse {
		public integer statusCode;
		public string statusCodeAsString;
		public string statusMessage;
		public string requestedAction;
		public string serviceName;
		public object response;

		public InboundRestResponse(string serviceName, string requestedAction) {
			this.statusCode = 0;
			this.statusCodeAsString = '0' + string.valueOf(this.statusCode);
			this.serviceName = serviceName;
			this.requestedAction = requestedAction;
		}
	}

}