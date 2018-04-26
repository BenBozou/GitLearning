/**
* Class is invoked by Transaction Security policy
* Eric Fishman
* taskid PLR-731
* @class LoginSessionsPolicyCondition
* @module Lead
* @constructor 
*/
global class LoginRestrictionPolicyCondition implements TxnSecurity.PolicyCondition {    
    /**
	*   method to evaluate login sessions
	*   author Eric Fishman
	*   taskId PLR-731
	*   @method evaluate
	*   @param  {TxnSecurity.Event} 
	*   @return {boolean}
	*
	*/
    public boolean evaluate(TxnSecurity.Event e) {
    	Integer maxSession = 1100;
    	Map<String, TransactionSettings__mdt> transactionSettingMap = new Map<String, TransactionSettings__mdt>();
		for (TransactionSettings__mdt transactionSetup : [Select Label, MaximumSession__c, Profile__c From TransactionSettings__mdt]) {
			transactionSettingMap.put(transactionSetup.Label, transactionSetup);
		}
															
        String profileB2CName = transactionSettingMap.get('LoginB2C').Profile__c; //'CSR-B2C';        
        maxSession = (transactionSettingMap.get('LoginB2C').MaximumSession__c == null || (Integer.valueof(transactionSettingMap.get('LoginB2C').MaximumSession__c)) <1) ? maxSession : 
                Integer.valueof(transactionSettingMap.get('LoginB2C').MaximumSession__c);    
     
        // Prepare list of Profiles for query
        String profileB2CNames = transactionSettingMap.get('LoginB2C').Profile__c; //'CSR-B2C';
     	List<String> pfList = new List<String>();
		pfList = profileB2CNames.split(',');	
		
		Map<Id,Profile> profileB2CMap = new Map<Id,Profile>( [SELECT Id from Profile WHERE Name IN : pfList]);

        List<AuthSession> sessions = [SELECT Id, CreatedDate, LastModifiedDate, NumSecondsValid, SessionType, UsersId 
        								FROM AuthSession 
        								Where UsersId IN 
        									(SELECT Id From User Where ProfileId in :profileB2CMap.keyset()) and ParentId = NULL];

        Map<String, String> sessionsToIgnore = (Map<String, String>)Auth.SessionManagement.ignoreForConcurrentSessionLimit(sessions);
        Set<Id> userId = new Set<Id>();
        
        Integer activeSessions = 0;
        for (AuthSession s : sessions) {
            DateTime d = (DateTime)s.get('LastModifiedDate');
            Integer n = (Integer)s.get('NumSecondsValid');
            String type = (String)s.get('SessionType');
            String sessionId = (String)s.get('Id');
            if(sessionsToIgnore.get(sessionId).equals('false')) {
                if(d.addSeconds(n) >= DateTime.now() && !userId.contains(s.UsersId) && s.UsersId != e.UserId) {
                    activeSessions = activeSessions + 1;
                    userId.add(s.UsersId);
                }
            }
        }
        
		
        if (activeSessions >= maxSession) {
            return true;
        }
        
        return false; 
    }
}