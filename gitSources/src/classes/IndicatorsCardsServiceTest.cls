/**
*   Test class for testing IndicatorsCardsService
*   @class IndicatorsCardsServiceTest
*   Gili Yehuda
*   taskid PLR-137 | PLR-132 | PLR-75 | PLR-310 | PLR-838
*   @module 360
*/
@isTest
public class IndicatorsCardsServiceTest {
	
	/**
	*   method for testing getB2CFirstIndicators
	*   Tal sabati
	*   taskId PLR-838
	*   @method testGetLegalDebtDetails
	*   @private
	*   @return void
	*/
	
	@isTest private static void testGetB2CFirstIndicators() {
		Map<String,Object> inMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();
  
        Account acc = TestFactory.testCreateAccountWithBillingAccs();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];
                
        inMap.put('accountId', acc.Id);
        inMap.put('contactId', con.Id);
		Test.startTest();
			IndicatorsCardsService ctrl = new IndicatorsCardsService();
        	system.debug('inMap before calling method' + inMap);
			Boolean result = ctrl.invokeMethod('getB2CFirstIndicators', inMap, outMap, optionMap);
			system.assertEquals(true, result);                              
		Test.stopTest();
	}
	
	/**
	*   method for testing getLegalDebtDetails
	*   Gili Yehuda
	*   taskId PLR-137
	*   @method testGetLegalDebtDetails
	*   @private
	*   @return void
	*/

		static {
			prepareTests();
		}
		
		private static void prepareTests() {
			EnvironmentSettings__c E = TestFactory.testCreateEnvSettForCurrentEnv();  
			
			mockHttpOutboundResponse globalMock =  new mockHttpOutboundResponse();
			
			HttpResponse mockHttpResponse = new HttpResponse();
			mockHttpResponse.setBody('{"status":"success"}');
                        			
			//String endPoint = 'https://sfiapi-int2.cellcom.co.il/api/services/rest/';
			globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/osb_retrievecustomerfinancedata_bp_00668','OSB'),mockHttpResponse);                			
            globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/osb_getdeliveriesinfo_sap_00790','OSB'),mockHttpResponse);            
            globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/osb_getnotesinfo_sap_00791','OSB'),mockHttpResponse);			            
            globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/osb_retrievecustomerdeposit_sap_00653','OSB'),mockHttpResponse);			            
            globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00796_osb_gettechnicianvisitsinfo_bp','OSB'),mockHttpResponse);			
            
            HttpResponse openCloseMockHttpResponse = new HttpResponse();            			
            openCloseMockHttpResponse.setBody('{"Header":{"From":"OSB","To":"SF","ProcessID":"176560d1-7a22-44bb-9ed8-c21d5cb371ef","MessageID":"4157f371-1bee-4328-bf46-b127ef6b2084","ActionID":null,"ReturnCode":"00","ReturnCodeMessage":"הצלחה","UserName":"SKLEIN","OptionalReturnAddress":null,"InterchangeID":"65e34878-421c-45d0-81a4-3b5e5a3aaf1b","ActivityID":"2d2aebcd-ae24-4d2d-bb01-a3ef9af6208a","InvokerActivityID":null,"UseInvokerActivityIDInd":null,"FunctionCode":"00648","NextTryIndex":null},"Body":{"Response":{"Open":{"CaseDetails":[{"sourceSystem":"Cellcom","dueDate":"26-AUG-02","ban":"1396213","taskNumber":"3961398","assigned_to":"NAVASH","subscriberNumber":null,"creationDate":"20161226182301","descriprion":"סגירל נכשל","fuCode":"0056"}]},"Close":{"CaseDetails":[{"sourceSystem":"Cellcom"}]}}}}');                
            globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00648_osb_retrievecustomerfuitems_bp','OSB'),openCloseMockHttpResponse);			
                        
            HttpResponse B2CFirstIndicatorsMockHttpResponse = new HttpResponse();            			
            B2CFirstIndicatorsMockHttpResponse.setBody('{"Header":{"From":"OSB","To":"SF","ProcessID":"cb37103a-efac-4134-a400-ddebc06096ca","MessageID":"2068548d-c886-4cbe-a403-877081494372","ActionID":null,"ReturnCode":"00","ReturnCodeMessage":"הצלחה","UserName":"BOAZGE","OptionalReturnAddress":null,"InterchangeID":"6436c46b-ac24-4210-a419-0f28fa5c301d","ActivityID":"9569e89b-e68a-4eca-a14d-e21af27b86e5","InvokerActivityID":null,"UseInvokerActivityIDInd":null,"FunctionCode":"00682","NextTryIndex":null},"Body":{"Response":{"indicatorArray":[{"indCase":"false"},{"indNote":"true"},{"indTechVisit":"false"},{"indDelivery":"true"},{"indLegal":"N"},{"getReturnCustomerInd":"false"},{"indLoveCellcom":"false"}]}}}');    
            globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00682_osb_retrievecustomerindicators_bp','OSB'),B2CFirstIndicatorsMockHttpResponse);            

			Test.setMock(HttpCalloutMock.class, globalMock);
		}

		@isTest static void testGetLegalDebtDetails() {
		
		Map<String,Object> inMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();
  
        Account acc = TestFactory.testCreateAccountWithBillingAccs();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];
                
        inMap.put('accountId', acc.Id);
        inMap.put('contactId', con.Id);						 		
		inMap.put('IncludeDebt', 'true');
		inMap.put('IncludeLegalInfo', 'true');
		inMap.put('IncludeCollectionInfo', 'true');       

		Test.startTest();
		
		IndicatorsCardsService callOut =new IndicatorsCardsService();

		// check for success
		Boolean result = callOut.invokeMethod('getLegalDebtDetails', inMap, outMap, optionMap);
		system.assertEquals(true, result);
		
		Test.stopTest();
	}
	
	/**
	*   method for testing getDeliveryDetails
	*   Gili Yehuda
	*   taskId PLR-132
	*   @method testGetDeliveryDetails
	*   @private
	*   @return void    
	*/
		@isTest static void testGetDeliveryDetails() {
				
		Map<String,Object> inMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();		
            
        Account acc = TestFactory.testCreateAccountWithBillingAccs();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];                    
		
		inMap.put('accountId',  acc.Id);
        inMap.put('contactId', con.Id);	

		Test.startTest();
		
		IndicatorsCardsService callOut =new IndicatorsCardsService();

		 // check for success
		Boolean result = callOut.invokeMethod('getDeliveryDetails', inMap, outMap, optionMap);
		system.assertEquals(true, result);
		
		Test.stopTest();
	}
	
	/**
	*   method for testing getDeviceInRepairDetails
	*   Gili Yehuda
	*   taskId PLR-75
	*   @method testGetDeviceInRepairDetails
	*   @private
	*   @return void    
	*/
		@isTest static void testGetDeviceInRepairDetails() {
				
		Map<String,Object> inMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();		
            
        Account acc = TestFactory.testCreateAccountWithBillingAccs();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];   
		
		inMap.put('accountId',  acc.Id);
        inMap.put('contactId', con.Id);	

		Test.startTest();
		IndicatorsCardsService callOut =new IndicatorsCardsService();

		 // check for success
		Boolean result = callOut.invokeMethod('getDeviceInRepairDetails', inMap, outMap, optionMap);
		system.assertEquals(true, result);
		Test.stopTest();
	}
	
	/**
	*   method for testing getDepositDetails
	*   Gili Yehuda
	*   taskId PLR-310
	*   @method testGetDepositDetails
	*   @private
	*   @return void    
	*/
		@isTest static void testGetDepositDetails() {
				
		Map<String,Object> inMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();
		
		Account acc = new Account(); 
		acc.Name = 'Test acc';              
		insert acc;
		
		inMap.put('accountId',  acc.Id);

		IndicatorsCardsService callOut =new IndicatorsCardsService();

		 // check for success
		Boolean result = callOut.invokeMethod('getDepositDetails', inMap, outMap, optionMap);
		system.assertEquals(true, result);
	}
	
	/**
	*   method for testing getCellcomBezeqTechVisitsDetails
	*   Gili Yehuda
	*   taskId PLR-79
	*   @method testGetCellcomBezeqTechVisitsDetails
	*   @private
	*   @return void    
	*/
		@isTest static void testGetCellcomBezeqTechVisitsDetails() {
				
		Map<String,Object> inMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();		  
            
        Account acc = TestFactory.testCreateAccountWithBillingAccs();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];   		

		inMap.put('accountId',  acc.Id);
        inMap.put('contactId', con.Id);	
            
		Test.startTest();
		
		IndicatorsCardsService callOut =new IndicatorsCardsService();

		// check for success
		Boolean result = callOut.invokeMethod('getCellcomBezeqTechVisitsDetails', inMap, outMap, optionMap);
		system.assertEquals(true, result);
		
		Test.stopTest();
	}

	/**
	*  method for testing getOpenCloseIssues
	*  Elad Iflah
	*  taskId PLR-643
	*  @method     testGetOpenCloseCases
	*  @private
	*  @return     void       
	*/
		@isTest static void testGetOpenCloseCases() {
				
		Map<String,Object> inMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();        
            
        inMap.put('NumOfDaysOpen', '45');
        inMap.put('NumOfDaysClosed', '60');            		                  
		                          
        Account acc = TestFactory.testCreateAccountWithBillingAccs();
        Contact con = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];   		
            
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Call';
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.WhatId = acc.id;
        t.Description = 'Test task';
        insert t;             

		inMap.put('accountId',  acc.Id);
        inMap.put('contactId', con.Id);	            		            
		
        Test.startTest();
		IndicatorsCardsService callOut =new IndicatorsCardsService();

		// check for success
		Boolean result = callOut.invokeMethod('getOpenCloseIssues', inMap, outMap, optionMap);
		system.assertEquals(true, result);
            
        Test.stopTest();
	}
}