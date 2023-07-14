/**********************************************************************************
* @author       Javier Suárez Jiménez
* @date         06/05/2020
* @description  Helper Class with the Logic used for the integration with CTI
                AUTOR   FECHA           DESCRIPCION
                MMV     13/12/2022      Cambio para enviar, en la desplanificación de llamadas la campaña en función del campo CTI Campaign de la tarea, si no hay CM
                AMT     02/12/2022      Cambio a la hora de recoger los valores para la columna preview de la llamada. 
                MMV     30/11/2022      Cambio para registrar el log de la llamada de borrado
                MMV     28/11/2022      Cambio para marcar el campo CTIErrorCheck__c cuando haya error de cTI
                EMA     22/11/2022      Modificado el comportamiento del insert y update de tareas para miembros de campaña desde integration events.
                AMT     17/11/2022      Se controla mediante el custom metadata CESS - CTI - Envío de Opp Planificadas el planificar llamadas para las Oportunidades.
                                        Se cambia el el campo preview de la llamda para que setee desde contacto si hay una opp asociada a un contacto con el mismo ramo que el cm.
                MMV     10/11/2022      Se envía siempre CustomerNumber__c, no opportunity_number
                MMV     07/11/2022      Corrección de errores en el envío de llamadas planificadas (insertRelatedCalls)
                MMV     14/10/2022      Se añade la actualización del campo CTIError con el OK de las llamadas para usarlo de histórico de llamadas.
                MMV     27/09/2022      Se añade el parámetro status en el envío e Lead o contactos a CTI con valor S si lleva fecha y hora planificada y C si no (solo en actualización)
                MMV     05/09/2022      Se controla que si el cliente tiene un CTI Gestionado se manda actualización (si es de la misma campaña)
                MMV     01/09/2022      Se controla que si el campo schedulecontact_datetime__c del Lead es anterior a hoy no se envían esos datos
                MKB     04/08/2022      Se añade el envío de llamadas para contactos sin oportunidad
                MMV     25/05/2022      Mejora lectura de código y cambios en caso de campName vacío
                JCB     09/05/2022      insertCallsFromIntegrationEvents: Cambio de objeto consultado a CampaignMember;
                                        insertRelatedCalls: Se consulta y trabaja con los datos del CampaignMember relacionada con Lead/Opp;
                                        updateRelatedCalls: Se consulta y trabaja con los datos del CampaignMember relacionada con Lead/Opp;
                                        Para cumplir con 2.2.5 del doc. técnico
 		        SER     10/01/2022      Delete method modified in order to update the opp and lead status to 'U'
               
**********************************************************************************/
public class CESS_BulkifiedCTILogic {

    final String CESS_CTIPLAN_ORDER = ORG_AppSettingsUtils.getSetting('CESS_CTIPLAN_ORDER');
    final String CESS_CTIPLAN_SKILL = ORG_AppSettingsUtils.getSetting('CESS_CTIPLAN_SKILL');
    final String CESS_CTI_FRONTCODE = ORG_AppSettingsUtils.getSetting('CESS_CTI_FRONTCODE');
    final String CESS_CTI_COLUMNFILTER = ORG_AppSettingsUtils.getSetting('CESS_CTI_COLUMNFILTER');
    final String CESS_CTIPLAN_CAMPAIGN = ORG_AppSettingsUtils.getSetting('CESS_CTIPLAN_CAMPAIGN');
    final String CESS_CTI_ENVIOOPORTUNIDADESPLANIFICADAS = ORG_AppSettingsUtils.getSetting('CESS - CTI - Envío de Opp Planificadas');


