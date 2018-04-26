public with sharing class CreateLeadService {
/**
* Service class for handle create Lead logic: 
* To check if Lead / Contact alrady exists in Slesforce or ODATA
* To create lead in ODATA and  create / update in Salesforce
* Eric Fishman
* taskid PLR-805
* @class CreateLeadService
* @module Lead 
*/
       
    
    /**
    * Create Lead 
    * Eric Fishman
    * @method createLead    
    * @param {String} objectName
    * @param {String} recordTypeName
    * @return {Id}
    * @static
    */
     public static  String createLead(String dataBody) {
        
        try{        
       
       
       System.debug('>>>> 100 createLead dataBody ' + dataBody);
        RequestsData requesetData = (RequestsData)JSON.deserialize(dataBody,RequestsData.class);
        
       //TBD LOGIC
        
        GetResultData resultObject = new GetResultData();
        ResultsData rdata = new ResultsData();
        
        GetResult newLeadData = NewLead(requesetData.RequestLineList[0]);
             
        
        rdata.phone =  newLeadData.detail.get('phone');         
        rdata.SequenceId = newLeadData.detail.get('LeadId');   
        
        
        resultObject.resultsDataList = new List<ResultsData>{rdata}; 
        return JSON.serialize(resultObject);
        }
        catch (Exception e) {
            System.debug('>>>> 30 createLead Exception: ' + e + ' from: ' + e.getStackTraceString());
                
            return null;
        }  
        
    } 
    
    
/**
    * Method to create new Lead in Salesforce and in Odata  
    * Eric Fishman
    * @method NewLead   
    * @param {RequestLine} cardLine 
    * @return {Srring}
    * @static
    */        
 public static GetResult NewLead(RequestLine line){
        
        Lead lead = new Lead ();
         try{           
            
            System.debug(' NewLead Input LINE :' + line);   
            
            GetResult resultData = new GetResult();
            resultdata.isExist = true;
            resultdata.detail = new Map<String, String>();
            // Get Record Type
            Id leadrecordType = RecordTypeService.getRecordTypeIdByName('Lead',line.recordType);    
            lead.RecordTypeId = leadrecordType;         
            lead.phone =  line.Phone;           
            lead.lastName  =  line.lastName;
            lead.company  =  (line.recordType=='B2C') ? 'Empty' : line.company;
            lead.description =  line.comments;
            lead.LeadSource = line.leadSource;       
            lead.firstName = line.firstName;
            lead.SourceFriendName__c = line.SourceFriendName;
            lead.SourceOther__c = line.SourceOther;
            lead.Product__c = line.ProductLst; 
             if(line.recordType=='B2B') {
                lead.City__c = line.addressCity;
                lead.Street__c = line.addressStreet;
                lead.Industry = line.lineOfBusiness;
                lead.BranchesAmountForCompany__c = line.branchesAmountForCompany;
                lead.NumberOfEmployees = line.numberOfEmployees;
               // lead.AdditionalInfo__c = line.additionalInfoFormula;
                lead.vlocity_cmt__PremisesId__c = line.LookupPremises;
            }
            
            
            System.debug(' Lead: ' + lead);   
              
            
            Database.SaveResult srInsert = Database.insert(lead);
            System.debug('SaveResult LEAD: ' + srInsert);
            
            if (!srInsert.isSuccess()){
                System.debug('Lead creation failed ');
                // Operation failed, so get all errors                
                for(Database.Error err : srInsert.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
            else{               
                resultdata.detail.put('LeadId',srInsert.getId());
                // Create Lead in ODATA
                 if(!Test.isRunningTest()){
                	createExternalLeadFuture (line.SSN, line.companyNumber,line.OdataType, srInsert.getId() );
                //createExternalLead (line,srInsert.getId());
                 }
                
            }
                        
            return resultdata;
            
          }
        catch (Exception e) {
            System.debug('SaveResult LEAD Exception: ' + e +' from: ' + e.getStackTraceString());
            return null;
        }
        
    
 }   
 
 
 @future (callout=true)
 public static void createExternalLeadFuture(String ssn, String companyNumber, 
 										String odataType, string leadId) {    
       try {
            Database.SaveResult sr;
            Leads__x leadX = new Leads__x();
            leadX.ssn__c= ssn;        
            leadX.company_number__c = companyNumber;         
            leadX.transactionId__c = leadId;
            leadX.id_type_sf__c = odataType == null ? 'I' : odataType;         
            
            System.debug(' NewLead IDATA leadX :' + leadX);   
            if(!Test.isRunningTest()) {
                sr = Database.insertImmediate(leadX);
            } else {
                String prefix = Leads__x.sobjecttype.getDescribe().getKeyPrefix();
                sr = (Database.SaveResult) JSON.deserialize('{"id":"' + prefix + '4E00000UCHL2QAP","success":true,"errors":[],"warnings":[]}', Database.SaveResult.class);
            }
            
            System.debug('ODATA SaveResult :' + sr);
            
            if (!sr.isSuccess ()) {            
                System.debug('ODATA Error to create it synchronically.' );
                }
            else
            {	Leads__x leadXUpdate;
                System.debug('>>>> 10 External SequenceID: ' + sr.getId());
                String xId = sr.getId();
                
                // Get External record to get OSB Sequence ID
                if(Test.isRunningTest()) {
                    leadXUpdate = new Leads__x(sequence_id__c = '5454646', transactionId__c = '4564654654');
                } else {
                    leadXUpdate =  [select sequence_id__c, transactionId__c from Leads__x where Id =:xId limit 1];
                }
            	
            	if (leadXUpdate !=null){      			
	      			// Update Lead record with Cellcom External ID
	      			updateLeadCellcomId(leadXUpdate, leadId);
      			}   
            	
                // Invoke method to create External Lead                                
            }

 		}
        catch (Exception e) {
             System.debug('createExternalLeadFuture error: ' + e.getmessage() + ' , ' + e.getStackTraceString() );
            
        }   
 }
 
 
  
    /**
    * Method to create External Lead 
    * Eric Fishman
    * @method createExternalLead    
    * @param {String} Phones    
    * @return {Srring}
    * @static
    */    
   
 public static void createExternalLead(RequestLine line, Id leadId) {
  
        try{
            
            Leads__x leadX = new Leads__x();
            // Removed from ODATA 
            /*
            //leadX.first_name__c = line.firstName; // (String)inputMap.get('First Name'); //firstName;         
            //leadX.last_name__c=  line.lastName; //line.LastName; //(String)inputMap.get('Last Name');//lastName;
            //leadX.company_name__c= line.companyName;
            */ 
            leadX.ssn__c= line.SSN;//(String)inputMap.get('Ssn'); // ssn;           
            leadX.company_number__c = line.companyNumber; //'12313123';         
            leadX.transactionId__c = leadId;
            leadX.id_type_sf__c = line.OdataType == null ? 'I' : line.OdataType;         
            
            System.debug(' NewLead IDATA leadX :' + leadX);   
            
            OdataSaveCallBackService callback = new OdataSaveCallBackService();
            
            //Database.SaveResult sr = Database.insertAsync(leadX, callback);
            Database.SaveResult sr;
             if(!Test.isRunningTest()){            
            	 sr = Database.insertImmediate(leadX);
             }
            
            System.debug('ODATA SaveResult :' + sr);
            //String locator = Database.getAsyncLocator ( sr );             
            //System.debug('External locator:' + locator);                
            //System.debug('External getAsyncSaveResult:' + Database.getAsyncSaveResult(sr));   
            
            
            if (!sr.isSuccess ()) {            
                System.debug('ODATA Error to create it synchronically. The process is in a queue' );
                }
            else
            {
                System.debug('>>>> 10 External SequenceID: ' + sr.getId());
                String xId = sr.getId();
                // Get External record to get OSB Sequence ID
            	Leads__x leadXUpdate =  [select sequence_id__c, transactionId__c from Leads__x where Id =:xId limit 1];
            	
            	if (leadXUpdate !=null){      			
	      			// Update Lead record with Cellcom External ID
	      			updateLeadCellcomId(leadXUpdate, leadId);
      			}   
            	
                // Invoke method to create External Lead                                
            }
            
        }
        catch (Exception e) {
             System.debug('createExternalLead error: ' + e.getmessage() + ' , ' + e.getStackTraceString() );
            
        }            
    } 
    
    /**
    * Method updates lead status in oData
    * Nikolay Iliaev
    * @method updateOdataLeads  
    * @param {String} externalId
    * @return {void}*     
    * @module Lead 
    */  
    public static void updateOdataLeads(String externalId, RequestLine line){
        OdataLeadUpdateCallBackService callback = new OdataLeadUpdateCallBackService();
        
        System.debug(LoggingLevel.ERROR,'externalId: ' + externalId + ' line: ' + line);
        
        Leads__x[] leadX = [SELECT Id FROM Leads__x WHERE ExternalId  = : externalId LIMIT 1]; 
        
        if(Test.isRunningTest()) {
            leadX.add(new Leads__x (ExternalId = '45465456')); 
        }
        
        if(!leadX.isEmpty()) {
            leadX[0].ssn__c = line.SSN;
            leadX[0].company_number__c = line.companyNumber;
            
             if(!Test.isRunningTest()){
            	Database.updateImmediate(leadX[0]);
             }
            //Database.updateAsync(leadX, callback);
            
        }
    }
    
    
    
    /**
    * Method to create External Lead 
    * Eric Fishman
    * @method updateOdataLeadsFuture    
    * @param {String}     
    * @return {Srring}
    * @static
    */    
 /*
  @future (callout=true)
 public static void updateOdataLeadsFuture(String externalId, String ssn, String companyNumber) {    
       try {
       	
       System.debug(LoggingLevel.ERROR,'externalId: ' + externalId);
        
        Leads__x leadX = [SELECT Id FROM Leads__x WHERE ExternalId  = : externalId limit 1];        
        
        if(leadX != null) {
            leadX.ssn__c = ssn;
            leadX.company_number__c = companyNumber;
            
            Database.updateImmediate(leadX);
            //Database.updateAsync(leadX, callback);
        }
       	
       }
       catch (Exception e) {
             System.debug('createExternalLeadFuture error: ' + e.getmessage() + ' , ' + e.getStackTraceString() );
            
        }   
    
    */
    
    /**
    * Find Lead / Account by company number in ODATA and return Salesforce Lead / Account record 
    * Nikolay Iliaev 
    * @method isExsitLeadAccountCN 
    * @param {String} CN    
    * @return {sObject} sObject    
    */
    public static Id isExsitLeadAccountCN(String inCN){
         String companyNum  = inCN;            
          
         List<AccountKeys__x> accXlist = new List<AccountKeys__x>();
         if(Test.isRunningTest()) {
            accXlist.add(new AccountKeys__x(id_number__c='111',cellcom_id__c='111'));
         }
         else {
            accXlist = [Select Id, cellcom_id__c, id_number__c From AccountKeys__x where id_number__c =:companyNum limit 1];
         }
         
         if (!accXlist.isEmpty() || Test.isRunningTest()) {
             // Find account in Salesforce by Odata ID
             List<Account> acclist = new List<Account>();
             acclist = [select Id from Account where CellcomExternalId__c =:accXlist[0].cellcom_id__c];
                         
            if (!acclist.isEmpty()) {
                return acclist[0].Id; 
            }         
         }
         return null;
        /*
         // Account not found, we should search in lead
            List<Leads__x> leadXlist = new List<Leads__x>();
            if(Test.isRunningTest()) {
                leadXlist.add(new Leads__x(company_number__c='111', sequence_id__c='OB0000025'));
            }
            else {
                leadXlist = [Select Id, sequence_id__c ,company_number__c From Leads__x where company_number__c =:companyNum limit 1];
            }
                
            if (!leadXlist.isEmpty() || Test.isRunningTest()) {          
                // Find the lead In Salesforce in order to return to OmniScript
                List<Lead> leadData = new List<Lead>();     
                leadData = [Select Id, Phone, AccountId__c, LeadSource From Lead where CellcomExternalID__c =:leadXlist[0].sequence_id__c limit 1];           
                if (!leadData.isEmpty()){
                    return leadData[0].AccountId__c;
                }
                               
            }*/
    return null;
}
    
    /**
    * Find Lead / Contact by SSN in ODATA and return Salesforce Lead / Contact record 
    * Eric Fishman 
    * @method isExsitLeadContactSSN 
    * @param {String} inSsn    
    * @return {sObject} sObject    
    */
    public static sObject isExsitLeadContactSSN(String inSsn){
         //Boolean isContactExist = false;           
         String ssn  = inSsn;            
          
         List<ContactKeys__x> conXlist = new List<ContactKeys__x>();
         if(Test.isRunningTest())
            conXlist.add(new ContactKeys__x(cellcom_id__c='notExistInSFDC'));
         else
            conXlist = [Select cellcom_id__c ,Id, id_number__c From ContactKeys__x where id_number__c =:ssn limit 1];
         
         system.debug('conXlist: ' +conXlist);
         system.debug('conXlist: ' +conXlist.size());
         
         if (!conXlist.isEmpty() || Test.isRunningTest()){
             system.debug('conlist: ' +conXlist);            
             // Find Contact in Salesforce by Odata ID
             List<Contact> conlist = new List<Contact>();
             conlist = [select Id,AccountId from Contact where CellcomExternalId__c =:conXlist[0].cellcom_id__c];
             system.debug('conlist: ' +conlist);
                         
            if  (!conlist.isEmpty()) {
                    return conlist[0]; 
            }         
         }
          return null;
        /*
         // Contact not found, we should search in lead
            List<Leads__x> leadXlist = new List<Leads__x>();
            if(Test.isRunningTest())
                leadXlist.add(new Leads__x(sequence_id__c='notExistInSFDC'));
            else
                leadXlist = [Select sequence_id__c From Leads__x where ssn__c =:ssn limit 1];
                
            system.debug('leadXlist: ' + leadXlist);
            
            if (!leadXlist.isEmpty() || Test.isRunningTest()){          
                // Find the lead In Salesforce in order to return to OmniScript
                List<Lead> leadData = new List<Lead>();     
                leadData = [Select Id, Phone, LeadSource, AccountId__c From Lead where CellcomExternalID__c =:leadXlist[0].sequence_id__c limit 1];           
                if (!leadData.isEmpty()){
                    return leadData[0];
                }               
         
    }*/
    return null;
}
 

/**
    * Find Lead / Contact by Phone 
    * Eric Fishman
    * @method isExsitLeadContact 
    * @param {String} cli    
    * @return {sObject} sObject    
    */
    /*
    public static sObject isExsitLeadContact(String cli){
         Boolean isContactExist = false;         
         String phoneNumber  = cli;
         SObject leadContact = null; 
         List<Contact> conlist = new List<Contact>();
         List<Lead> leadList = new List<Lead>();
                 
         String searchQuery = 'FIND \'' + cli+ '\' IN PHONE FIELDS RETURNING Contact(Id, Phone,AccountId), Lead(Id, Phone) LIMIT 1';
         List<List <sObject>> searchList = search.query(searchQuery);        
         
         conlist = ((List<Contact>)searchList[0]);
         leadList = ((List<Lead>)searchList[1]);
         system.debug('conlist: ' +conlist);
         system.debug('leadList: ' +leadList);
         
         if(!conlist.isEmpty()){        
             leadContact = conlist[0];
         }
         else{
                 if(!leadList.isEmpty()){       
                    leadContact = leadList[0];
             }  
         }
         
         return leadContact;
         
         
         if (!conlist.isEmpty()){
        
         conlist = ((List<Contact>)searchList[0]);
             
         system.debug('conlist: ' +conlist);
         
         if (!conlist.isEmpty()){
             system.debug('conlist: ' +conlist);
             isContactExist = true;         
             return conlist[0];
         }
        
        if (!isContactExist){
        
            List<Lead> leadData = new List<Lead>();     
            leadData = [Select Id, Phone, LeadSource From Lead l where l.Phone =:phoneNumber limit 1];
            system.debug('leadData: ' +leadData);
                         
            if  (leadData.isEmpty()){               
                return null;
             }
             else{
                return leadData[0];
             }               
        }
        
        
        
   }
   
*/   
   
   /**
    * Find Unica Lead / by Phone PLR-1185
    * Eric Fishman
    * @method FindExistingUnicaLead 
    * @param {List<String>} leadPhoneIdMap    
    * @return {sObject} sObject    
    */
    public static sObject FindExistingUnicaLead(Map<String, Id> leadPhoneIdMap){
         Boolean isContactExist = false;         
         List<Lead> unicaLeadToDeleteList = new List<Lead>();
         List<Lead> newLeadToUpdateList = new List<Lead>();
         
         List<Lead> leadList = new List<Lead>();        
        
        //string allstring = '\'' + string.join(new List<String>(leadPhoneIdMap.keySet()),' OR ') + '\'';
        //system.debug('>>>>allstring' + allstring); 
                 
         //String searchQuery = 'FIND ' + allstring + ' IN PHONE FIELDS RETURNING Lead(Id, Phone where LeadSource = \'LSO13\' and Status=\'LST01\')';
           
         //system.debug('searchQuery: ' +searchQuery);         
         
         //List<List <sObject>> searchList = search.query(searchQuery);        
         //system.debug('searchList: ' +searchList);       
         
         //leadList = ((List<Lead>)searchList[0]);         
         //system.debug('leadList: ' +leadList);
         
         for(Lead leadUnica : [SELECT Id, Phone FROM Lead WHERE (LeadSource='LSO13') AND (Status='LST01') AND Phone IN : leadPhoneIdMap.keySet()]) {
            if (leadPhoneIdMap.containskey(leadUnica.Phone)){
                unicaLeadToDeleteList.add(leadUnica);               
                // collect new created leads to update original leads
                Lead newLead = new Lead(id=leadPhoneIdMap.get(leadUnica.Phone), OriginalLeadSource__c = Label.LeadOriginalLeadSource); // /*'Unica
                newLeadToUpdateList.add(newLead);
            }           
         }
         
         // Delete Unica Leads
         system.debug('unicaLeadToDeleteList: ' +unicaLeadToDeleteList);
         if (!unicaLeadToDeleteList.isEmpty()){
            DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.DELETE_ACTION,unicaLeadToDeleteList,false);
         }
         
         // update Original Lead Source in new leads
         if (!newLeadToUpdateList.isEmpty()){
            DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION,newLeadToUpdateList,false);
         }
         
         
         return null;
    }
    
    
    
      /**
    * Method to update Lead with Cellcom external Id
    * Eric Fishman
    * @method updateLeadCellcomId	
	* @param {SaveResult} sr
	* @return {void}*     
    * @module Lead 
*/	    
    public static void updateLeadCellcomId(Leads__x leadX, Id leadId){
    	
        List<Lead> leadList = new List<Lead>();
        System.debug(LoggingLevel.ERROR,'>>>> callback leadX: ' + leadX );
        //Lead lead = [select Id, CellcomExternalID__c from Lead where ID =:leadX.transactionId__c limit 1];
        
       
        
        if (leadId != null){
        	 Lead lead = new Lead (Id=leadId,CellcomExternalID__c=leadX.sequence_id__c);
        	//lead.CellcomExternalID__c =  leadX.sequence_id__c;        	
        	update lead;        	
        }
    }
    
    
    /**
    /* Method updates lead status in oData
    /* the method will recived ח.פ + account externaID 
	/* this method should check if  ח.פ already exsist in case it dosent exsits it shoul update the  account odata "ח.פ"
 
    * Eric Fishman
    * @method updateOdataLeads  
    * @param {String} externalId
    * @return {void}*     
    * @module Lead 
    */  
    public static void updateOdataAccounts(String externalId, String companyNumber){                
        //System.debug(LoggingLevel.ERROR,'externalId: ' + externalId + ' line: ' + line);
        
        List<AccountKeys__x> accXlist = new List<AccountKeys__x>(); 
        if(Test.isRunningTest()) {
            accXlist.add(new AccountKeys__x(id_number__c='111',cellcom_id__c='111'));
         }
         else {
            accXlist = [Select Id, cellcom_id__c, id_number__c From AccountKeys__x where ExternalId =:externalId limit 1];
         }
         
         if(!accXlist.isEmpty()) {            
            accXlist[0].id_number__c = companyNumber;
            
	         if(!Test.isRunningTest()){
	         	Database.updateImmediate(accXlist[0]);
	         }  
    	}    
    }
    
    

/**
    * The method create GUID using crypto algorithm
    * Tal Sabati
    * taskid PLR-805
    * @method createGUID
    * @return {String} GUID
    */
    /*
    private static string createGUID(){
        String result = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));
        string GUID = result.substring(0,8) + '-' + result.substring(8,12) + '-' + result.substring(12,16) + '-' + result.substring(16,20)+ '-' + result.substring(20);
        system.debug('GUID: ' + GUID);
        return GUID;
    } 
    
    */   
    
/**
    * Class helper to get Lead data as a structure
    * Eric Fishman    
    * taskid PLR-805
    * @class CreateLeadService
    * @module Lead 
*/
 public class GetResultData{
     
      public Integer errorCode;
      public String errorMessage;
      public String timeStamp;
      public list<ResultsData> resultsDataList;  
 }
    public class ResultsData{
        public String sequenceId;
        public String phone;
        public String comanyNumber;
    }
    
    public class RequestsData{
       public String timeStamp;
       public RequestsData(String timeStamp)
       {
           this.timeStamp = timeStamp;
           this.RequestLineList = new List<RequestLine>();
       }
        public list<RequestLine> RequestLineList;
    }  
        
    
     public class RequestLine{
       public RequestLine(String Action,String firstName,
        String lastName, String OdataType, String ssn, String phone, 
        String company, String companyNumber, String comments, String leadSource,
        String addressCity, String addressStreet, String lineOfBusiness,
        Integer branchesAmountForCompany, Integer numberOfEmployees, String additionalInfoFormula,
        string LookupPremises,string SourceFriendName,string SourceOther,string ProductLst, String recordType){
           this.Action=Action;
           this.firstName=firstName;
           this.lastName=lastName;
           this.OdataType=OdataType;
           this.ssn=ssn;
           this.phone=phone;
           this.company=company;
           this.companyNumber=companyNumber;
           this.comments=comments;
           this.leadSource=leadSource;
           this.addressCity=addressCity;
           this.addressStreet=addressStreet;
           this.lineOfBusiness=lineOfBusiness;
           this.branchesAmountForCompany=branchesAmountForCompany;
           this.numberOfEmployees=numberOfEmployees;
           this.additionalInfoFormula=additionalInfoFormula;
           this.LookupPremises=LookupPremises;
           this.SourceFriendName=SourceFriendName;
           this.SourceOther=SourceOther;
           this.ProductLst=ProductLst;
           this.recordType=recordType;
        }
       public String Action;
       public String firstName;
       public String lastName;
       public String OdataType;
       public String ssn;
       public String phone;
       public String company;
       public String companyNumber;
       public String comments;    
       public String leadSource;
       public String addressCity; 
       public String addressStreet; 
       public String lineOfBusiness; 
       public Integer branchesAmountForCompany; 
       public Integer numberOfEmployees; 
       public String additionalInfoFormula;
       public String LookupPremises;
       public String SourceFriendName;
       public String SourceOther;
       public String ProductLst;
       public String recordType;            
    }
    
    public class GetResult{
        public Boolean isExist;
        public map<String,String> detail;
    }
        
    
    
}