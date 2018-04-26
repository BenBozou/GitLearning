/**
*   Test class for FileUploaderController
*   author Tal Sabati
*   taskid PLR-501
*   @class FileUploaderControllerTest
*   @module Leads
*/
@isTest
private class FileUploaderControllerTest {

    /**
    *   Method for testing FileUploaderController
    *   author Tal Sabati
    *   taskid PLR-501
    *   @method FileUploaderTest
    *   @return void
    */
    static testMethod void FileUploaderTest() {
        prepareTests();
        Test.startTest();
        testUploadFileFromOpp();
        testUploadFileFromCase();
        Test.stopTest();
    }
        
    private static void prepareTests() {
        
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
        EnvironmentSettings__c envSettings = (EnvironmentSettings__c ) new testFramework('EnvironmentSettings__c', 
                                              new map<String, Object> {'CurrentEnvironment__c' => 'Test'}, 
                                              settings).createObject();
         
        insert envSettings;
        
        mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        HttpResponse mockHttpResponse = new HttpResponse();
        mockHttpResponse.setBody('{"status":"<std:ReturnCode>00</std:ReturnCode>"}');                
        String endPoint = OutboundCalloutService.getEndPoint('api/services/soap/osb_genericfileupload_filesystem_00672','OSB');
        mock.addResponse(endPoint ,mockHttpResponse);  
        Test.setMock(HttpCalloutMock.class, mock);
    }
    
    private static void testUploadFileFromOpp(){
        Opportunity opp = TestFactory.testCreateOpportunity();
        
        PageReference pageRef = Page.FileUploader;
        pageRef.getParameters().put('retURL', '/' + opp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController standardController = new ApexPages.standardController(new ExternalAttachment__c());
        FileUploaderController controller = new FileUploaderController(standardController);
        controller.filebody = Blob.valueOf('Unit Test Document Body');
        controller.externalAttachment.Name__c = 'Test File.txt';
        controller.upload();
        
        controller = new FileUploaderController(standardController);
        controller.cancel();
    }
    
    
     private static void testUploadFileFromCase(){
        Case cas = TestFactory.testCreateCase();
        
        PageReference pageRef = Page.FileUploader;
        pageRef.getParameters().put('retURL', '/' + cas.id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController standardController = new ApexPages.standardController(new ExternalAttachment__c());
        FileUploaderController controller = new FileUploaderController(standardController);
        controller.filebody = Blob.valueOf('Unit Test Document Body');
        controller.externalAttachment.Name__c = 'Test File.txt';
        controller.upload();
        
        controller = new FileUploaderController(standardController);
        controller.cancel();
    }
}