public without sharing class ORG_IntegrationLogLogic {
	// -- CONSTANTS

	/* @description  */
	public static final String PUSH_TOPIC_NAME = 'IntegrationLog';

	/**
	* @description 
	*/
	public static void deleteLogsForIdentifier(Set<String> identifiers) {
		delete [select Id from IntegrationLog__c where identifier__c in :identifiers];
	}

	/**
	* @description 
	*/
	public static IntegrationLog__c createIntegrationLog(String recordIdentifier, String data, String externalSystem, String error, Integer retries, String handlerClass, Map<String,Object> fieldValues) {
		IntegrationLog__c log = new IntegrationLog__c(
			error__c = error,
			retries__c = retries,
			identifier__c = recordIdentifier,
			data__c = data,
			system__c = externalSystem,
			handler_class__c = handlerClass
		);

		if(fieldValues != null) {
			for(String fieldName : fieldValues.keySet()) {
				log.put(fieldName, fieldValues.get(fieldName));
			}
		}

		return log;
	}

	/**
	* @description 
	*/
	public static List<IntegrationLog__c> insertLogs(List<IntegrationLog__c> integrationLogs) {
		if(!integrationLogs.isEmpty()) insert integrationLogs;

		return integrationLogs;
	}

	/**
	* @description 
	*/
	@TestVisible private static PushTopic topic = null;

	public static PushTopic getPushTopic() {
		if(topic == null) {
			String topicName = PUSH_TOPIC_NAME + (Test.isRunningTest() ? 'Test' : '');
			List<PushTopic> pushTopics = [select Id from PushTopic where Name = :topicName];
			Boolean topicExists = !pushTopics.isEmpty();

			if(!topicExists && topic == null) {
				PushTopic pushTopic = new PushTopic();
				pushTopic.Name = topicName;
				pushTopic.Query = 'SELECT Id, Name, identifier__c FROM IntegrationLog__c';
				pushTopic.ApiVersion = 42.0;
				pushTopic.NotifyForOperationCreate = true;
				//pushTopic.NotifyForOperationUpdate = true;
				//pushTopic.NotifyForOperationUndelete = true;
				pushTopic.NotifyForOperationDelete = true;
				//pushTopic.NotifyForFields = 'Referenced';
				insert pushTopic;
				topic = pushTopic;
			}
			else {
				topic = pushTopics[0];
			}
		}

		return topic;
	}

	/**
	* @description 
	*/
	public static List<IntegrationLog__c> getIntegrationLogsForIdentifier(Set<String> identifiers) {
		return [
			select 
				Id,
				identifier__c,
				data__c,
				system__c,
            	error__c,
				handler_class__c
			from
				IntegrationLog__c 
			where 
				identifier__c in :identifiers
		];
	}

	/**********************************************************************************
    * @author       	Maria Dolores Sánchez Meroño 
    * @creation date    12/01/2020
    * @description  	Resolve IntegrationLog with errors
    * @param day		List of identifiers of integration Log
    **********************************************************************************/
    
    public static void resolveIntegrationLogsForIdentifier(Set<String> identifiers) {
		List<IntegrationLog__c> integrationLogs = getIntegrationLogsForIdentifier(identifiers);
		Map<String,String>extSystemHandlerName = new Map<String,String>();
		Map<String,Object> handlerClasses = new Map<String,Object>();
        List<ORG_Integration_Event__e> integrationEvents = new List<ORG_Integration_Event__e>();
		for(IntegrationLog__c log : integrationLogs) {
			if(String.isBlank(log.handler_class__c)) continue;
			if(!handlerClasses.containsKey(log.handler_class__c)) {
				try {
                    String data = log.data__c;
                    String externalSystem = log.system__c;
					if(log.data__c == '*') data = null;
					if(log.system__c == '*') externalSystem = null;
					ORG_Integration_Event__e newEvent = new ORG_Integration_Event__e(
                        System__c = log.system__c,
                        Object_Id__c = log.identifier__c,
                        Data__c = log.data__c,
                        Handler__c = log.handler_class__c
                    );   
                    integrationEvents.add(newEvent);
                    
				} 
				catch(Exception e) {
					System.debug(e.getMessage() + '\n' + e.getStackTraceString());
				}
			}
		}
        if (integrationEvents <> null && !integrationEvents.isEmpty()) {            
            try {
                Database.SaveResult[] platformEventPublishResult = EventBus.publish(integrationEvents);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }

		deleteLogsForIdentifier(identifiers);		
	}
	/**
	* @description METODO Anterior del boton Resolve  
	*/
	/*public static void resolveIntegrationLogsForIdentifier(Set<String> identifiers) {
		List<IntegrationLog__c> integrationLogs = getIntegrationLogsForIdentifier(identifiers);

		Map<String,Object> handlerClasses = new Map<String,Object>();
		for(IntegrationLog__c log : integrationLogs) {
			if(String.isBlank(log.handler_class__c)) continue;
			if(!handlerClasses.containsKey(log.handler_class__c)) {
				try {
					Type t = Type.forName(log.handler_class__c);					
        			final Object o = t.newInstance();
					if ((o instanceOf ORG_IIntegrationLogSolver)) {
						handlerClasses.put(log.handler_class__c, o);
					}
				} 
				catch(Exception e) {
					System.debug(e.getMessage() + '\n' + e.getStackTraceString());
				}
			}
		}

		Map<String,Map<String,Map<String,Object>>> identifierToDataToSystemToHandlerMap = new Map<String,Map<String,Map<String,Object>>>();
		for(IntegrationLog__c log : integrationLogs) {
			if(String.isBlank(log.handler_class__c)) continue;

			if(!identifierToDataToSystemToHandlerMap.containsKey(log.identifier__c)) identifierToDataToSystemToHandlerMap.put(log.identifier__c, new Map<String,Map<String,Object>>());
			Map<String,Map<String,Object>> dataToSystemToHandlerMap = identifierToDataToSystemToHandlerMap.get(log.identifier__c);
			String data = String.isBlank(log.data__c) ? '*' : log.data__c;
			if(!dataToSystemToHandlerMap.containsKey(data)) dataToSystemToHandlerMap.put(data, new Map<String,Object>());
			Map<String,Object> systemToHandlerMap = dataToSystemToHandlerMap.get(data);
			Object handler = handlerClasses.get(log.handler_class__c);
			if(handler != null) {
				String externalSystem = String.isBlank(log.system__c) ? '*' : log.system__c;
				systemToHandlerMap.put(externalSystem, handler);
			}
		}

		Boolean error = false;

		for(String identifer : identifierToDataToSystemToHandlerMap.keySet()) {
			Map<String,Map<String,Object>> dataToSystemToHandlerMap = identifierToDataToSystemToHandlerMap.get(identifer);
			for(String data : dataToSystemToHandlerMap.keySet()) {
				Map<String,Object> systemToHandlerMap = dataToSystemToHandlerMap.get(data);
				for(String externalSystem : systemToHandlerMap.keySet()) {
					Object handler = systemToHandlerMap.get(externalSystem);
					ORG_IIntegrationLogSolver solver = (ORG_IIntegrationLogSolver)handler;
					if(data == '*') data = null;
					if(externalSystem == '*') externalSystem = null;

					if(!solver.solveLog(identifer, data, externalSystem)) error = true;
				}
			}
		}

		if(!error) deleteLogsForIdentifier(identifiers);		
	}*/
}