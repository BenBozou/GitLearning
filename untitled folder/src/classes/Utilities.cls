/**
 * Class for Utilities Methods
 * Liron Cohen
 * @class Utilities
 * @module Infra
 */
public class Utilities{
    
    //map from object + field + picklist api val ==> translated value. 
    //Used to reduce number of describe call
    private static map<String, String> picklistAPI_Label_Map = new map<String, String>();
    
    /**
    *   method description: Get translated value of picklist value
    *   author Liron Cohen
    *   taskId PLR-1346
    *
    *   @method getTranslatedValue
    *   @param {String}    object name
    *   @param {String}    field name
    *   @param {String}    picklist value
    *   @return {String}    Translated picklist value
    */
    public static String getTranslatedValue(String objName, String fieldName, String apiValue){
    
        String retVal;
        
        if(picklistAPI_Label_Map.containsKey(objName + fieldName + apiValue)){
        
            retVal = picklistAPI_Label_Map.get(objName + fieldName + apiValue);
            
        }
        else{
            //get SObjectType
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
        
           // Sobject Object_name = targetType.newSObject();
            
          //  Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        
            Schema.DescribeSObjectResult sobject_describe = targetType.getDescribe(); //describe the sobject
        
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        
            List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        
            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                
                picklistAPI_Label_Map.put(objName + fieldName + a.getValue(), a.getLabel());
            
                if(a.getValue() == apiValue){
                    retVal = a.getLabel();
                }
            }
        }
 
        return retVal;
    
    }

}