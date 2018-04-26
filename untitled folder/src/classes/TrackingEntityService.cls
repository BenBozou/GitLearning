/**
 * Class for tracking entry
 * Liron Cohen
 * taskid PLR - 1346
 * @class TrackingEntityService
 * @module 360
 */
 public class TrackingEntityService{

    //Relvant statuses for intercation event records
    private static list<String> l_intercationStatus = new list<String>{
            'Completed', 'Cancel'};

    //Childs records of account that
    private static map<Id, sObject> childsAccountRecordsMap = new map<Id, sObject>();
    
    //SchemaMap
    private static map <String, Schema.SObjectType> schemaMap;
    
    /**
    *   method description: write tracking entry
    *   author Liron Cohen
    *   taskId PLR-1346
    *
    *   @method writeTrackingEntity
    *   @param {newList}            Usually will be trigger.new
    *   @param {newMap}             Usually will be trigger.newMap
    *   @param {oldMap}             Usually will be trigger.oldMap
    *   @param {trackingEntityName} Label of TrackingEntityName from custom metadata
    *   @param {textLabel}          Custom Label of the message to write
    *   @return void
    *
    */
    public static void writeTrackingEntity(
        list<sObject> newList,
        map<Id, sObject> newMap,
        map<Id, sObject> oldMap,
        String trackingEntityName){
    
        try{
            //Get relevant custom metadata record -contain the setup for the process  
            Tracking_Entity__mdt trackingEntity = [ select MasterLabel, Object__c, field__c,Additional_Criteria__c, Account_Lookup__c, 
                                                        Field_to_Query__c,Related_Account_Object__c, RelatedId_Field__c
                                                    from Tracking_Entity__mdt 
                                                    where MasterLabel = :trackingEntityName];
            
            //Get global describe for field type
            schemaMap = Schema.getGlobalDescribe();
            
            //Id of records that aply on criteria per the metadata setup
            set<Id> IdsAplyCriteria = getIdsAplyCriteria(trackingEntity, newList, oldMap);

            if(!IdsAplyCriteria.isEmpty()){
                
                //map per each account its relevant records
                map<String, list<sObject>> accountRecordMap = getAccountRecordsMap(trackingEntity, IdsAplyCriteria );
                
                System.debug('###' + accountRecordMap);
                
                //New record that will be inserted
                String msg = createTrackingEvent(trackingEntity, accountRecordMap, newMap, oldMap);
                
            }
        }
        catch(Exception ex){
            system.debug(Logginglevel.ERROR, ' ERROR :' + ex.getMessage() + ':' + ex.getStackTraceString());
            LoggerService.writeErrorMessage(new LoggerService.ErrorMessage(ex));
        }
         
    }        
    
    
    
    
    /**
    *   method description: get Ids of records that aply on criteria and the relevant field was changed
    *   author Liron Cohen
    *   taskId PLR-1346
    *
    *   @method getIdsAplyCriteria
    *   @param {trackingEntity}     Tracking Entity record from custom metadata
    *   @param {newList}            Usually will be trigger.new
    *   @param {oldMap}             Usually will be trigger.oldMap
    *   @return {Set<Id>}
    *
    */
    private static Set<Id> getIdsAplyCriteria(
        Tracking_Entity__mdt trackingEntity,
        list<sObject> newList,
        map<id, sObject> oldMap){
    
        Set<Id> idsAplyCriteria = new Set<Id>();
        
        
        //Criteria from the setup. e.g: 'LeadRecordType__c=Offer'
        list<String> l_criteria;
        if(trackingEntity.Additional_Criteria__c != null){
            l_criteria = trackingEntity.Additional_Criteria__c.split(';');
        }
            
    
        //Loop over records from the transaction
        for(sObject obj : newList){
            
            //Check if at least 1 relevant field was changed
            boolean fieldChanged = false;
            
            for(String field : trackingEntity.Field__c.split(',')){
                if(obj.get(field) != oldMap.get(obj.id).get(field))
                    fieldChanged = true;
            }
            
            //main field was changed?
            if(fieldChanged){
                    
                //Check the criterias
                boolean aplyCriteria = true;
                    
                if(l_criteria!=null){
                    
                    for(String criteria : l_criteria){
                        
                        String field = criteria.subStringBefore('=');
                        String val = criteria.subStringAfter('=');
                                
                        if(obj.get(field) != val)  {
                            aplyCriteria = false;
                        }
                    }
                }
                    
                if(aplyCriteria){
                    idsAplyCriteria.add(obj.id);
                }
            }
        }
            
        return idsAplyCriteria;
    }
    
    
    /**
    *   method description: build map per each account its relevant records
    *   author Liron Cohen
    *   taskId PLR-1346
    *
    *   @method getAccountRecordsMap
    *   @param {trackingEntity}     Tracking Entity record from custom metadata
    *   @param {IdsAplyCriteria}    Ids of recrods that should be processed
    *   @return {map<String, list<sObject>>}
    *
    */
    private static map<String, list<sObject>> getAccountRecordsMap(
        Tracking_Entity__mdt trackingEntity,
        set<Id> IdsAplyCriteria){
    
        //map per each account its relevant records
        map<String, list<sObject>> accountRecordMap = new map<String, list<sObject>>();
            
            
        //Perpare query from the relevant object. Should run query again due to:
        //    1.Possible need other field e.g. ToLabal(Status).
        //    2.Need to get the relevant accounts from other object e.g. 'AccountContactRelation'
        String querySelect = 'select id,' + trackingEntity.Account_Lookup__c;
                
        //Additional fields that should be query
        if(trackingEntity.Field_to_Query__c!= null)
            querySelect += ',' + trackingEntity.Field_to_Query__c;
                
        childsAccountRecordsMap = new map<Id, sObject>(
                Database.query(querySelect  + ' from ' + trackingEntity.Related_Account_Object__c 
                                            + ' where ' + trackingEntity.RelatedId_Field__c +' in :IdsAplyCriteria'));
                
        //Loop over records to create map per each account its relevant records
        for(sObject obj : childsAccountRecordsMap.values()){
                                
            if(!accountRecordMap.containsKey((String)obj.get(trackingEntity.Account_Lookup__c))){
                accountRecordMap.put((String)obj.get(trackingEntity.Account_Lookup__c), new list<sObject>());
            }
            accountRecordMap.get((String)obj.get(trackingEntity.Account_Lookup__c)).add(obj);
        }
        return accountRecordMap;
    }
    
    
    /**
    *   method description: Create new TrackingEntity records that will be insert
    *   author Liron Cohen
    *   taskId PLR-1346
    *
    *   @method getTrackingEventList
    *   @param {trackingEntity}     Tracking Entity record from custom metadata
    *   @param {accountRecordMap}   Map per each accountId its related records
    *   @param {newMap}             Usually will be trigger.newMap
    *   @param {oldMap}             Usually will be trigger.oldMap 
    *   @param {textLabel}          Custom Label of the message to write
    *   @return {list<vlocity_cmt__VlocityTrackingEntry__c>}
    *
    */
    private static String createTrackingEvent(
        Tracking_Entity__mdt trackingEntity,
        map<String, list<sObject>> accountRecordMap,
        map<Id, sObject> newMap,
        map<id, sObject> oldMap){

        String retMsg = '';
    
        //new trackingEntry record to insert
        list<vlocity_cmt__VlocityTrackingEntry__c> newTrackingEntryList = new list<vlocity_cmt__VlocityTrackingEntry__c>();
        
        //List of new topic to be added
        //list<vlocity_cmt__CustomerInteractionTopic__c> newTopicList = new list<vlocity_cmt__CustomerInteractionTopic__c>();
        
        //List of Customer Intercation records to update
        list<vlocity_cmt__CustomerInteraction__c> customerIntercationList = new list<vlocity_cmt__CustomerInteraction__c>();
        
        //Loop over related customer intercation records in the relevant statuses
        for(vlocity_cmt__CustomerInteraction__c customerIntercation : 
                                    [   select id, vlocity_cmt__AccountId__c, InteractionSubject__c
                                        from vlocity_cmt__CustomerInteraction__c
                                        where vlocity_cmt__AccountId__c IN :accountRecordMap.keySet()
                                            and vlocity_cmt__Status__c NOT IN :l_intercationStatus
                                            and createdBy.Id = :UserInfo.getUserId()]){
            
            if(customerIntercation.InteractionSubject__c == null || ! customerIntercation.InteractionSubject__c.contains('Action Was Done')){
                customerIntercation.InteractionSubject__c = customerIntercation.InteractionSubject__c == null ? 
                                                                'Action Was Done' : 
                                                                customerIntercation.InteractionSubject__c + 'Action Was Done';
                customerIntercationList.add(customerIntercation);
            }
            
            //Create new topic, but only if it was not created before for this customerIntercation 
            //if(customerIntercation.vlocity_cmt__CustomerInteractionTopics__r.isEmpty()){
                //newTopicList.add(new vlocity_cmt__CustomerInteractionTopic__c(
                //    vlocity_cmt__CustomerInteractionId__c = customerIntercation.id, 
                //    name = Label.IntercationTopicActionDone,
                //    vlocity_cmt__AccountId__c = customerIntercation.vlocity_cmt__AccountId__c));
            //}
    
            for(String field : trackingEntity.field__c.split(',')){
                
                //Get Field type, field label
                String fieldType = String.valueOf(schemaMap.get(trackingEntity.Object__c).getDescribe().fields.getMap().get(field).getDescribe().getType());
    
                String fieldLabel = schemaMap.get(trackingEntity.Object__c).getDescribe().fields.getMap().get(field).getDescribe().getLabel();
        
                for(sObject obj: accountRecordMap.get(customerIntercation.vlocity_cmt__AccountId__c)){
                
                    if(oldMap.get((String)obj.get(trackingEntity.RelatedId_Field__c)).get(field) != newMap.get((String)obj.get(trackingEntity.RelatedId_Field__c)).get(field)){
                        
                        //Get old/new value
                        String oldVal = String.valueOf(oldMap.get((String)obj.get(trackingEntity.RelatedId_Field__c)).get(field)), newVal = String.valueOf(newMap.get((String)obj.get(trackingEntity.RelatedId_Field__c)).get(field));
                
                        //if field is picklist should get the translated value
                        if(fieldType == 'PICKLIST'){
                            if(!String.isEmpty(oldVal))
                                oldVal = Utilities.getTranslatedValue(trackingEntity.Object__c, field, oldVal);
                            if(!String.isEmpty(newVal))
                                newVal = Utilities.getTranslatedValue(trackingEntity.Object__c, field, newVal);
                        }
                        
                        String summaryLine = Label.TrackingEntrySummaryLine.replace('{0}', fieldLabel).
                                            replace('{1}', (oldVal!=null ? oldVal : '')).
                                            replace('{2}', (newVal!=null ? newVal : '')).
                                            replace('{3}', userInfo.getName()).
                                            replace('{4}', String.valueOf(System.today()));
                                            
                        //Create new Tracking Event record
                        newTrackingEntryList.add(new vlocity_cmt__VlocityTrackingEntry__c(
                                    vlocity_cmt__CustomerInteractionId__c = customerIntercation.id,
                                    vlocity_cmt__Timestamp__c = System.Now(),
                                    Name = Label.ChangeDetails,
                                    vlocity_cmt__TrackingService__c = Label.ChangeDetails,
                                    vlocity_cmt__VlocityInteractionToken__c = userInfo.getSessionId(),
                                    vlocity_cmt__Data__c = '{"OldValue":"' + (oldVal!=null ? oldVal : '') + '",' 
                                                            +'"NewValue":"' + (newVal!=null ? newVal : '') + '",'
                                                            +'"AccountId":"' + customerIntercation.vlocity_cmt__AccountId__c +'",'
                                                            +'"recordId":"' + obj.id + '",'
                                                            +'"userName":"' + userInfo.getName() + '",'
                                                            +'"ElementLabel":"' + fieldLabel+ '",'
                                                            +'"SummaryLabel":"' + summaryLine + '",'
                                                            +'"ElementName":"' + trackingEntity.field__c + '",'
                                                            +'"TrackingEvent":"' + trackingEntity.MasterLabel + '",'
                                                            +'"TrackingName":"' + Label.ChangeDetails + '",'
                                                            +'"TrackingService":"' + Label.ChangeDetails + '",'
                                                            +'"OmniScriptSessionToken":"' + userInfo.getSessionId() + '"}'));
                    }
                }
            }    
        }
        
        if(! newTrackingEntryList.isEmpty()){
            DatabaseManager.DatabaseResult result1 = 
                DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.INSERT_ACTION, newTrackingEntryList);
                
            if(!result1.isSuccess())
                retMsg += result1.getAllErrorMessages('\n');
        }

        if(! customerIntercationList.isEmpty()){
            DatabaseManager.DatabaseResult result2 = 
                DatabaseManager.runDMLAction(DatabaseManager.DML_ACTION.UPDATE_ACTION, customerIntercationList);
                
            if(!result2.isSuccess())
                retMsg += result2.getAllErrorMessages('\n');
        }
        
        system.debug('####' + retMsg);
        return retMsg;
    }
}