/**********************************************************************************
* @author       Giovanni Modica - giovanni.modica@salesforce.com
* @date         22/05/2018
* @group        Test
* @description  Test trigger to test the ORG_TriggerFactory class
* @Revision
**********************************************************************************/
@isTest
public class ORG_TriggerHandlerTest implements ORG_Trigger {
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
        
    }
}