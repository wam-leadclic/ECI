/**
 * @name: ORG_scheduledDeactivateUserTest
 * @version: 1
 * @creation date: 27/02/2020
 * @autor: Ramón García Sánchez
 * @description: Test class made to check ORG_scheduledDeactivateUser/ORG_batchDeactivateUser class.
 * 
*/
@isTest
public class ORG_scheduledDeactivateUserTest {
    
    @testSetup
    private static void setup() {
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        List<User> users = new List<User>();
        User user1 = orgDataUtils.standardUserES();
        User user2 = orgDataUtils.adminUserES();
        User user3 = orgDataUtils.dataStageUserES();
        users.add(user1);
        users.add(user2);
        users.add(user3);
        
        insert users;
    }
    
    
    @isTest static void afterInsert() {
        ORG_scheduledDeactivateUser bd = new ORG_scheduledDeactivateUser();
        Test.startTest();
        	Datetime dt = Datetime.now();
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            System.schedule('ORG_scheduledDeactivateUserTest',CRON_EXP,bd);
        Test.stopTest();
    }
}