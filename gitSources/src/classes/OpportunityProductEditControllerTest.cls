/**
*   Test class for OpportunityProductEditController
*   
*   @class OpportunityProductEditControllerTest
*   author Eric Fishman
*   @module TestClass
*   @constructor
*/
@isTest
private class OpportunityProductEditControllerTest {

    @testSetup 
    static void setupTestData(){
         Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
        
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
    
    
    static testMethod void oppProductEditTest() {
    	
    	system.debug ('>> oppProductEditTest'  );
    	
    	Opportunity opp = [select id, Name, StageName from Opportunity limit 1];
    	
    	system.debug ('>> opp' + opp);
    	
    	Test.StartTest();
    	
    	OpportunityLineItem oppLine = [select Id, Name from OpportunityLineItem where OpportunityId =: opp.Id limit 1];   	
    	system.debug ('>> oppLine' + oppLine);
    	
    	PageReference pageRef = Page.OpportunityProductView;
        pageRef.getParameters().put('Id', oppLine.id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppLine);
        OpportunityProductEditController controller = new OpportunityProductEditController(sc);
        
        String prodName = controller.getoppItemName();
        
        controller.save();
        controller.Cancel();
        controller.Split();
        
             
        
        Test.StopTest();
        
        
        
    }
    
    /**
    * Test method to OpportunityProductSplitController 
    * Nikolay Iliaev
    * @method oppProductSplitTest
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void oppProductSplitTest() {
     	Opportunity opp = [select id, Name, StageName from Opportunity limit 1];
    	
    	system.debug ('>> opp' + opp);
    	
    	Test.StartTest();
    	
    	OpportunityLineItem oppLine = [select Id, Name from OpportunityLineItem where OpportunityId =: opp.Id limit 1];   	
    	system.debug ('>> oppLine' + oppLine);
    	
    	PageReference pageRef = Page.OpportunityProductSplit;
        //pageRef.getParameters().put('oppProdId', oppLine.id);
    	ApexPages.currentPage().getParameters().put('oppProdId', oppLine.id);
        
    	OpportunityProductSplitController controller = new OpportunityProductSplitController();
    	Test.setCurrentPage(pageRef);
        
        controller.countFromVF = 2;
        
        controller.cloneOppProd();
        
        for(OpportunityLineItem oppProdItem : controller.opportunityLineItemList) {
    		oppProdItem.Quantity = 1;
    	}
        
        controller.oppProdList[0].Quantity = 1;
        
    	controller.save();
    	
        controller.cancel();
        
        System.assertEquals(1, controller.opportunityLineItemList.size(),'size of list');
        
        Test.StopTest();
	}
}