/********************************************************************************** 
* @author       Francisco José Pérez - franciscojose.perez@salesforce.com
* @date         12/06/2019
* @group        Integrations
* @description  DTO for the insertaLead request of CTI Client
* @Revision
**********************************************************************************/
public class CESS_ctiResponseDto {

    @AuraEnabled public String details;
    @AuraEnabled public String request_id;
    @AuraEnabled public String message;

}