@isTest
public class LeadOmniScriptSupportTest {
    	
    @testSetup static void setupTestData() {
        Product2 product = TestFactory.testCreateProdact2();
        system.debug(LoggingLevel.ERROR, 'product >>>> ' + product);
        
        Map<String,Object> settings = new Map<String,Object>{
			'createlookupobject' => false,
			'countObjects' => 1
		};
		
        
        EnvironmentSettings__c envSettings = 
			(EnvironmentSettings__c ) new testFramework('EnvironmentSettings__c', 
														new map<String, Object> {'CurrentEnvironment__c' => 'Test'},
                                                        settings).createObject();
		 
		insert envSettings;
    }
    
    static testMethod void PicklistPopulationTest() {
        // Prepare unput data
        Map < String, Object > errorInMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > inputMapStp = new Map < String, Object > ();
        Map < String, Object > inputMapBlk = new Map < String, Object > ();
        
        LeadOmniScriptSupport omniPicklistPopulation = new LeadOmniScriptSupport();
        
        Test.startTest();
        
        inputMap.put('stpLeaddata', inputMapStp);
        inputMapStp.put('blkPrepareData', inputMapBlk);
        inputMapBlk.put('lobFormula', 'Consumer');
        Boolean result = omniPicklistPopulation.invokeMethod('PopulatePicklist', inputMap, outMap, optionMap);
        
        Test.stopTest();
        
        // check for success
        system.assertEquals(true, !outMap.isempty());
    }
    
    static testMethod void CheckSSNTest() {
        LeadOmniScriptSupport omnicheckSSN = new LeadOmniScriptSupport();
        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        insert lead;
        
        // Prepare unput data
        Map < String, Object > errorInMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > inputMapStp = new Map < String, Object > ();
        Map < String, Object > inputMapblkSSN = new Map < String, Object > ();
        Map < String, Object > leadDataMap = new Map < String, Object > ();
        Map < String, Object > leadsMap = new Map < String, Object > ();
        
        leadsMap.put('ExternalId','45465456');
        leadDataMap.put('Leads__x',leadsMap);
        inputMap.put('StpSSN', inputMapStp);
        inputMap.put('LeadData',leadDataMap);
        inputMap.put('ContextId',lead.Id);
        inputMap.put('SetSSNType','I');
        inputMapStp.put('blkSSN', inputMapblkSSN);
        
        Test.startTest();
        
        // check for success
        inputMapblkSSN.put('SSN', '025666108');
        Boolean result = omnicheckSSN.invokeMethod('checkSSN', inputMap, outMap, optionMap);
        System.debug(LoggingLevel.ERROR,'ValidSSN: ' + outMap.get('ValidSSN'));
        system.assertEquals(true, Boolean.valueOf(outMap.get('ValidSSN')));
        
        // check for false
        inputMapblkSSN.put('SSN', '0256');
        Boolean resultnotValid = omnicheckSSN.invokeMethod('checkSSN', inputMap, outMap, optionMap);
        system.assertEquals(false, Boolean.valueOf(outMap.get('ValidSSN')));
        // check for false
        //inputMapblkSSN.put('SSN', '025666109');
        //Boolean resultnotValid1 = omnicheckSSN.invokeMethod('checkSSN', inputMap, outMap, optionMap);
        //system.assertEquals(false, Boolean.valueOf(outMap.get('ValidSSN')));
		
        Test.stopTest();
    }
    
    /**
	* Test method to validate company number
	* Nikolay Iliaev
	* Taskid PLR-1394
	* @class CheckCNTest
	* @module Leads
	*/
    static testMethod void CheckCNTest() {
        LeadOmniScriptSupport omnicheckCN = new LeadOmniScriptSupport();
        
        Account accItem = TestFactory.testCreateAccount();
        accItem.CellcomExternalId__c = '111';
        update accItem;
        Lead leadItem = TestFactory.testCreateLeadWithCellExtID();
        leadItem.AccountId__c = accItem.Id;
        Database.insert(leadItem);
        
        
        // Prepare unput data
        //Map < String, Object > errorInMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > inputMapStp = new Map < String, Object > ();
        Map < String, Object > inputMapblkCN = new Map < String, Object > ();
        Map < String, Object > leadDataMap = new Map < String, Object > ();
        //Map < String, Object > leadsMap = new Map < String, Object > ();
        
        //leadsMap.put('ExternalId','45465456');
        //leadDataMap.put('Leads__x',leadsMap);
        inputMap.put('ContextId',leadItem.Id);
        inputMap.put('LeadData',leadDataMap);
        inputMap.put('StpCompanyNumber', inputMapStp);
        inputMapStp.put('blkCompanyNumber', inputMapblkCN);
        // check for success
        inputMapblkCN.put('CN', '025666108');
        
        Test.startTest();
        
        Boolean result = omnicheckCN.invokeMethod('checkCompanyNumber', inputMap, outMap, optionMap);
        System.debug(LoggingLevel.ERROR,'ValidCN: ' + outMap.get('ValidCN'));
        system.assertEquals(false, Boolean.valueOf(outMap.get('ValidCN')));
        
        Test.stopTest();
    }
    
