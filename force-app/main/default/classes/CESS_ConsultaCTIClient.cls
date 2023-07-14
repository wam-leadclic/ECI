/********************************************************************************** 
* @author       Francisco José Pérez - franciscojose.perez@salesforce.com
* @date         12/06/2019
* @group        Integrations
* @description  A set of definition methods to interact with the CTI Service.
* @Revision
**********************************************************************************/
public interface CESS_ConsultaCTIClient {

    //-- SERVICE METHODS
    
    /**
     * Gets Lead information
     *
     * @param identifier {@code String} param 1.
     *
     * @return {@code CESS_ConsultaCTIDto.ctiResponse}
     */
    CESS_ConsultaCTIDto.ctiResponse insertarLeadCampana(final String campaign_name,
                                                        final List < String > columns,
                                                        final List < String > values);

    /**
     * Gets Cliente information
     *
     * @param identifier {@code String} param 1.
     *
     * @return {@code CESS_ConsultaCTIDto.ConsultaClienteResponse}
     */
    CESS_ConsultaCTIDto.ctiResponse replanificaLlamada( final List <String> columns,
                                                        final List <String> values,
                                                        final List <String> sched,
                                                      	final string CTIcampaign);

}