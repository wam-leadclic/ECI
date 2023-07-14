/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         14/03/2018
* @group        Trigger
* @description  Apex Interface with the definition of a Trigger Handler.
* @Revision
**********************************************************************************/
public interface ORG_Trigger {

    //-- INTERFACE METHODS
    /**
     * @description This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    void bulkBefore();

    /**
     * @description This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    void bulkAfter();

    /**
     * @description This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    void beforeInsert(final SObject so);

    /**
     * @description This method is called iteratively for each record to be updated during a BEFORE
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param oldSo the old SObject record.
     * @param so the SObject record.
     */
    void beforeUpdate(final SObject oldSo, final SObject so);

    /**
     * @description This method is called iteratively for each record to be deleted during a BEFORE
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    void beforeDelete(final SObject so);

    /**
     * @description This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point. Never execute any DML or
     * SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    void afterInsert(final SObject so);

    /**
     * @description This method is called iteratively for each record updated during an AFTER
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param oldSo the old SObject record.
     * @param so the SObject record.
     */
    void afterUpdate(final SObject oldSo, final SObject so);

    /**
     * @description This method is called iteratively for each record deleted during an AFTER
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    void afterDelete(final SObject so);

    /**
     * @description This method is called iteratively for each record undeleted during an AFTER
     * trigger. Never execute any DML or SOQL/SOSL etc in this and other iterative methods.
     * @param so the SObject record.
     */
    void afterUndelete(final SObject so);

    /**
     * @description This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    void andFinally();

}