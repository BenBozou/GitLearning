@isTest
private class Template_DeactivateController_Test {

    static testMethod void controllerTest() {
        
        vlocity_cmt__VlocityUITemplate__c testTemplate = new vlocity_cmt__VlocityUITemplate__c(Name = 'test template', 
                                                         vlocity_cmt__Active__c = true);
                          
        vlocity_cmt__VlocityUILayout__c testLayout = new vlocity_cmt__VlocityUILayout__c(Name = 'test layout', 
                                                         vlocity_cmt__Active__c = true);
                                                          
        list<SObject> testObj_List = new list<SObject>{testTemplate, testLayout};
        insert testObj_List;                                               
                                                         
        Test.StartTest();
        Template_DeactivateController controller = new Template_DeactivateController();
        controller.getItems();
        controller.templates_List[0].vlocity_cmt__Active__c = true;
        controller.templatesTextArea = testTemplate.Name;
        controller.selectedComponent = 'Templates';
        controller.changeLists(); 
        controller.dactivateTemplates();
        
        Template_DeactivateController controller2 = new Template_DeactivateController();
        controller2.layouts_List[0].vlocity_cmt__Active__c = true;
        controller2.selectedComponent = 'Layouts';
        controller2.templatesTextArea = testLayout.Name;
        controller2.dactivateTemplates();
        controller2.templatesTextArea = '';
        controller2.dactivateTemplates();
        Test.StopTest();
        
        
    }
}