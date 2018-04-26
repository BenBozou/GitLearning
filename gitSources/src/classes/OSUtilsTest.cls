@isTest
private class OSUtilsTest {

    @testSetup 
    static void setupTestData(){
    	Account acc = TestFactory.testCreateAccount();
    }
    
    /**
	*   method for testing OSUtils.findObjectType
	*   Mohammad G.
	*   taskId
	*   @method findObjectTypeTest
	*   @private
	*   @return void
	*/
    static testMethod void findObjectTypeTest() {
        Account acc = [select id, RecordType.DeveloperName from Account limit 1];
        Test.StartTest();
        OSUtils osUtil = new OSUtils();
        osUtil.invokeMethod('contextObjectType', new Map<String,Object>(), new Map<String,Object>(), new Map<String,Object>());
        osUtil.invokeMethod('contextObjectType', new Map<String,Object>{'ContextId'=>acc.Id}, new Map<String,Object>(), new Map<String,Object>());
        Test.StopTest();
    }
    
    /**
	*   method for testing OSUtils.getAccountsByRecordType
	*   Mohammad G.
	*   taskId
	*   @method getAccountsByRecordTypeTest
	*   @private
	*   @return void
	*/
    static testMethod void getAccountsByRecordTypeTest() {
        Account acc = [select id, RecordType.DeveloperName from Account limit 1];
        Test.StartTest();
        OSUtils osUtil = new OSUtils();
        osUtil.invokeMethod('getAccountsByRecordType', new Map<String,Object>(), new Map<String,Object>(), new Map<String,Object>());
        osUtil.invokeMethod('getAccountsByRecordType', new Map<String,Object>{'recordType'=>acc.RecordType.DeveloperName}, new Map<String,Object>(), new Map<String,Object>());
        Test.StopTest();
    }
}