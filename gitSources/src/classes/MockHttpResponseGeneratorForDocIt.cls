/**
*   send a mock response for a specific endpoint: DocIt_int_2
*   author Tal Sabati
*   taskid PLR-501
*   @class MockHttpResponseGeneratorForDocIt
*   @module Leads
*   @return Http Response
*/
@isTest
global class MockHttpResponseGeneratorForDocIt implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('callout:DocIt_int_2', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"<std:ReturnCode>00</std:ReturnCode>"}');
        res.setStatusCode(200);
        return res;
    }
}