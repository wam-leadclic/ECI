/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         14/05/2019
* @group        Integrations
* @description  A set of definition methods to interact with the Consultas CESS Service.
* @Revision
**********************************************************************************/
public interface CESS_ConsultaCessClient {

    //-- SERVICE METHODS
    
    /**
     * Gets Lead information
     *
     * @param identifier {@code String} param 1.
     *
     * @return {@code CESS_ConsultaCESSDto.ConsultaRapidaResponse}
     */
    CESS_ConsultaCESSDto.ConsultaRapidaResponse consultaRapidaLead(final String operationType, final String tipoDocumento,
                                                                   final String numeroDocumento, final Map<String,String> listaContactos,
                                                                   final String idCess, final String idAneto);

    /**
     * Gets Cliente information
     *
     * @param identifier {@code String} param 1.
     *
     * @return {@code CESS_ConsultaCESSDto.ConsultaClienteResponse}
     */
    CESS_ConsultaCESSDto.ConsultaClienteResponse consultaCliente(final String operationType, final String tipoDocumento,
                                                                 final String numeroDocumento, final Map<String,String> listaContactos,
                                                                 final String idCess, final String idAneto);

    /**
     * Gets Cliente information
     *
     * @param identifier {@code String} param 1.
     *
     * @return {@code CESS_ConsultaCESSDto.ConsultaPolizasResponse}
     */
    CESS_ConsultaCESSDto.ConsultaPolizasResponse consultaPolizas(final String operationType,
                                                                       final String idCess, 
                                                                       final String idAneto);

    /**
     * Gets Cliente information
     *
     * @param identifier {@code String} param 1.
     *
     * @return {@code CESS_ConsultaCESSDto.ConsultaGestionesResponse}
     */
    CESS_ConsultaCESSDto.ConsultaGestionesResponse consultaGestiones(final String operationType,
                                                                       final String idCess, 
                                                                       final String idAneto);

}