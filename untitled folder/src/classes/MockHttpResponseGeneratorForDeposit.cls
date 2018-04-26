/**
*   send a mock response for Deposit Indicators Card
*   Gili Yehuda
*   taskid PLR-310
*   @class MockHttpResponseGeneratorForDeposit
*   @module 360
*	@return Http Response
*/
@isTest
global class MockHttpResponseGeneratorForDeposit  implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://sfiapi-int2.cellcom.co.il/api/services/rest/osb_retrievecustomerdeposit_sap_00653', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setHeader('Accept', 'application/json');
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);
        return res;
    }
}