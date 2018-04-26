@isTest
public class LironTest{

    static testMethod void test1() {
    
    
        
        Lead nlead = new Lead(lastName = 'test', company='test');
        Database.SaveResult sr = Database.insert(nlead );

        
        //Leads__x leadX = new Leads__x(sequence_id__c='1234');
        //Database.SaveResult sr = database.insertAsync(leadX);
        
       
        OdataSaveCallBackService od = new OdataSaveCallBackService();
        
        od.processSave(sr);

    }
}