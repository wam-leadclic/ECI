public class ORG_IntegrationEventLogic implements ORG_IIntegrationLogSolver {
	//-- CONSTANTS
	/* @description */	
	public static final String MAX_RETRIES_SETTING = 'ORG_INTEGRATION_RETRIES';	
	/* @description */	
	public static final String HANDLERS_SETTING = 'ORG_INTEGRATION_HANDLERS';		
	/* @description */	
	public static final Integer MAX_RETRIES_DEFAULT = 3;	


	/**
     * @description 
     */
	 public static void handleEvents(List<ORG_Integration_Event__e> events) {
         System.debug('loles handleEvents events -->'+ events.size() + 'hanlder: ' +events[0].Handler__c);
		final Integer maxRetries = getMaxRetries();

		Map<String,List<Handler>> handlersBySystem = getHandlers();    

		List<IntegrationLog__c> logs = new List<IntegrationLog__c>();

		for(ORG_Integration_Event__e event : events) {
            System.debug('ORG_Integration_Event__e Handler: ' +event.Handler__c + 'ORG_Integration_Event__e Retries: '+event.Times_Retried__c );
			System.debug('ORG_Integration_Event__e maxRetries: ' +maxRetries);
			if(event.Times_Retried__c > 0) { // if Times_Retried__c > 0 then this is event will be processed by a single handler
				Integer timesRetried = (Integer)event.Times_Retried__c;
                System.debug('EventBus.TriggerContext.currentContext().retries ' + EventBus.TriggerContext.currentContext().retries + 'ORG_Integration_Event__e Retries: '+event.Times_Retried__c );
				if(EventBus.TriggerContext.currentContext().retries < timesRetried && timesRetried <= maxRetries) {
					throw new EventBus.RetryableException('Wait some time to retry');
				}

				if(event.Times_Retried__c > maxRetries) { // do not retry anymore, register the fact that it has not yet been processed
					logs.add(registerLog(event));
					continue;
				}
			}

			if(String.isNotBlank(event.Handler__c)) {
				Handler handler = getHandlerByName(handlersBySystem, event.Handler__c);
				try {	
					handleEvent(event, event.Handler__c, handler.async);
				}
				catch(Exception e) { // retry the operation
					retryEvent(event, handler.handlerClass, e);
				}	
			}
			else {
				List<Handler> handlers = handlersBySystem.get(event.System__c);						
				for(Handler handler : handlers) {
					try {	
						handleEvent(event, handler.handlerClass, handler.async);
					}
					catch(Exception e) { // retry the operation
						retryEvent(event, handler.handlerClass, e);
					}
				}
			}
			
		}

		ORG_IntegrationLogLogic.insertLogs(logs);
	}

	/**
     * @description 
     */
	private static void handleEvent(ORG_Integration_Event__e event, String handlerClass, Boolean async) {
		if(async) {
			handleEventFuture(JSON.serialize(event), handlerClass);
		}
		else {			
			ORG_IIntegrationHandler integrationHandler = getIntegrationHandler(handlerClass);
			integrationHandler.handleEvent(event);
		}
	} 

	/**
     * @description 
     */
	@future(callout = true)
	private static void handleEventFuture(String eventAsJson, String handlerClass) {
		ORG_Integration_Event__e event = (ORG_Integration_Event__e)JSON.deserialize(eventAsJson, ORG_Integration_Event__e.class);
		try {
			Type t = Type.forName(handlerClass);			
			ORG_IIntegrationHandler handler = (ORG_IIntegrationHandler)t.newInstance();
			handler.handleEvent(event);
		}
		catch(Exception e) {
			retryEvent(event, handlerClass, e);
		}
	} 

	/**
     * @description 
     */
	 private static ORG_IIntegrationHandler getIntegrationHandler(String className) {
		Type t = Type.forName(className);
		Object o = t.newInstance();
		if(o instanceof ORG_IIntegrationHandler) {
			return (ORG_IIntegrationHandler)o;
		}					
		
		return null;
	}

	/**
     * @description 
     */
	private static void retryEvent(ORG_Integration_Event__e event, String handlerClass, Exception e) {
		String error = e.getMessage() + '\n' + e.getStackTraceString();
		System.debug(error);

		DateTime timestamp = event.Timestamp__c != null ? event.Timestamp__c : event.CreatedDate;
		String eventId = event.Event_Id__c != null ? event.Event_Id__c : event.ReplayId;

		ORG_Integration_Event__e newEvent = event.clone();
		newEvent.Times_Retried__c++;
		newEvent.Last_Error__c = error;
		newEvent.Event_Id__c = eventId;
		newEvent.Timestamp__c = timestamp;
		newEvent.Handler__c = handlerClass;
		EventBus.publish(newEvent);
	}	

	/**
     * @description 
     */
	private static IntegrationLog__c registerLog(ORG_Integration_Event__e event) {
		Map<String,Object> fields = new Map<String,Object>();
		String handlerClass = 'ORG_IntegrationEventLogic';
		if(String.isNotBlank(event.Handler__c)) {
            handlerClass = event.Handler__c;
			Type t = Type.forName(event.Handler__c);
			Object handler = t.newInstance();
			if(handler instanceOf ORG_IIntegrationHandler) {
				fields = ((ORG_IIntegrationHandler)handler).getLogValues(event);
			}			
		}  

		IntegrationLog__c log = ORG_IntegrationLogLogic.createIntegrationLog(event.Object_Id__c, event.Data__c, event.System__c, event.Last_Error__c, (Integer)event.Times_Retried__c, handlerClass, fields);

		return log;
	}	

	/**
     * @description 
     */
	private static Integer maxRetries = -1;
	@TestVisible private static Integer getMaxRetries() {
		if(maxRetries > 0) return maxRetries;

		String maxRetriesSetting = ORG_AppSettingsUtils.getSettingInt(MAX_RETRIES_SETTING);
		if(String.isBlank(maxRetriesSetting)) {
			maxRetries = MAX_RETRIES_DEFAULT;
		}
		else {
			try {
				maxRetries = Integer.valueOf(maxRetriesSetting);
			}
			catch(Exception e) {
				maxRetries = MAX_RETRIES_DEFAULT;
			}

		}

		if(maxRetries > 9) maxRetries = 9; // 9 is the maximum number of retries for platform events

		return maxRetries;
	}

	/**
     * @description 
     */
	private static Map<String,List<Handler>> getHandlers() {
		Map<String,List<Handler>> systemToHandlers = new Map<String,List<Handler>>();

		String handlersSettings = Test.isRunningTest() ? ORG_IntegrationEventLogicTest.setting : ORG_AppSettingsUtils.getSettingInt(HANDLERS_SETTING);
    	if(String.isBlank(handlersSettings)) return systemToHandlers;

		List<Handler> hs = (List<Handler>)JSON.deserialize(handlersSettings, List<Handler>.class);
		for(Handler h : hs) {
			if(!h.active || String.isBlank(h.handlerClass)) continue;
			try {				
				if(!systemToHandlers.containsKey(h.targetSystem)) systemToHandlers.put(h.targetSystem, new List<Handler>());
				Type t = Type.forName(h.handlerClass);
				Object o = t.newInstance();
				if(o instanceof ORG_IIntegrationHandler) {
					systemToHandlers.get(h.targetSystem).add(h);
				}
			}
			catch(Exception e) {
				System.debug(e.getMessage() + '\n' + e.getStackTraceString());
			}
		}

		return systemToHandlers;
	}

	/**
     * @description 
     */
	private static Handler getHandlerByName(Map<String,List<Handler>> handlersBySystem, String name) {
		for(String systemName : handlersBySystem.keySet()) {
			for(Handler h : handlersBySystem.get(systemName)) {
				if(h.handlerClass == name) return h;
			}
		}
		return null;
	}

	/**
     * @description 
     */
    public Boolean solveLog(String identifier, String data, String externalSystem) {
		ORG_Integration_Event__e newEvent = new ORG_Integration_Event__e(
			System__c = externalSystem,
			Object_Id__c = identifier,
			Data__c = data
		);
		EventBus.publish(newEvent);

        return true;
    }

	/**
     * @description 
     */
	private class Handler {
		public String s {get; set;}
		public String c {get; set;}
		public Boolean a {get; set;}
		public Boolean async {get; set;}
		
		public String targetSystem { get { return s; } }
		public String handlerClass { get { return c; } }
		public Boolean active  { get { return a; } }
	}

	//-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class ORG_IntegrationEventException extends Exception {
		
	}  
}