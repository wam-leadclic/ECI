/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         17/05/2019
* @group        Integrations
* @description  DTO for the EmpleadoInformation response of Consulta CESS Client
* @Revision
**********************************************************************************/
public with sharing class CESS_ConsultaRapidaResponseDto {

	@AuraEnabled public String return_code;
    @AuraEnabled public String error_message;
    @AuraEnabled public String prospect;
    @AuraEnabled public String tasks;  //cess_tasks
    @AuraEnabled public List <line_signed> line_signed;  //tradeList_signed
    @AuraEnabled public String age;   
    @AuraEnabled public String gender;
    @AuraEnabled public List <String> line_forbidden; //tradeList_forbidden
    //nuevos
    @AuraEnabled public String cess_identifier;
    @AuraEnabled public String aneto_identifier;

    public class line_signed {
        @AuraEnabled public String insurance_code;
        @AuraEnabled public String insurance_description;
    }

    /*    public CESS_ConsultaRapidaResponseDto(String c, String t, String nf, String e, 
                                          String rc, String ed, String g, String rp) {
        return_code = c;
        error_message = t;
        prospect = nf;
        tasks = e;
        //line_signed = rc;
        age = ed;
        gender = g;
        //line_forbidden = rp;
    }
    */

    //error fields.
    @AuraEnabled public String message;
    @AuraEnabled public String request_id;
    @AuraEnabled public Details details;


    public class Details {
        @AuraEnabled public String code; 
        @AuraEnabled public String message;
        @AuraEnabled public String description;
    }

    public CESS_ConsultaRapidaResponseDto(String error) {
        message = error;
    }

    public CESS_ConsultaRapidaResponseDto() {
        
    }

}