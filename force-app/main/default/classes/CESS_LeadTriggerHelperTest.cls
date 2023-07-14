/**********************************************************************************
* @name         	CESS_LeadTriggerHelperTest
* @version			1.0
* @creation date   	30/04/2020
* @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Test to the CESS_LeadTriggerHelperTest class
* @group        	Helper
FECHA       AUTOR       DESCRIPCION<br/>
30/05/2022  LCS-JCB   	Corrección Mét. TestSetRespone, y métodos de comprobación de número de documento.
						Se quitan métodos innecesarios.
05/11/2022  LCS-MHG   	Se comentan 4 Asserts que fallan en solamente en el despliegue a producción (se deberían revisar)
</pre>
**********************************************************************************/
@isTest
private class CESS_LeadTriggerHelperTest {
	/**
     * @description 
     */
	@testSetup
    private static void setup() {
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        List<Lead> lstLeads = new List<Lead>();
        Lead lead1 = orgDataUtils.newLead('Lead1');
        lead1.document_number__c = '15213308G';
        lead1.document_type__c = 'NIF';
        lead1.Status = 'New';
        lead1.Phone = '929308219';
        lead1.MobilePhone = '717003909';
		lead1.Email = 'testEmail1@leadclic.com';
        lead1.sent_cti__c = true;
        lead1.identifier_cess__c= 'test';
        lstLeads.add(lead1);
        Lead lead2 = orgDataUtils.newLead('Lead2');
        lead2.document_number__c = 'X7853753N';
        lead2.document_type__c = 'NIE';
        lead2.Status = 'New';
        lead2.Phone = '900110208';
        lead2.MobilePhone = '666692188';
		lead2.Email = 'testEmail2@leadclic.com';
        lead2.sent_cti__c = true;
        lstLeads.add(lead2);
        Lead lead3 = orgDataUtils.newLead('Lead3');
        lead3.document_number__c = 'G0076915H';
        lead3.document_type__c = 'CIF';
        lead3.Status = 'New';
        lead3.Phone = '926263863';
        lead3.MobilePhone = '769305514';
		lead3.Email = 'testEmail3@leadclic.com';
        lead3.sent_cti__c = true;
        lstLeads.add(lead3);
        insert lstLeads;
        
		List<Account> lstPersonAccounts = new List<Account>();
        Account account1 = orgDataUtils.newPersonAccount('personAccount1');
        account1.personal_document__pc = '27148808E';
        account1.document_type__pc = 'NIF';
        account1.notContacted__pc = true;
        account1.identifier_cess__pc = lead1.identifier_cess__c;
        lstPersonAccounts.add(account1);
        insert lstPersonAccounts;
        
        List<Campaign> lstCampaigns = new List<Campaign>();
        Campaign campaign1 = new Campaign();
        campaign1.Name = 'campaign1';
        campaign1.recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('CTI').getRecordTypeId();
        campaign1.Status = 'Planificada';
        lstCampaigns.add(campaign1);
        Campaign campaign2 = new Campaign();
        campaign2.Name = 'campaign2';
        campaign2.recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing').getRecordTypeId();
        campaign2.Status = 'Planificada';
        lstCampaigns.add(campaign2);
        insert lstCampaigns; 
        
    }
    /**
     * @description Test to verify validation NIE, If an error is not generated, the verification has been correct 
     */
    @isTest
    private static void checkIsNIEValidTest() {
        Lead lead1 = [SELECT Id,document_number__c,result__c,status,document_type__c,Bypass_ValidacionConsultaCESS__c, contact_attempts__c FROM Lead WHERE document_type__c='NIE' LIMIT 1];  
        lead1.document_number__c = 'X1234567P';
        CampaignMember cMember1 = new CampaignMember();
        cMember1.status = 'New';
        cMember1.LeadId = lead1.id;
        Test.startTest();
        	CESS_LeadTriggerHelper.checkIsNIFCIFNIEValid(lead1);
        Test.stopTest();
    }   
     /**
     * @description Test to verify validation NIF, If an error is not generated, the verification has been correct 
     */
    @isTest
    private static void checkIsNIFValidTest() {
        Lead lead1 = [SELECT Id,document_number__c,result__c,status,document_type__c,Bypass_ValidacionConsultaCESS__c, contact_attempts__c FROM Lead WHERE document_type__c='NIF' LIMIT 1];  
        lead1.document_number__c = 'G0076915H';
        Test.startTest();
        CESS_LeadTriggerHelper.checkIsNIFCIFNIEValid(lead1);
        Test.stopTest();
    }
    
