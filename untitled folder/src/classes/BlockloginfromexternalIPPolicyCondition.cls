global class BlockloginfromexternalIPPolicyCondition implements TxnSecurity.PolicyCondition {
    
    private final string GENERAL_WHITELISTED_IP = '192.118.30.102';
    private final string SALESFORCE_IP = 'Salesforce.com IP';
    
    public boolean evaluate(TxnSecurity.Event e) {
        boolean isInRange = false;
        LoginHistory eObj = null;
        if (Test.isRunningTest()) { } else { eObj = [SELECT SourceIp FROM LoginHistory WHERE Id = :e.data.get('LoginHistoryId')  limit 1];}

        
        List<AllowedIPRangeLogin__mdt> listIPRanges = [SELECT Start_IP__c, End_IP__c FROM AllowedIPRangeLogin__mdt];
                
        for (AllowedIPRangeLogin__mdt ipRange : listIPRanges) {
            if (eObj != null && eObj.SourceIp.compareTo(ipRange.Start_IP__c) >= 0 && eObj.SourceIp.compareTo(ipRange.End_IP__c) <= 0) {
                isInRange = true;
            }
        }
        
        if(eObj != null && (eObj.SourceIp == GENERAL_WHITELISTED_IP || eObj.SourceIp == SALESFORCE_IP || isInRange)){
            return false;
        }
        
        return true;
    }
    
}