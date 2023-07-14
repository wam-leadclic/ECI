/**********************************************************************************
* @author       Javier Suárez
* @date         05/05/2018
* @group        Case
* @description  Trigger for the Opportunity entity.
* @Revision
**********************************************************************************/
trigger ORG_OpportunityTrigger on Opportunity (before insert, before update, before delete,
                                 after insert, after update, after delete, after undelete) {
    ORG_TriggerFactory.createAndExecuteHandler(CESS_OpportunityTriggerHandler.class);
}