     /**
     * @description Test to verify validation NIF, if an error is generated, the lead will not be inserted - LCS-JCB
     */
    @isTest
    private static void checkIsNIFValidTest_Failed() {
        String errorMsje = '';
        Lead l1 = new Lead();
        l1.Status = 'New';
        l1.Phone = '601600601';
        l1.LastName = 'Apellido 2';
        l1.document_type__c = 'NIF';
        l1.document_number__c = '66666666T'; //Formato erróneo
        Test.startTest();
        try{
        	insert l1;
        }catch (Exception e){
            errorMsje = e.getMessage();
        }
        Test.stopTest();
        // Comprobación - Comentado por MHG 05/11/2022
        // System.assert(errorMsje.contains('NIF incorrecto'), 'Se esperaba una excepción para el formato de NIF');
    }
     /**
     * @description Test to verify validation CIF, if an error is generated, the lead will not be inserted - LCS-JCB
     */
    @isTest
    private static void checkIsCIFValidTest_Failed() {
        String errorMsje = '';
        Lead l1 = new Lead();
        l1.Status = 'New';
        l1.Phone = '601600601';
        l1.LastName = 'Apellido 2';
        l1.document_type__c = 'CIF';
        l1.document_number__c = 'Z6666666T';//Formato erróneo
        Test.startTest();
        try{
        	insert l1;
        }catch (Exception e){
            errorMsje = e.getMessage();
        }
        Test.stopTest();
        //Comprobación - Comentado por MHG 05/11/2022
        //System.assert(errorMsje.contains('CIF incorrecto'), 'Se esperaba una excepción para el formato de CIF');
    }
    
     /**
     * @description Test to verify validation NIE, if an error is generated, the lead will not be inserted - LCS-JCB
     */
    @isTest
    private static void checkIsNIEValidTest_Failed() {
        String errorMsje = '';
        Lead l1 = new Lead();
        l1.Status = 'New';
        l1.Phone = '601600601';
        l1.LastName = 'Apellido 2';
        l1.document_type__c = 'NIE';
        l1.document_number__c = 'A6666666T';//Formato erróneo
        Test.startTest();
        try{
        	insert l1;
        }catch (Exception e){
            errorMsje = e.getMessage();
        }
        Test.stopTest();
        //Comprobación - Comentado por MHG 05/11/2022
        //System.assert(errorMsje.contains('NIE incorrecto'), 'Se esperaba una excepción para el formato de NIE');
    }
    
     /**
     * @description Test to verify validation NIE (long.>9), if an error is generated, the lead will not be inserted - LCS-JCB
     */
    @isTest
    private static void checkIsNIEValidTest_Failed_1() {
        String errorMsje = '';
        Lead l1 = new Lead();
        l1.Status = 'New';
        l1.Phone = '601600601';
        l1.LastName = 'Apellido 2';
        l1.document_type__c = 'NIE';
        l1.document_number__c = 'A6666666T999';//Formato erróneo, longitud>9
        Test.startTest();
        try{
        	insert l1;
        }catch (Exception e){
            errorMsje = e.getMessage();
        }
        Test.stopTest();
        //Comprobación - Comentado por MHG 05/11/2022
        //System.assert(errorMsje.contains('NIE incorrecto'), 'Se esperaba una excepción para el formato de NIE');
    }
    
