public class OpportunityOverride {
    public Opportunity opp {get;set;}
    
    public OpportunityOverride(ApexPages.StandardController controller) {
        opp = (Opportunity) controller.getRecord();
        opp.Amount = 0;
        opp.CampaignName__c  = 'test';
    }
}