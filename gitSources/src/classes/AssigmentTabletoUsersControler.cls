/**
* Controller class for AssigmentTabletoUsers page
* Nikolay Iliaev
* taskid PLR-444
* @class AssigmentTabletoUsersControler
* @module Lead
* @constructor 
*/
public with sharing class AssigmentTabletoUsersControler {
	public static Savepoint sp;
	public User currentUser;
	public Id currentRoleId;
	public String roleName { get; private set; }
	//show user B2C
	public Boolean isUser { get; set; }
	//User B2B
	public Boolean isUserB2B { get; set; }
	//show RoleUser
	public Boolean isUserRole { get; set; }
	// singular user
	public Boolean isSingUser { get; set; }
	public Decimal quantity { get; set; }
	public String roleId = '';
	public List<WrapperClass> wrapperList { get; set; } 
	public String linkRoleIds { get; private set;}
	public List<Product2> productList = new List<Product2>();
	public List<User> userList = new List<User>();
	public List<UserSkill__c> allSkillsOfUsers;
	public List<UserSkill__c>allUserSkilstoUpdateList;
    public List<User> UsertoUpdateList;
    public List<UserRole> userRoleList;
    public List<Id> userRoleIdList = new List<Id>();
    public List<UserRole> userRoleChildList;
    public List<UserSkill__c> allUserSkillList;
    public List<String> roleAccountIdsList;
	public Map<String,String> titleMap { get; set; }
	public Map<Id,UserSkill__c> userRoleIdUserSkillObjectMap = new Map<Id,UserSkill__c>();
	public Map<Id,UserSkill__c> userIdUserSkillObjectMap = new Map<Id,UserSkill__c>();
	public Map<id, UserRole> pageHeader {get; private set; }
	public Map<Id,List<UserRole>> parentIdChildUserRoleListMap;
   	public Map<Id,List<User>> userRoleIdUserListMap;
   	public Map<Id,UserSkill__c> userIdUserSkillMap;
   	public Map <String,Boolean> leadStatusMap;
   	public static Map<String,String> partnerAccountMap;
   	public OrgSettings__c orgSettings;
   	public List<String> roleIdList { get; set; }
	

    public AssigmentTabletoUsersControler() {
    	OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
    	String tmp = '';
    	this.currentUser = getCurrentUser();
    	this.roleId = ApexPages.currentPage().getParameters().get('roleId');
    	
    	UserRole userRole = this.roleId != null ? getUserRole(this.roleId) : null;
    	
    	roleAccountIdsList = new List<String>();
    	
    	if ( userRole != null && userRole.PortalType == 'Partner') {
				// add first 15 chars - Account ID
				roleAccountIdsList.add(userRole.Name.left(15));
		}
    	
    	partnerAccountMap = new Map<String,String>();		 
		 
	    for (Account account : [select Id, Name from Account where Id in : roleAccountIdsList]) {
	        if (!partnerAccountMap.containsKey(account.Id))
	            partnerAccountMap.put(String.valueof(account.Id).left(15), account.Name);
	    }
    	
    	if (userRole != null && userRole.PortalType == 'Partner') {
    	    userRole.Name = partnerAccountMap.get(userRole.Name.left(15));
    	}
    	
    	if(ApexPages.currentPage().getParameters().get('roles') != null) {
    		tmp = ApexPages.currentPage().getParameters().get('roles');
    		System.debug(LoggingLevel.ERROR,'tmp: ' + tmp);
    	}
    	//remove all roled id in url except of current role id - to prevent grows up url 
		linkRoleIds = roleId == null  ? tmp : tmp.substringBefore(roleId).replaceAll(',$','') ;
		tmp = linkRoleIds;
		this.linkRoleIds += (this.roleId != null && tmp != '') ? ',' + this.roleId : this.currentUser.UserRoleId;
		//title of roles 
		pageHeader =  new Map<id, UserRole> ();
		List <UserRole> userRoleFromUlList = [SELECT Id, Name, PortalType FROM UserRole WHERE Id IN : tmp.split(',')];
		system.debug('>>> pageHeader' + pageHeader);
		
		roleAccountIdsList = new List<String>();
		
		for (UserRole roleItem : userRoleFromUlList) {
		    if (roleItem.PortalType == 'Partner') {
				// add first 15 chars - Account ID
				roleAccountIdsList.add(userRole.Name.left(15));
		    }
		}
		
		for (Account account : [select Id, Name from Account where Id in : roleAccountIdsList]) {
	        if (!partnerAccountMap.containsKey(account.Id))
	            partnerAccountMap.put(String.valueof(account.Id).left(15), account.Name);
	    }
		
		for (UserRole roleItem : userRoleFromUlList) {
		    if (roleItem.PortalType == 'Partner') {
		        roleItem.name = partnerAccountMap.get(userRole.Name.left(15));
		    }
		    pageHeader.put(roleItem.id,roleItem);
		}
		
		system.debug('>>> tmp ' + tmp);
		roleIdList = tmp.split(',');
		system.debug('>>> roleIdList' + roleIdList);
		
		roleName = userRole != null ? userRole.Name : this.currentUser.UserRole.Name;
		
		insertAllData();
    }
    
    /**
    * Method insert all data in VF
    * Nikolay Iliaev
    * @method insertAllData	
    * @return {Void}*     
    * @module Lead
    */
    public void insertAllData(){
        OrgSettings__c orgSettings = OrgSettings__c.getInstance('Org Settings');
		System.debug(LoggingLevel.ERROR,'Top_Role_Name_B2B__c: ' + orgSettings.Top_Role_Name_B2B__c + ' Top_Role_Name_B2C__c: ' + orgSettings.Top_Role_Name_B2C__c);
    	wrapperList = New List<WrapperClass>();
    	
    	//Column Product names
    	titleMap = new  Map<String,String>();
		this.isUserRole = true;
		this.isSingUser = true;
		UserSkill__c userSkill;
        
        //validation to show save button 
		this.isUserB2B = true; //ProfileTypeService.getProfileTypeByName(this.currentUser.Profile.Name) == 'B2B' ? false : true;
		//validation which product to show (B2B or B2C)
        if(ProfileTypeService.getProfileTypeByName(this.currentUser.Profile.Name) == 'B2B') {
       		productList = getProducts(true);
       	} else {
       		productList = getProducts(false);
       	}
        
        this.currentRoleId = this.currentUser.UserRoleId;
        //validaton to check if paramether role id existe in the url
        if(this.roleId != null) {
        	this.currentRoleId = this.roleId;
        }
        //get userRoles 
        userRoleList = getUserRoles(this.currentRoleId);
        System.debug('>>> userRoleList' + userRoleList);
        
        
    	//validation to get users for roles
    	if(userRoleList.isEmpty()) {
    		//Validation to singular user
    		if(this.roleId == null) {
    			this.isSingUser = false;
    			this.userList.add(this.currentUser);
    			UserSkill__c[] userSkillList = getUserSkillWithProductList();
				this.quantity = (!userSkillList.isEmpty()) ? userSkillList[0].Quantity__c : 0;
				userSkill = (!userSkillList.isEmpty()) ? userSkillList[0] : null;
				//
    			if(this.userList.size() > 1) {
    				this.userList.remove(1);
    			}
    		} else {
    			this.userList = getUserByRoleId(this.currentRoleId);
    			userSkill = getUserSkillByRoleId(this.currentRoleId);
				this.quantity = (userSkill != null) ? userSkill.Quantity__c : 0;
    		}
    		this.isUser = true;
            this.isUserRole = false;
			
			if (userSkill != null) {
	            for(Product2 prodItem : productList){
	                for(UserSkillProduct__c productItem : userSkill.User_Skill_Products__r){
	                    if(prodItem.Id == productItem.Product__c){
	                        titleMap.put(prodItem.Name,prodItem.Id);
	                    }
	                }
	            }
	        }
	        
	        UserSkill__c[] userSkillList = getUserSkillWithProductList();
	        //validation to populate userIdUserSkillObjectMap
	    	for (User userItem : userList) {
	 			for (UserSkill__c userSkillItem : userSkillList) {
	 				if (userItem.Id == userSkillItem.User__r.Id) {
	 					userIdUserSkillObjectMap.put(userItem.Id,userSkillItem);
	 				}
	 			}
	 		}
	 		
	 		//create wrapper object
			for(User userItem : userList){
	            WrapperClass item = new WrapperClass(null, userItem,productList,userIdUserSkillObjectMap.get(userItem.Id), userSkill);
	            wrapperList.Add(item);
	        }
    	}
        if(this.isUserRole) {
	        //logic to RoleUser	
	    	userSkill = getUserSkillByRoleId(this.currentRoleId);
			this.quantity = (userSkill != null) ? userSkill.Quantity__c : 0;
			//Top level role
			if((this.currentUser.UserRole.DeveloperName == orgSettings.Top_Role_Name_B2B__c && roleId == null 
					|| this.currentUser.UserRole.DeveloperName == orgSettings.Top_Role_Name_B2B__c && roleId == this.currentUser.UserRoleId)
					||(this.currentUser.UserRole.DeveloperName == orgSettings.Top_Role_Name_B2C__c && roleId == null
					||this.currentUser.UserRole.DeveloperName == orgSettings.Top_Role_Name_B2C__c && roleId == this.currentUser.UserRoleId)) {
				 for(Product2 prodItem : productList){
					  titleMap.put(prodItem.Name,prodItem.Id);
	             }
	        } else {
	        	//validation to populate titlmap
		        if (userSkill != null) {
		            for(Product2 prodItem : productList){
		                for(UserSkillProduct__c productItem : userSkill.User_Skill_Products__r){
		                    if(prodItem.Id == productItem.Product__c) {
		                        titleMap.put(prodItem.Name,prodItem.Id);
		                    }
		                }
		            }
		        }
	        }
			
	        UserSkill__c[] userSkillList = getUserSkillWithProductByRoleIdList(this.currentRoleId);
	    	//validation to populate userRoleIdUserSkillObjectMap
	    	for(UserRole userRoleItem : userRoleList) {
		 		for (UserSkill__c userSkillItem : userSkillList) {
		 			if (userRoleItem.Id == userSkillItem.Role__c) {
		 				userRoleIdUserSkillObjectMap.put(userRoleItem.Id,userSkillItem);
		 			}
		 		}
	 		}
	 		
	 		system.debug('>>>>> ' + roleAccountIdsList);
            partnerAccountMap = new Map<String,String>();		 
		 
		    for (Account account : [select Id, Name from Account where Id in : roleAccountIdsList]) {
		        if (!partnerAccountMap.containsKey(account.Id))
		            partnerAccountMap.put(String.valueof(account.Id).left(15), account.Name);
		    }
	 		
			//create wrapper object
			for(UserRole userRoleItem : userRoleList){
			     WrapperClass item = new WrapperClass(userRoleItem, null,productList,userRoleIdUserSkillObjectMap.get(userRoleItem.Id), userSkill);
			     wrapperList.Add(item);
		    }
	
        }
    }
    
    /**
    * Method save product and quantity to UserSkill__c
    * Nikolay Iliaev
    * @method save	
    * @return {Void}*     
    * @module Lead
    */
    public void save(){
		List<UserSkill__c> userSkillList = new List<UserSkill__c>();
		List<UserSkill__c> skillForUpdateStatusList = new List<UserSkill__c>();
		List<List<UserSkillProduct__c>> userSkillProductChildeList = new  List<List<UserSkillProduct__c>>();
		List<UserSkillProduct__c> userSkillProductToDeleteList = new List<UserSkillProduct__c>();
		List<UserSkillProduct__c> userSkillProductsToInsertList = new List<UserSkillProduct__c>();
		Map<Id,Integer> userIdAndQuantityMap = new Map<Id,Integer>();
		UserSkill__c userSkillItem;
		Id currentId;
       
       for(WrapperClass wrapperItem : WrapperList) {
           if(wrapperItem.userRole != null) {
               userRoleIdList.add(wrapperItem.userRole.Id);
           }
       }
       
       for(WrapperClass wrapperItem : WrapperList){
       	List<UserSkillProduct__c> userSkillProductList = new List<UserSkillProduct__c>();
       	
       		//check current id 
       		if(wrapperItem.user != null) {
       			currentId = wrapperItem.user.Id;
       			userSkillItem =  userIdUserSkillObjectMap.get(currentId);
       		} else {
       			currentId = wrapperItem.userRole.Id;
       			userSkillItem =  userRoleIdUserSkillObjectMap.get(currentId);
       			
       			if (userSkillItem != null) {
       				//Validation to divide Quantity
	       			if(userSkillItem.Quantity__c > wrapperItem.quantity) {
	       				divideQuantity(currentId, wrapperItem.quantity, userSkillList);
	       			}
	       			//checkboxes (lead,Hot_Lead,Existing) validation to delete 
	       			if((userSkillItem.Leads__c && !wrapperItem.lead) 
	       			|| (userSkillItem.HotLead__c && !wrapperItem.hotLead) 
	       			|| (userSkillItem.Existing__c && !wrapperItem.existing)) {
	       				
	       					leadStatusMap = new Map <String,Boolean> {
	       					'lead' => wrapperItem.lead,
	       					'hotLead' => wrapperItem.hotLead,
	       					'existing' => wrapperItem.existing };
	       					updateSkillStatus(currentId, skillForUpdateStatusList);
	       			}
	       			
       			}
       		}
       		if (userSkillItem != null) {
       			userSkillList.add(new UserSkill__c(Quantity__c = wrapperItem.quantity, Id = userSkillItem.Id, 
       			HotLead__c = wrapperItem.hotLead, Leads__c = wrapperItem.lead, Existing__c = wrapperItem.existing));
       			//Create UserSkillProduct__c 
       			for (String prodItem : wrapperItem.productMap.KeySet()) {
       				//Validation if check box is true = create product
	       			if (wrapperItem.productMap.get(prodItem)) {
	       				if(!wrapperItem.oldProductMap.get(prodItem)){
	       					userSkillProductList.add(new UserSkillProduct__c(Product__c = titleMap.get(prodItem)));
	       				}
	       			//Validation if check box is false = delete product
	       			} else {
	       				if(wrapperItem.oldProductMap.get(prodItem)){
	       					//Check all product in this userskill 
	       					for(UserSkillProduct__c productItem : userSkillItem.User_Skill_Products__r) {
	       						if(titleMap.get(prodItem) == productItem.Product__c){
                       				 userSkillProductToDeleteList.add(new UserSkillProduct__c(Id = productItem.Id));
                    			}
	       					}
	       					//Delete all products in low level
	       					deleteProducts(currentId, userSkillProductToDeleteList, prodItem);
	       				}
	       			}
       			}	       			
       		} else {
       			if(wrapperItem.quantity == 0) continue;
       			//User save
       			if(wrapperItem.user != null) {
       				userSkillList.add(new UserSkill__c(Quantity__c = wrapperItem.quantity, HotLead__c = wrapperItem.hotLead,
		   			User__c = wrapperItem.user.Id, Leads__c = wrapperItem.lead, Existing__c = wrapperItem.existing,
		   			OwnerId = wrapperItem.user.Id));
		   		//UserRole save
       			} else {
       				userSkillList.add(new UserSkill__c(Quantity__c = wrapperItem.quantity, HotLead__c = wrapperItem.hotLead,
		   			RecordTypeId = RecordTypeService.getRecordTypeIdByName('UserSkill__c', 'Manager'), Leads__c = wrapperItem.lead, Existing__c = wrapperItem.existing,
		   			Role__c = wrapperItem.userRole.Id));
       			}
	       		for(String prodItem : wrapperItem.productMap.KeySet()){
	       			if(wrapperItem.productMap.get(prodItem)){
	       				userSkillProductList.add(new UserSkillProduct__c(Product__c = titleMap.get(prodItem)));
	       			}
	       		}
       		}
       		userSkillProductChildeList.add(userSkillProductList);
       }
       try{
       	sp = Database.setSavepoint();
       	System.debug(LoggingLevel.ERROR,'userSkillList >>' + userSkillList);
       	if(!skillForUpdateStatusList.isEmpty()) {
       		Database.upsert(skillForUpdateStatusList);
       	}
       	Database.upsert(userSkillList);
       	
       	//populate list of product with corect user skill id 
       	for(Integer i = 0; i < userSkillProductChildeList.size(); i++){
       		for(UserSkillProduct__c childeItem : userSkillProductChildeList[i]){
       			childeItem.UserSkill__c = userSkillList[i].Id;
       			userSkillProductsToInsertList.add(childeItem);
       		}
       	}
       	
       	Database.upsert(userSkillProductsToInsertList);
       	Database.delete(userSkillProductToDeleteList);
       	
       	
       	
       	insertAllData();
       	
       	//B2B part to update leads 
       	for(WrapperClass wrapperItem : WrapperList) {
       		if(wrapperItem.user != null) {
       			if(ProfileTypeService.getProfileTypeByName(wrapperItem.user.Profile.Name) == 'B2B') {
       				if(wrapperItem.quantity != 0) {
       					userIdAndQuantityMap.put(wrapperItem.user.Id,wrapperItem.quantity);
       				}
       			}
	       	}
       	}
       	// validation and call to manager screen servise to update leads (B2B)
       	if(!userIdAndQuantityMap.isEmpty()) {
       		ManagerScreenService managerService = new ManagerScreenService();
       		//managerService.updateLeads(userIdAndQuantityMap, JSON.serialize(userIdUserSkillObjectMap));
       		ManagerScreenService.updateLeadsFuture(userIdAndQuantityMap, JSON.serialize(userIdUserSkillObjectMap));
       		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,Label.SavedSuccessfullyB2B));
       	} else  {
       	    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,Label.savedSuccessfully));
       	}
       	 
        
       }catch(Exception ex){
       		system.debug(Logginglevel.ERROR,  'EXCEPTION : '  +  ex.getMessage()  +  ':'  +  ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
          	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.errorManagerScreen));
            Database.rollback(sp);
       }
    }
    
	/**
    * Method divide quantity to all roles and users
    * Nikolay Iliaev
    * @method divideQuantity	
    * @return {void}*     
    * @module Lead
    */
	public void divideQuantity(Id currentId, Integer quantity, List<UserSkill__c> userSkillList) {
		Decimal sumQuantity = 0;
   		parentIdChildUserRoleListMap = new Map<Id,List<UserRole>>();
   		userRoleIdUserListMap = new Map<Id,List<User>>();
   		userIdUserSkillMap= new Map<Id,UserSkill__c>();
   		Map<Id,Decimal> roleIdQuantityMap = new Map<Id,Decimal>();
   		
   		//divide quantity to child rolse		
   		allUserSkillList = getUserSkillWithProductByRoleIdList(currentId);
   		
   		if(allUserSkillList.isEmpty()) {
   			this.userList = getUserByRoleId(currentId);
   			allUserSkillList = getUserSkillWithProductList();
   		}
   				
   		if(!allUserSkillList.isEmpty()) {
   			sumQuantity = quantity / allUserSkillList.size();
   		}
   				
   		for(UserSkill__c skillItem : allUserSkillList) {
   			userSkillList.add(new UserSkill__c(Id = skillItem.Id, Quantity__c = sumQuantity));
   		}
       	// divide quantity to all rolse and users in low level 			
   		Set<Id> userIdSet = new Set<Id>();
		userIdSet.add(currentId);
		Set<ID> finalUserRoleIdSet = getAllSubRoleIds(userIdSet);
		//get all data 
		prepareDataForMaps(finalUserRoleIdSet);
		
		for(ID userRoleIdItem : finalUserRoleIdSet) {
			
			//get Quantity per role id 
			sumQuantity = roleIdQuantityMap.get(userRoleIdItem) != null ? roleIdQuantityMap.get(userRoleIdItem) : sumQuantity;
			
			allUserSkilstoUpdateList = new List<UserSkill__c>();
			//divide quantity to roles
			for(UserRole userRoleItem: parentIdChildUserRoleListMap.get(userRoleIdItem)) {
				for(UserSkill__c userSkillItem : allUserSkillList) {
					if(userSkillItem.Role__c == userRoleItem.Id) {
						allUserSkilstoUpdateList.add(userSkillItem);
					}
				}
			}
			if(!allUserSkilstoUpdateList.isEmpty()) {
		       		sumQuantity = sumQuantity / allUserSkilstoUpdateList.size();
		       		//update user skill
				for(UserSkill__c skillItem : allUserSkilstoUpdateList) {
		   			userSkillList.add(new UserSkill__c(Id = skillItem.Id, Quantity__c = sumQuantity.longValue()));
		   		}
		   		//populate role is and his Quantity
		   		for(UserRole userRoleItem: parentIdChildUserRoleListMap.get(userRoleIdItem)) {
		   			roleIdQuantityMap.put(userRoleItem.Id,sumQuantity);
		   		}
		    }
		    //logic for users 
		    else {
		    	Decimal num = 0;
		    	if(roleIdQuantityMap.get(userRoleIdItem) != null) {
		    		num = roleIdQuantityMap.get(userRoleIdItem);
		    	}
		       	List<User> userList = userRoleIdUserListMap.get(userRoleIdItem);
		       	for(User userItem : userList) {
		       		if(userIdUserSkillMap.containsKey(userItem.Id)) {
		       			allUserSkilstoUpdateList.add(userIdUserSkillMap.get(userItem.Id));
		       		}
		       	}
	       		//divide quantity to users 
	       		if(!allUserSkilstoUpdateList.isEmpty()) {
	   				num = num / allUserSkilstoUpdateList.size();
	   				//update user skill
					for(UserSkill__c skillItem : allUserSkilstoUpdateList) {
			   			userSkillList.add(new UserSkill__c(Id = skillItem.Id, Quantity__c = num.longValue()));
			   		}
	       		}
		    }
		}
	}  
	
	/**
    * Method delete product from user skill in all roles and users
    * Nikolay Iliaev
    * @method deleteProducts
    * @param {Id} currentId
    * @param {ist<UserSkillProduct__c>} userSkillProductToDeleteList
    * @param {String} prodItem
    * @return {void}*     
    * @module Lead
    */
	public void deleteProducts(Id currentId, List<UserSkillProduct__c> userSkillProductToDeleteList, String prodItem) {
		
		allUserSkillList = getUserSkillWithProductByRoleIdList(currentId);
		//delete product to child rolse
   		if(allUserSkillList.isEmpty()) {
   			this.userList = getUserByRoleId(currentId);
   			allUserSkillList = getUserSkillWithProductList();
   		}
		  			
   		for(UserSkill__c skillItem : allUserSkillList) {
		   	for(UserSkillProduct__c productItem : skillItem.User_Skill_Products__r) {
		   		
   				if(titleMap.get(prodItem) == productItem.Product__c){
               		userSkillProductToDeleteList.add(new UserSkillProduct__c(Id = productItem.Id));
    			}
   			}
   		}
	    Set<Id> userIdSet = new Set<Id>();
		userIdSet.add(currentId);
		Set<ID> finalUserRoleIdSet = getAllSubRoleIds(userIdSet);
		//get all data
		prepareDataForMaps(finalUserRoleIdSet);
		
		//find all roles and user then delete relevant product 
		for(ID userRoleIdItem : finalUserRoleIdSet) {
			allUserSkilstoUpdateList = new List<UserSkill__c>();
			
			for(UserRole userRoleItem: parentIdChildUserRoleListMap.get(userRoleIdItem)) {
				for(UserSkill__c userSkillItem : allUserSkillList) {
					if(userSkillItem.Role__c == userRoleItem.Id) {
						allUserSkilstoUpdateList.add(userSkillItem);
					}
				}
			}
			//validation if no more roles in the low level
			if(allUserSkilstoUpdateList.isEmpty()) {
	       		List<User> userList = userRoleIdUserListMap.get(userRoleIdItem);
		       	for(User userItem : userList) {
		       		if(userIdUserSkillMap.containsKey(userItem.Id)) {
		       			allUserSkilstoUpdateList.add(userIdUserSkillMap.get(userItem.Id));
		       		}
		       	}
			}
			for(UserSkill__c skillItem : allUserSkilstoUpdateList) {
			   	for(UserSkillProduct__c productItem : skillItem.User_Skill_Products__r) {
	   				if(titleMap.get(prodItem) == productItem.Product__c){
	   				 	userSkillProductToDeleteList.add(new UserSkillProduct__c(Id = productItem.Id));
	    			}
	   			}
			}
		}
	}
	
	/**
    * Method unmarks check boxes with parameters hot_lead lead and existing 
    * Nikolay Iliaev
    * @method updateLeadStatus
    * @param {Id} currentId
    * @param {ist<UserSkillProduct__c>} userSkillProductToDeleteList
    * @return {void}*     
    * @module Lead
    */
	public void updateSkillStatus(Id currentId, List<UserSkill__c> userSkillList) {
		
		allUserSkillList = getUserSkillWithProductByRoleIdList(currentId);
		//validation if no more roles 
   		if(allUserSkillList.isEmpty()) {
   			this.userList = getUserByRoleId(currentId);
   			allUserSkillList = getUserSkillWithProductList();
   		}
		//update user skill  			
   		for(UserSkill__c skillItem : allUserSkillList) {
   			
   			UserSkill__c userSkill  = new UserSkill__c(Id = skillItem.Id);
   			if(!leadStatusMap.get('lead')) {
   				userSkill.Leads__c = leadStatusMap.get('lead');
   			}
   			if(!leadStatusMap.get('hotLead'))  {
   				userSkill.HotLead__c = leadStatusMap.get('hotLead');
   			}
			if(!leadStatusMap.get('existing')) {
				userSkill.Existing__c = leadStatusMap.get('existing');
			}
			userSkillList.add(userSkill);
			
   		}
	    Set<Id> userIdSet = new Set<Id>();
		userIdSet.add(currentId);
		Set<ID> finalUserRoleIdSet = getAllSubRoleIds(userIdSet);
		//get all data
		prepareDataForMaps(finalUserRoleIdSet);
		
		//find all roles and user then update relevant user skills 
		for(ID userRoleIdItem : finalUserRoleIdSet) {
			allUserSkilstoUpdateList = new List<UserSkill__c>();
			
			for(UserRole userRoleItem: parentIdChildUserRoleListMap.get(userRoleIdItem)) {
				for(UserSkill__c userSkillItem : allUserSkillList) {
					if(userSkillItem.Role__c == userRoleItem.Id) {
						allUserSkilstoUpdateList.add(userSkillItem);
					}
				}
			}
			//validation if no more roles in the low level
			if(allUserSkilstoUpdateList.isEmpty()) {
	       		List<User> userList = userRoleIdUserListMap.get(userRoleIdItem);
		       	for(User userItem : userList) {
		       		if(userIdUserSkillMap.containsKey(userItem.Id)) {
		       			allUserSkilstoUpdateList.add(userIdUserSkillMap.get(userItem.Id));
		       		}
		       	}
			}
			for(UserSkill__c skillItem : allUserSkilstoUpdateList) {
	   				
   			UserSkill__c userSkill  = new UserSkill__c(Id = skillItem.Id);
   			if(!leadStatusMap.get('lead')) {
   				userSkill.Leads__c = leadStatusMap.get('lead');
   			}
   			if(!leadStatusMap.get('hotLead'))  {
   				userSkill.HotLead__c = leadStatusMap.get('hotLead');
   			}
			if(!leadStatusMap.get('existing')) {
				userSkill.Existing__c = leadStatusMap.get('existing');
			}
			userSkillList.add(userSkill);
			}
		}
	}
	
	/**
    * Method prepare data for maps that used in methods divideQuantity and deleteProducts
    * Nikolay Iliaev
    * @method prepareDataForMaps
    * @param {Set<ID>} finalUserRoleIdSet
    * @return {Void}*     
    * @module Lead
    */
	public void prepareDataForMaps(Set<Id> finalUserRoleIdSet) {
		
   		parentIdChildUserRoleListMap = new Map<Id,List<UserRole>>();
   		userRoleIdUserListMap = new Map<Id,List<User>>();
   		userIdUserSkillMap= new Map<Id,UserSkill__c>();
   		
   		userRoleList = getUserRolesList(finalUserRoleIdSet);
		
		//Populate map with parent role id and child list user
		for(ID userRoleIdItem : finalUserRoleIdSet) {
			userRoleChildList = new List<UserRole>();
			for(UserRole userRoleItem : userRoleList) {
				if(userRoleIdItem == userRoleItem.ParentRoleId) {
					userRoleChildList.add(userRoleItem);
				}
			}
			parentIdChildUserRoleListMap.put(userRoleIdItem,userRoleChildList);
		}
		
		allUserSkillList = getUserSkillByRoleIdList(finalUserRoleIdSet);
		
		List<User> AllRoleUserList = getUserByRoleIdList(finalUserRoleIdSet);
		allSkillsOfUsers = getUserSkillWithProductForUsersList(AllRoleUserList);
		
		//populate map with user id and his user skill
		for(User userItem : AllRoleUserList) {
			for(UserSkill__c userSkilItem : allSkillsOfUsers) {
				if(userItem.Id == userSkilItem.User__r.Id) {
					userIdUserSkillMap.put(userItem.Id,userSkilItem);
				}
			}
		}
		
		// populate role id with all his users
         for(ID userRoleIdItem : finalUserRoleIdSet) {
            UsertoUpdateList = new List<User>();
            for(User userItem : AllRoleUserList) {
                if(userRoleIdItem == userItem.UserRoleId) {
					UsertoUpdateList.add(userItem);                    
                }
            }
            userRoleIdUserListMap.put(userRoleIdItem,UsertoUpdateList);
        }
	}
	
    /**
    * Method get all role Ids
    * Nikolay Iliaev
    * @method getAllSubRoleIds
    * @param {Set<ID>} roleIds
    * @return {Set<ID>}*     
    * @module Lead
    */
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
    
    Set<ID> currentRoleIds = new Set<ID>();
    
    // get all of the roles underneath the passed roles
    for(UserRole userRole :[select Id from UserRole where ParentRoleId 
                            IN :roleIds AND ParentRoleID != null]) {
                                currentRoleIds.add(userRole.Id);
                            }
    
    // go fetch some more rolls!
    if(currentRoleIds.size() > 0) {
        currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    }
 
    return currentRoleIds;
}
    
    /**
    * Method get user from DB
    * Nikolay Iliaev
    * @method getCurrentUser	
    * @return {User}*     
    * @module Lead
    */
    public User getCurrentUser() {
    	User currentUser = [SELECT Id, Name, UserRoleId, UserRole.Name, Profile.Name, UserRole.DeveloperName, RoleName__c,
    						(SELECT Quantity__c FROM User_Skills1__r)
                     		FROM user 
                     		WHERE id = :UserInfo.getUserId() 
                     		limit 1];
                     
        return currentUser;
    }
    
    /**
    * Method get user skill by role id from DB
    * Nikolay Iliaev
    * @method getUserSkillByRoleId
    * @param {Id} roleId
    * @return {UserSkill__c}*     
    * @module Lead
    */
    public UserSkill__c getUserSkillByRoleId(Id roleId) {
    	
    	UserSkill__c[] userSkill = [Select User__r.Name, Id, HotLead__c, Leads__c, Existing__c, Quantity__c, Role__c, Name,
        									FollowupPerDayUtilized__c, QuantityUtilizedPerHour__c, User__r.Id, Owner.Id, QuantityUtilized__c,
        									(Select Id, UserSkill__c, Product__c 
        									 From User_Skill_Products__r) 
        									 From UserSkill__c 
        									 WHERE Role__c = : roleId];
        
		return !userSkill.isEmpty() ? userSkill[0] : null;
    }
    
    /**
    * Method get user skill by role id from DB
    * Nikolay Iliaev
    * @method getUserSkillByRoleIdList
    * @param {Set<Id>} userRoleId
    * @return {UserSkill__c}*     
    * @module Lead
    */
     public List<UserSkill__c> getUserSkillByRoleIdList(Set<Id> userRoleId) {
    	
    	List<UserSkill__c> userSkillList = [Select User__r.Name, Id, HotLead__c, Leads__c, Existing__c, Quantity__c, Role__c, Name,
        									FollowupPerDayUtilized__c, QuantityUtilizedPerHour__c, User__r.Id, Owner.Id, QuantityUtilized__c,
        									(Select Id, UserSkill__c, Product__c 
        									 From User_Skill_Products__r) 
        									 From UserSkill__c 
        									 WHERE Role__c IN : userRoleId];
        
		return userSkillList;
    }
    
     /**
    * Method get user roles from DB
    * Nikolay Iliaev
    * @method getUserRolesList	
    * @param {Set<Id>} roleIdSet
    * @return {List<UserRole>}*     
    * @module Lead
    */
    public List<UserRole> getUserRolesList(Set<Id> roleIdSet) {
    	
    	List<UserRole> urList = [SELECT Id, Name,UserRole.ParentRoleId, PortalType
    							FROM UserRole 
    							WHERE UserRole.ParentRoleId IN : roleIdSet];
    	return urList;
    }
    
    /**
    * Method get user roles from DB
    * Nikolay Iliaev
    * @method getUserRoles	
    * @param {Id} roleId
    * @return {List<UserRole>}*     
    * @module Lead
    */
    public List<UserRole> getUserRoles(Id roleId) {
    	
    	
    	/*List<UserRole> urList = [SELECT Id, Name, PortalType
    							FROM UserRole 
    							WHERE UserRole.ParentRoleId = : roleId];
    	
    	*/
    	
    	List<UserRole> urList = new List<UserRole>();
    	roleAccountIdsList = new List<String>();
    	
		for (UserRole userRole : [SELECT Id, Name, PortalType
    							FROM UserRole 
    							WHERE UserRole.ParentRoleId = : roleId]) {
								
			urList.add(userRole);
			
			// collect Account IDs from Role Name - only for Partner Roles
			if (userRole.PortalType == 'Partner') {
				// add first 15 chars - Account ID
				roleAccountIdsList.add(userRole.Name.left(15));
			}
			
		}
    	/*
    	//### Test for black list ####
    	Map<Id,UserRole> idObjUserRoleMap = new Map<Id,UserRole>();						
		system.debug(Logginglevel.ERROR,'urList: ' + urList);
		for(UserRole roleItem: urList) {
		    idObjUserRoleMap.put(roleItem.Id,roleItem);
		}
		
		idObjUserRoleMap.remove('00E4E000000VuMlUAK');
		
		urList = idObjUserRoleMap.values();
		*/
    	return urList;
    }
    
    /**
    * Method get user role from DB
    * Nikolay Iliaev
    * @method getUserRole
    * @param {Id} roleId	
    * @return {UserRole}*     
    * @module Lead
    */
    public UserRole getUserRole(Id roleId) {
    	
    	UserRole userRole = [SELECT Id, Name, PortalType
    							FROM UserRole 
    							WHERE Id = : roleId];
    	return userRole;
    }
    
    /**
    * Method get user by role id from DB
    * Nikolay Iliaev
    * @method getUserByRoleId
    * @param {Id} roleId	
    * @return {List<User>}*     
    * @module Lead
    */
    public List<User> getUserByRoleId(Id roleId) {
    	
		List<User> userList = [SELECT Id, Name, Profile.Name 
								FROM User 
								WHERE UserRoleId = : roleId];
		
		return userList;
    }
    
    /**
    * Method get user by role id from DB
    * Nikolay Iliaev
    * @method getUserByRoleIdList
    * @param {Set<Id>} roleId	
    * @return {List<User>}*     
    * @module Lead
    */
    public List<User> getUserByRoleIdList(Set<Id> roleId) {
    	
		List<User> userList = [SELECT Id, Name, UserRoleId, RoleName__c 
								FROM User 
								WHERE UserRoleId = : roleId];
		
		return userList;
    }
    
    /**
    * Method get UserSkill__c from DB
    * Nikolay Iliaev
    * @method getUserSkillWithProductList	
    * @return {List<UserSkill__c>}*     
    * @module Lead
    */
    public List<UserSkill__c> getUserSkillWithProductList() {
        
        
        List<UserSkill__c> userSkillList = [SELECT User__r.Name, Id, HotLead__c, Leads__c, Existing__c, Quantity__c, QuantityUtilized__c,
        									FollowupPerDayUtilized__c, QuantityUtilizedPerHour__c, User__r.Id, Owner.Id,
        									(SELECT Id, UserSkill__c, Product__c 
        									 FROM User_Skill_Products__r) 
        									 FROM UserSkill__c 
        									 WHERE User__r.Id IN : this.userList
        									 LIMIT 10000];
	 
        return userSkillList;
    }
    
     /**
    * Method get UserSkill__c from DB
    * Nikolay Iliaev
    * @method getUserSkillWithProductForUsersList
    * @param {List<User>} userList	
    * @return {List<UserSkill__c>}*     
    * @module Lead
    */
    public List<UserSkill__c> getUserSkillWithProductForUsersList(List<User> userList) {
        
        
        List<UserSkill__c> userSkillList = [SELECT User__r.Name, Id, HotLead__c, Leads__c, Existing__c, Quantity__c, QuantityUtilized__c,
        									FollowupPerDayUtilized__c, QuantityUtilizedPerHour__c, User__r.Id, Owner.Id,
        									(SELECT Id, UserSkill__c, Product__c 
        									 FROM User_Skill_Products__r) 
        									 FROM UserSkill__c 
        									 WHERE User__r.Id IN : userList
        									 LIMIT 10000];
	 
        return userSkillList;
    }
    
    /**
    * Method get UserSkill__c from DB
    * Nikolay Iliaev
    * @method getUserSkillWithProductByRoleIdList
    * @param {Id} roleId	
    * @return {List<UserSkill__c>}*     
    * @module Lead
    */
    public List<UserSkill__c> getUserSkillWithProductByRoleIdList(Id roleId) {
        
        List<String> userRoleIdList = new List<String>();
        
        for(UserRole userRoleItem : getUserRoles(roleId)){
        	userRoleIdList.add(userRoleItem.Id);
        }
        
        List<UserSkill__c> userSkillList = [Select User__r.Name, Id, HotLead__c, Leads__c, Existing__c, Quantity__c, Role__c,
        									FollowupPerDayUtilized__c, QuantityUtilizedPerHour__c, User__r.Id, Owner.Id, QuantityUtilized__c,
        									(Select Id, UserSkill__c, Product__c 
        									 From User_Skill_Products__r) 
        									 From UserSkill__c 
        									 WHERE Role__c IN : userRoleIdList];
        									 
        									 
        return userSkillList;
    }
    
    /**
    * Method get products from DB
    * Nikolay Iliaev
    * @method getproducts	
    * @return {List<Product2>}*     
    * @module Lead
    */  
    public List<Product2> getProducts(Boolean isB2B) {
        
 		List<Product2> productList = Database.query('SELECT Id, Name, Family, LOB__c, RecordType.DeveloperName FROM Product2 WHERE IsActive = True AND RecordType.DeveloperName = \'LeadProduct\' AND ManagerScreenInd__c = true AND ' + (isB2B == true ? 'BusinessInd__c = true' : 'ConsumerInd__c = true'));
        
        return productList;
   }
   
  	/**
	* Inner wrapper class 
	* Nikolay Iliaev
	* taskid PLR-444
	* @class WrapperClass
	* @module Lead
	* @constructor 
	*/
    public Class WrapperClass {
        public User user { get; set; }
        public UserRole userRole { get; set; }
        public Integer quantity { get; set; }
        public Integer used { get; set; }
        public Integer followupPerHour { get; set; }
        public Boolean hotLead { get; set; }
        public Boolean hotLeadVisible { get; set; }
        public Boolean lead { get; set; }
        public Boolean leadVisible { get; set; }
        public Boolean existing { get; set; }
        public Boolean existingVisible { get; set; }
        public Boolean isSelected = false;
        public Map<String,boolean> productMap { get; set; }
        public Map<String,boolean> oldProductMap { get; set; }
        public UserSkill__c userSkillItem { get; set; }
        
        public WrapperClass(UserRole userRole, User userItem, List<Product2> productList, UserSkill__c userSkillItem, UserSkill__c parentUserSkill) {
			
			this.productMap = new Map<String,boolean>();
			this.oldProductMap = new Map<String,boolean>();
			this.userSkillItem = userSkillItem;
			
			//Validation to check witch id we have (user or userrole)
			if(userRole != null) {
			    
			    //system.debug('>>>> this.userRole.Name ' + userRole.Name);
			    //system.debug('>>>> partnerAccountMap ' + partnerAccountMap);
			    
			    userRole.Name = (userRole.PortalType == 'Partner') ? 
			        partnerAccountMap.get(userRole.Name.left(15)) : 
			        userRole.Name;
				this.userRole = userRole;
				
			} else {
				this.user = userItem;
			}
			//valsidation to show hotelead, leads and existing 
			if (parentUserSkill != null) {
					this.hotLeadVisible = !parentUserSkill.HotLead__c ? true : false;
					this.leadVisible = !parentUserSkill.Leads__c ? true : false;
					this.existingVisible = !parentUserSkill.Existing__c ? true : false;
				} else {
					this.hotLeadVisible = true;
					this.leadVisible = true;
					this.existingVisible = true;
				}
			if (this.userSkillItem != null) {
				
				this.quantity = (Integer)this.userSkillItem.Quantity__c;
				
				this.hotLead = this.userSkillItem.HotLead__c;
				this.lead = this.userSkillItem.Leads__c;
				this.existing = this.userSkillItem.Existing__c;
				this.followupPerHour = (Integer)userSkillItem.QuantityUtilizedPerHour__c;
				this.used = userSkillItem.QuantityUtilized__c == null ? 0 : (Integer)userSkillItem.QuantityUtilized__c;
				//validation of product 
				for(Product2 prodItem : productList){
					Boolean isSelected = false;
					for(UserSkillProduct__c productItem : this.userSkillItem.User_Skill_Products__r){
						if(prodItem.Id == productItem.Product__c){
							isSelected = true;
						}
					}
					this.productMap.put(prodItem.Name,isSelected);
					this.oldProductMap.put(prodItem.Name,productMap.get(prodItem.Name));
				}
			} else {
				this.quantity = 0;
				this.used = 0;
				this.hotLead = false;
				this.lead = false;
				this.existing = false;
				this.followupPerHour = 0;
				
				for(Product2 prodItem : productList){
					this.productMap.put(prodItem.Name,isSelected);
				}
			}
        }
    }
}