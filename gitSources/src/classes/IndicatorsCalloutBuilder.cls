/**
* Class helper for building Json request\response for Indicators callouts
* Gili Yehuda
* taskid PLR-137
* @class IndicatorsCalloutBuilder
* @module 360
*/
public with sharing class IndicatorsCalloutBuilder {
    /*
        NEW IMPLEMENTATION
    */

    public virtual class CustomerInfoBuilder{
        public String Ssn;
        public String ContactIdentifier ;
        public String AccountIdentifier ;
        public PsIdsBuilder PsIds;
        public BanIdsBuilder BanIds;

        public CustomerInfoBuilder() {
            this.PsIds = new PsIdsBuilder();
            this.BanIds = new BanIdsBuilder();
        }

        public CustomerInfoBuilder(String[] psIds, String[] banIds) {
            this.PsIds = new PsIdsBuilder(psIds);
            this.BanIds = new BanIdsBuilder(banIds);
        }

        public void setBanPsIds(Account parentAccount, Contact contact) {
            this.AccountIdentifier = parentAccount.CellcomExternalID__c;
            this.ContactIdentifier = contact.CellcomExternalID__c;

            if(parentAccount.RecordType.DeveloperName == 'Business'){
                for(Account currAcc :  parentAccount.ChildAccounts) {
                    if(currAcc.CELL_Ind__c && String.isNotBlank(currAcc.BANPSID__c)) {
                        BanIds.BanId.add(currAcc.BANPSID__c);
                    }
                    else if(currAcc.NETV_Ind__c && String.isNotBlank(currAcc.BANPSID__c)) {
                        PsIds.PsId.add(currAcc.BANPSID__c);
                    }
                }
            }
            else{
                        
                List<AccountContactRelation> accContRelList = [SELECT AccountId ,BANPSID__c, Account.CELL_Ind__c, Account.NETV_Ind__c FROM AccountContactRelation
                                                            where ContactId = :contact.Id and AccountRecordTypeName__c = 'Billing' AND AccountId IN :parentAccount.ChildAccounts AND IsActive = true];

                for( AccountContactRelation currAccCont :  accContRelList) {
                    if(currAccCont.Account.CELL_Ind__c && String.isNotBlank(currAccCont.BANPSID__c)) {
                        BanIds.BanId.add(currAccCont.BANPSID__c);
                    }
                    else if(currAccCont.Account.NETV_Ind__c && String.isNotBlank(currAccCont.BANPSID__c)) {
                        PsIds.PsId.add(currAccCont.BANPSID__c);
                    }
                }
            }
        }


    }

    public class PsIdsBuilder {
        public String[] PsId;
        public PsIdsBuilder() {
            this.PsId = new String[]{};
        }

        public PsIdsBuilder(String[] psIds) {
            this.PsId = psIds;
        }
    }

    public class BanIdsBuilder {
        public String [] BanId;

        public BanIdsBuilder() {
            this.BanId = new String[]{};
        }
        public BanIdsBuilder(String[] banIds) {
            this.BanId = banIds;
        }
    }

    public virtual class IndicatorsRequestBuilder extends OSBCalloutBuilder.RequestBuilder{
        public CustomerInfoBuilder CustInfo;

        public IndicatorsRequestBuilder() {
            CustInfo = new CustomerInfoBuilder();
        }

        public IndicatorsRequestBuilder(String[] psIds, String[] banIds) {
            CustInfo = new CustomerInfoBuilder(psIds, banIds);
        }

        public IndicatorsRequestBuilder(CustomerInfoBuilder cust) {
            CustInfo = cust;
        }

        public void setCustInfoNode(CustomerInfoBuilder CustInfo) {
            this.CustInfo = CustInfo;
        }
    }



    /**
    * Class helper for creating and populating Json request for B2CFirstIndicators callout
    * Tal sabati
    * taskid PLR-838
    * @class B2CFirstIndicators
    * @module 360
    */
    public class B2CFirstIndicatorsRequestBuilder extends OSBCalloutBuilder.RequestBuilder{
        public B2CFirstIndicatorsServiceInfoBuilder ServiceInfo;
        public CustomerInfoBuilder CustInfo;

        public B2CFirstIndicatorsRequestBuilder() {
            ServiceInfo = new B2CFirstIndicatorsServiceInfoBuilder();
            CustInfo = new CustomerInfoBuilder();
        }
        public void setServiceInfoNode(B2CFirstIndicatorsServiceInfoBuilder ServiceInfo) {
            this.ServiceInfo = ServiceInfo;
        }
        public void setCustInfoNode(CustomerInfoBuilder CustInfo) {
            this.CustInfo = CustInfo;
        }
    }

    public class B2CFirstIndicatorsServiceInfoBuilder {
        public DatesInfoBuilder getCaseOpenInd;
        public DatesInfoBuilder getNoteOpenInd;
        public DatesInfoBuilder getTechVisitOpenInd;
        public DatesInfoBuilder getDeliveryOpenInd;
        public RequiredBuilder getLoveCellcomInd;
        public RequiredBuilder getReturnCustomerInd;
        public RequiredBuilder getLegalInd;

        public B2CFirstIndicatorsServiceInfoBuilder() {
            getCaseOpenInd = new DatesInfoBuilder();
            getNoteOpenInd = new DatesInfoBuilder();
            getTechVisitOpenInd = new DatesInfoBuilder();
            getDeliveryOpenInd = new DatesInfoBuilder();
            getLoveCellcomInd = new RequiredBuilder();
            getReturnCustomerInd = new RequiredBuilder();
            getLegalInd = new RequiredBuilder();
        }
    }

    public class RequiredBuilder {
        public String Required;
        public RequiredBuilder(){
            Required = 'Y';
        }
    }

    public class DatesInfoBuilder {
        public String StartDate;
        public String EndDate;
        public String Required;

        public DatesInfoBuilder(){
            DateTime d = Date.Today() ;
            StartDate = d.format('dd/MM/yyyy');
            EndDate = d.format('dd/MM/yyyy');
            Required = 'Y';
        }
        public void setDatesInfoBuilder(String daysBack, String daysForward){
            Integer openDaysBack = Integer.valueOf(CustomMetadataTypeService.getCrmVariable(daysBack));
            Integer openDaysForward = Integer.valueOf(CustomMetadataTypeService.getCrmVariable(daysForward));
            DateTime d = Date.Today();
            StartDate = String.valueOf(d.addDays(-openDaysBack).format('dd/MM/yyyy'));
            EndDate = String.valueOf(d.addDays(openDaysForward).format('dd/MM/yyyy'));
        }
    }













    //Shared
    /**
    * Class helper for creating and populating Json Header request for all callouts
    * Gili Yehuda
    * taskid PLR-137
    * @class CalloutHeader
    * @constructor
    * @param {String} funcCode
    * @module 360
    */
    public class CalloutHeader{
        private String source;
        private String target;
        private String userName;
        private String functionCode;

        public CalloutHeader(String funcCode){
            source='SF';
            target='OSB';
            functionCode=funcCode;
        /** String userNameTmp=UserInfo.getUserName();
            Integer index=userNameTmp.indexOf('@');
            UserName=userNameTmp.substring(0,index);*/
            userName='SKLEIN';
        }

        /**
        * Method that serialize this object, replace members names
        * and returns the new deserialized Json as Map<String, Object>.
        * Gili Yehuda
        * taskid PLR-137
        * @method setMap
        * @return {Map}
        */
        public map<String, Object> setMap(){
            String tmp = Json.serialize(this);
            //tmp = tmp.replaceAll('(?i)\bFrom1\b','From');
            tmp=tmp.replace('source','From');
            tmp=tmp.replace('target','To');
            tmp=tmp.replace('userName','UserName');
            tmp=tmp.replace('functionCode','FunctionCode');

            return (Map<String, Object>)Json.deserializeUntyped(tmp);
        }
    }

    /**
    * Class helper for creating and populating Json request for DebtsLegalIssues callout
    * Gili Yehuda
    * taskid PLR-137
    * @class DebtsLegalIssuesReq
    * @module 360
    */
    public class DebtsLegalRequestBuilder extends IndicatorsRequestBuilder {
        public serviceInfoBuilder ServiceInfo;
        public String IncludeBalance;
        public String IncludeDebt;
        public String IncludeFutureCheques;
        public String IncludeLastInvoice;
        public String IncludeLegalInfo;
        public String IncludeCollectionInfo;
        
        public DebtsLegalRequestBuilder(String AccountRecordType, String includeBalance, String includeDebt, 
                                        String includeFutureCheques, String includeLastInvoice, String includeLegalInfo, 
                                        String includeCollectionInfo) {
                                            this.ServiceInfo = new serviceInfoBuilder(AccountRecordType);
                                            this.IncludeBalance = includeBalance;
                                            this.IncludeDebt = includeDebt;
                                            this.IncludeFutureCheques = includeFutureCheques;
                                            this.IncludeLastInvoice = includeLastInvoice;
                                            this.IncludeLegalInfo = includeLegalInfo;
                                            this.IncludeCollectionInfo = includeCollectionInfo;
                                        }
    }
    
    
    public class DebtsLegalIssuesReq{
        public Map<String, Object> Header;
        public BodyBuilder Body;
    }

    public class BodyBuilder {
        public RequestBuilder Request;
    }

    public class RequestBuilder {
        public CustInfoBuilder CustInfo;
        public String IncludeBalance;
        public String IncludeDebt;
        public String IncludeFutureCheques;
        public String IncludeLastInvoice;
        public String IncludeLegalInfo;
        public String IncludeCollectionInfo;
    }

    public class CustInfoBuilder{
        public String Ssn;
        public String ContactIdentifier ;
        public String AccountIdentifier ;
        public PsIdsBuilder PsIds;
        public BanIdsBuilder BanIds;
    }


    /**
    * Class helper for creating and populating Json request for DeviceInRepair / CustomerDelivery callout
    * Gili Yehuda
    * taskid PLR-75 | PLR-132
    * @class DeviceInRepairCustomerDeliveryRequest
    * @module 360
    */

    public class DeviceInRepairCustomerDeliveryRequest extends IndicatorsRequestBuilder {
        public RepairDeliveryServiceInfoBuilder ServiceInfo;
        public DeviceInRepairCustomerDeliveryRequest(list<StatusDateInfoBuilder> statusDateInfo) {
            this.ServiceInfo = new RepairDeliveryServiceInfoBuilder(statusDateInfo);
        }
    }

    public class RepairDeliveryServiceInfoBuilder {
        public StatusesDatesInfoBuilder StatusesDatesInfo;
        public RepairDeliveryServiceInfoBuilder(list<StatusDateInfoBuilder> statusDateInfo) {
            this.StatusesDatesInfo = new StatusesDatesInfoBuilder(statusDateInfo);
        }
    }

    public class StatusesDatesInfoBuilder {
        public list<StatusDateInfoBuilder> StatusDateInfo;
        public StatusesDatesInfoBuilder(list<StatusDateInfoBuilder> statusDateInfo) {
            this.StatusDateInfo = statusDateInfo;
        }
    }

    public class StatusDateInfoBuilder {
        public String Status;
        public String StartDate;
        public String EndDate;

        public StatusDateInfoBuilder(String Stat, String daysBack, String daysForward, boolean dateTimeInd){
            Status = Stat;
            Integer DaysBk = Integer.valueOf(CustomMetadataTypeService.getCrmVariable(daysBack));
            Integer DaysFd = Integer.valueOf(CustomMetadataTypeService.getCrmVariable(daysForward));

            if(dateTimeInd) {
                DateTime nowDate = Datetime.now();
                StartDate =String.valueOf(nowDate.addDays(-DaysBk)).replace(' ','T');
                EndDate =String.valueOf(nowDate.addDays(DaysFd)).replace(' ','T');
            }
            else {
                DateTime d = Date.Today();
                StartDate = String.valueOf(d.addDays(-DaysBk).format('dd/MM/yyyy'));
                EndDate = String.valueOf(d.addDays(DaysFd).format('dd/MM/yyyy'));
            }
        }


    }

    /**
    * Class helper for creating and populating Json request for Cellcom/Bezeq technician visit callout
    * Gili Yehuda
    * taskid PLR-79
    * @class CellcomBezeqTechnicianVisitRequest
    * @module 360
    */
    /*public class CellcomBezeqTechnicianVisitRequest{
        public Map<String, Object> Header;
        public CellcomBezeqBodyBuilder Body;
    }

    public class CellcomBezeqBodyBuilder{
        public CellcomBezeqRequestBuilder Request;
    }

    public class CellcomBezeqRequestBuilder{
        public CellcomBezeqCustInfoBuilder CustInfo;
        public CellcomBezeqServiceInfoBuilder ServiceInfo;
    }

    public class CellcomBezeqCustInfoBuilder{
        public PsIdsBuilder PsIds;
        public BanIdsBuilder BanIds;
    }

    public class CellcomBezeqServiceInfoBuilder{
        public StatusesDatesInfoBuilder StatusesDatesInfo;
    }*/


    /**
    * Class helper for creating and populating Json request for OpenCloseCases callout
    * Elad Iflah
    * taskid PLR-645
    * @class OpenCloseCasesReq
    * @module 360
    */

    public class OpenCloseCasesRequest extends IndicatorsRequestBuilder {

        public String Status;
        public String FromDate_open;
        public String ToDate_open;
        public String FromDate_closed;
        public String ToDate_closed;

        public OpenCloseCasesRequest(String status) {

            this.Status = status;

            DateTime d = Date.Today();
            //String toDateNow = d.format('yyyyMMddhhmmss');
            String toDateNow = String.valueOf(d.addDays(1).format('yyyyMMddhhmmss'));
            Integer openDaysBk = Integer.valueOf(CustomMetadataTypeService.getCrmVariable('OpenCaseDaysBack'));
            Integer closeDaysBk = Integer.valueOf(CustomMetadataTypeService.getCrmVariable('CloseCaseDaysBack'));

            FromDate_open = String.valueOf(d.addDays(-openDaysBk).format('yyyyMMddhhmmss'));
            ToDate_open = toDateNow;
            FromDate_closed = String.valueOf(d.addDays(-closeDaysBk).format('yyyyMMddhhmmss'));
            ToDate_closed = toDateNow;

        }
    }


    /*public class OpenCloseCasesReq{
        public Map<String, Object> Header;
        public OpenCloseCasesBodyBuilder Body;
    }

    public class OpenCloseCasesBodyBuilder {
        public OpenCloseCasesRequestBuilder Request;
    }

    public class OpenCloseCasesRequestBuilder {
        public CustInfoBuilder CustInfo;
        public String Status;
        public String FromDate_open;
        public String ToDate_open;
        public String FromDate_closed;
        public String ToDate_closed;
    }
    */


    /**
    * Class helper for creating and populating Json response for OpenCloseCases callout
    * Elad Iflah
    * taskid PLR-645
    * @class openCloseCasesResponse
    * @module 360
    */

    public class osbCasesResponse {
        public casesRespBody Body;
        public casesRespHeader Header;
        public String errorCode;    //INVOKE-200
        public String error;    //OK
    }

    public class casesRespBody {
        public openCloseCasesResponse Response;
    }

    public class openCloseCasesResponse {
        public closeCases Close;
        public openCases Open;
    }

    public class closeCases {
        public caseDetails[] CaseDetails;
    }

    public class caseDetails {
        public String fuCode;   //0056
        public String descriprion;  //סגירת חיוג חו"ל נכשל
        public String creationDate; //20170102201223
        public String subscriberNumber; //0522499229
        public String assignedTo;  //@@
        public String taskNumber;   //88795839
        public String ban;  //221691774
        public String psid;  //221691774
        public String dueDate;  //18-SEP-16
        public String sourceSystem; //Cellcom
        public String businessUnit;
        public String creditTotalAmt;
        public String creditName;
        public String billCycle;
        public String openedBy;
        public String closedBy;
        public String fuText;
        public String assignedToTeam;
        public String status; 
        public String statusReason;   
    }

    public class openCases {
        public caseDetails[] CaseDetails;
    }

    public class casesRespHeader {
        public cls_NextTryIndex NextTryIndex;
        public String FunctionCode; //00648
        public cls_UseInvokerActivityIDInd UseInvokerActivityIDInd;
        public cls_InvokerActivityID InvokerActivityID;
        public String ActivityID;   //e3fa0f49-a17e-4745-9d9b-32302b18d42e
        public String InterchangeID;    //43cffacc-b462-4e3a-bb6f-d7a8473560f4
        public cls_OptionalReturnAddress OptionalReturnAddress;
        public String UserName; //SKLEIN
        public String ReturnCodeMessage;    //הצלחה
        public String ReturnCode;   //00
        public cls_ActionID ActionID;
        public String MessageID;    //a33d15ae-64fb-493e-a969-1b792bb92efc
        public String ProcessID;    //7b51932c-1d6e-4a61-b032-31ab7051a90c
        public String To;   //SF
        //public String From;   //OSB
    }

    public class cls_NextTryIndex {
    }

    public class cls_UseInvokerActivityIDInd {
    }

    public class cls_InvokerActivityID {
    }

    public class cls_OptionalReturnAddress {
    }

    public class cls_ActionID {
    }

    public class casesFlatResponse{
        public List<flatCaseDetails> caseList;
    }

    public class flatCaseDetails{
        public string status;
        public string displayStatus;
        public String fuCode;   //0056
        public String descriprion;  //סגירת חיוג חו"ל נכשל
        public String creationDate; //20170102201223
        public String subscriberNumber; //0522499229
        public String assignedTo;  //@@
        public String taskNumber;   //88795839
        public String ban;  //221691774
        public String psid;  //221691774
        public DateTime dueDate;  //18-SEP-16
        public String sourceSystem; //Cellcom
        public String displaySourceSys;
        public String businessUnit;
        public String creditTotalAmt;
        public String creditName;
        public String billCycle;
        public String openedBy;
        public String closedBy;
        public String fuText;
        public String assignedToTeam;       
        public String statusReason;   
    }

    /* END taskid PLR-645 */

    /**
    * Class helper for creating and populating Json response for OpenCloseCases callout
    * Elad Iflah
    * taskid PLR-874
    * @class GeneralIndicatorsRequestBuilder - good for general request with record type field only
    * @module 360
    */

    public class GeneralIndicatorsRequestBuilder extends IndicatorsRequestBuilder {
        public serviceInfoBuilder ServiceInfo;
        public GeneralIndicatorsRequestBuilder(String AccountRecordType) {
            this.ServiceInfo = new serviceInfoBuilder(AccountRecordType);
        }
    }

    public class serviceInfoBuilder {
        public String RecordType;
        public serviceInfoBuilder(String AccountRecordType) {
            RecordType = AccountRecordType.left(1);
        }
    }

    /* END taskid PLR-874 */


    public class AccessibilityFirstIndicatorsCustInfoBuilder extends CustomerInfoBuilder {
        public String RecordType;
        public AccessibilityFirstIndicatorsCustInfoBuilder(String recordType){
            super();
            this.RecordType = recordType.left(1);
        }
    }

    /**
    * Class helper for creating and populating Json response for Customer Story callout
    * Gili Yehuda\Ilana Brodsky
    * taskid PLR-1045
    * @class CustomerStoryRequestBuilder - good for general request with record type field and custom metadata
    * @module 360
    */

    public class CustomerStoryRequestBuilder extends IndicatorsRequestBuilder {
        public CustomerStoryServiceInfoBuilder ServiceInfo;
        public CustomerStoryRequestBuilder(String AccountRecordType, String month) {
            this.ServiceInfo = new CustomerStoryServiceInfoBuilder(AccountRecordType, month);
        }
    }

    public class CustomerStoryServiceInfoBuilder {
        public String RecordType;
        public String Months;
        public CustomerStoryServiceInfoBuilder(String AccountRecordType,String month) {
            RecordType = AccountRecordType.left(1);
            Months=month;
        }
    }

    /**
    * Class helper for creating and populating Json response for B2C Get Recommendations callout
    * Elad Iflah
    * taskid PLR-1038
    * @class RecommendationsBuilder
    * @module 360
    */
    public class RecommendationsBuilder extends IndicatorsRequestBuilder{

        public RecommendationsCls Recommendations;

        public RecommendationsBuilder(String UserName, String DealerCode, String Direction, String TreatCount, String Product)
        {
            this.Recommendations = new RecommendationsCls(UserName, DealerCode, Direction, TreatCount, Product);
        }
    }

    public class RecommendationsCls{

        public String userName; //DORONKE
        public String dealerCode;   //
        public String direction;    //INBOUND
        public InboundCls inbound;

        public RecommendationsCls(String UserName, String DealerCode, String Direction, String TreatCount, String Product)
        {
            this.userName = UserName;
            this.dealerCode = DealerCode;
            this.direction = Direction;
            this.inbound = new InboundCls(TreatCount, Product);
        }
    }

    public class InboundCls {

        public String treat_count;  //3
        public String product;  //TVPOLM

        public InboundCls(String TreatCount, String Product){
            this.treat_count = TreatCount;
            this.product = Product;
        }
    }
	
	/**
    * Class helper for creating and populating Json request for Personal Folder callout
    * Gili Yehuda
    * taskid PLR-1402
    * @class PersonalFolder
    * @module 360
    */
    public class PersonalFolder extends OSBCalloutBuilder.RequestBuilder{
        public PersonalFolderServiceInfoBuilder ServiceInfo;
         public PersonalFolder(String UserId, Integer daysBack) {
            ServiceInfo = new PersonalFolderServiceInfoBuilder(UserId, daysBack);
         }
    }
    
     public class PersonalFolderServiceInfoBuilder {
        public String UserID;
        public String FromDate;
        public String ToDate;

        public PersonalFolderServiceInfoBuilder(String user, Integer daysBack) {
        	system.debug('useruser:' + user);
        	//Integer DaysBack = Integer.valueOf(CustomMetadataTypeService.getCrmVariable('PersonlFolderDaysBack'));
            DateTime d = Date.Today();
            FromDate = String.valueOf(d.addDays(-daysBack).format('yyyyMMdd'));
			ToDate = d.format('yyyyMMdd');
            UserID=user;
			//FromDate='20160801';
			//ToDate='20160802';
        }
    }
}