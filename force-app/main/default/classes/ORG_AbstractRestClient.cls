/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         12/03/2018
* @group        Integrations
* @description  Client abstract class which contains all necessary methods to interact with ECI.
* @Revision
				FECHA       AUTOR       DESCRIPCION<br/>
				01/06/2022  LCS-JCB     Se añade headers User-Agente y BMECI en BuildRequest, 
										para control de seguridad necesario en todas las peticiones a WSO2
**********************************************************************************/
public abstract with sharing class ORG_AbstractRestClient {

    //-- CONSTANTS
    /**
     * Default timeout, in milliseconds.
     */
    private static final Integer DEFAULT_TIMEOUT = 120000;
    /**
     * Authentication mode: ['Custom','Managed']
     */
    private static final String ORG_WSO2_AUTH_METHOD = ORG_AppSettingsUtils.getSetting('ORG_WSO2_AUTH_METHOD');
    
	/**
	 * Values new Headers for requests to WSO2
	 */
    private static final String ORG_WSO2_USER_AGENT = ORG_AppSettingsUtils.getSetting('ORG_WSO2_USERAGENT');
    private static final String ORG_WSO2_BMECI = ORG_AppSettingsUtils.getSetting('ORG_WSO2_BMECI');
    
    //-- VARIABLES
    private String authenticationMethod;

    private ORG_WSO2RestClient auth = new ORG_WSO2RestClient();
	// MMV: COMENTADO PARA EVITAR DEPENDENCIAS
    //private VOC_MKCloudRestClient authMK = new VOC_MKCloudRestClient();      

    protected HTTPResponse lastResponse;

    //-- CONSTRUCTORS
    /**
     * Default constructor.
     */
    public ORG_AbstractRestClient() {
        this.authenticationMethod = ORG_WSO2_AUTH_METHOD;
    }
    /**
     * Overloaded constructor.
     */
    public ORG_AbstractRestClient(final String authMethod) {
        this.authenticationMethod = authMethod;
    }

    //-- ENUM
    /**
     * Enumerates all valid REST methods.
     */
    public enum RestMethod {
        GET,
        POST,
        PUT,
        DEL        
    }

    //-- PROTECTED METHODS   
    /**
     * Creates a new generic request.
     *
     * @param restMethod {@code RestMethod}
     * @param endpoint {@code String}
     * @return {@code HttpRequest}
     */
    protected HttpRequest buildRequest(final RestMethod restMethod, final String endpoint, final String body) {
        //-- REQUEST INIT
        HttpRequest req;
		System.debug('ORG_AbstractRestClient.buildRequest --> authenticationMethod: ' + authenticationMethod);
        //-- AUTH CONFIG
        if (authenticationMethod == 'Managed') {
            req = new HttpRequest();
            req.setEndpoint(endpoint); 
            //Cabeceras nuevas, incluir en las peticiones a WSO2 LCS-JCB 
			req.setHeader('User-Agent', ORG_WSO2_USER_AGENT );
            req.setHeader('BMECI', ORG_WSO2_BMECI);
        } else{
             if (authenticationMethod == 'Marketing'){
                 System.debug('1');
                 // MMV: COMENTADO PARA EVITAR DEPENDENCIAS
                 //authMK.setTokenNamedCredential('callout:VOC_MKTCLOUD');
                 //req = authMK.buildRequest(endpoint,restMethod.name());           
             }        
             else {
                auth.setTokenNamedCredential('callout:WSO2_Token');
                req = auth.buildRequest(endpoint,restMethod.name());
            }            
        }

        //-- REQUEST PARAMS
        if (restMethod.name() == 'DEL')
            req.setMethod('DELETE');
        else {
            req.setMethod(restMethod.name());
        }
        req.setTimeout(DEFAULT_TIMEOUT);

        //-- REQUEST BODY
        if (!String.isEmpty(body)) {
            req.setBody(body);
            system.debug(LoggingLevel.INFO, 'Sending Payload: ' + body);
        }

        //-- RETURN REQUEST
        return req;
    }

    /**
     * Sends a request.
     *
     * @param request {@code HttpRequest}
     * @return {@code String}
     */
    protected String sendRequest(final HttpRequest request) {
        //-- Prevalidations
        if (request == null) throw new ORG_AbstractRestClientException('"request" is null.');

        if (Limits.getLimitCallouts() - Limits.getCallouts() < 1)
            throw new ORG_AbstractRestClientException('Callout limit reached within this thread.');

        //-- Send request
        //Http
        final Http http = new Http();
        try {
            //Send request
            final HTTPResponse response;

            if (authenticationMethod == 'Managed') {
                response = http.send(request);            
            } else{
                if (authenticationMethod == 'Marketing'){
                    // MMV: COMENTADO PARA EVITAR DEPENDENCIAS
                    //response = authMK.sendRequest(request);        
                }            
                else {
                    response = auth.sendRequest(request);
                }                 
            }            

            lastResponse = response;

            System.debug('sendRequest, request: ' + request.getMethod() + ', response: ' + response.getStatus() );
            
			//-- Check result
            //Response is null
            if (response == null) throw new ORG_AbstractRestClientException('"response" is null.');          


            //Valid response
            else if ((response.getStatusCode() == 200 && response.getStatus() == 'OK') ||
                    (response.getStatusCode() == 201 && response.getStatus() == 'Created') ||
                    (response.getStatusCode() == 202 && response.getStatus() == 'Accepted')) {
                system.debug(System.LoggingLevel.INFO, 'Callout response: '+response.getBody());
                return response.getBody();
            }

            //Response seems NO VALID
            else {
                /*throw new ORG_AbstractRestClientException(
                        'Something went wrong. Status: ' + response.getStatus() +
                                ' Code: ' + response.getStatusCode() + ' Message: ' + response.getBody()
                );*/
                system.debug(LoggingLevel.ERROR, 'Something went wrong. Status: ' + response.getStatus() +
                                                 ' Code: ' + response.getStatusCode() + 
                                                 ' Message: ' + response.getBody());
                return response.getBody();
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            throw new ORG_AbstractRestClientException(e);
        }
    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class ORG_AbstractRestClientException extends Exception {}
}