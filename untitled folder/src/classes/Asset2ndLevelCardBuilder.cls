/**
* Class for building json body for Asset2ndLevelCardService
* Tal sabtai
* @class AccountCellularCardBuilder
* @module 360 
*/
  
public class Asset2ndLevelCardBuilder {
	
	public virtual class ServiceInfo{
		public String ProductId;
        public String ProductType;
	}
	
	public virtual class CustInfoWithBanAndPs{
    	public BanIdsBuilder BanIds;
    	public PsIdsBuilder PsIds;
    }
	
	/**
    * taskid PLR-988
    * Inner class for creating RequestBuilder for InfrastructureCardData
    */
	public class InfrastructureCardBuilder extends OSBCalloutBuilder.RequestBuilder {       
	    public ServiceInfoWithSubscriberIdentifier ServiceInfo;
	    public InfrastructureCustInfo CustInfo;
	        
	    public InfrastructureCardBuilder(String subscriberNo, String productType, String productId, String accountId, String contactId, String banId, String psId){
	        this.ServiceInfo = new ServiceInfoWithSubscriberIdentifier(subscriberNo, productType, productId);
	        this.CustInfo = new InfrastructureCustInfo(accountId, contactId, banId, psId);
	    }
	}
	/**
    * taskid PLR-946
    * Inner class for creating RequestBuilder for BundleCardData
    */
	public class BundleCardBuilder extends OSBCalloutBuilder.RequestBuilder {       
	    public BundleServiceInfo ServiceInfo;
	    public BundleCustInfo CustInfo;
	        
	    public BundleCardBuilder(String productId, String productType, String recordType, String bundleID, String accountId, String contactId, String banId, String psId){
	        this.ServiceInfo = new BundleServiceInfo(productId, productType, recordType, bundleID);
	        this.CustInfo = new BundleCustInfo(contactId, accountId, banId, psId);
	    }
	}
	/**
    * taskid PLR-554
    * Inner class for creating RequestBuilder for VOIPCardData
    */
	public class VOIPCardBuilder extends OSBCalloutBuilder.RequestBuilder {       
	    public ServiceInfoWithSubscriberIdentifier ServiceInfo;
	    public VOIPCustInfo CustInfo;
	        
	    public VOIPCardBuilder(String subscriberNo, String productType, String productId, String banId, String psId, string recordType){
	        this.ServiceInfo = new ServiceInfoWithSubscriberIdentifier(subscriberNo, productType, productId);
	        this.CustInfo = new VOIPCustInfo(psId, banId, recordType);
	    }
	}
	/**
    * taskid PLR-905
    * Inner class for creating RequestBuilder for ISPCardData
    */
	public class ISPCardBuilder extends OSBCalloutBuilder.RequestBuilder {       
	    public ServiceInfoWithSubscriberIdentifier ServiceInfo;
	    public ISPCustInfo CustInfo;
	        
	    public ISPCardBuilder(String subscriberNo, String productType, String productId, String banId, String psId){
	        this.ServiceInfo = new ServiceInfoWithSubscriberIdentifier(subscriberNo, productType, productId);
	        this.CustInfo = new ISPCustInfo(psId, banId);
	    }
	}
	/**
    * taskid PLR-902
    * Inner class for creating RequestBuilder for TVCardData
    */
	public class TVCardBuilder extends OSBCalloutBuilder.RequestBuilder {       
	    public ServiceInfoWithSubscriberNo ServiceInfo;
	    public TVCustInfo CustInfo;
	        
	    public TVCardBuilder(String subscriberNo, String productType, String productId, String banId){
	        this.ServiceInfo = new ServiceInfoWithSubscriberNo(subscriberNo, productType, productId);
	        this.CustInfo = new TVCustInfo(banId);
	    }
	}
	/**
    * taskid PLR-543
    * Inner class for creating RequestBuilder for CellularCardData
    */
	public class CellularCardBuilder extends OSBCalloutBuilder.RequestBuilder {       
	    public ServiceInfoWithSubscriberNo ServiceInfo;
	    public CellularCustInfo CustInfo;
	        
