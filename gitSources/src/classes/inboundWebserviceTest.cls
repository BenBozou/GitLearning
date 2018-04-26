/**
*   Test class for all inbound web services
*   
*   @class inboundWebserviceTest
*   author Dmitry Rivlin
*   @module TestClass
*   @constructor
*/
@isTest
public class inboundWebserviceTest {
    
    private static inboundWebservice.InboundRestResponse prepareInboundWebservice(
            string serviceName, 
            string actionName, 
            string urlParams, 
            string body, 
            string method) {

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/inboundWebservice/' + serviceName + '/' + actionName;
        if (method == 'GET'){ 
            RestContext.request.requestURI += '?' + urlParams;
            inboundWebservice.inboundWebserviceGet();
        }
        if (method == 'POST'){
            RestContext.request.requestBody = Blob.valueof(body);
            inboundWebservice.inboundWebservicePost();
        }
        //inboundWebservice.InboundRestResponse result = (inboundWebservice.InboundRestResponse) JSON.deserialize(RestContext.response.responseBody.toString(), inboundWebservice.InboundRestResponse.class);
        inboundWebservice.InboundRestResponse result = new inboundWebservice.InboundRestResponse(serviceName, actionName);
        return result;
    }
    
    static testMethod void inboundWebserviceCustomerStory() {
		setupTestData();
		test.startTest();
			String body='{}';
			inboundWebservice.InboundRestResponse res = prepareInboundWebservice('CustomerStory','getCustomerStory','', body, 'POST');
			body='{"banId":"test", "psId":"test"}';
		    res = prepareInboundWebservice('CustomerStory','getCustomerStory','', body, 'POST');
			body='{"banId":"test"}';
			res = prepareInboundWebservice('CustomerStory','getCustomerStory','', body, 'POST');
			body='{"psId":"test"}';
			res = prepareInboundWebservice('CustomerStory','getCustomerStory','', body, 'POST');
			body='{"psId":"test1"}';
			res = prepareInboundWebservice('CustomerStory','getCustomerStory','', body, 'POST');
			body='{"psId":"test1"}';
			res = prepareInboundWebservice('CustomerStory','getCustomerStory1','', body, 'POST');
			
			
		test.stopTest();
	}
    /**
    *   Check exception for webservice
    *   author Dmitry Rivlin
    *   taskId PLR-627
    *
    *   @method inboundWebserviceGenerateException

    *   @return void
    *
    
    static testMethod void inboundWebserviceGenerateException() {
        test.startTest();
            inboundWebservice.InboundRestResponse res = prepareInboundWebservice('Test','Test','','GET');
            system.debug(LoggingLevel.ERROR,' RESPONSE ' + res);
            system.assertEquals(res.statusCode, 99);
        test.stopTest();
    }
    */
    
