@isTest
public class TestFactory {

    public static Contact testCreateContact() {
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Contact C = (Contact) new testFramework('Contact', null, settings).createObject();
        return C;
    }

    public static Account testCreateAccountAndContact() {
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Account A = (Account) new testFramework('Account', null, settings).createObject();

        insert A;

        Contact C = (Contact) new testFramework('Contact', new map<String, Object> {
                'AccountId' => A.id
            }, settings).createObject();
        
        insert C;

        List<AccountContactRelation> acrList = [SELECT RoleFunction__c FROM AccountContactRelation WHERE AccountId =: A.id AND ContactId =: C.id];
        if(acrList.size() > 0) {
            acrList[0].RoleFunction__c = 'P';
            update acrList[0];
        }

        return A;

    }
    
    public static Account testCreateAccAndContConsumer() {
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
                
        Account A = (Account) new testFramework('Account', new map<String, Object> {
            'RecordTypeId' => RecordTypeService.getSelectiveRecordTypeIdByName('Account', 'Consumer')
            }, settings).createObject();                

        insert A;                

        Contact C = (Contact) new testFramework('Contact', new map<String, Object> {
                'AccountId' => A.id                
            }, settings).createObject();
        
        insert C;

        List<AccountContactRelation> acrList = [SELECT RoleFunction__c FROM AccountContactRelation WHERE AccountId =: A.id AND ContactId =: C.id];
        if(acrList.size() > 0) {
            acrList[0].RoleFunction__c = 'P';
            update acrList[0];
        }

        return A;

    }

    public static Account testCreateAccount() {
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Account A = (Account) new testFramework('Account', null, settings).createObject();
        insert A;

        return A;
    }
    
    
    /**
    *   Create an AccountTeamMember
    *   author
    *   @method CreateAccountTeamMember
    *   @return {AccountTeamMember }
    *
    */
    public static AccountTeamMember CreateAccountTeamMember(Id accountId, Id userId, String accessLevel, Boolean insertRecord)
    {
        AccountTeamMember ATM      = new AccountTeamMember();
        ATM.AccountId              = accountId;
        ATM.UserId                 = userId;
        ATM.AccountAccessLevel     = accessLevel;
        ATM.ContactAccessLevel     = accessLevel;
        ATM.OpportunityAccessLevel = accessLevel;
        ATM.CaseAccessLevel        = accessLevel;
        
        if(insertRecord == true){
            insert ATM;
        }
        return ATM;
    }
    
    /**
    *   method Create environment setting (Custom setting) to simulate working from DEV environment
    *   author Elad Iflah
    *   taskId PLR-874
    *
    *   @method testCreateEnvSettForCurrentEnv
    *   @return {EnvironmentSettings__c}
    *
    */
    public static EnvironmentSettings__c testCreateEnvSettForCurrentEnv() {
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        EnvironmentSettings__c E = (EnvironmentSettings__c) new testFramework('EnvironmentSettings__c', new map<String, Object> {
            'CurrentEnvironment__c' => 'DEV',
            'SetupOwnerId' => Userinfo.getOrganizationId()
            }, settings).createObject();

        insert E;

        return E;
    }

    /**
    *   method Create Consumer Account with Connected Billing Accounts, NV and Cellcom.
    *   author Elad Iflah
    *   taskId PLR-874
    *
    *   @method testCreateAccountWithBillingAccs
    *   @return {Account}
    *
    */
    public static Account testCreateAccountWithBillingAccs() {

        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
                'countObjects' => 1
        };

