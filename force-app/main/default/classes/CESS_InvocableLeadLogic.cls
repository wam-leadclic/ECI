/**
@description
<pre>
Clase que invoca métodos de la clase ORG_LeadLogic</br>

FECHA       AUTOR       DESCRIPCION<br/>
28/11/2022  LCS - MMV   Se añade la invocación al método para la eliminación en CTI de un registro en la ContactList
28/04/2022  J.Castelo   Eliminación referencias y llamadas a met. sentCTI_sfYgenesys y setDuplicatedLead
                        Adaptación de mét. invocableLeadLogic para llamada desde Flow
                        Se añade param cmID y se cambia param leadId a tipo optional. Para cumplir con 2.2.21 del dóc. técnico
</pre>
@author Leadclic Solutions
@date 28/04/2022

*/
/**********************************************************************************old*
* @author       Francisco Pérez - franciscojose.perez@salesforce.com
* @date         17/05/2018
* @group        Case
* @description  Invocable class for the Lead entity
* @Revision
**********************************************************************************/

global class CESS_InvocableLeadLogic {
    //-- CONSTANTS

    //-- ATTRIBUTES

    //-- CONSTRUCTORS

    //-- PUBLIC METHODS
    /**
     * @description Retrieves the Lead id and method to ivoke. Call the necessary method
     * @param 
     * @return 
     */
    
    @InvocableMethod( label='invocableLeadLogic' description='LeadLogic methods' category='Callout' )
    public static void invocableLeadLogic(List <invocableLeadLogicRequest> leadRequest) {
        List<Id> allCrlIds = new List<Id>();
        // Lista para añadir los registros que deben ser enviados a borrar a CTI
        List<Id> lIdRecord2Delete = new List<Id>();

        // Itera para rellenar las listas del método a invocar
        for (invocableLeadLogicRequest lr : leadRequest){
            if (lr.method == 'sentCTI_crl') {
                allCrlIds.add(lr.leadId);
            }
            if (lr.method == 'deleteRecordCTI') {
                // Se llena la lista con el identificador del nuevo registro gestionado
                lIdRecord2Delete.add(lr.cmId);
            }
        }

        // Para cada lista (si está rellena) invocamos al método correspondiente
        if ( !allCrlIds.isEmpty() ) {
            //ORG_LeadLogic.sentCTI_crl(allCrlIds);
        }
        if ( !lIdRecord2Delete.isEmpty() ) {
            ORG_LeadLogic.deleteRecordCTI(lIdRecord2Delete);
        }



        for ( invocableLeadLogicRequest lr : leadRequest){
            if (lr.method == 'sendEmail') {
                ORG_LeadLogic.sendEmail(lr.leadId,lr.fromAddress,lr.emailTemplateName);
            }
        }
    }

    /**
     * @description Parameters from the application.
     * @param 
     * @return 
     */
 global class invocableLeadLogicRequest {

    //-- REQUIRED PARAMS
    @InvocableVariable(required=true)
    global String method;

    //-- OPTIONAL PARAMS
    @InvocableVariable(required=false)
    global ID leadId;

    @InvocableVariable(required=false)
    global String fromAddress;

    @InvocableVariable(required=false)
    global String emailTemplateName;

    @InvocableVariable(required=false)
    global ID cmId;

 }
    
}