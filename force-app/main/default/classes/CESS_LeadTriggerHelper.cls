/**********************************************************************************
* @name         	CESS_LeadTriggerHelper
* @version			1.0
* @creation date    28/04/2020
* @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Apex Class with the functionality of the helper for Lead
* @group        	Helper
* @revision         AUTHOR          DATE        Reason
                    MSC - LCS       03/02/2023  Añadir nuevos campos de Lead que se pasan en la creación del Platform Event
                    MHG - LCS       05/11/2022  Fix- Hacemos que No se lance la consulta de contactos duplicados si no hay mobil ni telefono ni email ni documento
                    MHG - LCS       05/11/2022  Fix- Query no selectiva al buscar duplicados de Lead o de Contacto de "sendPlatformEvents"
                    MMV - LCS       06/09/2022  Fix- para que no falle el método deleteCTILead
                    MMV - LCS       02/09/2022  Añado la funcionalidad de asignar al lead la tarea de llamada entrante
                    MHG - LCS       02/07/2022  Cambio de campos deprecados de Lead a sus versiones nuevas en la creación del Platform Event
                    MMV - LCS       08/06/2022  Añado a la búsqueda de leads que no esté convertido
                    MMV - LCS       25/05/2022  Quito el funcionamiento de checkIsNIFCIFNIEValid para que no haga cambios en el miembro de campaña, no tiene sentido ahora (too many queries)
                    MMV - LCS       09/05/2022  Solo se crean los cm creation event si hay un matched record Id (existe ya un lead o un contacto)   
                    MMV - LCS       21/04/2022  Añado un switch para poder desactivar la validación del borrado de Leads     
                    JNM - LCS       29/03/2022  Añadida la creación de platform events con todos los campos            
                    MMV - LCS       28/03/2022  Añado el método para setear el campo management_sf__c    
                    JCB - LCS       03/07/2023  Añadido campo GCLID__c en Platform Event.                   
**********************************************************************************/
public class CESS_LeadTriggerHelper {

    /* The name of the class */
    private static String CLASS_NAME = CESS_LeadTriggerHelper.class.getName();
    /**********************************************************************************
    * @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
    * @creation date    28/04/2020
    * @description  	Validate documentation
    * @param header		the header for csv out
    * @param issuedLead	Lead
    *********************************************************************************/
	
    public static void checkIsNIFCIFNIEValid(final Lead issuedLead) {
        String myUser = UserInfo.getUserName();
        
        String usersNotValidateDoc = ORG_AppSettingsUtils.getSetting('CESS_notValidateDoc');
        Set<String> setUsers = new Set<String>();
        if(usersNotValidateDoc!='' && usersNotValidateDoc!=null){
            List<String> lstUsers = usersNotValidateDoc.split(';');
        	setUsers = new Set<String>(lstUsers);
        }
        Boolean validar = false;
        if(!validar && (setUsers.size()==0 || (setUsers.size()>0 &&!setUsers.contains(myUser)))){
           if(!String.isEmpty(issuedLead.document_number__c ) && (issuedLead.document_number__c.length() > 9) ){
               String validDoc = issuedLead.document_number__c.right(9);
               issuedLead.document_number__c = validDoc;
            }
            if (!String.isEmpty(issuedLead.document_number__c) && 
                    !String.isEmpty(issuedLead.document_type__c ) &&
                    issuedLead.document_type__c  == 'NIF' &&
                    !ORG_helperObjects.isNifValid(issuedLead.document_number__c ) &&
                    !ORG_helperObjects.isNCValid(issuedLead.document_number__c ) ) {
                    issuedLead.addError('Número de NIF incorrecto.');
            }
            else if (!String.isEmpty(issuedLead.document_number__c) && 
                       !String.isEmpty(issuedLead.document_type__c ) &&
                       issuedLead.document_type__c == 'CIF' &&
                       !ORG_helperObjects.isCifValid(issuedLead.document_number__c)) {
                issuedLead.addError('Número de CIF incorrecto.');
            }
            else if (!String.isEmpty(issuedLead.document_number__c) && 
                       !String.isEmpty(issuedLead.document_type__c ) &&
                       issuedLead.document_type__c == 'NIE' &&
                       !ORG_helperObjects.isNieValid(issuedLead.document_number__c)) {
                issuedLead.addError('Número de NIE incorrecto.');
            }
        } else if(validar){
            issuedLead.Bypass_ValidacionConsultaCESS__c = false;
        }       
    }
    