    /**
	* Test method to send sms
	* Nikolay Iliaev
	* Taskid PLR-1313
	* @class sendSMSTest
	* @module Leads
	*/
    testMethod static void sendSMSTest() {
       	Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        
        Map < String, Object > dataMap = new Map < String, Object > {
            'Phone' => '05423383565',
            'SmsTemplate' => 'SMS'
    	};
           
        mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        HttpResponse mockHttpResponse = new HttpResponse();
		mockHttpResponse.setBody('{"Header":{"From":"OSB","To":"SF","ProcessID":"f52378ef-842d-4ae7-b051-3d4590d14d4f","MessageID":"e4534320-c1cc-49d7-a894-cc669a103f96","ActionID":null,"ReturnCode":"00","ReturnCodeMessage":"\"הצלחה\"","UserName":"NIKOLAEI","OptionalReturnAddress":null,"InterchangeID":"5ed43f45-a3bb-ee63-ce10-5ddbcb1ce39d","ActivityID":"afef44a6- 5070-808e-b029-b0b759b6043f","InvokerActivityID":null,"UseInvokerActivityIDInd":null,"FunctionCode":"00499","NextTryIndex":null},"Body":{"Response":{"sms":{"message":[{"text":null,"messageFrom":"Cellcom","messageTo":"0522222222"}]},"email":null}}}');
		mockHttpResponse.setStatusCode(200);
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/osb_sendsms_cellcomcourier','OSB');
        
        System.debug(LoggingLevel.ERROR,'end Point: ' + endPoint);
        
        mock.addResponse(endPoint ,mockHttpResponse);  
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        LeadOmniScriptSupport omniconvertLead = new LeadOmniScriptSupport();
        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        insert lead;
        inputMap.put('LeadData', dataMap);
        inputMap.put('SmsTemplate', 'SMS');
        
        Test.startTest();
        
        system.debug(LoggingLevel.ERROR, 'Lead >>>> ' + lead);
        
        Boolean result = omniconvertLead.invokeMethod('sendSMS', inputMap, outMap, optionMap);
        Test.stopTest();
        
        System.assertEquals(true, result);
        
    }
    
    /**
	* Test method to send sms
	* Nikolay Iliaev
	* Taskid PLR-1451
	* @class BlockCustomer
	* @module Leads
	*/
    testMethod static void BlockCustomer() {
       	Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        
        Map < String, Object > dataMap = new Map < String, Object > {
            'Phone' => '0522222222',
            'SmsTemplate' => 'SMS'
    	};
            
        mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        HttpResponse mockHttpResponse = new HttpResponse();
		mockHttpResponse.setBody('{"Header":{"From":"OSB","To":"SF","ProcessID":"853598f7-30a1-42d7-9ed6-189b5b01d405","MessageID":"8b015812-9da4-4329-999b-995b0bad2109","ActionID":null,"ReturnCode":"00","ReturnCodeMessage":"הצלחה","UserName":"NIKOLAEI","OptionalReturnAddress":null,"InterchangeID":"c80f1498-0277-a704-f8f3-9684e9d50816","ActivityID":"b2ad3ce3- 897f-ec0f-040b-eaed52ebe47b","InvokerActivityID":null,"UseInvokerActivityIDInd":null,"FunctionCode":"00729","NextTryIndex":null},"Body":{"Request":null,"Response":{"action":"SMS"}}}');
		mockHttpResponse.setStatusCode(200);
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00729_osb_botheredcustomerblock_bp','OSB');
        
        System.debug(LoggingLevel.ERROR,'end Point: ' + endPoint);
        
        mock.addResponse(endPoint ,mockHttpResponse);  
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        LeadOmniScriptSupport BlockCustomerLead = new LeadOmniScriptSupport();
        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        insert lead;
        inputMap.put('LeadData', dataMap);
        inputMap.put('SmsTemplate', 'SMS');
        
        Test.startTest();
            
            system.debug(LoggingLevel.ERROR, 'Lead >>>> ' + lead);
            Boolean result = BlockCustomerLead.invokeMethod('BlocktroubledCustomer', inputMap, outMap, optionMap);
        Test.stopTest();
        System.assertEquals(true, result);
    }
    
