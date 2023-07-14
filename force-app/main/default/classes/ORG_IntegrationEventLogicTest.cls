/**********************************************************************************
* @author       Giovanni Modica - gmodica@salesforce.com
* @date         06/08/2018
* @group        Test
* @description  Tests for class ORG_IntegrationEventLogic
* @revision
**********************************************************************************/
@isTest
public class ORG_IntegrationEventLogicTest implements ORG_IIntegrationHandler {
	public static String setting = '[{"s": "Test","c": "ORG_IntegrationEventLogicTest","a": true, "async": true}]';

	/**
     * @description
     */   
	@testSetup
	private static void setup() {
		insert new Lead(LastName = 'Test',source_manualrecord__c='Otros',MobilePhone='632333232');
	} 

	/**
	* @description 
	*/
	public void handleEvent(ORG_Integration_Event__e event) {
		Data data = String.isNotBlank(event.Data__c) ? (Data)JSON.deserialize(event.Data__c, Data.class) : null;

		if(data.error) throw new ORG_IntegrationEventLogic.ORG_IntegrationEventException('Test');
	}

	/**
	* @description 
	*/
	public Map<String,Object> getLogValues(ORG_Integration_Event__e event) {
		return new Map<String,Object>();
	}

	/**
     * @description
     */   
	@isTest
	private static void testSolve() {
		Lead l = [select Id from Lead];

		Test.startTest();

		new ORG_IntegrationEventLogic().solveLog(l.Id,SObjectType.Lead.name + ',' + l.Id + ',' + 'update','Test');

		Test.stopTest();
	}

	/**
     * @description
     */   
	@isTest
	private static void testHandleEvents() {
		ORG_Integration_Event__e event = new ORG_Integration_Event__e(
			System__c = 'Test',
			Data__c = '{"error": false}',
			Times_Retried__c = 0
        );

		Test.startTest();

		ORG_IntegrationEventLogic.handleEvents(new List<ORG_Integration_Event__e> { event });

		Test.stopTest();
	}

	/**
     * @description
     */   
	@isTest
	private static void testHandleEventsRetried() {
		ORG_Integration_Event__e event = new ORG_Integration_Event__e(
			System__c = 'Test',
			Data__c = '{"error": false}',
			Times_Retried__c = 1
        );

		Test.startTest();

		String errorMessage = null;
		try {
			ORG_IntegrationEventLogic.handleEvents(new List<ORG_Integration_Event__e> { event });
		}
		catch(Exception e) {
			errorMessage = e.getMessage();
		}

		Test.stopTest();

		System.assertNotEquals(null, errorMessage);
	}	

	/**
     * @description
     */   
	@isTest
	private static void testHandleEventsRetriedMax() {
		ORG_Integration_Event__e event = new ORG_Integration_Event__e(
			System__c = 'Test',
			Data__c = '{"error": false}',
			Times_Retried__c = ORG_IntegrationEventLogic.getMaxRetries() + 1,
			Handler__c = 'ORG_IntegrationEventLogicTest'
        );

		Test.startTest();

		ORG_IntegrationEventLogic.handleEvents(new List<ORG_Integration_Event__e> { event });

		Test.stopTest();
	}	

	/**
     * @description
     */   
	@isTest
	private static void testHandleEventsRetriedMaxWithError() {
		ORG_Integration_Event__e event = new ORG_Integration_Event__e(
			System__c = 'Test',
			Data__c = '{"error": true}',
			Times_Retried__c = ORG_IntegrationEventLogic.getMaxRetries() + 1
        );

		Test.startTest();

		ORG_IntegrationEventLogic.handleEvents(new List<ORG_Integration_Event__e> { event });

		Test.stopTest();

		System.assertEquals(1, [select count() from IntegrationLog__c]);
	}			

	/**
     * @description
     */   
	@isTest
	private static void testHandleEventsWithHandler() {
		ORG_Integration_Event__e event = new ORG_Integration_Event__e(
			System__c = 'Test',
			Data__c = '{"error": false}',
			Times_Retried__c = 0,
			Handler__c = 'ORG_IntegrationEventLogicTest'
        );

		Test.startTest();

		ORG_IntegrationEventLogic.handleEvents(new List<ORG_Integration_Event__e> { event });

		Test.stopTest();
	}	

	/**
     * @description
     */   
	@isTest
	private static void testHandleEventsWithError() {
		ORG_Integration_Event__e event = new ORG_Integration_Event__e(
			System__c = 'Test',
			Data__c = '{"error": true}',
			Times_Retried__c = 0
        );

		Test.startTest();

		ORG_IntegrationEventLogic.handleEvents(new List<ORG_Integration_Event__e> { event });

		Test.stopTest();
	}	

	/**
     * @description
     */   
	@isTest
	private static void testHandleEventsWithErrorSync() {
		setting = '[{"s": "Test","c": "ORG_IntegrationEventLogicTest","a": true, "async": false}]';

		ORG_Integration_Event__e event = new ORG_Integration_Event__e(
			System__c = 'Test',
			Data__c = '{"error": true}',
			Times_Retried__c = 0
        );

		Test.startTest();

		ORG_IntegrationEventLogic.handleEvents(new List<ORG_Integration_Event__e> { event });

		Test.stopTest();
	}		

	//-- INNER CLASSES
	/**
	* @description 
	*/
	public class Data {
		public Boolean error {get; set;}
	}	
}