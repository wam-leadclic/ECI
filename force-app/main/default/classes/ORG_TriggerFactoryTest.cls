/**********************************************************************************
* @author       Giovanni Modica - giovanni.modica@salesforce.com
* @date         22/05/2018
* @group        Test
* @description  Test for the ORG_TriggerFactory class
* @Revision
**********************************************************************************/
@isTest
private class ORG_TriggerFactoryTest {
	/**
     * @description Test setup
     */    
	@testSetup
    private static void setup() {
        
    }
    
	/**
     * @description 
     */    
    @isTest
    private static void testForNonExistentTriggerHandler() {
        Test.startTest();

		Boolean errorProduced = false;
		String errorMessage = null;        
        try {
            ORG_TriggerFactory.createAndExecuteHandler(ORG_TriggerFactoryTest.class);
        }
        catch(ORG_TriggerFactory.ORG_TriggerFactoryException e) {
            errorProduced = true;
            errorMessage = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assertEquals(true, errorProduced);
        System.assertEquals('No Trigger Handler found named: ORG_TriggerFactoryTest', errorMessage);
    } 
    
	/**
     * @description 
     */    
    @isTest
    private static void testTriggerMethods() {
        Lead l = ORG_TestDataUtils.getInstance().newLead('Test');

        Test.startTest();

        insert l;
        update l;
        delete l;
        undelete l;
        
        Test.stopTest();
    }    
}