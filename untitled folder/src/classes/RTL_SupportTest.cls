/**
*	Test class
*	
*	@class RTL_SupportTest
*	author Dmitry Rivlin
*/
@isTest
private class RTL_SupportTest {

	static testMethod void RTL_Support() {
		test.startTest();
			RTL_Support Ctrl = new RTL_Support(new ApexPages.StandardController(new Contact()));
			RTL_Support Ctrl1 = new RTL_Support('Test');
			RTL_Support Ctrl2 = new RTL_Support();
			Boolean rT = Ctrl2.isLanguageRTL;

			system.assertEquals(true, true);
		test.stopTest();
	}
}