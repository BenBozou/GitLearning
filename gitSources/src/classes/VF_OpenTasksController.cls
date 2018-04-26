public with sharing class VF_OpenTasksController {
	
	public PageReference redirectToPage() {
		
		return new PageReference('/apex/ConsoleCards_Preview?layout=UserOpenTasks');
	}
}