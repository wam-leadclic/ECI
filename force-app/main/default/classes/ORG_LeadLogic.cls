/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         17/05/2018
* @group        Case
* @description  Logic class for the Lead entity
                AUTHOR            DATE       Reason
* @Revision     SER-Leadclic      15/10/21   Validate if CESS_Scoring__c is null, if it's not null, then don't change order__c
                JLQ-Leadclic      20/01/22   Add temporary duplicates based on the phone
                MMV - LCS         21/03/22   Cambios en el modelo de datos y refactorización
				JLQ-Leadclic      22/03/22   Add Sevilla Exception
				MPS-Leadclic 	  17/06/22	 Se ha añadido en el metodo Send CTRL, que se llama justo despues de la creación de un lead la 
												comprobacion que si tiene el campo asociarLeadLlamada__c a true, relacione la tarea de telefonía actual del agente con el lead.
                MMV - LCS         02/09/22   Se quita de esta clase la funcionalidad de asignación de la tarea
                MMV - LCS         28/11/22   Se añade el método para invocar el borrado del registro (si lo hay) en CTI
**********************************************************************************/
public with sharing class ORG_LeadLogic {

    //-- CONSTANTS
    private static final Integer BATCH_FUTURE_CALL = 45;
    private static final Integer PLATFORM_FUTURE_CALL = 20;
    private static final String CESS_CTI_FRONTCODE = ORG_AppSettingsUtils.getSetting('CESS_CTI_FRONTCODE');
    
    //-- ATTRIBUTES

    //-- CONSTRUCTORS
    /**
     * @description Enforce non-instantiability.
     */
    private ORG_LeadLogic() {
        throw new ORG_LeadLogicException('This class cannot be instantiated.');
    }

    //-- PUBLIC METHODS  
    /**
     * @description Cuando se pasa a gestionado un CM CTI, lanza una llamada a Genesys para borrar el registro con esos datos (si lo hay)
     * @param List <Id> Listado de identificadores de MC gestionados cuyo Lead o Cliente hay que mandar para borrar
     * @return 
     */
    @future (callout = true)
    public static void deleteRecordCTI (List <Id> lGestionadoCTIId){

        // Inicializa el request
        CESS_BulkifiedCTIRequestDto.DeleteCalls request = new CESS_BulkifiedCTIRequestDto.DeleteCalls();
        CESS_BulkifiedCTIRestClient client;
        CESS_BulkifiedCTIResponseDto.DeleteCalls deletionResponse;
        // Mapa para los gestionados por Lead o ContactId
        Map <String,AMCM__c> mLeadIdContactIdAMCM = new Map <String,AMCM__c>();
        // Mapa para los AMCM a actualizar
        Map <Id,AMCM__c> mAMCM2Upd = new Map <Id,AMCM__c>();
        // Tamaño del campo CTIError
        Schema.DescribeFieldResult describeCTIError = AMCM__c.CTIError__c.getDescribe();

        // Itera para rellenar el mapa de Gestionados por su Lead o Contact Id
        for(AMCM__c gest : [SELECT Id,Lead__c, Contact__c, CTIError__c, SFCampaign__r.Name FROM AMCM__c WHERE Id IN : lGestionadoCTIId]) {
            if( gest.Lead__c != null ) mLeadIdContactIdAMCM.put(gest.Lead__c,gest);
            if( gest.Contact__c != null ) mLeadIdContactIdAMCM.put(gest.Contact__c,gest);
        }

        // Itera los registros recibidos y para cada uno monta el request y lo añade a la lista
        for(String key : mLeadIdContactIdAMCM.keyset()) {
           
            AMCM__c gest = mLeadIdContactIdAMCM.get(key);
            
            // Request para borrar registros para ese Lead
            if( key.left(3) == '00Q' ){
                CESS_BulkifiedCTIRequestDto.RequestDeleteContact ric = new CESS_BulkifiedCTIRequestDto.RequestDeleteContact();
                ric.values.add(gest.Lead__c);
                ric.columns.add('external_id');
                ric.front_code = CESS_CTI_FRONTCODE;
                ric.column_filter = 'external_id';
                ric.campaign_name = gest.SFCampaign__r.Name;
                request.requestDeleteContactList.add(ric);
            }
            // Request para borrar registros para ese Contacto
            if( key.left(3) == '003' ){
                CESS_BulkifiedCTIRequestDto.RequestDeleteContact ric = new CESS_BulkifiedCTIRequestDto.RequestDeleteContact();
                ric.values.add(gest.Contact__c);
                ric.columns.add('external_id');
                ric.front_code = CESS_CTI_FRONTCODE;
                ric.column_filter = 'external_id';
                ric.campaign_name = gest.SFCampaign__r.Name;
                request.requestDeleteContactList.add(ric);
            }
        }
   
        try{
             client = new CESS_BulkifiedCTIRestClient();
             deletionResponse = client.deleteCalls(request);            
        } catch (Exception e) {} 

        // Analizamos la respuesta del borrado y añadimos el log al campo
        if( deletionResponse != null && deletionResponse.response != null && deletionResponse.response.results != null ){

            for (String resultsMsg: deletionResponse.response.results) {
                Map<String, String> resultsMsgMap = parseResultToken(resultsMsg);
                if (resultsMsgMap.size() > 0 && resultsMsgMap.get('EXT_ID') <> null){
                    String leadContactId = resultsMsgMap.get('EXT_ID');
                    AMCM__c gest = new AMCM__c();
                    gest = mLeadIdContactIdAMCM.get(leadContactId);
                    if (String.isBlank(gest.CTIError__c)) gest.CTIError__c = '';

                    // Generamos los mensajes de OK o Error y se añaden al campo CTIError 
                    if ( resultsMsgMap.get('STATUS') == 'OK' ) {                                        
                        // Actualizamos el mensaje de error y el campo de error
                        String newCTIError = gest.CTIError__c + ' *OK DLT GEST ' + leadContactId + ' ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss','Europe/Paris');                    
                        if( newCTIError.length() <= describeCTIError.getLength() ) gest.CTIError__c = newCTIError;
                    }else{
                        // Actualizamos el mensaje de error y el campo de error
                        String newCTIError = gest.CTIError__c + ' *ERROR DLT GEST: ' + leadContactId + ' ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss','Europe/Paris') + ': ' + resultsMsgMap.get('MESSAGE');              
                        if( newCTIError.length() <= describeCTIError.getLength() ) gest.CTIError__c = newCTIError;
                    }
                    // Se añadel el CM al mapa para actualizar
                    mAMCM2Upd.put(gest.id,gest);
                }
            }

        }

        try {
            update mAMCM2Upd.values();
        } catch (Exception e) {}
        
    }

    /**
     * @description Parsea la respuesta del servicio de WSO2
     * @param String resultado del servicio de WSO2
     * @return Map<String, String> Mapa con cada resultado por separado
     */
    private static Map<String, String> parseResultToken(String token) {
        try{
            Map<String, String> ret = new Map<String, String>();

            String statusString = token.substring(0, token.toUpperCase().indexOf('EXTERNAL_ID'));
            ret.put('STATUS', statusString.toUpperCase().contains('OK')?'OK':'ERROR');

            String val = token.substring(token.toUpperCase().indexOf('EXTERNAL_ID') + 12);

            if ( val.length() >= 18 ) {
                val = val.substring(0,18);
            }

            ret.put('EXT_ID', val);

            val = token.substring(token.indexOf(val)+19);

            ret.put('MESSAGE', val);

            return ret;
        }catch(Exception e) {
            return new Map<String, String>();
        }
    }



    
    /* Comentamos esta parte porque ya no sirve, no se usa
    public static void sentCTI_crl (List <Id> leadIds){
    
        Integer i = 0;
        List <Id> lstSendLead = new List <Id>();

        //execute the future callout
        for (Id ldid:leadIds){
            lstSendLead.add(ldid);
            if ( i<(BATCH_FUTURE_CALL-1) ){
                i++;                
            }else{
                i=0;
                System.debug('SentCTI_crl: mandamos primer batch ' + lstSendLead.size() + ' a Future Callout');
                controlCRL(lstSendLead);
                lstSendLead.clear();
            }
        }
        
        if (i>0){
                i=0;
                System.debug('SentCTI_crl: mandamos resto de batch ' + lstSendLead.size() + ' Future Callout');
                controlCRL(lstSendLead);            
        }
    }

    // The callout method. Control the CRL process and update the necessary flags to continue the CTI sent process
    // The maximum leads size is BATCH_FUTURE_CALL
    @future (callout = true)
    public static void controlCRL (List <Id> leadId){//método para lista de leads
               
        List < Lead >  lstOfLead = [SELECT Id,crl_ok__c,MobilePhone,Email,
                                    identifier_aneto__c,identifier_cess__c,
                                    document_number__c,document_type__c,Phone,gender__c,
                                    businesslines_prohibited__c,age__c,CRLError__c,managements_cess__c,
                                    businesslines_contracted__c
                                    FROM Lead WHERE Id IN :leadId];
                                    

        if ( !lstOfLead.isEmpty() ){

            for (Lead ld:lstOfLead){   

                if ( String.isBlank(ld.Phone) && String.isBlank(ld.Email) && String.isBlank(ld.MobilePhone) ){
                    // NUNCA SE EJECUTA, PORQUE NO ES POSIBLE INSERTAR UN LEAD SIN PHONE NI MOBILE PHONE
                    ld.CRLError__c = String.isBlank(ld.CRLError__c) ? '' : ld.CRLError__c;
                    ld.CRLError__c += '*controlCRL: Lead sin datos de contacto.*';                    
                    ld.crl_ok__c = false;
                }else{

                    Map <String,String> myContactListMap = new Map<String,String>();    
                    myContactListMap.put('A0T0',ld.Phone);
                    myContactListMap.put('A3E0',ld.Email);
                    myContactListMap.put('A1M0',ld.MobilePhone);

                    //call CRL service and wait the answer.
                    List<CESS_ConsultaRapidaResponseDto> responseCRL;

                    responseCRL = getCRLRecords(ld.document_type__c, ld.document_number__c, myContactListMap, ld.identifier_cess__c, ld.identifier_aneto__c);

                    if( responseCRL.size() == 1 ){
                        if( getErrorCRLResponse(responseCRL[0].error_message) || getErrorCRLResponse(responseCRL[0].message) ){
                            ld.CRLError__c = String.isBlank(ld.CRLError__c) ? '' : ld.CRLError__c;
                            if (responseCRL[0].error_message != null){
                                ld.CRLError__c += '*controlCRL: ' + responseCRL[0].error_message + '*';
                            }
                            if (responseCRL[0].message != null){
                                ld.CRLError__c += '*controlCRL: ' + responseCRL[0].message + '*';
                            }
                        }else{
                            
                            // Completamos la información en el Lead
                            ld.managements_cess__c = getBooleanTypeValue(responseCRL[0].tasks);
                            for (Integer i=0; i < responseCRL[0].line_signed.size(); i++ ){
                                if (ld.businesslines_contracted__c == null){
                                    ld.businesslines_contracted__c = responseCRL[0].line_signed[i].insurance_description.normalizeSpace();
                                }else{
                                    ld.businesslines_contracted__c += ', ' + responseCRL[0].line_signed[i].insurance_description.normalizeSpace();
                                }
                            }
                            if (!String.isBlank(responseCRL[0].age)){
                                ld.age__c = decimal.valueOf(responseCRL[0].age);
                            } 
                            ld.gender__c = geGenderTypeValue(responseCRL[0].gender);
                            ld.identifier_cess__c = responseCRL[0].cess_identifier;
                            ld.identifier_aneto__c = responseCRL[0].aneto_identifier;
                            if (responseCRL[0].line_forbidden.size() > 0){
                                ld.businesslines_prohibited__c = responseCRL[0].line_forbidden[0];                
                            }
                        }
                    }else{
                    //if callout get 0 or more than 1 record, complete the error field if it's necessary
                        if (getErrorCRLResponse(responseCRL[0].message)){
                            ld.CRLError__c = String.isBlank(ld.CRLError__c) ? '' : ld.CRLError__c;
                            ld.CRLError__c += '*controlCRL: ' + responseCRL[0].message + ' *';
                        }else{
                            ld.CRLError__c = String.isBlank(ld.CRLError__c) ? '' : ld.CRLError__c;
                            ld.CRLError__c += '*controlCRL: Imposible Identificar cliente único*';                            
                        }
                    } 
                    ld.crl_ok__c = true;                    
                }
            }//end for

            try{
                update lstOfLead;
            }catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }
        }
    }
    
    
  @AuraEnabled
    public static List<CESS_ConsultaRapidaResponseDto> getCRLRecords(final String document_type,
                                                                     final String document_number, 
                                                                     final Map<String,String> contact_list, 
                                                                     final String identifier_cess,
                                                                     final String identifier_aneto) {

        CESS_ConsultaCESSDto.ConsultaRapidaResponse leadOperationResponse;
        try {
            //-- no es necesario, viene de parámetros.   Map<String, String> myMap = new Map<String, String>();
            leadOperationResponse = CESS_ConsultaCessRestClient.getInstance().consultaRapidaLead('CRL',document_type,document_number,contact_list,identifier_cess,identifier_aneto);
        } catch(Exception e) {
           	return new List<CESS_ConsultaRapidaResponseDto>{ new CESS_ConsultaRapidaResponseDto(e.getMessage() )};
        }

        if (leadOperationResponse <> null) {
            if (leadOperationResponse.crlcustomer_rating[0].return_code == 'KO'){
                // No lanzo el error para que continúe mientras se ejecuta en servidor. Si necesito visualizar estos
                // campos en la interfaz, para que el browser se entere del error tendría que lanzar la excepción.
                // throw new ORG_LeadLogicException(leadOperationResponse.crlcustomer_rating[0].error_message);
                
                return leadOperationResponse.crlcustomer_rating; 
            }else{
                return leadOperationResponse.crlcustomer_rating; //consultaRapidaResults;
            }
        }
        else {
            return new List<CESS_ConsultaRapidaResponseDto>{ new CESS_ConsultaRapidaResponseDto('CRL return null' )};
        }
    }
    */

  @AuraEnabled
    public static List<CESS_ConsultaPolizasResponseDto> getCESSPolicyRecords(final String identifier_cess,
                                                                            final String identifier_aneto) {

        CESS_ConsultaCESSDto.ConsultaPolizasResponse polizasResponse;
        try {
            polizasResponse = CESS_ConsultaCessRestClient.getInstance().consultaPolizas('DP',identifier_cess,identifier_aneto);
        } catch(Exception e) {
           	return null;
        }

        if (polizasResponse <> null) {
            
            if  (getErrorCRLResponse(polizasResponse.dppolicy[0].error_message) || getErrorCRLResponse(polizasResponse.dppolicy[0].message)){
                polizasResponse.dppolicy[0].return_code = 'KO';
                //throw new ORG_LeadLogicException(polizasResponse.dppolicy[0].error_message);
                return new List<CESS_ConsultaPolizasResponseDto>{polizasResponse.dppolicy[0]};
            }else{
                return polizasResponse.dppolicy; 
            }
        }
        else {
            return new List<CESS_ConsultaPolizasResponseDto>();
        }
    }


  @AuraEnabled
    public static List<CESS_ConsultaGestionesResponseDto> getDGRecords(final String identifier_cess,
                                                                            final String identifier_aneto) {

        CESS_ConsultaCESSDto.ConsultaGestionesResponse gestionesResponse;

        try {
            gestionesResponse = CESS_ConsultaCessRestClient.getInstance().consultaGestiones('DG',identifier_cess,identifier_aneto);
       } catch(Exception e) {
           	return null;
        }
        if (gestionesResponse <> null) {

            if  (getErrorCRLResponse(gestionesResponse.dgcustomer_management[0].error_message) || getErrorCRLResponse(gestionesResponse.dgcustomer_management[0].message)){
                gestionesResponse.dgcustomer_management[0].return_code = 'KO';
                return new List<CESS_ConsultaGestionesResponseDto>{gestionesResponse.dgcustomer_management[0]};
            }else{
                return gestionesResponse.dgcustomer_management; //consultaGestionesResults;
            }
        }else {
            return new List<CESS_ConsultaGestionesResponseDto>();
        }
    }

  @AuraEnabled
    public static CESS_ctiResponseDto replanificaLlamadaCTI (Task ts) {
        
        final String CESS_CTIPLAN_ORDER = ORG_AppSettingsUtils.getSetting('CESS_CTIPLAN_ORDER'); 
        final String CESS_CTIPLAN_SKILL = ORG_AppSettingsUtils.getSetting('CESS_CTIPLAN_SKILL'); 

        // Query Opp 
        Opportunity theOpp = [SELECT opportunity_number__c,CTI_Campaign__c FROM Opportunity 
                             WHERE Id = :ts.WhatId LIMIT 1];

        if (theOpp == null){
            return new CESS_ctiResponseDto();  //no hay registros.
        }

        CESS_ConsultaCTIDto.ctiResponse ctiResponse;

        try {

            String sched_time = ((Datetime)ts.CESS_Fecha_Planificada__c).format('yyyy-MM-dd HH:mm:ss');
            String tlf = ts.Account.PersonMobilePhone == null ? ts.Account.Phone : ts.Account.PersonMobilePhone;

            List <String> columns = new List <String>{'external_id','lead_number','order_number','skills','source_datetime','tel_contact1'};
            List <String> values = new List <String>{ts.Id,theOpp.opportunity_number__c,CESS_CTIPLAN_ORDER,CESS_CTIPLAN_SKILL,sched_time,tlf};
            
            //String en este orden: agent_id, phone_number, sched_time
            List <String> sched = new List <String>{ts.owner_ctiuser__c == null ? '' : ts.owner_ctiuser__c,tlf,sched_time};
      
            ctiResponse = CESS_ConsultaCTIRestClient.getInstance().replanificaLlamada(columns, values, sched, theOpp.CTI_Campaign__c);
       } catch(Exception e) {
           	return new CESS_ctiResponseDto();
        }
        if (ctiResponse <> null) {
            return ctiResponse.error; 
        }
        else {
            return new CESS_ctiResponseDto();
        }
    }


   /**
     * @description Retrieves the Lead information about acccount.
            The search order is 
                1.-Id Cess
                2.-Id Aneto
                3.- Nif
                4.- tlf + email
     * @param Document Number, Id cess, Id aneto, email, Mobile Phone and Phone.
     * @return The account Id. 
     */
  @AuraEnabled
    public static String getAccountId (String nif, String cessId, String anetoId, String email, String mphone, String phone) {

        //General variables
        String fields = 'Id';
        String sobjectApiName = 'Account';
        String relatedFieldApiName = '';

        //construct where clause
        if (String.isNotBlank(cessId)){
            relatedFieldApiName = 'identifier_cess__pc=:cessId';
        }else{
            if (String.isNotBlank(anetoId)){
                    relatedFieldApiName = 'identifier_aneto__pc=:anetoId';
            }else {
                if (String.isNotBlank(nif)){
                    relatedFieldApiName = 'personal_document__pc=:nif';
                }else {
                    if (String.isNotBlank(email)){
                        relatedFieldApiName = relatedFieldApiName+' PersonEmail=:email';
                    }
                    if (String.isNotBlank(mphone)){
                        if (String.isNotBlank(relatedFieldApiName)){
                            relatedFieldApiName = relatedFieldApiName+' OR PersonAssistantPhone=:mphone';
                        }else{
                            relatedFieldApiName = relatedFieldApiName+'PersonAssistantPhone=:mphone';
                        }
                    }
                    if (String.isNotBlank(phone)){
                        if (String.isNotBlank(relatedFieldApiName)){
                            relatedFieldApiName = relatedFieldApiName+' OR Phone=:phone';
                        }else{
                            relatedFieldApiName = relatedFieldApiName+'Phone=:phone';
                        }
                    }
                }
            }
        }

        if (String.isBlank(relatedFieldApiName)){
                return '';  //no tenemos criterios de búsqueda
        }

        String squery = 'Select '+fields+' From '+sobjectApiName+' WHERE ' +relatedFieldApiName;  

        List <Account> lstOfAcc = new List <Account>();
        try {
            lstOfAcc = Database.query(squery);
        } catch (Exception e) {
            throw new ORG_LeadLogicException('SOQL query exception: '+e.getMessage());
        }

        if (lstOfAcc.isEmpty() || lstOfAcc.size() > 1){
            return '';  //no hay registros o devuelve más de 1 cliente.
        }else{
            return (String)lstOfAcc[0].Id;
        }
 
    }

    /**
     * @description Sends an Email and records its transaction
     * @param leadId {Id} the Id of the record in context 
     * @return 
     */
    public static void sendEmail (final Id leadId, final String fromAddress, final String emailTemplateName) {

        // Query Lead in context
        Lead theLead = [SELECT Id, Email FROM Lead WHERE Id = :leadId LIMIT 1];

        // Email Template (developer name)
        final Id emailTemplate = ORG_EmailUtils.getEmailTemplateFromName(emailTemplateName);

        // Declare Email
        final Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate, leadId, null);

        //Optional/not needed
        //email.setWhatId(leadId);
        email.setSubject(email.getSubject());
        email.setHtmlBody(email.getHtmlBody());
        //email.setTargetObjectId(UserInfo.getUserId());
        email.setTargetObjectId(LeadId);
        //email.setTreatTargetObjectAsRecipient(false);

        //Save as activity
        email.setSaveAsActivity(true);

        //To Addresses
        email.setToAddresses(new List<String>{theLead.Email});

        //From Address
        if (fromAddress <> null) {
            email.setOrgWideEmailAddressId(ORG_EmailUtils.getOrgWideEmailAddrrIdFromName(fromAddress));
        }
        else {
            email.setReplyTo(UserInfo.getUserEmail());
            email.setSenderDisplayName(UserInfo.getName());
        }

        // Other configs
        email.setBccSender(false);
        email.setUseSignature(false);

        // Perform sending
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

 @AuraEnabled
    public static String getDocumentTypeValue (String value){
        switch on value {
            when 'A001'{
                return 'NIF';
            }
            when 'C003'{
                return 'NIE';
            }
            when 'F006'{
                return 'PASSPORT';
            }
            when 'E005'{
                return 'CIF';
            }
            when 'Pasaporte'{
                return 'PASSPORT';
            }
            when else{
                return value;
            }
        }
    }

 @AuraEnabled
    public static String getCESSDocumentTypeValue (String value){
        switch on value {
            when 'NIF'{
                return 'A001';
            }
            when 'NIE'{
                return 'C003';
            }
            when 'PASSPORT'{
                return 'F006';
            }
            when 'Pasaporte'{
                return 'F006';
            }
            when 'CIF'{
                return 'E005';
            }
            when else{
                return value;
            }
        }
    }
 @AuraEnabled
    public static Boolean getBooleanTypeValue (String value){
            switch on value {
            when 'S'{
                return true;
            }
            when else{
                return false;
            }
        }
    }

    /**
     * @description Return true if find error on the CTI response
     * @param the message of the ctiresponse object 
     * @return true if the message is an error.
     */
@AuraEnabled
    public static Boolean getErrorCtiResponse (String value){
        return value == null || value != 'Processed correctly' ? true : false;
    }

@AuraEnabled
    public static Boolean getErrorCRLResponse(String value){
        System.debug('getErrorCRLResponse.value: ' + value);
        if ( value != null && value != 'Processed correctly' ){
            System.debug('getErrorCRLResponse.return   TRUE ');
            return true;
        }else{
            System.debug('getErrorCRLResponse.return   FALSE ');
            return false;
        } 
    }
    

    /* Comentamos estos métodos porque ya no se usan
 @AuraEnabled
    public static String geGenderTypeValue (String value){
            switch on value {
            when 'V'{
                return 'MALE';
            }
            when 'M'{
                return 'FEMALE';
            }
            when else{
                return '';
            }
        }    
    }
    */

    //-- PRIVATE METHODS

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class ORG_LeadLogicException extends Exception {}
    
}