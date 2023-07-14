/**********************************************************************************
* @author       Franciso José Pérez - franciscojose.pere@salesforce.com
* @date         5/07/2019
* @group        Test
* @description  Test class to test the CESS_InsertCTIIntegrationHandler class
* @revision
**********************************************************************************/
@isTest
public class CESS_InsertCTIIntegrationHandlerTest {
	//public static String setting = '[{"s": "Test","c": "CESS_InsertCTIIntegrationHandlerTest","a": true, "async": true}]';

	/**
     * @description
     */   
	@testSetup
	private static void setup() {

        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345', FirstName='ApeTestTask', PersonMobilePhone='632333232',document_type__pc='NIF',personal_document__pc='66573439P');
        insert (acc);

        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);


        List <Lead> lstLd = new List <Lead>();
        
        lstLd.add(new Lead (LastName='TestCTI1', source_manualrecord__c='Otros', Email = 'test1@email.com',
                            MobilePhone='677889900',sent_cti__c=true,identifier_cess__c='12345',campaign__c='t2o',
                            source_type__c = 'Adwords', source_cess__c = 'lead_autos',order__c=900,skill__c='2',age__c=54,
                            campaign_cess__c='Campaña Autos',gender__c='MALE',line_insurance__c='Vida',
                            risk_postalcode__c='28021',Phone='999888898',campaign_cti__c='CP - TEST_CESS' ));
        lstLd.add(new Lead (LastName='TestCTI2', source_manualrecord__c='Otros', Email = 'test2@email.com',
                            MobilePhone='',sent_cti__c=true,identifier_cess__c='12345',campaign__c='t2o',
                            source_type__c = 'Adwords', source_cess__c = 'lead_motos',order__c=903,skill__c='4',age__c=54,
                            campaign_cess__c='Campaña Motos',gender__c='FEMALE',line_insurance__c='Salud',
                            risk_postalcode__c='28021',Phone='999889999',campaign_cti__c='CP - TEST_CESS', schedulecontact_datetime__c = DateTime.newInstance(2019, 7, 18, 10, 15, 10)  ));
        //lstLd.add(new Lead (LastName='TestCTI3', source_manualrecord__c='Otros',sent_cti__c=true,Phone='988889989' ));
                            
        insert (lstLd);
	
	} 

	/**
     * @description
     */   
	@isTest
	private static void testHandleEventsLeadCamapana() {

        List <ORG_Integration_Event__e> events = new List <ORG_Integration_Event__e>();

        CESS_ConsultaCTIDto.ctiResponse ctiResponse = new CESS_ConsultaCTIDto.ctiResponse();
        CESS_ctiResponseDto ctiData = new CESS_ctiResponseDto();
        ctiData.message = 'Processed correctly';

        ctiResponse.error = ctiData;
        
        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            JSON.serialize(ctiResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse); 

		Test.startTest();

		 for (Lead ld: [SELECT Id FROM Lead WHERE LastName = 'TestCTI1']){

            ORG_Integration_Event__e event = new ORG_Integration_Event__e(
                System__c = 'CESS-CTI',
                Event_Id__c = '', 
                Handler__c = 'CESS_InsertCTIIntegrationHandler', 
                Object_Id__c = ld.Id 
            );

            new CESS_InsertCTIIntegrationHandler().handleEvent(event);

        }

        Test.stopTest();

        List<Lead> lstLead = [SELECT Id,campaign_cti__c,crl_ok__c,source_type__c,sent_cti__c,line_insurance__c,
                            campaign_cess__c, MobilePhone,Email,Phone,managements_sf__c,identifier_aneto__c,identifier_cess__c,
                            document_number__c,cti_error__c,lead_number__c,order__c,skill__c,source_datetime__c,
                            age__c,is_customer__c,managements_cess__c,gender__c,businessline_prohibited__c,
                            businessline_contracted__c,risk_postalcode__c,source_cess__c
                     FROM Lead WHERE LastName = 'TestCTI1'];

        System.assertEquals(true, lstLead[0].sent_cti__c, 'Enviado a CTI correctamente' );

	}

	/**
     * @description
     */   
	@isTest
	private static void testHandleEventsLeadPlanificado() {

        List <ORG_Integration_Event__e> events = new List <ORG_Integration_Event__e>();

        CESS_ConsultaCTIDto.ctiResponse ctiResponse = new CESS_ConsultaCTIDto.ctiResponse();
        CESS_ctiResponseDto ctiData = new CESS_ctiResponseDto();
        ctiData.message = 'Processed correctly';

        ctiResponse.error = ctiData;
        
        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            JSON.serialize(ctiResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse); 

		Test.startTest();

		 for (Lead ld: [SELECT Id FROM Lead WHERE LastName = 'TestCTI2']){

            ORG_Integration_Event__e event = new ORG_Integration_Event__e(
                System__c = 'CESS-CTI',
                Event_Id__c = '', 
                Handler__c = 'CESS_InsertCTIIntegrationHandler', 
                Object_Id__c = ld.Id 
            );

            new CESS_InsertCTIIntegrationHandler().handleEvent(event);

        }

        Test.stopTest();

        List<Lead> lstLead = [SELECT Id,campaign_cti__c,crl_ok__c,source_type__c,sent_cti__c,line_insurance__c,
                            campaign_cess__c, MobilePhone,Email,Phone,managements_sf__c,identifier_aneto__c,identifier_cess__c,
                            document_number__c,cti_error__c,lead_number__c,order__c,skill__c,source_datetime__c,
                            age__c,is_customer__c,managements_cess__c,gender__c,businessline_prohibited__c,
                            businessline_contracted__c,risk_postalcode__c,source_cess__c
                     FROM Lead WHERE LastName = 'TestCTI2'];

        System.assertEquals(true, lstLead[0].sent_cti__c, 'Enviado a CTI correctamente' );

	}

}