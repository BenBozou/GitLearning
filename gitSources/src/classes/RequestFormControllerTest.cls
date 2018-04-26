@isTest
private class RequestFormControllerTest {

    @testSetup 
    static void setupTestData(){
        
        Opportunity opp = TestFactory.testCreateOpportunity();
        opp = [select id, Name, StageName from Opportunity where id =: opp.id];
        
        list<sObject> configList = new list<sObject>();
        configList.add(testCreateRequestConfig('Implementation',1,'Stage','Output','','Opportunity','Opportunity','Name','Id','OpportunityId__c'));
        configList.add(testCreateRequestConfig('Implementation',2,'Stam','Picklist','a;b;c','','','','',''));
        configList.add(testCreateRequestConfig('Implementation',2,'Stam2','Picklist','a;b;c','','','','',''));
        configList.add(testCreateRequestDetailsConfig('Implementation',opp.Name,'a','a',1,'field1','Text Short','',''));
        configList.add(testCreateRequestDetailsConfig('Implementation',opp.Name,'a','a',2,'field2','Picklist','1;2;3',''));
        configList.add(testCreateRequestDetailsConfig('Implementation',opp.Name,'a','a',3,'only data','Data','',''));
        configList.add(testCreateRequestDetailsConfig('Implementation',opp.Name,'a','b',1,'test link','URL','',''));
        configList.add(testCreateRequestDetailsConfig('Approval Request','Direct Manager','Manager Pricelist','',1,'only data','Data','',''));
        configList.add(testCreateRequestDetailsConfig('Approval Request','Indirect Manager','Manager Pricelist','',1,'only data','Data','',''));
        configList.add(testCreateRequestDetailsConfig('Approval Request','Vice President','Manager Pricelist','',1,'only data','Data','','requestTestQueue'));
        Request__c parentReq = testCreateCommercialRequest('Direct Manager','Manager Pricelist', opp.Id,null,'In Process');
        configList.add(parentReq);
        insert configList;
        
        list<Request__c> childReqList = new list<Request__c>();
        childReqList.add(testCreateCommercialRequest('Direct Manager','Manager Pricelist', opp.Id,parentReq.Id,'In Process'));
        childReqList.add(testCreateCommercialRequest('Indirect Manager','Manager Pricelist', opp.Id,parentReq.Id,'Hold'));
        insert childReqList;
        
        Group reqQueue = new Group(Name='requestTestQueue', type='Queue');
        insert reqQueue;
    }
    
    static testMethod void RequestFormTest() {
        
        Opportunity opp = [select id, StageName from Opportunity limit 1];
        
        PageReference pageRef = Page.RequestForm;
        pageRef.getParameters().put('oppId_lkid', opp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Request__c());
        Test.StartTest();
        //Operative
        RequestFormController requestForm = new RequestFormController(sc);
        requestForm.request.OpportunityId__c = opp.id;
        requestForm.request.Source__c = 'Opportunity';
        requestForm.sourceObjType = 'Opportunity';
        requestForm.startFlowBasedOnCategory();
        requestForm.request.Category__c = 'Operative';
        requestForm.startFlowBasedOnCategory();
        requestForm.request.Type__c = 'Implementation';
        requestForm.request.SLA__c = 1000;
        requestForm.retreiveControllingMetadata();
        //requestForm.controllingFieldsList[0].fieldValue --> contains the opportunity name
        system.debug(Logginglevel.ERROR,'>>> requestForm.controllingFieldsList: ' + requestForm.controllingFieldsList.size());
        requestForm.cont2Val = 'a';
        requestForm.cont3Val = 'a';
        //requestForm.controllingFieldsList[1].fieldValue = 'a';
        //requestForm.controllingFieldsList[1].fieldValueLabel = 'a';
        requestForm.retreiveFieldsMetadata();
        requestForm.requestDetailsWrapList[0].rDetails.FieldValue__c = 'value for field1';
        requestForm.requestDetailsWrapList[0].rDetails.FieldValue__c = '2';//value for field2
        requestForm.createRequest();
        requestForm.back();
        requestForm.cancel();
        //Operative URL
        requestForm = new RequestFormController(sc);
        requestForm.request.OpportunityId__c = opp.id;
        requestForm.request.Source__c = 'Opportunity';
        requestForm.sourceObjType = 'Opportunity';
        requestForm.request.Category__c = 'Operative';
        requestForm.request.Type__c = 'Implementation';
        requestForm.retreiveControllingMetadata();
        //requestForm.controllingFieldsList[0].fieldValue --> contains the opportunity name
        requestForm.cont2Val = 'a';
        requestForm.cont3Val = 'b';
        requestForm.retreiveFieldsMetadata();
        requestForm.createRequest();
        //Commercial
        requestForm = new RequestFormController(sc);
        requestForm.request.OpportunityId__c = opp.id;
        requestForm.request.Source__c = 'Opportunity';
        requestForm.sourceObjType = 'Opportunity';
        requestForm.request.Category__c = 'Commercial';
        requestForm.startFlowBasedOnCategory();
        requestForm.childRequestsList[0].Approver__c = 'Direct Manager';//Indirect Manager
        requestForm.childRequestsList[0].ApprovalType__c = 'Manager Pricelist';
        requestForm.addRequest();
        requestForm.childRequestsList[1].Approver__c = 'Indirect Manager';//'Vice President';
        requestForm.childRequestsList[1].ApprovalType__c = 'Manager Pricelist';
        requestForm.addRequest();
        requestForm.childRequestsList[1].Approver__c = 'Vice President';
        requestForm.childRequestsList[1].ApprovalType__c = 'Manager Pricelist';
        requestForm.addRequest();
        requestForm.requestIndexToDelete = 4;
        requestForm.deleteRequest();
        requestForm.createCommercialRequest();
        Test.StopTest();
    }
    
