/**********************************************************************************
* @author       Francisco José Pérez - franciscojose.perez@salesforce.com
* @date         17/05/2019
* @group        Integrations
* @description  DTO for the Policy response of Consulta CESS Client 
* @Revision
**********************************************************************************/
public with sharing class CESS_ConsultaPolizasResponseDto {

    @AuraEnabled public String company;
    @AuraEnabled public String company_description;
    @AuraEnabled public String insurance_type;
    @AuraEnabled public String product_description;
    @AuraEnabled public String insurance_line;
    @AuraEnabled public String line_description;
    @AuraEnabled public String policy_number;
    @AuraEnabled public String certificate_number;
    @AuraEnabled public String request_number;
    @AuraEnabled public String status;
    @AuraEnabled public String status_description;
    @AuraEnabled public String start_date;
    @AuraEnabled public String end_date;
    @AuraEnabled public String expiration_date;
    @AuraEnabled public String cancelation_type;
    @AuraEnabled public String cancelation_reason;
    @AuraEnabled public String cancelation_description;
    @AuraEnabled public String insured_risk;
    @AuraEnabled public String origin_system;
    @AuraEnabled public String anual_quota;
    @AuraEnabled public String branch_code;
    @AuraEnabled public String branch_description;
    @AuraEnabled public String collaborator_code;
    @AuraEnabled public String collaborator_name;
    @AuraEnabled public String collaborator_surname1;
    @AuraEnabled public String collaborator_surname2;
	@AuraEnabled public String return_code;
    @AuraEnabled public String error_message;
    @AuraEnabled public String message;

}