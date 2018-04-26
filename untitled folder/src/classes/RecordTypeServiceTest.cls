/**
*	Test class for testing RecordTypeService
*	@class RecordTypeServiceTest
*	Mohammad Garrah
*	@module infrastructure
*/ 
@isTest
private class RecordTypeServiceTest {

    /**
	*	method for testing RecordTypeService
	*	Mohammad Garrah
	*	@method	recordTypeServicesTest
	*	@return	void
	*/
    static testMethod void recordTypeServicesTest() {
        
        RecordType accountRecordType = [Select Id, Name, developername From RecordType where IsActive = true and SobjectType = 'Account' limit 1];
        
        //testing the following methods: getRecordTypeNameById, getObjectRecordTypeIdNameMap and getObjectRecordTypesInfo
        String recordTypeName = RecordTypeService.getRecordTypeNameById('Account',accountRecordType.Id);
        system.assertEquals(accountRecordType.Name,recordTypeName);
        
        //testing the following methods: getRecordTypeIdByName, getObjectRecordTypeNameIdMap and getObjectRecordTypesInfo
        Id recordTypeId = RecordTypeService.getRecordTypeIdByName('Account',accountRecordType.developername);
        system.assertEquals(accountRecordType.Id,recordTypeId);
    }
}