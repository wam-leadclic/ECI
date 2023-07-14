/********************************************************************************** 
* @author       Francisco José Pérez - franciscojose.perez@salesforce.com
* @date         17/06/2019
* @group        Integrations
* @description  Handler for the CTI integration
* @Revision
**********************************************************************************/
public class CESS_InsertCTIIntegrationHandler implements ORG_IIntegrationHandler {

    //--CONSTANTS
    public static final String CESS_CTI_SYSTEM = 'CESS-CTI';

    //-- INTEGRATION HANDLER METHODS
    /** {@inheritDoc} */
    public void handleEvent(ORG_Integration_Event__e event) {

    System.debug('CESS_InsertCTIIntegrationHandler: Id a mandar a CTI ' + event.Object_Id__c);

    	if (event.Object_Id__c == null)
    		throw new CESS_InsertCTIIntegrationHandlerException('Can´t locate element that fired the event.');

    	List<Lead> lead = new List<Lead>();
    	try {
    		lead = [SELECT Id,campaign_cti__c,crl_ok__c,source_type__c,sent_cti__c,line_insurance__c,
                            campaign_cess__c, MobilePhone,Email,Phone,managements_sf__c,identifier_aneto__c,identifier_cess__c,
                            document_number__c,cti_error__c,lead_number__c,order__c,skill__c,source_datetime__c,
                            age__c,is_customer__c,managements_cess__c,gender__c,businessline_prohibited__c,
                            businessline_contracted__c,risk_postalcode__c,source_cess__c,cti_username__c,schedulecontact_datetime__c
                     FROM Lead 
                     WHERE Id = :event.Object_Id__c 
                     LIMIT 1];
    	} catch (Exception e) {
    		throw new CESS_InsertCTIIntegrationHandlerException('SOQL query exception: '+e.getMessage());
    	}

        System.debug('CESS_InsertCTIIntegrationHandler: Lead consultado vacío. ' + lead.isEmpty());

    	if (lead.isEmpty())
    		throw new CESS_InsertCTIIntegrationHandlerException('Can´t locate sobject related to event.');
    	else {

    		Lead sentLead = lead[0];

            CESS_ConsultaCTIDto.ctiResponse ctiResponse;

            //1.- fill the necessary information
            /*

            obligatorios del servicio cti.

            front_code    //relleno en DTO
            column_filter  //relleno en DTO

            campaign_name  campaign_cti__c

            columns fields
                Required string lead_Number,      lead_number__c , opportunity_number__c
                Required integer order_number,     order__c
                Required string skills,             skill__c
                Required datetime source_datetime,   source_datetime__c
                Required string tel_contact1        Phone, MobilePhone

                Optional string age,                age__c
                Optional string cess_campaign,    campaign_cess__c
                Optional string cess_customer,     is_customer__c
                Optional string cess_tasks,         managements_cess__c
                Optional string channel,            source_type__c
                Optional string crm_task,          managements_sf__c
                Optional string gender,             gender__c
                Optional string insurance_line,    line_insurance__c
                Optional string line_forbidden,    businessline_prohibited__c
                Optional string line_signed,      businessline_contracted__c
                Optional string postal_code,     risk_postalcode__c
                Optional string source,           source_cess__c   
                Optional string tel_contact2,      Phone, MobilePhone
                Optional string zone 



                [CAMPOS OBLIGATORIOS]     
                - leadNumber string (256) - Identificador de cliente en Salesforce
                - leadInsertDate string (256) - Fecha de inserción de cliente
                - order string (256) - Orden
                - skills string (256) - Skills del cliente

                [CAMPOS OPCIONALES]   
                - source [optional] string (256) - Origen
                - means [optional] string (256) - Medio
                - branch [optional] string (256) - Ramo
                - isClient [optional] string (1) - Cliente CESS tenga o no pólizas (Y/N)
                - isExistingBranch [optional] string (1) - Ramo existente (Y/N)
                - isForbiddenBranch [optional] string (1) - Ramo prohibido (Y/N)
                - isExistingCESSIssues [optional] string (1) - Tiene gestiones CESS (Y/N)
                - isExistingSFIssues [optional] string (1) - Tiene gestiones Salesfoce (oportunidades abiertas) (Y/N)
                - age [optional] string (256) - Edad del cliente
                - gender [optional] string (256) - Sexo del cliente
                - postalCode [optional] string (256) - Código postal
                - campaignCESS [optional] string (256) - Campaña CESS

            */

            String campaign_name = '';

            List <String> columns = new List <String>();
            List <String> values = new List <String>();
      
            //required

            System.debug('intHandler: campaign_name: ' + sentLead.campaign_cti__c + ', source_datetime__c: ' + sentLead.source_datetime__c);
            campaign_name = sentLead.campaign_cti__c == null ? '' : sentLead.campaign_cti__c;
            System.debug('intHandler: campaign_name: ' + campaign_name);

            columns.add('external_id');
            values.add(sentLead.Id);
            columns.add('lead_Number');
            values.add(sentLead.lead_number__c);
            columns.add('order_number');
            values.add(string.valueOf(sentLead.order__c));
            columns.add('skills');
            values.add(sentLead.skill__c);
            columns.add('source_datetime');
            values.add( sentLead.source_datetime__c == null ? datetime.now().format('yyyy-MM-dd HH:mm:ss') : ((Datetime)sentLead.source_datetime__c).format('yyyy-MM-dd HH:mm:ss') );
            if (sentLead.MobilePhone != null){
                columns.add('tel_contact1');
                values.add(sentLead.MobilePhone);
            }else {
                columns.add('tel_contact1');
                values.add(sentLead.Phone); 
            }
            //optional
            if (sentLead.age__c != null){
                columns.add('age');
                values.add(string.valueOf(sentLead.age__c));
            }
            if (sentLead.campaign_cess__c != null){
                columns.add('cess_campaign');
                values.add(string.valueOf(sentLead.campaign_cess__c));
            }
            columns.add('cess_customer');
            values.add(sentLead.is_customer__c ? 'Y' : 'N');
            columns.add('cess_tasks');
            values.add(sentLead.managements_cess__c ? 'Y' : 'N');
            columns.add('crm_tasks');
            values.add(sentLead.managements_sf__c ? 'Y' : 'N');
            columns.add('line_forbidden');
            values.add(sentLead.businessline_prohibited__c ? 'Y' : 'N');
            columns.add('line_signed');
            values.add(sentLead.businessline_contracted__c ? 'Y' : 'N');
            if (sentLead.source_type__c != null){
                columns.add('channel');
                values.add(string.valueOf(sentLead.source_type__c));
            }
            if (sentLead.gender__c != null){
                columns.add('gender');
                values.add(string.valueOf(sentLead.gender__c));
            }
            if (sentLead.line_insurance__c != null){
                columns.add('insurance_line');
                values.add(string.valueOf(sentLead.line_insurance__c));
            }
            if (sentLead.risk_postalcode__c != null){
                columns.add('postal_code');
                values.add(string.valueOf(sentLead.risk_postalcode__c));
            }
            if (sentLead.source_cess__c != null){
                columns.add('source');
                values.add(string.valueOf(sentLead.source_cess__c));
            }
            if (sentLead.MobilePhone != null){ //phone informed on tlf1
                if (sentLead.Phone != null){
                    columns.add('tel_contact2');
                    values.add(sentLead.Phone);
                }
            }
            //no definido
            //columns.add('zone');
            //values.add(sentLead.zone);

            System.debug('CESS_InsertCTIIntegrationHandler: Mandando a CTI: ' + values.size() + ' Lista: ' + values);

    		// 2.- Perform callout
    		try {

                if (sentLead.schedulecontact_datetime__c != null){
                    String sched_time = ((Datetime)sentLead.schedulecontact_datetime__c).format('yyyy-MM-dd HH:mm:ss');
                    //String en este orden: agent_id, phone_number, sched_time
                    List <String> sched = new List <String>{sentLead.cti_username__c == null ? '' : sentLead.cti_username__c,sentLead.MobilePhone == null ? (sentLead.Phone == null ? '' : sentLead.Phone) : sentLead.MobilePhone,sched_time};
                    System.debug('Lead Planificado. Id: ' + sentLead.Id + ' cti_username__c: ' + sentLead.cti_username__c);
                    ctiResponse = CESS_ConsultaCTIRestClient.getInstance().insertarLeadPlanificado(columns,values,sched,null);
                }else{
                    ctiResponse = CESS_ConsultaCTIRestClient.getInstance().insertarLeadCampana(campaign_name,columns,values);
                }

    		} catch (Exception e) {
                system.debug(LoggingLevel.ERROR,'CESS_InsertCTIIntegrationHandler Exception: '+e.getMessage());
    		    leadIntegrationFailAck(sentLead);
    		}

            System.debug('Respuesta CESS_InsertCTIIntegrationHandler.ctiResponse: ' + ctiResponse);

			// 3.- Update lead when succeed, throw an exception otherwise 
            Lead oLead = new Lead (id=sentLead.Id);
            if (!ORG_LeadLogic.getErrorCtiResponse(ctiResponse.error.message)) {
                if (String.isBlank(oLead.cti_error__c)) oLead.cti_error__c = '';
				//oLead.cti_error__c = '*Integración CTI realizada*';
                oLead.crl_ok__c = false;
                oLead.sent_cti__c = true;
				update oLead;
			}else{
                // Update Lead Integration Status
                if (String.isBlank(oLead.cti_error__c)) oLead.cti_error__c = '';
                oLead.cti_error__c += '*Error envío CTI: Integración CTI fallida: ' + ctiResponse.error.message + '*';
                oLead.crl_ok__c = false;
                oLead.sent_cti__c = false;
                update oLead;
                insert ORG_IntegrationLogLogic.createIntegrationLog(sentLead.Id,'','CESS-CTI',JSON.serialize(ctiResponse),1,
                                                                    'CESS_InsertCTIIntegrationHandler',getLogValues(event));
            }
    	}
    }
    
