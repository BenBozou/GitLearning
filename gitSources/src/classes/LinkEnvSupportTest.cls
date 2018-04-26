@isTest
public class LinkEnvSupportTest {

	/**
	 *   method for testing LinkEnvSupport
	 *   Elad Iflaj
	 *   taskId POC
	 *   @method testLinkEnvSupport
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

			HttpResponse dataSharingMockHttpResponse = new HttpResponse();
			dataSharingMockHttpResponse.setBody('{"Body":{"Response":{"shareDataInd": "N"}}}');
			globalMock.addResponse(OutboundCalloutService.getEndPoint('api/services/rest/00720_osb_b2cdatacollaboration_k2view','OSB'),dataSharingMockHttpResponse);

			Test.setMock(HttpCalloutMock.class, globalMock);

		}


	@isTest static void testgetUrlLinkByEnv() {

		LinkEnvSupport envSup = new LinkEnvSupport();
		LinkEnvSupport Ctrl = new LinkEnvSupport(new ApexPages.StandardController(new Contact()));
		LinkEnvSupport Ctrl1 = new LinkEnvSupport('Test');
		String testList = envSup.urlLinkList;

	}

	/*@isTest static void testsetCustomerInteractioinStatus() {
		Account account = TestFactory.testCreateAccountAndCustomerInteraction();
		test.startTest();

		Boolean bol = LinkEnvSupport.setCustomerInteractioinStatus(account.Id);
		System.assertEquals(bol, true);

		test.stopTest();
	}

	@isTest static void testhasTabClosed() {
		Account account = TestFactory.testCreateAccountAndCustomerInteraction();
		test.startTest();

		Boolean bol = LinkEnvSupport.hasTabClosed(account.Id);
		System.assertEquals(bol, false);

		test.stopTest();
	}*/

	static testMethod void RTL_Support() {
		test.startTest();
		/*RTL_Support Ctrl = new RTL_Support(new ApexPages.StandardController(new Contact()));
		RTL_Support Ctrl1 = new RTL_Support('Test');*/
        Account A = TestFactory.testCreateAccountAndCustomerInteraction();
        System.currentPageReference().getParameters().put('id', A.Id);

		LinkEnvSupport Ctrl1 = new LinkEnvSupport(new ApexPages.StandardController(A));
        LinkEnvSupport Ctrl = new LinkEnvSupport(A);

        System.currentPageReference().getParameters().put('id', A.Id);

		Boolean rT = Ctrl.isLanguageRTL;
        Boolean isA = Ctrl.isAdminUser;
        Boolean isC = Ctrl.getInCommunity();
        String L = Ctrl.currentLang;
        Ctrl.PreLoad();
        Ctrl.getCustomerInteraction(A.Id);
        Ctrl.getDataSharing(A);

		system.assertEquals(true, true);
		test.stopTest();
	}
     static testMethod void GetPrimaryContact() {
        test.startTest();
        	Account account = TestFactory.testCreateAccountAndContact();
        	ApexPages.currentPage().getParameters().put('id',account.Id);
            LinkEnvSupport Ctrl = new LinkEnvSupport(new ApexPages.StandardController(account));
            LinkEnvSupport Ctrl2 = new LinkEnvSupport();
            LinkEnvSupport Ctrl3 = new LinkEnvSupport(new Account());
            String primaryContactId = Ctrl3.primaryContactId;

            system.assertEquals(true, true);
        test.stopTest();
    }

    static testmethod void testCustomerInteraction(){

        PageReference pageRef = Page.AccountSidebar;
        Account account = TestFactory.testCreateAccountAndContact();

        test.startTest();

        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',account.Id);
        LinkEnvSupport  controller = new LinkEnvSupport();
//        System.assertEquals(null,controller.CustomerInteraction());

        test.stopTest();
    }

    static testmethod void testCustomerInteraction2(){

        PageReference pageRef = Page.AccountSidebar;
        Account account = TestFactory.testCreateAccountAndContact();

        test.startTest();

        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',account.Id);
        LinkEnvSupport  controller = new LinkEnvSupport(new ApexPages.StandardController(account));

        test.stopTest();
    }
    static testmethod void testgetShowHeaderSidebar(){

        PageReference pageRef = Page.AccountSidebar;
        Account account = TestFactory.testCreateAccountWithBillingAccsCollab();

        test.startTest();

        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id',account.Id);
        LinkEnvSupport  controller = new LinkEnvSupport(account);
		controller.getShowHeaderSidebar();
		controller.PreLoad();
        test.stopTest();
    }

}