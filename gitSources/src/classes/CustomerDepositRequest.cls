/**
* Class helper for creating and populating Json request for Customer Deposit callout
* Gili Yehuda
* taskid PLR-310
* @class CustomerDepositRequest
* @module 360 
*/
public with sharing class CustomerDepositRequest {
	//public HeaderInterface Header;
	public Map<String, Object> Header;
	public InterfaceBody Body;

	public class InterfaceBody {
		public InterfaceRequest Request;
	}
	 
	public class InterfaceRequest {
		public InterfaceCustInfo CustInfo;
	}
	
	public class InterfaceCustInfo {
		public String IdentificationValue;	
		public String IdentificationType ;	
	}
}