public with sharing class Template_DeactivateController {

    public list <vlocity_cmt__VlocityUITemplate__c> templates_List {get;set;}
    public list <vlocity_cmt__VlocityUILayout__c> layouts_List {get;set;}

    public String templatesTextArea {get;set;}
    public String selectedComponent{get;set;}

    public Template_DeactivateController() {

        templates_List = init();
        layouts_List = initLayouts();
        selectedComponent = 'Templates';
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Templates','Templates')); 
        options.add(new SelectOption('Layouts','Layouts'));
        return options; 
    }
                   
    public list<vlocity_cmt__VlocityUITemplate__c > init() {

        templates_List = [SELECT Id, Name, vlocity_cmt__Type__c, LastModifiedDate, vlocity_cmt__Active__c
            FROM vlocity_cmt__VlocityUITemplate__c WHERE vlocity_cmt__Active__c = true order by Name asc
        ];

        for (vlocity_cmt__VlocityUITemplate__c temp: templates_List) {

            temp.vlocity_cmt__Active__c = false;
        }  
        
        return templates_List; 
    }
    
    public list<vlocity_cmt__VlocityUILayout__c> initLayouts() {
    
    
        layouts_List = [SELECT Id, Name, vlocity_cmt__Type__c, LastModifiedDate, vlocity_cmt__Active__c
                    FROM vlocity_cmt__VlocityUILayout__c WHERE vlocity_cmt__Active__c = true order by Name asc];
        
        for (vlocity_cmt__VlocityUILayout__c layout: layouts_List) {
    
             layout.vlocity_cmt__Active__c = false;
        }   
        
        return layouts_List;
    }
    
    public PageReference changeLists() {
        
        selectedComponent = (selectedComponent == 'Templates') ? 'Templates' : 'Layouts';
        
        return null;
    }
    

    public PageReference dactivateTemplates() {

        map <Id, vlocity_cmt__VlocityUITemplate__c> templatesToUpdate_Map = new map <Id, vlocity_cmt__VlocityUITemplate__c> ();
        map <Id, vlocity_cmt__VlocityUILayout__c> layoutsToUpdate_Map = new map <Id, vlocity_cmt__VlocityUILayout__c> ();

        
        if (selectedComponent == 'Templates') {
           
            for (vlocity_cmt__VlocityUITemplate__c temp: templates_List) {
    
                if (temp.vlocity_cmt__Active__c) {
    
                    temp.vlocity_cmt__Active__c = false;
                    templatesToUpdate_Map.put(temp.Id, temp);
                }
            }
        }
        
        else {        
           
            for (vlocity_cmt__VlocityUILayout__c layout : layouts_List ) {
    
                if (layout .vlocity_cmt__Active__c) {
    
                    layout .vlocity_cmt__Active__c = false;
                    layoutsToUpdate_Map.put(layout.Id, layout);
                }
            }
        }


        if (!String.isEmpty(templatesTextArea)) {

            list <String> templates_Lst = templatesTextArea.split('\\s+');
            set <String> templates_Set = new set <String> ();
            templates_Set.addAll(templates_Lst);
            
            if (selectedComponent == 'Templates') {
                for (vlocity_cmt__VlocityUITemplate__c temp: [SELECT Id, vlocity_cmt__Active__c FROM vlocity_cmt__VlocityUITemplate__c
                        WHERE vlocity_cmt__Active__c = true and Name IN: templates_Set
                    ]) {
                    temp.vlocity_cmt__Active__c = false;
                    templatesToUpdate_Map.put(temp.Id, temp);
                }
            }
             
             else {   
                for (vlocity_cmt__VlocityUILayout__c layout : [SELECT Id, vlocity_cmt__Active__c FROM vlocity_cmt__VlocityUILayout__c
                    WHERE vlocity_cmt__Active__c = true and Name IN: templates_Set
                ]) {
                    layout.vlocity_cmt__Active__c = false;
                    layoutsToUpdate_Map.put(layout.Id, layout);
                }
             }
        }

        if (templatesToUpdate_Map.isEmpty() && layoutsToUpdate_Map.isEmpty()) {

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please choose at least 1 Active Template/Layout or paste Template/Layout names'));
            templatesTextArea = '';
            return null;
        }
            
        if (!templatesToUpdate_Map.isEmpty()) {    
            update templatesToUpdate_Map.values();
        }
        
        else if (!layoutsToUpdate_Map.isEmpty()) {  
            update layoutsToUpdate_Map.values();
        }
        templatesTextArea = '';
        templates_List = init();
        layouts_List = initLayouts();
            
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Templates/Layouts have been deactivated'));
        return null;
    }
}