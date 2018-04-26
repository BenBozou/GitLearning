/**
*   Post script for running after sandbox creation
*   
*   @class SandBoxPostCreation
*   author Liron Cohen
*   
*	When refreshing sandbox or creating new sandbox, should select this
*	class in salesforce window.
*/
global class SandBoxPostCreation implements SandBoxPostCopy{
	
	/**
    *   main script that will be run after sandbox creation
    *   author Liron Cohen
    *   taskId PLR-639
    *
    *   @method runApexClass
    *	@param	{SandboxContext} 	context
    *
    */
	global void runApexClass(SandboxContext context) {
		
		//Update custom setting which indicate the environment end point
		changeEnvironmentSetup(context.sandboxName());
    }
    
    
    /**
    *   Update custom setting which indicate the environment end point
    *   author Liron Cohen
    *   taskId PLR-639
    *
    *   @method changeEnvironmentSetup
    *	@param	{SString} 	sandboxName
    */
    private void changeEnvironmentSetup(String sandboxName){
    	//Setup the indication for the relevant environment - Dev/INT
		EnvironmentSettings__c environmentSettings = EnvironmentSettings__c.getOrgDefaults();
		
		if(environmentSettings != null){
			
			//Clear the value at first. If the process won't find matching value it will be updated to null, and should be setup manually
			environmentSettings.CurrentEnvironment__c = '';
			
			map<String, SandBoxType__c> sandBoxTypeMap = SandBoxType__c.getAll();
			
			if (! sandBoxTypeMap.isEmpty()){
				//loop over all custom setting. Check if have setup that the sandbox name starts with
				for(SandBoxType__c sandboxType : sandBoxTypeMap.values()){
					if(sandboxName.toLowerCase().startsWith(sandboxType.Name.toLowerCase())){
						environmentSettings.CurrentEnvironment__c = sandboxType.CurrentEnvironment__c;
					}
				}
			}	
			
			update environmentSettings;
		}
    }
}