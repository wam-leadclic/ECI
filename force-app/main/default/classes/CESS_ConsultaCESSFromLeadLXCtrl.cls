/********************************************************************************** 
 * @author       Francisco José Pérez - franciscojose.perez@salesforce.com
 * @date         23/04/2019
 * @group        Console
 * @description  Apex Controller of the Lightning Component 'CESS_ConsultaCESSFromLead'
 * @Revision
 *              AUTOR   FECHA           DESCRIPCION
                MMV     06/11/2022      Se añade el return false para que notifique del error, en caso de que lo haya
**********************************************************************************/

public with sharing class CESS_ConsultaCESSFromLeadLXCtrl {


    //-- PUBLIC METHODS

/**
     * @description Retrieves the Account Id, the new data and update the account.
     * @param 
     * @return The account Id. 
     */

  @AuraEnabled
    public static Boolean updateAccountFromOpp (String accountId,  String datos) {

        System.debug('** updateAccountFromOpp rowId: ' + accountId);
        System.debug('** updateAccountFromOpp datos: ' + datos);
        
        CESS_ConsultaClienteResponseDto misDatos = (CESS_ConsultaClienteResponseDto) JSON.deserialize(datos, CESS_ConsultaClienteResponseDto.class);

        System.debug('** updateAccountFromOpp misDatos: ' + misDatos);

        if (String.isBlank(accountId)){
                return false; 
        }

        String squery = 'SELECT Id,identifier_aneto__pc,surname_first__pc,surname_second__pc,birthdate__pc,share_personaldata__pc,identifier_cess__pc,document_type__pc,gender__pc,PersonEmail,Phone,PersonMobilePhone,businesslines_prohibited__pc,personal_document__pc,card_eci__pc,Bypass_ValidacionConsultaCESS__c ' +
                        'FROM Account WHERE Id=:accountId LIMIT 1';
        List <Account> lstOfAcc = new List <Account>();
        try {
            lstOfAcc = Database.query(squery);
        } catch (Exception e) {
            System.debug('** updateAccountFromOpp error: ' + e.getMessage());
            throw new CESS_ConsultaCESSFromLeadLXCtrlException('SOQL query exception: '+e.getMessage());
        }

        if (lstOfAcc.isEmpty() || lstOfAcc.size() > 1){
            return false;
        }
        //update the records

        Account accountToUpdate = lstOfAcc[0];
        try {      
            // Update the data
            accountToUpdate.surname_first__pc = misDatos.surname_first;
            accountToUpdate.surname_second__pc = misDatos.surname_second;
            accountToUpdate.FirstName = misDatos.first_name;
            accountToUpdate.LastName = misDatos.surname_first + ' ' + misDatos.surname_second;
            accountToUpdate.Bypass_ValidacionConsultaCESS__c = True;
            accountToUpdate.birthdate__pc = date.parse(misDatos.birthdate);

            accountToUpdate.identifier_aneto__pc = misDatos.aneto_identifier;
            accountToUpdate.identifier_cess__pc = misDatos.cess_identifier;
            accountToUpdate.share_personaldata__pc = ORG_LeadLogic.getBooleanTypeValue(misDatos.group_permission);
            accountToUpdate.card_eci__pc = misDatos.eci_card;

            accountToUpdate.document_type__pc = ORG_LeadLogic.getDocumentTypeValue(misDatos.list_document[0].document_type);
            accountToUpdate.personal_document__pc = misDatos.list_document[0].document_number;
            accountToUpdate.businesslines_prohibited__pc = misDatos.result_descriptions;
            //pendiente el campo list_document[0].sequence, que no se donde se mapea, si es necesario.
            /* esto es lo que me llega que no he mapeado
            rating_type
            */

            accountToUpdate.PersonEmail = misDatos.Email;
            accountToUpdate.Phone = misDatos.fijo;
            accountToUpdate.PersonMobilePhone = misDatos.movil;

            // Make the update call.
            update accountToUpdate;
        } catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            return false;
        }

        return true;
    }

   @AuraEnabled
    public static List<CESS_ConsultaClienteResponseDto> getCESSClientRecords(final String document_type,
                                                                     final String document_number, 
                                                                     final Map<String,String> contact_list, 
                                                                     final String identifier_cess,
                                                                     final String identifier_aneto) {

        System.debug('** Map: ' + contact_list);
        System.debug('** Map get: ' + contact_list.get('A0T0'));

        CESS_ConsultaCESSDto.ConsultaClienteResponse clientOperationResponse;
        try {
            //-- no es necesario, viene de parámetros.   Map<String, String> myMap = new Map<String, String>();
            clientOperationResponse = CESS_ConsultaCessRestClient.getInstance().consultaCliente('DC',document_type,document_number,contact_list,identifier_cess,identifier_aneto);
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'CESS_ConsultaCESSFromLeadLXCtrl.getClientRecords: '+e.getMessage());
           	return null;
        }

        System.debug(LoggingLevel.ERROR,'CESS_ConsultaCESSFromLeadLXCtrl.getClientRecords: '+ clientOperationResponse.dccustomer_management[0]);
         
        if ( clientOperationResponse <> null){
            System.debug('** clientOperationResponse: ' + clientOperationResponse.dccustomer_management); 
            if (clientOperationResponse.dccustomer_management[0].return_code == 'KO'){
                throw new CESS_ConsultaCESSFromLeadLXCtrlException(clientOperationResponse.dccustomer_management[0].error_message);
            }else{
                return clientOperationResponse.dccustomer_management;
            }
        }
        else {
          System.debug('** clientOperationResponse is null ');
          return new List<CESS_ConsultaClienteResponseDto>();
        }

    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class CESS_ConsultaCESSFromLeadLXCtrlException extends Exception {}


}