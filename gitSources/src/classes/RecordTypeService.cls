/**
* Service class for record types.
* Mohammad Garrah
* @class RecordTypeService
* @module infrastructure
*/ 
public with sharing class RecordTypeService {

    //Maps will store all the records types
    //Map: recordTypeId_NameMap. For key: Record Type Id  ==>  Record Type Name
    //Map: objectRTDeveloperIdMap. For key: object + Developer Name ==> Record Type Id
	private static map<Id, String> recordTypeId_NameMap = new map<Id, String>();
	
	private static map<String, Id> objectRTDeveloperIdMap = new map<String, Id>();
	
    /**
    * Retrieves the record type name for a record type id 
    * Mohammad
    * @method getRecordTypeNameById 
    * @param {String} objectName
    * @param {Id} recordTypeId
    * @return {String}
    * @static
    */
    public static String getRecordTypeNameById(String objectName, Id recordTypeId){
        //value to return
        String recordTypeName;
        
        if(!String.isBlank(objectName) && !String.isBlank(recordTypeId)){
        
        	//if Id map doesn't contain the Id parameter then populate the map
        	if(recordTypeId_NameMap.isEmpty()){
        		populateRecordTypeMaps();
        	}
        	
        	//Now the map should contain the Id Paramter
        	recordTypeName = recordTypeId_NameMap.get(recordTypeId);
        }

        return recordTypeName;
    }
    
    /**
    * Retrieves the record type Id for a record type develoepr name 
    * Mohammad
    * @method getRecordTypeIdByName 
    * @param {String} objectName
    * @param {String} recordTypeDeveloperName
    * @return {Id}
    * @static
    */
    public static Id getRecordTypeIdByName(String objectName, String recordTypeName){
      
        //value to return
        Id recordTypeId = null;
        
        if(!String.isBlank(objectName) && !String.isBlank(recordTypeName)){
        	
        	//If the paramter are not in the map yet, should populate the map
        	if(objectRTDeveloperIdMap.isEmpty()){
        		populateRecordTypeMaps();
        	}
        	
        	//Now the map should contain the object name + record type name
        	recordTypeId = objectRTDeveloperIdMap.get(objectName + recordTypeName);
		}
        
        return recordTypeId;
    }

    
     
    /**
    * Retrieves all record type in system and store them in maps 
    * Liron
    * @method populateRecordTypeMaps  
    * @static
    */
        private static void populateRecordTypeMaps(){
    
        	//If the record type was not retrieved before, query all the record types
    		for(RecordType recordType : [   select id, Name, developerName, sobjectType  from RecordType]){
                    
                recordTypeId_NameMap.put(recordType.id, recordType.Name);  
                
                objectRTDeveloperIdMap.put(recordType.sobjectType + recordType.developerName, recordType.id);                             
    		}
        }
        
     /**
    * Retrieves record type Id by name
    * Elad
    * @method getredordTypeIdByName  
    * @static
    */  
        public static Id getSelectiveRecordTypeIdByName(String objectName, String recordTypeName){
    
    		String soql = 'SELECT Id FROM RecordType WHERE sobjectType = \''  + objectName + '\' and developerName = \'' + recordTypeName + '\'';
    		
    		list<RecordType> recordType_List = DataBase.query(soql);
     		if (recordType_List.isEmpty()) {
    		    return null;
    		}
    		return recordType_List[0].Id;
        }
}