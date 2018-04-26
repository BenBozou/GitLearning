trigger Lead on Lead (before Insert,after insert, before update, after update) {
/**
*   Triger for Lead object 
*   All logic is in LeadHandler 
*   Eric Fishman
*   taskid PLR-42
*   @module Leads 
*/   

    new triggerHandler('Lead');
}