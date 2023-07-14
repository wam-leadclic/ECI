/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         03/06/2020
* @description  Trigger for the CESS_Integration_Event__e
* @Revision
**********************************************************************************/
trigger CESS_IntegrationEventTrigger on CESS_Integration_Event__e (after insert) {
    CESS_IntegrationEventLogic.handleEvents(Trigger.new);
}