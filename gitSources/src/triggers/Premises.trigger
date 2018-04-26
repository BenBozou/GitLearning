trigger Premises on vlocity_cmt__Premises__c (after update) {
/**
*   Triger for vlocity Premises__c object 
*   All logic is in PremisesHandler 
*   Eric Fishman
*   taskid PLR-1446
*   @module Leads 
*/   

    new triggerHandler('vlocity_cmt_Premises');
    
}