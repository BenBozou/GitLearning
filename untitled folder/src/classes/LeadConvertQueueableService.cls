/**
* Queueable service class for lead convert: 
* Nikolay Iliaev
* taskid PLR-798
* @class LeadConvertQueueableService
* @module Lead
* @constructor 
*/  
public with sharing class LeadConvertQueueableService implements Queueable {
    
    List<Lead> leadlist = new List<Lead>();
    
    public LeadConvertQueueableService(List<Lead> leadList){
    	this.leadlist = leadList;
    }
    
    /**
    * Execute method
    * Nikolay Iliaev
    * @method execute	
	* @return {void}*     
    * @module Lead 
    */
    public void execute(QueueableContext context){
    	
    	LeadConvertB2BService leadConvertServ = new LeadConvertB2BService(this.leadList);
	}
}