trigger ORG_IntegrationEventTrigger on ORG_Integration_Event__e (after insert) {
    ORG_IntegrationEventLogic.handleEvents(Trigger.new); 
}