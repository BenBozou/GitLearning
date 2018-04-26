/**
* Class helper for creating and populating Json request for DeviceInRepair / CustomerDelivery callout
* Gili Yehuda
* taskid PLR-75 | PLR-132
* @class DeviceInRepairCustomerDeliveryRequest
* @module 360 
*/
public with sharing class DeviceInRepairCustomerDeliveryRequest {
	
	public Map<String, Object> Header;
	public InterfaceBody Body;
	
	public class InterfaceBody {
		public InterfaceRequest Request;
	}  
	
	public class InterfaceRequest {
		public InterfaceCustInfo CustInfo;
		public InterfaceServiceInfo ServiceInfo;
	}
	
	public class InterfaceCustInfo {
		public InterfaceBanIds BanIds;
	}
	
	public class InterfaceBanIds {
		public String[] BanId;
	}
	
	public class InterfaceServiceInfo {
		public InterfaceStatusesDatesInfo StatusesDatesInfo;
	}
	
	public class InterfaceStatusesDatesInfo {
		public list<InterfaceStatusDateInfo> StatusDateInfo;
	}
	
	public class InterfaceStatusDateInfo {
		public String Status;	//string
		public String StartDate;	//string
		public String EndDate;	//string
		
		public InterfaceStatusDateInfo(String Stat, String StartDt, String EndDt){
			Status = Stat;
			StartDate= StartDt;
			EndDate =EndDt;
		}
	}
}