    public static void addLeadsToDelete(final Lead ld, List<String> taskToDeleteId){	
        Lead l = (Lead) ld;	
        if ( l.Status == 'Unqualified' ) {	
            taskToDeleteId.add(l.Id);            	
        }	
    }	
    public static Boolean checkLeadsToDelete(List<String> taskToDeleteId, Boolean hasUpdateTasks){	
        if ( taskToDeleteId.size() > 0 && hasUpdateTasks == false ) {	
            hasUpdateTasks = true; 	
            	
            List<Task> totalTasksToDelete = [select id from task where whoid in :taskToDeleteId and type='Schedule Call' and cess_fecha_planificada__c >= YESTERDAY];	
            for ( Task t: totalTasksToDelete ) {	
                t.Status = 'Completed';                	
            }	
            update totalTasksToDelete;	
        } 	
        return hasUpdateTasks;	
    }
    
   
	/**********************************************************************************
    * @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
    * @creation date    13/11/2020
    * @description  	inetration with Lead
    * @param issuedLead	Lead
    *********************************************************************************/
    
    public static void deleteCTILead(final List<Lead> lstLeads) {

        // DECLARACION DE VARIABLES
        List<Id> lstLeadsToDelete = new List<Id>();
        List<CampaignMember> lCMember = new List<CampaignMember>();
        Map <Id,CampaignMember> mLeadCM = new Map<Id,CampaignMember>();
        CampaignMember issuedCMember = null;

        // Buscamos los miembros de campaña CTI de los leads
        lCMember = [SELECT id,CTISent__c,CTIIntergrationStatus__c,LeadId,result__c,RecordTypeid 
                    FROM CampaignMember 
                    WHERE LeadId IN :lstLeads 
                    AND RecordType.DeveloperName = 'CTI' ];

        // Si encontramos alguno evaluamos las acciones
        if(lCMember.size() >0){

            // Generamos un mapa indexando los CM CTI por su Lead
            for(CampaignMember mapedCMember : lCMember){
                mLeadCM.put(mapedCMember.LeadId,mapedCMember); 
            }

            for(Lead issuedLead : lstLeads){

                issuedCMember = mLeadCM.get(issuedLead.id);
                // Si el Lead tiene algún miembro de campaña en la lista y cumple las condiciones se le añade a la lista para borrar de CTI el dato
                if( issuedCMember != null ){
                    if( (issuedCMember.CTIIntergrationStatus__c == CESS_Constantes.PDT_DELETE_CTI && 
                        (issuedLead.Status == CESS_Constantes.LEAD_NEW_STATUS || (issuedCMember.result__c == CESS_Constantes.LEAD_DUPLICADO_RESULT && issuedLead.Status == CESS_Constantes.LEAD_UNQUALIFIED_STATUS))
                        && issuedCMember.CTISent__c == true)
                        || (issuedLead.IsConverted && issuedCMember.CTISent__c == true && issuedCMember.CTIIntergrationStatus__c == CESS_Constantes.SIN_INT_CTI)){

                        lstLeadsToDelete.add(issuedLead.Id);
                    }
                }                
            }

            // Si la lista no está vacía llamamos el sigiuente método
            if(!lstLeadsToDelete.isEmpty()){
                deleteLeadsFromCTI(lstLeadsToDelete);
            }
        } 
    } 

