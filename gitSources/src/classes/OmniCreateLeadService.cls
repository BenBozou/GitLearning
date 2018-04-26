global with sharing class OmniCreateLeadService  implements vlocity_cmt.VlocityOpenInterface {
    
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    { 
        Boolean result = true;
        try
        {
            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('findExistingLead')) {
                system.debug('Calling findExistingLead function');
                //Map<String,Object> detailsInputs = (Map<String,Object>)inputMap.get('CreateLead');
               // findExistingLead(detailsInputs,outMap);
                 findExistingLead(inputMap,outMap);
            }
        }
        catch(Exception e)
        {
            result = false;
        }
        return result;
    }
   
   
    /**
    * Get Reccommendations 
    * Eric Fishman
    * @method findExistingLead 
    * @param {Map} inputMap
    * @param {String} recordTypeName
    * @return {Map} inputMap
    * @static
    */
    
    private void findExistingLead(Map<String,Object> inputMap, Map<String,Object> outMap) {
     
       try
        {
            CreateLeadService.GetResultData resultObject;
             
            
            String cli = (String)inputMap.get('Cli_U');          
            String ssn = (String)inputMap.get('Ssn_U');
            
           
                system.debug(LoggingLevel.Error, 'ssn and cli ' + ssn + ' + ' + cli);
            sObject leadContactSNN ;
            // Check if Phone exists in Lead or Contact
              if(ssn !=null && ssn != ''){    
                 leadContactSNN = CreateLeadService.isExsitLeadContactSSN(ssn);
             }
            if (leadContactSNN !=null ){
                outMap.put('accountID',leadContactSNN.get(Contact.AccountId));
                outMap.put('leadID',leadContactSNN.Id);
                outMap.put('duplicate','yes');
            }
            else
            {  
                /*
                sObject leadContact = CreateLeadService.isExsitLeadContact(cli);
                if (leadContact !=null){
                    
                    outMap.put('accountID',leadContact.get(Contact.AccountId));
                    outMap.put('leadID',leadContact.Id);
                    outMap.put('duplicate','yes');
                }
                else{
                */              
                    CreateLeadService.RequestsData rdata = new CreateLeadService.RequestsData(string.valueof(dateTime.now()));
                    // Create B2B lead
                    Map<String,Object> detailsInputs = (Map<String,Object>)inputMap.get('CreateLead');
                    Map<String,Object> detailsInputsComment = (Map<String,Object>)detailsInputs.get('BlkTxt2');
                
                    if((String)inputMap.get('LeadType_U') == 'B2B') {
                        rdata.RequestLineList.add(new CreateLeadService.RequestLine('Action',
                        (String)inputMap.get('FirstName_U'),
                        (String)inputMap.get('LastName_U'),
                        (String)inputMap.get('Odatatype_U'),
                        null,
                        (String)inputMap.get('Cli_U'),
                        (String)inputMap.get('Company_U'),
                        (String)inputMap.get('CompanyNumber_U'),
                        detailsInputsComment != null ? (String)detailsInputsComment.get('Comment') : null ,
                        (String)inputMap.get('LeadSource_U'),
                        (String)inputMap.get('B2BAddressCity_U'),
                        (String)inputMap.get('B2BAddressStreet_U'),
                        (String)inputMap.get('B2BLineOfBusiness_U'),
                        String.valueof(inputMap.get('B2BBranches_U'))!= '' ? (integer)inputMap.get('B2BBranches_U') : null,
                        String.valueof(inputMap.get('B2BEmpNum_U'))!= '' ? (integer)inputMap.get('B2BEmpNum_U') : null,
                        null,
                         String.valueof(inputMap.get('LookupPremises_U'))!= '' ?(String)inputMap.get('LookupPremises_U'):null,
                        (String)inputMap.get('SourceFriendName_U'), 
                        (String)inputMap.get('SourceOtherOption_U'),
                         String.valueof(inputMap.get('ProductLst_U'))!= '' ?(String)inputMap.get('ProductLst_U'):null,                                                                  
                        (String)inputMap.get('LeadType_U')));
                    } else {
                        // Create B2C lead
                        rdata.RequestLineList.add(new CreateLeadService.RequestLine('Action',
                        (String)inputMap.get('FirstName_U'),
                        (String)inputMap.get('LastName_U'),
                        (String)inputMap.get('Odatatype_U'),
                        (String)inputMap.get('Ssn_U'),
                        (String)inputMap.get('Cli_U'),
                        '',
                        (String)inputMap.get('CompanyNumber_U'),
                        (String)detailsInputsComment.get('Comment'),
                        (String)inputMap.get('LeadSource_U'),
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        (String)inputMap.get('SourceFriendName_U'), 
                        (String)inputMap.get('SourceOtherOption_U'),
                        String.valueof(inputMap.get('ProductLst_U'))!= '' ?(String)inputMap.get('ProductLst_U'):null, 
                        (String)inputMap.get('LeadType_U')));
                    }
                    
                    String result = CreateLeadService.createLead(JSON.serialize(rdata));   
                    resultObject = (CreateLeadService.GetResultData)JSON.deserialize(result,CreateLeadService.GetResultData.class);
                    system.debug(LoggingLevel.Error, 'test ' + resultObject.resultsDataList);
                
                    outMap.put('leadID',resultObject.resultsDataList[0].SequenceId);     
                    outMap.put('duplicate','no');       
                //}
            }
        }
        catch (Exception e) {
            system.debug('ERROR :'+e.getMessage() + ' ' + e.getStackTraceString() );
            outMap.put('errordescription',e.getMessage()+ ' ' + e.getStackTraceString());
        }
    }
     
    
}