trigger Account on Account (after insert, after update, after delete) {
/**
*   Triger for Account object 
*   Dmitry Rivlin
*   taskid PLR-1329
*   @module Account
*/   
    new triggerHandler('Account');
}