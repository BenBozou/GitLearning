public class VlocityCommunityController {

    //Home page widgets
    public Contact currentContact {get; set;}
    public Account currentAccount {get; set;}
    //public Account demoAccount1 {get; set;}
    //public Account demoAccount2 {get; set;}
    //public Account demoAccount3 {get; set;}
    //public List<Attachment> listAttachments {get;set;}
    //public List<Case> listCases {get; set;}
    //public List<Idea> listIdeas {get; set;}
    //public List<Order> listOrders {get; set;}
    //public List<Product2> listProducts {get;set;}
   // public List<vlocity_cmt__OmniScriptInstance__c> listScripts {get;set;}
    //public List<vlocity_cmt__StatementLineItem__c> listUsage {get;set;}
    public String accountKey {get;set;}
    public User currentUser {get;set;}
    
    //Card properties
    public String layout {get;set;}
    public String sfInstanceUrl {get; private set;}
    public String currentInstanceUrlWithPath {get; private set;}
    
    public VlocityCommunityController(){
        DemoSetup();
    }
    
    public VlocityCommunityController(ApexPages.StandardController stdController) {
        DemoSetup();  
    }
    
    public void DemoSetup(){  
        //Widget configuration
        try{
            accountKey = ApexPages.currentPage().getParameters().get('id') != NULL? ApexPages.currentPage().getParameters().get('id'): 'demoaccount2';
            currentAccount = [SELECT id, name, shippingcity FROM Account WHERE Id = :accountKey LIMIT 1];
            currentContact = [SELECT firstname, lastname, id, phone, email FROM Contact WHERE AccountId =: accountKey LIMIT 1];
            currentUser = [SELECT id FROM User WHERE id = :userinfo.getuserId()];
            //demoAccount1 = [SELECT name, shippingcity FROM Account WHERE Vlocity_Demo_Key__c = 'demoaccount1' LIMIT 1];
            //demoAccount2 = [SELECT name, shippingcity FROM Account WHERE Vlocity_Demo_Key__c = 'demoaccount2' LIMIT 1];
            //demoAccount3 = [SELECT name, shippingcity FROM Account WHERE Vlocity_Demo_Key__c = 'demoaccount3' LIMIT 1];
            //listCases = [SELECT id, casenumber, subject, status, lastmodifieddate FROM Case WHERE Account.Vlocity_Demo_Key__c = :accountKey ORDER BY LastModifiedDate DESC LIMIT 5];
            //listIdeas = [SELECT id, title, votetotal FROM Idea ORDER BY VoteTotal DESC LIMIT 10];
            //listOrders = [SELECT id, name, OrderNumber, effectivedate, vlocity_cmt__OrderTotal__c FROM order WHERE Account.vlocity_demo_key__c = :accountKey ORDER BY EffectiveDate DESC LIMIT 8];
           // listProducts = [SELECT id, name FROM Product2 WHERE product_channel__c = 'Web' LIMIT 5];
            //listAttachments = [SELECT id, parent.name, parentid FROM Attachment WHERE parentid IN :listProducts AND name LIKE '%TN%'];
            //listScripts = [SELECT vlocity_cmt__Status__c, vlocity_cmt__OmniScriptSubType__c, vlocity_cmt__OmniScriptType__c, vlocity_cmt__ObjectId__c, vlocity_cmt__ResumeLink__c, vlocity_cmt__LastSaved__c FROM vlocity_cmt__OmniScriptInstance__c ORDER BY vlocity_cmt__LastSaved__c DESC LIMIT 10];
            //listUsage = [SELECT Id, name, vlocity_cmt__AccountId__c, vlocity_cmt__Type__c, vlocity_cmt__Amount__c FROM vlocity_cmt__StatementLineItem__c WHERE vlocity_cmt__StatementId__r.vlocity_cmt__AccountId__c = :currentAccount.id AND vlocity_cmt__StatementId__r.name = 'Current Usage Statement'];
            
            //for(vlocity_cmt__OmniScriptInstance__c script : listScripts){
                //script.vlocity_cmt__ResumeLink__c = script.vlocity_cmt__ResumeLink__c.replace(script.vlocity_cmt__ResumeLink__c.substring(script.vlocity_cmt__ResumeLink__c.indexOf('/apex/'), script.vlocity_cmt__ResumeLink__c.indexOf('?')), '/apex/VlocityDemoOmniscript');
            //}
        
        }catch(Exception e){
            System.debug(e);
        }  
        //Card configuration
        layout = ApexPages.currentPage().getParameters().get('layout') != NULL? ApexPages.currentPage().getParameters().get('layout'): 'B2CMainPreview';
        sfInstanceUrl = 'https://' + ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
        String currentRequestUrl = System.URL.getCurrentRequestUrl().toExternalForm();
        Integer posOfApexPath = currentRequestUrl.indexOf('/apex');
        currentInstanceUrlWithPath = (posOfApexPath > -1)?currentRequestUrl.substring(0,posOfApexPath):currentRequestUrl;

    }
}