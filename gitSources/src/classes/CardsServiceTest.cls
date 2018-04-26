/**
 *  AccountConsoleSidebar - test class
 *
 *  @class AccountSidebarCardsServiceTest
 *  author Dmitry Rivlin
 *  @module {Test}
 *  @constructor
 */
@isTest
public class CardsServiceTest {

	static {
		prepareTests();
	}

	private static void prepareTests() {
		EnvironmentSettings__c E = TestFactory.testCreateEnvSettForCurrentEnv();
		mockHttpOutboundResponse globalMock =  new mockHttpOutboundResponse();
		HttpResponse mockHttpResponse = new HttpResponse();
		mockHttpResponse.setBody('{"status":"success"}');
		String endPoint1 = OutboundCalloutService.getEndPoint('api/services/rest/00723_osb_b2cdisplaycustomerequipment_k2view','OSB');
		globalMock.addResponse(endPoint1 ,mockHttpResponse);

		Test.setMock(HttpCalloutMock.class, globalMock);
	}

	@isTest static void testB2CCustomerEquipment2Level() {

		Map < String, Object > inMap = new Map < String, Object > ();
		Map < String, Object > outMap = new Map < String, Object > ();
		Map < String, Object > optionMap = new Map < String, Object > ();

		Account acc = TestFactory.testCreateAccountAndContact();

		inMap.put('accountId', acc.Id);

		Account A = TestFactory.testCreateAccountWithBillingAccs();
		Contact C = [SELECT Id, Name FROM Contact WHERE AccountId = :A.Id];

		Test.startTest();

			CardsService ctrl = new CardsService();

			system.debug('inMap before calling method' + inMap);

			Boolean result = ctrl.invokeMethod('B2CCustomerEquipment2Level', inMap, outMap, optionMap);
			system.assertEquals(false, result);

			inMap.put('contactId', c.Id);
			result = ctrl.invokeMethod('B2CCustomerEquipment2Level', inMap, outMap, optionMap);
			system.assertEquals(true, result);

		Test.stopTest();
	}

}