/**
*   General mockup for all http outbound requests. Start from Sprint'17 we can use a Custom Metadata
*   to store all responses and headers
*
*   USAGE: in your test methods need put a line Test.setMock(HttpCalloutMock.class, new mockHttpOutboundResponse());
*
*  method must see like :
*
*   static testMethod void outbound() {
		mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
		mock.addResponse('ENDPOINT', HttpResponse);
		...
		mock.addResponse('ENDPOINT N', HttpResponseN);

*       Test.setMock(HttpCalloutMock.class, mock);
*       
*       //Your logic
*
*       test.startTest();
*           //Your logic
*       test.stopTest();
*   }
*
*   @class mockHttpOutboundResponse
*   author Dmitry Rivlin
*   @module {NEED SET}
*   @constructor
*/
@isTest
public class mockHttpOutboundResponse implements HttpCalloutMock {

	private map<string, httpResponse> responses;

	/**
	*   method description
	*   author Dmitry Rivlin
	*   taskId
	*
	*   @method mockHttpOutboundResponse

	*   @return 
	*
	*/
	public mockHttpOutboundResponse() {
		responses = new map<String, HttpResponse>();
		//fillAllResponses();
	}

	public void addResponse(String endPoint, HttpResponse response) {
		
        responses.put(endPoint.toLowerCase(), response);
	}

	/**
	*   Respond method from mockHttpOutboundResponse interface
	*   author Dmitry Rivlin
	*   taskId
	*
	*   @method respond
	*   @param  {HTTPRequest} req
	*   @return HTTPResponse
	*
	*/
	public HTTPResponse respond(HTTPRequest req) {
		String endPoint = req.getEndpoint().toLowerCase();
		HTTPResponse result;
        if (responses.containsKey(endPoint)) {
            result = responses.get(endPoint);
            system.debug(LoggingLevel.Error,'MOCK REQUEST ' + req + '\n' + result);
        }
		else {
			//throw new applicationException(null, 'Test data for endPoint : ' + endPoint + ' don\'t found', applicationException.ExceptionType.INBOUND);
			String msg = 'Test data for endPoint : ' + endPoint + ' don\'t found';
			result = new HTTPResponse();
			result.setStatusCode(404);
			result.setStatus(msg);
            system.debug(Logginglevel.ERROR,'RESPONSE: ' + msg);
		}
		return result;
	}

	/**
	*   In this method we need set all headers and body for all requests
	*   author Dmitry Rivlin
	*   taskId
	*
	*   @method fillAllResponses

	*   @return void
	*
	*/
	private void fillAllResponses() {
		responses = new map<String, HttpResponse>();
	}

}