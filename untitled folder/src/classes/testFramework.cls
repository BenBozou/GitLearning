/**
*	Comments examples for creating Class docs
*	EXAMPLE
*	param = new map<String, object> {'fillAllFields' => true, 'testUserProfile' => '0000000000000'};

*	fillAllFields      - fill all fields in created object
*	createLookupObject - create all object for fill ALL lookup fields
*	countObjects       - count of created object
*	testUserProfile    - Profile name for test User
*
*	@class testUtilClass
*	author Dmitry Rivlin
*	@module Frameworks
*	@constructor
*/
@isTest
public with sharing class testFramework {

	// Store all created object for use in all testMethods
	public static map<String, sObject[]> createdObjects;
	private static map<String, map<String,Schema.SObjectField>> existfieldMap;
	private static String PROFILE_NAME;

	private innerParams allParams;
	private sObject curObject;

	/**
	*	constructor
	*	author Dmitry Rivlin
	*
	*	@method	TestUtilClass
	*	@param	{String} objName
	*	@param	{Map<String,Object>} fieldSet
	*	@param	{map<String, Object>} params
	*	@return	
	*
	*/
	public testFramework(String objName, Map<String,Object> fieldSet, map<String, Object> params) {
		allParams = new innerParams(objName, fieldSet, params);
	}


	/**
	*	Create list of sObjects
	*	author Dmitry Rivlin
	*
	*	@method	createObjects

	*	@return	sObject[]
	*
	*/
	public sObject[] createObjects(){
		sObject[] result = new sObject[]{};
		createGenericSObject();
		//Result.getSObjectType().getDescribe().fields.getMap();
		
		for (Integer I = 0;I< (Integer) allParams.getValueSetting('countobjects'); I++ ) result.add(fillObject());
		//return this.sObjLst;
		system.debug(LoggingLevel.ERROR,'Create object ' + allParams.objName);
		system.debug(LoggingLevel.ERROR,'Create object ' + result);
		return result;
	}

	/**
	*	create ONE sObject
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	createObject
	*	@return	sObject
	*
	*/
	public sObject createObject() {
		return createObjects()[0];
	}

	/*
		PRIVATE METHODS
	*/

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	createGenericSObject

	*	@return	void
	*
	*/
	private void createGenericSObject() {
		sObject result;
		map<String, Schema.SObjectType> gd = getDescribeGlobal;
		for (String Item : gd.keySet()) {
			if (!(Item == this.allParams.objName || Item.endsWith('__' + this.allParams.objName))) continue;
			Result = gd.get(Item).newSObject();
			if (!existfieldMap.containsKey(this.allParams.objName)) existfieldMap.put(this.allParams.objName, Result.getSObjectType().getDescribe().fields.getMap());
			break;
		}
		//Fix SALESFORCE BUG
		if (this.allParams.objName == 'Contact' && Result.get('Name') == null) Result.put('LastName','BUG SALESFORCE');
		this.curObject = result;
	}

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	fillObject

	*	@return	sObject
	*
	*/
	private sObject fillObject(){
		sObject result = this.curObject.clone();

		for (String Item : existfieldMap.get(allParams.objName).keyset()) {
			try {
				string localItem = Item.replaceAll('^\\S+?__',''); // Prepare Item from package without Prefix
				//system.debug (LoggingLevel.Error, 'Item = ' + Item + ' : ' + localItem);
				if (allParams.fieldSetCorrect != null && (allParams.fieldSetCorrect.containsKey(Item.toLowerCase()) || allParams.fieldSetCorrect.containsKey(localItem.toLowerCase()))) {
					//system.debug(LoggingLevel.ERROR,' FOUND in INITIAL SET : '  + Item + ' : ' + allParams.getValueFieldSet(Item));
					if (!Item.contains('.')) {
						object value = allParams.getValueFieldSet(Item);
						value = (value == null) ? allParams.getValueFieldSet(localItem) : value;
						Result.put(Item,value);
						//system.debug (LoggingLevel.Error, 'FieldSet = ' + fieldSet);
						//system.debug (LoggingLevel.Error, 'FieldName = ' + Item + ':' + localItem + '\n' + result + ':' + fieldSet.get(localItem));
						//system.debug (LoggingLevel.Error, 'RESULT : ' + result);
					}
				} else {
					Schema.SObjectField field = existfieldMap.get(allParams.objName).get(Item);
                    //system.debug(LoggingLevel.Error,'Start Describe ' + allParams.objName + ':' + Item);
					Schema.DescribeFieldResult F = field.getDescribe();
                    
					Boolean isFieldreq  = ((F.isCreateable() && !F.isDefaultedOnCreate() && !F.isCalculated() && !F.isNillable()) || (Item == 'name' && F.isNillable()));
					Boolean isLookUp = (allParams.getValueSetting('createlookupobject') == true && F.getReferenceTo() != null && F.getReferenceTo().size() >0 && Item.endsWith('__c'));// Fix recursion
					Boolean isAllField = (allParams.getValueSetting('fillallfields') == true);
					Set<String> sT= (Set<String>) allParams.getValueSetting('enumvalues');
					Boolean isEnumField = (sT != null && (sT.contains(Item) || (sT.contains('all') && f.getType() == Schema.DisplayType.Picklist)));
					//system.debug(LoggingLevel.ERROR, ' Item : ' + Item);
					//system.debug(LoggingLevel.Error,'End Describe ' + allParams.objName + ':' + Item);
					if (isFieldreq || isLookUp || isAllField || isEnumField) {
						//system.debug (LoggingLevel.Error, 'FieldName = ' + Item+' MasterDetail : '+F.isWriteRequiresMasterRead()+' Custom - '+F.isCustom() + ' : ' + f.getLocalName() + '\n' + result);
						Result.put(Item, this.fillField(Item,F.isUnique()));
						//system.debug (LoggingLevel.Error, 'FieldName = ' + Item+' MasterDetail : '+F.isWriteRequiresMasterRead()+' Custom - '+F.isCustom() + ' : ' + f.getLocalName() + '\n' + result);
					} else {

					}
				}

			} catch (Exception E) {				
				system.debug(LoggingLevel.ERROR,'Failure on Create object ' + allParams.objName + ' : ' + Item + ' : ' + E.getmessage());
			}
		}
		if (!createdObjects.containsKey(allParams.objName)) createdObjects.put(allParams.objName, new sObject[]{});
		createdObjects.get(allParams.objName).add(result);
		return result;
	}

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	fillField
	*	@param	{String} fieldName
	*	@param	{boolean} isUniq
	*	@return	object
	*
	*/
	private object fillField(String fieldName, boolean isUniq) {
	
		object result;

		String TestString = (isUniq ? system.now().formatLong().reverse().substring(0,3) : '') + 'Test String';

		Schema.DescribeFieldResult fieldDescribe = existfieldMap.get(allParams.objName).get(fieldName).getDescribe();
		Schema.DisplayType Type = fieldDescribe.getType();

		if (Type == Schema.DisplayType.Integer) result = 10;
		else if (Type == Schema.DisplayType.Date) result = system.now().date();
		else if (Type == Schema.DisplayType.DateTime) result = system.now();
		else if (Type == Schema.DisplayType.Time) result = system.now().time();
		else if (Type == Schema.DisplayType.Currency) result = math.rint(100);
		else if (Type == Schema.DisplayType.Percent) result = math.rint(100);
		else if (Type == Schema.DisplayType.Double) result = math.random();
		else if (Type == Schema.DisplayType.email) result = TestEmail;
		else if (Type == Schema.DisplayType.Url) result = 'http://google.com';
		else if (Type == Schema.DisplayType.Boolean) result = true;
		else if (Type == Schema.DisplayType.base64) result = blob.valueOf(TestString);
		else if (Type == Schema.DisplayType.Picklist || Type == Schema.DisplayType.MultiPicklist) result = returnPickList(fieldDescribe, TestString);
		else if (Type == Schema.DisplayType.Reference) result = returnReference(fieldDescribe, TestString);
		else result = returnString(fieldDescribe, TestString);

		return result;
	}
	
	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	returnString
	*	@param	{DescribeFieldResult} fieldDescribe
	*	@param	{String} TestString
	*	@return	object
	*
	*/
	private object returnString(Schema.DescribeFieldResult fieldDescribe, String TestString){
		Integer curFLen = fieldDescribe.getLength();
		object result = (curFLen < TestString.length() && curFLen>0) 
			? TestString.substring(0,curFLen-1)
			: TestString;
		return result;
	}

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	returnPickList
	*	@param	{DescribeFieldResult} fieldDescribe
	*	@param	{String} TestString
	*	@return	object
	*
	*/
	private object returnPickList(Schema.DescribeFieldResult fieldDescribe, String TestString) {
		Schema.PicklistEntry[] allPickValues = fieldDescribe.getPicklistValues();
		Integer curIndex = allPickValues.size() > 0 ? (integer) math.rint(allPickValues.size()-1) : 0;
		object result = allPickValues.size() > 0 ? allPickValues[curIndex].getValue() : TestString;
		return result;
	}

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	returnReference
	*	@param	{DescribeFieldResult} fieldDescribe
	*	@param	{String} TestString
	*	@return	object
	*
	*/
	private object returnReference(Schema.DescribeFieldResult fieldDescribe, String TestString) {
		object result;
		String RefObj = fieldDescribe.getReferenceTo()[0].getDescribe().getLocalName().toLowerCase();
		if (RefObj == 'user') result = userInfo.getUserId();
		else if (RefObj == 'RecordType') result = setRecordType(curObject);
		else if (RefObj == 'Profile') result = allParams.settings.get('userprofileId');
		else {
			if (!createdObjects.containsKey(RefObj)) {
				map <String, Object> tmpfieldSet = new map <String, Object>();
				for (String Item : allparams.fieldSetCorrect.keyset()) {
					if (Item.indexOf(RefObj.toLowerCase()+'.') !=-1) {
						tmpfieldSet.put(item.substringAfter(RefObj.toLowerCase()+'.'), allparams.fieldSetCorrect.get(Item));
					}
				}
				sObject tmp = new TestFramework(RefObj, tmpfieldSet, new map<String, object>{'createlookupobject' => false,'countobjects'=> 1}).createObject();
				insert tmp;
				system.debug(LoggingLevel.Error,'REFERENCE OBJECT : ' + tmp);
				createdObjects.put(RefObj, new sObject[]{tmp});
				result = createdObjects.get(RefObj)[0].Id;
			} else {
				result = createdObjects.get(RefObj)[0].Id;
			}
		}
		return result;
	}


	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	setRecordType
	*	@param	{SObject} obj
	*	@return	id
	*
	*/
	private id setRecordType(SObject obj) {
		List<Schema.RecordTypeInfo> recordTypes = obj.getSObjectType().getDescribe().getRecordTypeInfos();
		id Result = null;
		if (recordTypes.size() > 1) { // all objects have default Master type
			for (Schema.RecordTypeInfo recordType : recordTypes) {
				if (recordType.isAvailable() && recordType.isDefaultRecordTypeMapping()) {
					Result = recordType.getRecordTypeId();
					break;
				}
			}
		}
		return Result;
	}

	// Make email__c for email__c Fields
	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	TestEmail

	*	@return	String
	*
	*/
	public static String TestEmail {
		get {
			if (TestEmail == null) {
				String email = [select email from User where Id=:UserInfo.getUserId()].email;
				String domain = email.substring(email.indexOf('@')+1, email.length());
				if (domain.indexOf('.') != domain.lastIndexOf('.')) {
					domain = domain.substring(0, domain.lastIndexOf('.'));
				}
				Id orgid = UserInfo.getOrganizationId();
				email='test'+string.valueof(orgid).substring(10)+'@'+domain;
				email=(email.length()>32) ? email.substring(email.length()-32,email.length()) : email;
				TestEmail = email;
			}
			return TestEmail;
		}
	}

	// Create User with Profile = ProfileName
	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	createUser
	*	@param	{String} ProfileName
	*	@return	User
	*
	*/
	public static User createUser(String ProfileName) {
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		ProfileName = (ProfileName == null) ? 'Standard User' : ProfileName;
		Profile p = [SELECT Id FROM Profile WHERE Name=:ProfileName];
		String UName = string.valueOf(system.now().format('yyyyMMdd_hhmmss')) + randomInt + TestEmail;

		User u = new User(
			Alias = Uname.substring(0,7),
			email = Uname,
			EmailEncodingKey='UTF-8',
			LastName='Testing',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles',
			UserName = UName
		);
		return U;
	}

	//Get global Describe information
	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	getDescribeGlobal

	*	@return	Map<String, Schema.SObjectType>
	*
	*/
	public static Map<String, Schema.SObjectType> getDescribeGlobal {
		get {
			if (getDescribeGlobal == null) {
				Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
				return gd;
			} else return getDescribeGlobal;
		}

	}

	/*
		INNER Classes
	*/

	private class innerParams {
		public String objName;
		public map <String, Object> settings;
		public map <String, Object> fieldSetCorrect;

		public innerParams(String objName, Map<String,Object> fieldSet, map<String, Object> params) {
			this.objName = objName.toLowerCase();
			this.settings = new map<String, object>();
			this.fieldSetCorrect = new map <String, Object>();

			if (fieldSet != null) {
				for (String Item : fieldSet.keySet()) {
					fieldSetCorrect.put(Item.toLowerCase(),fieldSet.get(Item));
				}
			}
			// prepare settings
			if (params != null) {
				for (String Item : params.keyset()) {
					this.settings.put(Item.toLowerCase(), params.get(Item));

					if (Item == 'enumvalues') {
						this.settings.put(Item.toLowerCase(),new set<String>(string.valueof(params.get(Item)).toLowerCase().split('[ ],[ ]')));
					}
				}
			}

			String ProfileName = (this.getValueSetting('testuserprofile') == null) ? 'System Administrator' : (string) this.getValueSetting('testuserprofile');

			if (ProfileName!=PROFILE_NAME) {
				settings.put('userprofileid', [Select Id from Profile where Name = :ProfileName LIMIT 1].id);
				PROFILE_NAME = ProfileName;
			}

		}

		public object getValueSetting(String Key) {
			// need to set defaultValue
			object Result = null;
			if (this.settings.containsKey(Key.toLowerCase())) {
				Result = this.settings.get(Key);
			}
			return Result;
		}

		public object getValueFieldSet(String Key) {
			// need to set defaultValue
			object Result = null;
			if (this.fieldSetCorrect.containsKey(Key.toLowerCase())) {
				Result = this.fieldSetCorrect.get(Key);
			}
			return Result;
		}
	}

	static {
		existfieldMap = new map<String, map<String,Schema.SObjectField>>();
		createdObjects = new map<String, sObject[]>();
	}
}