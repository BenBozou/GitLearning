public without sharing class CreateLeadServiceJC
{
    public static void createExternalLead()
    {
        try
        {
            Leads__x leadX = new Leads__x();
            leadX.ssn__c= '123456789';           
            leadX.company_number__c = '12345654123'; 
            leadX.id_type_sf__c = 'I';  
            leadX.transactionId__c = '00Q4E000002HfHw';
                
                //'00Q4E000002FkDN';
            
            
            
            System.debug(' Current User :' + userInfo.getusername());   
            
            System.debug(' NewLead IDATA leadX :' + leadX);   
            OdataSaveCallBackService callback = new OdataSaveCallBackService();
            Database.SaveResult sr = Database.insertAsync(leadX);
//            Database.SaveResult sr = Database.insertImmediate(leadX);
            
            /*System.debug('ODATA SaveResult :' + sr);
            String locator = Database.getAsyncLocator ( sr );             
            System.debug('External locator:' + locator);                
            //System.debug('External getAsyncSaveResult:' + Database.getAsyncSaveResult(sr));   
            
            if (!sr.isSuccess ())
            {            
                System.debug('ODATA Error to create it synchronically. The process is in a queue' );
            }
            else
            {
                System.debug('>>>> 10 External SequenceID: ' + sr.getId());
            }*/
        }
        catch (Exception e) {
            System.debug('Exception : ' + e.getStackTraceString());
        }            
    } 
    
    public class RequestLine{
       public RequestLine(String Action,String firstName,
        String lastName, String ssn, String phone, 
        String company, String companyNumber, String comments, String leadSource,
        String addressCity, String addressStreet, String lineOfBusiness,
        String branchesAmountForCompany, Integer numberOfEmployees, String additionalInfoFormula, String recordType){
           this.Action=Action;
           this.firstName=firstName;
           this.lastName=lastName;
           this.ssn=ssn;
           this.phone=phone;
           this.company=company;
           this.companyNumber=companyNumber;
           this.comments=comments;
           this.leadSource=leadSource;
           this.addressCity=addressCity;
           this.addressStreet=addressStreet;
           this.lineOfBusiness=lineOfBusiness;
           this.branchesAmountForCompany=branchesAmountForCompany;
           this.numberOfEmployees=numberOfEmployees;
           this.additionalInfoFormula=additionalInfoFormula;
           this.recordType=recordType;
        }
       public String Action;
       public String firstName;
       public String lastName;
       public String ssn;
       public String phone;
       public String company;
       public String companyNumber;
       public String comments;    
       public String leadSource;
       public String addressCity; 
       public String addressStreet; 
       public String lineOfBusiness; 
       public String branchesAmountForCompany; 
       public Integer numberOfEmployees; 
       public String additionalInfoFormula;
       public String recordType;            
    }
    
}