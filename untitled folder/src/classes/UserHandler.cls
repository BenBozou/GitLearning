/**
* Class to handle User object trigger:  
*   Elad Kaplan
*   taskid PLR-1577
*   @module user
*/
public with sharing class UserHandler implements triggerHandler.triggerInterface {
    public void insertRecords() {   
        if(Trigger.isBefore){
            deativateCommunityUsersOnCreate(trigger.New);
        }
    }
        
  public void deleteRecords() {
    }
    
    public void undeleteRecords() {
    }
  
  public void updateRecords() {
    }
    
    private void deativateCommunityUsersOnCreate(list<User> newUsers_List) {

        list<User> users_List = new list<User>();
        set<Id> partnerProfileIds_Set = new set<Id>();
        
        for (Profile partnerProfile : [SELECT Id FROM Profile WHERE UserLicense.Name =: 'Partner Community']) {
            partnerProfileIds_Set.add(partnerProfile.Id);
        }

        
        for (User newUser : newUsers_List) {
            if (partnerProfileIds_Set.contains(newUser.ProfileId)) {
                newUser.isActive = false;
                newUser.UserPreferencesActivityRemindersPopup = true;
                users_List.add(newUser);
            }
        }
        
        if (!users_List.isEmpty()) {
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = false;
            
            try {    
                Database.insert(users_List, dmlo);
            }
            
            catch(Exception e) {
                system.debug('could not insert dml : ' + e.getMessage());
            }
        }
    }
   
}