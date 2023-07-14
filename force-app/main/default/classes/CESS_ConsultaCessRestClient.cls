/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         14/05/2019
* @group        Integrations
* @description  Client class which contains all necessary methods to interact with the Consulta CESS Service.
* @Revision
**********************************************************************************/
public with sharing class CESS_ConsultaCessRestClient extends ORG_AbstractRestClient
											          implements CESS_ConsultaCessClient {

    //-- CONSTANTS
    private static final String CESS_CONSULTACESS_CONSULTAGENERAL_RESOURCE = ORG_AppSettingsUtils.getSetting('CESS_CONS_GENERAL_RESOURCE'); 


    //-- ATTRIBUTES

    //-- CONSTRUCTOR
    /**
     * It must be instantiated using singleton pattern.
     */
    private CESS_ConsultaCessRestClient() { }

    //-- SINGLETON PATTERN
    /**
     * Instance is only instantiated once per request (thread/execution context).
     */
    private static CESS_ConsultaCessRestClient instance;
    public static CESS_ConsultaCessRestClient getInstance() {
        if (instance == null) instance = new CESS_ConsultaCessRestClient();
        return instance;
    }

    //-- SERVICE METHODS
    /** {@inheritDoc} */
    public CESS_ConsultaCESSDto.ConsultaRapidaResponse consultaRapidaLead(final String operationType, final String tipoDocumento,
                                                                          final String numeroDocumento, final Map<String,String> listaContactos,
                                                                          final String idCess, final String idAneto) {
		//-- PREVALIDATIONS
		if (operationType <> 'CRL') throw new CESS_ConsultaCessRestClientException('"operationType" wrong.');
		
        //-- HTTP REQUEST
        String resource = CESS_CONSULTACESS_CONSULTAGENERAL_RESOURCE; 
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.GET;

        //-- SET BODY
        String body;

        //-- BUILD REQUEST
        String urlStringParameter='';

        //A través del menú principal
        urlStringParameter = 'main_menu?operation_type=CRL';
        urlStringParameter = constructUrlParam(urlStringParameter, tipoDocumento, numeroDocumento, listaContactos, idCess, idAneto);
        resource += urlStringParameter;
        final HttpRequest request = this.getRestRequest(restMethod, resource, body);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);
                                                                       
        //-- PARSE & RETURN RESPONSE
        return CESS_ConsultaCESSDto.parseConsultaRapida(responseBody);
    }

    /** {@inheritDoc} */
    public CESS_ConsultaCESSDto.ConsultaClienteResponse consultaCliente(final String operationType, final String document_type,
                                                                          final String document_number, final Map<String,String> listaContactos,
                                                                          final String cess_identifier, final String aneto_identifier) {
		//-- PREVALIDATIONS
		if (operationType <> 'DC') throw new CESS_ConsultaCessRestClientException('"operationType" wrong.');
		
        //-- HTTP REQUEST
        String resource = CESS_CONSULTACESS_CONSULTAGENERAL_RESOURCE;  
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.GET;

        //-- BUILD REQUEST
        String body;

		String urlStringParameter='';

        //A través del menú principal
        urlStringParameter = 'main_menu?operation_type=DC';

        urlStringParameter = constructUrlParam(urlStringParameter, document_type, document_number, listaContactos, cess_identifier, aneto_identifier);
   
        resource += urlStringParameter;

        System.debug('Llamada datos clientes: ' + resource);
        final HttpRequest request = this.getRestRequest(restMethod, resource, body);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);
        
        
        System.debug('Response clientes: ' + responseBody);

        //-- PARSE & RETURN RESPONSE
        return CESS_ConsultaCESSDto.parseconsultaCliente(responseBody);
    }

    //-- SERVICE METHODS
    /** {@inheritDoc} */
    public CESS_ConsultaCESSDto.ConsultaPolizasResponse consultaPolizas(final String operationType,
                                                                       final String idCess, 
                                                                       final String idAneto) {
		
        //-- PREVALIDATIONS
		if (operationType <> 'DP') throw new CESS_ConsultaCessRestClientException('"operationType" wrong.');
		
        //-- HTTP REQUEST
        String resource = CESS_CONSULTACESS_CONSULTAGENERAL_RESOURCE;                                               

		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.GET;

        //-- SET BODY
        String body;  // null si no se usa

        //-- BUILD REQUEST

        resource += 'main_menu?operation_type=DP';
        if (String.isNotBlank(idCess)) resource += '&cess_identifier=' + idCess;
        if (String.isNotBlank(idAneto)) resource += '&aneto_identifier=' + idAneto;

        final HttpRequest request = this.getRestRequest(restMethod, resource, body);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);
                                                                       
        //-- PARSE & RETURN RESPONSE
        return CESS_ConsultaCESSDto.parseConsultaPolizas(responseBody);
    }

        //-- SERVICE METHODS
    /** {@inheritDoc} */
    public CESS_ConsultaCESSDto.ConsultaGestionesResponse consultaGestiones(final String operationType,
                                                                       final String idCess, 
                                                                       final String idAneto) {
		
        //-- PREVALIDATIONS
		if (operationType <> 'DG') throw new CESS_ConsultaCessRestClientException('"operationType" wrong.');

        //-- HTTP REQUEST
        String resource = CESS_CONSULTACESS_CONSULTAGENERAL_RESOURCE;
                                                                    
        final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.GET;

        //-- SET BODY
        String body;  // null si no se usa

        //-- BUILD REQUEST
        
        resource += 'main_menu?operation_type=DG';
        if (String.isNotBlank(idCess)) resource += '&cess_identifier=' + idCess;
        if (String.isNotBlank(idAneto)) resource += '&aneto_identifier=' + idAneto;

        final HttpRequest request = this.getRestRequest(restMethod, resource, body);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);
                                                                    
        //-- PARSE & RETURN RESPONSE
        System.debug('consultaCessGeneral DG response: ' + responseBody);

        return CESS_ConsultaCESSDto.parseConsultaGestiones(responseBody);
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

    private String addUrlParameter(String cad, String param, String value){

        if (String.isNotBlank(cad)){
            return (cad + '&' + param + '=' + value);
        }else{
            return (cad + '?' + param + '=' + value);
        }
    }

    private String constructUrlParam(final String urlStringParameter,final String document_type,final String document_number, 
                                     final Map<String,String> listaContactos, final String cess_identifier, 
                                     final String aneto_identifier ){
        String salida = urlStringParameter;

        //construct url parameter
        if (String.isNotBlank(cess_identifier)){
            salida = addUrlParameter(salida, 'cess_identifier', cess_identifier);
        }else{
            if (String.isNotBlank(aneto_identifier)){
                salida = addUrlParameter(salida, 'aneto_identifier', aneto_identifier);
            }else {
                if (String.isNotBlank(document_number)){
                    salida = addUrlParameter(salida, 'document_number', document_number.leftPad(15, '0'));
                    salida = addUrlParameter(salida, 'document_type', ORG_LeadLogic.getCESSDocumentTypeValue(document_type));                      
                }else {//contact list
                    if (!listaContactos.isEmpty()){
                        for (String fieldName : listaContactos.keySet()){
                            if (listaContactos.get(fieldName) != null){
                                salida = addUrlParameter(salida, 'contact_type', fieldName);
                                salida = addUrlParameter(salida, 'contact_data', listaContactos.get(fieldName));
                            }
                        } 
                    }
                }//else contact list
           }
        }
        return salida;
    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class CESS_ConsultaCessRestClientException extends Exception {}

}