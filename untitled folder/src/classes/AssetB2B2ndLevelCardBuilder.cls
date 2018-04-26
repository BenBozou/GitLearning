/**
* Class helper for building Json request\response for B2B Asset 2nd level callouts
* Elad Iflah
* taskid PLR-560
* @class AssetB2B2ndLevelCardBuilder
* @module 360
*/
public with sharing class AssetB2B2ndLevelCardBuilder {
        
    /**
    * taskid PLR-1164
    * Inner class for B2B Cellular Data
    */
    public class B2BCellData2LevelRequestBuilder extends IndicatorsCalloutBuilder.IndicatorsRequestBuilder {
		public serviceInfoBuilder ServiceInfo;
		public B2BCellData2LevelRequestBuilder(String recordType, String itemName, String categoryName) {
			this.ServiceInfo = new serviceInfoBuilder(recordType, itemName, categoryName);
		}
	}

	public class serviceInfoBuilder {
		public String RecordType;
        public String ItemName;
        public String Category;
		public serviceInfoBuilder(String recordType, String itemName, String category) {
			this.RecordType = recordType.left(1);
            this.ItemName = itemName;
            this.Category = category;
		}
	}

}