/**********************************************************************************
* @author       Giovanni Modica - gmodica@salesforce.com
* @date         01/08/2018
* @group        Test
* @description  Tests for class ORG_IntegrationLogLogic
* @revision
**********************************************************************************/
@isTest
public class ORG_IntegrationLogLogicTest {
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
	private static void testCreate() {
		Test.startTest();

		IntegrationLog__c log = ORG_IntegrationLogLogic.createIntegrationLog('00001', '', '', 'Error', 0, null, new Map<String,Object> { 'system__c' => 'Test'});

		Test.stopTest();

		System.assertEquals('Test', log.system__c);
	}

	/**
     * @description
     */ 
	@isTest
	private static void testInsert() {
		IntegrationLog__c log = ORG_IntegrationLogLogic.createIntegrationLog('00001', '', '', 'Error', 0, null, new Map<String,Object> { 'system__c' => 'Test'});

		Test.startTest();

		List<IntegrationLog__c> logs = ORG_IntegrationLogLogic.insertLogs(new List<IntegrationLog__c> { log });

		Test.stopTest();

		log = logs[0];

		System.assertNotEquals(null, log.Id);
	}

	/**
     * @description
     */ 
	@isTest
	private static void testDelete() {
		IntegrationLog__c log = ORG_IntegrationLogLogic.createIntegrationLog('00001', '', '', 'Error', 0, null, new Map<String,Object> { 'system__c' => 'Test'});
		List<IntegrationLog__c> logs = ORG_IntegrationLogLogic.insertLogs(new List<IntegrationLog__c> { log });

		System.assertEquals(1, [select count() from IntegrationLog__c where identifier__c = '00001']);

		Test.startTest();

		ORG_IntegrationLogLogic.deleteLogsForIdentifier(new Set<String> { '00001' });

		Test.stopTest();

		System.assertEquals(0, [select count() from IntegrationLog__c where identifier__c = '00001']);
	}

	/**
     * @description
     */ 
	@isTest
	private static void testPushTopic() {
		Test.startTest();

		PushTopic topic = ORG_IntegrationLogLogic.getPushTopic();

		Test.stopTest();

		System.assertNotEquals(null, topic);
		System.assertEquals(ORG_IntegrationLogLogic.PUSH_TOPIC_NAME + 'Test', topic.Name);
		System.assertEquals(topic, ORG_IntegrationLogLogic.topic);
	}

	/**
     * @description
     */ 
	@isTest
	private static void testPushTopicFromCache() {
		PushTopic topic = ORG_IntegrationLogLogic.getPushTopic();

		Test.startTest();

		PushTopic topicFromCache = ORG_IntegrationLogLogic.getPushTopic();

		Test.stopTest();

		System.assertEquals(topic, topicFromCache);
	}

	/**
     * @description
     */ 
	@isTest
	private static void testGetLogsWithIdentifier() {
		IntegrationLog__c log = ORG_IntegrationLogLogic.createIntegrationLog('00001', '', '', 'Error', 0, null, new Map<String,Object> { 'system__c' => 'Test'});
		List<IntegrationLog__c> logs = ORG_IntegrationLogLogic.insertLogs(new List<IntegrationLog__c> { log });

		System.assertEquals(1, [select count() from IntegrationLog__c where identifier__c = '00001']);

		Test.startTest();

		logs = ORG_IntegrationLogLogic.getIntegrationLogsForIdentifier(new Set<String> { '00001' });

		Test.stopTest();

		System.assertEquals(1, logs.size());
	}

	/**
     * @description
     */ 
	@isTest
	private static void testResolve() {
		IntegrationLog__c log = ORG_IntegrationLogLogic.createIntegrationLog('00001', '', '', 'Error', 0, 'ORG_IntegrationLogLogicTest.LogSolver', new Map<String,Object> { 'system__c' => 'Test'});
		List<IntegrationLog__c> logs = ORG_IntegrationLogLogic.insertLogs(new List<IntegrationLog__c> { log });

		System.assertEquals(1, [select count() from IntegrationLog__c where identifier__c = '00001']);

		Test.startTest();

		ORG_IntegrationLogLogic.resolveIntegrationLogsForIdentifier(new Set<String> { '00001' });

		Test.stopTest();
	}

	/**
	* @description 
	*/
	public class LogSolver implements ORG_IIntegrationLogSolver {
		/**
		* @description 
		*/
		public Boolean solveLog(String identifier, String data, String externalSystem) {
			
			return true;
		}
	}
}