/**********************************************************************************
* @author       Francisco Pérez - franciscojose.perez@salesforce.com
* @date         16/06/2020
* @group        Test
* @description  Tests for trigger CESS_IntegrationEventTrigger
* @revision
**********************************************************************************/
@isTest
private class CESS_IntegrationEventTrigger_Test {
	/**
     * @description
     */   
	@testSetup
	private static void setup() {

	} 

	/**
     * @description
     */   
	@isTest
	private static void test() {
		Test.startTest();

		EventBus.publish(new CESS_Integration_Event__e(
			System__c = 'Test',
			Data__c = '{"error": false}',
			Times_Retried__c = 1,
			Handler__c = 'CESS_IntegrationEventLogicTest'
        ));

		Test.stopTest();
	}
}