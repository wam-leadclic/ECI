/**********************************************************************************
* @author       Francisco José Pérez - franciscojose.perez@salesforce.com
* @date         17/05/2019
* @group        Integrations
* @description  DTO for the Gestiones response of Consulta CESS Client 
* @Revision
**********************************************************************************/
public with sharing class CESS_ConsultaGestionesResponseDto {

    @AuraEnabled public String task_number;
    @AuraEnabled public String next_date;
    @AuraEnabled public String task_subject;
    @AuraEnabled public String collaborator_number;
    @AuraEnabled public String collaborator_name;
    @AuraEnabled public String assigned_office;
    @AuraEnabled public String branch_description;
    @AuraEnabled public String open_date;
	@AuraEnabled public String return_code;
    @AuraEnabled public String error_message;
    @AuraEnabled public String message;
    
    @AuraEnabled public List <String> comments; 

}