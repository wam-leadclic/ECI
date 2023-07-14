/********************************************************************************** 
 * @author       Francisco José Pérez - franciscojose.perez@salesforce.com
 * @date         30/04/2019
 * @group        Console
 * @description  Apex Controller of the Lightning Component 'CESS_AllCESSData'
 * @Revision
**********************************************************************************/
public with sharing class CESS_ConsultaPolizasLXCtrl {

    //-- PUBLIC METHODS

	/**
     * Requests detailed info of an operation
     *
     * @param lead query fields for cess system. email, phone, dni, cessId - the transaction being queried
     * @return CESS_ConsultaPolizasResponseDto
     */
    @AuraEnabled
    public static List<CESS_ConsultaPolizasResponseDto> getCESSPolicyRecords( final String identifier_cess,
                                                                             final String identifier_aneto) {

        return ORG_LeadLogic.getCESSPolicyRecords(identifier_cess, identifier_aneto);

    }
}