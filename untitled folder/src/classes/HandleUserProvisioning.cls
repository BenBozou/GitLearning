/**
*   This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization. 
*   author Eric Fishman
*   taskId PLR-*
*   @method HandleUserProvisioning
*   @param  {}
*   @return 
*
*/
//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class HandleUserProvisioning implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    private void handleUser(boolean create, User u, Map<String, String> attributes, String federationIdentifier, boolean isStandard, Account a) {
        
        if(create) {
            if(attributes.containsKey('username')) {
                u.Username = attributes.get('username') + '@cellcom.co.il';
            }
            if(attributes.containsKey('username')) {
                u.FederationIdentifier = attributes.get('username');
            } else {
                u.FederationIdentifier = federationIdentifier;
            }
            u.Email = attributes.get('username') + '@cellcom.co.il';
        }

        if(attributes.containsKey('firstName')) {
            u.FirstName = attributes.get('firstName');
        }
        if(attributes.containsKey('lastName')) {
            u.LastName = attributes.get('lastName');
        }
        u.CompanyName = a.Name;
        if(attributes.containsKey('username')) {
            u.CommunityNickname = attributes.get('username');
        }
                
        if(attributes.containsKey('UserOUName')) {
        	u.DealerCode__c = attributes.get('UserOUName');
        }
/*
        u.ReceivesAdminInfoEmails = true;
        u.ReceivesInfoEmails = true;
*/            
        String uid = UserInfo.getUserId();
        User currentUser = 
            [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
        if(create) {
            u.LocaleSidKey = currentUser.LocaleSidKey;
        }
        if(create) {
            u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        }
        if(create) {
            String alias = '';
            if(u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            if(alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
        }
        if(create) {
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        }
        if(create) {
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
        }

        /*
         * If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
         * If your identity provider sends these User fields as attributes along with Contact 
         * or Account fields, you must modify the logic in this class to update either these 
         * User fields or the Contact and Account fields.
         */
        /*if(attributes.containsKey('User.IsActive')) {
            String IsActiveVal = attributes.get('User.IsActive');
            u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
        }
            
        u.ForecastEnabled = false;
        if(create) {
            String profileId = '00e58000000EKFz';
            Profile p = [SELECT Id FROM Profile WHERE Id=:profileId];
            u.ProfileId = p.Id;
       
            String userRole = a.Name + 'PartnerUser';
            userRole = userRole.replaceAll('\\s+', '');
            UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName =:userRole];
            u.UserRoleId = r.Id;
        }
*/
        
        String portalProfile = 'Vlocity Partner User';
        Profile p = [SELECT Id FROM Profile WHERE Name =: portalProfile];
        u.ProfileId = p.Id;
        //Handle custom fields here

        if(!create) {
            update(u);
        }
    }

    private void handleContact(boolean create, String accountId, User u, Map<String, String> attributes) {
        Contact c;
        boolean newContact = false;
        if(create) {
            c = new Contact();
            newContact = true;
        } else {
            String contact = u.ContactId;
            c = [SELECT Id, AccountId FROM Contact WHERE Id=:contact];
        }
        if(!newContact && c.AccountId != accountId) {
            throw new JitException('Mismatched account: ' + c.AccountId + ', ' + accountId);
        }
        
        if(attributes.containsKey('firstName')) {
            c.FirstName = attributes.get('firstName');
        }
        if(attributes.containsKey('lastName')) {
            c.LastName = attributes.get('lastName');
        }
        //c.LastName = 'BenPartner';

        if(newContact) {
            c.AccountId = accountId;
            insert(c);
            u.ContactId = c.Id;
        } else {
            update(c);
        }
    }

    private Account handleAccount(boolean create, User u, Map<String, String> attributes) {
        Account a;        
        if(attributes.containsKey('UserOUName')) {        	
            String account = attributes.get('UserOUName');
            a = [SELECT Id, Name, IsPartner FROM Account WHERE CellcomExternalID__c =: account]; 
            
            /// to check if Account is Partner Enable
            if (a != null && a.IsPartner==false) {
            	throw new JitException('Account is not enabled for Patner Community. Please contact your Administrator');
            } 
            
        } else {
            throw new JitException('Dealer not specified');
        }

        return a;
    }

    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        if(communityId != null || portalId != null) {
            Account account = handleAccount(create, u, attributes);
            handleContact(create, account.Id, u, attributes);
            handleUser(create, u, attributes, federationIdentifier, false, account);
        } else {
            handleUser(create, u, attributes, federationIdentifier, true, null);
        }
    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
            system.debug('Create user');
        handleJit(true, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
            system.debug('Update user');
        User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
    }
}