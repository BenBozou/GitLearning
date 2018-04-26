/**
* controller class for FileUploader page.
* Tal Sabati
* taskid PLR-501
* @class FileUploaderController
* @module Leads
* @constructor FileUploaderController
*/

public with sharing class FileUploaderController {

    transient public Blob filebody {get;set;}
    public ExternalAttachment__c externalAttachment {get; set;}
    
    private sobject parentObj;
	private String contextId;
    private String objType;
    private string retURL;
    
    public FileUploaderController(ApexPages.StandardController stdController) {
       
        Integer index = apexpages.currentpage().getparameters().get('retURL').indexOf('id=');
        if(index == -1)
        	index = 1;
        else
        	index += 3;
        contextId = apexpages.currentpage().getparameters().get('retURL').substring(index,index+15);
        retURL = apexpages.currentpage().getparameters().get('retURL');
        setParentObjType();
        if(objType == 'Opportunity' || objType == 'Case')
        	parentObj = Database.query('select Id, AccountId, Account.CellcomExternalID__c from ' + objType + ' where Id= \'' + contextId + '\'');
        externalAttachment = new ExternalAttachment__c();
    }

    /**
    * Tal Sabati
    * taskid PLR-501
    * @method cancel
    * @return {Pagereference} opportunity page
    */
    public Pagereference cancel(){
        return new PageReference(retURL);
     }
    /**
    * The method prepares data for http call,
    * and saves the information in external attachment if success
    * Tal Sabati
    * taskid PLR-501
    * @method upload
    * @return {Pagereference} opportunity page
    */
    public Pagereference upload(){
        map<string,string> inputHeaderMap = createInputHeaderMap();
        map<string,string> inputBodyMap = createInputBodyMap();
        Boolean IsHttpRequestSuccess = ArchiveFilesUploadWebService.ArchiveFilesUpload(filebody, inputHeaderMap, inputBodyMap, externalAttachment, objType.removeEnd('__c') + 'Id__c', contextId);
        if(IsHttpRequestSuccess){
            return new PageReference(retURL);
        }
            
        ApexPages.Message mss = new ApexPages.Message(ApexPages.Severity.ERROR,Label.ArchiveFilesError);
        ApexPages.addMessage(mss);
        return null;
    }
    
    /**
    * The method create map with the parameters of the header xml.
    * Tal Sabati
    * taskid PLR-501
    * @method createInputMap
    * @return {map<string,string>} inputMap
    */
    private map<string,string> createInputHeaderMap(){
        map<string,string> inputHeaderMap = new map<string,string>();
        User currentuser = [Select Id,FederationIdentifier from User where Id=:userinfo.getuserId()];       
        inputHeaderMap.put('From','sf');
        inputHeaderMap.put('To','archive');
        inputHeaderMap.put('UserName', currentuser.FederationIdentifier);
        return inputHeaderMap;
    }
    
    /**
    * The method create map with the parameters of the body xml.
    * Tal Sabati
    * taskid PLR-501
    * @method createInputMap
    * @return {map<string,string>} inputMap
    */
    private map<string,string> createInputBodyMap(){
        map<string,string> inputBodyMap = new map<string,string>();
        if(objType == 'Opportunity' || objType == 'Case'){
        	inputBodyMap.put('ExtSFID', (string) parentObj.getSObject('Account').get('CellcomExternalID__c'));
        	inputBodyMap.put('SFOpportunity', parentObj.Id);
        }
		else{
			inputBodyMap.put('SFOpportunity', contextId);
		}
		inputBodyMap.put('DOC_TYPE', 'T');
		inputBodyMap.put('DOC_BUS_TYPE', '66');
		inputBodyMap.put('LETTER_DATE', '');
        return inputBodyMap;
        
    }
    
    
     /**
    * The method set the Objetct name
    * Eliran shalom
    * taskid PLR-501
    * @method setParentObjType
    * @return {String} objType
    */
    public void setParentObjType()
    {
        objType = ((Id)contextId).getSObjectType().getDescribe().getName();
    }
}