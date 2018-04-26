/**
* controller to VF opportunity product  
* Nikolay Iliaev
* taskid PLR-1433
* @class OpportunityProductSplit
* @module Lead
*/  
public with sharing class OpportunityProductSplitController {
    
    public Id oppProdId { get; set; }
    public Integer quantity { get; set; }
    public Integer countFromVF { get; set; }
    public Integer maxCountSplit = 20;
    public Integer step { get; set; }
    public List<OpportunityLineItem> opportunityLineItemList { get; set;}
    public List<OpportunityLineItem> oppProdList { get; set;} 
    
    public OpportunityProductSplitController() {
       oppProdList = new List<OpportunityLineItem>();
       // setup step of process
       step = 0;
       // get oppProd id form url
       this.oppProdId= ApexPages.currentPage().getParameters().get('oppProdId');
       // prepere data to clone 
       prepereData(this.oppProdId);
    }
    
    /**
    * Method saev opp line item
    * Nikolay Iliaev
    * @method save
    * @return {Void}*     
    * @module Lead
    */
    public PageReference save() {
        
        OpportunityHandler.allowOpportunutyQuantityChange = true;
        
        DatabaseManager.DatabaseResult dbResult;
        DatabaseManager.DatabaseResult dbResult1;
        
        String msg;
        String msg1;
        Integer sum = 0;
        
        if(!opportunityLineItemList.isEmpty()) {
            
            for(OpportunityLineItem oppProdItem : opportunityLineItemList) {
                sum += (Integer)oppProdItem.Quantity != null ? (Integer)oppProdItem.Quantity : 0;
            }
            
            sum += (Integer)oppProdList[0].Quantity != null ? (Integer)oppProdList[0].Quantity : 0;
            
            System.debug(LoggingLevel.ERROR,'Sum: ' + sum);
            
            if(sum != quantity) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ErrorQuantityInRow));
                return null;
            }
            
            
            dbResult = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION, opportunityLineItemList,false);
            
            msg = dbResult.getAllErrorMessages('\n');
            
            System.debug(LoggingLevel.ERROR,'ERROR: ' + msg);
            
            dbResult1 = DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION, oppProdList,false);
            
            msg1 = dbResult1.getAllErrorMessages('\n');
            
            System.debug(LoggingLevel.ERROR,'ERROR: ' + msg1);
            
            if(!dbResult.isSuccess() || !dbResult1.isSuccess()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.errorManagerScreen + msg + ':' + msg1));
                return null;
            } else {
                PageReference pageRef = new PageReference('/' + oppProdList[0].OpportunityId);
                pageRef.setRedirect(true);
                return pageRef;
            }
        } else {
            step = 0;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.NoRowToClone));
            return null;
        }
    }
    
    /**
    * Method clone opplineitem
    * Nikolay Iliaev
    * @method cloneOppProd
    * @return {Void}*     
    * @module Lead
    */
    public void cloneOppProd() {
        
        step = 1;
        
        opportunityLineItemList = new List<OpportunityLineItem>();
        
         if(countFromVF <= this.quantity && countFromVF <= maxCountSplit) {
            // clone object 
            for (Integer i = 0; i < countFromVF-1; i++) {
                opportunityLineItemList.add(oppProdList[0].clone(false, true));
            }
            
            for(OpportunityLineItem oppProdItem : opportunityLineItemList) {
                oppProdItem.Quantity = null;
            }
                
        } else {
            step = 0;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ErrorQuantityToSplit));
        }
        
    }
    
    /**
    * Method split oppotrunity product 
    * Nikolay Iliaev
    * @method prepereData
    * param   {Id} OppProductId
    * @return {Void}*     
    * @module Lead
    */
    public void prepereData(Id OppProductId) {
        
        DatabaseManager.DatabaseResult dbResult;
        String msg;
        String fieldsString;
        
        
         // get all field from object
        Schema.DescribeSObjectResult dsr = OpportunityLineItem.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
        
        Set<String> fieldsNameSet = new Set<String>();

        fieldsNameSet = fieldMap.keySet();
        
        // remove field from set 
        fieldsNameSet.remove('totalprice');
        
        String str = String.join(new List<String>(fieldsNameSet), ',');
        
        oppProdList = Database.query('SELECT ' + str + ' FROM OpportunityLineItem WHERE Id = :OppProductId');
            this.quantity = (Integer)oppProdList[0].Quantity;
            oppProdList[0].Quantity = null;
            
    }
    
    /**
    * Method returns to opportunity line item 
    * Nikolay Iliaev
    * @method cancel
    * @return {Void}*     
    * @module Lead
    */
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + oppProdId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}