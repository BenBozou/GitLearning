/**
*  Class to override Partner Standard Account
*  Kennedy Nyaga
*
*  Please use code style for project !!!
*/

public class PartnerOverrideAccount {
	//Store the passed Standard Controller
	ApexPages.StandardController stdCtrl;

	public PartnerOverrideAccount(ApexPages.StandardController controller) {
		stdCtrl = controller;
	}

	public PageReference redirect() {
		Account inputAccount = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Account WHERE Id=:stdCtrl.getId()];
		
		Map<String,String> rParams = ApexPages.currentPage().getParameters();
		PageReference result  = stdCtrl.view();
		if (Network.getNetworkId() != null && inputAccount.RecordTypeId != null && inputAccount.RecordType.DeveloperName == 'Consumer') {
			result =  Page.VF_PartnerAccount;
			result.setRedirect(true);
		} else {
			result.setRedirect(false);
			result.getParameters().put('nooverride', '1');
		}

		for(String paramKey : rParams.keySet()) {
				result.getParameters().put(paramKey,rParams.get(paramKey));
		}
		return result;

	}

}