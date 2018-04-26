/**
* Service class for Custom Metadata Type.
* Tal sabati
* @class CustomMetadataTypeService
* @module infrastructure
*/ 
public with sharing class CustomMetadataTypeService {
	/**
	* Retrieves Crm Variable value by specific key
	* Tal sabati
	* @method getCrmVariable	
	* @param {String} key
	* @return {String} value
	* @static
	*/
	public static string getCrmVariable(String key){
		list<CrmVariable__mdt> crmVariableList = [Select Value__c, QualifiedApiName From CrmVariable__mdt  where QualifiedApiName =: key];
	    if(crmVariableList.isEmpty()){
            return null;
        }
        return crmVariableList[0].Value__c;
	}
}