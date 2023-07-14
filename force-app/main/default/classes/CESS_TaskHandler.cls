/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         27/04/2020
* @description  Trigger handler class fot the Task entity.
* @Revision
**********************************************************************************/
public class CESS_TaskHandler implements ORG_Trigger {

    //-- ATTRIBUTES
    public List<Id> totalTasksIdsToDelete = new List<Id>();
    public List<Id> totalTasksIdsToInsert = new List<Id>();
    public List<Id> totalTasksIdsToUpdate = new List<Id>();
    public List<Task> totalTasksToUpdate = new List<Task>();
    public Map<ID, Opportunity> opportunityMap = new Map<ID, Opportunity>();
    public Map<ID, Lead> leadMap = new Map<ID, Lead>();
    public Map<ID, Contact> ContactMap = new Map<ID, Contact>();
    public Map<ID, Lead> maxIntentosleadMap = new Map<ID, Lead>();
    public static Boolean hasInsert = false;

    public Map<ID, String> controlCTIMap = new Map<ID, String>();

    //-- OVERRIDEN ORG_Trigger METHODS
    /**
     * @description This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() {
        
        if (Trigger.isUpdate || Trigger.isInsert){
            CESS_TaskTriggerHelper.checkNewAndUpdateTasks((List<Task>) Trigger.new, controlCTIMap, opportunityMap,leadMap,maxIntentosleadMap,ContactMap);
        }
    }

    /**
     * @description This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter() {
    }

    /**
     * @description This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    public void beforeInsert(final SObject so) {

        CESS_TaskTriggerHelper.setReminderAndPlanificada((Task)so);
        CESS_TaskTriggerHelper.validateCreateLlamadasPlanificadas((Task)so,opportunityMap,leadMap,ContactMap);

    }

    /**
     * @description This method is called iteratively for each record to be updated during a BEFORE
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param oldSo the old SObject record.
     * @param so the SObject record.
     */
    public void beforeUpdate(final SObject oldSo, final SObject so) { 
        CESS_TaskTriggerHelper.controlUpdatePlanificadas((Task)oldSo,(Task)so, opportunityMap,totalTasksToUpdate,totalTasksIdsToDelete, totalTasksIdsToUpdate,leadMap, hasInsert,ContactMap);
    }

    /**
     * @description This method is called iteratively for each record to be deleted during a BEFORE
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    public void beforeDelete(final SObject so) {
        CESS_TaskTriggerHelper.controlBorradoPlanificada(so);
    }

    /**
     * @description This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point. Never execute any DML or
     * SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    public void afterInsert(final SObject so) {
        CESS_TaskTriggerHelper.insertaMapPlanificada(so,totalTasksIdsToInsert);
    }

    /**
     * @description This method is called iteratively for each record updated during an AFTER
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param oldSo the old SObject record.
     * @param so the SObject record.
     */
    public void afterUpdate(final SObject oldSo, final SObject so) {
    }

    /**
     * @description This method is called iteratively for each record deleted during an AFTER
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    public void afterDelete(final SObject so) {

    }

    /**
     * @description This method is called iteratively for each record undeleted during an AFTER
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    public void afterUndelete(final SObject so) {

    }

    /**
     * @description This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally() {
        hasInsert = CESS_TaskTriggerHelper.sincronizaPlanificadas(totalTasksIdsToDelete,totalTasksToUpdate,totalTasksIdsToInsert,totalTasksIdsToUpdate,maxIntentosleadMap,controlCTIMap,hasInsert);        
    }

}