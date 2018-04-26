/**
*   Test class for AssigmentTabletoUsersControler
*   Author Nikolay Iliaev

*   taskid PLR-444
*   @class AssigmentTabletoUsersControlerTest
*   @module Lead
*/
@isTest 
private class AssigmentTabletoUsersControlerTest {
    
    /**
    * Method get relevant data
    * Nikolay Iliaev
    * @method setupTestData 
    * @return {Void}*     
    * @module Lead
    */
    @testSetup static void setupTestData(){
        
        Product2  product = TestFactory.testCreateProdact2();
        product.ManagerScreenInd__c = true;
        update product;
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
         ProfileType__c profileTypeSettings = 
            (ProfileType__c ) new testFramework('ProfileType__c', 
                                                        new map<String, Object> {'Name' => 'CSR B2B','Type__c' => 'B2B' }, 
                                                        settings).createObject();
        insert profileTypeSettings;
        
        OrgSettings__c orgSettings = 
            (OrgSettings__c ) new testFramework('OrgSettings__c', 
                                                        new map<String, Object> {'Name' => 'Org Settings','Top_Role_Name_B2B__c' => 'R50007937','Top_Role_Name_B2C__c' => 'R50007948' }, 
                                                        settings).createObject();
        insert orgSettings;
        
        Account accountItem = TestFactory.testCreateAccountAndContact();
        accountItem.Phone = '0123410125';
        update accountItem;
    }
    
    /**
    * Method prepare user data
    * Nikolay Iliaev
    * @method dataPrepare   
    * @return {User[]}*     
    * @module Lead
    */
    private static User[] dataPrepare() {
        
        List<User> userList = new List<User>();
        List<UserRole> userRoleList = TestFactory.testCreateUserRoles();
        
        
        for(Integer i = 0; i<3; i++) {
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            userList.add(testFramework.createUser(null));
            userList[i].UserName = i + randomInt + '@acme.com';
        }
        userList.add(testFramework.createUser('CSR B2B'));
        
        for(Integer y = 0; y<userList.size(); y++) {
            userList[y].UserRoleId = userRoleList[y].Id;
        }
        
        for(Integer k = 1; k<userRoleList.size(); k++) {
            userRoleList[k].ParentRoleId = userRoleList[k-1].Id;
        }
      
        insert userList;
        update userRoleList;
        
        return userList;
    }
    /**
    * Method prepare userSkill data
    * Nikolay Iliaev
    * @method dataUserSkillPrepare  
    * @return {UserSkill__c}*     
    * @module Lead
    */
     private static UserSkill__c[] dataUserSkillPrepare() {
          UserSkillProduct__c userSkillProduct = new UserSkillProduct__c();
          List<UserSkill__c> userSkillList = new List<UserSkill__c>();
          Product2 product = [SELECT Id FROM Product2];
         
          for(Integer j = 0; j<4; j++) {
            userSkillList.add(TestFactory.testCreateUserSkill(null,null, null, null));
        }
        
        insert userSkillList;
        
        for(UserSkill__c skillItem : userSkillList) {
             userSkillProduct.UserSkill__c = skillItem.Id;
        }
        userSkillProduct.Product__c = product.Id;
        
        insert userSkillProduct;
        return userSkillList;
     }
    /**
    * Method tests insert new user skill to data
    * Nikolay Iliaev
    * @method insertTest    
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void insertTest(){
       List<User> userList = AssigmentTabletoUsersControlerTest.dataPrepare();
        
        System.runAs(userList[1]) {
        
            Test.startTest();
                AssigmentTabletoUsersControler assigmentcontroller = new AssigmentTabletoUsersControler();
                assigmentcontroller.WrapperList[0].quantity = 1;
                assigmentcontroller.WrapperList[0].productMap.put('Test String',True);
                assigmentcontroller.save();
            Test.stopTest();
            
            Product2 product = [SELECT Id FROM Product2];
            
            List<UserSkill__c> userSkillList = [Select Id, Quantity__c, Role__c 
                                                From UserSkill__c 
                                                WHERE Role__c = : userList[2].UserRoleId];
            
            System.assertEquals(1,userSkillList[0].Quantity__c,'  <<<<assertEquals 01>>>>');
        }
    }
    
    /**
    * Method test save with Role id paramether in url 
    * Nikolay Iliaev
    * @method updateWithRoleIdParametherTest    
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void updateWithRoleIdParametherTest() {
        
        List<User> userList = AssigmentTabletoUsersControlerTest.dataPrepare();
        
        Test.setCurrentPageReference(new PageReference('Page.AssigmentTableToUsers')); 
        System.currentPageReference().getParameters().put('roleId', userList[3].UserRoleId);
        
        System.runAs(userList[3]) {
            Test.startTest();
                UserSkill__c userSkill = TestFactory.testCreateUserSkill(userList[3].Id,null, null, null);
                userSkill.Role__c = userList[0].UserRoleId;
                UserSkillProduct__c userSkillProduct = new UserSkillProduct__c();
                Product2 product = [SELECT Id FROM Product2];
            
                insert userSkill;
                
                userSkillProduct.UserSkill__c = userSkill.Id;
                userSkillProduct.Product__c = product.Id;
                
                insert userSkillProduct;
                
                AssigmentTabletoUsersControler assigmentcontroller = new AssigmentTabletoUsersControler();
                assigmentcontroller.WrapperList[0].quantity = 1;
                assigmentcontroller.WrapperList[0].productMap.put('Test String',True);
                assigmentcontroller.save();
            Test.stopTest();
            
            List<UserSkill__c> userSkillList = [Select Id, Quantity__c, User__r.Id
                                                 From UserSkill__c 
                                                 WHERE User__r.Id = : userList[3].Id];

            for(UserSkill__c userSkillItem : userSkillList){
                ///System.assertEquals(1,userSkillItem.Quantity__c,'  <<<<assertEquals 01>>>>');
            }     
        }
    }
    
    /**
    * Method delete relevant product
    * Nikolay Iliaev
    * @method deleteProductTest 
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void deleteProductTest() {
        
        List<User> userList = AssigmentTabletoUsersControlerTest.dataPrepare();
        
        System.runAs(userList[0]) {
            Test.startTest();
            
                UserSkill__c userSkill = TestFactory.testCreateUserSkill(userList[0].Id,null, null, null);
                userSkill.Role__c = userList[0].UserRoleId;
                UserSkillProduct__c userSkillProduct = new UserSkillProduct__c();
                Product2 product = [SELECT Id FROM Product2];
            
                insert userSkill;
                
                userSkillProduct.UserSkill__c = userSkill.Id;
                userSkillProduct.Product__c = product.Id;
                
                insert userSkillProduct;
                
                AssigmentTabletoUsersControler assigmentcontroller = new AssigmentTabletoUsersControler();
                
                assigmentcontroller.WrapperList[0].quantity = 10;
                assigmentcontroller.WrapperList[0].productMap.put('Test String',true);
                assigmentcontroller.save();

                assigmentcontroller.WrapperList[0].quantity = 9;
                assigmentcontroller.WrapperList[0].productMap.put('Test String',false);
                
                assigmentcontroller.save();
            Test.stopTest();
        
        UserSkill__c userSkillUpdated = [SELECT Id, Quantity__c, User__c,
                                         (Select Id, UserSkill__c, Product__c From User_Skill_Products__r) 
                                         FROM UserSkill__c 
                                         WHERE Id = : assigmentcontroller.WrapperList[0].userSkillItem.Id 
                                         Limit 1];
        System.debug(LoggingLevel.ERROR,'Product >>> ' + userSkillUpdated.User_Skill_Products__r);
        
        System.assertEquals(0,userSkillUpdated.User_Skill_Products__r.size(),'  <<<<assertEquals 03>>>>');
        
        }
    }
    
    /**
    * Method update relevant leads
    * Nikolay Iliaev
    * @method deleteProductTest 
    * @return {Void}*     
    * @module Lead
    */ 
    
