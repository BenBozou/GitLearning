/**
* Test Class for UserHandler:  
*   Elad Kaplan
*   taskid PLR-1577
*   @module user
*/
@isTest(SeeAllData=true)
private class UserHandlerTest {
    
    enum PortalType { CSPLiteUser, PowerPartner, PowerCustomerSuccess, CustomerSuccess }

    static testmethod void usertest() {
        User pu = getPortalUser(PortalType.PowerPartner, null, true);
    }
    
    public static User getPortalUser(PortalType portalType, User userWithRole, Boolean doInsert) {
        if(userWithRole == null) {  
            if(UserInfo.getUserRoleId() == null) {
                 userWithRole = [SELECT Id FROM User WHERE Profile.Name =: 'System Administrator' and UserRoleId != null and isActive = true limit 1];
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
                }
        Account a;
        Contact c;
        System.runAs(userWithRole) {
            a = new Account(name = 'TEST ACCOUNT');
            Database.insert(a);
            a.isPartner = true;
            update a;
            c = new Contact(AccountId = a.id, lastname = 'lastname');
            Database.insert(c);
        }
        Profile p = [select id
                      from profile
                     where usertype = :portalType.name()
                     limit 1];  
        String testemail = 'testCellcom@Cellcom.co.ilTest';
        User pu = new User(profileId = p.id, email = testemail,
                            Username = 'portalUserCellcom@cellcom.co.ilTest', CommunityNickname = 'portalUserCellcom',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = c.id);
        if(doInsert) {
            Database.insert(pu);
        }
        return pu;
    }
}