/**
* Util for getting the record access for the running user
* Mohammad Garrah
* taskid 
* @class UserRecordAccessUtil
* @module Leads
* @constructor UserRecordAccessUtil
*/
global without sharing class UserRecordAccessUtil{
    
	global Id recordId;
    global Boolean hasReadAccess 		{get;set;}
    global Boolean hasEditAccess 		{get;set;}
    global Boolean hasTransferAccess 	{get;set;}
    global Boolean hasDeleteAccess 		{get;set;}
    global Boolean hasAllAccess 		{get;set;}
    
    global UserRecordAccessUtil(Id recordId) {
		this.recordId = recordId;
		getUserRecordAccess();
    }
    
    global UserRecordAccessUtil(ApexPages.StandardController stdController) { 
    	this.recordId = ApexPages.currentPage().getParameters().get('id');
    	getUserRecordAccess();
    }
    
    /**
    * Mohammad G.
    * taskid
    * @method getUserRecordAccess
    * @return {UserRecordAccess} current user record access
    */
    public UserRecordAccess getUserRecordAccess(){
    	if(this.recordId == null)	return null;
    	system.debug('>>> RecordId: ' + RecordId);
    	UserRecordAccess recordAccess = [Select RecordId, 
    											HasReadAccess, 
    											HasEditAccess, 
    											HasTransferAccess, 
    											HasDeleteAccess, 
    											HasAllAccess 
    									 From 	UserRecordAccess 
    									 where 	RecordId =: recordId
    									 		and 
    									 		UserId =: UserInfo.getUserId()];
    	system.debug('>>> recordAccess: ' + recordAccess);
    	system.debug('>>> hasReadAccess: ' + recordAccess.hasReadAccess);
    	this.hasReadAccess		= recordAccess.HasReadAccess;
   		this.hasEditAccess		= recordAccess.HasEditAccess;
    	this.hasTransferAccess	= recordAccess.HasTransferAccess;
    	this.hasDeleteAccess	= recordAccess.HasDeleteAccess;
    	this.hasAllAccess		= recordAccess.HasAllAccess;
    	
    	return recordAccess;
    }
}