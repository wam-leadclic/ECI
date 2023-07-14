/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         05/07/2019
* @group        Test
* @description  Test class to test the CESS_AllCESSDataLXCtrlTest class
* @Revision
**********************************************************************************/
@isTest
public class CESS_AllCESSDataLXCtrlTest {

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
    
    @IsTest static void testGetDGRecords() {

        Test.startTest();
            CESS_AllCESSDataLXCtrl.getDGRecords('test','test');
        Test.stopTest();
    }

    @IsTest static void testFailGetDGRecordsCESSId() {

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            '{ \"Fail\":[ {\"request_id\": \"salesforce_main_menu_1561719028487\", \"message\": \"Error generico.\"}]}',
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        List <CESS_ConsultaGestionesResponseDto> dg = new List <CESS_ConsultaGestionesResponseDto>();
        
        Test.startTest();
            dg = CESS_AllCESSDataLXCtrl.getDGRecords('12345',''); 
        Test.stopTest();

        //System.debug('Resultado Test dg: ' + dg);

        System.assertEquals('KO', dg[0].return_code);
        System.assertEquals('Fallo en el sistema CESS', dg[0].error_message); 
    }

    @IsTest static void testErrorGetDGRecordsCESSId() {

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            '{ \"error\": {\"request_id\": \"salesforce_main_menu_1561719028487\", \"message\": \"Error generico.\", \"details\": { \"code\": \"12\" }}}',
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);  

        List <CESS_ConsultaGestionesResponseDto> dg = new List <CESS_ConsultaGestionesResponseDto>();

        Test.startTest();    
            dg = CESS_AllCESSDataLXCtrl.getDGRecords('12345',''); 
        Test.stopTest();

        System.debug('Resultado Test dg: ' + dg);

        System.assertEquals('KO', dg[0].return_code);
        System.assertEquals('Error generico.', dg[0].message); 
    }
   
       @IsTest static void testOKGetDGRecordsAnetoId() {

        CESS_ConsultaCESSDto.ConsultaGestionesResponse gestionesResponse = new CESS_ConsultaCESSDto.ConsultaGestionesResponse();

        CESS_ConsultaGestionesResponseDto crData = new CESS_ConsultaGestionesResponseDto();
        crData.return_code = 'OK';
        crData.task_number = '999999';
        crData.next_date = '2019/11/21';
        crData.task_subject = 'subject';
        crData.collaborator_number = '123';
        crData.collaborator_name = 'test_name 1';
        crData.assigned_office = 'office 1';
        crData.branch_description = 'descripción ';
        crData.open_date = '2019/01/01';

        gestionesResponse.dgcustomer_management = new List <CESS_ConsultaGestionesResponseDto>{crData};

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            JSON.serialize(gestionesResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);  

        List <CESS_ConsultaGestionesResponseDto> dg = new List <CESS_ConsultaGestionesResponseDto>();

        Test.startTest();
            dg = CESS_AllCESSDataLXCtrl.getDGRecords('','12345');
        Test.stopTest();

        System.assertEquals('OK', dg[0].return_code);
        System.assertEquals('999999', dg[0].task_number);
        System.assertEquals('2019/11/21', dg[0].next_date);
        System.assertEquals('subject', dg[0].task_subject);
        System.assertEquals('123', dg[0].collaborator_number);
        System.assertEquals('test_name 1', dg[0].collaborator_name);
        System.assertEquals('office 1', dg[0].assigned_office);
        System.assertEquals('descripción ', dg[0].branch_description);
        System.assertEquals('2019/01/01', dg[0].open_date); 
    }
}