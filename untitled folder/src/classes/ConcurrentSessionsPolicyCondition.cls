/**
* Class is invoked by Transaction Security policy
* Eric Fishman
* taskid PLR-731
* @class ConcurrentSessionsPolicyCondition
* @module Lead
* @constructor 
*/
global class ConcurrentSessionsPolicyCondition implements TxnSecurity.PolicyCondition {

	/**
	*   method to evaluate concurrent sessions
	*   author Eric Fishman
	*   taskId PLR-731
	*   @method evaluate
	*   @param  {TxnSecurity.Event} 
	*   @return {boolean}
	*
	*/
	public boolean evaluate(TxnSecurity.Event e){
		Integer MAX_USER_SESSIONS = 1;
		String profileIgnored = 'ETLLoad';
		// Select Custom Setup		
		Map<String, TransactionSettings__mdt> transactionSettingMap = new Map<String, TransactionSettings__mdt>();
		
		for (TransactionSettings__mdt transactionSetup : [Select Label, MaximumSession__c, Profile__c From TransactionSettings__mdt]) {
			transactionSettingMap.put(transactionSetup.Label, transactionSetup);
		} 
		
		MAX_USER_SESSIONS = (transactionSettingMap.get('ConcurrentAll').MaximumSession__c == null || (Integer.valueof(transactionSettingMap.get('ConcurrentAll').MaximumSession__c)) <1) ? MAX_USER_SESSIONS : 
			Integer.valueof(transactionSettingMap.get('ConcurrentAll').MaximumSession__c);
			
		profileIgnored = 	
		 transactionSettingMap.get('ConcurrentAll').Profile__c == null  ? profileIgnored : 
			transactionSettingMap.get('ConcurrentAll').Profile__c;
		
		// Get Current user's profile	
		List<User> users = [SELECT ProfileId, Profile.Name FROM User WHERE Id = :e.UserId];
		String profileName = users[0].Profile.Name;
		 
		
		// check profile to ignore profiles  based on setup
		if (profileIgnored.containsIgnoreCase(profileName)) {
		    return false;
        }
		
		List<AuthSession> sessions
			= [SELECT Id, CreatedDate, LastModifiedDate, NumSecondsValid, SessionType
			  FROM AuthSession
			  WHERE UsersId =: e.UserId and ParentId = NULL];		
			
		//system.debug(' >>> sessions' + sessions); 
		//system.debug(' >>> profileIgnored' + profileIgnored); 
		//system.debug(' >>> profileName' + profileName); 
		
		if (profileIgnored.containsIgnoreCase(profileName)) {
		    //system.debug(' >>> 	return  false before query' ); 
			return false;
		}
		
		Map<String, String> sessionsToIgnore = (Map<String, String>)Auth.SessionManagement.ignoreForConcurrentSessionLimit(sessions); 
		Integer activeSessions = 0; 
		
		for (AuthSession s : sessions) {
			DateTime d = (DateTime)s.get('LastModifiedDate');
			Integer n = (Integer)s.get('NumSecondsValid');
			String type = (String)s.get('SessionType');
			String sessionId = (String)s.get('Id');
			
			if(sessionsToIgnore.get(sessionId).equals('false')) {
				if(d.addSeconds(n) >= DateTime.now()) {
					activeSessions = activeSessions + 1;
				}
				
				 system.debug(' >>> 	activeSessions  ' + activeSessions ); 
				 	// check profile to ignore profiles  based on setup
					if (profileIgnored.containsIgnoreCase(profileName)) {
						return false;
					}
					else {
						if(activeSessions > MAX_USER_SESSIONS) {	
							return true;
						}		
					}
			}
		}
		
		return false;

	}
	
	
	
	
}