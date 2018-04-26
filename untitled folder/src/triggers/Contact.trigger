trigger Contact on Contact (before Insert,after insert, before update, after update) {
/**
*   Triger for Contact object 
*   All logic is in ContactService 
*   Nikolay Iliaev
*   taskid PLR-42
*   @module Contact
*/   
    //triggerHandler.isPreventLoop = false;
    new triggerHandler('Contact');
}