/**
* Service class populate picklist in omniscript
* Eliran Shalom
* Taskid PLR-855
* @class PicklistPopulation
* @module Leads
*/
global class PicklistPopulation implements vlocity_cmt.VlocityOpenInterface{
    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
      
        system.debug('Evaluate method name');
        try 
        {
            if (methodName.equals('PopulatePicklist'))
            {
                PopulatePicklist(input, outMap, options);
            }  
            
        }
        catch (Exception e) 
        {
            System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

       return true;
    }
    
    // Get All Product Family Associated with the Record Type where the Omniscript is Launched
    public void PopulatePicklist(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        List<Map<String,String>> optionsValue = new List<Map<String, String>>();
		Map<String,Object> detailsInputs = (Map<String,Object>)input.get('stpLeaddata');
        
        String leadType = (String)detailsInputs.get('lobFormula');
        leadType = '%'+leadType+'%'; 
        
        for(Product2 prd : [Select p.LOB__c, p.Family, p.ConsumerInd__c From Product2 p where p.LOB__c like:leadType])
        {
            Map<String, String> tempMap = new Map<String, String>();

            tempMap.put('name', prd.Family); // Language Independent 
            tempMap.put('value', prd.Family); // Displayed in Picklist UI
            optionsValue.add(tempMap);
        }
        
        outMap.put('options',optionsValue);    
    }

}