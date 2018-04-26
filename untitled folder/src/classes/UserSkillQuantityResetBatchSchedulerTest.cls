/**
*   Test class for UserSkillQuantityResetBatchScheduler process
*   Author Mohammad Garrah
*   taskid PLR-1018
*   @class UserSkillQuantityResetBatchSchedulerTest
*   @module Contact
*/
@isTest
private class UserSkillQuantityResetBatchSchedulerTest {

    /**
    *   Method for setup test data
    *   Author Mohammad Garrah
    *   @method setupTestData
    *   @return void
    */
    @testSetup 
    static void setupTestData(){
    	
    	User u = TestFactory.testCreateUser();
        
        list<UserSkill__c> lst_userSkills = new list<UserSkill__c>();
        lst_userSkills.add(TestFactory.testCreateUserSkill(u.Id,10,10,Datetime.now().addMinutes(-70)));//hourly Reset = yes
        lst_userSkills.add(TestFactory.testCreateUserSkill(u.Id,10,10,Datetime.now().addMinutes(-70)));//hourly Reset = yes
        lst_userSkills.add(TestFactory.testCreateUserSkill(u.Id,10,10,Datetime.now().addMinutes(-30)));//hourly Reset = no
        insert lst_userSkills;
    }
    
    /**
    * Method tests UserSkillQuantityResetBatchScheduler class
    * Author Mohammad Garrah
    * @method hourlyResetQuantityTest	
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void hourlyResetQuantityTest() {
        
        Test.StartTest();
        
        //cover the scheduler and the batch code
        UserSkillQuantityResetBatchScheduler qResetBatchSchedule = new UserSkillQuantityResetBatchScheduler('Hourly');
		String sch = '0 0 23 * * ?';
		system.schedule('Test quantity reset', sch, qResetBatchSchedule);
        
        //test the hourly batch logic
        ID batchprocessid = Database.executeBatch(qResetBatchSchedule);
        
        Test.StopTest();
        
        list<UserSkill__c> lst_userSkills = [select id, QuantityUtilizedPerHour__c from UserSkill__c where QuantityUtilizedPerHour__c = 0];
        system.assertEquals(2 , lst_userSkills.size());
    }
    
    /**
    * Method tests UserSkillQuantityResetBatchScheduler class
    * Author Mohammad Garrah
    * @method dailyResetQuantityTest	
    * @return {Void}*     
    * @module Lead
    */
    static testMethod void dailyResetQuantityTest() {
        
        Test.StartTest();
        
        //test the daily batch logic
        UserSkillQuantityResetBatchScheduler qResetBatchSchedule = new UserSkillQuantityResetBatchScheduler('Daily');
        ID batchprocessid = Database.executeBatch(qResetBatchSchedule);
        
        Test.StopTest();
        
        list<UserSkill__c> lst_userSkills = [select id, QuantityUtilized__c, QuantityUtilizedPerHour__c from UserSkill__c where QuantityUtilizedPerHour__c = 0 and QuantityUtilized__c = 0];
        system.assertEquals(3 , lst_userSkills.size());
    }
}