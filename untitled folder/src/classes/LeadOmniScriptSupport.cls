/**
* Service class Support omniscripthandle
* Eliran Shalom
* Taskid PLR-31
* @class LeadOmniScriptSupport
* @module Leads
*/

global class LeadOmniScriptSupport implements vlocity_cmt.VlocityOpenInterface{
  public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        system.debug(LoggingLevel.ERROR,'Evaluate method name: ' + methodName);
        //system.debug('Evaluate method name' + methodName.equals('checkSSN'));
        try 
        {
            if (methodName.equals('convertopportunity'))
                convertopportunity(input, outMap);
            if (methodName.equals('checkSSN'))
                checkSSN(input, outMap);
            if (methodName.equals('PopulatePicklist'))
                PopulatePicklist(input, outMap, options);
            if (methodName.equals('getLIcData'))
                getLIcData(input, outMap, options);
            if (methodName.equals('activateCMProv'))
                activategetCMProv(input, outMap, options);
            if (methodName.equalsIgnoreCase('getLeadData'))
                getLeadData(input, outMap, options);
            if (methodName.equalsIgnoreCase('getLeadStory'))
                getLeadStory(input, outMap, options);
            if (methodName.equalsIgnoreCase('PopulatePicklistCallOption'))
                PopulatePicklistCallOption(input, outMap, options);
            if (methodName.equalsIgnoreCase('getPremisesData'))
                getPremisesData(input, outMap, options);
            if (methodName.equalsIgnoreCase('sendSMS'))
                sendSMS(input, outMap);
             if (methodName.equalsIgnoreCase('BlocktroubledCustomer'))
                BlocktroubledCustomer(input, outMap);
            if (methodName.equalsIgnoreCase('checkCompanyNumber'))
                checkCompanyNumber(input, outMap);
                
              
        }
        catch (Exception e)
            {System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());}

       return true;
    }   
/**
* invoke to sms service to send sms 
* Nikolay Iliaev
* Taskid PLR-1313
* @class sendSMS
* @module Leads
*/
    public void sendSMS(Map<String, Object> input, Map<String, Object> outMap) {
        
        Map<String,Object> detailsInputs = (Map<String,Object>)input.get('LeadData');
       // Map<String,Object> blkSSN = (Map<String,Object>)detailsInputs.get('blkSSN');
        String Phone = (String)detailsInputs.get('Phone');
        String SmsTemplate = (String)input.get('SmsTemplate');
        system.debug('smstemplate = ' + SmsTemplate);
        system.debug('Phone = ' + Phone);
        if(Phone!= null && SmsTemplate!= null){
             new SMSService(SmsTemplate,Phone,'');
         }
    }
    
/**
* invoke to sms service to BlocktroubledCustomer 
* Eliran Shalom
* Taskid PLR-1313
* @class BlocktroubledCustomer
* @module Leads
*/
    public void BlocktroubledCustomer(Map<String, Object> input, Map<String, Object> outMap) {
        
        Map<String,Object> detailsInputs = (Map<String,Object>)input.get('LeadData');
       // Map<String,Object> blkSSN = (Map<String,Object>)detailsInputs.get('blkSSN');
        String Phone = (String)detailsInputs.get('Phone');
        String SmsTemplate = (String)input.get('SmsTemplate');
        system.debug('smstemplate = ' + SmsTemplate);
        system.debug('Phone = ' + Phone);
       
    /*
      Phone =  Phone.ReplaceAll('(','');
      Phone =  Phone.ReplaceAll(')','');
      Phone =  Phone.ReplaceAll('-','');
      Phone =  Phone.ReplaceAll(' ','');
    */  
        
        if(Phone!= null && SmsTemplate!= null){
            
           BlocktroubledCustomerService.GetResult resultObject = BlocktroubledCustomerService.BlockCustomer(SmsTemplate,Phone,'');
              if(resultObject !=null)
              {   
                  system.debug('resultObject = ' + resultObject);
                   outMap.put('troubledBlockType',resultObject.blockType);
                   outMap.put('troubledReturnCode',resultObject.ReturnCode);
                }
           }
    }
    
