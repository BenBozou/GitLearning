@isTest
private class PicklistPopulationTest {
    
    @testSetup static void setupTestData(){
    	
    	Product2 product = TestFactory.testCreateProdact2();
    	
    	system.debug(LoggingLevel.ERROR, 'product >>>> ' + product);

		
    }
    
      static testMethod void PicklistPopulationTest(){

		PicklistPopulation omniPicklistPopulation = new PicklistPopulation();
		
		Test.startTest();
		// Prepare unput data
		Map<String,Object> errorInMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();
		Map<String,Object> inputMap = new Map<String,Object>();
	    Map<String,Object> inputMapStp = new Map<String,Object>();
		inputMap.put('stpLeaddata', inputMapStp);
		inputMapStp.put('lobFormula', 'Consumer');
		Boolean result = omniPicklistPopulation.invokeMethod('PopulatePicklist', inputMap, outMap, optionMap);
		 
		Test.stopTest();
		
		// check for success
		system.assertEquals(true,!outMap.isempty());
    }
}