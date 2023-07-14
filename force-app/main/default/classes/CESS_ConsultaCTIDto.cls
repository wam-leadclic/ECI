/********************************************************************************** 
 * @author       Francisco José Pérez - franciscojose.perez@salesforce.com
 * @date         12/06/2019
* @group        Integrations
* @description  A set of DTOs (Data Transfer Object) that represents the Consulta CTI structure.
* @Revision
**********************************************************************************/
public with sharing class CESS_ConsultaCTIDto {

    //-- CONSTRUCTOR
    /**
     * Enforce non-instantiabily.
     */
    private CESS_ConsultaCTIDto() {
        throw new CESS_ConsultaCTIDtoException('CESS_ConsultaCTIDto must never be instantiated.');
    }

    //-- SERIALIZE (BUILD) METHODS
    /**
     * serialize the body for a proper JSON payload.
     *
     * @param {@code customerRecordRequest} request
     * @return {@code String}
     */
    public static String buildConsultaCTIRequest(final String campaign_name, final List <String> columns, final List <String> values) {
        String body = System.JSON.serialize((ConsultaCTIRequest) new ConsultaCTIRequest(campaign_name,columns,values));
        return body;
    }

    //-- SERIALIZE (BUILD) METHODS
    /**
     * serialize the body for a proper JSON payload.
     *
     * @param {@code customerRecordRequest} request
     * @return {@code String}
     */
    public static String buildreplanificaCTIRequest(final List <String> columns, final List <String> values, final List <String> sched,string CTIcampaign) {
        String body = System.JSON.serialize((ConsultaCTIRequest) new ConsultaCTIRequest(columns,values,sched,CTIcampaign));
        return body;
    }

    //-- DESERIALIZE (PARSE) METHODS

    /**
     * Parses JSON string into ctiResponse.
     *
     * @param {@code String} json
     * @return {@code ctiResponse}
     */
    public static ctiResponse parseInsertaLead(String json) {

        String cad = json;
        if  (json.contains('fault\":') ){ //error controlado
                cad = json.replace('fault\":','error\":');
//                cad = cad.replace('}}}', '}}]}');
         }

        return (ctiResponse) System.JSON.deserialize(cad, ctiResponse.class);

    }
    
    /**
     * Parses JSON string into ctiResponse.
     *
     * @param {@code String} json
     * @return {@code ctiResponse}
     */
    public static ctiResponse parserelanificaCTI(String json) {

        return (ctiResponse) System.JSON.deserialize(json, ctiResponse.class);

    }
    
    //-- INNER CLASSES 
    /**
     * Class that represents a ConsultaCTIRequest.
     */
    public class ConsultaCTIRequest {
        public CESS_ConsultaCTIRequestDto contact;

        public ConsultaCTIRequest(final String campaign_name, final List <String> columns, final List <String> values) {
            this.contact = new CESS_ConsultaCTIRequestDto(campaign_name,columns,values);
        }

        public ConsultaCTIRequest(final List <String> columns, final List <String> values, final List <String> sched,string CTIcampaign) {
            this.contact = new CESS_ConsultaCTIRequestDto(columns,values,sched,CTIcampaign);
        }

    }
 
    
    /**
     * Class that represents a ctiResponse.
     */
    public class ctiResponse {  //only 1 response, don't need a list
        public CESS_ctiResponseDto error;
    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class CESS_ConsultaCTIDtoException extends Exception { }
}