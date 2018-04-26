/**
*   Test class for UpdateUserCSRController
*   
*   @class UpdateUserCSRControllerTest
*   author Liron Cohen
*   @module 360
*/
@isTest
private class UpdateUserCSRControllerTest{

    static testMethod void testUpdateUserCSR(){
    
        UpdateUserCSRController controller = new UpdateUserCSRController();
        
        controller.findUser();
        
        controller.userIdByName = UserInfo.getUserId();
        controller.findUser();
        
        controller.updateUser();
            
    
    }
}