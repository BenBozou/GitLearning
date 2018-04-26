/** 
*   Trigger pattern interface implementation. For more information can go to https://developer.salesforce.com/page/Trigger_Frameworks_and_Apex_Trigger_Best_Practices
*
*   @class triggerHandler
*   author Dmitry Rivlin
*   @module Frameworks
*   email : wildervit@gmail.com
*   description: 
*
* STATIC VARIABLE isPreventLoop by default = TRUE.
*
*   Example :
* 
*   trigger Account on Account (before insert, before update) {
*       new triggerHandler('Account');
*   }
*
*   public with sharing class AccountHandler implements triggerHandler.triggerInterface {
*
*   public void insertRecords() {}
*   public void updateRecords() {}
*   public void deleteRecords() {}
*   public void undeleteRecords() {}
*}
**/

public with sharing class triggerHandler {

    public static triggerInfo[] triggersRun;
    public static String initialObject;
    public static String prevObject;
    public static String curObject;
    public static Boolean isPreventLoop;
    public static savePoint sPoint;
    
    public static User currentUser;

    //Check if bypass is check for user
    private static boolean isBypassTrigger(){
        
        if (currentUser == null){
            currentUser = [select id, Bypass_Trigger__c from User where id = :userInfo.getUserId()]; 
        }
        return currentUser.Bypass_Trigger__c;
    }
    

    // Interface Declaration
    public interface triggerInterface {
        void insertRecords();
        void updateRecords();
        void deleteRecords();
        void undeleteRecords();
    }

    /**
    *   constructor
    *   author Dmitry Rivlin
    *
    *   @method triggerHandler
    *   @param  {triggerInterface} connectorInstance
    *   @return 
    *
    */
    public triggerHandler(triggerInterface connectorInstance) {
        try {
            if (triggersRun == null) {
                triggersRun = new triggerInfo[] {};
            }
            this.execute(connectorInstance);
        } catch (Exception E) {
            throw new triggerException(e.getMessage() + ' ' + E.getStackTraceString());
        }
    }

    /**
    *   constructor
    *   author Dmitry Rivlin
    *
    *   @method triggerHandler
    *   @param  {String} triggerInterfaceName
    *   @return 
    *
    */
    public triggerHandler(String triggerInterfaceName) {
        isPreventLoop = (isPreventLoop == null) ? true : isPreventLoop;
        //licenseManager.getInstance(true);
        try {
            if (triggersRun == null) {
                triggersRun = new triggerInfo[] {};
            }
            Type handlerType = Type.forName(triggerInterfaceName + 'Handler');
            triggerInterface connectorInstance = (triggerInterface) handlerType.newInstance();
            this.execute(connectorInstance);
        } catch (Exception E) {
            throw new triggerException(e.getMessage() + ' ' + E.getStackTraceString());
        } finally {
            //debugLog.createExeptionRecord(null);
        }
    }

    /**
    *   Execute triggerHandler method
    *   author Dmitry Rivlin
    *
    *   @method execute
    *   @param  {triggerInterface} connectorInstance
    *   @return void
    *
    */
    public void execute(triggerInterface connectorInstance) {
        if(isBypassTrigger()){
            return;
        }
        
        integer Level = triggerHandler.getCurLevel();
        prevObject = curObject;
        triggersRun.add(new triggerInfo(true, Level, triggerHandler.triggersRun.size() == 0 ? 0 : triggerHandler.triggersRun[triggerHandler.triggersRun.size() - 1].SOQLLimit));
        if (triggerHandler.triggersRun.size() == 1) initialObject = triggersRun[0].objName;
        curObject = triggersRun[triggerHandler.triggersRun.size() - 1].objName;

        if (delectLoop()) {
            system.debug(LoggingLevel.ERROR, 'DETECT LOOP ON OBJECT ' + curObject);
            //need to use for this probably future method
            //if (triggerHandler.sPoint!=null) Database.rollback(triggerHandler.sPoint);
            //return;
        }

        triggerHandler.sPoint = Database.setsavePoint();

        if (trigger.isInsert) connectorInstance.insertRecords();
        else if (trigger.isUpdate) connectorInstance.updateRecords();
        else if (trigger.isDelete) connectorInstance.deleteRecords();
        else if (trigger.isUndelete) connectorInstance.undeleteRecords();

        triggersRun.add(new triggerInfo(false, Level, triggerHandler.triggersRun.size() == 0 ? 0 : triggerHandler.triggersRun[triggerHandler.triggersRun.size() - 1].SOQLLimit));
        printDebug();
        system.debug(LoggingLevel.ERROR, printDebug());
    }

    /**
    *   Loop detection
    *   author Dmitry Rivlin
    *
    *   @method delectLoop
    *   @return boolean
    *
    */
    private boolean delectLoop() {
        if (!isPreventLoop) return false;
        set < String > isAlreadyDone = new set < string > ();
        for (triggerInfo Item: triggersRun) {

            String key = (Item.isStart ? 'START' : 'END') + Item.curActionBA + Item.curAction + Item.objName;
            system.debug(LoggingLevel.Error,'LOOP DETECTION ' + key); 
            if (isAlreadyDone.contains(key)) return true;
            isAlreadyDone.add(key);
        }
        return false;
    }

    private class triggerInfo {
        public Integer recordCount;
        public String objName;
        public String curAction;
        public String curActionBA;
        public String keyPrefix;
        public set < Id > ids;
        public Integer parentItem;
        public boolean isStart;
        public Integer shiftCounter;
        public Integer SOQLLimit;
        private String startTime;

        public triggerInfo(Boolean start, Integer parent, Integer PrevSOQLCount) {
            this.startTime = system.now().format('HH:mm:ss.SSS');
            this.recordCount = Trigger.Size;
            this.isStart = start;
            this.parentItem = parent;
            this.shiftCounter = parent;

            ids = new set < Id > ();

            if (Trigger.isBefore) curActionBA = 'BEFORE';
            else curActionBA = 'AFTER';

            sObject[] TMP;

            if (Trigger.isInsert) {
                curAction = 'INSERT';
                TMP = Trigger.new;
            } else if (Trigger.isUpdate) {
                curAction = 'UPDATE';
                TMP = Trigger.old;
            } else if (Trigger.isDelete) {
                curAction = 'DELETE';
                TMP = Trigger.old;
            } else {
                curAction = 'UNDELETE';
                TMP = Trigger.new;
            }
            this.objName = Tmp[0].getSObjectType().getDescribe().getLocalName();
            this.keyPrefix = Tmp[0].getSObjectType().getDescribe().getKeyPrefix();
            for (sObject S: Tmp) {
                ids.add(S.Id);
                if (this.curAction == 'INSERT') {
                    system.debug(LoggingLevel.Error, ' VALUE ITEM : ' + S + '\n');
                }
            }
            this.SOQLLimit = Limits.getQueries() - PrevSOQLCount;
            if (!this.isStart) this.startTime = system.now().format('HH:mm:ss.SSS');
        }

        public String printInfo() {
            String Sp = ' ';
            Sp += SP.repeat(this.shiftCounter * 2) + '[' + parentItem + '][' + ((this.isStart) ? 'START' : 'END   ') + '] ' + objName + ' [' + this.curActionBA + ' : ' + this.curAction + ']' + (!this.isStart ? ' SOQL Count : [' + this.SOQLLimit + '] ' : '') + '(' + recordCount + ')';
            Sp += ' Items Id : ' + ids + '\n';
            return this.startTime + ' ' + SP;
        }
    }

    /**
    *   Get current level for trigger in global execution tree
    *   author Dmitry Rivlin
    *
    *   @method getCurLevel
    *   @return Integer
    *
    */
    public static Integer getCurLevel() {
        Integer Level;
        if (triggerHandler.triggersRun.size() == 0) Level = 0;
        else {
            Level = triggerHandler.triggersRun[triggerHandler.triggersRun.size() - 1].ParentItem;
            if (triggerHandler.triggersRun[triggerHandler.triggersRun.size() - 1].isStart) Level++;
        }
        return Level;
    }

    /**
    *   Put debug information into salesforce debug log
    *   author Dmitry Rivlin
    *
    *   @method printDebug

    *   @return String
    *
    */
    private static String printDebug() {
        String DebugLog = '\n\n';
        for (triggerInfo Item: triggerHandler.triggersRun) {
            DebugLog += Item.printInfo();
        }
        if (triggerHandler.triggersRun.size() == 1) initialObject = triggerHandler.triggersRun[0].objName;

        DebugLog += 'Count RUNS : ' + (triggerHandler.triggersRun.size() / 2) + '\n\n';
        return DebugLog;
    }

    /*
        Triggers methods
    */

    /**
    *   Create set<Id> from list of sObject[]
    *   author Dmitry Rivlin
    *
    *   @method createSetId
    *   @param  {sObject[]} sList
    *   @param  {String} field
    *   @return set < id >
    *
    */
    public static set < id > createSetId(sObject[] sList, String field) {
        return createSetId(sList, new set < String > {
            field
        });
    }

    /**
    *   Create set<Id> from list of sObject[] and set of fields
    *   author Dmitry Rivlin
    *   taskId
    *
    *   @method createSetId
    *   @param  {sObject[]} sList
    *   @return set < id >
    *
    */
    public static set < id > createSetId(sObject[] sList, set < String > fieldLst) {
        set < id > Result = new set < id > ();
        if (sList == null) return Result;
        for (sObject item: sList) {
            for (String field: fieldLst) {
                if (item.get(field) != null) Result.add((id) item.get(field));
            }
        }
        return Result;
    }

    /**
    *   create set<object> from list of sObject if item."field" == "val" and return "resField"
    *   author Dmitry Rivlin
    *
    *   @method createSetByValue
    *   @param  {sObject[]} sList
    *   @param  {String} Field
    *   @param  {Object} Val
    *   @param  {String} resField
    *   @return set < object >
    *
    */
    public static set < object > createSetByValue(sObject[] sList, String Field, Object Val, String resField) {
        set < object > Result = new set < object > ();
        if (sList == null) return Result;
        for (sObject item: sList) {
            if (item.get(field) == val) Result.add(item.get(resField));
        }
        return Result;
    }

    /**
    *   create Map From List (String keyField, String valField, sObject[] sList) {
    *   author Dmitry Rivlin
    *
    *   @method createMapFromList
    *   @param  {String} keyField
    *   @param  {String} valField
    *   @param  {sObject[]} sList
    *   @return map < object, object >
    *
    */
    public static map < object, object > createMapFromList(String keyField, String valField, sObject[] sList) {
        map < object, object > Result = new map < object, object > ();
        if (sList == null) return Result;
        String[] keyFieldArr = keyField.split('\\.');
        String[] valFieldArr = valField.split('\\.');
        for (sObject item: sList) {
            //system.debug(LoggingLevel.ERROR,'createMapFromList ' + keyFieldArr);
            sObject obj = item;
            object key;
            object value;
            for (Integer i = 0; i < keyFieldArr.size(); i++) {
                //system.debug(LoggingLevel.ERROR,'createMapFromList key' + i + ' ][ ' +keyFieldArr.size() + ' ' + item + '\n' +obj + '\n' + keyFieldArr[i]);
                if (obj == null) {
                    break;
                }
                if (i < keyFieldArr.size() - 1) obj = obj.getSobject(keyFieldArr[i]);
                else key = obj.get(keyFieldArr[i]);

            }
            obj = item;
            for (Integer i = 0; i < valFieldArr.size(); i++) {
                //system.debug(LoggingLevel.ERROR,'createMapFromList Value ' + i + ' ][ ' +valFieldArr.size() + ' ' + item + '\n' +obj + '\n' + valFieldArr[i]);
                if (obj == null) {
                    break;
                }
                if (i < valFieldArr.size() - 1) obj = obj.getSobject(valFieldArr[i]);
                else value = obj.get(valFieldArr[i]);

            }
            if (key != null) {
                //system.debug(LoggingLevel.ERROR, Key + ' = ' + value);
                Result.put(key, value);
            }

        }
        return Result;
    }

    /**
    *   type of "keyField" must be Id
    *   author Dmitry Rivlin
    *   taskId
    *
    *   @method createMapFromListToId
    *   @param  {String} keyField
    *   @param  {String} valField
    *   @param  {sObject[]} sList
    *   @return map < Id, object >
    *
    */
    public static map < Id, object > createMapFromListToId(String keyField, String valField, sObject[] sList) {
        map < Id, object > Result = new map < Id, object > ();
        if (sList == null) return Result;
        for (sObject item: sList) {
            Result.put((id) item.get(keyField), item.get(valField));
        }
        return Result;
    }

    /**
    *   method description
    *   author Dmitry Rivlin
    *   taskId
    *
    *   @method createMapsObjectFromList
    *   @param  {String} keyField
    *   @param  {sObject[]} sList
    *   @return map < object, sObject >
    *
    */
    public static map < object, sObject > createMapsObjectFromList(String keyField, sObject[] sList) {
        map < object, sObject > Result = new map < object, sObject > ();
        if (sList == null) return Result;
        String[] keyFieldArr = keyField.split('\\.');
        for (sObject item: sList) {
            sObject obj = item;
            for (Integer i = 0; i < keyFieldArr.size(); i++) {
                if (i < keyFieldArr.size() - 1) obj = obj.getSobject(keyFieldArr[i]);
                else {
                    //system.debug(LoggingLevel.ERROR, keyFieldArr[i] + ' ' + obj);
                    Result.put(obj.get(keyFieldArr[i]), item);
                }
            }
            //Result.put(item.get(keyField),item);
        }
        return Result;
    }

    /**
    *   return map < "Id of changed record", set < "Name of changed Field" >>
    *   author Dmitry Rivlin
    *   taskId
    *
    *   @method getIdsOfChangedRecordsToMap
    *   @param  {sObject[]} sListNew
    *   @return map < Id, set < String >>
    *
    */
    public static map < Id, set < String >> getIdsOfChangedRecordsToMap(sObject[] sListNew, map < Id, sObject > sMapOld, set < String > field_names) {
        map < Id, set < String >> ids = new map < Id, set < String >> ();

        for (SObject newRecord: sListNew) {
            for (String field: field_names) {
                if (sMapOld == null || sMapOld.get(newRecord.id).get(field) != newRecord.get(field)) {
                    if (!ids.containsKey(newRecord.id)) ids.put(newRecord.id, new set < String > ());
                    ids.get(newRecord.id).add(field);
                }
            }
        }
        return ids;
    }

    /**
    *   return set<"Id of changed record">
    *   author Dmitry Rivlin
    *
    *   @method getIdsOfChangedRecords
    *   @param  {sObject[]} sListNew
    *   @return Set < Id >
    *
    */
    public static Set < Id > getIdsOfChangedRecords(sObject[] sListNew, map < Id, sObject > sMapOld, set < String > field_names) {
        Set < Id > ids = new Set < Id > ();

        for (SObject newRecord: sListNew) {
            for (String field: field_names) {
                if (sMapOld == null || sMapOld.get(newRecord.id).get(field) != newRecord.get(field)) {
                    ids.add(newRecord.id);
                }
            }
        }
        return ids;
    }

    /**
    *   return map < "Id of changed record", set < "Value of changed Field" >>
    *   author Dmitry Rivlin
    *
    *   @method getIdsOfChangedRecordsToValueMap
    *   @param  {sObject[]} sListNew
    *   @return map < Id, set < object >>
    *
    */
    public static map < Id, set < object >> getIdsOfChangedRecordsToValueMap(sObject[] sListNew, map < Id, sObject > sMapOld, set < String > field_names) {
        map < Id, set < object >> ids = new map < Id, set < object >> ();

        for (SObject newRecord: sListNew) {
            for (String field: field_names) {
                if (sMapOld == null || sMapOld.get(newRecord.id).get(field) != newRecord.get(field)) {
                    if (!ids.containsKey(newRecord.id)) ids.put(newRecord.id, new set < object > ());
                    ids.get(newRecord.id).add(newRecord.get(field));
                }
            }
        }
        return ids;
    }
    /**
    *   general use in multipicklist. Found exact string in source string
    *   EXAMPLE : FoundInArray('test',';','test1;test;test2');
    *   author Dmitry Rivlin
    *   taskId
    *
    *   @method FoundInArray
    *   @param  {String} InStr
    *   @param  {String} Delimer
    *   @param  {String} Source
    *   @return boolean
    *
    */
    public static boolean FoundInArray(String InStr, String Delimer, String Source) {
        if (string.isEmpty(InStr)) return false;
        String[] StrArr = InStr.split(' *' + Delimer + ' *');
        for (String Key: StrArr) {
            if (Key == Source) return true;
        }
        return false;
    }

    public class triggerException extends Exception {}
}