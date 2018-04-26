/**
* Service class for AssigmentTabletoUsers controller
* Nikolay Iliaev
* taskid PLR-1078
* @class ManagerScreenService
* @module Lead
* @constructor 
*/
public with sharing class ManagerScreenService {
    
    public ManagerScreenService() {
    	
    }
    /**
    * Method updates leads (B2B)
    * Nikolay Iliaev
    * @method getLeads
    * @param {Map<Id,Integer>} userIdAndQuantityMap
    * @param {Map<Id,UserSkill__c>} userIdUserSkillObjectMap
    * @return {void}*     
    * @module Lead
     public static void updateLeads(Map<Id,Integer> userIdAndQuantityMap, Map<Id,UserSkill__c> userIdUserSkillObjectMap) {
    */
    
    public static void updateLeads(Map<Id,Integer> userIdAndQuantityMap, String userIdUserSkillObjectMap1) {
    	ManagerScreenService.updateLeadsGlobal(userIdAndQuantityMap, userIdUserSkillObjectMap1);
    }
    
    @future
    public static void updateLeadsFuture(Map<Id,Integer> userIdAndQuantityMap, String userIdUserSkillObjectMap1) {
    	ManagerScreenService.updateLeadsGlobal(userIdAndQuantityMap, userIdUserSkillObjectMap1);
    }
    
    public static void updateLeadsGlobal(Map<Id,Integer> userIdAndQuantityMap, String userIdUserSkillObjectMap1) {
    	Map<Id,UserSkill__c> userIdUserSkillObjectMap = (Map<Id,UserSkill__c>) JSON.deserialize(userIdUserSkillObjectMap1,Map<Id,UserSkill__c>.class);
    	List<Lead> leadUpdateList = new List<Lead>();
		Set<Id> productIdSet = new Set<Id>();
		Map<Id,List<Id>> accIdUserIdListMap = new Map<Id,List<Id>>();
		Map<Id,Set<Id>> userIdGroupIdSetMap = new  Map<Id,Set<Id>>();
		Map<Id,List<Id>> userIdAccIdMap = new Map<Id,List<Id>>();
		Map<Id,List<Account>> userIdAccObjListMap = new Map<Id,List<Account>>();
		Boolean isGet = false;
		
		try {
			
		Id queueId = [SELECT QueueId  FROM QueueSobject WHERE Queue.DeveloperName = 'POLM_Business' LIMIT 1].QueueId;
        
		//populate product id set 
		for(UserSkill__c userSkillItem : userIdUserSkillObjectMap.values()) {
			for(UserSkillProduct__c productItem : userSkillItem.User_Skill_Products__r){
				productIdSet.add(productItem.Product__c);
			}
		}
		
		System.debug(LoggingLevel.ERROR,'userIdAndQuantityMap>>> ' + userIdAndQuantityMap);
		
		//Reset ManagerScreenInd__c in the leads
		List<Lead> resetManagerScreenInd = [SELECT Id, Name,Product__c,AccountId__c,Status,LeadSource 
											FROM Lead 
											WHERE (Status = 'LST01') AND (LeadSource = 'LSO14') 
											AND (ManagerScreenInd__c = true) AND OwnerId IN : userIdAndQuantityMap.keySet()];
		
		
		for(Lead leadItem : resetManagerScreenInd) {
			leadItem.ManagerScreenInd__c = false;
			leadItem.OwnerId = queueId;
		}
										
		try{
			System.debug(LoggingLevel.ERROR,'resetManagerScreenInd>>> ' + resetManagerScreenInd);
			Database.update(resetManagerScreenInd);
		}
		catch(Exception ex){
			system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
          	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+ ex));
		}
		
		List<GroupMember> groupMemberList = [SELECT Id, Group.Name, UserOrGroupId, GroupId FROM GroupMember 
		                                        WHERE UserOrGroupId IN : userIdAndQuantityMap.keySet()];
		
		
		//get all groups for all users  
		for(Id userId : userIdAndQuantityMap.keySet()) {
            Set<id> groupSet = new Set<id>();
            for(GroupMember member : groupMemberList) {
                if(member.UserOrGroupId == userId) {
                    groupSet.add(member.GroupId);
                }
            }
		    userIdGroupIdSetMap.put(userId,groupSet);
		}
		//Populate id set with user id and group id
		Set<Id> idSet = new Set<Id>();
		idSet.addAll(userIdAndQuantityMap.keySet());
		for(Set<Id> iditem : userIdGroupIdSetMap.values()) {
		    idSet.addAll(iditem);
		}
		
		System.debug(LoggingLevel.ERROR,'idSet>>> ' + idSet);
		
        //get all relevant AccountShare 
		List<AccountShare> accountShareList = [SELECT Id, UserOrGroupId, AccountId 
		                        FROM AccountShare 
		                        WHERE UserOrGroupId IN : idSet
		                        and Account.recordType.DeveloperName = 'Business'];
							   
        
        //Populate map userIdAccIdMap
        for(Id userId : userIdAndQuantityMap.keySet()) {
            List<Id> accList = new List<Id>();
            for(AccountShare accSharItem : accountShareList) {
                //find user id in UserOrGroupId
                if(accSharItem.UserOrGroupId == userId || userIdGroupIdSetMap.get(userId).contains(accSharItem.UserOrGroupId)) {
                    accList.add(accSharItem.AccountId);
                }
            }
            userIdAccIdMap.put(userId,accList);
        }
        
        System.debug('userIdAccIdMap: ' + userIdAccIdMap);
        
	   //populate id set of accounts 
	   Set<Id> accIdSet = new Set<Id>();
	   for(AccountShare accountShareItem : accountShareList) {
	   		accIdSet.add(accountShareItem.AccountId);
	   }
	   
	   //get accounts and leads 
	   List<Account> accList = [SELECT Id, RecordType.Name, 
	   						   (SELECT Id, OwnerId, Name FROM Leads__r WHERE (Product__c IN : productIdSet) AND (AccountId__c <> NULL)
	   						    AND (Status = 'LST01' OR Status = 'LST05') AND (LeadSource = 'LSO14') AND OwnerId = : queueId
	   						    ORDER BY Status DESC, CreatedDate ASC, Score__c DESC)
	   						    FROM Account 
	   						    WHERE Id IN : accIdSet AND (recordType.DeveloperName = 'Business')];
	  
      //List<Lead> leadItem02 = [SELECT Id, OwnerId, Name FROM Lead WHERE AccountId__c =: accList[0].Id]; 
        
	  System.debug('accList: ' + accList);
      //System.debug('leadItem02: ' + leadItem02);
	  //populate map with account id and list of leads and populate userIdAccObjListMap 
	  for(Id userId : userIdAndQuantityMap.keySet()) {
	      List<Account> accObjList = new List<Account>();
	  	 for(Account accItem : accList) {
	  	     for(Id accId : userIdAccIdMap.get(userId)) {
	  	         if(accItem.Id == accId) {
	  	             accObjList.add(accItem);
	  	         }
	  	     }
	  	 }
	     userIdAccObjListMap.put(userId,accObjList);
	  }
	  System.debug('userIdAccObjListMap: ' + userIdAccObjListMap);
	  //find all relevant leads 
	  for(Id idItem : userIdAndQuantityMap.keySet()) {
	  		Integer limitQ = userIdAndQuantityMap.get(idItem);
  			for(Account accItem : userIdAccObjListMap.get(idItem)) {
  				if(limitQ > 0) {
  				    isGet = false;
					for(Lead leadItem : accItem.Leads__r) {
						if(leadItem.OwnerId == queueId) {
						    isGet = true;
							leadItem.ManagerScreenInd__c = true;
							leadItem.OwnerId = idItem;
							leadUpdateList.add(leadItem);
						}
					}
					if(isGet) {
					    limitQ -= 1;
					}
  				}
	  		}
	  }
	   try {
	       
	   		System.debug(LoggingLevel.ERROR,'leadUpdateList>>> ' + leadUpdateList);
	   		Database.update(leadUpdateList);
	   		sendMail(Label.savedSuccessfully);
	   	
	   
	   } catch(Exception ex) {
       		system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
          	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+ ex));
          	sendMail('EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
   		}
    
			
		} catch(Exception ex) {
			system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
          	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+ ex));
          	sendMail('EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
		}
    }
    
    /**
    * Method send mail to current user 
    * Nikolay Iliaev
    * @method sendMail	
    * @return {Void}*     
    * @module Lead
    */
    public static void sendMail(String msg) {
        
        List<Messaging.SingleEmailMessage> mailsToSendList = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
		List<String> toaddressesList = new List<String>();
        
        toaddressesList.add(UserInfo.getUserEmail());
   		mailToSend.setToAddresses(toaddressesList);
   		mailToSend.setSubject('Niko test');
   		mailToSend.setPlainTextBody(msg);
   		mailsToSendList.add(mailToSend);
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailsToSendList);
    }
}