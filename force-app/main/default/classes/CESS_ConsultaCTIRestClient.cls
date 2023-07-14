/********************************************************************************** 
 * @author       Francisco José Pérez - franciscojose.perez@salesforce.com
 * @date         12/06/2019
 * @group        Integrations
 * @description  Client class which contains all necessary methods to interact with the Consulta CTI Service
 * @Revision
**********************************************************************************/

public with sharing class CESS_ConsultaCTIRestClient extends ORG_AbstractRestClient
											          implements CESS_ConsultaCTIClient {

    //-- CONSTANTS
    private static final String CESS_CTI_CONSULTAGENERAL_RESOURCE = ORG_AppSettingsUtils.getSetting('CESS_CTI_GENERAL_RESOURCE'); 

    //-- ATTRIBUTES

    //-- CONSTRUCTOR
    /**
     * It must be instantiated using singleton pattern.
     */
    private CESS_ConsultaCTIRestClient() { }

    //-- SINGLETON PATTERN
    /**
     * Instance is only instantiated once per request (thread/execution context).
     */
    private static CESS_ConsultaCTIRestClient instance;
    public static CESS_ConsultaCTIRestClient getInstance() {
        if (instance == null) instance = new CESS_ConsultaCTIRestClient();
        return instance;
    }

    //-- SERVICE METHODS

    /** {@inheritDoc} */
    public CESS_ConsultaCTIDto.ctiResponse insertarLeadCampana( final String campaign_name,
                                                                final List <String> columns,
                                                                final List <String> values) {
		//-- PREVALIDATIONS

        //-- HTTP REQUEST
        String resource = CESS_CTI_CONSULTAGENERAL_RESOURCE;  
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.POST;

        //-- SET BODY
        final String body = CESS_ConsultaCTIDto.buildConsultaCTIRequest(campaign_name, columns, values);
        
        //-- BUILD REQUEST
        resource += 'Add';

        System.debug('Llamada datos clientes resource: ' + resource);
        System.debug('Llamada datos clientes body: ' + body);
        
        final HttpRequest request = this.getRestRequest(restMethod, resource, body);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);

       //-- PARSE & RETURN RESPONSE
        return CESS_ConsultaCTIDto.parseInsertaLead(responseBody);
    }

        //-- SERVICE METHODS
    /** {@inheritDoc} */
    public CESS_ConsultaCTIDto.ctiResponse insertarLeadPlanificado(  final List <String> columns,
                                                                final List <String> values,
                                                                final List <String> sched,
                                                                final string CTIcampaign){
                return replanificaLlamada(columns,values,sched,CTIcampaign);                                                
    }

        //-- SERVICE METHODS
    /** {@inheritDoc} */
    public CESS_ConsultaCTIDto.ctiResponse replanificaLlamada(  final List <String> columns,
                                                                final List <String> values,
                                                                final List <String> sched,
                                                             	final string CTIcampaign){
		
		//-- PREVALIDATIONS

        //-- HTTP REQUEST
        String resource = CESS_CTI_CONSULTAGENERAL_RESOURCE;  
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.POST;

        //-- SET BODY
        final String body = CESS_ConsultaCTIDto.buildreplanificaCTIRequest(columns, values, sched,CTIcampaign);
        
        //-- BUILD REQUEST
        resource += 'Add';

        System.debug('Llamada datos clientes resource: ' + resource);
        System.debug('Llamada datos clientes body: ' + body);
        
        final HttpRequest request = this.getRestRequest(restMethod, resource, body);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);

       //-- PARSE & RETURN RESPONSE
        return CESS_ConsultaCTIDto.parserelanificaCTI(responseBody);
    }


    //-- PRIVATE METHODS
	/**
     * Builds a request based on a resource, rest method and params.
     *
     * @param {@code RestMethod} restMethod
     * @param {@code String} resource
     * @return {@code HttpRequest}
     */
    private HttpRequest getRestRequest(final RestMethod restMethod, final String resource, final String body) {
        //-- 1. Build endpoint
        final String endpoint = resource;

        //-- 2. Build request
        HttpRequest req = super.buildRequest(restMethod, endpoint, body);

        //-- 3. Return request
        return req;
    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class CESS_ConsultaCTIRestClientException extends Exception {}

}