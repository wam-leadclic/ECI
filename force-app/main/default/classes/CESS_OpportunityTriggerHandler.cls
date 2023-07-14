/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         05/05/2020
* @description  Trigger handler class fot the Opportunity entity.
* @Revision
**********************************************************************************/
public class CESS_OpportunityTriggerHandler implements ORG_Trigger {

    //-- ATTRIBUTES
    public List<Task> totalTasksToDelete = new List<Task>();
    static Boolean hasUpdateTasks = false;
    public Map<ID, List<Task>> taskMap = new Map<ID, List<Task>>();

    //-- OVERRIDEN ORG_Trigger METHODS
    /**
     * @description This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() {  
    }

    /**
     * @description This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter() {
        if (Trigger.isUpdate){
            CESS_OpportunityTriggerHelper.selectOppTaskToUpdate(taskMap);          	
        }
    }

    /**
     * @description This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    public void beforeInsert(final SObject so) {
    }

    /**
     * @description This method is called iteratively for each record to be updated during a BEFORE
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param oldSo the old SObject record.
     * @param so the SObject record.
     */
    public void beforeUpdate(final SObject oldSo, final SObject so) {        
    }

    /**
     * @description This method is called iteratively for each record to be deleted during a BEFORE
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    public void beforeDelete(final SObject so) {        
    }

    /**
     * @description This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point. Never execute any DML or
     * SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    public void afterInsert(final SObject so) {
    }

    /**
     * @description This method is called iteratively for each record updated during an AFTER
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param oldSo the old SObject record.
     * @param so the SObject record.
     */
    public void afterUpdate(final SObject oldSo, final SObject so) {
        CESS_OpportunityTriggerHelper.checkTaskToDelete(taskMap,(Opportunity) so,totalTasksToDelete);
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
        if ( totalTasksToDelete.size() > 0 && Trigger.isUpdate && Trigger.isAfter && hasUpdateTasks == false ) { 
            hasUpdateTasks = true;
            update totalTasksToDelete;
        }   
    }        
}