	    public CellularCardBuilder (String subscriberNo, String productType, String productId, String banId){
	        this.ServiceInfo = new ServiceInfoWithSubscriberNo(subscriberNo, productType, productId);
	        this.CustInfo = new CellularCustInfo(banId);
	    }
	}
	/**
    * taskid PLR-946
    * Inner class for creating ServiceInfo for BundleCardData
    */
	public class BundleServiceInfo extends ServiceInfo {
        public String BundleID;
        public String RecordType;

        public BundleServiceInfo(String productId, String productType, String recordType, String bundleID){
            this.BundleID = bundleID;
            this.RecordType = recordType;
            this.ProductType = productType;
            this.ProductId = productId;
        }
   }
   public class ServiceInfoWithSubscriberIdentifier extends ServiceInfo {
        public String SubscriberIdentifier;
        
        public ServiceInfoWithSubscriberIdentifier(String subscriberNo,String productType,String productId){
            this.SubscriberIdentifier = subscriberNo;
            this.ProductType = productType;
            this.ProductId = productId;
        }
   }
  	/**
    * taskid PLR-988
    * Inner class for creating CustInfo for InfrastructureCardData
    */
  public class InfrastructureCustInfo extends CustInfoWithBanAndPs {
		public string ContactIdentifier;
		public string AccountIdentifier;
		
		public InfrastructureCustInfo(string accountId, string contactId, string banId, string psId){
			PsIds = new PsIdsBuilder(psId);
			BanIds = new BanIdsBuilder(banId);
			this.AccountIdentifier = accountId;
			this.ContactIdentifier = contactId;
		}
   }
   	/**
    * taskid PLR-905
    * Inner class for creating CustInfo for ISPCardData
    */
   public class ISPCustInfo extends CustInfoWithBanAndPs {
   		public ISPCustInfo(String psId, String banId) {
			this.PsIds = new PsIdsBuilder(psId);
			this.BanIds = new BanIdsBuilder(banId);
		}
   }
	/**
    * taskid PLR-554
    * Inner class for creating CustInfo for VOIPCardData
    */
	public class VOIPCustInfo extends CustInfoWithBanAndPs {
		public String RecordType;
		
		public VOIPCustInfo(String psId, String banId, String recordType){
			this.PsIds = new PsIdsBuilder(psId);
			this.BanIds = new BanIdsBuilder(banId);
			this.RecordType = recordType;
		}
	}
   
   public class ServiceInfoWithSubscriberNo extends ServiceInfo {
        public String SubscriberNo;
        
        public ServiceInfoWithSubscriberNo(String subscriberNo,String productType,String productId){
            this.SubscriberNo = subscriberNo;
            this.ProductType = productType;
            this.ProductId = productId;
        }
    }
    /**
    * taskid PLR-902
    * Inner class for creating CustInfo for TVCardData
    */
    public class TVCustInfo{
		public BanIdsBuilder BanIds;
		
		public TVCustInfo(String banId) {
			this.BanIds = new BanIdsBuilder(banId);
		}
	}
	/**
    * taskid PLR-946
    * Inner class for creating CustInfo for BundleCardData
    */
	public class BundleCustInfo{
		public string ContactIdentifier;
		public string AccountIdentifier;
		public string BanId;
		public string PsId;
		
		public BundleCustInfo(String contactId, String accountId, String banId, String psId){
            this.ContactIdentifier = contactId;
            this.AccountIdentifier = accountId;
            this.BanId = banId;
            this.PsId = psId;
        }
		
	}
	/**
    * taskid PLR-543
    * Inner class for creating CustInfo for CellularCardData
    */
    public class CellularCustInfo{
        public BanIds BanIds;
        public CellularCustInfo(String banId){
            this.BanIds = new BanIds(banId);
        }
    }
   
   	public class PsIdsBuilder {
		public String[] PsId;
		
		public PsIdsBuilder(String psId) {
			this.PsId = new String[]{psId};
		}
	}
	
   public class BanIdsBuilder {
		public String [] BanId;

		public BanIdsBuilder(String banId) {
			this.BanId = new String[]{banId};
		}
	}
	
    public class BanIds{
        public String BanId;
        public BanIds(String banId){
            this.BanId = banId;
        }
    }
}