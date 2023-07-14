/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         22/05/2018
* @group        Test
* @description  Test class for utility test methods.
* @Revision
*   FECHA       AUTOR       DESCRIPCION<br/>
*   06/11/2022  LCS - MHG   Cambio de teléfono en creación de cuentas para que sea diferente en cada cuenta
*   18/05/2022  LCS - MMV   Añadido el MobilPhone a la creación del Lead.
* @revision     LCS - NestorR   31/05/2022 Modificados los métodos newLead() y newPersonAccount() para evitar problemas de validacion y duplicados
**********************************************************************************/
@IsTest
public class ORG_TestDataUtils {
	
    //ATTRIBUTES
    private final ORG_RecordTypeUtils rtUtils;
	private final Id personAccountRecordTypeId;
    //CONSTANTS
    public static final String CTI_STATUS_PDT_ELIMINAR = 'Pendiente de eliminar';
    public static final String labelEmailAdresses = 'LabelEmailCCAdresses@iecisa.com';
    public static final String labelEmailCCAdresses = 'LabelEmailCCAdresses@iecisa.com';
    public static final String nameCsvOut = 'NameCsvOut Email';
    public static final String subject = 'Subject Email';
    public static final String body = 'Body Email';
    public static final String header = 'Header1,header2';
    
    /*Case Status Cancelado*/
    public static final String CASE_STATUS_CANCELADO = 'SAC_04_Cancelado';
    /*Case Status Cerrado*/
    public static final String CASE_STATUS_CLOSED = 'SAC_03_Closed';
    /*Case Status Nuevo */
    public static final String CASE_STATUS_NEW = 'SAC_01_New';
    /*Case Closed reason automatico*/
    public static final String CIERRE_FALTA_RESPUESTA = 'SAC_13_Falta de respuesta de cliente';
    /*Case Closed comment falta contestación Cliente*/
    public static final String COMMENT_FALTA_RESPUESTA = 'Falta respuesta del cliente';
    
    
     /*QUEUE CENTRAL SIN ASIGNAR*/
    public static final String QUEUE_CENTRAL_SIN_ASIGNAR = 'CENTRAL SIN ASIGNAR';
    
    /*Case Type Promoción*/
     public static final String CASE_TYPE_PROMOCION = 'Promoción';
    /*Case Origin Formulario App*/
    public static final String CASE_ORIGIN_FORMAPP = 'Formulario App';
    //CONSTRUCTOR
    private ORG_TestDataUtils() {
        this.rtUtils = ORG_RecordTypeUtils.getInstance();
        
        List<ORG_RecordTypeUtils.RecordTypeWrapper> recordTypes = rtUtils.getRt(SObjectType.Account.name);
        for(ORG_RecordTypeUtils.RecordTypeWrapper rt : recordTypes) {
            if(rt.IsPersonAccount) {
                personAccountRecordTypeId = rt.Id;
                break;
            }
        }

    }

    //SINGLETON PATTERN
    private static ORG_TestDataUtils instance;
    public static ORG_TestDataUtils getInstance() {
        if (instance == null) instance = new ORG_TestDataUtils();
        return instance;
    }

    //USER
    public User standardUser() {
        return new User(
            Alias = 'standt',
            Email = 'aaron@nube53.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' OR Name = 'Usuario estándar'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'aaron@nube53.com.eci'
        );
    }
    
    public User adminUser() {
        return new User(
            Alias = 'sysAdmin',
            Email = 'aaron@nube53.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'aaron@nube53.com.eci.dev'
        );
    }
    
    public User dataStageUser() {
        return new User(
            Alias = 'sysAdmin',
            Email = 'aaron@nube53.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'datastage',
            LastName = 'integration',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'atastage.integration@eci.es.test'
        );
    }
    
    //USER SPANISH
    public User standardUserES() {
        return new User(
            Alias = 'standt',
            Email = 'aaron@nube53.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' OR Name = 'Usuario estándar'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'aaron@nube53.com.eci.es'
        );
    }
    
    public User adminUserES() {
        return new User(
            Alias = 'sysAdmin',
            Email = 'aaron@nube53.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'aaron@nube53.com.eci.dev.es'
        );
    }
    
    public User dataStageUserES() {
        return new User(
            Alias = 'sysAdmin',
            Email = 'aaron@nube53.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'datastage',
            LastName = 'integration',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'atastage.integration@eci.es.test.es'
        );
    }
    
    //LEAD
    public Lead newLead(String variant) {
        return new Lead(
            LastName = 'Name ' + variant,
            source_manualrecord__c='Otros',
            MobilePhone = '123' + variant
        );
    }    
	// PLANIFICACION LLAMADAS TODAS HORAS MISMO MÁXIMO
    public PlanificacionLlamadas__c newPlanLLamadaEstandar(String dayWeek,Integer maxLlamadas,String area){
        return new PlanificacionLlamadas__c(
            CESS_Type__c = 'Estandar',
            CESS_DayOfWeek__c = dayWeek,
            CESS_LlamadasP0900__c = maxLlamadas,
            CESS_LlamadasP1000__c = maxLlamadas,
            CESS_LlamadasP1100__c = maxLlamadas,
            CESS_LlamadasP1200__c = maxLlamadas,
            CESS_LlamadasP1300__c = maxLlamadas,
            CESS_LlamadasP1400__c = maxLlamadas,
            CESS_LlamadasP1500__c = maxLlamadas,
            CESS_LlamadasP1600__c = maxLlamadas,
            CESS_LlamadasP1700__c = maxLlamadas,
            CESS_LlamadasP1800__c = maxLlamadas,
            CESS_LlamadasP1900__c = maxLlamadas,
            CESS_LlamadasP2000__c = maxLlamadas,
            CESS_Area__c = area
        );
    }
        