    /** {@inheritDoc} */
    public Map<String,Object> getLogValues(ORG_Integration_Event__e event) {
        Map<String,Object> values = new Map<String,Object>();

//esto que es? case? funciona con null. creado el lookup en "IntegrationLog__c" pero no lo pilla
    //    values = new Map<String,Object> { SObjectType.IntegrationLog__c.fields.case__c.name => event.Object_Id__c};
    //    values = new Map<String,Object> { SObjectType.IntegrationLog__c.fields.Lead__c.lead_number__c => event.Object_Id__c};

        return values;
    }

    //-- PRIVATE METHODS
    /**
     * It manages the case when an error occured
     */
    private void leadIntegrationFailAck(final Lead sentLead) {
		// Update Case Integration Status
        if (String.isBlank(sentLead.cti_error__c)) sentLead.cti_error__c = '';
		sentLead.cti_error__c += '*Error envío CTI: Integración CTI fallida*';
        //no enviamos mas por el process
        sentLead.send_cti__c = false; 
        sentLead.crl_ok__c = false;
        update sentLead;
		// Throw exception for the integration handler to retry later
		throw new CESS_InsertCTIIntegrationHandlerException('Integration CTI failed.');
    }
    
    public class CESS_InsertCTIIntegrationHandlerException extends Exception {}
}