/**********************************************************************************
* @author       Maria Dolores Sánchez Meroño -mdolores.sanchez@iecisa.com
* @date         04/05/2018
* @group        Case
* @description  Trigger for the Account entity.
* @Revision
**********************************************************************************/
trigger ORG_AccountTrigger on Account (before insert, before update, before delete,
                                 after insert, after update, after delete, after undelete) {
    ORG_TriggerFactory.createAndExecuteHandler(CESS_AccountTriggerHandler.class);
}