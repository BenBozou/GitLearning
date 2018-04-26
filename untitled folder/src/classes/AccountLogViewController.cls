/**
*   Log when account record is viewed
*   
*   @class AccountLogViewController
*   author Liron Cohen
*   @module Customer View
*
*   Description: Should create log record when account record is viewed. 
*   The page AccountLogView should be added to any Account layout that being used 
*
*/
//this is test
public class AccountLogViewController {
    
    private final Account acc {get; set;}
    
    public AccountLogViewController(ApexPages.StandardController sc){
        acc = [select id, CellcomExternalID__c from Account where id = : ((Account)sc.getRecord()).id];
        
    }
    
    /**
    *   method for logging, as it cannot be done in the constructor
    *   author Liron Cohen
    *   taskId PLR-436
    *
    *   @method logAccount
    */
    public void logAccount(){
        LoggerService.writeViewMessage(
            acc.id,
            new LoggerService.ViewMessage(LoggerService.ViewMessageType.View, acc.id, acc.CellcomExternalID__c));       
    }
}