    /**
     * @description Retrieves the Lead id, search open opportunities for this customer and check management_sf__c
     * @param List Leads Listado de leads que viene de la inserción
     * @return 
     */
    public static void setManagementSF (List <Lead> lLead){

        // VARIABLES
        // Para agrupar todos los valores en los Leads y extraer las cuentas relacionadas
        Set<String> sIdentifiercesspc = new Set<String>();
        Set<String> sIdentifieranetopc = new Set<String>();
        Set<String> sPersonaldocumentpc = new Set<String>();
        Set<String> sPersonEmail = new Set<String>();
        Set<String> sPersonAssistantPhone = new Set<String>();
        Set<String> sPhone = new Set<String>();
        // Para indexar las cuentas encontradas y facilitar su mapeo
        Map<String,Id> mIdentifiercesspcAccountId = new Map<String,Id>();
        Map<String,Id> mIdentifieranetopcAccountId = new Map<String,Id>();
        Map<String,Id> mPersonaldocumentpcAccountId = new Map<String,Id>();
        Map<String,Id> mPersonEmailAccountId = new Map<String,Id>();
        Map<String,Id> mPersonAssistantPhoneAccountId = new Map<String,Id>();
        Map<String,Id> mPhoneAccountId = new Map<String,Id>();
        
        Set<Id> sAccountIds = new Set<Id>();
        Set<Id> sAccIdWithOpenOpps = new Set<Id>();
        
        // Iteramos los Leads y agrupamos sus valores en los Set
        for (Lead l : lLead){

            if( !String.isEmpty(l.identifier_cess__c) ) sIdentifiercesspc.add(l.identifier_cess__c);
            if( !String.isEmpty(l.identifier_aneto__c) ) sIdentifieranetopc.add(l.identifier_aneto__c);
            if( !String.isEmpty(l.document_number__c) ) sPersonaldocumentpc.add(l.document_number__c);
            if( !String.isEmpty(l.Email) ) sPersonEmail.add(l.Email);
            if( l.MobilePhone != null ) sPersonAssistantPhone.add(l.MobilePhone);
            if( l.Phone != null ) sPhone.add(l.Phone);

        }
        // Buscamos las cuentas que cumplan alguno de esos criterios y las iteramos para rellenar los mapas
        for(Account acc : [SELECT Id, identifier_cess__pc, identifier_aneto__pc, personal_document__pc, PersonEmail, PersonAssistantPhone, Phone
                            FROM Account 
                            WHERE identifier_cess__pc IN: sIdentifiercesspc 
                            OR identifier_aneto__pc IN: sIdentifieranetopc
                            OR personal_document__pc IN: sPersonaldocumentpc
                            OR PersonEmail IN: sPersonEmail
                            OR PersonAssistantPhone IN: sPersonAssistantPhone
                            OR Phone IN: sPhone]){

            mIdentifiercesspcAccountId.put(acc.identifier_cess__pc, acc.Id);
            mIdentifieranetopcAccountId.put(acc.identifier_aneto__pc, acc.Id);
            mPersonaldocumentpcAccountId.put(acc.personal_document__pc, acc.Id);
            mPersonEmailAccountId.put(acc.PersonEmail, acc.Id);
            mPersonAssistantPhoneAccountId.put(acc.PersonAssistantPhone, acc.Id);
            mPhoneAccountId.put(acc.Phone, acc.Id);
            sAccountIds.add(acc.Id);
        }

        if( !sAccountIds.isEmpty() ){
            // Buscamos las oportunidades de esas cuentas y los mapeamos por AccountId
            for(Opportunity opp: [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN: sAccountIds AND (Probability > 0 AND Probability < 100)]){
                sAccIdWithOpenOpps.add(opp.AccountId);
            }
        }    

        for (Lead l: lLead){
            
            //buscar Gestiones abiertas en SF (si el cliente está identificado)
            //Get AccountId
            String accountIdAux = null;            
            
            // Buscamos las cuentas priorizando por: identifier_cess__pc, identifier_aneto__pc, personal_document__pc
            accountIdAux = !String.isBlank(l.identifier_cess__c) ? mIdentifiercesspcAccountId.get(l.identifier_cess__c) :
                            !String.isBlank(l.identifier_aneto__c) ? mIdentifieranetopcAccountId.get(l.identifier_aneto__c) :
                            !String.isBlank(l.document_number__c) ? mPersonaldocumentpcAccountId.get(l.document_number__c) :
                            null;
            // Si no se ha encontrado la cuenta por esos parámetros buscamos por email y/o teléfono
            accountIdAux = accountIdAux == null && !String.isBlank(l.Email) ? mPersonEmailAccountId.get(l.Email) : accountIdAux;
            accountIdAux = accountIdAux == null && !String.isBlank(l.MobilePhone) ? mPersonAssistantPhoneAccountId.get(l.MobilePhone) : accountIdAux;
            accountIdAux = accountIdAux == null && !String.isBlank(l.Phone) ? mPhoneAccountId.get(l.Phone) : accountIdAux;

            // Si hay alguna oportunidad abierta en esa cuenta marcamos el campo a true
            l.managements_sf__c = accountIdAux != null && sAccIdWithOpenOpps.contains(accountIdAux) ? true : false;  
            
        }//end for        
    } 