/**
* Service class convert lead to opportunity from omniscript
* Eliran Shalom
* Taskid PLR-31
* @class convertopportunity
* @module Leads
*/
     public void convertopportunity(Map<String, Object> input, Map<String, Object> outMap)
    {
        try 
        { 
            String leadId = (String)input.get('leadIDParam');
            String resp = LeadConvertManually.convertLead((ID)leadId);
            
            if (resp != null && resp.contains('#$')) {
                outMap.put('oppId',resp.substringAfter('#$'));
                outMap.put('convertopportunityData',resp.substringBefore('#$')); 
            } else {
                outMap.put('convertopportunityData',resp);
            }
            outMap.put('convertetd',true); 
        }
        catch (Exception e){System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());}  
    }
   
    
    
    
    
    //shoud be move to utils class
    public static integer idVerification(String id) {
        String a;
        integer sum=0, i, j, num;
        
        for(i=0; i<8; i++)
        {
            if(i==0 || math.mod(i, 2)==0)
            {
                num = integer.valueOf(id.substring(i,i+1));
                sum = sum+num;
            }
            else
            {
                num = integer.valueOf(id.substring(i,i+1));
                if((num*2)>10)
                {
                    a = string.valueof(num*2);
                    for(j=0; j<2; j++)
                    {
                        num = integer.valueOf(a.substring(j,j+1));
                        sum = sum+num;
                    }
                }
                else
                    sum = sum+(num*2);
            }
        }
        
        return sum;
    }
    
    /**
    * Service class check validation on Vompany number
    * Nikolay Iliaev
    * Taskid PLR-1394
    * @class checkCompanyNumber
    * @module Leads
    */
    public void checkCompanyNumber(Map<String, Object> input, Map<String, Object> outMap)
    {
        
        List<Map<String,String>> optionsValue = new List<Map<String, String>>();
        Boolean isCompanyNum = true;
        try 
        { 
            Map<String,Object> detailsInputs = (Map<String,Object>)input.get('StpCompanyNumber');
            Map<String,Object> blkSSN = (Map<String,Object>)detailsInputs.get('blkCompanyNumber');
            String companyNumber = (String)blkSSN.get('CN');
            String accId;
            String ValidCN = 'true';
            
            if(companyNumber != null) {
                Id leadAccountCN=  createleadService.isExsitLeadAccountCN(companyNumber);
                if(leadAccountCN != null) {
                    ValidCN = 'false';
                    accId =  (String)leadAccountCN;
                    System.debug(LoggingLevel.ERROR,'accId: ' + accId);
                }
                
            }
            
            CreateOrUpdateLeadX(input,outMap,isCompanyNum);
            
            outMap.put('accId',accId);
            outMap.put('ValidCN',ValidCN);
            
        }
        catch (Exception e){System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());}  
    }
    
    /**
    * Service class check validation on SSN
    * Eliran Shalom
    * Taskid PLR-31
    * @class checkSSN
    * @module Leads
    */
    public void checkSSN(Map<String, Object> input, Map<String, Object> outMap)
    {
        
        List<Map<String,String>> optionsValue = new List<Map<String, String>>();
        Boolean isCompanyNum = false; 
        try 
        { 
            
            Map<String,Object> detailsInputs = (Map<String,Object>)input.get('StpSSN');
            Map<String,Object> blkSSN = (Map<String,Object>)detailsInputs.get('blkSSN');
            
            
            String SSN = (String)blkSSN.get('SSN');
            
            String leadAccount;
            String leadContact;
            Boolean ValidSSN = false ;
            String validateSsnMsg;
            system.debug('Evaluate method name');
            //if(SSN.length()==9)
            //{    
                //boolean verifyID = idVerificationNew(SSN);
                //Integer bikoret = integer.valueOf(SSN.substring(8,9));
                // system.debug('verifyID = ' + verifyID);
                //if(verifyID){
                if(CheckIdentificationNumberValueValidity(SSN)){
                    sObject leadContactSNN = CreateLeadService.isExsitLeadContactSSN(SSN);
                    System.debug(LoggingLevel.ERROR,'leadContactSNN: ' + leadContactSNN);
            
                    if (leadContactSNN !=null){
                        
                        leadAccount =  Schema.Lead.getSObjectType() == leadContactSNN.getSObjectType() 
                            ? (String)leadContactSNN.get('AccountId__c') 
                            : (String)leadContactSNN.get('AccountId');
                        
                        System.debug(LoggingLevel.ERROR,'leadAccount: ' + leadAccount);
                        
                       
                     
                        leadContact = (String)leadContactSNN.get('Id');
                        validateSsnMsg = 'Exsits';
                        
                        //ValidSSN = false;
                         ValidSSN = true;
                       CreateOrUpdateLeadX(input,outMap,isCompanyNum);
                    }
                    else
                    {   
                       validateSsnMsg = 'The ID is legal';
                       ValidSSN = true;
                       CreateOrUpdateLeadX(input,outMap,isCompanyNum);
                    }
                }
                else{
                	validateSsnMsg = 'ilegal';
                }
               //} lse
                //validateSsnMsg = 'The ID is ilegal!!';
        //}
        //else
        //{
        //     validateSsnMsg = 'An Israeli ID must contain 9 numbers. \nEnter your ID:';
      
        //}
             outMap.put('leadAccount',leadAccount);
             outMap.put('leadContact',leadContact);
             outMap.put('validateSsnMsg',validateSsnMsg);
            // outMap.put('validateSsnMsg',validateSsnMsg);
             outMap.put('ValidSSN',ValidSSN); 
        }
        catch (Exception e){System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());}  
    }
 
    /**
    * update or create lead X ODATA with SSn or company nymber
    * Nikolay Iliaev
    * Taskid PLR-1452
    * @method CreateOrUpdateLeadX
    * @param {Map<String, Object>} input
    * @param {Map<String, Object>} outMap
    * @module Leads
    */
    public void CreateOrUpdateLeadX(Map<String, Object> input, Map<String, Object> outMap,Boolean isCompanyNum) {
        
        // Part of B2C logic
        if(isCompanyNum) {
            Map<String,Object> detailsInputs = (Map<String,Object>)input.get('StpCompanyNumber');
            Map<String,Object> blkSSN = (Map<String,Object>)detailsInputs.get('blkCompanyNumber');
            Map<String,Object> leadDataMap = (Map<String,Object>)input.get('LeadData');
            Map<String,Object> LeadXMap = (Map<String,Object>)leadDataMap.get('Leads__x');
            
            System.debug(LoggingLevel.ERROR,'LeadXMap ' + LeadXMap);
            
            String companyNumber = (String)blkSSN.get('CN');
            Id leadId = (Id)input.get('leadIDParam');
            String ExternalId = (LeadXMap != null && LeadXMap.containsKey('ExternalId')) 
                ? (String)LeadXMap.get('ExternalId') 
                : '';
            
            System.debug(LoggingLevel.ERROR,'CN: ' + companyNumber + ' ExternalId: ' + ExternalId);
            
            CreateLeadService.RequestLine line = new CreateLeadService.RequestLine(null,null,null,'B',null,null,null,companyNumber,null,null,null,null,null,
                                                                                    null,null,null,null,null,null,null,null);
            
            if(ExternalId != ''){
                //call update leadX
                CreateLeadService.updateOdataLeads(ExternalId,line); 
            } else {
                CreateLeadService.createExternalLead(line,leadId);
            }
            // Part of B2C logic
        } else {
            
            Map<String,Object> detailsInputs = (Map<String,Object>)input.get('StpSSN');
            Map<String,Object> blkSSN = (Map<String,Object>)detailsInputs.get('blkSSN');
            Map<String,Object> leadDataMap = (Map<String,Object>)input.get('LeadData');
            Map<String,Object> LeadXMap = (Map<String,Object>)leadDataMap.get('Leads__x');
            
            String SSN = (String)blkSSN.get('SSN');
            String SetSSNType = (String)input.get('SetSSNType');
            String ExternalId = (LeadXMap != null && LeadXMap.containsKey('ExternalId')) 
                ? (String)LeadXMap.get('ExternalId') 
                : '';
            String companyNumber = (String)input.get('company_number__c');
            Id leadId = (Id)input.get('leadIDParam');
            
            CreateLeadService.RequestLine line = new CreateLeadService.RequestLine(null,null,null,SetSSNType,SSN,null,null,companyNumber,null,null,null,null,null,
                                                                                    null,null,null,null,null,null,null,null);
            
            
            System.debug(LoggingLevel.ERROR,'SSN: ' + SSN + ' SSN type: ' + SetSSNType + ' ExternalId: ' + ExternalId + ' Lead Id: '  + leadId);
            System.debug(LoggingLevel.ERROR,'Line: ' + line);
            
            if(ExternalId != ''){
                //call update leadX
                CreateLeadService.updateOdataLeads(ExternalId,line); 
                
            } else {
                CreateLeadService.createExternalLead(line,leadId);
            }
        }
    }
    
