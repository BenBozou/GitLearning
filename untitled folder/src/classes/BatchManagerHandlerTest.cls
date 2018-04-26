/**
*   Test class for BatchManagerHandler
*   Author Nikolay Iliaev

*   taskid PLR-1512
*   @class BatchManagerHandlerTest
*   @module Lead
*/
@isTest 
public class BatchManagerHandlerTest {
	
    
    /**
    * Method tests insert new user BatchManager__c to data
    * Nikolay Iliaev
    * @method insertTest    
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void insertBM01Test() {
        
        BatchManager__c batchManager = new BatchManager__c(Action__c = 'BM01');
        Test.startTest();
        	insert batchManager;
        Test.stopTest();
    }
    
    /**
    * Method tests insert new user BatchManager__c to data
    * Nikolay Iliaev
    * @method insertTest    
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void insertBM02Test() {
        
        BatchManager__c batchManager = new BatchManager__c(Action__c = 'BM02');
        Test.startTest();
        	insert batchManager;
        Test.stopTest();
    }
    
    
    /**
    * Method tests insert new user BatchManager__c to data
    * Eric Fishman
    * @method insertTest    
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void insertBM04Test() {
        
        BatchManager__c batchManager = new BatchManager__c(Action__c = 'BM04');
        Test.startTest();
        	insert batchManager;
        Test.stopTest();
    }
}