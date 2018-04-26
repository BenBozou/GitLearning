/**
*	Test class for testing OmniCreateLeadService
*	@class OmniCreateLeadServiceTest
*	Eric Fishman
*   taskid PLR-805
*	@module Lead
*/
@isTest
private class OmniCreateLeadServiceTest {
	
	/**
	*	method for testing OmniCreateLeadService
	*	author Eric Fishman
	*	taskId PLR-805	
	*	@method	createLeadServiceTest
	*	@return	void	
	*/
	static testMethod void createLeadServiceTest() {
		
		
		OmniCreateLeadService omniCreatLead = new OmniCreateLeadService();

		// Prepare unput data
		Map<String,Object> errorInMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();
		Map<String,Object> inputMap = new Map<String,Object>();
				
		Map<String,Object> detailsInputs = new Map<String,Object>();
        Map<String,Object> BlkTxt2 = new Map<String,Object>();
        
        BlkTxt2.put('Comment','first####');
        detailsInputs.put('BlkTxt2', BlkTxt2);
		inputMap.put('FirstName_U', 'first1');
		inputMap.put('LastName_U', 'last1');
		inputMap.put('Ssn_U', '025666108');
		inputMap.put('Cli_U', '0521213546');
		inputMap.put('CompanyNumber_U', '');
		inputMap.put('Comment_U', 'first');
		inputMap.put('LeadType_U', 'B2B');
		inputMap.put('B2BAddressCity_U','tel-aviv');
        inputMap.put('B2BAddressStreet_U','moshe');
        inputMap.put('B2BLineOfBusiness_U','Cars');
        inputMap.put('B2BBranches_U','10');
        inputMap.put('B2BEmpNum_U',15);
        inputMap.put('AdditionalInfoFormula_U','test');
        inputMap.put('LookupPremises_U',null);
        inputMap.put('SourceFriendName_U','test');
        inputMap.put('SourceOther_U','test');
        inputMap.put('ProductLst_U',null);

		inputMap.put('CreateLead',detailsInputs);
		
		// check for success
		Boolean result = omniCreatLead.invokeMethod('findExistingLead', inputMap, outMap, optionMap);
		system.assertEquals(true, result);

		// check for error, no accountId sent
		/*Boolean failResult = contSvc.invokeMethod('getContactDetails', errorInMap, outMap, optionMap);
		system.assertEquals(true, result);*/		
	}     
	
    /**
	*	method for testing OmniCreateLeadService to create B2C lead type
	*	author Nikolay Iliaev
	*	taskId PLR-1295	
	*	@method	createLeadServiceTest
	*	@return	void	
	*/
	static testMethod void createLeadServiceB2CTest() {
		
		
		OmniCreateLeadService omniCreatLead = new OmniCreateLeadService();

		// Prepare unput data
		Map<String,Object> errorInMap = new Map<String,Object>();
		Map<String,Object> outMap = new Map<String,Object>();
		Map<String,Object> optionMap = new Map<String,Object>();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> BlkTxt2 = new Map<String,Object>();
		
		Map<String,Object> detailsInputs = new Map<String,Object>();
        BlkTxt2.put('Comment','first####');
        detailsInputs.put('BlkTxt2', BlkTxt2);
		inputMap.put('FirstName_U', 'first1');
		inputMap.put('LastName_U', 'last1');
		inputMap.put('Ssn_U', '326554568');
		inputMap.put('Cli_U', '0521213546');
		inputMap.put('Company_U', 'ccmopany1');
		inputMap.put('CompanyNumber_U', '');
		BlkTxt2.put('Comment_U', 'first');
		inputMap.put('LeadType_U', 'B2C');
		
		
		inputMap.put('CreateLead',detailsInputs);
		Test.startTest();
		// check for success
		Boolean result = omniCreatLead.invokeMethod('findExistingLead', inputMap, outMap, optionMap);
		system.assertEquals(true, result);

        Test.stopTest();
		// check for error, no accountId sent
		/*Boolean failResult = contSvc.invokeMethod('getContactDetails', errorInMap, outMap, optionMap);
		system.assertEquals(true, result);*/		
	}     
}