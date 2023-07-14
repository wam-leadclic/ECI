/**********************************************************************************
	* @name         	CESS_AccountTriggerHandler
	* @version			1.0
	* @creation date    30/04/2020
	* @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
	* @description  	Apex Class with the handler for Account
	* @group        	Handler
	**********************************************************************************/
    public class CESS_AccountTriggerHandler implements ORG_Trigger {

    /* (non-Javadoc)
     *  @see ORG_cls_Trigger#bulkBefore()
     */
    public void bulkBefore() {
        if (Trigger.isDelete) {
        }
    }

    /* (non-Javadoc)
     *  @see ORG_cls_Trigger#bulkAfter()
     */
    public void bulkAfter() {
    }

   /* (non-Javadoc)
    *  @see ORG_cls_Trigger#beforeInsert(SObject)
    */
    public void beforeInsert(SObject so){       
		CESS_AccountTriggerHelper.checkIsNIFCIFNIEValid((Account)so);
    }

   /* (non-Javadoc)
    *  @see ORG_cls_Trigger#beforeUpdate(SObject, SObject)
    */
    public void beforeUpdate(SObject oldSo, SObject so) {

		//Check NIF,CIF or NIE is valid
		if (oldSo.get('personal_document__pc') <> so.get('personal_document__pc'))
			CESS_AccountTriggerHelper.checkIsNIFCIFNIEValid((Account) so);
    }

   /* (non-Javadoc)
    *  @see ORG_cls_Trigger#beforeDelete(SObject)
    */
    public void beforeDelete(final SObject so) {
        
    }

   /* (non-Javadoc)
    *  @see ORG_cls_Trigger#afterInsert(SObject)
    */
    public void afterInsert(SObject so) {        
    }

   /* (non-Javadoc)
    *  @see ORG_cls_Trigger#afterUpdate(SObject, SObject)
    */
    public void afterUpdate(final SObject oldSo, final SObject so) {         
    }

   /* (non-Javadoc)
    *  @see ORG_cls_Trigger#afterDelete(SObject)
    */
    public void afterDelete(final SObject so) { 
    }

    /* (non-Javadoc)
    *  @see ORG_cls_Trigger#afterUndelete(SObject)
    */
    public void afterUndelete(final SObject so) { 
    }

    /* (non-Javadoc)
     *  @see ORG_cls_Trigger#andFinally()
     */
    public void andFinally() {
    }
}