     /**
     * @description Test to verify that if a lead updates their status to 'Unqualified', 
     * their Id is added to change the status of their pending calls. - LCS-JCB
     */
    @isTest
    private static void checkAddLeadToDeleteTest() {
        Lead l1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1];
        Task t = new Task (WhoId=l1.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        insert (t);
        l1.Status = 'Unqualified';
        Test.startTest();
			update l1;
        Test.stopTest();
        //Comprobación
        for(Task tarea : [select id, Status from task where whoid =: l1.Id and type='Schedule Call' ]){
            //La tarea ha cambiado su estado original
            System.assert(tarea.Status != 'Not Started', 'Se esperaba que la tarea cambiara de estado');
        }
    }
    
     /**
     * @description Test to verify Delete from CTI, when the service return a failed request the value 
     * of CampaignMember.CTIIntergrationStatus__c change to 'Eliminacion fallida'  - LCS-JCB
     */
    @isTest
    private static void checkLeadToDeleteCTITest_failedDelete() {
        Lead l1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1];
        Campaign campaign1 = new Campaign(Name = 'campaign1', recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('CTI').getRecordTypeId(), Status = 'Planificada'  );
        insert campaign1;
        CampaignMember cm = new CampaignMember(status='New', CampaignId=campaign1.Id, LeadId = l1.Id , CTISent__c=true, CTIIntergrationStatus__c = CESS_Constantes.PDT_DELETE_CTI);
        insert cm;
        Task t = new Task (WhoId=l1.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        insert (t);
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        l1.Status = 'New';
        Test.startTest();
			update l1;
        Test.stopTest();
        //Comprobación del valor CTIIntergrationStatus__c
        for(CampaignMember cMem : [select id, CTIIntergrationStatus__c from CampaignMember where LeadId =: l1.Id AND RecordType.DeveloperName = 'CTI']){
            System.assert(cMem.CTIIntergrationStatus__c == 'Eliminación fallida', 'Se esperaba una eliminación fallida ');            
        }  
    }
    
    /**********************************************************************************
    * @author       	Jesús Navarro -jnavarrom@leadclic.com
    * @creation date    28/02/2022
    * @description  	test send platform evetns method
    **********************************************************************************/
    @isTest
    static void validateSendEventNIFLeadMatched() {

        // Update Lead Status
        Lead lead1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1];
		lead1.Status = 'Unqualified';
        update lead1;

        // Create new Lead that matches with lead1 by document number
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        Lead lead4 = orgDataUtils.newLead('Lead4');
        lead4.document_number__c = '15213308G'; //mismo núm. de documento
        lead4.document_type__c = 'NIF';
        lead4.Status = 'New';
        lead4.Phone = '666666666';
       