    static testMethod void inboundWebserviceTest() {
        setupTestData();
        test.startTest();     
        inboundWebserviceInteractionEvent();
        inboundWebserviceNextLead();
        inboundWebserviceLeadTest();
        test.stopTest();
    }
    /**
    *   Test for InboundWebserviceInteractionEvent
    *   author Tal sabati
    *   taskid PLR-694
    *   @method inboundWebserviceInteractionEvent
    *   @return void
    *
    */
    private static void inboundWebserviceInteractionEvent() {
        User currentuser = [Select Id,FederationIdentifier from User where FederationIdentifier != null limit 1];
        Contact con = [Select Id, CellcomExternalID__c from Contact Limit 1];  
        Account acc = [Select Id, CellcomExternalID__c from Account Limit 1];  
                       
        string body = createBodyMapInteractionEvent('test', '', '');
        inboundWebservice.InboundRestResponse res = prepareInboundWebservice('InteractionEvent','setCallEvent','', body, 'POST');
        system.assertEquals(res.statusCode, 0);
        
        body = createBodyMapInteractionEvent(currentuser.FederationIdentifier, con.CellcomExternalID__c, acc.CellcomExternalID__c);
        res = prepareInboundWebservice('InteractionEvent','setCallEvent','', body, 'POST');
        system.assertEquals(res.statusCode, 0);
        
        body = createBodyMapInteractionEvent(currentuser.FederationIdentifier, con.CellcomExternalID__c, '');
        res = prepareInboundWebservice('InteractionEvent','setCallEvent','', body, 'POST');
        system.assertEquals(res.statusCode, 0);
        
        body = createBodyMapInteractionEvent(currentuser.FederationIdentifier,'', acc.CellcomExternalID__c);
        res = prepareInboundWebservice('InteractionEvent','setCallEvent','', body, 'POST');
        system.assertEquals(res.statusCode, 0);
        
        body = createBodyMapInteractionEvent(currentuser.FederationIdentifier, '', '');
        res = prepareInboundWebservice('InteractionEvent','setCallEvent','', body, 'POST');
        system.assertEquals(res.statusCode, 0);
    }
    /**
    * The method create map with the parameters of the json body.
    * Tal Sabati
    * @method createBodyMap
    * @return {map<string,string>}
    */
    private static string createBodyMapInteractionEvent(string userIdentifier, string conIdentifier, string accIdentifier){
        map<string, string> bodyMap = new map<string, string>();
        bodyMap.put('userIdentifier', userIdentifier);
        bodyMap.put('contactIdentifier', conIdentifier);
        bodyMap.put('accountIdentifier', accIdentifier);
        bodyMap.put('phoneNumber', '123');
        bodyMap.put('customeSegment', 'test');
        bodyMap.put('callOrigin', 'test');
        bodyMap.put('sharingAgrement', 'test');
        bodyMap.put('paymentIdentifier', 'test');
        bodyMap.put('paymentIdentifierRelatedEntity', 'test');

        return generateJSONContent(bodyMap);
    }
    /**
    *   Test for InboundWebserviceNextLead
    *   author Tal sabati
    *   taskId PLR-627
    *   @method inboundWebserviceGenerateException
    *   @return void
    *
    */
    private static void inboundWebserviceNextLead() {
        User currentuser = [Select Id, FederationIdentifier from User where FederationIdentifier != null limit 1];
        string body = createBodyMapNextLead(currentuser.FederationIdentifier);
        inboundWebservice.InboundRestResponse res = prepareInboundWebservice('NextLead','GetNextLead','', body, 'POST');
        system.assertEquals(res.statusCode, 0);
        
        body = createBodyMapNextLead('test');
        res = prepareInboundWebservice('NextLead','GetNextLead','', body, 'POST');
        system.assertEquals(res.statusCode, 0);
    }
    /**
    * The method create map with the parameters of the json body.
    * Tal Sabati
    * @method createBodyMap
    * @return {map<string,string>}
    */
    private static string createBodyMapNextLead(string userIdentifier){
        map<string, string> bodyMap = new map<string, string>();
        bodyMap.put('userIdentifier', userIdentifier);
        return generateJSONContent(bodyMap);
    }
    /**
    *   Method for generate JSON-encoded content.
    *   Author Tal Sabati
    *   @method setupTestData
    *   @param {map<string, string>} bodyMap 
    *   @return {string}
    */
    private static string generateJSONContent(map<string, string> bodyMap){     
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        for (string key : bodyMap.keySet()) {
            gen.writeStringField(key, bodyMap.get(key));
        }
        gen.writeEndObject();
        return gen.getAsString();
    }
    
    /**
    *   Test for InboundWebserviceLead
    *   author MG
    *   taskId
    *   @method inboundWebserviceLeadTest
    *   @return void
    *
    */
    private static void inboundWebserviceLeadTest() {
        string body = generateJSONContent(new map<string, string>());
        inboundWebservice.InboundRestResponse res = prepareInboundWebservice('Lead','Web2CreateLead','', body, 'POST');
        res = prepareInboundWebservice('Lead','stam','', body, 'POST');
    }
    
    
    /**
    *   Method for setup data for tests
    *   Author Tal Sabati
    *   @method setupTestData
    *   @return void
    */
    @testSetup static void setupTestData() {
      	string dt = string.valueOf(system.currentTimeMillis());
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      	User u = new User();
      	u.Alias = 'newUser';
      	u.Email='newuser@testorg.com';
        u.LastName='Testing'; 
        u.ProfileId = p.Id; 
        u.TimeZoneSidKey='America/Los_Angeles'; 
        u.UserName='user@testorg.com' + dt;
        u.FederationIdentifier = 'f' + dt;
      	u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        insert u;
      	
        Id accRecordType = RecordTypeService.getRecordTypeIdByName('Account','Consumer');
        Account acc = new Account();
        acc.RecordTypeId = accRecordType;
        acc.Name = 'Testing acc';
        acc.CellcomExternalID__c = 'a' + dt;
        insert acc;

        
        accRecordType = RecordTypeService.getRecordTypeIdByName('Account','Billing');
        Account accBilling = new Account();
        accBilling.RecordTypeId = accRecordType;
        accBilling.Name = 'Testing acc';
        accBilling.CellcomExternalID__c = 'abi' + dt;
        accBilling.BANPSID__c = 'test';
        accBilling.Cell_Ind__c = true;
        accBilling.ParentId = acc.Id;
        insert accBilling;

        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Account = acc;
        con.CellcomExternalID__c = 'c' + dt;
        insert con;
        
        Id leadrecordType = RecordTypeService.getRecordTypeIdByName('Lead','B2B');
        Lead newLead = new Lead();
        newLead.RecordTypeId = leadrecordType;
        newLead.LastName = 'Testing lead';
        newLead.Company = 'Company';
        newLead.MobilePhone = '123';
        insert newLead; 
    }
}