    public void insertCallsFromIntegrationEvents(List<CESS_Integration_Event__e> events) {

        CESS_BulkifiedCTIRequestDto.InsertCampaingCalls campaingMembers = new CESS_BulkifiedCTIRequestDto.InsertCampaingCalls();
        CESS_BulkifiedCTIRequestDto.InsertCampaingCalls updateCampaingMembers = new CESS_BulkifiedCTIRequestDto.InsertCampaingCalls();

        /* ************ Añadido como solución temporal el 23.11.2022. Eliminar para restarurar la versión original ******* */
        CESS_BulkifiedCTIRequestDto.DeleteCalls deleteLegacyCampaignMembers = new CESS_BulkifiedCTIRequestDto.DeleteCalls();
        CESS_BulkifiedCTIRequestDto.RequestDeleteContact deleteRequest;
        /* *********************** Fin añadido como solución temporal el 23.11.2022 ************************************** */
		system.debug('entra******');
        // DECLARACION E INICIALIZACION DE VARIABLES
        // Set que contiene los Ids de clientes (ya sea Contacto o Lead) de los CM CTIs
        Set <Id> sIdClientes = new Set <Id> (); 
        // Mapa de Miembros de campaña CTI gestionados que se enviaron a CTI de los clientes 
        Map <String,AMCM__c> mClienteIdCampaignNameAMCMGest = new Map <String,AMCM__c>();
        // Set con  los ids de contactos asociados a los Campaing Members.
        Set<Id> contactsIds = new Set<Id>();
        // Tamaño del campo CTIError
        Schema.DescribeFieldResult describeCTIError = CampaignMember.CTIError__c.getDescribe();
        // Mapa que almacena los CMs a actualizar
        Map<Id,CampaignMember> mCM2Update = new Map<Id,CampaignMember>();
        // Listado de errores a insertar
        list<String> logsMess = new list<String>();
        //Do the callouts for both lists
        CESS_BulkifiedCTIRestClient client = new CESS_BulkifiedCTIRestClient();
        CESS_BulkifiedCTIResponseDto.InsertCampaingCalls insertCampaingResponse;
        CESS_BulkifiedCTIResponseDto.InsertCampaingCalls updateCampaignResponse;
        List<Lead> leadListToUpdate = new List<Lead>();        
        List<String> completeListOfIds = new List<String>();



        /*Campo Object_Id__c de objeto CESS_Integration_Event__e tiene Id CampaignMember*/
        Set<Id> ids = new Set<Id>();
        //Mapa con Id de Lead/Contact (external_id) y Id Miembro de campaña (Usada para despues de la inserción, actualización de estado)
        Map<Id,Id> leadContactCampaignMap = new Map<Id,Id>();
        for ( CESS_Integration_Event__e event: events ) {
            if (event.Object_Id__c != null) {
                ids.add(event.Object_Id__c);
            }
        }
        /* newVer object CampaigMember*/
        Map<ID, CampaignMember> cmsMap = new Map<ID, CampaignMember>( [SELECT Id, Campaign.Name, ContactId, LeadId, ClientOrLeadNumber__c,
                                                                        CTIOrder__c, CTISkill__c, CTIClientSkill__c, MobilePhone, Phone, Age__c, CampaignCess__c,
                                                                        IsCustomer__c, ManagementsCess__c, BussinesLineProhibited__c, BusinessLineContracted__c,
                                                                        SourceType__c, Gender__c, LineInsurance__c, CTIRiskPostalCode__c, SourceCess__c,
                                                                        SFURLPop__c, IsPreview__c, CTISent__c, CTIError__c, CreatedDate, ManagementsSF__c,
                                                                        Lead.schedulecontact_datetime__c, Lead.cti_username__c, Lead.crl_ok__c, LeadOrContactId
                                                                        FROM CampaignMember
                                                                        WHERE Id in :ids]);
        // Añadimos los ids de los contactos de los Campaign Members.                                                                
        for(CampaignMember cm : cmsMap.values()) {
            contactsIds.add(cm.ContactId);
        }
        //Llamamos a la función getContactInsurance, para recuperar un set que contega ContactID-Ramo Oportunidad.
        Set<String> sContactInsurance = getContactInsurance(contactsIds);
        
        // Iteramos para sacar un set con los clientes de estos CMs        
        for(ID idKey : cmsMap.keyset()){
            sIdClientes.add(cmsMap.get(idKey).LeadOrContactId);
        }
                                                    
        // Get Miembro de Campaña Gestionado CTI         
        for(AMCM__c mcGest : [SELECT Id, LeadOrContactId__c, SFCampaign__r.Name FROM AMCM__c 
                              WHERE LeadOrContactId__c IN: sIdClientes
                              AND CTISent__c = true 
                              AND Tipo__c = 'CTI'
                              AND (Lead__c = null OR Contact__c = null)]){
            // Generamos el key y lo añadimos al mapa
            mClienteIdCampaignNameAMCMGest.put(mcGest.LeadOrContactId__c + '-' + mcGest.SFCampaign__r.Name, mcGest);
        }


        for(ID idKey : cmsMap.keyset()){

            CampaignMember sentCM = cmsMap.get(idKey);
            CESS_BulkifiedCTIRequestDto.RequestUpsertContact ric = new CESS_BulkifiedCTIRequestDto.RequestUpsertContact();

            if(sentCM.ContactId != null){
                leadContactCampaignMap.put(sentCM.ContactId, sentCM.Id);                
            }else{
                leadContactCampaignMap.put(sentCM.LeadId, sentCM.Id);
            }
        //REQUERID
            ric.campaign_name = sentCM.Campaign.Name == null ? '' : sentCM.Campaign.Name;
            ric.columns.add('external_id');
            ric.values.add(sentCM.ContactId != null? sentCM.ContactId : sentCM.LeadId);
            ric.columns.add('lead_Number');
            ric.values.add(sentCM.ClientOrLeadNumber__c);
            ric.columns.add('order_number');
            ric.values.add(sentCM.CTIOrder__c != null ? string.valueOf(sentCM.CTIOrder__c) : CESS_CTIPLAN_ORDER);
            //SKILLS: Para llamadas planificadas se envia CTIClientSkill__c, e.o.c CTISkill__c
            ric.columns.add('skills');
            if(sentCM.Lead.schedulecontact_datetime__c != null && sentCM.Lead.schedulecontact_datetime__c >= DateTime.now() ){
                ric.values.add(sentCM.CTIClientSkill__c != null ? sentCM.CTIClientSkill__c : CESS_CTIPLAN_SKILL);
            }else {
                ric.values.add(sentCM.CTISkill__c != null? sentCM.CTISkill__c : CESS_CTIPLAN_SKILL);
            }
            ric.columns.add('source_datetime');
            ric.values.add( (sentCM.CreatedDate).format('yyyy-MM-dd HH:mm:ss','Europe/Paris') );
            ric.columns.add('tel_contact1');
            ric.values.add(sentCM.MobilePhone != null? sentCM.MobilePhone : sentCM.Phone);
        //OPTIONAL
            if (sentCM.Age__c != null){
                ric.columns.add('age');
                ric.values.add(string.valueOf(sentCM.Age__c));
            }
            if (sentCM.CampaignCess__c != null){
                ric.columns.add('cess_campaign');
                ric.values.add(string.valueOf(sentCM.CampaignCess__c));
            }
            ric.columns.add('cess_customer');
            ric.values.add(sentCM.IsCustomer__c ? 'Y' : 'N');
            ric.columns.add('cess_tasks');
            ric.values.add(sentCM.ManagementsCess__c ? 'Y' : 'N');
            ric.columns.add('crm_tasks');
            ric.values.add(sentCM.ManagementsSF__c ? 'Y' : 'N');
            ric.columns.add('line_forbidden');
            ric.values.add(sentCM.BussinesLineProhibited__c ? 'Y' : 'N');
            ric.columns.add('line_signed');
            ric.values.add(sentCM.BusinessLineContracted__c ? 'Y' : 'N');
            if (sentCM.SourceType__c != null){
                ric.columns.add('channel');
                ric.values.add(string.valueOf(sentCM.SourceType__c));
            }
            if (sentCM.Gender__c != null){
                ric.columns.add('gender');
                ric.values.add(string.valueOf(sentCM.Gender__c));
            }
            if (sentCM.LineInsurance__c != null){
                ric.columns.add('insurance_line');
                ric.values.add(string.valueOf(sentCM.LineInsurance__c));
            }
            if (sentCM.CTIRiskPostalCode__c != null){
                ric.columns.add('postal_code');
                ric.values.add(string.valueOf(sentCM.CTIRiskPostalCode__c));
            }
            if (sentCM.SourceCess__c != null){
                ric.columns.add('source');
                ric.values.add(string.valueOf(sentCM.SourceCess__c));
            }
            if (sentCM.MobilePhone != null){ //phone informed on tlf1
                if (sentCM.Phone != null){
                    ric.columns.add('tel_contact2');
                    ric.values.add(sentCM.Phone);
                }
            }
            if (sentCM.SFURLPop__c != null){
                ric.columns.add('sf_urlpop');
                ric.values.add(sentCM.SFURLPop__c);
            }
            ric.columns.add('sf_cm_id');
            ric.values.add(sentCM.id);
            //Comprobamos si la columna preview debe o no verse en función de si coincide el rampo del CM y de la Opp asociadas al contacto
            if(sContactInsurance.contains(sentCM.ContactId+'-'+sentCM.LineInsurance__c)) {
                ric.columns.add('preview');
                ric.values.add('true');
            } else {
                ric.columns.add('preview');
                ric.values.add('false');
            }
            ric.front_code =  CESS_CTI_FRONTCODE ;
            ric.column_filter = CESS_CTI_COLUMNFILTER;

            if (sentCM.Lead.schedulecontact_datetime__c != null && sentCM.Lead.schedulecontact_datetime__c >= DateTime.now()){
                //Si es una inserción pero tiene el lead llamada planificada (leads referencia)
                String sched_time = ((Datetime)sentCM.Lead.schedulecontact_datetime__c).format('yyyy-MM-dd HH:mm:ss','Europe/Paris');
                //String en este orden: agent_id, phone_number, sched_time
                CESS_BulkifiedCTIRequestDto.ScheduledPlanningCall spc = new CESS_BulkifiedCTIRequestDto.ScheduledPlanningCall();
                spc.phone_number = sentCM.MobilePhone == null ? (sentCM.Phone == null ? '' : sentCM.Phone) : sentCM.MobilePhone;
                spc.agent_id = sentCM.Lead.cti_username__c == null ? '' : sentCM.Lead.cti_username__c;
                spc.sched_time = sched_time;                
                ric.scheduled_planning_call = spc;
            }
			

            /*********** Código deshabilitado debido la solución temporal del 23/11/2022. Rehabilitar para restaurar la versión original ****

            // Si el Miembro de campaña tiene marcado CTISent__c o si existe un CTI Gestionado enviado anteriormente a CTI de la misma campaña CTI
            // será para hacer una actualización (updateCampaignCalls)
            if( sentCM.CTISent__c ){
                // Si ya se ha enviado este CM CTI es porque es una actualización de datos
                updateCampaingMembers.requestInsertContactList.add(ric);

            }else if( mClienteIdCampaignNameAMCMGest.containsKey(sentCM.LeadOrContactId + '-' + sentCM.Campaign.Name) ){
                // Si actualizamos pero porque ya existía un gestionado, mandamos el parámetro Status para que se reabra el registro en la contact list
                ric.columns.add('status');
                ric.values.add('C');                    
                updateCampaingMembers.requestInsertContactList.add(ric);
                            
            }else{
                // Si es una creación sin más
                campaingMembers.requestInsertContactList.add(ric);
            }

            *************** Fin Código deshabilitado debido la solución temporal del 23/11/2022 *********************************/


            /* ************ Añadido como solución temporal el 23.11.2022. Eliminar para restarurar la versión original ******* */

            // Ya no diferenciamos si es un update o un delete, así que añadiremos todas las RequestUpsertContact al insert.
            campaingMembers.requestInsertContactList.add(ric);

            //Creamos un nuevo delete request para asegurar que el destinatario no tenga duplicados en su base de datos
            deleteRequest = new CESS_BulkifiedCTIRequestDto.RequestDeleteContact();
            deleteRequest.values.add(sentCM.ContactId != null ? sentCM.ContactId : sentCM.LeadId);
            deleteRequest.columns.add('external_id');
            deleteRequest.column_filter = 'external_id';
            deleteRequest.front_code = CESS_CTI_FRONTCODE;
            deleteRequest.campaign_name = (sentCM.Campaign == null || sentCM.Campaign.Name == null) ? '' : sentCM.Campaign.Name;
            deleteLegacyCampaignMembers.requestDeleteContactList.add(deleteRequest);

            /* *********************** Fin añadido como solución temporal el 23.11.2022 ************************************** */
        }

        
        /* ************ Añadido como solución temporal el 23.11.2022. Eliminar para restarurar la versión original ******* */

        CESS_BulkifiedCTIResponseDto.DeleteCalls deletionResponse;

        if (campaingMembers.requestInsertContactList.size() > 0 ) {
            try {
                deletionResponse = client.deleteCalls(deleteLegacyCampaignMembers);
                /* 
                    Se asume que si no devuelve una excepción, el borrado ha sido exitoso. Probablemente no sea así y se 
                    deba procesar la respuesta, pero se desconocen los detalles de la respuesta 
                */
                insertCampaingResponse = client.insertCampaingCalls(campaingMembers);
            } catch (Exception e) {
                logsMess.add('GENERAL ERROR: '+e.getMessage());
            }
        }

        // Analizamos la respuesta del borrado y añadimos el log al campo
        if( deletionResponse != null && deletionResponse.response != null&& deletionResponse.response.results != null ){

            for (String resultsMsg: deletionResponse.response.results) {
                Map<String, String> resultsMsgMap = parseResultToken(resultsMsg);
                if (resultsMsgMap.size() > 0 && resultsMsgMap.get('EXT_ID') <> null){
                    String leadContactId = resultsMsgMap.get('EXT_ID');
                    CampaignMember oCM = new CampaignMember();
                    oCM = cmsMap.get(leadContactCampaignMap.get(leadContactId));
                    if (String.isBlank(oCM.CTIError__c)) oCM.CTIError__c = '';
                    // Generamos los mensajes de OK o Error y se añaden al campo CTIError 
                    if ( resultsMsgMap.get('STATUS') == 'OK' ) {                                        
                        // Actualizamos el mensaje de error y el campo de error
                        String newCTIError = oCM.CTIError__c + ' *OK DLT ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss','Europe/Paris');                    
                        if( newCTIError.length() <= describeCTIError.getLength() ) oCM.CTIError__c = newCTIError;
                    }else{
                        // Actualizamos el mensaje de error y el campo de error
                        String newCTIError = oCM.CTIError__c + ' *ERROR DLT: ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss','Europe/Paris') + ': ' + resultsMsgMap.get('MESSAGE');              
                        if( newCTIError.length() <= describeCTIError.getLength() ) oCM.CTIError__c = newCTIError;                                        
    
                        logsMess.add('CM ID: '+oCM.Id+' :: ERROR DLT: '+ resultsMsgMap.get('MESSAGE'));
                    }
                    // Se añadel el CM al mapa para actualizar
                    mCM2Update.put(oCM.id,oCM);
                }
            }

        }
        

        /* *********************** Fin añadido como solución temporal el 23.11.2022 ************************************** */
        
        /*********** Código deshabilitado debido la solución temporal del 23/11/2022. Rehabilitar para restaurar la versión original ****

        if ( campaingMembers.requestInsertContactList.size() > 0 ) {
            try {
                insertCampaingResponse = client.insertCampaingCalls(campaingMembers);
            } catch (Exception e) {
                logsMess.add('GENERAL ERROR: '+e.getMessage());
            }
        }

        //-JCB- Miembros de Campaña con sent_cti__c marcado, se hace una actualización met.updateCampaignCalls
        if (updateCampaingMembers.requestInsertContactList.size() > 0){
            try {
                updateCampaignResponse = client.updateCampaignCalls(updateCampaingMembers);
            } catch (Exception e) {
                logsMess.add('GENERAL ERROR: '+e.getMessage());
            }
        }

        *************** Fin Código deshabilitado debido la solución temporal del 23/11/2022 *********************************/

        
        if ( insertCampaingResponse != null && insertCampaingResponse.response != null
            && insertCampaingResponse.response.results != null && insertCampaingResponse.response.results.size() > 0 ){

            //ACTUALIZACIÓN DE CAMPOS EN OBJETOS
            for (String resultsMsg: insertCampaingResponse.response.results) {
                Map<String, String> resultsMsgMap = parseResultToken(resultsMsg);
                if (resultsMsgMap.size() > 0 && resultsMsgMap.get('EXT_ID') <> null){
                    String leadContactId = resultsMsgMap.get('EXT_ID');
                    CampaignMember oCM = new CampaignMember();
                    oCM = cmsMap.get(leadContactCampaignMap.get(leadContactId));
                    // Obtenemos el oCM que está en el mapa de actualización, si está ahí
                    oCM = mCM2Update.containsKey(oCM.Id) ? mCM2Update.get(oCM.Id) : oCM;
                    if( String.isBlank(oCM.CTIError__c) ) oCM.CTIError__c = '';

                    if( resultsMsgMap.get('STATUS') == 'OK' ){                    
                        //Si es Lead actualizar el campo crl_ok__c
                        if( resultsMsgMap.get('EXT_ID').startsWith('00Q') ){
                            Lead oLead = new Lead(id=resultsMsgMap.get('EXT_ID'));
                            oLead.crl_ok__c = false;
                            leadListToUpdate.add(oLead);
                        }
                        // Actualizamos el mensaje de error y el campo de error
                        String newCTIError = oCM.CTIError__c + ' *OK INS ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss','Europe/Paris');                    
                        if( newCTIError.length() <= describeCTIError.getLength() ) oCM.CTIError__c = newCTIError;
                        oCM.CTIErrorCheck__c = false;
                        oCM.CTISent__c = true;
                        
                    }else{
                        
                        //Si es Lead actualizar el campo crl_ok__c
                        if( resultsMsgMap.get('EXT_ID').startsWith('00Q') ){
                            Lead oLead = new Lead(id=resultsMsgMap.get('EXT_ID'));
                            oLead.crl_ok__c = false;
                            leadListToUpdate.add(oLead);
                        }
                       
                        //En caso de error 'Contact list not found' se realiza un reintento de envio al servidor
                        
                       // if(String.valueof(resultsMsgMap.get('MESSAGE')).contains(System.Label.ErrorContactListNotFound)&&!String.valueof(oCM.CTIError__c).contains(' Reintentado ')){
                         //   oCM.CTISend__c = true;
                         //   oCM.CTIError__c = oCM.CTIError__c +' Reintentado ';
                            
                        //}
                        // Actualizamos el mensaje de error y el campo de error
                        String newCTIError = oCM.CTIError__c + ' *ERROR INS ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss','Europe/Paris') + ': ' + resultsMsgMap.get('MESSAGE');              
                        if( newCTIError.length() <= describeCTIError.getLength() ) oCM.CTIError__c = newCTIError;
                        oCM.CTIErrorCheck__c = true;
                        oCM.CTISent__c = false;

                        logsMess.add('CM ID: '+oCM.Id+' :: ERROR INS: '+ resultsMsgMap.get('MESSAGE'));
                        
                    }

                    mCM2Update.put(oCM.Id,oCM);
                }
            }
        }        

        

        try {
            update mCM2Update.values();
            update leadListToUpdate;
        } catch (Exception e) {
            System.debug(e);
        }

        if ( logsMess.size() > 0 ) {
            system.debug('entra log');
            IntegrationLog__c log = new IntegrationLog__c();
            log.error__c = JSON.serialize(logsMess);
            log.handler_class__c = 'CESS_BulkifiedCTILogic';
            log.system__c = 'CESS-CTI';
            log.retries__c = 1;
            try {
                insert log;
            } catch (Exception e) {
                System.debug(e);
            }
        }

    }
    /*********************************************************************************/
    public String deleteRelatedCalls(List<ID> tasksIds) {

        List<Task> taskList = [SELECT Id, WhoId, WhatId, Status, Type, AccountId,
                               CESS_Fecha_Planificada__c, OwnerId, owner_ctiuser__c, cti_error__c,
                               Account.Phone, Account.PersonMobilePhone, CampaignMemberId__c, CTICampaign__c
                               FROM Task WHERE Type = 'Schedule Call'
                               and id in :tasksIds];

        List<Id> opportunitiesIds = new List<Id>();
        List<Id> leadsIds = new List<Id>();
        List<Id> contactsIds = new List<Id>();
        List<Id> cmRelateds = new List<Id>();
        for (Task t: taskList) {
            if ( t.WhatId != null && ((String) t.WhatId).startsWith('006') ) {
                opportunitiesIds.add(t.WhatId);
            }else if ( t.WhoId != null && ((String) t.WhoId).startsWith('00Q') ) {
                    leadsIds.add(t.WhoId);
            }else if ( t.WhoId != null && ((String) t.WhoId).startsWith('003') ) {
                contactsIds.add(t.WhoId);
            }

            if(t.CampaignMemberId__c !=null){cmRelateds.add(t.CampaignMemberId__c);}
        }

        Map<ID, Opportunity> opportunitiesMap = new Map<ID, Opportunity>([SELECT Account.PersonContact.CustomerNumber__c ,CTI_Campaign__c,phone__c,
                                                                          CESSCreadoPorUsuario_CTI__c,skill__c, relatedCTICampaignMemberId__c 
                                                                          FROM Opportunity
                                                                          WHERE Id in :opportunitiesIds]);

        for(Id  o : opportunitiesMap.keySet()){
            if(opportunitiesMap.get(o).relatedCTICampaignMemberId__c!=null)
                cmRelateds.add(opportunitiesMap.get(o).relatedCTICampaignMemberId__c);
        }

        Map<Id, CampaignMember> cMembersRelated = new Map<Id, CampaignMember>([SELECT ClientOrLeadNumber__c, MobilePhone, Phone, CTIOrder__c, CTIClientSkill__c, CTISkill__c, Campaign.Name  FROM CampaignMember
                            WHERE Id IN :cmRelateds] );
        Map<ID, Lead> leadsMap = new Map<ID, Lead>([SELECT lead_number__c,contact_attempts__c,MobilePhone,Phone,campaign_cti__c FROM Lead
                             WHERE Id in :leadsIds]);
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT MobilePhone, Account.Phone, CustomerNumber__c  FROM Contact WHERE Id IN :contactsIds]);

        CESS_BulkifiedCTIRequestDto.UnscheduledCalls icc = new CESS_BulkifiedCTIRequestDto.UnscheduledCalls();

        String sObjectToUse = 'None';
        CampaignMember cm = new CampaignMember();
        String tlf = '';
        String skill = '';
        String order ='';
        String oNumber='';
        String nombreCamp = '';

        for (Task ts: taskList) {
            if ( ts.WhatId != null && opportunitiesMap.get(ts.WhatId) != null ) {
                sObjectToUse = 'Opportunity';
            } else if ( ts.WhoId != null && leadsMap.get(ts.WhoId) != null ) {
                    sObjectToUse = 'Lead';
            } else if ( ts.WhoId != null && contactsMap.get(ts.WhoId) != null ) {
                sObjectToUse = 'Contact';
            }


            String sched_time = ((Datetime)ts.CESS_Fecha_Planificada__c).format('yyyy-MM-dd HH:mm:ss'); //TODO: Validate if this info is needed for Delete

            List <String> columns = new List <String>{'external_id','lead_number','order_number','skills','source_datetime','tel_contact1','status','Resultado' };
            List <String> values = new List<String>();

            if ( sObjectToUse == 'Opportunity' ) {
                //Si tiene un CM relacionado se toman los valores de éste, sino los valores por defecto
                if(cMembersRelated.get(opportunitiesMap.get(ts.WhatId).relatedCTICampaignMemberId__c) != null){
                    cm = cMembersRelated.get(opportunitiesMap.get(ts.WhatId).relatedCTICampaignMemberId__c);
                    tlf = cm.MobilePhone != null? cm.MobilePhone : cm.Phone;
                    skill = cm.CTIClientSkill__c != null? cm.CTIClientSkill__c : CESS_CTIPLAN_SKILL;
                    order = cm.CTIOrder__c != null ? string.valueOf(cm.CTIOrder__c) : CESS_CTIPLAN_ORDER;
                    oNumber = cm.ClientOrLeadNumber__c;
                    nombreCamp = cm.Campaign.Name;
                }else{
                    tlf = opportunitiesMap.get(ts.WhatId).phone__c == null ? (ts.Account.PersonMobilePhone == null ? ts.Account.Phone : ts.Account.PersonMobilePhone) : opportunitiesMap.get(ts.WhatId).phone__c;
                    skill = CESS_CTIPLAN_SKILL;
                    order = CESS_CTIPLAN_ORDER;
                    oNumber = opportunitiesMap.get(ts.WhatId).Account.PersonContact.CustomerNumber__c;
                    nombreCamp = ts.CTICampaign__c;
                }
                values = new List <String>{ts.Id,oNumber,order,skill,sched_time,tlf,'U','DESP_SALESFORCE'};

            } else if ( sObjectToUse == 'Lead' ) {
                //Se toma el CampaignMember referenciado en CampaignMemberId__c de Tarea, si no existe se toman valores por defecto
                if( cMembersRelated.get(ts.CampaignMemberId__c) != null ){
                    cm = cMembersRelated.get(ts.CampaignMemberId__c);
                    tlf = cm.MobilePhone != null? cm.MobilePhone : cm.Phone;
                    skill = cm.CTIClientSkill__c != null? cm.CTIClientSkill__c : CESS_CTIPLAN_SKILL;
                    order = cm.CTIOrder__c != null ? string.valueOf(cm.CTIOrder__c) : CESS_CTIPLAN_ORDER;
                    oNumber = cm.ClientOrLeadNumber__c;
                    nombreCamp = cm.Campaign.Name;
                }else{
                    tlf = leadsMap.get(ts.WhoId).MobilePhone == null ? (leadsMap.get(ts.WhoId).Phone == null ? '' : leadsMap.get(ts.WhoId).Phone) : leadsMap.get(ts.WhoId).MobilePhone; //FPEREZ. Tlf añadido
                    oNumber = leadsMap.get(ts.WhoId).lead_number__c;
                    order = CESS_CTIPLAN_ORDER;
                    skill = CESS_CTIPLAN_SKILL;
                    nombreCamp = ts.CTICampaign__c;
                }
                values = new List <String>{ts.Id,oNumber,order,skill,sched_time,tlf,'U','DESP_SALESFORCE'};

            } else if ( sObjectToUse == 'Contact' ) {
                if( cMembersRelated.get(ts.CampaignMemberId__c) != null ){
                    cm = cMembersRelated.get(ts.CampaignMemberId__c);
                    tlf = cm.MobilePhone != null? cm.MobilePhone : cm.Phone;
                    skill = cm.CTIClientSkill__c != null? cm.CTIClientSkill__c : CESS_CTIPLAN_SKILL;
                    order = cm.CTIOrder__c != null ? string.valueOf(cm.CTIOrder__c) : CESS_CTIPLAN_ORDER;
                    oNumber = cm.ClientOrLeadNumber__c;
                    nombreCamp = cm.Campaign.Name;
                }else{
                    tlf = contactsMap.get(ts.WhoId).MobilePhone == null ? (contactsMap.get(ts.WhoId).Account.Phone == null ? '' : contactsMap.get(ts.WhoId).Account.Phone) : contactsMap.get(ts.WhoId).MobilePhone;
                    oNumber = contactsMap.get(ts.WhoId).CustomerNumber__c;
                    order = CESS_CTIPLAN_ORDER;
                    skill = CESS_CTIPLAN_SKILL;
                    nombreCamp = ts.CTICampaign__c;
                }
                values = new List <String>{ts.Id,oNumber,order,skill,sched_time,tlf,'U','DESP_SALESFORCE'};

            }

            CESS_BulkifiedCTIRequestDto.RequestUnscheduledContact ric = new CESS_BulkifiedCTIRequestDto.RequestUnscheduledContact();
            ric.front_code =  CESS_CTI_FRONTCODE ;
            ric.column_filter = CESS_CTI_COLUMNFILTER;
            ric.campaign_name = nombreCamp == null? '' : nombreCamp;

            for (String column: columns) {
                ric.columns.add(column);
            }
            for (String value: values) {
                ric.values.add(value);
            }

            icc.requestUnscheduledContactList.add(ric);

        }
        String endedCall = null;
        try
        {
            CESS_BulkifiedCTIRestClient client = new CESS_BulkifiedCTIRestClient();
            CESS_BulkifiedCTIResponseDto.UnscheduledCalls deleteResponse = client.updateUnscheduledCalls(icc);

            if ( deleteResponse != null && deleteResponse.response != null
                && deleteResponse.response.results != null && deleteResponse.response.results.size() > 0 ){

                setResponseErrors(tasksIds, deleteResponse.response, true);
            }
            else {
                setResponseErrors(tasksIds, null, true);
                endedCall = 'final';
            }
        } catch (Exception e) {
            System.debug('Error calling deleteCalls: '+e);
        }
        return endedCall;

    }
    /*****************************************************************/
    public void insertRelatedCalls(List<ID> tasksIds) {

        List<Task> taskList = [SELECT Id, WhoId, WhatId, Status, Type, AccountId,
                               CESS_Fecha_Planificada__c, OwnerId, owner_ctiuser__c, cti_error__c,
                               Account.Phone, Account.PersonMobilePhone, CampaignMemberId__c

                               FROM Task WHERE Type = 'Schedule Call'
                               and id in :tasksIds];

        List<Id> opportunitiesIds = new List<Id>();
        List<Id> leadsIds = new List<Id>();
        List<Id> contactsIds = new List<Id>();
        List<Id> cmRelateds = new List<Id>();
        for (Task t: taskList) {
            if ( t.WhatId != null && ((String) t.WhatId).startsWith('006') ) {
                opportunitiesIds.add(t.WhatId);
            } else if ( t.WhoId != null && ((String) t.WhoId).startsWith('00Q') ) {
                leadsIds.add(t.WhoId);
            } else if ( t.WhoId != null && ((String) t.WhoId).startsWith('003') ) {
                contactsIds.add(t.WhoId);
            }
            if( t.CampaignMemberId__c != null ){
                cmRelateds.add(t.CampaignMemberId__c);
            }
        }

        Map<ID, Opportunity> opportunitiesMap = new Map<ID, Opportunity>( [SELECT Account.PersonContact.CustomerNumber__c,CTI_Campaign__c,phone__c, line_insurance__c,
                                                                           CESSCreadoPorUsuario_CTI__c,Skill__c, relatedCTICampaignMemberId__c, IsClosed
                                                                           FROM Opportunity
                                                                           WHERE Id in :opportunitiesIds]);

        for(Id  o : opportunitiesMap.keySet()){
            if( opportunitiesMap.get(o).relatedCTICampaignMemberId__c != null )
                cmRelateds.add(opportunitiesMap.get(o).relatedCTICampaignMemberId__c);
        }

        Map<Id, CampaignMember> cMembersRelated = new Map<Id, CampaignMember>([SELECT ClientOrLeadNumber__c, MobilePhone, Phone, CTIOrder__c, CTIClientSkill__c,
                                                                               CTISkill__c, Campaign.Name, SFURLPop__c, Id, IsPreview__c, LineInsurance__c
                                                                               FROM CampaignMember
                                                                               WHERE Id IN :cmRelateds] );

        Map<ID, Lead> leadsMap = new Map<ID, Lead>([SELECT lead_number__c,contact_attempts__c,MobilePhone,Phone,campaign_cti__c
                                                    FROM Lead
                                                    WHERE Id in :leadsIds]);

        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT MobilePhone, Account.Phone, CustomerNumber__c  FROM Contact WHERE Id IN :contactsIds]);
        
        //Llamamos a la función getContactInsurance, para recuperar un set que contega ContactID-Ramo Oportunidad.
        Set<String> sContactInsurance = getContactInsurance(contactsMap.keySet());

        CESS_BulkifiedCTIRequestDto.InsertScheduleCalls icc = new CESS_BulkifiedCTIRequestDto.InsertScheduleCalls();
        String sObjectToUse = 'None';
        for (Task ts: taskList) {

            if ( ts.WhatId != null && opportunitiesMap.get(ts.WhatId) != null ) {
                sObjectToUse = 'Opportunity';
            } else if ( ts.WhoId != null && leadsMap.get(ts.WhoId) != null ) {
                sObjectToUse = 'Lead';
            } else if (ts.WhoId != null && contactsMap.get(ts.WhoId) != null ){
                    sObjectToUse = 'Contact';
            }
            
            if ( sObjectToUse != 'Opportunity' || (sObjectToUse == 'Opportunity' && Boolean.valueOf(CESS_CTI_ENVIOOPORTUNIDADESPLANIFICADAS)) || Test.isRunningTest() ) {
                    
                String sched_time = ((Datetime)ts.CESS_Fecha_Planificada__c).format('yyyy-MM-dd HH:mm:ss');
                String tlf = '';
                String skill = '';
                String order ='';
                String oNumber='';
                String nombreCamp = '';
        		Boolean valuePreview;
        		Boolean hasPreview = false;
                List <String> columns = new List <String>{'external_id','lead_number','order_number','skills','source_datetime','tel_contact1'};
                List <String> values = new List<String>();
                CampaignMember cm = new CampaignMember();

                if ( sObjectToUse == 'Opportunity' ) {

                    if( cMembersRelated.get(opportunitiesMap.get(ts.WhatId).relatedCTICampaignMemberId__c) != null ){
                        cm = cMembersRelated.get(opportunitiesMap.get(ts.WhatId).relatedCTICampaignMemberId__c);
                        tlf = cm.MobilePhone != null? cm.MobilePhone : cm.Phone;
                        skill = cm.CTIClientSkill__c != null? cm.CTIClientSkill__c : CESS_CTIPLAN_SKILL;
                        order = cm.CTIOrder__c != null ? string.valueOf(cm.CTIOrder__c) : CESS_CTIPLAN_ORDER;
                        oNumber = cm.ClientOrLeadNumber__c;
                        nombreCamp = cm.Campaign.Name;
                    }else{
                        tlf = opportunitiesMap.get(ts.WhatId).phone__c == null ? (ts.Account.PersonMobilePhone == null ? ts.Account.Phone : ts.Account.PersonMobilePhone) : opportunitiesMap.get(ts.WhatId).phone__c;
                        skill = opportunitiesMap.get(ts.WhatId).Skill__c == null ? CESS_CTIPLAN_SKILL : opportunitiesMap.get(ts.WhatId).Skill__c;
                        order = CESS_CTIPLAN_ORDER;
                        oNumber = opportunitiesMap.get(ts.WhatId).Account.PersonContact.CustomerNumber__c;
                        nombreCamp = opportunitiesMap.get(ts.WhatId).CTI_Campaign__c;
                    }

                }else if ( sObjectToUse == 'Lead' ) {

                    //Se toma el CampMembers referenciado en  CampaignMemberId__c de Tarea, si no existe se toman valores por defecto
                    if( cMembersRelated.get(ts.CampaignMemberId__c) != null ){
                        cm = cMembersRelated.get(ts.CampaignMemberId__c);
                        tlf = cm.MobilePhone != null? cm.MobilePhone : cm.Phone;
                        skill = cm.CTIClientSkill__c != null? cm.CTIClientSkill__c : CESS_CTIPLAN_SKILL;
                        order = cm.CTIOrder__c != null ? string.valueOf(cm.CTIOrder__c) : CESS_CTIPLAN_ORDER;
                        oNumber = cm.ClientOrLeadNumber__c;
                        nombreCamp = cm.Campaign.Name;
                    }else{
                        tlf = leadsMap.get(ts.WhoId).MobilePhone == null ? (leadsMap.get(ts.WhoId).Phone == null ? '' : leadsMap.get(ts.WhoId).Phone) : leadsMap.get(ts.WhoId).MobilePhone; //FPEREZ. Tlf añadido
                        oNumber = leadsMap.get(ts.WhoId).lead_number__c;
                        order = CESS_CTIPLAN_ORDER;
                        skill = CESS_CTIPLAN_SKILL;
                        nombreCamp = leadsMap.get(ts.WhoId).campaign_cti__c;
                    }

                }else if( sObjectToUse == 'Contact'){

                    if( cMembersRelated.get(ts.CampaignMemberId__c) != null ){
                        cm = cMembersRelated.get(ts.CampaignMemberId__c);
                        tlf = cm.MobilePhone != null? cm.MobilePhone : cm.Phone;
                        skill = cm.CTIClientSkill__c != null? cm.CTIClientSkill__c : CESS_CTIPLAN_SKILL;
                        order = cm.CTIOrder__c != null ? string.valueOf(cm.CTIOrder__c) : CESS_CTIPLAN_ORDER;
                        oNumber = cm.ClientOrLeadNumber__c;
                        nombreCamp = cm.Campaign.Name;
                        //Comprobamos si la columna preview debe o no verse en función de si coincide el rampo del CM y de la Opp asociadas al contacto
                        hasPreview = true;
                        if(sContactInsurance.contains(ts.WhoId+'-'+cm.LineInsurance__c)) {
                            valuePreview = true;
                        } else {
                            valuePreview = false;
                        }
                    }else{
                        tlf = contactsMap.get(ts.WhoId).MobilePhone == null ? (contactsMap.get(ts.WhoId).Account.Phone == null ? '' : contactsMap.get(ts.WhoId).Account.Phone) : contactsMap.get(ts.WhoId).MobilePhone;
                        oNumber = contactsMap.get(ts.WhoId).CustomerNumber__c;
                        order = CESS_CTIPLAN_ORDER;
                        skill = CESS_CTIPLAN_SKILL;
                        nombreCamp = null;
                        hasPreview = false;
                    }

                }
                
                values = new List <String>{ts.Id,oNumber,order,skill,sched_time,tlf};

                //Se añaden 3 nuevos params si existen
                if (cm.id != null){
                    columns.add('sf_cm_id');
                    values.add(cm.id);
                }
                if (cm.SFURLPop__c != null){
                    columns.add('sf_urlpop');
                    values.add(cm.SFURLPop__c);
                }
                if (sObjectToUse == 'Contact' && hasPreview){
                    columns.add('preview');
                    if(valuePreview) {
                        values.add('true');   
                    } else {
                        values.add('false');
                    }
                }

                CESS_BulkifiedCTIRequestDto.RequestUpsertContact ric = new CESS_BulkifiedCTIRequestDto.RequestUpsertContact();

                ric.front_code =  CESS_CTI_FRONTCODE ;
                ric.column_filter = CESS_CTI_COLUMNFILTER;
                // Si la campaña cti a enviar está vacía enviamos la campaña por defecto, nunca vacío
                ric.campaign_name = String.isBlank(nombreCamp) ? CESS_CTIPLAN_CAMPAIGN : nombreCamp;
                for (String column: columns) {
                    ric.columns.add(column);
                }
                for (String value: values) {
                    ric.values.add(value);
                }

                CESS_BulkifiedCTIRequestDto.ScheduledPlanningCall spc = new CESS_BulkifiedCTIRequestDto.ScheduledPlanningCall();
                if ( sObjectToUse == 'Opportunity' ) {
                    spc.agent_id = opportunitiesMap.get(ts.WhatId).CESSCreadoPorUsuario_CTI__c == null ? '' : opportunitiesMap.get(ts.WhatId).CESSCreadoPorUsuario_CTI__c;
                }else if ( sObjectToUse == 'Lead' ) {
                    spc.agent_id = '';
                }else if ( sObjectToUse == 'Contact' ) {
                    spc.agent_id = '';
                }

                spc.phone_number = tlf;
                spc.sched_time = sched_time;
                ric.scheduled_planning_call = spc;
                icc.requestInsertContactList.add(ric);
            }
        }

        try{

            CESS_BulkifiedCTIRestClient client = new CESS_BulkifiedCTIRestClient();
            CESS_BulkifiedCTIResponseDto.InsertScheduleCalls insertResponse = client.insertScheduleCalls(icc);


            if ( insertResponse != null && insertResponse.response != null
                && insertResponse.response.results != null && insertResponse.response.results.size() > 0 ){
                setResponseErrors(tasksIds, insertResponse.response, false);
            }
            else {
                setResponseErrors(tasksIds, null, false);
            }

        } catch (Exception e) {
            System.debug('Error calling insertCalls: '+e);
        }

    }
    /******************************************************************************* */
    public void updateRelatedCalls(List<ID> tasksIds) {


        List<Task> taskList = [SELECT Id, WhoId, WhatId, Status, Type, AccountId,
                               CESS_Fecha_Planificada__c, OwnerId, owner_ctiuser__c, cti_error__c,
                               Account.Phone, Account.PersonMobilePhone, CampaignMemberId__c
                               FROM Task WHERE Type = 'Schedule Call'
                               and id in :tasksIds];

        List<Id> opportunitiesIds = new List<Id>();
        List<Id> leadsIds = new List<Id>();
        List<Id> contactsIds = new List<Id>();
        List<Id> cmRelateds = new List<Id>();
        for (Task t: taskList) {
            if ( t.WhatId != null && ((String) t.WhatId).startsWith('006') ) {
                opportunitiesIds.add(t.WhatId);
            } else if ( t.WhoId != null && ((String) t.WhoId).startsWith('00Q') ) {
                    leadsIds.add(t.WhoId);
            } else if ( t.WhoId != null && ((String) t.WhoId).startsWith('003') ) {
                    contactsIds.add(t.WhoId);
            }
            if(t.CampaignMemberId__c !=null){
                cmRelateds.add(t.CampaignMemberId__c);
            }
        }

        Map<ID, Opportunity> opportunitiesMap = new Map<ID, Opportunity>([SELECT Account.PersonContact.CustomerNumber__c,Skill__c,CTI_Campaign__c, line_insurance__c,
                                                                          phone__c, relatedCTICampaignMemberId__c, IsClosed
                                                                          FROM Opportunity
                                                                          WHERE Id in :opportunitiesIds]);

        for(Id  o : opportunitiesMap.keySet()){
            if(opportunitiesMap.get(o).relatedCTICampaignMemberId__c!=null)
                cmRelateds.add(opportunitiesMap.get(o).relatedCTICampaignMemberId__c);
        }

        Map<Id, CampaignMember> cMembersRelated = new Map<Id, CampaignMember>([SELECT ClientOrLeadNumber__c, MobilePhone, Phone, CTIOrder__c, CTIClientSkill__c,
                                                                               CTISkill__c, Campaign.Name, SFURLPop__c, Id, IsPreview__c, LineInsurance__c
                                                                               FROM CampaignMember
                                                                               WHERE Id IN :cmRelateds] );

        Map<ID, Lead> leadsMap = new Map<ID, Lead>([SELECT lead_number__c,contact_attempts__c,MobilePhone,Phone,campaign_cti__c
                                                    FROM Lead
                                                    WHERE Id in :leadsIds]);

        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT MobilePhone, Account.Phone, CustomerNumber__c  FROM Contact WHERE Id IN :contactsIds]);
        
        //Llamamos a la función getContactInsurance, para recuperar un set que contega ContactID-Ramo Oportunidad.
        Set<String> sContactInsurance = getContactInsurance(contactsMap.keySet());

        CESS_BulkifiedCTIRequestDto.UpdateCalls icc = new CESS_BulkifiedCTIRequestDto.UpdateCalls();

        String sObjectToUse = 'None';
        String tlf = '';
        String skill = '';
        String order ='';
        String oNumber='';
        String nombreCamp = '';
        Boolean valuePreview;
        Boolean hasPreview = false;

        for (Task ts: taskList) {

            if ( ts.WhatId != null && opportunitiesMap.get(ts.WhatId) != null ) {
                sObjectToUse = 'Opportunity';
            } else if ( ts.WhoId != null && leadsMap.get(ts.WhoId) != null ) {
                sObjectToUse = 'Lead';
            } else if ( ts.WhoId != null && contactsMap.get(ts.WhoId) != null ) {
                sObjectToUse = 'Contact';
            }

            if ( sObjectToUse != 'Opportunity' || (sObjectToUse == 'Opportunity' && Boolean.valueOf(CESS_CTI_ENVIOOPORTUNIDADESPLANIFICADAS)) || Test.isRunningTest() ) {

                String sched_time = ((Datetime)ts.CESS_Fecha_Planificada__c).format('yyyy-MM-dd HH:mm:ss'); //TODO: Validate if this info is needed for Delete

                List <String> columns = new List <String>{'external_id','lead_number','order_number','skills','source_datetime','tel_contact1'};
                List <String> values = new List<String>();
                CampaignMember cm = new CampaignMember();

                if ( sObjectToUse == 'Opportunity' ) {
                    if( cMembersRelated.get(opportunitiesMap.get(ts.WhatId).relatedCTICampaignMemberId__c) != null ){
                        cm = cMembersRelated.get(opportunitiesMap.get(ts.WhatId).relatedCTICampaignMemberId__c);
                        tlf = cm.MobilePhone != null? cm.MobilePhone : cm.Phone;
                        skill = cm.CTIClientSkill__c != null? cm.CTIClientSkill__c : CESS_CTIPLAN_SKILL;
                        order = cm.CTIOrder__c != null ? string.valueOf(cm.CTIOrder__c) : CESS_CTIPLAN_ORDER;
                        oNumber = cm.ClientOrLeadNumber__c;
                        nombreCamp = cm.Campaign.Name;
                    }else{
                        tlf = opportunitiesMap.get(ts.WhatId).phone__c == null ? (ts.Account.PersonMobilePhone == null ? ts.Account.Phone : ts.Account.PersonMobilePhone) : opportunitiesMap.get(ts.WhatId).phone__c;
                        skill = opportunitiesMap.get(ts.WhatId).Skill__c == null ? CESS_CTIPLAN_SKILL : opportunitiesMap.get(ts.WhatId).Skill__c;
                        order = CESS_CTIPLAN_ORDER;
                        oNumber = opportunitiesMap.get(ts.WhatId).Account.PersonContact.CustomerNumber__c;
                        nombreCamp = opportunitiesMap.get(ts.WhatId).CTI_Campaign__c;
                    }

                } else if ( sObjectToUse == 'Lead' ) {
                    //Se toma el CampMember referenciado en CampaignMemberId__c de Tarea, si no existe se toman valores por defecto
                    if( cMembersRelated.get(ts.CampaignMemberId__c) != null ){
                        cm = cMembersRelated.get(ts.CampaignMemberId__c);
                        tlf = cm.MobilePhone != null? cm.MobilePhone : cm.Phone;
                        skill = cm.CTIClientSkill__c != null? cm.CTIClientSkill__c : CESS_CTIPLAN_SKILL;
                        order = cm.CTIOrder__c != null ? string.valueOf(cm.CTIOrder__c) : CESS_CTIPLAN_ORDER;
                        oNumber = cm.ClientOrLeadNumber__c;
                        nombreCamp = cm.Campaign.Name;
                    }else{
                        tlf = leadsMap.get(ts.WhoId).MobilePhone == null ? (leadsMap.get(ts.WhoId).Phone == null ? '' : leadsMap.get(ts.WhoId).Phone) : leadsMap.get(ts.WhoId).MobilePhone; //FPEREZ. Tlf añadido
                        oNumber = leadsMap.get(ts.WhoId).lead_number__c;
                        order = CESS_CTIPLAN_ORDER;
                        skill = CESS_CTIPLAN_SKILL;
                        nombreCamp = leadsMap.get(ts.WhoId).campaign_cti__c;
                    }

                } else if ( sObjectToUse == 'Contact' ) {

                    if( cMembersRelated.get(ts.CampaignMemberId__c) != null ){
                        cm = cMembersRelated.get(ts.CampaignMemberId__c);
                        tlf = cm.MobilePhone != null? cm.MobilePhone : cm.Phone;
                        skill = cm.CTIClientSkill__c != null? cm.CTIClientSkill__c : CESS_CTIPLAN_SKILL;
                        order = cm.CTIOrder__c != null ? string.valueOf(cm.CTIOrder__c) : CESS_CTIPLAN_ORDER;
                        oNumber = cm.ClientOrLeadNumber__c;
                        nombreCamp = cm.Campaign.Name;
                        //Comprobamos si la columna preview debe o no verse en función de si coincide el rampo del CM y de la Opp asociadas al contacto
                        if(sContactInsurance.contains(ts.WhoId+'-'+cm.LineInsurance__c)) {
                            valuePreview = true;
                        } else {
                            valuePreview = false;
                        }
                        hasPreview = true;
                    }else{
                        tlf = contactsMap.get(ts.WhoId).MobilePhone == null ? (contactsMap.get(ts.WhoId).Account.Phone == null ? '' : contactsMap.get(ts.WhoId).Account.Phone) : contactsMap.get(ts.WhoId).MobilePhone;
                        oNumber = contactsMap.get(ts.WhoId).CustomerNumber__c;
                        order = CESS_CTIPLAN_ORDER;
                        skill = CESS_CTIPLAN_SKILL;
                        nombreCamp = null;
                        hasPreview = false;
                    }
                }
                values = new List <String>{ts.Id,oNumber,order,skill,sched_time,tlf};

                //Se añaden 3 nuevos params si existen
                if (cm.Id != null){
                    columns.add('sf_cm_id');
                    values.add(cm.Id);
                }

                if (cm.SFURLPop__c != null){
                    columns.add('sf_urlpop');
                    values.add(cm.SFURLPop__c);
                }
                
                if(sObjectToUse == 'Contact' && hasPreview) {
                    columns.add('preview');
                    if(valuePreview) {
                        values.add('true');   
                    } else {
                        values.add('false');
                    }
                }

                CESS_BulkifiedCTIRequestDto.RequestUpsertContact ric = new CESS_BulkifiedCTIRequestDto.RequestUpsertContact();
                ric.front_code =  CESS_CTI_FRONTCODE ;
                ric.column_filter = CESS_CTI_COLUMNFILTER;
                ric.campaign_name = nombreCamp == null? '' : nombreCamp;

                for (String column: columns) {
                    ric.columns.add(column);
                }
                for (String value: values) {
                    ric.values.add(value);
                }

                CESS_BulkifiedCTIRequestDto.ScheduledPlanningCall spc = new CESS_BulkifiedCTIRequestDto.ScheduledPlanningCall();
                if ( sObjectToUse == 'Opportunity' ) {
                    spc.agent_id = ts.owner_ctiuser__c == null ? '' : ts.owner_ctiuser__c;
                }else if ( sObjectToUse == 'Lead' ) {
                    spc.agent_id = '';
                }else if ( sObjectToUse == 'Contact' ) {
                    spc.agent_id = '';
                }
                spc.phone_number = tlf;
                spc.sched_time = sched_time;
                ric.scheduled_planning_call = spc;
                icc.requestUpdateContactList.add(ric);
            }
        }

        try
        {
            CESS_BulkifiedCTIRestClient client = new CESS_BulkifiedCTIRestClient();
            CESS_BulkifiedCTIResponseDto.UpdateCalls updateResponse = client.updateCalls(icc);

            if ( updateResponse != null && updateResponse.response != null
                && updateResponse.response.results != null && updateResponse.response.results.size() > 0 ){

                setResponseErrors(tasksIds, updateResponse.response, false);
            }
            else {
                setResponseErrors(tasksIds, null, false);
            }

        } catch (Exception e) {
            System.debug('Error calling updateCalls: '+e);
        }

    }

    private void setResponseErrors(List<String> tasksIds, CESS_BulkifiedCTIResponseDto.Response response, Boolean isDelete) {
        Map<String, String> resultMap = new Map<String, String>();

        if ( response != null ){
            for ( String r: response.results ) {
                Map<String,String> rMap = parseResultToken(r);
                if ( rMap.size() > 0 && rMap.get('EXT_ID') != null ) {
                    String recordId = rMap.get('EXT_ID');
                    if ( rMap.get('STATUS') == 'ERROR' ) {
                        String errorMessage = rMap.get('MESSAGE');
                        resultMap.put(recordId, (errorMessage != null && errorMessage.length() > 0 )?errorMessage:'');
                    } else {
                        if ( rMap.get('STATUS') == 'OK' ) {
                            if ( isDelete )
                                resultMap.put(recordId, 'CANCELADA');
                            else
                                resultMap.put(recordId, 'OK');
                        }
                    }
                }
            }
        }

        List<Task> tasks = [select id, subject, WhatId from task where id in :tasksIds];

        for (Task t: tasks) {
            // Comprobamos si la tarea viene de oportunidad, en caso de que venga hay que revisar el custom setting de CESS_CTI_ENVIOOPORTUNIDADESPLANIFICADAS
            if ( !(t.WhatId != null && ((String) t.WhatId).startsWith('006')) || (t.WhatId != null && ((String) t.WhatId).startsWith('006') && Boolean.valueOf(CESS_CTI_ENVIOOPORTUNIDADESPLANIFICADAS)) || Test.isRunningTest() ) {
                if ( resultMap.get(t.Id) != null ) {
                    t.cti_error__c = resultMap.get(t.Id) + ' ' + String.valueOf(System.currentTimeMillis());
                    t.Subject = resultMap.get(t.Id) + ' ** ' + t.Subject;
                }
                else { // Jsuarez: error come without external_id to identify the task
                    t.cti_error__c = 'KO ' + String.valueOf(System.currentTimeMillis());
                    t.Subject = 'KO ** ' + t.Subject;
                }
            }
        }

        update tasks;
    }

    private Map<String, String> parseResultToken(String token) {
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
    
    /**
    @description Función para recuperar un set de IdContacto-Ramo Opp
    @param Set<Id> sContact
    @return Set<String> sContactInsurance
    */
    private Set<String> getContactInsurance(Set<Id> sContact) {

        Set<String> sContactInsurance = new Set<String>();
        //Comprobamos si tenemos contactos.
        if(!sContact.isEmpty()) {
            //Recuperamos las oportunidades relacionadas a los contactos.
            List<Opportunity> oppsRelatedContact = [SELECT line_insurance__c, Account.PersonContactId, IsClosed FROM Opportunity 
                WHERE Account.PersonContactId IN :sContact];
            // Si la oportunidad está abierta añadimos al set IdContacto-RamoOpp
            for(Opportunity o : oppsRelatedContact) {
                if(!o.IsClosed) {
                    sContactInsurance.add(o.Account.PersonContactId+'-'+o.line_insurance__c);
                }
            }
        }
        return sContactInsurance;
    }

}