    //ACCOUNT
    public Account newAccount(String variant) {
        return new Account(
            Name = 'Name ' + variant
        );
    }
    
    //PERSON ACCOUNT
    public Account newPersonAccount(String variant) {          
        return new Account(
            FirstName = 'Name ' + variant,
            LastName = 'Surname ' + variant,
            PersonEmail = 'test@example.com',
            Phone = '+34 910123123' + variant,
            document_type__pc='NIF',
            personal_document__pc='66573439P',
            RecordTypeId = personAccountRecordTypeId
        );
    }

    //CONTACT
    public Contact newContact(String variant) {
        return new Contact(
            FirstName = 'Name ' + variant,
            LastName = 'Surname ' + variant
        );
    }

    public Contact newContact(String variant, Id accountId) {
        return new Contact(
            FirstName = 'Name ' + variant,
            LastName = 'Surname ' + variant,
            AccountId = accountId
        );
    }
    //CASE
    /* MMV: COMENTADO PARA EVITAR DEPENDENCIAS
    public Case newCase(String variant) {
        return new Case(
            Subject = 'Subject ' + variant,
            Description = 'Description ' + variant
        );
    }
    public Case newCase(String variant,ShoppingCenter__c centro) {
        return new Case(
            Subject = 'Subject ' + variant,
            Description = 'Description ' + variant,
            center_code__c = centro.Id
        );
    }
    public Case newCase(String variant, Id contactId) {
        return new Case(
            Subject = 'Subject ' + variant,
            Description = 'Description ' + variant,
            ContactId = contactId
        );
    }
    
	public Case newCase(String variant, Id contactId, String recordType) {
        Case c = newCase(variant, contactId);
        c.RecordTypeId = rtUtils.getRtId(SObjectType.Case.name, recordType);
        return c;
    }

    public Case newCaseMk(String MKRequestId, String definitionkey, String subject, String description, String statusMkCloud){
        Case c = newCase(subject);
        c.VOC_MKRequestId__c = MKRequestId;
        c.VOC_DefinitionKey__c = definitionkey;
        c.VOC_StatusMKCloud__c = statusMkCloud;
        return c;        
    }    
    
    
     public Case newCase(String variant, Id accountId, Id contactId) {
        return new Case(
            Subject = 'Subject ' + variant,
            Description = 'Description ' + variant,
            ContactId = contactId,
            AccountId = accountId
        );
    }   
    */
    

    //CUC Account 
    public Account newAccount_cuc(String variant, String mergedCUC, String identifierCUC){
            return new Account(
            FirstName = 'Name ' + variant,
            LastName = 'Surname ' + variant,
            PersonEmail = 'test@example.com',
            identifier_cuc__c = identifierCUC,
            merged_cuc__c = mergedCUC
            );
    }

    //VOC_RESPONSE
    /* MMV: COMENTADO PARA EVITAR DEPENDENCIAS    
    public VOC_MKCloudGetStatusPostMessageResponse VocResponse(String status){
            
        VOC_MKCloudGetStatusPostMessageResponse response = new VOC_MKCloudGetStatusPostMessageResponse();
        VOC_MKCloudGetStatusPostMessageResponse.To responseTo = new VOC_MKCloudGetStatusPostMessageResponse.To();
    	response.id = 'xxxxx';
		response.status = status;
        response.deliveryTime = '2008-10-5 12:20:20';
        responseTo.address = 'Direccion';
        responseTo.id='Id1';
        responseTo.key='Key01';
		response.to = responseTo;
            
        return response;   
            
    }
    */

    //ENTITLEMENT
    public Entitlement newEntitlement(String variant, Id accountId) {
        return new Entitlement(
            AccountId = accountId, 
            Name = variant);
    }

    //-- MOCK HTTP
    public class SingleRequestMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;

        public SingleRequestMock(Integer code, String status, String body,
                                 Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }

        public SingleRequestMock(Integer code, String status, Blob body,
                                 Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsBlob = body;
            this.bodyAsString = null;
            this.responseHeaders = responseHeaders;
        }
        

        

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);
            resp.setStatus(status);
            
            if (bodyAsBlob != null) {
                resp.setBodyAsBlob(bodyAsBlob);
            }
            else {
                resp.setBody(bodyAsString);
            }
            
            if(req.getEndpoint().startsWith('callout:WSO2_TokenError')) {
				resp.setStatusCode(500);
				resp.setStatus('Service down');
			}
			else if(req.getEndpoint().startsWith('callout:WSO2_Token')) {
                resp.setHeader('Content-Type', 'application/json');
                if(req.getHeader('X-SF-info') == 'requested') {
                    // this means that the token is being refreshed so give a new token
                    resp.setHeader('X-SF-info', 'refreshed');
                    resp.setBody('{"success": true, "access_token": "0987654321", "scope": "", "token_type": "Bearer", "expires_in": 300}');
                } else {
					// this is the first time we get the token so set the status
					resp.setHeader('X-SF-info', 'requested');
					resp.setBody('{"success": true, "access_token": "1234567890", "scope": "", "token_type": "Bearer", "expires_in": 300}');					
				}

				resp.setStatusCode(200);
            }

            if (responseHeaders != null) {
                for (String key : responseHeaders.keySet()) {
                    resp.setHeader(key, responseHeaders.get(key));
                }
            }

            return resp;
        }
    }

}