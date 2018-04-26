/**
*   Account Console Sidebar implementation
*
*   @class AccountSidebarCardsService
*   author Dmitry Rivlin
*   @module {Console}
*   @constructor
*/

global with sharing class AccountSidebarCardsService implements vlocity_cmt.VlocityOpenInterface2 {

	public enum cardStatus {ERROR, INFO, WARNING, SUCCESS}
	private static String accLayout = '';

	/**
	*   Account Console Sidebar implementation
	*
	*   @class AccountSidebarCardsService
	*   author Dmitry Rivlin
	*   @module {Console}
	*   @constructor
	*/
	global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
		System.debug(Logginglevel.ERROR, 'AccountSidebarCardsService.invokeMethod - methodName: ' + methodName);
		System.debug(Logginglevel.ERROR, 'AccountSidebarCardsService.invokeMethod - inputMap: ' + inputMap);

		outMap.put('processError', 'false');

		try {

			if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('B2BAccountSidebar')) {
				return B2BAccountSidebar(inputMap, outMap, options);
			}

			else if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getProductIndicators')) {
				return getProductIndicators(inputMap, outMap, options);
			}

			else if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('getAccessibilityFirstIndicators')) {
				return getAccessibilityFirstIndicators(inputMap, outMap, options);
			}
			else if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('B2CCustomerExposure')) {
				return B2CCustomerExposure(inputMap, outMap, options);
			}
		} catch (Exception e) {
			outMap.put('EXCEPTION',methodName + ':' + e.getMessage() + ':' + e.getStackTraceString());
			system.debug(Logginglevel.ERROR, 'invokeMethod ' + methodName + ' ERROR :' + e.getMessage() + ':' + e.getStackTraceString());
			return returnError(outMap, cardStatus.ERROR, Label.ErrCardIntegration.replace('{0}', methodName));
		}

		return true;

	}

	public static Boolean handleMatalCoordData(Account a, List<User> matalList, CoordinatorTeamList coordTeamLs){

		Boolean userIsTeamMem = false;
		String currUser = UserInfo.getUserId();

		//PLR-217 Add Income, Reciprocity and Interesting fields from Account when user is an AccountTeamMember.
		List <AccountTeamMember> teamMembers = [SELECT Id, UserID, TeamMemberRole
												FROM AccountTeamMember
												WHERE AccountId = :a.id ];

		Set<String> accUsrList = new Set<String>();

		for( AccountTeamMember currTeamMemb : teamMembers ) {
			if(currTeamMemb.UserId == currUser)
				userIsTeamMem = true;

			if(currTeamMemb.TeamMemberRole == 'Account Manager') {
				accUsrList.add(currTeamMemb.UserID);
			}
		}

		for(User user : [SELECT FederationIdentifier, Name FROM User WHERE Id in: accUsrList AND IsActive = true]){
			matalList.add(user);
		}

		//PLR-179 Add list of AccountShare members to show on card.
		List<AccountShare> accountShareList = [SELECT RowCause , UserOrGroupId, UserOrGroup.Name FROM AccountShare
											WHERE RowCause = 'Manual' AND UserOrGroupId IN (SELECT Id FROM Group) AND AccountId =: a.Id];

		List<User> tempUserLst;
		CoordinatorTeam tempCoordTeam;

		//list of userOrGroup Ids from AccountShare
		list<String> userOrGroupIdASList = new list<String>();

		//list of userOrGroup Ids from GroupMember
		list<String> userOrGroupIdGMList = new list<String>();

		//Map for each groupId its group Name
		map<Id, String> groupIdGroupNamemap = new map<Id, String>();

		for(AccountShare currAccShare : accountShareList) {
			groupIdGroupNamemap.put(currAccShare.UserOrGroupId, currAccShare.UserOrGroup.Name);
		}

		map<Id, list<GroupMember>> groupId_MemberMap = new map<Id, list<GroupMember>>();

		List<GroupMember> groupMemberList = [SELECT GroupId, UserOrGroupId from GroupMember where GroupId IN :groupIdGroupNamemap.keySet()];

		for(GroupMember groupMember : groupMemberList){

			if(! groupId_MemberMap.containsKey(groupMember.GroupId))
				groupId_MemberMap.put(groupMember.GroupId, new list<GroupMember>{groupMember});
			else
				groupId_MemberMap.get(groupMember.GroupId).add(groupMember);

			userOrGroupIdGMList.add(groupMember.UserOrGroupId);
		}
		system.debug('####groupId_MemberMap: ' + groupId_MemberMap.size());

		map<Id, User> m_idUser = new map<Id, User>([
			SELECT FederationIdentifier, Name FROM User WHERE Id IN :userOrGroupIdGMList AND IsActive = true]);

		if( !userIsTeamMem ) {
			userIsTeamMem = m_idUser.containsKey(currUser);
		}

		for(Id groupId : groupId_MemberMap.keySet()){

			tempCoordTeam = new CoordinatorTeam(groupIdGroupNamemap.get(groupId));

			for(GroupMember groupMember : groupId_MemberMap.get(groupId)){

				if(m_idUser.containsKey(groupMember.UserOrGroupId)){

					Coordinator coord = new Coordinator(m_idUser.get(groupMember.UserOrGroupId).FederationIdentifier, m_idUser.get(groupMember.UserOrGroupId).Name);
					tempCoordTeam.coordTeam.add(coord);
				}
			}

			coordTeamLs.coordTeamList.add(tempCoordTeam);
		}

		return userIsTeamMem;

	}

	private static void cleanNonDigits(Contact obj){
		if (obj.Phone != null){
			obj.Phone = obj.Phone.replaceAll('[^0-9]','');
		}
		if (obj.HomePhone != null){
			obj.HomePhone = obj.HomePhone.replaceAll('[^0-9]','');
		}
		if (obj.MobilePhone != null){
			obj.MobilePhone = obj.MobilePhone.replaceAll('[^0-9]','');
		}
	}

	private static Boolean B2BAccountSidebar(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

		if (!inputMap.containsKey('accountId') || String.isEmpty((string) inputMap.get('accountId'))) return returnError(outMap, cardStatus.ERROR, Label.msgAccountNotFound);
		string interactionLogPrefix = InteractionEvent__c.sobjecttype.getDescribe().getKeyPrefix();
		String accountId = (string) inputMap.get('accountId');

		if (accountId.startsWith(interactionLogPrefix)) {
			InteractionEvent__c IE = [SELECT AccountId__c, ContactId__c FROM InteractionEvent__c WHERE Id =: accountId];
			accountId = IE.accountId__c;
			inputMap.put('contactId', IE.contactId__c);
		}

		Contact c = checkLinkContactToAccount(accountId, (String) inputMap.get('contactId'), outMap);

		if (c == null) return false;
		cleanNonDigits(c);
		Account a = new Account();
		String soql = 'SELECT Name, Income__c,Reciprocity__c,toLabel(Interesting__c), Parent.RecordType.DeveloperName, Parent.Name, toLabel(vlocity_cmt__Status__c), ShippingCity__c, ShippingStreet__c, ShippingHouseNum__c , ShippingPostalCode__c, ShippingPOB__c, toLabel(Segment__c), toLabel(RecordType.Name), RecordType.DeveloperName, ConsumerType__c, Phone,CELL_Ind__c,NETV_Ind__c ';
		soql += ', (SELECT Id FROM ChildAccounts WHERE RecordType.DeveloperName = ' + '\'' + 'Billing' + '\'' + ')';
		String soqlOdata = ',(Select id_number__c, company_name__c From AccountKeys__r)';
		String soqlParty = ', (SELECT id, Name FROM vlocity_cmt__Party__r)';
		String fromWHEREClause = ' FROM Account WHERE Id = ' + '\'' +  accountId + '\' LIMIT 1';
		String soqlNoOdata = (accLayout == 'B2BMainPreview') ? soql + soqlParty : '';
		soql += (accLayout == 'B2BMainPreview') ? soqlParty + soqlOdata : '';

		try {
			a = database.Query(soql + fromWHEREClause);
		}

		catch(Exception exc) {
			a = database.Query(soqlNoOdata + fromWHEREClause);
		}

		a.vlocity_cmt__TaxID__c = (a.AccountKeys__r != null &&  !a.AccountKeys__r.isEmpty()) ? a.AccountKeys__r[0].id_number__c : '';

		String parentRecType = a.Parent.RecordType.DeveloperName;
		Boolean userIsTeamMem = false;

		// Retrieve following data only in case of B2B
		if(a.RecordType.DeveloperName == 'Business') {

			// call new function that will return matal and coordinator list
			List<User> matalList = new List<User>();

			CoordinatorTeamList coordTeamLs = new CoordinatorTeamList();

			userIsTeamMem = handleMatalCoordData(a, matalList, coordTeamLs);

			outMap.put('matalList', matalList);
			outMap.put('AccountShareData',coordTeamLs);

			List <AccountContactRelation> listAccountCR= [SELECT tolabel(Roles), tolabel(B2BRoleType__c)
														FROM AccountContactRelation
														WHERE ContactId =: c.Id and AccountId =: accountId and IsActive = true LIMIT 1];
			outMap.put('AccountContactRelations', listAccountCR);


		}
		//END only for B2B customers

		if( !userIsTeamMem )
		{
			a.Income__c = 0;
			a.Reciprocity__c = 0;
			a.Interesting__c = '';
		}

		AccountContactRelation minAccountContactRelation = setMinRoleFunction(c, a);

		outMap.put('AccountInfo', new map < String, object > {
			'Contact' => c,
			'Account' => a,
			'ParentRecordType' => parentRecType,
			'MinRoleFunction' => minAccountContactRelation != null ? minAccountContactRelation.RoleFunction__c : null,
			'isPOA' => minAccountContactRelation != null ? String.valueOf(minAccountContactRelation.IsPowerOfAttorney__c) : null
		});

		Account[] accLst = [
			SELECT Name, ParentId, RecordType.DeveloperName, toLabel(RecordType.Name), AccountNumber, Parent.RecordType.DeveloperName, Parent.Name
			FROM Account
			WHERE Id IN(SELECT AccountId FROM AccountContactRelation WHERE ContactId =: c.Id) AND Id !=: (id) inputMap.get('accountId') AND RecordType.DeveloperName = 'Consumer'
		];

		outMap.put('PersonContactProfile', accLst);

		return true;
	}

	private static Boolean B2CCustomerExposure(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
		//Credit Control callout
		Map<String, Object> resBody;

		String inputAccId = (String)inputMap.get('accountId');
		String inputContId = (String)inputMap.get('contactId');
		String SSN = (String)inputMap.get('SSN');

		if( String.isEmpty(inputAccId) || String.isEmpty(inputContId) ) {
			return null;
		}

		Account a = getAccountWithActiveBillAcc(inputAccId);
		Contact c = getContact(inputContId);

		boolean isNeedSet = isNeedSetBanPsIds(A);

		// ELAD :  This is an overhead - the method 'getRecordTypeIdByName' retreives ALL the record types of ALL objects in the system (currently 85 Records), we only need 1 record type, please fix
		if(a != null && c != null  && isNeedSet && a.recordTypeId==RecordTypeService.getSelectiveRecordTypeIdByName('Account', 'Consumer')){
			//From user need the locatoin__c field
			User curUser = [select id, location__c, DealerCode__c from user where id =:userInfo.getUserId()];
			CreditControlRequestBuilder creditControlerRequest =
				new CreditControlRequestBuilder(SSN ,  a.recordType != null ? a.recordType.developerName.left(1) : '', curUser.location__c, curUser.DealerCode__c);
				system.debug('creditControlerRequest '+creditControlerRequest);

			creditControlerRequest.CustInfo.setBanPsIds(a, c);

			OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00667', outMap, Label.msgSrvErr667, Label.msgSrvWarn667,new map<String, object>{'withoutCheck' => true});
			request.body.setRequestNode(creditControlerRequest );
			Map<String, Object> response = request.sendRequestWithErrorCheck('OSB', 'api/services/rest/00667_osb_calculatecurrentrisk_bp');
			system.debug('#### response-ilana' + response);
			if(response != null){
				Map<String, Object> responseBody = (Map < String, Object>)response.get('Body');

				if(responseBody != null){
					resBody = (Map < String, Object>)responseBody.get('Response');
				}
			}
		}


		outMap.put('AccountInfo', new map < String, object > {
			/*'Contact' => c,
			'Account' => a,*/
			/*'ParentRecordType' => parentRecType,*/
		/* 'MinRoleFunction' => minAccountContactRelation != null ? minAccountContactRelation.RoleFunction__c : null,*/
			'NumPayment' => resBody!=null && resBody.containsKey('NumPayment') ? resBody.get('NumPayment') : '',
			'CurrentRiskByNum' => resBody!=null && resBody.containsKey('RemainRiskByNum') ? resBody.get('RemainRiskByNum') : '',
			// bug 92148 'CurrentRisk' => resBody!=null && resBody.containsKey('AllowedRisk') ? resBody.get('AllowedRisk') : ''});
			'CurrentRisk' => resBody!=null && resBody.containsKey('RemainRisk') ? resBody.get('RemainRisk') : ''

		});

		system.debug('outMap '+outMap);

		return true;
	}


	/**
	*   method return the min RoleFunction
	*   author Tal sabati
	*   @method setMinRoleFunction
	*   @param  {Contact} c
	*   @param  {Account} a
	*   @return {AccountContactRelation} minAccountContactRelation
	*
	*/
	private static AccountContactRelation setMinRoleFunction(Contact c, Account a){
		AccountContactRelation minAccountContactRelation ;
		set<Id> childAccountsIdsSet = new set<Id>();
		for(Account child : a.ChildAccounts){
			childAccountsIdsSet.add(child.id);
		}

		list<AccountContactRelation> accoConRelationList = [Select AccountId, ContactId, toLabel(RoleFunction__c), LevelOfRoleFunction__c, IsPowerOfAttorney__c
															From AccountContactRelation
															Where Account.RecordType.DeveloperName = 'Billing'
															And ContactId =: c.id
															And AccountId IN: childAccountsIdsSet
															ORDER BY LevelOfRoleFunction__c ASC NULLS LAST LIMIT 1];

		if(accoConRelationList != null && !accoConRelationList.isEmpty()){
			minAccountContactRelation = accoConRelationList[0];
		}
		return minAccountContactRelation;
	}
	/**
	*   method description
	*   author Dmitry Rivlin
	*   taskId
	*
	*   @method checkLinkContactToAccount
	*   @param  {String} accId
	*   @param  {String} cntId
	*   @return Contact
	*
	*/

	private static Contact checkLinkContactToAccount(String accId, String cntId, Map < String, Object > outMap) {

		Contact result = null;
		Contact[] c = null;

		if (string.isEmpty(accId)) return result;

		if (string.isEmpty(cntId)) {

			AccountContactRelation[] acr = [SELECT ContactId, Contact.Id,  Account.CardLayout__c FROM AccountContactRelation WHERE AccountId=:accId AND IsActive = true LIMIT 1];
			if( acr.size() > 0 ) {
				accLayout = acr[0].Account.CardLayout__c;
				result = acr[0].Contact;
			}
			else {
				result = null;
			}
		}

		else {
			AccountContactRelation[] acrEmptyCnt = [SELECT Contact.Id,  Account.CardLayout__c FROM AccountContactRelation WHERE ContactId =:cntId AND AccountId=:accId AND IsActive = true];
			if (acrEmptyCnt.size() > 0) {
				accLayout = acrEmptyCnt[0].Account.CardLayout__c;
				result =  acrEmptyCnt[0].Contact;
			}
		}

		if (result != null) {

			//From now we don't use ODATA in Contact
			try {
				result  = [SELECT  Name, FirstName, toLabel(vlocity_cmt__Type__c), LastName, Title, Email, MailingAddress, Phone, HomePhone, MobilePhone, CellcomExternalId__c, vlocity_cmt__SSN__c, (select id_number__c from ContactKeys__r)  FROM Contact WHERE Id =: result.Id];
				system.debug('result=> '+result);
				system.debug(Logginglevel.ERROR,'ODATA ' + result);
				if (test.isRunningTest()) return result;

				if (result.ContactKeys__r.size() > 0) {
					result.vlocity_cmt__SSN__c = result.ContactKeys__r[0].id_number__c;
				}
			} catch (Exception E){
				result  = [SELECT  FirstName, vlocity_cmt__Type__c, LastName, Title, Email, MailingAddress, Phone, HomePhone, MobilePhone, CellcomExternalId__c FROM Contact WHERE Id =: result.Id];
				returnError(outMap, cardStatus.WARNING, Label.msgAccountSidebarContactOdata);
			}
		} else {
			returnError(outMap, cardStatus.WARNING, Label.msgAccountSidebarContact);
		}


		return result;
	}

	/* NEW METHOD THAT WE NEEED USE */

	public static boolean returnError(Map < String, Object > outMap, cardStatus status, object msg) {
		Boolean result = false;
		if (status == cardStatus.ERROR) {
			outMap.put('processError', 'true');
		}

		String statusMsg = (status == cardStatus.ERROR)
			? 'processErrorMsg'
			: (status == cardStatus.INFO)
				? 'processInfoMsg'
				: (status == cardStatus.WARNING)
					? 'processWarningMsg'
					: (status == cardStatus.SUCCESS)
						? 'processSuccessMsg'
						: null;

		outMap.put(statusMsg, msg);

		return result;
	}

	public static boolean isError(Map < String, Object > outMap, OSBCalloutBuilder.OSBRequest response , object msg) {

		if (response.errorCode == null || response.errorCode == 99) {
			return returnError(outMap,cardStatus.ERROR, msg + ' : ' + response.errorCodeMessage);
		}
		if (response.errorCode > 0 && response.errorCode < 99) {
			return returnError(outMap,cardStatus.WARNING, msg + ' : ' + response.errorCodeMessage);
		}
		return false;
	}


	/**
	*   method Outer function for retrieving product indicators.
	*   author Tal sabati
	*   taskId PLR-874
	*
	*   @method getFirstIndicators
	*   @param  {Map}
	*   @param  {Map}
	*   @param  {Map}
	*   @return {Boolean}
	*
	*/
	private static Boolean getAccessibilityFirstIndicators(Map <String, Object> inputMap, Map <String, Object> outMap, Map <String,Object> options) {

		String inputAccId = (String)inputMap.get('accountId');
		String inputContId = (String)inputMap.get('contactId');
		if( String.isEmpty(inputAccId) || String.isEmpty(inputContId) ){
			return null;
		}
		Account inputAccount = getAccount(inputAccId);
		Contact inputContact = getContact(inputContId);

		boolean isNeedSet = isNeedSetBanPsIds(inputAccount);
		
		//outMap.put('dataAdd',inputAccount);

		if (!isNeedSet) return true;

		IndicatorsCalloutBuilder.IndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.IndicatorsRequestBuilder();

		IndicatorsCalloutBuilder.AccessibilityFirstIndicatorsCustInfoBuilder curCustInfo = new IndicatorsCalloutBuilder.AccessibilityFirstIndicatorsCustInfoBuilder(inputAccount.RecordType.DeveloperName);
		curCustInfo.ContactIdentifier = inputContact.CellcomExternalID__c;
		curCustInfo.setBanPsIds(inputAccount,inputContact);
		curRequest.setCustInfoNode(curCustInfo);

		//OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00681');
		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00681', outMap, Label.msgSrvErr668, Label.msgSrvWarn681);
		request.body.setRequestNode(curRequest);

		Map<String,Object> response = request.sendRequestWithErrorCheck('OSB','api/services/rest/00681_osb_retrievecustomerflags_k2view');

        if(inputAccount.RecordType.DeveloperName == 'Business'){
            addViewB2BGoldPermissionToList(response);
        }
		outMap.put('data',response);

		return true;
	}

    /**
	*   Method for check if the user has permission to view the gold customers
	*   Author Tal sabati
	*
	*   @method addViewB2BGoldPermissionToList
	*   @param  {Map<String,Object>} responseMap
	*   @return {Boolean}
	*
	*/
    private static void addViewB2BGoldPermissionToList(Map<String,Object> responseMap){
        if(!Test.isRunningTest()){
             if(responseMap.containsKey('Body')){
                Map<String,Object> bodyMap = (Map<String,Object>) responseMap.get('Body');
                if(bodyMap.containsKey('Response')){
                    Map<String,Object> responsetMap = (Map<String,Object>) bodyMap.get('Response');
                    if(responsetMap.containsKey('Account')){
                        List<Object> accountArray = (List<Object>) responsetMap.get('Account');
                        for(Object account : accountArray){
                            Map<String,object> acc = (Map<String,object>) account;
                            if(acc.containsKey('Indicators')){
                                Map<String,object> indicatorsArray = (Map<String,object>) acc.get('Indicators');
                                if(indicatorsArray.containsKey('indGold') ){
                                    //WritePermissionsObject__c.getInstance().ViewB2BGold__c
                                    if(indicatorsArray.get('indGold') == 'Y' && !CustomPermissionService.getCustomPermissionByName('View_B2B_Gold')){
                                        indicatorsArray.put('indGold', 'noPermissionToview');
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
	/**
	*   method Outer function for retrieving product indicators.
	*   author Elad Iflah
	*   taskId PLR-874
	*
	*   @method getProductIndicators
	*   @param  {Map}
	*   @param  {Map}
	*   @param  {Map}
	*   @return {Boolean}
	*
	*/
	private static Boolean getProductIndicators(Map <String, Object> inputMap, Map <String, Object> outMap, Map <String,Object> options) {

		String inputAccId = (String)inputMap.get('accountId');
		String inputContId = (String)inputMap.get('contactId');

		if( String.isEmpty(inputAccId) || String.isEmpty(inputContId) ) {
			return null;
		}

		Account inputAccount = getAccount(inputAccId);
		Contact inputContact = getContact(inputContId);

		boolean isNeedSet = isNeedSetBanPsIds(inputAccount);

		if (!isNeedSet) return true;

		IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder curRequest = new IndicatorsCalloutBuilder.GeneralIndicatorsRequestBuilder(inputAccount.RecordType.DeveloperName);
		curRequest.CustInfo.ContactIdentifier = inputContact.CellcomExternalID__c;
		curRequest.CustInfo.setBanPsIds(inputAccount,inputContact);

		//OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00689');
		OSBCalloutBuilder.OSBRequest request = new OSBCalloutBuilder.OSBRequest('00689', outMap, Label.msgSrvErr689, Label.msgSrvWarn689);
		request.body.setRequestNode(curRequest);

		Map<String,Object> response = request.sendRequestWithErrorCheck('OSB','api/services/rest/00689_osb_b2ccustomerassetsindicators_k2view');
		//if (isError(outMap,request, Label.msgResponseIssue)) return false;

		/*if (response == null) {
			return returnError(outMap, 'processErrorMsg', 'Response issue');

		}*/

		outMap.put('data',response);

		return true;

	}

	public static boolean isNeedSetBanPsIds(Account A) {
		if (A==null || A.ChildAccounts == null || A.ChildAccounts.size() == 0) return false;
		for (Account item : A.ChildAccounts) {
			if (item.RecordType.DeveloperName == 'Billing' && (!string.isEmpty(item.BANPSID__c) || !string.isEmpty(item.CellcomExternalID__c))) return true;
		}
		return false;
	}

	public static Account getAccount(String accountId) {

		List<Account> accList = [SELECT Name, BillingAddress, toLabel(Segment__c), RecordType.DeveloperName,toLabel(RecordType.Name), ConsumerType__c,ConsumerTypeEnglish__c, Phone,BANPSID__c,CellcomExternalID__c,CELL_Ind__c, NETV_Ind__c,
								(SELECT Name, AccountNumber, PaidById__c, PaidById__r.Name, RecordType.DeveloperName, CellcomExternalID__c,CELL_Ind__c, NETV_Ind__c, BANPSID__c,NVID__c, BillingStreet, BillingCity, BillingPostalCode__c, toLabel(vlocity_cmt__Status__c) FROM ChildAccounts WHERE RecordType.DeveloperName = 'Billing')
								FROM Account
								WHERE Id = :accountId];

		if (accList.isEmpty()){
			return null;
		}

		return accList[0];
	}

	public static Account getAccountWithActiveBillAcc(String accountId) {

		List<Account> accList = [SELECT Name, BillingAddress, toLabel(Segment__c), RecordType.DeveloperName, toLabel(RecordType.Name), ConsumerType__c, Phone,BANPSID__c,CellcomExternalID__c,CELL_Ind__c, NETV_Ind__c,
								(SELECT Name, AccountNumber, RecordType.DeveloperName, CellcomExternalID__c,CELL_Ind__c, NETV_Ind__c, BANPSID__c,NVID__c, BillingStreet, BillingCity, BillingPostalCode__c, toLabel(vlocity_cmt__Status__c) FROM ChildAccounts WHERE RecordType.DeveloperName = 'Billing' AND ( vlocity_cmt__Status__c = 'Active' OR vlocity_cmt__Status__c = 'Suspended') )
								FROM Account
								WHERE Id = :accountId];

		if (accList.isEmpty()){
			return null;
		}

		return accList[0];
	}


	public static Contact getContact(String contactId) {

		List<Contact> conList = [SELECT Id, vlocity_cmt__SSN__c, CellcomExternalID__c FROM Contact WHERE Id = :contactId];
		if(conList.isEmpty()) {
		return null;
		}
		return conList[0];
	}


	public class CoordinatorTeamList {
		public List<CoordinatorTeam> coordTeamList;
		public CoordinatorTeamList(){
			coordTeamList = new List<CoordinatorTeam>();
		}
	}

	public class CoordinatorTeam {
		String name;
		public List<Coordinator> coordTeam;
		public CoordinatorTeam(String Name) {
		this.name = Name;
			coordTeam = new List<Coordinator>();
		}
	}

	public class Coordinator {
		String userId;
		String name;

		public Coordinator(String UserId, String Name) {
			this.userId = UserId;
			this.name = Name;
		}
	}

	public class Matal {
		String userId;
		String name;

		public Matal(String UserId, String Name) {
			this.userId = UserId;
			this.name = Name;
		}
	}

	public class CreditControlRequestBuilder extends IndicatorsCalloutBuilder.IndicatorsRequestBuilder{

		public CreditControlServiceInfo ServiceInfo;

		public CreditControlRequestBuilder(String iValue, String rType, String location, String dCode){
			ServiceInfo = new CreditControlServiceinfo(iValue, rType, location, dCode);
		}
	}

	public class CreditControlServiceinfo{
		public String IdentificationValue;
		public String IdentificationType;
		public String RecordType;
		public String SaleLocation;
		public String SaleChanel;
		public String DealerCode;

		public CreditControlServiceinfo(String iValue, String rType, String location, String dCode){
			IdentificationValue = iValue;
			RecordType = rType;
			SaleLocation = location;
			SaleChanel = '04';
			IdentificationType='I';
			DealerCode = dCode;
		}
	}
}