/**********************************************************************************
* @author       Maria Dolores Sánchez Meroño -mdolores.sanchez@iecisa.com
* @date         04/05/2018
* @group        Case
* @description  Trigger for the Lead entity.
* @Revision
**********************************************************************************/
trigger ORG_LeadTrigger on Lead (before insert, before update, before delete,
                                 after insert, after update, after delete, after undelete) {
    ORG_TriggerFactory.createAndExecuteHandler(CESS_LeadTriggerHandler.class);
}