/**
*  Test class for testing VlocityAuthRegistrationHandler
*  @class VlocityAuthRegistrationHandlerTest
*  Mohammad Garrah
*  @module infrastructure
*/
@isTest
private class VlocityAuthRegistrationHandlerTest {

     /**
	  *  method for testing VlocityAuthRegistrationHandler
	  *  Mohammad Garrah
	  *  @method  testCreateAndUpdateUser
	  *  @return  void  
	  */
    static testMethod void testCreateAndUpdateUser() {
	    VlocityAuthRegistrationHandler handler = new VlocityAuthRegistrationHandler();
	    Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
	        'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
	        null, new Map<String, String>{'language' => 'en_US'});
	    User u = handler.createUser(null, sampleData);
	    System.assertEquals('testuser@example.org', u.email);
	    System.assertEquals('testLast', u.lastName);
	    System.assertEquals('testFirst', u.firstName);
	    insert(u);
	    String uid = u.id;
	    
	    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
	        'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
	        null, new Map<String, String>{});
	    handler.updateUser(uid, null, sampleData);
	    
	    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
	    System.assertEquals('testnewuser@example.org', updatedUser.email);
	    System.assertEquals('testNewLast', updatedUser.lastName);
	    System.assertEquals('testNewFirst', updatedUser.firstName);
	}
}