    static testMethod void RequestViewEditComponentControllerTest() {
        Test.StartTest();
        RequestViewEditComponentController controller = new RequestViewEditComponentController();
        controller.req = [select id, Category__c, Status__c, OwnerId, CreatedById, ProductLineItemId__c, (select id, Status__c, OwnerId from Requests__r) from Request__c where ParentRequestId__c = null limit 1];
        controller.pageMode = '';
        //controller.req.Requests__r[0].Status__c = 'Approved';
        controller.childRequests[0].Status__c = 'Approved';
        controller.saveRequest();
        //controller.req.Requests__r[1].Status__c = 'Approved';
        controller.childRequests[1].Status__c = 'Approved';
        controller.saveRequest();
        controller.reSend();
        controller.EditRequest();
        controller.getHasEditAccess();
        Test.StopTest();
    }
    
    public static RequestConfig__c testCreateRequestConfig(String rType, Decimal fieldOrder, String fieldLabel, String  fieldType, String picklistOptions, String objType, String fieldSourceObject, String fieldSourcePath, String fieldSourceCriteria, String fieldSourceIdentifier){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
        RequestConfig__c rConfig = (RequestConfig__c) new testFramework('RequestConfig__c', new map<String, Object> {
            'RequestType__c' => rType,
            'FieldOrder__c' => fieldOrder,
            'FieldLabel__c' => fieldLabel,
            'FieldType__c' => fieldType,
            'PicklistOptions__c' => picklistOptions,
            'ObjectType__c' => objType,
            'FieldSourceObject__c' => fieldSourceObject,
            'FieldSourcePath__c' => fieldSourcePath,
            'FieldSourceCriteria__c' => fieldSourceCriteria,
            'FieldSourceIdentifier__c' => fieldSourceIdentifier
            }, settings).createObject();
        
        return rConfig;     
    }
    
    
    public static RequestDetailsConfig__c testCreateRequestDetailsConfig(String rType, String controllingValue1, String controllingValue2, String controllingValue3, Decimal fieldOrder, String fieldLabel, String fieldType, String picklistOptions, String queueName){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
        RequestDetailsConfig__c rdConfig = (RequestDetailsConfig__c) new testFramework('RequestDetailsConfig__c', new map<String, Object> {
            'RequestType__c' => rType,
            'ControllingValue1__c' => controllingValue1,
            'ControllingValue2__c' => controllingValue2,
            'ControllingValue3__c' => controllingValue3,
            'FieldOrder__c' => fieldOrder,
            'FieldLabel__c' => fieldLabel,
            'FieldType__c' => fieldType,
            'PicklistOptions__c' => picklistOptions,
            'QueueSFDCID__c' => queueName
            }, settings).createObject();
        
        return rdConfig;        
    }
    
    
    public static Request__c testCreateCommercialRequest(String approver, String approvalType, Id oppId, Id parentReq, String status){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
        Request__c request = (Request__c) new testFramework('Request__c', new map<String, Object> {
            'Category__c' => 'Commercial',
            'Source__c' => 'Opportunity',
            'Type__c' => 'Approval Request',
            'Approver__c' => approver,
            'ApprovalType__c' => approvalType,
            'OpportunityId__c' => oppId,
            'ParentRequestId__c' => parentReq,
            'Status__c' => status
            }, settings).createObject();
        
        return request;     
    }
    
}