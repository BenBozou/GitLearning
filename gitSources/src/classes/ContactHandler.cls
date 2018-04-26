public with sharing class ContactHandler implements triggerHandler.triggerInterface {
/**
* Class to handle Contact object trigger:  
* Nikolay Iliaev
* taskid PLR-42
* @class ContactHandler
* @module Contact 
*/
    public void insertRecords() {
        if(Trigger.IsAfter){
            updateInOdata();
        }
    }
        
    public void updateRecords() {
        /*
        if(Trigger.isAfter){
            updateInOdata();
        }
        */
        if(trigger.isAfter){
            TrackingEntityService.writeTrackingEntity(
                trigger.new, trigger.newMap, trigger.oldMap, 'Contact Mobile Phone');
        }
           
    }
    
    public void deleteRecords() {}
    
    public void undeleteRecords() {}
    
    /**
    *   Method calls to LeadConvertB2CService class
    *   author Nikolay Iliaev
    *   @method updateInOdata
    *   @return {void}* 
    */
    private void updateInOdata(){
        
        List<Contact> contactList = new List<Contact>();
        for(Contact contItem : (List<Contact>)Trigger.new){
            if(contItem.CellcomExternalID__c != null){
                contactList.add(contItem);
            }
        }
        if(!contactList.isEmpty()){
            System.enqueueJob(new LeadConvertB2CService(contactList));
        }
    }
}