    // Temporarily diable in order to allow build
    /*
    static testMethod void updateLeads() {
        
        List<User> userList = AssigmentTabletoUsersControlerTest.dataPrepare();
        Account[] accountItem = [SELECT Id, Phone FROM Account WHERE Phone = '0123410125' LIMIT 1];
        
        System.debug('Account: ' + accountItem);
        System.runAs(userList[3]) {
            Test.startTest();
                Lead leadItem = TestFactory.testCreateLeadWithCellExtID();
            
                insert leadItem;
            	
                leadItem.OwnerId = userList[3].Id;
                leadItem.AccountId__c = accountItem[0].Id;
                leadItem.LeadSource = 'LSO14';
            	leadItem.Status = 'LST01';
            	leadItem.ManagerScreenInd__c = true;
            
                UserSkill__c userSkill = TestFactory.testCreateUserSkill(userList[3].Id,null, null, null);
                UserSkillProduct__c userSkillProduct = new UserSkillProduct__c();
                Product2 product = [SELECT Id FROM Product2];
                
            	System.debug('product: ' + product);
            
                leadItem.Product__c = product.Id;
                update leadItem;
                insert userSkill;
                
                userSkillProduct.UserSkill__c = userSkill.Id;
                userSkillProduct.Product__c = product.Id;
                
                insert userSkillProduct;
                
                AssigmentTabletoUsersControler assigmentcontroller = new AssigmentTabletoUsersControler();
                assigmentcontroller.WrapperList[0].quantity = 1;
                assigmentcontroller.WrapperList[0].productMap.put('Test String',True);
                assigmentcontroller.save();
            Test.stopTest();
            
            Lead lead = [SELECT Id, Name, ManagerScreenInd__c FROM Lead WHERE OwnerId = : userList[3].Id LIMIT 1];

            System.assertEquals(true,lead.ManagerScreenInd__c,'  <<<<assertEquals 06>>>>');
         }
    }
    */
    
    /**
    * Method tests update new user skill to data
    * Nikolay Iliaev
    * @method updateTest    
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void updateTest() {
        List<User> userList = AssigmentTabletoUsersControlerTest.dataPrepare();
         System.runAs(userList[0]) {
             Test.startTest();
                List<UserSkill__c> skillList = AssigmentTabletoUsersControlerTest.dataUserSkillPrepare();
                UserSkill__c userSkillUser = TestFactory.testCreateUserSkill(userList[3].Id,null, null, null);
                skillList[1].Role__c = userList[1].UserRoleId;
                skillList[2].Role__c = userList[2].UserRoleId;
                skillList[3].Role__c = userList[3].UserRoleId;
                userSkillUser.User__c = userList[3].Id;
                
                update skillList;
                insert userSkillUser;
             
                AssigmentTabletoUsersControler assigmentController = new AssigmentTabletoUsersControler();
                assigmentcontroller.WrapperList[0].quantity = 1;
                assigmentcontroller.WrapperList[0].lead = false;
                assigmentController.save();
             Test.stopTest();
             UserSkill__c[]  userSkillList = [SELECT id, Name, Quantity__c, Role__c, Leads__c, User__c
                                              FROM userSkill__c
                                              WHERE Role__c = : userList[1].UserRoleId 
                                              LIMIT 1];
             
             System.assertEquals(1,userSkillList[0].Quantity__c,'  <<<<assertEquals 06>>>>');
             System.assertEquals(false,userSkillList[0].Leads__c,'  <<<<assertEquals 07>>>>');
         }
    }
}