        Account A = (Account) new testFramework('Account', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488151'
            }, settings).createObject();

        insert A;

        Account ACell = (Account) new testFramework('Account', new map<String, Object> {
            'CELL_Ind__c' => true,
            'BANPSID__c' => '221691774',
            'ParentId' => A.Id
            }, settings).createObject();

           insert ACell;

        Account ANv = (Account) new testFramework('Account', new map<String, Object> {
            'NETV_Ind__c' => true,
            'BANPSID__c' => '1545757',
            'ParentId' => A.Id
            }, settings).createObject();

        insert ANv;

        Contact C = (Contact) new testFramework('Contact', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488151',
            'AccountId' => A.Id
            }, settings).createObject();

        insert C;

        List<AccountContactRelation> acrList = [SELECT RoleFunction__c FROM AccountContactRelation WHERE AccountId =: A.id AND ContactId =: C.id];
        if(acrList.size() > 0) {
            acrList[0].RoleFunction__c = 'P';
            update acrList[0];
        }

        return A;
    }

    /**
    *   method Create accouunt and contact with CellcomExternalID
    *   author Nikolay Iliaev
    *   taskId PLR-42
    *
    *   @method testCreateContactAndAccountWithCellExtID
    *   @return {Contact}
    *
    */
    public static Contact testCreateContactAndAccountWithCellExtID(){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Account A = (Account) new testFramework('Account', null, settings).createObject();

        insert A;

        Contact C = (Contact) new testFramework('Contact', new map<String, Object> {
                'CellcomExternalID__c' => 'OB000001',
                'AccountId' => A.Id
                }, settings).createObject();

        insert C;

        return C;
    }

    /**
    *   method Create lead Connected to account and contact
    *   author Tal Sabati
    *   taskid PLR-633
    *
    *   @method testCreateLeadWithAccountAndContact
    *   @return {Lead}
    *
    */
    public static Lead testCreateLeadWithAccountAndContact() {

        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Contact C = (Contact) new testFramework('Contact', null, settings).createObject();
        insert C;

        Account A = (Account) new testFramework('Account', new map<String, Object> {
        'vlocity_cmt__PersonContactId__c' => C.id
        }, settings).createObject();
        
        insert A;

        Lead L = (Lead) new testFramework('Lead', new map<String, Object> {
            'ContactId__c' => C.id,
            'AccountId__c' => A.id
            }, settings).createObject();

        insert L;
        return L;
    }

    /**
    *   method Create interactionEvent Connected to account and contact
    *   author Nikolay Iliaev
    *   Taskid PLR-683
    *
    *   @method testCreateContactAndAccountWithCellExtID
    *   @return {Contact}
    *
    */
    public static void testCreateInteractionEvent(){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
        String businessRecordTypeId = RecordTypeService.getRecordTypeIdByName('Account', 'Business');
        Account businessAccount = (Account) new testFramework('Account', new map<String, Object> {
            'RecordTypeId' => businessRecordTypeId
            }, settings).createObject();
        insert businessAccount;
        
        String consumerRecordTypeId = RecordTypeService.getRecordTypeIdByName('Account', 'Consumer');
        Account consumerAccount = (Account) new testFramework('Account', new map<String, Object> {
            'RecordTypeId' => consumerRecordTypeId
            }, settings).createObject();
        insert consumerAccount;
        
        Contact C = (Contact) new testFramework('Contact', new map<String, Object> {
                'AccountId' => businessAccount.Id
                }, settings).createObject();
        insert C;

        Lead L = (Lead) new testFramework('Lead', new map<String, Object> {
            'Phone' => '123'
            }, settings).createObject();
        insert L;
        
        InteractionEvent__c interactionEventWithBusinessAccount = (InteractionEvent__c) new testFramework('InteractionEvent__c', new map<String, Object> {
            'URL__c' => '/apex/SearchScreen',
            'Name' => 'Test console Url',
            'AccountId__c' => businessAccount.id,
            'CustomerSegment__c' => 'B2B'
            }, settings).createObject();
        insert interactionEventWithBusinessAccount;
        
        InteractionEvent__c interactionEventWithConsumerAccount = (InteractionEvent__c) new testFramework('InteractionEvent__c', new map<String, Object> {
            'URL__c' => '/apex/SearchScreen',
            'Name' => 'Test console Url',
            'AccountId__c' => consumerAccount.id,
            'CustomerSegment__c' => 'B2C'
            }, settings).createObject();
        insert interactionEventWithConsumerAccount;
        
        InteractionEvent__c interactionEventWithContact = (InteractionEvent__c) new testFramework('InteractionEvent__c', new map<String, Object> {
            'URL__c' => '/apex/SearchScreen',
            'Name' => 'Test console Url',
            'ContactId__c' => C.id
            }, settings).createObject();
        insert interactionEventWithContact;
        
        InteractionEvent__c interactionEventWithLead = (InteractionEvent__c) new testFramework('InteractionEvent__c', new map<String, Object> {
            'URL__c' => '/apex/SearchScreen',
            'Name' => 'Test console Url',
            'PhoneNumber__c' => '123'
            }, settings).createObject();
        insert interactionEventWithLead;
    }
    /**
    *   method Create Lead with CellcomExternalID
    *   author Nikolay Iliaev
    *   taskId PLR-42
    *
    *   @method testCreateLeadWithCellExtID
    *   @return {Lead}
    *
    */
    public static Lead testCreateLeadWithCellExtID(){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Lead L = (Lead) new testFramework('Lead', new map<String, Object> {
            'CellcomExternalID__c' => 'OB0000025',
            'Name' => 'TestB2C',
            'LeadRecordType__c' => 'B2B',
            'Status' => 'LST05'
            }, settings).createObject();

        return L;
    }

    /**
    *   method Create Lead with Owner
    *   author Mohammad Garrah
    *   taskId PLR-1022
    *
    *   @method testCreateLead
    *   @param {Id} userId
    *   @return {Lead}
    *
    */
    public static Lead testCreateLead(Id userId){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Lead L = (Lead) new testFramework('Lead', new map<String, Object> {
            'Name' => 'Test lead',
            'Status' => 'LST01',
            'LeadSource' => 'LSO13',
            'OwnerId' => userId
            }, settings).createObject();

        insert L;

        return L;
    }

    /**
    *   method Create product type Cunsomer
    *   author Eliran Shalom
    *   taskId PLR-55
    *
    *   @method testCreateProdact2
    *   @return {Product2}
    *
    */
    public static Product2 testCreateProdact2(){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Product2 P = (Product2) new testFramework('Product2',new map<String, Object> {
            'LOB__c' => 'Consumer & Business',
            'RecordType' => '0124E0000008wPZQAY',
            'IsActive' => true
            },settings).createObject();

        insert P;

        return P;
    }

    /**
    *   method Create Opportunity
    *   author Tal Sabati
    *   taskid PLR-501
    *
    *   @method testCreateOpportunity
    *   @return {Opportunity}
    *
    */
    public static Opportunity testCreateOpportunity() {

        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        Account A = (Account) new testFramework('Account', new map<String, Object> {
                'CellcomExternalID__c' => 'OB1488153'
                }, settings).createObject();
        insert A;

        Opportunity O = (Opportunity) new testFramework('Opportunity', new map<String, Object> {
                        'AccountId' => A.id
                        }, settings).createObject();

        insert O;
        return O;
    }

    /**
    *   method Create Case
    *   author Tal Sabati
    *   taskid PLR-501
    *
    *   @method testCreateCaseS
    *   @return {Case}
    *
    */
    public static Case testCreateCase() {

        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        Account A = (Account) new testFramework('Account', new map<String, Object> {
                'CellcomExternalID__c' => 'OB1488150'
                }, settings).createObject();
        insert A;

        Case C = (Case) new testFramework('Case', new map<String, Object> {
                'AccountId' => A.id
                }, settings).createObject();

        insert C;
        return C;
    }

    /**
    *   method Create User
    *   author Nikolay Iliaev
    *   taskId PLR-444
    *
    *   @method testCreateUser
    *   @return {User}
    *
    */
    public static User testCreateUser() {
        User U = testFramework.createUser(null);
        insert U;

        return U;
    }

    /**
    *   method Create User
    *   author Mohammad Garrah
    *
    *   @method testCreateUser
    *   @param {String} fName
    *   @param {String} lName
    *   @param {String} userName
    *   @return {User}
    *
    */
    public static User testCreateUser(String fName, String lName, String userName) {
        User U = testFramework.createUser(null);
        U.FirstName = fName;
        U.LastName = lName;
        U.UserName = userName;
        insert U;

        return U;
    }

    /**
    *   method Create UserSkill without Id
    *   author Mohammad Garrah
    *   taskId PLR-1018
    *
    *   @method testCreateUserSkill
    *   @param {Id} userId
    *   @param {Integer} quantityUtilized
    *   @param {Datetime} lastRunDate
    *   @return {UserSkill__c}
    *
    */
    public static UserSkill__c testCreateUserSkill(Id userId, Integer QuantityUtilizedPerHour, Integer quantityUtilized, Datetime lastRunDate){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        UserSkill__c uSkill = (UserSkill__c) new testFramework('UserSkill__c', new map<String, Object> {
            'User__c' => userId,
            'Quantity__c' => 20,
            'QuantityUtilizedPerHour__c' => QuantityUtilizedPerHour,
            'QuantityUtilized__c' => quantityUtilized,
            'LastRunDate__c' => lastRunDate,
            'HotLead__c' => true,
            'Existing__c' => true,
            'Leads__c' => true
            }, settings).createObject();

        return uSkill;
    }

    /**
    *   method Create UserSkillProduct without Id
    *   author Mohammad Garrah
    *   taskId PLR-1023
    *
    *   @method testCreateUserSkillProduct
    *   @param {Id} userSkillId
    *   @param {Id} ProductId
    *   @return {UserSkillProduct__c}
    *
    */
    public static UserSkillProduct__c testCreateUserSkillProduct(Id userSkillId, Id ProductId){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        UserSkillProduct__c uSkillProduct = (UserSkillProduct__c) new testFramework('UserSkillProduct__c', new map<String, Object> {
            'UserSkill__c' => userSkillId,
            'Product__c' => ProductId
            }, settings).createObject();

        return uSkillProduct;
    }

    /**
    *   method Create UserRole
    *   author Nikolay Iliaev
    *   taskId PLR-444
    *
    *   @method testCreateUserRoles
    *   @return {List<UserRole>}
    *
    */
    public static List<UserRole> testCreateUserRoles(){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 4
        };

        List<UserRole> userRoleList = (List<UserRole>) new testFramework('UserRole', new map<String, Object> {
            }, settings).createObjects();

        insert userRoleList;

        return userRoleList;
    }

    /**
    *   method Create Business Account with two level Connected Business accounts and Billing Accounts, NV and Cellcom.
    *   author Giliy
    *   taskId PLR-135
    *
    *   @method testCreateBusinessAccounts
    *   @return {Account}
    *
    */
    public static Account testCreateBusinessAccounts() {

        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
                'countObjects' => 1
        };

        String recordTypeId = RecordTypeService.getRecordTypeIdByName('Account', 'Business');

         Account A = (Account) new testFramework('Account', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488154',
            'RecordTypeId' => recordTypeId
            }, settings).createObject();

        insert A;

        Account ACell = (Account) new testFramework('Account', new map<String, Object> {
            'CELL_Ind__c' => true,
            'BANPSID__c' => '221691774',
            'ParentId' => A.Id
            }, settings).createObject();

           insert ACell;

        Account ANv = (Account) new testFramework('Account', new map<String, Object> {
            'NETV_Ind__c' => true,
            'BANPSID__c' => '1545757',
            'ParentId' => A.Id
            }, settings).createObject();

        insert ANv;

         Account B = (Account) new testFramework('Account', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488152',
            'RecordTypeId' => recordTypeId,
            'ParentId' => A.Id
            }, settings).createObject();

        insert B;

         Account C = (Account) new testFramework('Account', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488153',
            'RecordTypeId' => recordTypeId,
            'ParentId' => B.Id
            }, settings).createObject();

        insert C;

        return C;
    }

    /**
    *   Return  AccountContactRelation List
    *   author Giliy
    *   taskId PLR-1134
    *
    *   @method testCreateAccountContactRelation
    *   @return {List<AccountContactRelation>}
    *
    */
    public static void testCreateAccountContactRelation() {

        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
                'countObjects' => 1
        };

        //String recordTypeId = RecordTypeService.getRecordTypeIdByName('Account', 'Business');

         Account A1 = (Account) new testFramework('Account', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488151'
            }, settings).createObject();

        insert A1;

        Account A2 = (Account) new testFramework('Account', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488152'
            }, settings).createObject();

           insert A2;

        Account A3 = (Account) new testFramework('Account', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488153'
            }, settings).createObject();

        insert A3;

        Contact C1 = (Contact) new testFramework('Contact', new map<String, Object> {
                'CellcomExternalID__c' => 'OB000001',
                'AccountId' => A1.Id
                }, settings).createObject();

        insert C1;

        Contact C2 = (Contact) new testFramework('Contact', new map<String, Object> {
                'CellcomExternalID__c' => 'OB000002',
                'AccountId' => A2.Id
                }, settings).createObject();

        insert C2;

        Contact C3 = (Contact) new testFramework('Contact', new map<String, Object> {
                'CellcomExternalID__c' => 'OB000003',
                'AccountId' => A3.Id
                }, settings).createObject();

        insert C3;

    }

    public static Lead  testCreateLeadWithRTbyAccount(Account A) {

         Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        String recordTypeId = RecordTypeService.getRecordTypeIdByName('Lead', 'Offer');
            Lead L = (Lead) new testFramework('Lead', new map<String, Object> {
            'Name' => 'TestB2C',
            'RecordTypeId' => recordTypeId,
            'AccountId__c'=>A.Id
            }, settings).createObject();

        insert L;
        return L;

    }

    /**
    *   method Create Account with Customer Interaction.
    *   author Giliy
    *   taskId PLR-238
    *
    *   @method testCreateAccountAndCustomerInteraction
    *   @return {Account}
    *
    */
    public static Account testCreateAccountAndCustomerInteraction() {

        Account acc = testCreateAccountAndContact();

        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
                'countObjects' => 1
        };

        vlocity_cmt__CustomerInteraction__c C = (vlocity_cmt__CustomerInteraction__c) new testFramework('vlocity_cmt__CustomerInteraction__c', new map<String, Object> {
            'vlocity_cmt__AccountId__c' => acc.Id,
            'vlocity_cmt__Status__c' => 'In Progress'
            }, settings).createObject();

        insert C;

        return acc;
    }

    /**
    *   method Create Business Account with two level Connected Business accounts and Billing Accounts, NV and Cellcom.
    *   author Elad Iflah
    *   taskId PLR-1038
    *
    *   @method testCreateVlocityAction
    *   @return {vlocity_cmt__VlocityAction__c}
    *
    */
    public static vlocity_cmt__VlocityAction__c testCreateVlocityAction() {

        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
                'countObjects' => 1
        };

        vlocity_cmt__VlocityAction__c VA = (vlocity_cmt__VlocityAction__c) new testFramework('vlocity_cmt__VlocityAction__c', new map<String, Object> {
            'Name' => 'B2B Recommendations - Open Lead',
            'vlocity_cmt__DisplayLabel__c' => 'B2CRecomAction',
            'vlocity_cmt__URL__c' => 'http:\\www.google.com'
            }, settings).createObject();

        insert VA;

        return VA;
    }
    
    /**
    *   method Create Task
    *   author Nikolay Iliaev
    *   taskId PLR-1363
    *
    *   @method createTask
    *   @return {Task}
    *
    */
    public static Task createTask() {
        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
                'countObjects' => 1
        };
        Task T = (Task) new testFramework('Task', null, settings).createObject();

        return T;
    }
    
    
    /**
    *   method Create Event
    *   author Eric Fishman
    *   taskId PLR-1336    *
    *   @method testGeneralEvent
    *   @return {Event}
    *
    */
    public static Event testCreateEvent(String subject){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Event event = (Event) new testFramework('Event', new map<String, Object> {
            'Subject' => subject,
            'Startdatetime' => Datetime.now(),
            'Enddatetime' => Datetime.now()+1,
            'OwnerID' => Userinfo.getuserId()
            }, settings).createObject();
        return event;
    }
    
    /**
    *   method Create Task For Customer Folder.
    *   author Giliy
    *   taskId PLR-122
    *
    *   @method createCustomerFolderTask
    *   @return {Task}
    *
    */
    public static Task createCustomerFolderTask() {
        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
            'countObjects' => 1
        };
        Task T = (Task) new testFramework('Task', new map<String, Object> {
            'Status' => 'TST04',
            'OwnerID' => Userinfo.getuserId()
            }, settings).createObject();

        return T;
    }
    
    /**
    *   method Creates Sela__c object.
    *   author Nikolay Iliaev
    *   taskId PLR-1430
    *
    *   @method createSelaObject
    *   @return {Sela__c}
    *
    */
    public static Sela__c createSelaObject() {
        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
            'countObjects' => 1
        };
        Sela__c S = (Sela__c) new testFramework('Sela__c', new map<String, Object> {
            'OwnerID' => Userinfo.getuserId()
            }, settings).createObject();

        return S;
    }
    
    
    /**
    *   method Create Account Team Member
    *   author Elad Iflah
    *   taskId Elevate code coverage
    *   @method testCreateAccTeamMemb
    *   @return {AccountTeamMember}
    *
    */
    public static AccountTeamMember testCreateAccTeamMemb(String userName, String accId){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        AccountTeamMember accTeamMemb = (AccountTeamMember) new testFramework('AccountTeamMember', new map<String, Object> {
            'AccountId' => accId,
            'UserId' => userName,
            'TeamMemberRole' => 'Account Manager'
            }, settings).createObject();
        
        insert accTeamMemb;
        
        return accTeamMemb;
    }
    
    /**
    *   method Create AccountShare for Account
    *   author Elad Iflah
    *   taskId Elevate code coverage
    *   @method testCreateAccShare
    *   @return {AccountShare}
    *
    */
    public static AccountShare testCreateAccShare(String accId, String GroupId){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        AccountShare accShare = (AccountShare) new testFramework('AccountShare', new map<String, Object> {
            'AccountId' => accId,
            'UserOrGroupId' => GroupId,
            'RowCause' => 'Manual',
            'AccountAccessLevel' => 'Edit',
            'OpportunityAccessLevel' => 'None',
            'ContactAccessLevel'=> 'Edit'
            }, settings).createObject();          
        
        insert accShare;
        
        return accShare;
    }
    
    /**
    *   method Create Group
    *   author Elad Iflah
    *   taskId Elevate code coverage
    *   @method testCreateGroup
    *   @return {Group}
    *
    */
    public static Group testCreateGroup(){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        Group testGroup = (Group) new testFramework('Group', new map<String, Object> {
            'Name' => 'MyGroup',
            'Type' => 'Regular'
            }, settings).createObject();        
        
        insert testGroup;
        
        return testGroup;
    } 
    
    /**
    *   method Create GroupMember
    *   author Elad Iflah
    *   taskId Elevate code coverage
    *   @method testCreateGroupMember
    *   @return {Group}
    *
    */
    public static GroupMember testCreateGroupMember(String userId, String groupId){
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };

        GroupMember testGroupMemb = (GroupMember) new testFramework('GroupMember', new map<String, Object> {
            'UserOrGroupId' => userId,
            'GroupId' => groupId
            }, settings).createObject();        
        
        insert testGroupMemb;
        
        return testGroupMemb;
    } 
    
    /**
    *   method Create Consumer Account with Connected Billing Accounts, NV and Cellcom.
    *   author Gili Yehuda
    *   taskId PLR-874
    *
    *   @method testCreateAccountWithBillingAccsCollab
    *   @return {Account}
    *
    */ 
    public static Account testCreateAccountWithBillingAccsCollab() {

        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
                'countObjects' => 1
        };

        String recordTypeId = RecordTypeService.getRecordTypeIdByName('Account', 'Billing');
        String recordTypeIdCon = RecordTypeService.getRecordTypeIdByName('Account', 'Consumer');
    
        Account A = (Account) new testFramework('Account', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488151',
            'RecordTypeId' => recordTypeIdCon,
            'CELL_Ind__c' => true,
            'NETV_Ind__c' => true           
            }, settings).createObject();

        insert A;

        Account ACell = (Account) new testFramework('Account', new map<String, Object> {
            'CELL_Ind__c' => true,
            'BANPSID__c' => '221691774',
            'ParentId' => A.Id,
            'RecordTypeId' => recordTypeId
            }, settings).createObject();

           insert ACell;

        Account ANv = (Account) new testFramework('Account', new map<String, Object> {
            'NETV_Ind__c' => true,
            'BANPSID__c' => '1545757',
            'ParentId' => A.Id,
            'RecordTypeId' => recordTypeId
            }, settings).createObject();

        insert ANv;

        Contact C = (Contact) new testFramework('Contact', new map<String, Object> {
            'CellcomExternalID__c' => 'OB1488151',
            'AccountId' => A.Id
            }, settings).createObject();

        insert C;
        
        AccountContactRelation ACR1 = (AccountContactRelation) new testFramework('AccountContactRelation', new map<String, Object> {
            'IsActive' => true,
            'AccountId' => ACell.Id,
            'ContactId' => C.Id
            }, settings).createObject();

        insert ACR1;
        
        AccountContactRelation ACR2 = (AccountContactRelation) new testFramework('AccountContactRelation', new map<String, Object> {
            'IsActive' => true,
            'AccountId' => ANv.Id,
            'ContactId' => C.Id
            }, settings).createObject();

        insert ACR2;

        List<AccountContactRelation> acrList = [SELECT RoleFunction__c, IsActive  FROM AccountContactRelation WHERE AccountId =: A.id AND ContactId =: C.id];
        if(acrList.size() > 0) {
            acrList[0].RoleFunction__c = 'P';
            acrList[0].IsActive = true;
            update acrList[0];
        }
        if(acrList.size() > 1) {
            acrList[1].IsActive = true;
            
            update acrList[1];
        }

        return A;
    }
    
    
    /**
    *   method Create Account with vlocity_cmt__Active__c = Yes , vlocity_cmt__Status__c = Inactive 
    *   for AccountActiveFlagUpdateOneShotBatch
    *   author Elad Iflah
    *   taskId NO US
    *
    *   @method testCreateAccountStatusInactive
    *   @return {Account}
    *
    */
    public static Account testCreateAccountStatusInactive() {

        Map<String,Object> settings = new Map<String,Object> {
            'createlookupobject' => false,
                'countObjects' => 1
        };

        Account A = (Account) new testFramework('Account', new map<String, Object> {
            'vlocity_cmt__Active__c' => 'Yes',
            'vlocity_cmt__Status__c' => 'Inactive'
            }, settings).createObject();

        insert A;
        
        return A;

    }
    
}