    /**
	* Test method to get lead story
	* Nikolay Iliaev
	* Taskid PLR-1451
	* @class getLeadStoryTest
	* @module Leads
	*/
    testMethod static void getLeadStoryTest() {
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        
        LeadOmniScriptSupport omniconvertLead = new LeadOmniScriptSupport();
        
        Test.startTest();
        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        insert lead;
        
        Task taskItem = TestFactory.createTask();
        taskItem.WhoId = lead.Id;
        insert taskItem;
        
        inputMap.put('leadId', lead.Id);
        system.debug(LoggingLevel.ERROR, 'Lead >>>> ' + lead);
        Boolean result = omniconvertLead.invokeMethod('getLeadStory', inputMap, outMap, optionMap);
        
        Test.stopTest();
        
        System.assertEquals(true, result);
    }
    
    /**
	* Test method populate pick list call options
	* Nikolay Iliaev
	* Taskid PLR-1451
	* @class PopulatePicklistCallOptionTest
	* @module Leads
	*/
    static testMethod void PopulatePicklistCallOptionTest() {
        // Prepare unput data
        Map < String, Object > errorInMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > inputMapStp = new Map < String, Object > ();
        Map < String, Object > inputMapBlk = new Map < String, Object > ();
        Map < String, Object > LeadDataMap = new Map < String, Object >();
        Map < String, Object > userDataMap = new Map < String, Object >();
        
        
        LeadOmniScriptSupport omniPicklistPopulation = new LeadOmniScriptSupport();
        
        Test.startTest();
        
        inputMap.put('stpLeaddata', inputMapStp);
        inputMapStp.put('blkPrepareData', inputMapBlk);
        inputMapBlk.put('lobFormula', 'Consumer');
        LeadDataMap.put('Outbond__c',true);
        userDataMap.put('IsSoftphone__c',true);
        inputMap.put('LeadData',LeadDataMap);
        inputMap.put('userData',userDataMap);
        Boolean result = omniPicklistPopulation.invokeMethod('PopulatePicklistCallOption', inputMap, outMap, optionMap);
        
        Test.stopTest();
        
        // check for success
        system.assertEquals(true, !outMap.isempty());
    }
    
     /**
	* Test method get permises Data 
	* Nikolay Iliaev
	* Taskid PLR-1451
	* @class getPremisesDataTest
	* @module Leads
	*/
	testMethod static void getPremisesDataTest() {
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        Map < String, Object > creatLeadMap = new Map < String, Object > ();
        
        vlocity_cmt__Premises__c premisesItem = new vlocity_cmt__Premises__c();
        premisesItem.vlocity_cmt__City__c = 'Eliran';
        premisesItem.CBStreet__c = 'shalom';
        insert premisesItem;
        
        LeadOmniScriptSupport omniconvertLead = new LeadOmniScriptSupport();
        
        creatLeadMap.put('premissFormulaStreet','shalom');
        creatLeadMap.put('premissFormulaCity','Eliran');
        
        inputMap.put('CreateLead', creatLeadMap);
        
        Test.startTest();
        
        
        Boolean result = omniconvertLead.invokeMethod('getPremisesData', inputMap, outMap, optionMap);
        
        Test.stopTest();
        system.assertEquals(true, !outMap.isempty());
    }
    
    testMethod static void getLeadDataTest() {
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        LeadOmniScriptSupport omniconvertLead = new LeadOmniScriptSupport();
        Test.startTest();
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        insert lead;
        inputMap.put('leadId', lead.Id);
        system.debug(LoggingLevel.ERROR, 'Lead >>>> ' + lead);
        Boolean result = omniconvertLead.invokeMethod('getLeadData', inputMap, outMap, optionMap);
        Test.stopTest();
        system.assertEquals(true, !outMap.isempty());
    }
    
