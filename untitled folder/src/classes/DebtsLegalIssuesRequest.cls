/**
* Class helper for creating and populating Json request for DebtsLegalIssues callout
* Gili Yehuda
* taskid PLR-137
* @class DebtsLegalIssuesRequest
* @module 360 
*/
public with sharing class DebtsLegalIssuesRequest {
	//public HeaderInterface Header;
	public Map<String, Object> Header;
	public InterfaceBody Body;

	public class InterfaceBody {
		public InterfaceRequest Request;
	}
	 
	public class InterfaceRequest {
		public InterfaceCustInfo CustInfo;
		public String IncludeBalance;	
		public String IncludeDebt;	
		public String IncludeFutureCheques;	
		public String IncludeLastInvoice;	
		public String IncludeLegalInfo;	
		public String IncludeCollectionInfo;	
	}
	
	public class InterfaceCustInfo {
		public String Ssn;	
		public String ContactIdentifier ;	
		public String AccountIdentifier ;	
		public InterfacePsIds PsIds;
		public InterfaceBanIds BanIds;
	}
	
	public class InterfacePsIds {
		public String [] PsId;
	}
	
	public class InterfaceBanIds {
		public String [] BanId;
	}
	
}