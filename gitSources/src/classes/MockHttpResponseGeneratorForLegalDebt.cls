/**
*   send a mock response for Legal Debt Indicators Card
*   Gili Yehuda
*   taskid PLR-137
*   @class MockHttpResponseGeneratorForLegalDebt
*   @module 360
*	@return Http Response
*/
@isTest
global class MockHttpResponseGeneratorForLegalDebt  implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://sfiapi-int2.cellcom.co.il/api/services/rest/osb_retrievecustomerfinancedata_bp_00668', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setHeader('Accept', 'application/json');
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);
        return res;
    }
}