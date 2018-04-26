trigger BatchManager on BatchManager__c (after insert) {
	/**
*   Triger for BatchManager object 
*   All logic is in BatchManagerHandler 
*   Eric Fishman
*   taskid PLR-1512
*   @module BatchManager 
*/   

    new triggerHandler('BatchManager'); 
    
}