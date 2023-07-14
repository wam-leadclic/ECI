/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         23/04/2020
* @description  The bulkified CTI Client implementation for all methods
* @Revision		SER   10/01/2022    updateUnscheduledCalls method created in order to update the opp and lead status to 'U'
* @Revision		JLQ   22/04/2022    add updateCampaignCalls method
**********************************************************************************/
public class CESS_BulkifiedCTIRestClient extends ORG_AbstractRestClient implements CESS_BulkifiedCTIClient{
    
    //-- CONSTANTS
    private static final String CESS_CTI_DELETE_RESOURCE = ORG_AppSettingsUtils.getSetting('CESS_CTI_DELETE_GENERAL_RESOURCE');
    private static final String CESS_CTI_CONSULTAGENERAL_RESOURCE = ORG_AppSettingsUtils.getSetting('CESS_CTI_GENERAL_RESOURCE');
    //private static final String CESS_CTI_CONSULTAGENERAL_RESOURCE = 'https://boiling-everglades-47292.herokuapp.com/log';
    
    public CESS_BulkifiedCTIResponseDto.InsertCampaingCalls insertCampaingCalls(CESS_BulkifiedCTIRequestDto.InsertCampaingCalls payload){
    //public CESS_BulkifiedCTIResponseDto.InsertCampaingCalls insertCampaingCalls(Object payload){ //TODO Map the correct DTO when provided
        //-- PREVALIDATIONS

        //-- HTTP REQUEST
        String resource = CESS_CTI_CONSULTAGENERAL_RESOURCE;
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.POST;

        //-- SET BODY
        final String body = payload.serialize(false);    
        
        //-- BUILD REQUEST
        resource += 'Add';

        System.debug('Llamada datos clientes resource: ' + resource);
        System.debug('Llamada datos clientes body: ' + body);

        String cad = '{"lst_contact":'+ body+'}';//FPEREZ. Add the label.

        System.debug('Llamada datos clientes modificada CAD: ' + cad);
        
        final HttpRequest request = super.buildRequest(restMethod, resource, cad);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);

