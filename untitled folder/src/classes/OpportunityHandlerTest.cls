/**
*   Test class for OpportunityHandlerTest
*   Author Eric Fishman

*   taskid PLR-
*   @class OpportunityHandlerTest
*   @module Lead
*/
@isTest 
public with sharing class OpportunityHandlerTest {
	
	 /**
    * Method tests insert new user BatchManager__c to data
    * Eric Fishman
    * @method insertTest    
    * @return {Void}*     
    * @module Lead
    */
     @testSetup 
    static void setupTestData(){
        
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
        User u = TestFactory.testCreateUser();       
        //Opportunity opp = TestFactory.testCreateOpportunity();
          //Create Account
        String recordTypeId = RecordTypeService.getRecordTypeIdByName('Account', 'Business'); 
        
        Account acc = (Account ) new testFramework(
                            'Account', 
                            new map<String, Object> {'RecordTypeId' => recordTypeId}, 
                            settings).createObject();
        insert acc;
       
        
        Product2 product = (Product2) new testFramework(
                            'Product2', 
                            new map<String, Object> {'ProductCode' => 'TestProduct',
                            	'Family' => 'Telephony',
                            	'LOB__c' => 'Business'                            	
                            }, 
        
                            settings).createObject();
                            
		                            
        insert product;
        
        list<PricebookEntry> l_pbe = new list<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id =  Product.id;
        pbe.UnitPrice = 10;
        pbe.IsActive = true;        
        pbe.UseStandardPrice = false;
        
        l_pbe.add(pbe);
                
         insert l_pbe;
        
        //Create opps
        String oppRecordTypeId = RecordTypeService.getRecordTypeIdByName('Opportunity', 'B2B');
        
        list<Opportunity> l_opps = new list<Opportunity>();
        l_opps.add((Opportunity) new testFramework(
                            'Opportunity', 
                            new map<String, Object> {'accountId' => acc.id,
                                                    'CloseDate' => system.today() + 10,
                                                    'StageName' => 'Opportunity',
                                                    'RecordTypeId' => oppRecordTypeId}, 
                            settings).createObject());
                insert l_opps;
        
      
      OpportunityLineItem OPplineitem2 = new OpportunityLineItem 
      	(Quantity=2, OpportunityId=l_opps.get(0).id,UnitPrice=4,PriceBookEntryId=l_pbe.get(0).id);
 		insert OPplineitem2;
        	
    }
    
    
     static testMethod void ChangeOppQuantityTest() {
        
        Opportunity opp = [select id, Name, StageName from Opportunity limit 1];
        system.assert(opp!=null);
        OpportunityLineItem oppLine = [select Id, Name, Quantity from OpportunityLineItem where OpportunityId =: opp.Id limit 1]; 
        
        Test.StartTest();        
	        oppLine.Quantity = oppLine.Quantity +  1;
	        update oppLine;
         
         Test.StopTest();
    }
    
}