    /**
     * @description Relate the current call of the user, with the lead that has already created for the call
     * @param id (the lead id that have just created)
     * @return 
     */
    public static void relateTasktoLead (List<Lead> lNewLead){

        // Iteramos la lista de lead, y el que tenga marcado el campo le asignamos la tarea
        Id idLeadRelacionar = null;
        for(Lead l: lNewLead){
            idLeadRelacionar = l.asociarLeadLlamada__c ? l.Id : idLeadRelacionar;            
        }

        // Si hay un lead con ese campo a true buscamos la tarea y la relacionamos con el lead
        if( idLeadRelacionar != null ){
            List<Task> taskList = [SELECT Id, inin_remoteani__c, CreatedDate, Whoid 
                                FROM Task 
                                WHERE Task.OwnerId =: UserInfo.getUserId() 
                                AND inin_remoteani__c != null
                                AND Station__c != ''
                                AND Station__c != null
                                AND CallDurationInSeconds = null    
                                ORDER BY createdDate DESC limit 1];

            // Si se encuentra la tarea la relacionamos con los leads que tengan marcado el campo asociarLeadLlamada__c                       
            if( !taskList.isEmpty() )  { 
                Task task = taskList[0];
                task.WhoId = idLeadRelacionar;
                update task;                
            }
        }
    }
    
   
    /**********************************************************************************
    * @author       	Jesús Navarro -jnavarrom@leadclic.com
    * @creation date    28/02/2022
    * @description  	send platform evetns depending on existing contacts or leads
    * @param lstOldOri  the inserted list of Leads
    **********************************************************************************/
    public static void sendPlatformEvents(List<Lead> lstLead) {
        final String methodName = 'sendPlatformEvents';
        // Declare variables
        Set<String> sDocTypes = new Set<String>();
        Set<String> sNumDocs = new Set<String>();
        Set<String> sPhones = new Set<String>();
        Set<String> sMobilePhones = new Set<String>();
        Set<String> sEmails = new Set<String>();
        Map<String, SObject> mKeyObject = new Map<String, SObject>();
        
        final String leadObjName = Schema.Lead.getSObjectType().getDescribe().getName();
        final String contactObjName = Schema.Contact.getSObjectType().getDescribe().getName();
        List<CMCreationEvent__e> lstPlatformEvents = new List<CMCreationEvent__e>();
        Contact matchedContact;
        Lead matchedLead;
        CMCreationEvent__e singleEvent;
        Integer leadCounter = 0;
        Integer platformEventBlockSize = Integer.valueOf(ORG_ApplicationSettings__mdt.getInstance('CESS_CTI_EventBlockSize').Value__c);

        // En el Before se buscan coincidencias en Lead y Contact y si se encuentran se asocian los CM a ese registro
        if( Trigger.isBefore ){
            
            for(Lead ld:lstLead){
                if(ld.document_type__c != null) sDocTypes.add(ld.document_type__c);
                if(ld.document_number__c != null) sNumDocs.add(ld.document_number__c);
                if(ld.Phone != null) sPhones.add(ld.Phone);
                if(ld.MobilePhone != null) sMobilePhones.add(ld.MobilePhone);
                if(ld.Email != null) sEmails.add(ld.Email);
            }

            // Se construye la consulta de Leads en base a las listas que se an rellenado en el punto anterior
            // se hace dinámica porque estaba dando un error de "No selectiva" si se usaban los Sets directamente
            String queryContacts = 'SELECT Id, document_type__c, personal_document__c, Phone, MobilePhone, Email FROM Contact '+
                                'WHERE isFraudulent__c = false ';
            String queryContactsCondiciones = '';
            if (!sNumDocs.isEmpty()){
                queryContactsCondiciones += 'personal_document__c IN (';
                    for (String valor: sNumDocs){
                        queryContactsCondiciones += '\'' + valor + '\',';
                    }
                    queryContactsCondiciones = queryContactsCondiciones.removeEnd(',') + ')';
            }
            if (!sPhones.isEmpty()){
                if (queryContactsCondiciones <> ''){
                    queryContactsCondiciones += ' or ';
                }
                queryContactsCondiciones += 'Phone IN (';
                for (String valor: sPhones){
                    queryContactsCondiciones += '\'' + valor + '\',';
                }
                queryContactsCondiciones = queryContactsCondiciones.removeEnd(',') + ')';
            }
            if (!sMobilePhones.isEmpty()){
                if (queryContactsCondiciones <> ''){
                    queryContactsCondiciones += ' or ';
                }
                queryContactsCondiciones += 'MobilePhone IN (';
                for (String valor: sMobilePhones){
                    queryContactsCondiciones += '\'' + valor + '\',';
                }
                queryContactsCondiciones = queryContactsCondiciones.removeEnd(',') + ')';
            }
            if (!sEmails.isEmpty()){
                if (queryContactsCondiciones <> ''){
                    queryContactsCondiciones += ' or ';
                }
                queryContactsCondiciones += 'Email IN (';
                for (String valor: sEmails){
                    queryContactsCondiciones += '\'' + valor + '\',';
                }
                queryContactsCondiciones = queryContactsCondiciones.removeEnd(',') + ')';
            }
            if (queryContactsCondiciones != '') {
                queryContacts += ' and (' + queryContactsCondiciones + ')';
            }

            // Si no hay parámetros (queryContactsCondiciones está vacío) entonces no hacemos nada
            if (queryContactsCondiciones <> '') {
                // Se lanza la consulta
                List<Contact> contactList = Database.query(queryContacts);

                // Iteramos la consulta para añadir las claves al mapa de duplicados            
                for(Contact con : contactList){
                    if(!mKeyObject.containsKey(contactObjName + con.document_type__c + con.personal_document__c)){
                        mKeyObject.put(contactObjName + con.document_type__c + con.personal_document__c, con);
                    }
                    if(!mKeyObject.containsKey(contactObjName + con.Phone)){
                        mKeyObject.put(contactObjName + con.Phone, con);
                    }
                    if(!mKeyObject.containsKey(contactObjName + con.MobilePhone)){
                        mKeyObject.put(contactObjName + con.MobilePhone, con);
                    }
                    if(!mKeyObject.containsKey(contactObjName + con.Email)){
                        mKeyObject.put(contactObjName + con.Email, con);
                    }
                }
            }

            // Se construye la consulta de Leads en base a las listas que se an rellenado en el punto anterior
            // se hace dinámica porque estaba dando un error de "No selectiva" si se usaban los Sets directamente
            String queryLeads = 'SELECT Id, document_type__c, document_number__c, Phone, MobilePhone, Email '+
                                'FROM Lead WHERE isFraudulent__c = false AND IsConverted = false ';
            String queryLeadsCondiciones = '';
            if (!sNumDocs.isEmpty()){
                    queryLeadsCondiciones += 'document_number__c IN (';
                    for (String valor: sNumDocs){
                        queryLeadsCondiciones += '\'' + valor + '\',';
                    }
                    queryLeadsCondiciones = queryLeadsCondiciones.removeEnd(',') + ')';
            }
            if (!sPhones.isEmpty()){
                if (queryLeadsCondiciones <> ''){
                    queryLeadsCondiciones += ' or ';
                }
                queryLeadsCondiciones += 'PhoneAux__c IN (';
                for (String valor: sPhones){
                    queryLeadsCondiciones += '\'' + valor + '\',';
                }
                queryLeadsCondiciones = queryLeadsCondiciones.removeEnd(',') + ')';
            }
            if (!sMobilePhones.isEmpty()){
                if (queryLeadsCondiciones <> ''){
                    queryLeadsCondiciones += ' or ';
                }
                queryLeadsCondiciones += 'MobilePhoneAux__c IN (';
                for (String valor: sMobilePhones){
                    queryLeadsCondiciones += '\'' + valor + '\',';
                }
                queryLeadsCondiciones = queryLeadsCondiciones.removeEnd(',') + ')';
            }
            if (!sEmails.isEmpty()){
                if (queryLeadsCondiciones <> ''){
                    queryLeadsCondiciones += ' or ';
                }
                queryLeadsCondiciones += 'Email IN (';
                for (String valor: sEmails){
                    queryLeadsCondiciones += '\'' + valor + '\',';
                }
                queryLeadsCondiciones = queryLeadsCondiciones.removeEnd(',') + ')';
            }
            if (queryLeadsCondiciones != '') {
                queryLeads += ' and (' + queryLeadsCondiciones + ')';
            }

            // Si no hay parámetros (queryLeadsCondiciones está vacío) entonces no hacemos nada
            if (queryLeadsCondiciones <> '') {
                // Se lanza la consulta
                List<Lead> leadList = Database.query(queryLeads);

                // Iteramos la consulta para añadir las claves al mapa de duplicados
                for(Lead ld : leadList){
                    if(!mKeyObject.containsKey(leadObjName + ld.document_type__c + ld.document_number__c)) {
                        mKeyObject.put(leadObjName + ld.document_type__c + ld.document_number__c, ld);
                    }
                    if(!mKeyObject.containsKey(leadObjName + ld.Phone)) {
                        mKeyObject.put(leadObjName + ld.Phone, ld);
                    }
                    if(!mKeyObject.containsKey(leadObjName + ld.MobilePhone)) {
                        mKeyObject.put(leadObjName + ld.MobilePhone, ld);
                    }
                    if(!mKeyObject.containsKey(leadObjName + ld.Email)) {
                        mKeyObject.put(leadObjName + ld.Email, ld);
                    }
                }
            }
        }

        // Loop over inserted leads and evaluate their correspondence
        for(Lead ld : lstLead){

            leadCounter++;
            singleEvent = new CMCreationEvent__e();
            // Set all fixed lead data to platform event
            singleEvent.sourceLeadDocumentType__c = ld.document_type__c;
            singleEvent.sourceLeadNumber__c = ld.document_number__c;
            singleEvent.sourceLeadEmail__c = ld.Email;
            singleEvent.sourceLeadPhone__c = ld.Phone;
            singleEvent.sourceLeadMobilePhone__c = ld.MobilePhone;
            singleEvent.Campaign__c = ld.campaign__c;
            singleEvent.campaignCESS__c = ld.campaign_cess__c;
            singleEvent.campaignCTI__c = ld.Campaign_CTI_Picklist__c;
            singleEvent.referenceCampaign__c = ld.reference_campaign__c;
            singleEvent.quoteCode__c = ld.quote_code__c;
            singleEvent.riskPostalcode__c = ld.risk_postalcode__c;
            singleEvent.insuranceCompany__c = ld.insurance_company__c;
            singleEvent.riskDescription__c = ld.risk_description__c;
            singleEvent.riskdriverLicensedate__c = ld.riskdriver_licensedate__c;
            singleEvent.riskownerLicensedate__c = ld.riskowner_licensedate__c;
            singleEvent.riskpolicyholderLicensedate__c = ld.riskpolicyholder_licensedate__c;
            singleEvent.birthdate__c = ld.birthdate__c;
            singleEvent.renewalDate__c = ld.renewal_date__c;
            singleEvent.riskInsuredBirthDate__c = ld.riskinsured_birthdate__c;
            singleEvent.riskDriverBirthDate__c = ld.riskdriver_birthdate__c;
            singleEvent.riskOwnerBirthDate__c = ld.riskowner_birthdate__c;
            singleEvent.riskPolicyHolderBirthDate__c = ld.riskpolicyholder_birthdate__c;
            singleEvent.riskExpirationdate__c = ld.risk_expirationdate__c;
            singleEvent.IdExterno__c = ld.IdExterno__c;
            singleEvent.CESSIDDisplayAdvertisments__c = ld.CESS_IDDisplayAdvertisments__c;
            singleEvent.CESSIDGoogleAnalytics__c = ld.CESS_IDGoogleAnalytics__c;
            singleEvent.CESSIdPricing__c = ld.CESS_IdPricing__c;
            singleEvent.riskBrand__c = ld.risk_brand__c;
            singleEvent.sourceType__c = ld.source_type__c;
            singleEvent.riskSquaremetres__c = ld.risk_squaremetres__c;
            singleEvent.riskCategory__c = ld.risk_category__c;
            singleEvent.riskModel__c = ld.risk_model__c;
            singleEvent.riskinsuredNumber__c = ld.riskinsured_number__c;
            singleEvent.sourceCess__c = ld.source_cess__c;
            singleEvent.referencesourceCess__c = ld.referencesource_cess__c;
            singleEvent.LeadSource__c = ld.LeadSource;
            singleEvent.sourceManualrecord__c = ld.source_manualrecord__c;
            singleEvent.sourceWeb__c = ld.sourceWeb__c;
            singleEvent.riskTenant__c = ld.risk_tenant__c;
            singleEvent.lineInsurance__c = ld.line_insurance__c;
            singleEvent.ageRange__c = ld.age_range__c;
            singleEvent.riskGender__c = ld.risk_gender__c;
            singleEvent.riskEcicard__c = ld.risk_ecicard__c;
            singleEvent.campaingtypeCess__c = ld.campaingtype_cess__c;
            singleEvent.riskPropertytype__c = ld.risk_propertytype__c;
            singleEvent.CESSScoring__c = ld.CESS_Scoring__c;
            singleEvent.riskVersion__c = ld.risk_version__c;
            singleEvent.source_web__c = ld.source_web__c;
            singleEvent.SalesSlip__c = ld.SalesSlip__c;
            singleEvent.MerchandiseType__c = ld.MerchandiseType__c;
            singleEvent.DescriptionMerchandise__c = ld.DescriptionMerchandise__c;
            singleEvent.AmountMerchandise__c = ld.AmountMerchandise__c;
            singleEvent.OtherRiskData__c = ld.OtherRiskData__c;
            singleEvent.RiskAddress__c = ld.RiskAddress__c;
            singleEvent.RiskLocation__c = ld.RiskLocation__c;
            singleEvent.RiskProvince__c = ld.RiskProvince__c;
            singleEvent.RiskOptionCapitalInsured__c = ld.RiskOptionCapitalInsured__c;
            singleEvent.InsuredRisk__c = ld.InsuredRisk__c;
            singleEvent.order__c = ld.order__c;
            singleEvent.skill__c = ld.skill__c;
            singleEvent.GCLID__c = ld.GCLID__c;

            // En el Before puede haber un registro encontrado, en el after nunca lo habrá, porque el Lead se ha insertado
            if( Trigger.isBefore ){

                // Contact founded
                if( getMatchedRecord(contactObjName, ld, mKeyObject) != null ) {
                    matchedContact = (Contact) getMatchedRecord(contactObjName, ld, mKeyObject);
                    singleEvent.matchedRecordId__c = matchedContact.Id;
                    
                // Lead founded
                } else if ( getMatchedRecord(leadObjName, ld, mKeyObject) != null ) {
                    matchedLead = (Lead) getMatchedRecord(leadObjName, ld, mKeyObject);
                    singleEvent.matchedRecordId__c = matchedLead.Id;
                    
                // Lead doesn't match
                } else {
                    singleEvent.matchedRecordId__c = null;
                }

            }else{
                // Si se ejecuta en After significa que el Lead se ha insertado, por lo tanto no habrá registros coincidentes y el matched record siempre es el Lead
                singleEvent.matchedRecordId__c = ld.Id;
            }            

            // Add to events list if matchedRecordId != null
            // Si se añaden los eventos en el before insert, se ejecuta el flow On CM Creation Event insert antes de que se cree el Lead, por lo tanto no se asignan correctamente los CcampaigMember
            if( !String.isBlank(singleEvent.matchedRecordId__c) ) lstPlatformEvents.add(singleEvent);

            // Send events list if size matches or the list is finished
            if(!lstPlatformEvents.isEmpty() && (lstPlatformEvents.size() == platformEventBlockSize || leadCounter == lstLead.size())) {

                // Send bulk platform events
                List<Database.SaveResult> lstSR = EventBus.publish(lstPlatformEvents);

                // Inspect results
                for(Database.SaveResult sr:lstSR){
                    if (!sr.isSuccess()) {
                        for(Database.Error e : sr.getErrors()) {
                            ld.addError(e.getMessage());
                        }
                    }
                }
                // Clear list
                lstPlatformEvents.clear();
            }
        }        
    }

