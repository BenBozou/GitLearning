/**
*   Test class for all RecommendationCardService 
*   
*   @class RecommendationCardServiceTest
*   author Liron Cohen
*   @module TestClass
*   @constructor
*/
@isTest
private class RecommendationCardServiceTest {

    static testMethod void recommendationTest() {
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
        //Create Account
        String recordTypeId = RecordTypeService.getRecordTypeIdByName('Account', 'Business'); 
        
        Account acc = (Account ) new testFramework(
                            'Account', 
                            new map<String, Object> {'RecordTypeId' => recordTypeId}, 
                            settings).createObject();
        insert acc;
        
        
        //Create leads
        String leadRecordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'Offer'); 
        
        list<Lead> l_leads = new list<Lead>();
        l_leads.add((Lead ) new testFramework(
                            'Lead', 
                            new map<String, Object> {'AccountId__c' => acc.id,
                                                    'Status' => 'LST01',
                                                    'Subscriber__c' => '0000000000',
                                                    'RecordTypeId' => leadRecordTypeId}, 
                            settings).createObject());
        l_leads.add((Lead ) new testFramework(
                            'Lead', 
                            new map<String, Object> {'AccountId__c' => acc.id,
                                                    'Status' => 'LST01',
                                                    'Subscriber__c' => '0000011111',
                                                    'RecordTypeId' => leadRecordTypeId}, 
                            settings).createObject());
        insert l_leads;
        
        Product2 product = (Product2) new testFramework(
                            'Product2', 
                            new map<String, Object> {'ProductCode' => 'TestProduct'}, 
                            settings).createObject();
        insert product;
        
        list<PricebookEntry> l_pbe = new list<PricebookEntry>();
        l_pbe.add((PricebookEntry) new testFramework(
                            'PricebookEntry', 
                            new map<String, Object> {'Pricebook2Id' => Test.getStandardPricebookId(),
                                                    'Product2Id' => Product.id,
                                                    'UnitPrice' => 10,
                                                    'IsActive' => true}, 
                            settings).createObject());
        insert l_pbe;  
        
        //Create opps
        String oppRecordTypeId = RecordTypeService.getRecordTypeIdByName('Opportunity', 'B2B');
        
        list<Opportunity> l_opps = new list<Opportunity>();
        l_opps.add((Opportunity) new testFramework(
                            'Opportunity', 
                            new map<String, Object> {'accountId' => acc.id,
                                                    'CloseDate' => system.today() + 10,
                                                    'StageName' => 'Opportunity',
                                                    'RecordTypeId' => oppRecordTypeId}, 
                            settings).createObject());
        l_opps.add((Opportunity ) new testFramework(
                            'Opportunity', 
                            new map<String, Object> {'accountId' => acc.id,
                                                    'CloseDate' => system.today() + 10,
                                                    'StageName' => 'Opportunity',
                                                    'RecordTypeId' => oppRecordTypeId}, 
                            settings).createObject());
        insert l_opps;
        
        list<OpportunityLineItem> l_oli = new list<OpportunityLineItem>();
        l_oli.add((OpportunityLineItem) new testFramework(
                            'OpportunityLineItem', 
                            new map<String, Object> {'OpportunityId' => l_opps.get(0).id,
                                                    'OrderNumber__c' => '1',
                                                    'TotalPrice' => 500,
                                                    'PricebookEntryId' => l_pbe.get(0).id}, 
                            settings).createObject());
        insert l_oli;
        
        Task testTask = (Task ) new testFramework(
                            'Task', 
                            new map<String, Object> { 'WhatID' => l_opps[0].id,
        'Subject'=>'Donni',
        'Status'=>'New',
        'Priority'=>'Normal'}, 
                            settings).createObject();
        insert testTask;
        
        //run test
        Test.startTest();
        map<String, object> inputMap = new map<string, object>();

        inputMap.put('accountId', acc.id);
        inputMap.put('recordTypeName', 'B2B');

        RecommendationCardService testRecommendation = new RecommendationCardService();

        Boolean result = testRecommendation.invokeMethod(
                        'getRecommandations', 
                        inputMap, 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(true, result);
        
        //testing withouth parameters to get error
        result = testRecommendation.invokeMethod(
                        'getRecommandations', 
                        new map<String, object>(), 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(false, result);
        
        Boolean result1 = testRecommendation.invokeMethod(
                        'getRecommandationsForLeadsFlyout', 
                        inputMap, 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(true, result1);
        
        //testing withouth parameters to get error
        result1 = testRecommendation.invokeMethod(
                        'getRecommandationsForLeadsFlyout', 
                        new map<String, object>(), 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(false, result1);
        
        Boolean result2 = testRecommendation.invokeMethod(
                        'getRecommandationsForOpportunitiesFlyout', 
                        inputMap, 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(true, result2);
        
        //testing withouth parameters to get error
        result2 = testRecommendation.invokeMethod(
                        'getRecommandationsForOpportunitiesFlyout', 
                        new map<String, object>(), 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(false, result2);
        
        Boolean result3 = testRecommendation.invokeMethod(
                        'getRecommandationsForOrdersFlyout', 
                        inputMap, 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(true, result3);
        
        //testing withouth parameters to get error
        result3 = testRecommendation.invokeMethod(
                        'getRecommandationsForOrdersFlyout', 
                        new map<String, object>(), 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(false, result3);
        
         Boolean result4 = testRecommendation.invokeMethod(
                        'getRecommandationPermission', 
                        inputMap, 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(true, result4); 
        
        
         EnvironmentSettings__c E = TestFactory.testCreateEnvSettForCurrentEnv();  
        mockHttpOutboundResponse globalMock =  new mockHttpOutboundResponse();
        HttpResponse mockHttpResponse = new HttpResponse();
        mockHttpResponse.setHeader('Header','header');
        mockHttpResponse.setBody('{"Body":{"Response":{ "open":{ "tasksAssignedToUser":{ "taskDetails":[{"taskNumber": "87845040",  "subscriberNumber": null,            "status": null,            "sourceSystem": "Cellcom",           "openDate": "20160801203114",            "dueDate": "20160801203114",            "description": "הועבר לטיפול קשרי עו\"ד",            "customerName": "סרגיי סבידלר",            "comments": null,            "billingCycle": "11",            "assignedToUserName": "MALICA",            "assignedToTeamName": "צוות גביה משפטית",            "CustomerNumber": null,            "CreatedByUser": null        },        {            "taskNumber": "87836184",            "subscriberNumber": null,            "status": null,            "sourceSystem": "Cellcom",            "openDate": "20160801144510",            "dueDate": "20160801144510",            "description": "הועבר לטיפול קשרי עו\"ד",            "customerName": "שלמה ממנה",            "comments": null,            "billingCycle": "27",            "assignedToUserName": "MALICA",            "assignedToTeamName": "צוות גביה משפטית",            "CustomerNumber": null,            "CreatedByUser": null  }]}}}}}');                
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00725_osb_personalfolderforcsr_bp','OSB');
        globalMock.addResponse(endPoint ,mockHttpResponse);        
        Test.setMock(HttpCalloutMock.class, globalMock);
        
        Task t =TestFactory.createCustomerFolderTask();
        Boolean result5 = testRecommendation.invokeMethod(
                        'getRelevantOpenTasks', 
                        inputMap, 
                        new map<String, object>(), 
                        new map<String, object>());
        
        system.assertEquals(true, result5);            
    }
}