public without sharing class PremiseOpportunityController {
    private List<Opportunity> oppz;
    private vlocity_cmt__Premises__c premise; 
    private List<vlocity_cmt__VlocityAction__c> linkToRecord;
    
    public PremiseOpportunityController(ApexPages.StandardController controller) {
        this.premise= (vlocity_cmt__Premises__c)controller.getRecord();
    }

    public List<Opportunity> getOppz()
    {
        oppz = [Select id, Name, Account.Id, Account.Name, Owner.Alias, toLabel(RecordType.Name),CreatedDate,CloseDate 
                from Opportunity 
                where Premises__r.id = :premise.id];
        if (oppz.isEmpty()){
            return null;
        }
        return oppz;
    }
    public vlocity_cmt__VlocityAction__c getAction(){

        linkToRecord = [SELECT Id,Name,vlocity_cmt__DisplayLabel__c,vlocity_cmt__LinkType__c,vlocity_cmt__UrlParameters__c,vlocity_cmt__URL__c 
                       FROM vlocity_cmt__VlocityAction__c 
                       WHERE Name = 'LinkToRecord'];
                       
        if (linkToRecord.isEmpty()){
            return null;
        }else{
            return linkToRecord[0];
        }

    }
}