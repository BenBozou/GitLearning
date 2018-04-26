public class NewLeadController {
    
    public NewLeadController(ApexPages.StandardController c) {
        
    }
 
    public PageReference getRedirect() {
        String b2cRT = RecordTypeService.getRecordTypeIdByName('Lead','B2C');
        String b2bRT = RecordTypeService.getRecordTypeIdByName('Lead','B2B');
        String actualRecordType = null;
        String PremisesId;
        Map<String, String> parameters =  ApexPages.currentPage().getParameters();
        
         if (ApexPages.currentPage().getParameters().get('RecordType') == null) {
            Schema.DescribeSObjectResult describeLead = Schema.SObjectType.Lead;
            List<Schema.RecordTypeInfo> rtInfos = describeLead.getRecordTypeInfos();
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                // walk through the map to determine the correct record type, this is done with the isAvailable() function
                if(!rtInfo.isMaster() && rtInfo.isAvailable()) {
                    // below lines will only run one time only
                    System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available, adding it as parameter to the page.');
                   // ApexPages.currentPage().getParameters().put('RecordType', rtInfo.getRecordTypeId());
                    actualRecordType = rtInfo.getRecordTypeId();
                }
            }
    	}
        else
        {
           
            if (parameters.containsKey('RecordType')) {
            	actualRecordType = parameters.get('RecordType');
        	}
            
        }
          
       	String  premisesPrefix = vlocity_cmt__Premises__c.sObjectType.getDescribe().getKeyPrefix();
        
        for(String param : parameters.keySet()){
            if(param.endsWithIgnoreCase('_lkid') && parameters.get(param).startsWithIgnoreCase(premisesPrefix)){
                PremisesId =  parameters.get(param);
                break;
            }
        }
        
    
        
        if (actualRecordType != null) {
            if (b2cRT.startsWith(actualRecordType)) {
                return new PageReference('/apex/OmniScriptCellcomPage?RecordType=B2C&omniscriptname=CreateLead&id=%7B0%7D#/OmniScriptType/Lead/OmniScriptSubType/Create/OmniScriptLang/English/ContextId/%7B0%7D/PrefillDataRaptorBundle/true');
            } else if (b2bRT.startsWith(actualRecordType)) {
                return new PageReference('/apex/OmniScriptCellcomPage?PremisesId='+PremisesId+'&RecordType=B2B&omniscriptname=CreateLead&id=%7B0%7D#/OmniScriptType/Lead/OmniScriptSubType/Create/OmniScriptLang/English/ContextId/%7B0%7D/PrefillDataRaptorBundle/true');
            }  
        } else {
            return new PageReference('/00Q/e?nooverride=1&recommendation=true');
        }

        return new PageReference('/00Q/e?RecordType=' + parameters.get('RecordType') + '&nooverride=1&recommendation=true');
    }
}