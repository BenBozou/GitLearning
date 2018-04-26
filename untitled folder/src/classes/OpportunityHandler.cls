public with sharing class OpportunityHandler implements triggerHandler.triggerInterface{
    
/**
* Class to handle Opportunity object trigger:  
* Eric Fishman
* taskid PLR-
* @class OpportunityHandler
* @module Lead 
*/

public static Boolean allowOpportunutyQuantityChange = false;

    public void insertRecords() {
    }
    
    
    public void updateRecords() {
        if (Trigger.isBefore) {
            //triggerHandler.isPreventLoop = false;
            PreventProductDelete();
        }
        
    }
    public void deleteRecords() {}
    public void undeleteRecords() {}
    

/**
    * Class to invoke prevent Opp Product Delete
    * Eric Fishman
    * taskid PLR-
    * @class 
    * @module Lead 
    */
    
private void PreventProductDelete() {
List<Opportunity> oppsList = new List<Opportunity>();    
Map<Id,Opportunity> oppOldMap =  (Map<Id,Opportunity>)trigger.oldMap;
Map<Id,Opportunity> oppNewMap = (Map<Id,Opportunity>)trigger.NewMap;

set<id> changedOppIds = triggerHandler.getIdsOfChangedRecords(trigger.new, trigger.oldMap, new set<string>{'TotalOpportunityQuantity'});

  system.debug(Logginglevel.ERROR,'>>> changedOppIds: ' + changedOppIds);

    if (!allowOpportunutyQuantityChange) {
        for (Id item : changedOppIds){
            Opportunity oppItem = (Opportunity) trigger.newMap.get(item);
            oppsList.add(oppItem);
        }
    }
     
     system.debug(Logginglevel.ERROR,'>>> oppsList: ' + oppsList);
     
    if (!oppsList.isEmpty()) {
        // get Opportunity Products 
        AggregateResult[] oppLineResults = [SELECT SUM(Quantity) quantity, OpportunityId 
                                            FROM OpportunityLineItem 
                                            WHERE OpportunityId in : oppsList
                                            GROUP BY OpportunityId];

        for (AggregateResult ar : oppLineResults ) {
            Id oppId = (Id)ar.get('OpportunityId');
            Decimal oppQty = oppOldMap.get(oppId).TotalOpportunityQuantity;
            if (oppQty > (Decimal)ar.get('quantity') ){
               oppNewMap.get((ID)ar.get('OpportunityId')).addError (Label.DelOppProductError);
           }
        }
    }
}

}