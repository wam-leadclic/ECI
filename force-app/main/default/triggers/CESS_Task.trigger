/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         27/04/2020
* @description  General Trigger in the Task entity
* @Revision
**********************************************************************************/
trigger CESS_Task on Task (before insert, before update, before delete,
                                 after insert, after update, after delete) {
	ORG_TriggerFactory.createAndExecuteHandler(CESS_TaskHandler.class);
}