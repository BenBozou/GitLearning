public with sharing class IndicatorsCalloutBuilderNew {

	public static map<String, Object> prepareHeader(String funcCode) {
		string uName = UserInfo.getUserName().replaceAll('@.*$','');
		map<String, Object> result = new map<String, Object> {
			'From' => 'SF',
			'To' => 'OSB',
			//'UserName' => uName,
			'UserName' =>'SKLEIN',
			'FunctionCode' => funcCode
		};

		return result;
	}


	public virtual class OSBRequest {
		public Map<String, Object> Header;
		public BodyBuilder Body;
		
		public OSBRequest(String funcCode) {
			Header = prepareHeader(funcCode);
			Body = new BodyBuilder();
		}

		public OSBRequest(String funcCode, BodyBuilder bb) {
			this.Header = prepareHeader(funcCode);
			this.Body = bb;
		}

		public string serialize(){
			return JSON.serialize(this);
		}
	}

	public virtual class BodyBuilder {
		public RequestBuilder Request;
		public BodyBuilder() {
			Request = new RequestBuilder();
		}

		public void setRequestNode(RequestBuilder req) {
			Request = req;
		}

	}

	public virtual class RequestBuilder {
		public CustInfoBuilder CustInfo;
		/*public String IncludeBalance;   
		public String IncludeDebt;  
		public String IncludeFutureCheques; 
		public String IncludeLastInvoice;   
		public String IncludeLegalInfo; 
		public String IncludeCollectionInfo;*/

		public RequestBuilder() {
			CustInfo = new CustInfoBuilder(null, null);
		}

		public RequestBuilder(String[] psIds, String[] banIds) {
			CustInfo = new CustInfoBuilder(psIds, banIds);
		}

		public RequestBuilder(CustInfoBuilder cust) {
			CustInfo = cust;
		}

		public void setCustInfoNode(CustInfoBuilder CustInfo) {
			this.CustInfo = CustInfo;
		}
	}
	
	public virtual class CustInfoBuilder{
		//public String Ssn;  
		public String ContactIdentifier ;
		public String AccountIdentifier ;
		public PsIdsBuilder PsIds;
		public BanIdsBuilder BanIds;

		public CustInfoBuilder(String[] psIds, String[] banIds) {
			this.PsIds = new PsIdsBuilder(psIds);
			this.BanIds = new BanIdsBuilder(banIds);
		}
	}

	public class PsIdsBuilder {
		public String [] PsId;
		public PsIdsBuilder(String[] psIds) {
			this.PsId = psIds;
		}
	}
	
	public class BanIdsBuilder {
		public String [] BanId;
		public BanIdsBuilder(String[] banIds) {
			this.BanId = banIds;
		}
	}
/*
	IMPLEMENTATION
 */


	public class DeviceInRepairCustomerDeliveryRequest extends OSBRequest{
		public Map<String, Object> Header;
		public BodyBuilder Body;

		public DeviceInRepairCustomerDeliveryRequest (String funcCode) {
			SUPER(funcCode);
		}

	}
	
	public class RepairDeliveryCustInfoBuilder extends CustInfoBuilder{
		public String RecordType;
		
		public RepairDeliveryCustInfoBuilder(String[] psIds, String[] banIds) {
			SUPER(psIds, banIds);
		}
	}
	
	public class RepairDeliveryRequestBuilder extends RequestBuilder{
		public RepairDeliveryServiceInfoBuilder ServiceInfo;
		
		public RepairDeliveryRequestBuilder() {
			ServiceInfo = new RepairDeliveryServiceInfoBuilder();
		}
	}
	
	public class RepairDeliveryServiceInfoBuilder {
		public StatusesDatesInfoBuilder getCaseOpenInd;
    	public StatusesDatesInfoBuilder getNoteOpenInd;
    	public StatusesDatesInfoBuilder getTechVisitOpenInd;
    	public StatusesDatesInfoBuilder getDeliveryOpenInd;
    	public StatusesRequiredBuilder getLoveCellcomInd;
    	public StatusesRequiredBuilder getReturnCustomerInd;
    	public StatusesRequiredBuilder getLegalInd;
    	
    	public RepairDeliveryServiceInfoBuilder() {
			getCaseOpenInd = new StatusesDatesInfoBuilder();
			getNoteOpenInd = new StatusesDatesInfoBuilder();
			getTechVisitOpenInd = new StatusesDatesInfoBuilder();
			getDeliveryOpenInd = new StatusesDatesInfoBuilder();
			getLoveCellcomInd = new StatusesRequiredBuilder();
			getReturnCustomerInd = new StatusesRequiredBuilder();
			getLegalInd = new StatusesRequiredBuilder();
		}
	}
	
	public class StatusesRequiredBuilder {
        public String Required;
        
        public StatusesRequiredBuilder(){
            Required = 'Y';
        }
	}
	
	public class StatusesDatesInfoBuilder {
		public String StartDate;
        public String EndDate;
        public String Required;
        
        public StatusesDatesInfoBuilder(){
            /*
            DateTime nowDate = Datetime.now();   
            StartDate = String.valueOf(nowDate);
            EndDate  = String.valueOf(nowDate);
			*/
            DateTime d = Date.Today() ;
            StartDate = d.format('dd/MM/yyyy');
            EndDate = d.format('dd/MM/yyyy');
            Required = 'Y';
        }
        public void setStatusesDatesInfoBuilder(String daysBack, String daysForward){
            Integer openDaysBack = Integer.valueOf(CustomMetadataTypeService.getCrmVariable(daysBack));
	        Integer openDaysForward = Integer.valueOf(CustomMetadataTypeService.getCrmVariable(daysForward));
	        DateTime d = Date.Today();     
	        StartDate = String.valueOf(d.addDays(-openDaysBack).format('dd/MM/yyyy'));
	        EndDate = String.valueOf(d.addDays(openDaysForward).format('dd/MM/yyyy')); 
        }
	}
    

}