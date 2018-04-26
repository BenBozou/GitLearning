/**
*     Test class for Trigger Handler
*     Liron Cohen
*
*     @class TriggerHandlerTest
*     @module Infra
*/

@isTest
private class TriggerHandlerTest{

    static testMethod void utilitiesTest(){
    
        Map<String,Object> settings = new Map<String,Object>{
            'createlookupobject' => false,
            'countObjects' => 1
        };
        
         Account account= 
            (Account) new testFramework('Account', 
                                         new map<String, Object> {'Name' => 'TestAccount'}, 
                                         settings).createObject();
		insert account;
		                                                        
        Account[] accountArray = new Account[]{account};
        
        Set<Id> idSet = triggerHandler.createSetId(accountArray, 'Id');
		system.assertEquals(true, idSet.contains(account.id));

        set<object> objSet = triggerHandler.createSetByValue(accountArray, 'Name', 'TestAccount', 'Name');
        system.assertEquals(true, objSet.contains(account.Name));

        map<object, object> objMap =  triggerHandler.createMapFromList('Name', 'Id', accountArray);
        system.assertEquals(true, objMap.containsKey(account.Name));

        map<Id, object> idMap = triggerHandler.createMapFromListToId('Id', 'Name', accountArray);
        system.assertEquals(true, idMap.containsKey(account.Id));

        map<object, sObject> objSobjMap = triggerHandler.createMapsObjectFromList('Name', accountArray);
        system.assertEquals(true, objSobjMap.containsKey(account.Name));

        map<Id, set<String>> idSetMap = triggerHandler.getIdsOfChangedRecordsToMap(accountArray, new map<Id, sObject>{account.id => account}, new set<String>{'Name'});
        system.assertEquals(true, !idSetMap.containsKey(account.Id));

        Set<Id> idsChangeSet = triggerHandler.getIdsOfChangedRecords(accountArray, new map<Id, sObject>{account.id => account}, new set<String>{'Name'});
        system.assertEquals(true, !idsChangeSet.contains(account.Id));

        map<Id, set<object>> idSetChangeMap = triggerHandler.getIdsOfChangedRecordsToValueMap(accountArray, new map<Id, sObject>{account.id => account}, new set<String>{'Name'});
        system.assertEquals(true, !idSetChangeMap.containsKey(account.Id));

        Boolean foundBol = triggerHandler.FoundInArray('str', ';', 'str;sty');
    }
}