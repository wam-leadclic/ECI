/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         05/07/2019
* @group        Test
* @description  Test class to test the CESS_ConsultaPolizasLXCtrl class
* @Revision
**********************************************************************************/
@isTest
public class CESS_ConsultaPolizasLXCtrlTest {

    @testSetup
    private static void setup() {

        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        SAC_TestDataUtils sacDataUtils = SAC_TestDataUtils.getInstance();

        // Lead
        Lead newLead = orgDataUtils.newLead('test');
        newLead.identifier_cess__c = 'test';
        newLead.identifier_aneto__c = 'test';
        newLead.source_type__c = 'Telefono';
        //newLead.source_manualrecord__c = 'Otros';
        insert newLead;
        
        /*
        System.runAs(orgDataUtils.adminUser())
        {
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SObjectType = 'Case');
            QueuesObject q2 = new QueueSObject(QueueID = g2.id, SObjectType = 'Case');
            QueuesObject q3 = new QueueSObject(QueueID = g3.id, SObjectType = 'Case');
            insert new QueuesObject[] { q1, q2, q3 };
        }
        */
    }
    
    @IsTest static void testGetCESSPolicyRecords() {
        Test.startTest();
            CESS_ConsultaPolizasLXCtrl.getCESSPolicyRecords('test','test');
        Test.stopTest();
    }

    @IsTest static void testOKGetCESSPolicyRecordsAnetoId() {

        CESS_ConsultaCESSDto.ConsultaPolizasResponse polizasResponse = new CESS_ConsultaCESSDto.ConsultaPolizasResponse();

        CESS_ConsultaPolizasResponseDto crData = new CESS_ConsultaPolizasResponseDto();
        crData.company ='company';
        crData.company_description='company_description';
        crData.insurance_type='insurance_type';
        crData.product_description='product_description';
        crData.insurance_line='insurance_line';
        crData.line_description='line_description';
        crData.policy_number='12345';
        crData.certificate_number='67890';
        crData.request_number='111111';
        crData.status='open';
        crData.status_description='abierto';
        crData.start_date='2019/01/01';
        crData.end_date='2019/11/11';
        crData.expiration_date='2019/10/10';
        crData.cancelation_type='cancel type';
        crData.cancelation_reason='cancel reason';
        crData.cancelation_description='cancel desc';
        crData.insured_risk='insured_risk';
        crData.origin_system='aneto';
        crData.anual_quota='2000';
        crData.branch_code='branch_code';
        crData.branch_description='branch_description';
        crData.collaborator_code='1234';
        crData.collaborator_name='name 1';
        crData.collaborator_surname1='surname1';
        crData.collaborator_surname2='surname2';
        crData.return_code='OK';


        polizasResponse.dppolicy = new List <CESS_ConsultaPolizasResponseDto>{crData};

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            JSON.serialize(polizasResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);  

        List <CESS_ConsultaPolizasResponseDto> dp = new List <CESS_ConsultaPolizasResponseDto>();

        Test.startTest();
            dp = CESS_ConsultaPolizasLXCtrl.getCESSPolicyRecords('','12345');
        Test.stopTest();

        System.assertEquals('OK', dp[0].return_code);
        System.assertEquals('company', dp[0].company);
        System.assertEquals('company_description', dp[0].company_description);
        System.assertEquals('insurance_type', dp[0].insurance_type);
        System.assertEquals('product_description', dp[0].product_description);
        System.assertEquals('insurance_line', dp[0].insurance_line);
        System.assertEquals('line_description', dp[0].line_description);
        System.assertEquals('12345', dp[0].policy_number);
        System.assertEquals('67890', dp[0].certificate_number); 
        System.assertEquals('111111', dp[0].request_number); 
        System.assertEquals('open', dp[0].status); 
        System.assertEquals('abierto', dp[0].status_description); 
        System.assertEquals('2019/01/01', dp[0].start_date); 
        System.assertEquals('2019/11/11', dp[0].end_date); 
        System.assertEquals('2019/10/10', dp[0].expiration_date); 
        System.assertEquals('cancel type', dp[0].cancelation_type); 
        System.assertEquals('cancel reason', dp[0].cancelation_reason); 
        System.assertEquals('cancel desc', dp[0].cancelation_description); 
        System.assertEquals('insured_risk', dp[0].insured_risk); 
        System.assertEquals('aneto', dp[0].origin_system); 
        System.assertEquals('2000', dp[0].anual_quota); 
        System.assertEquals('branch_code', dp[0].branch_code); 
        System.assertEquals('branch_description', dp[0].branch_description); 
        System.assertEquals('1234', dp[0].collaborator_code); 
        System.assertEquals('name 1', dp[0].collaborator_name); 
        System.assertEquals('surname1', dp[0].collaborator_surname1); 
        System.assertEquals('surname2', dp[0].collaborator_surname2); 

    }


    @IsTest static void testFailGetDGRecordsCESSId() {

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            '{ \"Fail\":[ {\"request_id\": \"salesforce_main_menu_1561719028487\", \"message\": \"Error generico.\"}]}',
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);  

        List <CESS_ConsultaPolizasResponseDto> dp = new List <CESS_ConsultaPolizasResponseDto>();
        
        Test.startTest();
            dp = CESS_ConsultaPolizasLXCtrl.getCESSPolicyRecords('12345','');
        Test.stopTest();

        //System.debug('Resultado Test dg: ' + dg);

        System.assertEquals('KO', dp[0].return_code);
        System.assertEquals('Fallo en el sistema CESS', dp[0].error_message); 
    }

    @IsTest static void testErrorGetDGRecordsAnetoId() {

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            '{ \"error\": {\"request_id\": \"salesforce_main_menu_1561719028487\", \"message\": \"Error generico.\", \"details\": { \"code\": \"12\" }}}',
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);  

        List <CESS_ConsultaPolizasResponseDto> dp = new List <CESS_ConsultaPolizasResponseDto>();
        
        Test.startTest();
            dp = CESS_ConsultaPolizasLXCtrl.getCESSPolicyRecords('','12345');
        Test.stopTest();

        System.assertEquals('KO', dp[0].return_code);
        System.assertEquals('Error generico.', dp[0].message); 
    }

}