    testMethod static void leadConvertTest() {
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        LeadOmniScriptSupport omniconvertLead = new LeadOmniScriptSupport();
        Test.startTest();
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        insert lead;
        inputMap.put('leadIDParam', lead.Id);
        system.debug(LoggingLevel.ERROR, 'Lead >>>> ' + lead);
        Boolean result = omniconvertLead.invokeMethod('convertopportunity', inputMap, outMap, optionMap);
        Test.stopTest();
        system.assertEquals(true, !outMap.isempty());
    }
    
    static testMethod void getLicTest() {
        LeadOmniScriptSupport omnigetLic = new LeadOmniScriptSupport();
        Test.startTest();
        // Prepare unput data
        Map < String, Object > errorInMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > inputMapStp = new Map < String, Object > ();
        Map < String, Object > productdata = new Map < String, Object > ();
        inputMap.put('LeadData', inputMapStp);
        inputMapStp.put('productData', productdata);
        productdata.put('LinkToLegacy__c', 'LIC_AmdocsOpenCloseIssues');
        system.debug('inputMap : ' + inputMap);
        Boolean result = omnigetLic.invokeMethod('getLIcData', inputMap, outMap, optionMap);
        Test.stopTest();
        // check for success
        system.assertEquals(true, !outMap.isempty());
    }

    testMethod static void activategetCMProvTest() {
        EnvironmentSettings__c envSettings = TestFactory.testCreateEnvSettForCurrentEnv();
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > outMap = new Map < String, Object > ();
        Map < String, Object > optionMap = new Map < String, Object > ();
        Map < String, Object > LeadDataMap = new Map < String, Object >();
        
        LeadOmniScriptSupport omniconvertLead = new LeadOmniScriptSupport();
        
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        insert lead;
        
        //inputMap.put('ContextId', lead.Id);
        LeadDataMap.put('LeadData', lead);
        inputMap.put('LeadData',LeadDataMap);
        inputMap.put('provCode', '771252624205305632');
        inputMap.put('cmprov', '103094572_12526_000657458');
        
        
        Test.startTest();
        
        mockHttpOutboundResponse mock = new mockHttpOutboundResponse();
        HttpResponse mockHttpResponse = new HttpResponse();
        //mockHttpResponse.setBody(JSON.serialize(response));
        mockHttpResponse.setBody('{"Body":{"Response":{"RequestResponse":{"@row_count":"string","provision_detail":{"@row_index":"string","@success_count":"string","@fail_count":"string","prov_code":"string","subscriber_number":"string","comm_code":"223232323","reply_code":"0","channel_id":"string","dealer_id":"string","return_code":"00","return_code_message":"string","update_recom_sync":"string","installed_soc":"string","installed_atomic_socs":"string","auto_soc_removal_ind":"string","parameters":{"param1":"string","param2":"string","param3":"string"},"email":"string","email_block_ind":"string","action_memo_description":"string","interact_treatment_code":"string"}}}}}');
        String endPoint = OutboundCalloutService.getEndPoint('api/services/rest/00705_osb_cmprovisioning', 'OSB');
        mock.addResponse(endPoint, mockHttpResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        
        system.debug(LoggingLevel.ERROR, 'Lead >>>> ' + lead);
        Boolean result = omniconvertLead.invokeMethod('activateCMProv', inputMap, outMap, optionMap);
        
        Test.stopTest();
        
        system.assertEquals(true, !outMap.isempty());
    }
    
    /**
	* Test method checks duplicate web 
	* Nikolay Iliaev
	* Taskid PLR-1451
	* @class checkDuplicateWebLead
	* @module Leads
	*/
    testMethod static void checkDuplicateWebLead() {
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        
        lead.LeadSource = 'LSO09';
        lead.Phone = '05465656556';
        
        Test.startTest();
    		insert lead;
        Test.stopTest();
    }
    
    testMethod static void createExternalLeadFuture() {
        
        //Lead[] leadList = [SELECT Id FROM Lead LIMIT 1];
        Lead lead = TestFactory.testCreateLeadWithCellExtID();
        insert lead;
        
        Test.startTest();
        	CreateLeadService.createExternalLeadFuture('3255645454','526554488','I',lead.Id);
        Test.stopTest();
    }
}