/**
* Get All Product Family Associated with the Record Type where the Omniscript is Launched
* Eliran Shalom
* Taskid PLR-855
* @class PicklistPopulation
* @module Leads
*/
    public void PopulatePicklist(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        List<Map<String,String>> optionsValue = new List<Map<String, String>>();
         
        String lineOfBusinessInd = ((String)input.get('lobFormula')=='B2C'?'ConsumerInd__c':'BusinessInd__c');
       
        String query = 'Select LOB__c, tolabel(Family) translateFamily,Family  ' +
                        'From Product2 where IsActive = true and ' +
                        lineOfBusinessInd + '= true';
        
         //List<Product2> productList = [Select p.LOB__c, tolabel(p.Family) translateFamily,p.Family , p.ConsumerInd__c 
         //    From Product2 p 
         //    where (B2B and p.ConsumerInd__c = true)
         //                             or
         //                      (B2C and p.BusinessInd__c = true)];
        List<Product2> productList = (List<Product2>)Database.query(query);
        

        Set<String> productUniqueSet = new Set<String>();
        for (Product2 product: productList) {
            if (!productUniqueSet.contains(product.Family)){
                Map<String, String> tempMap = new Map<String, String>();
               
                tempMap.put('name',  product.Family); // Language Independent 
                tempMap.put('value',(String)product.get('translateFamily')); // Displayed in Picklist UI
                optionsValue.add(tempMap);
                productUniqueSet.add(product.Family);
            }
            
        }
     
        outMap.put('options',optionsValue);    
    }
    
    
    public void PopulatePicklistCallOption(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        List<Map<String,String>> optionsValue = new List<Map<String, String>>();
        Map<String,Object> detailsInputs = (Map<String,Object>)input.get('stpLeaddata');
        Map<String,Object> userData = (Map<String,Object>)input.get('userData');
        Map<String,Object> LeadData = (Map<String,Object>)input.get('LeadData');
        
        String leadType = (String)input.get('lobFormula');
        boolean Outbond = (boolean)LeadData.get('Outbond__c');
        boolean IsSoftphone = (boolean)userData.get('IsSoftphone__c');
        
        Schema.DescribeFieldResult leadStatusDesc = Lead.Status.getDescribe();
        List<Schema.PicklistEntry> statusPicklistValues = leadStatusDesc.getPicklistValues();
        for (Schema.PicklistEntry entry : statusPicklistValues) {
            if(entry.getValue()== 'LST06' || entry.getValue()== 'LST03' || entry.getValue()== 'LST05' ||
               (entry.getValue()== 'LST13' && (leadType=='B2C' || Outbond)) || (entry.getValue()== 'LST02' && !IsSoftphone)){
                    optionsValue.add(new Map<String, String> {'name'=>entry.getValue(), 'value'=>entry.getLabel()});
             }
         }
        outMap.put('options',optionsValue);    
    }

    /**
* Get All LIC
* Eliran Shalom
* Taskid PLR-855
* @class PicklistPopulation
* @module Leads
*/
    public void getLIcData(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        List<Map<String,String>> optionsValue = new List<Map<String, String>>();
        Map<String,Object> detailsInputs = (Map<String,Object>)input.get('LeadData');
        Map<String,Object> productdata = (Map<String,Object>)detailsInputs.get('productData');
      
        String Lic = (String)productdata.get('LinkToLegacy__c');
        List<String> LicList = Lic.split(';');
        List<vlocity_cmt__VlocityAction__c> actionlist =  [select vlocity_cmt__URL__c,vlocity_cmt__LinkType__c,name,vlocity_cmt__DisplayLabel__c,vlocity_cmt__UrlParameters__c  from vlocity_cmt__VlocityAction__c where name IN :LicList];
       
       
        for(vlocity_cmt__VlocityAction__c prd : actionlist)
        {
            Map<String, String> tempMap = new Map<String, String>();
            tempMap.put('displayname', prd.vlocity_cmt__DisplayLabel__c); 
            tempMap.put('name', prd.name); 
            tempMap.put('LinkType', prd.vlocity_cmt__LinkType__c); 
            tempMap.put('LinkUrl', prd.vlocity_cmt__URL__c); 
            tempMap.put('UrlParameters', prd.vlocity_cmt__UrlParameters__c); 
            optionsValue.add(tempMap);
        }
         outMap.put('LIcData',optionsValue); 
        
       }
       
 /**
* Get All getPremisesData
* Eliran Shalom
* Taskid PLR-855
* @class getPremisesData
* @module Leads
*/
    public void getPremisesData(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        List<Map<String,String>> optionsValue = new List<Map<String, String>>();
        Map<String,Object> detailsInputs = (Map<String,Object>)input.get('CreateLead');
       
       String CBStreet = (String)detailsInputs.get('premissFormulaStreet');
       String CBCity = (String)detailsInputs.get('premissFormulaCity');
         
        List<vlocity_cmt__Premises__c> Premiseslist =  [Select id ,name,toLabel(vlocity_cmt__Status__c),Score__c,PremiseLocation__c  from vlocity_cmt__Premises__c where vlocity_cmt__City__c like:CBCity  and CBStreet__c like:CBStreet ];
       
       
        for(vlocity_cmt__Premises__c  Prem : Premiseslist)
        {
            Map<String, String> tempMap = new Map<String, String>();
            
            tempMap.put('name', Prem.id +'|' + Prem.PremiseLocation__c); 
            tempMap.put('value',Prem.name +'('+ Prem.vlocity_cmt__Status__c +')'); 
            optionsValue.add(tempMap);
        }
         outMap.put('options',optionsValue); 
       }


