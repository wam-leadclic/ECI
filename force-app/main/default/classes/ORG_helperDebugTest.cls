/**********************************************************************************
* @name         	ORG_helperDebugTest
* @version			1.0
* @author           María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @creation date    16/11/2020
* @description  	Apex Class with the test for ORG_helperDebug
* @group        	Test
**********************************************************************************/
@isTest
public class ORG_helperDebugTest {
    
    /**********************************************************************************
    * @author           María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    16/11/2020
    * @description  	Test getException
    **********************************************************************************/
    @isTest
    static void testGetException() {
      
        DmlException exc = new DmlException();
        exc.setMessage('message');
        Test.startTest();
        String msg = ORG_helperDebug.getException('nameClass', 'nameMethod', exc);
        Test.stopTest();
        System.assertNotEquals(null, msg);
    }

}