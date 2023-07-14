/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         14/05/2019
* @group        Integrations
* @description  A set of DTOs (Data Transfer Object) that represents the Consulta CESS structure.
* @Revision
**********************************************************************************/
public with sharing class CESS_ConsultaCESSDto {

    //-- CONSTRUCTOR
    /**
     * Enforce non-instantiabily.
     */
    private CESS_ConsultaCESSDto() {
        throw new CESS_ConsultaCESSDtoException('CESS_ConsultaCESSDto must never be instantiated.');
    }

    //-- SERIALIZE (BUILD) METHODS
    /**
     * serialize the body for a proper JSON payload.
     *
     * @param {@code customerRecordRequest} request
     * @return {@code String}
     */

    //-- DESERIALIZE (PARSE) METHODS
    /**
     * Parses JSON string into ConsultaRapida.
     *
     * @param {@code String} json
     * @return {@code ConsultaRapida}
     */
    public static ConsultaRapidaResponse parseConsultaRapida(String json) {

        String cad = revisaCessError('crlcustomer_rating',json);

        System.debug('***parseConsultaRapida: ' + System.JSON.deserialize(cad, ConsultaRapidaResponse.class));

        return (ConsultaRapidaResponse) System.JSON.deserialize(cad, ConsultaRapidaResponse.class);
    }

    /**
     * Parses JSON string into ConsultaRapida.
     *
     * @param {@code String} json
     * @return {@code ConsultaRapida}
     */
    public static ConsultaClienteResponse parseConsultaCliente(String json) {

        String cad = revisaCessError('dccustomer_management',json);

        return (ConsultaClienteResponse) System.JSON.deserialize(cad, ConsultaClienteResponse.class);

    }

    /**
     * Parses JSON string into ConsultaPolizas.
     *
     * @param {@code String} json
     * @return {@code ConsultaPolizas}
     */
    public static ConsultaPolizasResponse parseConsultaPolizas(String json) {

        String cad = revisaCessError('dppolicy',json);

        return (ConsultaPolizasResponse) System.JSON.deserialize(cad, ConsultaPolizasResponse.class);

    }
    
    /**
     * Parses JSON string into ConsultaGestiones.
     *
     * @param {@code String} json
     * @return {@code ConsultaGestiones}
     */
    public static ConsultaGestionesResponse parseConsultaGestiones(String json) {

        String cad = revisaCessError('dgcustomer_management',json);         

        return (ConsultaGestionesResponse) System.JSON.deserialize(cad, ConsultaGestionesResponse.class);

    }
    
    //-- INNER CLASSES 


    public static String revisaCessError(String buscar, String json){
  
       String cad = json;
        if (!json.contains(buscar+'\":')){ //respuesta errónea
            if (json.contains('error\":') == true){ //error controlado
                cad = json.replace('error\":',buscar+'\":[');
                cad = cad.replace('}}}', '}}]}');
            }else{//fallo de sistema
                cad = '{ \"' + buscar + '\":[ {\"return_code\": \"KO\", \"error_message\": \"Fallo en el sistema CESS\"}]}';
            }
        }

        return cad;
    } 

	/**
     * Class that represents a ConsultaRapidaResponse.
     */
    public class ConsultaRapidaResponse {
        public List<CESS_ConsultaRapidaResponseDto> crlcustomer_rating; //consultaRapidaResults;
    }

    /**
     * Class that represents a ConsultaClienteResponse.
     */
    public class ConsultaClienteResponse {  //consultaClienteResults
        public List<CESS_ConsultaClienteResponseDto> dccustomer_management;
    }

    /**
     * Class that represents a ConsultaPolizasResponse.
     */
    public class ConsultaPolizasResponse { //consultaPolizasResults
        public List<CESS_ConsultaPolizasResponseDto> dppolicy;
    }

    /**
     * Class that represents a ConsultaGestionesResponse.
     */
    public class ConsultaGestionesResponse {
        public List<CESS_ConsultaGestionesResponseDto> dgcustomer_management;  //consultaGestionesResults;
    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class CESS_ConsultaCESSDtoException extends Exception { }

}