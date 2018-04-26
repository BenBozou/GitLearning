/**
* controller class for  OpportunityProduct Edit / View page.
* Author Eric Fishman
* taskid PLR-1405
* @class OpportunityProductEditController
* @module Lead
* @constructor OpportunityProductEditController
*/

public with sharing class OpportunityProductEditController {
    public OpportunityLineItem oppLineItem { get; set; }
    public String oppItemName;
    public Boolean inputMode {get; set;}
    public Boolean enableHosting {get; set;}
    public Boolean enableTelephony {get; set;}
    public Boolean enableTransmition {get; set;}
    public Boolean enableCellular {get; set;}    
    public Boolean enableOneTimeCellular {get; set;}
    public String pageMode {get;set;}
    
     /**
    *  Constructor
    *  @method OpportunityProductEditController
    */
    public OpportunityProductEditController (ApexPages.StandardController controller)
    {
        // Class Constructor
        this.oppLineItem = (OpportunityLineItem)controller.getRecord();
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        inputMode = (retUrl == null) ? false : true;   
        this.oppLineItem  = GetOppLineFields();
        
         system.debug ('==>>> Family : ' + oppLineItem.Product2.Family ); 
                                            
        if (oppLineItem.Product2.Family.startsWithIgnoreCase('Stationary'))
            enableHosting = true;
        if (this.oppLineItem.Product2.Family == 'Telephony')
            enableTelephony = true;
        if (this.oppLineItem.Product2.Family == 'Transmission')
            enableTransmition = true;
        if (this.oppLineItem.Product2.Family == 'Cellular')
            enableCellular = true; 
		if (this.oppLineItem.Product2.Family == 'One Time - Cellular')
            enableOneTimeCellular = true;            
            
        
    }
    
    /**
    *   Method Collect all Fields Set fields for SOQL Query
    *   @method GetOppLineFields
    *   @param {} response
    *   @return {OpportunityLineItem}
    */
    public OpportunityLineItem GetOppLineFields(){
    // Collect all Fields Set fields for SOQL Query
    Set<String> fieldNames = new Set<String>();
  
        try
        {
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : this.getGeneral_1()) {                
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            for (Schema.FieldSetMember f : this.getGeneral_2()) {                
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            for (Schema.FieldSetMember f : this.getGeneral_3()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';                       
                }
                fieldNames.add(f.getFieldPath());                
            }
            for (Schema.FieldSetMember f : this.getHosting_1()) {                 
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());             
            }
            for (Schema.FieldSetMember f : this.getHosting_2()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            for (Schema.FieldSetMember f : this.getHosting_3()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            for (Schema.FieldSetMember f : this.getTelephony_1()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                else {
                    fieldNames.add(f.getFieldPath());
                }
            }
            for (Schema.FieldSetMember f : this.getTelephony_2()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
                
            }
            for (Schema.FieldSetMember f : this.getTelephony_3()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }            
            for (Schema.FieldSetMember f : this.getTransmition()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            for (Schema.FieldSetMember f : this.getCellular_1()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            /*            
            for (Schema.FieldSetMember f : this.getCellular_2()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            */
            ////
            for (Schema.FieldSetMember f : this.getOneTime_Cellular1()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            for (Schema.FieldSetMember f : this.getOneTime_Cellular2()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            for (Schema.FieldSetMember f : this.getOneTime_Cellular3()) {
                if (!fieldNames.contains(f.getFieldPath()) ){
                    query += f.getFieldPath() + ', ';
                }
                fieldNames.add(f.getFieldPath());
            }
            
            // Get Opp item record
        //system.debug ('==>>> QUERY oppLineItem.Id : ' + oppLineItem.Id  );      
        query += ' Id, Product2.Family, Product2.Name  FROM OpportunityLineItem Where ID =\'' + oppLineItem.Id + '\' LIMIT 1';   
            system.debug ('==>>> QUERY: ' + query );  
            return Database.query(query);        
        
        }
        Catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage()));            
            return null;
        }
        return oppLineItem;
 }
  
  /**
    *   Save the record
    *   @method Save
    *   @param {} 
    *   @return {PageReference}
    */  
    public PageReference Save()
    {
    	try
        {
        	update oppLineItem;
        }
        Catch (System.DmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));            
            return null;
        }
        String returnURL = ApexPages.currentPage().getParameters().get('retURL');
        return new PageReference('/'+oppLineItem.Id);
    }        
    
    public PageReference Cancel()
    {        
        return new PageReference('/'+oppLineItem.OpportunityId);
    }
    
    
     public PageReference Split()
     {                                                           
        PageReference pageRef = Page.OpportunityProductSplit;           
        pageRef.getParameters().put('oppProdId', oppLineItem.id);
        pageRef.setRedirect(true);      
        
        return pageRef; 
    }    
    
    public String getoppItemName()
    {
        String oppItemName = oppLineItem.Product2.Name;// /'Oportunuty Product Edit: '  + oppLineItem.Name;    
        return oppItemName;        
    }
    
    //Fill Hosting_1 Field Set
    public List<Schema.FieldSetMember> getHosting_1()
    {
        return SObjectType.OpportunityLineItem.FieldSets.Hosting_1.getFields();
    }
    
    //Fill Hosting_2 Field Set
    public List<Schema.FieldSetMember> getHosting_2()
    {
        return SObjectType.OpportunityLineItem.FieldSets.Hosting_2.getFields();
    }
   //Fill Hosting_3 Field Set
    public List<Schema.FieldSetMember> getHosting_3()
    {
        return SObjectType.OpportunityLineItem.FieldSets.Hosting_3.getFields();
    }
    
    //Fill Telephony_1 Field Set
    public List<Schema.FieldSetMember> getTelephony_1()
    {
        return SObjectType.OpportunityLineItem.FieldSets.Telephony_1.getFields();
    }
    //Fill Telephony_2 Field Set
    public List<Schema.FieldSetMember> getTelephony_2()
    {
        return SObjectType.OpportunityLineItem.FieldSets.Telephony_2.getFields();
    }
    //Fill Telephony_3 Field Set
    public List<Schema.FieldSetMember> getTelephony_3()
    {
        return SObjectType.OpportunityLineItem.FieldSets.Telephony_3.getFields();
    }
    
    //Fill General_1 Field Set
    public List<Schema.FieldSetMember> getGeneral_1()
    {
        return SObjectType.OpportunityLineItem.FieldSets.General_1.getFields();
    }
    //Fill General_2 Field Set
    public List<Schema.FieldSetMember> getGeneral_2()
    {
        return SObjectType.OpportunityLineItem.FieldSets.General_2.getFields();
    }
    //Fill General_3 Field Set
    public List<Schema.FieldSetMember> getGeneral_3()
    {
        return SObjectType.OpportunityLineItem.FieldSets.General_3.getFields();
    }
    //Fill Transmition Field Set
    public List<Schema.FieldSetMember> getTransmition()
    {
        return SObjectType.OpportunityLineItem.FieldSets.Transmition.getFields();
    }
    //Fill Cellular_1 Field Set
    public List<Schema.FieldSetMember> getCellular_1()
    {
        return SObjectType.OpportunityLineItem.FieldSets.Cellular_1.getFields();
    }
    //Fill Cellular_2 Field Set
    /*public List<Schema.FieldSetMember> getCellular_2()
    {
        return SObjectType.OpportunityLineItem.FieldSets.Cellular_2.getFields();
    }*/    
    //Fill OneTime_Cellular1 Field Set
    public List<Schema.FieldSetMember> getOneTime_Cellular1()
    {
        return SObjectType.OpportunityLineItem.FieldSets.OneTime_Cellular1.getFields();
    }
    //Fill OneTime_Cellular2 Field Set
    public List<Schema.FieldSetMember> getOneTime_Cellular2()
    {
        return SObjectType.OpportunityLineItem.FieldSets.OneTime_Cellular2.getFields();
    }
    //Fill OneTime_Cellular3 Field Set
    public List<Schema.FieldSetMember> getOneTime_Cellular3()
    {
        return SObjectType.OpportunityLineItem.FieldSets.OneTime_Cellular3.getFields();
    }
    
    
    
}