public without sharing class RequestViewEditComponentController{

    public Request__c req {get;set;}
    public String pageMode {get;set;}
    public Decimal editableRowNumber {get;set;}
    //public Boolean hasEditAccess{get;set;}
    //public String allowedToEdit{get;set;}
    public list<Request__c> childRequests   {get{
                                                    if(childRequests == null){
                                                        system.debug('>>> getchildRequests req.Id: ' + req.Id);
                                                        childRequests = new list<Request__c>([select id, SubStatus__c, Status__c, OwnerId, Approver__c, ApprovalType__c, Note__c, ApprovalSummary__c, Order__c, SLA__c, OppProductId__c from Request__c where ParentRequestId__c =: req.Id order by Order__c ASC]);
                                                        for(Request__c r : childRequests)
                                                            if(r.Status__c == 'In Process'){
                                                                editableRowNumber = r.Order__c;
                                                                break;
                                                            }
                                                    }
                                                    return childRequests;
                                                }
                                                set;
                                            }
    
    public RequestViewEditComponentController(){
        //hasEditAccess = false;
        //system.debug('>>>@@@: ' + req.Category__c);
        //allowedToEdit = UserInfo.getUserId();
        //list<Group> queuesList = [Select GroupId, UserOrGroupId From GroupMember where Group.Type = 'Queue' and UserOrGroupId =: UserInfo.getUserId()];
        //for(Group q: queuesList)
        //  allowedToEdit += ',' + q.UserOrGroupId;
    }
    
    //public list<Request__c> getchildRequests(){
    //  system.debug('>>> getchildRequests req.Id: ' + req.Id);
    //  childRequests = [select id, Status__c, OwnerId, Approver__c, ApprovalType__c, Note__c, ApprovalSummary__c from Request__c where ParentRequestId__c =: req.Id];
    //  return childRequests;
    //}
    
    public PageReference saveRequest(){
        Boolean isChangeOwner = false; 
        //list<Request__c> requestsToUpdate = new list<Request__c>();
        system.debug('>>> Save method' + childRequests);
        if(req.Category__c == 'Commercial'){
            Integer i = 0;
            for(Request__c childReq : childRequests){
                i++;
                system.debug('>>> childReq.Status__c - ' + i + ': ' + childReq.Status__c);
                if(childReq.Status__c == 'In Process'){
                    req.OwnerId = childReq.OwnerId;
                    isChangeOwner = true;
                    break;
                }
                if(childReq.Status__c == 'Approved'){
                    if(childRequests.size() == i){
                        //the last child was approved
                        req.Status__c = 'Approved';
                        req.OwnerId = req.CreatedById;
                        isChangeOwner = true;
                    }
                    continue;
                }
                if(childReq.Status__c == 'Rejected' || childReq.Status__c == 'Edit Details'){
                    //set the same status for the req and assign it to the req creator
                    req.Status__c = childReq.Status__c;
                    req.OwnerId = req.CreatedById;
                    isChangeOwner = true;
                    break;
                }
                if(childReq.Status__c == 'Hold'){
                    childReq.Status__c = 'In Process';
                    if(childReq.SLA__c != null)
                        childReq.DueDate__c = RequestFormController.addWorkingMinutes(Datetime.now(), Integer.valueOf(childReq.SLA__c));
                    req.OwnerId = childReq.OwnerId;
                    isChangeOwner = true;
                    break;
                }
            }
            system.debug('>>> ' + childRequests);
            update childRequests;
            if(String.isNotBlank(req.ProductLineItemId__c))
                update new opportunityLineItem(Id = req.ProductLineItemId__c, CommercialRequestStatus__c = req.Status__c);
        }
        update req;
        if(isChangeOwner){
            shareRequestToCurrentUser();
        }
        return new PageReference('/apex/RequestView?id=' + req.Id);
    }
    
    /**
    * Mohammad G.
    * taskid
    * @method shareRequestToCurrentUser
    * @return {void} 
    */
    private void shareRequestToCurrentUser(){
        list<Request__Share> rShareList = new list<Request__Share>();
        
        //share parent
        rShareList.add(new Request__Share(ParentId = req.Id, UserOrGroupId = UserInfo.getUserId(), AccessLevel = 'Read', RowCause = Schema.Request__Share.RowCause.RequestCreator__c));
        
        //share childs
        if(childRequests != null && childRequests.size() > 0)
        	for(Request__c r : childRequests)
        		rShareList.add(new Request__Share(ParentId = r.Id, UserOrGroupId = UserInfo.getUserId(), AccessLevel = 'Read', RowCause = Schema.Request__Share.RowCause.RequestCreator__c));
        
        list<Database.SaveResult> srList = Database.insert(rShareList,false);
        for(Database.SaveResult sr : srList){
	        if(!sr.isSuccess()){
	            Database.Error err = sr.getErrors()[0];
	            // Check if the error is related to trival access level.
	            // Access level must be more permissive than the object's default.
	            // These sharing records are not required and thus an insert exception is acceptable.
	            if(err.getStatusCode() != StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION || !err.getMessage().contains('AccessLevel'))
	                system.debug(Logginglevel.ERROR,'Faild to share the Request to the creator: ' + err.getMessage());
	        }
    	}
    }
    
    public PageReference EditRequest(){
        return new PageReference('/' + req.Id + '/e');
        return null;
    }
    
    public Boolean getHasEditAccess(){
        list<UserRecordAccess> recordAccessList = [Select RecordId, HasEditAccess
                                                   FROM  UserRecordAccess
                                                   WHERE UserId =: UserInfo.getUserId() and
                                                         RecordId =: req.Id];
        system.debug('>>> ' + recordAccessList);
        if(!recordAccessList.isEmpty() && recordAccessList[0].HasEditAccess){
            return true;
        }
        return false;
    }
    
    /*
    public Boolean getHasViewAccess(){
        list<UserRecordAccess> recordAccessList = [Select RecordId, HasReadAccess
                                                   FROM  UserRecordAccess
                                                   WHERE UserId =: UserInfo.getUserId() and
                                                         RecordId =: req.Id];
        system.debug('>>> ' + recordAccessList);
        if(!recordAccessList.isEmpty() && recordAccessList[0].HasReadAccess){
            return true;
        }
        return false;
    }
    */
    
    public PageReference reSend(){
        for(Request__c childReq : childRequests){
            childReq.Status__c = 'Hold';
            childReq.DueDate__c = null;
        }
        childRequests[0].Status__c = 'In Process';
        if(childRequests[0].SLA__c != null)
            childRequests[0].DueDate__c = RequestFormController.addWorkingMinutes(Datetime.now(), Integer.valueOf(childRequests[0].SLA__c));
        req.Status__c = 'In Process';
        req.OwnerId = childRequests[0].OwnerId;
        update req;
        update childRequests;
        if(String.isNotBlank(req.ProductLineItemId__c))
            update new opportunityLineItem(Id = req.ProductLineItemId__c, CommercialRequestStatus__c = req.Status__c);
        return null;
    }
}