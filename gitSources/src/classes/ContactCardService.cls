/**
* Service class for vlocity cards to retrieve contact data from legacy systems.
* Elad Iflah
* taskid PLR-462
* @class ContactCardService
* @module 360 
*/

global with sharing class ContactCardService implements vlocity_cmt.VlocityOpenInterface
{
    /**
* Method implemented from interface, that will be called from vlocity card, 
* and will call inner method according to method name.
* Elad Iflah
* taskid PLR-462
* @method invokeMethod
* @param {String} methodName
* @param {Map} inputMap
* @param {Map} outMap
* @param {Map} options
* @return {Boolean} returns if method succeeded
*/
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        Boolean result = false;
        
        System.debug(Logginglevel.ERROR, 'ContactCardService - invokeMethod - input method name is :' + methodName);
        System.debug(Logginglevel.ERROR, 'ContactCardService - invokeMethod - input map is :' + JSON.serialize(inputMap));
        
        try
        {                        
            if(String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getContactDetails')) {                
                result = getContactDetails(inputMap, outMap);
            }
            
        }
        catch(Exception e) {
            system.debug(Logginglevel.ERROR,'ContactCardService - invokeMethod - ERROR :'+e.getMessage());
        }
        
        return result;
    }
    
    /**
* Retrieves contact details from legacy systems and segment from record type,
* and filter relevant fields according to segment.
* Elad Iflah
* taskid PLR-462
* @method getContactDetails	
* @param {Map} inputMap
* @param {Map} outMap
* @static
*/
    
    private static Boolean getContactDetails(Map<String,Object> inputMap, Map<String,Object> outMap) {
        
        String accountId;
        String recordType;
        
        system.debug(Logginglevel.ERROR,'ContactCardService - getContactDetails - Starting getContactDetails');
        
        if(inputMap.containsKey('accountId')) {
            
            system.debug(Logginglevel.ERROR,'ContactCardService - getContactDetails - accountId found');            
            
            accountId = String.valueOf(inputMap.get('accountId'));            
            List<Account> accountList = [select Id, RecordType.Name from Account where id = :accountId];
            
            if(accountList.size()>0)
            {
                system.debug('Account found :' + accountList[0]);
                recordType = accountList[0].RecordType.Name;
                
                outMap.put('customerType', recordType);
                system.debug('recordType is :' +recordType );
                
                outMap.put('firstName', 'משה');
                outMap.put('lastName', 'יעלון');
                outMap.put('idNumber', '045254577');
                outMap.put('phoneNumber', '0525554445');
                outMap.put('address', 'הארבעה 4 תל אביב');
                outMap.put('email', 'bogiy@gmail.com');                        
                outMap.put('orgPosition', 'משק ממטרות');
                outMap.put('orgAddress', 'קפלן 12 תל אביב');
            }
            else
            {
                outMap.put('objectType', 'Unknown');
                return false;
            }
            
        }
        else {
            outMap.put('objectType', 'Unknown');
            return false;
        }
        
        return true;
        
    }
}