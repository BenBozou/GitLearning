/*
*   @class LeadConsoleSideBarController - controller for VF_LeadconsoleSideBar
*   author Elad Kaplan
*   @module {Console}
*   @constructor
*/
public with sharing class LeadConsoleSideBarController {
    
    public list<Task> relatedTasks {get; private set;}
    
    public LeadConsoleSideBarController(ApexPages.StandardController controller) {
        
        if(controller.getId() != null)    
            relatedTasks = [Select ActivityDate, WhoId , Product__r.Name  , Description ,tolabel(LeadSubStatus__c),
                 type, tolabel(LeadStatus__c), Id ,owner.name From Task where whoid =: controller.getId() order by createdDate desc];
    }
    
    public Boolean isLanguageRTL {
        get {
            Set < String > rtlLang = new Set < String > {
                'iw', 'ar','ur'
            };
            String language = UserInfo.getLanguage();
            return rtlLang.contains(language);
        }
        private set;
    }
}