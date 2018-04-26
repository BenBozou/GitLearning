/**
* Service for Inboud Integrations
* author: Tal Sabati
* @class InboundWebserviceIVR
* Taskid PLR-694
* @module 360
*    
*    endpoint : /services/apexrest/inboundWebservice/InteractionEvent/setCallEvent
*    Request Body:   
	    {
	      "userIdentifier" : "talSab",              
	      "contactIdentifier": "testCon",           
	      "accountIdentifier" : "testAccount",          
	      "phoneNumber" : "0542211311",                    
	      "customeSegment" : "customeSegment",              
	      "callOrigin" : "callOrigin",              
	      "sharingAgrement" : "true",           
	      "PaymentIdentifier" : "paymentIdentifier",            
	      "PaymentIdentifierRelatedEntity" : "paymentIdentifierRelatedEntity",
	      "CallPurpose" : "CallPurpose"
	    }
*/ 

public with sharing class InboundWebserviceInteractionEvent implements inboundWebservice.InboundWebserviceInterface {
	private Account account;
	private Contact contact;
    private AccountContactRelation accConRelation;
    private list<Lead> leadList;
    private ConsoleService console;
    
	/**
	*   Method for handling calls to that service
	*   @method handle
	*   @param {RestRequest} request 
	*   @param {inboundWebservice.InboundRestResponse} result 
	*   @return void
	*/
	public void handle(RestRequest request, inboundWebservice.InboundRestResponse result) { 
	    try{
	        String jsonReq = request.requestBody.toString();
	        Map<String, Object> objReq = (Map<String, Object>) JSON.deserializeUntyped(jsonReq);
	        if(result.requestedAction == 'setCallEvent'){
	            setCallEvent(objReq, result);
	        }else{
	            setResultError('Incorrect Service',2,result);
	        }
	    }catch(Exception ex){
	        setResultError('Exception ' + ex.getStackTraceString(),99,result);
	    }
	}
	
	/**
	*   Method for retrieving popup screen for specific agent
	*   @method openScreenByParams
	*   @param {Map<String, Object>} objReq
	*   @param {inboundWebservice.InboundRestResponse} result 
	*   @return void
	*/
	private void setCallEvent(Map<String, Object> objReq, inboundWebservice.InboundRestResponse result){
	    String federationId = String.valueOf(objReq.get('userIdentifier'));
	    User user = getUserFederationId(federationId);
	    if(user == null){
	        setResultError('Invalid User', 3, result);
	        return; 
	    }
	    setConsoleService(objReq, user);
        if(console.openUrl()){
        	result.response = console.getOpenScreenName() + '-' + console.getInteractionEventId();
        }
        else{
        	setResultError('Exception - Create Agent Work',99,result);
        }
	}
	
	/**
	*   The method set Console Service according to the parameters in the request
	*   @method setConsoleService
	*   @param {Map<String, Object>} objReq
	*   @param {User} user 
	*   @return void
	*/
	private void setConsoleService(Map<String, Object> objReq, User user){ 
	    setObjectbyRequestData(objReq);
	    setUrlByAccountOrContact(objReq, user);
	    if(console == null){
	        setUrlByLead(objReq, user);
	    }
	}
	
	/**
	*   The method set accountRecordtypeSet, account, contact and lead by the request
	*   @method setObjectbyRequestData
	*   @param {Map<String, Object>} objReq
	*   @return void
	*/
	private void setObjectbyRequestData(Map<String, Object> objReq){
		string accountIdentifier = String.valueOf(objReq.get('accountIdentifier'));
		string contactIdentifier = String.valueOf(objReq.get('contactIdentifier'));
		string customerSegment = String.valueOf(objReq.get('customeSegment'));
		string phoneNumber = String.valueOf(objReq.get('phoneNumber'));
		set<String> accountRecordtypeSet = new set<String>{'Consumer', 'Business'};
		
		if(customerSegment == 'B2B'){
			accountRecordtypeSet = new set<String>{'Business'};
		}
		else if(customerSegment == 'B2C'){
			accountRecordtypeSet = new set<String>{'Consumer'};
		}
		
        if(accountIdentifier != '' && contactIdentifier != '' && accountIdentifier != null && contactIdentifier != null){
            getAccConRelationByExternalId(accountIdentifier, contactIdentifier, accountRecordtypeSet);
        }
        else{
        	if(accountIdentifier != '' && accountIdentifier != null){
                getAccountByExternalId(accountIdentifier, accountRecordtypeSet);
            }
            if(contactIdentifier != '' && contactIdentifier != null){
                getContactByExternalId(contactIdentifier, accountRecordtypeSet);
            }
        }
    	if(phoneNumber != '' && phoneNumber != null){
			getLeadByphoneNumber(phoneNumber);
        }
	}
	
	/**
	*   The method set Console Service by the phone parameter
	*   @method setUrlByLead
	*   @param {Map<String, Object>} objReq
	*   @param {User} user 
	*   @return void
	*/
	private void setUrlByLead(Map<String, Object> objReq, User user){
	    system.debug('## leadList ' + leadList);
	    
	    if(leadList == null || leadList.isEmpty()){
	    	system.debug('## leadList isEmpty ');
	        setInformation(objReq, user, '/apex/SearchScreen', System.Label.SearchScreenTabName, null, null, null, CustomMetadataTypeService.getCrmVariable('SearchScreenTabName'), false);
	    }
	    else if(leadList.size() == 1){
	    	system.debug('## size 1 ');
	        string url = '/apex/LeadScreen?id=' + leadList[0].id;
	        setInformation(objReq, user, url , System.Label.LeadScreenTabName, null, null, leadList[0].id, CustomMetadataTypeService.getCrmVariable('LeadScreenTabName'), false);
	    }
	    else if(leadList.size() > 1){
	    	system.debug('## size > 1 ');
	        setInformation(objReq, user, '/apex/SearchScreen', System.Label.LeadSearchScreenTabName, null, null, null, CustomMetadataTypeService.getCrmVariable('LeadSearchScreenTabName'), false);
	    }
	}
	/**
	*   The method set Console Service by account and contact parameters
	*   @method setUrlByAccountOrContact
	*   @param {Map<String, Object>} objReq
	*   @param {User} user 
	*   @return void
	*/
	private void setUrlByAccountOrContact(Map<String, Object> objReq, User user){
        if(accConRelation != null){
            string url = '/' + accConRelation.AccountId + '?contactId=' + accConRelation.ContactId;
            setInformation(objReq, user, url , accConRelation.Account.Name, accConRelation.AccountId, accConRelation.ContactId, null, CustomMetadataTypeService.getCrmVariable('MainScreen360TabName'), false);
        }
        else if(account != null && contact != null){
        	setInformation(objReq, user, '/apex/SearchScreen', System.Label.SearchScreenTabName, null, null, null, CustomMetadataTypeService.getCrmVariable('SearchScreenTabName'), true);
        }
        else if(account != null && contact == null){
            if(account.AccountContactRelations.isEmpty()){
            	setInformation(objReq, user, '/apex/SearchScreen', System.Label.SearchScreenTabName, null, null, null, CustomMetadataTypeService.getCrmVariable('SearchScreenTabName'), true);
            }
            else if(account.AccountContactRelations.size() == 1){
                string url = '/' + account.Id + '?contactId=' + account.AccountContactRelations[0].ContactId;
                setInformation(objReq, user, url , account.Name, account.Id, account.AccountContactRelations[0].ContactId, null, CustomMetadataTypeService.getCrmVariable('MainScreen360TabName'), false);
            }
            else if(account.AccountContactRelations.size() > 1){
                setInformation(objReq, user, '/apex/SearchScreen', System.Label.ContactSearchScreenTabName, account.Id, null, null, CustomMetadataTypeService.getCrmVariable('ContactSearchScreenTabName'), false);
            }
        }
        else if(account == null && contact != null){
            if(contact.AccountContactRelations.isEmpty()){
            	setInformation(objReq, user, '/apex/SearchScreen', System.Label.SearchScreenTabName, null, null, null, CustomMetadataTypeService.getCrmVariable('SearchScreenTabName'), true);
            }
            else if(contact.AccountContactRelations.size() == 1){
                string url = '/' + contact.AccountContactRelations[0].AccountId + '?contactId=' + contact.Id;
                setInformation(objReq, user, url, contact.AccountContactRelations[0].Account.Name, contact.AccountContactRelations[0].AccountId, contact.Id, null, CustomMetadataTypeService.getCrmVariable('MainScreen360TabName'), false);
            }
            else if(contact.AccountContactRelations.size() > 1){
                setInformation(objReq, user, '/apex/SearchScreen', System.Label.AccountSearchScreenTabName, null, contact.Id, null, CustomMetadataTypeService.getCrmVariable('AccountSearchScreenTabName'), false);
            }
        }
	}
	/**
	*   The method set Console Service by account and contact parameters
	*   @method setInformation
	*   @param {Map<String, Object>} objReq
	*   @param {User} user 
	*   @param {string} url
	*   @param {string} tabName         
	*   @param {Id} accountId         
	*   @param {Id} contactId         
	*   @param {Id} leadId         
	*   @param {string} openScreen         
	*   @param {Boolean} invalidRquest         
	*   @return void
	*/
	private void setInformation(Map<String, Object> objReq, User user, string url, string tabName, Id accountId, Id contactId, Id leadId, string openScreen, Boolean invalidRquest){
	    console = new ConsoleService(user, url, tabName);
	    string callOrigin = String.valueOf(objReq.get('callOrigin'));
	    string paymentIdentifierRelatedEntity = String.valueOf(objReq.get('PaymentIdentifierRelatedEntity'));
	    string paymentIdentifier = String.valueOf(objReq.get('PaymentIdentifier'));
	    string customerSegment = String.valueOf(objReq.get('customeSegment'));
	    string phoneNumber = String.valueOf(objReq.get('phoneNumber'));     
	    string callPurpose = String.valueOf(objReq.get('CallPurpose'));     
	    Boolean sharingAgrement = false;
	    if(objReq.get('sharingAgrement') != null){
	        sharingAgrement = Boolean.valueOf(objReq.get('sharingAgrement'));
	    }
	    console.setInboundInformation(accountId, contactId, leadId, openScreen, invalidRquest, callOrigin, paymentIdentifierRelatedEntity, paymentIdentifier, customerSegment, phoneNumber, sharingAgrement, callPurpose);                     
	}
	
	/**
	*   Method for getting AccountContactRelation based on externalId of account and contact
	*   @method getAccConRelationByExternalId
	*   @param {string} accExternalId
	*   @param {string} conExternalId
	*   @param {set<String>} accountRecordtypeSet
	*   @return void
	*/
	
	private void getAccConRelationByExternalId(string accExternalId, string conExternalId, set<String> accountRecordtypeSet){
	    list<AccountContactRelation> accConRelationList = [Select Contact.CellcomExternalID__c, ContactId, Account.CellcomExternalID__c, AccountId, Account.Name, IsActive, AccountRecordTypeName__c 
	    												From AccountContactRelation 
	    												where IsActive = true 
	    												and AccountRecordTypeName__c in: accountRecordtypeSet
	    												and Account.CellcomExternalID__c =: accExternalId 
	    												and Contact.CellcomExternalID__c =: conExternalId];
	    																						
	    system.debug('## accConRelation: ' + accConRelationList);
	    if(!accConRelationList.isEmpty()){
	        accConRelation = accConRelationList[0];
	    }
	}
	
	/**
	*   Method for getting account based on externalId
	*   @method getAccountByExternalId
	*   @param {string} externalId
	*   @param {set<String>} accountRecordtypeSet
	*   @return void
	*/
	private void getAccountByExternalId(string externalId, set<String> accountRecordtypeSet){
	    list<Account> accountList = [Select Id, CellcomExternalID__c, Name, RecordType.DeveloperName, 
	    							(Select ContactId, IsActive From AccountContactRelations where IsActive = true) 
	    							From Account 
	    							where RecordType.DeveloperName in: accountRecordtypeSet
	    							and CellcomExternalID__c =: externalId];
	    							
	    system.debug('## accountList: ' + accountList);
	    if(!accountList.isEmpty()){
	        account = accountList[0];
	    }
	}
	/**
	*   Method for getting contact based on externalId
	*   @method getContactByExternalId
	*   @param {string} externalId
	*   @param {set<String>} accountRecordtypeSet
	*   @return void
	*/
	private void getContactByExternalId(string externalId, set<String> accountRecordtypeSet){
	    list<Contact> contactList = [Select Id, CellcomExternalID__c, 
	    							(Select AccountId, Account.Name, AccountRecordTypeName__c From AccountContactRelations where IsActive = true and AccountRecordTypeName__c in: accountRecordtypeSet) 
	    							From Contact 
	    							where CellcomExternalID__c =: externalId];
	    							
	    system.debug('## contactList: ' + contactList);
	    if(!contactList.isEmpty()){
	        contact = contactList[0];
	    }
	}
	/**
	*   Method for getting list of keads based on phone number
	*   @method getLeadByphoneNumber
	*   @param {string} phoneNumber
	*   @return void
	*/
	private void getLeadByphoneNumber(string phoneNumber){
	   phoneNumber = phoneNumber.replaceAll('\\D','');
	   leadList = new list<Lead>();
	   String searchQuery = 'FIND \'' + phoneNumber + '\' IN PHONE FIELDS RETURNING Lead(Name, Phone)';
	   List<List <sObject>> searchList = search.query(searchQuery);
	   for(Lead l : (List<Lead>)searchList[0]){
		   if(l.Phone.replaceAll('\\D','') == phoneNumber){
				leadList.add(l);
		   }
	   }
	   system.debug('## leadList: ' + leadList);
	}
	/**
	*   Method for Applying an application error to the Result
	*   @method setResultError
	*   @param {String} errorMessage
	*   @param {inboundWebservice.InboundRestResponse} result 
	*   @return void
	*/
	private void setResultError(String errorMessage, Integer errorCode, inboundWebservice.InboundRestResponse result){
	    result.statusCode = errorCode;
	    result.statusMessage = errorMessage;
	}  
	/**
	*   Method for getting user based on his federation Id
	*   @method getUserFederationId
	*   @param {String} federationId
	*   @return {User}
	*/
	private User getUserFederationId(String federationId){
		List<User> userList =  [select Id, Name, Username, FederationIdentifier  
		                        from User
		                        where FederationIdentifier =: federationId
		                        limit 1];
		if(userList.isEmpty()){
		    return null;
		}
		return userList[0];
	}

}