/**
* Get Lead data for side bar
* Eric Fishman
* Taskid PLR-1249
* @class 
*   @method getLeadData
*   @param  {Map}
*   @param  {Map}
*   @param  {Map}
*   @return {Boolean}
* @module Leads
*/

 
    private static Boolean getLeadData(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
    {
        try{
        
            System.debug(Logginglevel.ERROR, 'getLeadData.invokeMethod - inputMap: ' + inputMap);
            
            if ((inputMap.containsKey('fromOmni') && (string) inputMap.get('fromOmni') == 'true') &&
                (!inputMap.containsKey('leadId') || String.isEmpty((string) inputMap.get('leadId'))))
                return returnError(outMap, 'processInfoMsg', Label.msgInsertNewLead);  
                
            if (!inputMap.containsKey('leadId') || String.isEmpty((string) inputMap.get('leadId'))) 
                return returnError(outMap, 'processErrorMsg', Label.MissingParameterError);             
                
                String leadId = (Id) inputMap.get('leadId');
                    
            Lead lead = new Lead();            
        
            lead = [select Phone, FirstName, LastName, Email,  Product__c, /*SubProduct__c,*/ Status, Company,
                        (select ssn__c, sequence_id__c, company_number__c
                        from Leads__r)
                    from Lead where Id =: leadId];
                    
            if (lead != null)
            {
                outMap.put('FirstName', lead.FirstName);
                outMap.put('LastName', lead.LastName);
                outMap.put('Phone', lead.Phone);
                outMap.put('Email', lead.Email);
                outMap.put('Company', lead.Company);
                outMap.put('ssn', (lead.Leads__r.size()>0) ? lead.Leads__r[0].ssn__c : '');
                outMap.put('CompanyNumber', (lead.Leads__r.size()>0) ? lead.Leads__r[0].company_number__c : '');
            }
                                        
                    
            return true;
                                             
        }catch (Exception e) {
            System.debug(Logginglevel.ERROR, '>>>> 30 getLeadData Exception: ' + e + ' from: ' + e.getStackTraceString());
            outMap.put('processError', 'false');
            return false;
        } 
    }

/**
* Get Lead data for side bar leadstory
* Eric Fishman
* Taskid PLR-1249
* @class 
*   @method getLeadData
*   @param  {Map}
*   @param  {Map}
*   @param  {Map}
*   @return {Boolean}
* @module Leads
*/

 
    private static Boolean getLeadStory(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
    {
        try{
             List<Map<String,String>> optionsValue = new List<Map<String, String>>();
            System.debug(Logginglevel.ERROR, 'getLeadStory.invokeMethod - inputMap: ' + inputMap);
            
            if (!inputMap.containsKey('leadId') || String.isEmpty((string) inputMap.get('leadId'))) 
                return returnError(outMap, 'processErrorMsg', Label.MissingParameterError);             
                
                String leadId = (Id) inputMap.get('leadId');
        
                List<Task> tasklist =  [Select t.ActivityDate,t.WhoId , t.Product__r.Name  , Description ,tolabel(t.LeadSubStatus__c),type,tolabel(t.LeadStatus__c), t.Id ,t.owner.name From Task t where t.LeadId__c=:leadId order by t.createdDate desc];
           
            for(Task tsk : tasklist){
                Map<String, String> tempMap = new Map<String, String>();
                tempMap.put('ActivityDate', String.ValueOf(tsk.ActivityDate)); 
                tempMap.put('LeadStatus__c', String.ValueOf(tsk.LeadStatus__c));
                tempMap.put('LeadSubStatus__c', String.ValueOf(tsk.LeadSubStatus__c));
                tempMap.put('Description', String.ValueOf(tsk.Description));
                tempMap.put('Id', String.ValueOf(tsk.get('id')));
                tempMap.put('owner', String.ValueOf(tsk.owner.name));
                tempMap.put('Product', String.ValueOf(tsk.Product__r.Name));
                optionsValue.add(tempMap);
        }
        
          outMap.put('StoryData', optionsValue);
            
            return true;
                                             
        }catch (Exception e) {
            System.debug(Logginglevel.ERROR, '>>>> 30 getLeadData Exception: ' + e + ' from: ' + e.getStackTraceString());
            outMap.put('processError', 'false');
            return false;
        } 
    }


       
/**
* Get All LIC
* Eric Fishman
* Taskid PLR-930
* @class 
* @module Leads
*/
    private static Boolean activategetCMProv(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        
       
        try{
            
        
            System.debug(Logginglevel.ERROR, 'activategetCMProv.invokeMethod - inputMap: ' + input);            
           
            
                        
            // build Body JSON
            activateCMPROVBuilder request = new activateCMPROVBuilder(input);
            OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00705');
             
            // Append Body tp Request JSON
            ctrlRequest.body.setRequestNode(request); 
                
            System.debug(Logginglevel.debug,' request IN ' + request);             
                                                                    
             Map<String,Object> res = ctrlRequest.sendRequestWithErrorCheck('OSB', 'api/services/rest/00705_osb_cmprovisioning');                     
               
            System.debug(Logginglevel.debug,'IN ' + res);         
         
            map<String,Object> bodyMap = (map<String,Object>)res.get('Body');
            map<String,Object> Response = (map<String,Object>)bodyMap.get('Response');
            map<String,Object> RequestResponse = (map<String,Object>)Response.get('RequestResponse');
            map<String,Object> provision_detail = (map<String,Object>)RequestResponse.get('provision_detail');

            String return_code =     (String)provision_detail.get('return_code')   ;
            String return_code_message =     (String)provision_detail.get('return_code_message')   ;         
            System.debug(Logginglevel.debug,' return_code ' + return_code);  
         
            outMap.put('return_code', return_code);
            outMap.put('return_code_message', return_code_message);              
            system.debug(Logginglevel.Error,'Invoke OSB response: ' + res);
                
                
                return true;           
                
        }
        catch (Exception e) {
            System.debug(Logginglevel.ERROR, '>>>> 30 activategetCMProv Exception: ' + e + ' from: ' + e.getStackTraceString());
            outMap.put('processError', 'false');
            return false;
        } 
        
       }
       
       /**
    * Class helper for creating and populating Json Header request for Activate CMPROM callouts
    * Eric Fishman
    * Taskid PLR-930
    * @class polmRecommnendationsBuilder
    * @constructor
    * @param {String} funcCode
    * @module Lead
    */     
    public class activateCMPROVBuilder extends OSBCalloutBuilder.RequestBuilder { 
        public RequestResponseController  RequestResponse; 
        
        public activateCMPROVBuilder(Map<String,Object> input){
            RequestResponse = new RequestResponseController(input);    
        }
    }
    
    
    public class RequestResponseController {
        public provisionDetail provision_detail;
        
        public RequestResponseController (Map<String,Object> input){            
            
            System.debug(Logginglevel.debug, 'RequestResponseController - inputMap: ' + input);
            Map<String,Object> detailsInputs = (Map<String,Object>)input.get('LeadData');
            provision_detail = new provisionDetail();           
        	
        	String DealerCodeStr = string.valueof(input.get('SetDealerCode'));
        	
            provision_detail.prov_code = (String)detailsInputs.get('ProvCode');
            provision_detail.comm_code =  (String)detailsInputs.get('CommCode'); 
            provision_detail.subscriber_number = (String)detailsInputs.get('Subscriber');                            
            provision_detail.channel_id = string.valueof(input.get('channel_id'));//'213';
            provision_detail.dealer_id = DealerCodeStr.toUpperCase();//[select id, DealerCode__c from User where Id =: UserInfo.getUserId() limit 1].DealerCode__c;//'51101';
            provision_detail.return_code=''; 
            provision_detail.return_code_message='';            
    
        } 
        
        public RequestResponseController parse(String json){
            return (RequestResponseController) System.JSON.deserialize(json, RequestResponseController.class);
        }
        
    }
    
      private static boolean returnError(Map < String, Object > outMap, String key, object msg) {
        outMap.put(key, msg);
        outMap.put('processError', 'true');
        return false;
    }
    
    
    public class enlarge_pp_socs {
        public soc[] soc;
    }
    public class soc {
        public String soc_name; //string
        public String effective_date;   //string
        public String expiration_date;  //string
        public String srv_mode; //string
    }
    public class parameters {
        public String param1;   //string
        public String param2;   //string
        public String param3;   //string
    }
    
        public class provisionDetail {
        public String prov_code;    //string        
        public String reply_code;   //string        
        public String subscriber_number;    //string
        public String comm_code;    //string
        public String channel_id;   //string
        public String dealer_id;    //string
        public String return_code;  //string
        public String return_code_message;  //string
    
    }
    
    
    public static Boolean CheckIdentificationNumberValueValidity(string identificationValue){
        Integer sum, mul, tmp, i, result;
        sum = 0;
        mul = 1;
    
        Pattern r = Pattern.compile('[0-9]{5,9}');
        Matcher m = r.matcher(identificationValue);
        if(!m.matches())
            return false;
        
        if (identificationValue.length() < 4 || identificationValue.length() > 9)
            return false;
    
        if (identificationValue.length() < 9)
            identificationValue = AddLeadingZero(identificationValue);
        
        system.debug('>>> ' + identificationValue);
        for (i = 0; i <= (identificationValue.length() - 2); i++){
            //system.debug('>>> ' + identificationValue.Substring(i, i+1));
            tmp = mul * Integer.ValueOf(identificationValue.Substring(i, i+1));
            if (tmp > 9)
                tmp -= 9;
    
            sum += tmp;
            mul = 3 - mul;
        }
    
        sum = math.mod(sum,10);
        result = 10 - sum;
        if (result == 10)
            result = 0;
        
        //system.debug('>>> result: ' + result);
        //system.debug('>>> identificationValue.Substring(i, i+1): ' + identificationValue.Substring(i, i+1));
        
        if (Integer.ValueOf(identificationValue.Substring(i, i+1)) != result)
            return false;
    
        return true;
    }
    
    
    private static string AddLeadingZero(string idn){
        Integer i;
        string tmp;
        tmp = '0';
        for (i = 1; i < (9 - idn.length() - 1); i++){
           tmp += '0';
        }
        return tmp + idn;
    }
    
    
}