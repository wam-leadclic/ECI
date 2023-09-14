/**********************************************************************************
* @author       
* @date         
* @group        Test
* @description  Test class to test the CEES_GetTelephonyTaskInvocable class
* @revision
**********************************************************************************/
@isTest
public class CEES_GetTelephonyTaskInvocableTest {

    @isTest
    static void test_getTask() {
        Task task = new Task(
            subject = 'Test'
        );

        insert task;

        Test.startTest();

        CEES_GetTelephonyTaskInvocable.GetTaskRequest request = new CEES_GetTelephonyTaskInvocable.GetTaskRequest();
        request.ownerid = UserInfo.getUserId();
        List <CEES_GetTelephonyTaskInvocable.GetTaskRequest> requests= new List <CEES_GetTelephonyTaskInvocable.GetTaskRequest>();
        requests.add(request);
        List <CEES_GetTelephonyTaskInvocable.GetTaskResult> result=CEES_GetTelephonyTaskInvocable.getTaskId (requests);
        
        Test.stopTest();

        System.assert( result != null );
        System.assertEquals( 1, result.size() );
    
    }
    
}