    private static SObject getMatchedRecord(String sObjectName, Lead currentLead, Map<String, SObject> mKeyObject) {

        SObject objectResult;

        if( !String.isBlank(currentLead.document_number__c) && mKeyObject.containsKey(sObjectName + currentLead.document_type__c + currentLead.document_number__c)) {
            objectResult = mKeyObject.get(sObjectName + currentLead.document_type__c + currentLead.document_number__c);
        }
        else if(!String.isBlank(currentLead.Phone) && mKeyObject.containsKey(sObjectName + currentLead.Phone)) {
            objectResult = mKeyObject.get(sObjectName + currentLead.Phone);
        }
        else if(!String.isBlank(currentLead.MobilePhone) && mKeyObject.containsKey(sObjectName + currentLead.MobilePhone)){
            objectResult = mKeyObject.get(sObjectName + currentLead.MobilePhone);
        }
        else if(!String.isBlank(currentLead.Email) && mKeyObject.containsKey(sObjectName + currentLead.Email)){
            objectResult = mKeyObject.get(sObjectName + currentLead.Email);
        }

        return objectResult;

    }
    
   
    /**********************************************************************************
    * @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
    * @creation date    17/11/2020
    * @description  	Validations to delete Lead
    * @param lstOldOri  the deleted list of Leads
    **********************************************************************************/
    public static void validateDelete(List<Lead> lstLead) {

        // Comprobamos que el switch no este activado
        SwitchesConfiguration__c switches = SwitchesConfiguration__c.getOrgDefaults();
        if( !switches.DesactiveValidationDeleteLead__c ){
            final String methodName = 'validateDelete';
            Map<Id, String> mapLeadError = new Map<Id, String>();
            List<CampaignMember> lCMember = [SELECT id,CTISent__c,CTIIntergrationStatus__c,LeadId,result__c,RecordTypeid FROM CampaignMember WHERE LeadId IN :lstLead AND RecordType.DeveloperName = 'CTI' ];
            Map <Id,CampaignMember> mLeadCMemeber= new Map<Id,CampaignMember>();
            for(CampaignMember mapedCMember : lCMember){
                if(lCMember.size() >0){
                mLeadCMemeber.put(mapedCMember.LeadId,mapedCMember); 
                }
            }
            if(lCMember.size() >0){
                for(Lead ld :lstLead){
                    CampaignMember issuedCMember = mLeadCMemeber.get(ld.id);
                    if( (ld.Status == CESS_Constantes.LEAD_NEW_STATUS || (issuedCMember.result__c == CESS_Constantes.LEAD_DUPLICADO_RESULT && ld.Status == CESS_Constantes.LEAD_UNQUALIFIED_STATUS))
                    && issuedCMember.CTISent__c == True && issuedCMember.CTIIntergrationStatus__c != CESS_Constantes.SUCCESS_DELETE_CTI){
                        ld.addError('Error al eliminar, no se eliminó del CTI');
                    }
                }
            }  
        }        
    }
    
