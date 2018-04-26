public with sharing class ManagerScreenControler {
        public Decimal remainsDivided {get;set;}
        public user currentUser {get;set;}

        public ManagerScreenControler(){
            list<User> currentUser_List = new list<User>();
            currentUser_List = [select Name,UserRole.Name,IsActive,UserRoleId, (Select Records_Amount__c, Russian__c, Arabic__c, TV__c, ISP__c, Wholesale_Market__c, Mobile__c, HotCold__c, Potential__c From Users_Assignment__r) from User where Name =: 'Yaniv Gabay' and IsActive =true limit 1];
            currentUser = currentUser_List[0];
        }
}