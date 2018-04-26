/**
*	Test class for testing CustomMetadataTypeService
*	@class CustomMetadataTypeServiceTest
*	Tal sabati
*	@module infrastructure
*/ 
@isTest
private class CustomMetadataTypeServiceTest {

    /**
	*	method for testing getCrmVariable
	*	Tal sabati
	*	@method	getCrmVariableTest
	*	@return	void
	*/
    static testMethod void getCrmVariableTest() {
        list<CrmVariable__mdt> crmVariableList = [Select Value__c, QualifiedApiName From CrmVariable__mdt limit 1];
        if(!crmVariableList.isEmpty()){
        	String crmVariableValue = CustomMetadataTypeService.getCrmVariable(crmVariableList[0].QualifiedApiName);
        }
    }
}