    @Future(callout=True)
    @testvisible
    private static void deleteLeadsFromCTI(List<Id> leadsIds) {
      
        List<Id> opportunitiesIds = new List<Id>();
        List<Lead> leads = new List<Lead>();
       // usar o borrar CESS_DeleteLeadCTIRequestDto
        CESS_BulkifiedCTIRequestDto.DeleteCalls request = new CESS_BulkifiedCTIRequestDto.DeleteCalls();
        for(Lead ld : [SELECT Id,lead_number__c,campaign_cti__c,status FROM Lead WHERE Id IN : leadsIds]) {
            CESS_BulkifiedCTIRequestDto.RequestDeleteContact ric = new CESS_BulkifiedCTIRequestDto.RequestDeleteContact();
            ric.values.add(ld.Id);
            ric.columns.add('external_id');
            ric.front_code = '25FEE590';
            ric.column_filter = 'external_id';
            if(ld.campaign_cti__c <> null) ric.campaign_name = ld.campaign_cti__c;
            request.requestDeleteContactList.add(ric);
        }
   
        try
        {
            CESS_BulkifiedCTIRestClient client = new CESS_BulkifiedCTIRestClient();
            CESS_BulkifiedCTIResponseDto.DeleteCalls deleteResponse = client.deleteLeadInCTI(request);

            if ( deleteResponse != null && deleteResponse.response != null
                && deleteResponse.response.results != null && deleteResponse.response.results.size() > 0 ){
                setResponse(leadsIds, deleteResponse.response, true);                                    
            }
            else {
                leads = [select id,status,lead_number__c from Lead where Id  in :leadsIds];
                List<CampaignMember> lCMember = [SELECT id,CTISent__c,CTIIntergrationStatus__c,LeadId,result__c,RecordTypeid FROM CampaignMember WHERE LeadId IN :leads AND RecordType.DeveloperName = 'CTI' ];
        		Map <Id,CampaignMember> mLeadCMemeber= new Map<Id,CampaignMember>();
       			for(CampaignMember mapedCMember : lCMember){
                	if(lCMember.size() >0){
               			mLeadCMemeber.put(mapedCMember.LeadId,mapedCMember); 
            		}
       			}
                String resultado;
                List<CampaignMember> issuedCMembertoUpdate = new List<CampaignMember>();
                for (Lead ld: leads) { 
                    CampaignMember issuedCMember = mLeadCMemeber.get(ld.id);
                    issuedCMember.CTIIntergrationStatus__c = 'Eliminación fallida';
                    issuedCMember.CTIDeleteError__c = 'Error al eliminar del CTI : No responde.' ;
                    issuedCMembertoUpdate.add(issuedCMember);
                }
                update issuedCMembertoUpdate;
            } 
        } catch (Exception e) {
        }               
    }
    public static void setResponse(List<String> leadsIds, CESS_BulkifiedCTIResponseDto.Response response, Boolean isDelete) {
        Map<String, String> resultMap = new Map<String, String>();
        List<Lead> lstLeadsToDelFromSF = new List<Lead>();
        if ( response != null ){
            for ( String r: response.results ) {
                Map<String,String> rMap = parseResultToken(r);
                if ( rMap.size() > 0 && rMap.get('EXT_ID') != null ) {
                    String recordId = rMap.get('EXT_ID');
                    if ( rMap.get('STATUS') == 'ERROR' ) {
                        String errorMessage = rMap.get('MESSAGE');
                        resultMap.put(recordId, (errorMessage != null && errorMessage.length() > 0 )?errorMessage:'');                    
                    } else {
                        if ( rMap.get('STATUS') == 'OK' ) resultMap.put(recordId, 'OK');
                    }
                } 
            }
        }
                        
        List<Lead> leads = [select id,status,lead_number__c from Lead where Id  in :leadsIds];
        String resultado;
        CampaignMember issuedCMember  = new CampaignMember();
        List<CampaignMember> lCMemberToUpdate = new List<CampaignMember>();
        List<CampaignMember> lCMember = [SELECT Id,CTISent__c,CTIIntergrationStatus__c,LeadId,result__c,RecordTypeid FROM CampaignMember WHERE LeadId IN :leads AND RecordType.DeveloperName = 'CTI' ];
        Map <Id,CampaignMember> mLeadCMemeber= new Map<Id,CampaignMember>();
        for(CampaignMember mapedCMember : lCMember){
            if(lCMember.size() >0){
               mLeadCMemeber.put(mapedCMember.LeadId,mapedCMember); 
            }
        }
        for (Lead ld: leads) { 
            //Recuperamos el miembro de campaña relacionado con el lead
            if(resultMap.get(ld.Id) != null){
                resultado = resultMap.get(ld.Id);
                if(lCMember.size() >0){
                     issuedCMember = mLeadCMemeber.get(ld.Id);
                    if(resultado == 'OK'){
                        issuedCMember.CTIIntergrationStatus__c = CESS_Constantes.SUCCESS_DELETE_CTI;
                        issuedCMember.CTIDeleteError__c = CESS_Constantes.INT_DELETE_CTI_SUCCESS;
                       
                    } else{
                        if(issuedCMember != null){
                            issuedCMember.CTIIntergrationStatus__c = 'Eliminación fallida';
                            issuedCMember.CTIDeleteError__c = 'Error al eliminar del CTI : ' + +resultado;
                        }
                    }
                     lCMemberToUpdate.add(issuedCMember);
                }
                
            }
        }
        if(issuedCMember != null){
        	update lCMemberToUpdate;
        }
    }
    
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
      //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class CESS_LeadTriggerHelperException extends Exception {}
}