/**********************************************************************************
    * @name             CESS_LeadTriggerHandler
    * @version          1.0
    * @creation date    28/04/2020
    * @author           Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
    * @description      Apex Class with the handler for Lead
    * @group            Handler
    * updates           07/05/2020 - Javier Suárez - add the logic for delete task when close a lead
    * @revision         AUTHOR          DATE        Reason
                        MMV - LCS       28/03/2022  Añado la llamada al método setManagementSF en el before
                        JNM - LCS       29/03/2022  Añado la llamada al metodo sendPlatformEvents en el bulk before
                        MMV - LCS       09/05/2022  Añado la llamada al metodo sendPlatformEvents también en el after
                        MMV - LCS       02/09/2022  Añado en el after insert la funcionalidad de asignar la tarea de llamada entrante
                        MMV - LCS       05/09/2022  Se añade control por Custom setting para no crear los registros de Campaign Member o Miembro de campaña AG
    **********************************************************************************/
    public class CESS_LeadTriggerHandler implements ORG_Trigger {
        
    public static Boolean hasUpdateTasks = false;
    public List<String> taskToDeleteId = new List<String>();
    /**
     * @description List of ORG_Integration_Event__e events to be published on the EventBus
     *
     */
    private List<CESS_Integration_Event__e> integrationEvents = new List<CESS_Integration_Event__e>();    
    /* (non-Javadoc)
     *  @see ORG_cls_Trigger#bulkBefore()
     */
    public void bulkBefore() {
        if (Trigger.isInsert) {
            CESS_LeadTriggerHelper.setManagementSF(Trigger.new);
        	if( !SwitchesConfiguration__c.getInstance().DesactiveCreateCM__c ) CESS_LeadTriggerHelper.sendPlatformEvents(Trigger.new);
        }
        if (Trigger.isDelete) {
        	CESS_LeadTriggerHelper.validateDelete(Trigger.old);
        }
    }

    /* (non-Javadoc)
     *  @see ORG_cls_Trigger#bulkAfter()
     */
    public void bulkAfter() {
        if (Trigger.isInsert) {
            CESS_LeadTriggerHelper.relateTasktoLead(Trigger.new);
        	if( !SwitchesConfiguration__c.getInstance().DesactiveCreateCM__c ) CESS_LeadTriggerHelper.sendPlatformEvents(Trigger.new);
        }
        if(Trigger.isUpdate){          
            CESS_LeadTriggerHelper.deleteCTILead((List<Lead>) Trigger.new);
        }
    }

   /* (non-Javadoc)
    *  @see ORG_cls_Trigger#beforeInsert(SObject)
    */
    public void beforeInsert(SObject so){
    CESS_LeadTriggerHelper.checkIsNIFCIFNIEValid((Lead)so);
    }

   /* (non-Javadoc)
    *  @see ORG_cls_Trigger#beforeUpdate(SObject, SObject)
    */
    public void beforeUpdate(SObject oldSo, SObject so) {
		//Boolean notValidateDoc = so.get('Bypass_ValidacionConsultaCESS__c');
        //Check NIF,CIF or NIE is valid
        System.debug('beforeUpdated oldso: '+ oldSo.get('document_number__c')+' so: '+ so.get('document_number__c'));
        if ( oldSo.get('document_number__c') <> so.get('document_number__c'))
            CESS_LeadTriggerHelper.checkIsNIFCIFNIEValid((Lead) so);
        
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
        //Si el lead cumple condiciones se añade a la lista de revisión de tareas.	
        CESS_LeadTriggerHelper.addLeadsToDelete((Lead) so,taskToDeleteId);
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
        
        if ( Trigger.isUpdate && Trigger.isAfter ) {	
            System.debug('hasUpdateTasks antes: ' +hasUpdateTasks);	
            //Si el lead cumple condiciones se cierran las tareas asociadas.	
            hasUpdateTasks = CESS_LeadTriggerHelper.checkLeadsToDelete(taskToDeleteId,hasUpdateTasks);	
            System.debug('hasUpdateTasks despues: ' +hasUpdateTasks);
        }
    }
}