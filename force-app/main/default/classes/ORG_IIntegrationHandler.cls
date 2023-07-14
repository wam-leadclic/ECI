public interface ORG_IIntegrationHandler {
	void handleEvent(ORG_Integration_Event__e event);
	Map<String,Object> getLogValues(ORG_Integration_Event__e event);
}