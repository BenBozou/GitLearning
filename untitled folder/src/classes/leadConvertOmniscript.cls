/**
* Service class convert lead to opportunity from omniscript
* Eliran Shalom
* Taskid PLR-31
* @class convertopportunity
* @module Leads
*/
global class leadConvertOmniscript implements vlocity_cmt.VlocityOpenInterface{
  public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        //system.debug('Evaluate method name');
        try 
        {
            if (methodName.equals('convertopportunity')){
                convertopportunity(input, outMap, options);
            }  
            if (methodName.equals('checkSSN')){
                convertopportunity(input, outMap, options);
            }
        }
        catch (Exception e){System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());}
      return true;
    }   
    
    
    public void convertopportunity(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        
        List<Map<String,String>> optionsValue = new List<Map<String, String>>();
        try 
        { 
            String leadId = (String)input.get('ContextId');
            String resp = LeadConvertManually.convertLead((ID)leadId);
            outMap.put('convertopportunityStatus',resp); 
        }
        catch (Exception e){System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());}  
    }
    
    
    
    public void checkSSN(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        
        List<Map<String,String>> optionsValue = new List<Map<String, String>>();
        try 
        { 
            system.debug('Evaluate method name');
            Map<String,Object> detailsInputs = (Map<String,Object>)input.get('stpLeaddata');
            String leadId = (String)input.get('ContextId');
            String resp = LeadConvertManually.convertLead((ID)leadId);
            outMap.put('convertopportunityStatus',resp); 
        }
        catch (Exception e){System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());}  
    }
}