       //-- PARSE & RETURN RESPONSE
        return CESS_BulkifiedCTIResponseDto.deserializeInsertCampaingCalls(responseBody);
    }

    /**
    @description Método que realiza una llamada de actualización de contactos en la contact list de Genesys
    @return Respuesta de Genesys deserializada
    */
    public CESS_BulkifiedCTIResponseDto.InsertCampaingCalls updateCampaignCalls(CESS_BulkifiedCTIRequestDto.InsertCampaingCalls payload){
        //-- PREVALIDATIONS

        //-- HTTP REQUEST
        String resource = CESS_CTI_CONSULTAGENERAL_RESOURCE;
                                                                        
        final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.PUT;

        //-- SET BODY
        final String body = payload.serialize(false);    
        
        //-- BUILD REQUEST
        resource += 'Update';

        System.debug('Llamada datos clientes resource: ' + resource);
        System.debug('Llamada datos clientes body: ' + body);

        String cad = '{"lst_contact_update":'+ body+'}';//FPEREZ. Add the label.

        System.debug('Llamada datos clientes modificada CAD: ' + cad);
        
        final HttpRequest request = super.buildRequest(restMethod, resource, cad);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);

        //-- PARSE & RETURN RESPONSE
        return CESS_BulkifiedCTIResponseDto.deserializeInsertCampaingCalls(responseBody);
    }
    
    public CESS_BulkifiedCTIResponseDto.InsertScheduleCalls insertScheduleCalls(CESS_BulkifiedCTIRequestDto.InsertScheduleCalls payload){
    //public CESS_BulkifiedCTIResponseDto.InsertScheduleCalls insertScheduleCalls(Object payload){ //TODO Map the correct DTO when provided
        //-- PREVALIDATIONS

        //-- HTTP REQUEST
        String resource = CESS_CTI_CONSULTAGENERAL_RESOURCE;
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.POST;

        //-- SET BODY
        final String body = payload.serialize(false); //need to check that don't delete some fields
        //final String body = JSON.serialize(payload);
        
        //-- BUILD REQUEST
        resource += 'Add';

        System.debug('Llamada datos clientes resource: ' + resource);
        System.debug('Llamada datos clientes body: ' + body);
        
        String cad = '{"lst_contact":'+ body+'}';//FPEREZ. Add the label.

        System.debug('Llamada datos clientes modificada CAD: ' + cad);

        final HttpRequest request = super.buildRequest(restMethod, resource, cad);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);

       //-- PARSE & RETURN RESPONSE
       System.debug('Llamada datos clientes response body: ' + responseBody);

        return CESS_BulkifiedCTIResponseDto.deserializeInsertScheduleCalls(responseBody);
    }
    
    public CESS_BulkifiedCTIResponseDto.DeleteCalls deleteLeadInCTI(CESS_BulkifiedCTIRequestDto.DeleteCalls payload) {
		 //-- PREVALIDATIONS

        //-- HTTP REQUEST
        String resource = CESS_CTI_DELETE_RESOURCE;
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.PUT;

        //-- SET BODY
        final String body = payload.serialize(false);
        //final String body = JSON.serialize(payload);
        
        //-- BUILD REQUEST
       // resource += 'Delete';

        System.debug('Llamada datos clientes resource: ' + resource);

        String cad = '{"lst_contact_delete":'+ body+'}';//FPEREZ. Add the label.

        System.debug('Body Llamada datos clientes modificada CAD: ' + cad);

        final HttpRequest request = super.buildRequest(restMethod, resource, cad);

        //-- SEND REQUEST
        /*Añadido SCA*/
        system.debug('AÑADIDO SCA: ' + request);
        final String responseBody = super.sendRequest(request);

       //-- PARSE & RETURN RESPONSE
        return CESS_BulkifiedCTIResponseDto.deserializeDeleteCalls(responseBody);
    }
	public CESS_BulkifiedCTIResponseDto.DeleteCalls deleteCalls(CESS_BulkifiedCTIRequestDto.DeleteCalls payload){
        //-- PREVALIDATIONS

        //-- HTTP REQUEST
        String resource = CESS_CTI_CONSULTAGENERAL_RESOURCE;
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.PUT;

        //-- SET BODY
        final String body = payload.serialize(false);
        //final String body = JSON.serialize(payload);
        
        //-- BUILD REQUEST
        resource += 'Delete';

        System.debug('Llamada datos clientes resource: ' + resource);

        String cad = '{"lst_contact_delete":'+ body+'}';//FPEREZ. Add the label.

        System.debug('Llamada datos clientes modificada CAD: ' + cad);

        final HttpRequest request = super.buildRequest(restMethod, resource, cad);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);

       //-- PARSE & RETURN RESPONSE
        return CESS_BulkifiedCTIResponseDto.deserializeDeleteCalls(responseBody);
    }
    
    public CESS_BulkifiedCTIResponseDto.UpdateCalls updateCalls(CESS_BulkifiedCTIRequestDto.UpdateCalls payload){
        //-- PREVALIDATIONS

        //-- HTTP REQUEST
        String resource = CESS_CTI_CONSULTAGENERAL_RESOURCE;
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.PUT;

        //-- SET BODY
        final String body = payload.serialize(false);
        //final String body = JSON.serialize(payload);
        
        //-- BUILD REQUEST
        resource += 'Update';

        System.debug('Llamada datos clientes resource: ' + resource);

        String cad = '{"lst_contact_update":'+ body+'}';//FPEREZ. Add the label.

        System.debug('Llamada datos clientes modificada CAD: ' + cad);

        final HttpRequest request = super.buildRequest(restMethod, resource, cad);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);

       //-- PARSE & RETURN RESPONSE
        return CESS_BulkifiedCTIResponseDto.deserializeUpdateCalls(responseBody);
    }
    public CESS_BulkifiedCTIResponseDto.UnscheduledCalls updateUnscheduledCalls(CESS_BulkifiedCTIRequestDto.UnscheduledCalls payload){
        //-- PREVALIDATIONS

        //-- HTTP REQUEST
        String resource = CESS_CTI_CONSULTAGENERAL_RESOURCE;
                                                                       
		final RestMethod restMethod = ORG_AbstractRestClient.RestMethod.PUT;

        //-- SET BODY
        final String body = payload.serialize(false);
        //final String body = JSON.serialize(payload);
        
        //-- BUILD REQUEST
        resource += 'Update';

        System.debug('Llamada datos clientes resource: ' + resource);

        String cad = '{"lst_contact_update":'+ body+'}';//FPEREZ. Add the label.

        System.debug('Llamada datos clientes modificada CAD: ' + cad);

        final HttpRequest request = super.buildRequest(restMethod, resource, cad);

        //-- SEND REQUEST
        final String responseBody = super.sendRequest(request);

       //-- PARSE & RETURN RESPONSE
        return CESS_BulkifiedCTIResponseDto.deserializeUnscheduledUpdateCalls(responseBody);
    }
}