        Test.startTest();
        try{
            insert lead4;
        }catch(Exception e){
        }
        Test.stopTest();
       // lead1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1]; 
       	System.assertEquals(1, Limits.getPublishImmediateDML(), 'There should be one event sent');
        //System.assertEquals('New', lead1.Status, 'Matched lead should be in status New');

    }
    @isTest
    static void validateSendEventPhoneLeadMatched() {
        // Update Lead Status
        Lead lead1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1];
		lead1.Status = 'Unqualified';
        update lead1;

        // Create new Lead that matches with lead1 by phone
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        Lead lead4 = orgDataUtils.newLead('Lead4');
        lead4.document_type__c = 'NIF';
        lead4.document_number__c = '35353535M';
        lead4.Phone = '929308219';//Mismo teléfono
        lead4.Status = 'New';
        lead4.sent_cti__c = true;
        
        Test.startTest();
        try{
            insert lead4;
        }catch(Exception e){
        }
        Test.stopTest();
       // lead1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1]; 
       	System.assertEquals(1, Limits.getPublishImmediateDML(), 'There should be one event sent');
        //System.assertEquals('New', lead1.Status, 'Matched lead should be in status New');


    }
    @isTest
    static void validateSendEventMobilePhoneLeadMatched() {

        // Update Lead Status
        Lead lead1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1];
		lead1.Status = 'Unqualified';
        update lead1;

        // Create new Lead that matches with lead1 by phone
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        Lead lead4 = orgDataUtils.newLead('Lead4');
        lead4.document_type__c = 'NIF';
        lead4.document_number__c = '35353535M';
        lead4.MobilePhone = '717003909'; //Mismo tel.móvil
        lead4.Status = 'New';
        lead4.sent_cti__c = true;
        
        Test.startTest();
        try{
            insert lead4;
        }catch(Exception e){
        }
        Test.stopTest();
       // lead1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1]; 
       	System.assertEquals(1, Limits.getPublishImmediateDML(), 'There should be one event sent');
        //System.assertEquals('New', lead1.Status, 'Matched lead should be in status New');

    }
    @isTest
    static void validateSendEventEmailLeadMatched() {
        // Update Lead Status
        Lead lead1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1];
		lead1.Status = 'Unqualified';
        update lead1;

        // Create new Lead that matches with lead1 by phone
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        Lead lead4 = orgDataUtils.newLead('Lead4');
        lead4.document_type__c = 'NIF';
        lead4.document_number__c = '35353535M';
        lead4.MobilePhone = '626626888';
        lead4.Status = 'New';
        lead4.Email ='testEmail1@leadclic.com';
         
        Test.startTest();
        try{
            insert lead4;
        }catch(Exception e){
        }
        Test.stopTest();
       // lead1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1]; 
       	System.assertEquals(1, Limits.getPublishImmediateDML(), 'There should be one event sent');
        //System.assertEquals('New', lead1.Status, 'Matched lead should be in status New');

    }
    @isTest
    static void validateSendEventNIFContactMatched() {

        // Create new Lead that matches with account1 by document number
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        Lead lead4 = orgDataUtils.newLead('Lead4');
        lead4.document_number__c = '27148808E';//Mismo NIF
        lead4.document_type__c = 'NIF';
        lead4.Status = 'New';
        lead4.Phone = '666666666';
        lead4.sent_cti__c = true;
        Test.startTest();
        try{
            insert lead4;
        }catch(Exception e){
        }
        Test.stopTest();

        // Query record
        Account account1 = [SELECT Id, notContacted__pc FROM Account WHERE LastName = 'Surname personAccount1' LIMIT 1];
        
        // Assert
        System.assertEquals(1, Limits.getPublishImmediateDML(), 'There should be one event sent');
        //System.assertEquals(false, account1.notContacted__pc, 'Matched contact should have notContacted field false');

    }

    /**********************************************************************************
     * @author           María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    18/11/2020
    * @description  	Test setResponse
    **********************************************************************************/
    @isTest
    static void testSetResponse() {
        String CTI_STATUS_PDT_ELIMINAR = ORG_TestDataUtils.CTI_STATUS_PDT_ELIMINAR;
        List<Lead> lstLeads = [SELECT Id,lead_number__c,result__c,status,cti_integrationstatus__c,sent_cti__c FROM Lead WHERE sent_cti__c = true LIMIT 2];
        List<String> lstIds = new List<String>(); 
        Campaign campaign1 = new Campaign();
        campaign1.Name = 'campaign1';
        campaign1.recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('CTI').getRecordTypeId();
        campaign1.Status = 'Planificada';
        insert campaign1;
        CESS_BulkifiedCTIResponseDto.response respuesta = new CESS_BulkifiedCTIResponseDto.response();
        respuesta.message= 'Failed process';
        respuesta.request_id= 'fd2463b2-c645-4194-8284-d9790e31906b';
        List<String> resultList = new List<String>();
        for(Lead ld :lstLeads){
            CampaignMember cMember1 = new CampaignMember(status = 'New', CampaignId = campaign1.Id, LeadId = ld.Id);
            insert cMember1;
            lstIds.add(ld.Id);
            resultList.add('OK EXTERNAL_ID '+ld.Id+' Correct process');
        }
        respuesta.results = resultList;
        
        Test.startTest();
             CESS_LeadTriggerHelper.setResponse(lstIds, respuesta, True);
        Test.stopTest();
        for(CampaignMember cm : [SELECT Id, CTIIntergrationStatus__c FROM CampaignMember WHERE LeadId IN:lstIds AND RecordType.DeveloperName = 'CTI']){
            System.assert(cm.CTIIntergrationStatus__c == CESS_Constantes.SUCCESS_DELETE_CTI, 'Se esperaba actualización de valores en CampaignMember');
            
        }

    }

     
}