/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         05/07/2019
* @group        Test
* @description  Test class to test the CESS_ConsultaCESSFromLeadLXCtrl class
* @Revision
**********************************************************************************/
@isTest
public class CESS_ConsultaCESSFromLeadLXCtrlTest {

    @testSetup
    private static void setup() {

        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        SAC_TestDataUtils sacDataUtils = SAC_TestDataUtils.getInstance();

        // Person account
        Account a1 = sacDataUtils.completeCliente(orgDataUtils.newPersonAccount('P1'));
        insert new Account[] { a1 };

        /* MMV: COMENTADO PARA EVITAR DEPENDENCIAS
        Card__c card = new Card__c(customer__c = a1.Id,
                                   card__c = '0');
        insert card;
        */
        
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
    
    @IsTest static void testUpdateAccountFromOpp() {

        CESS_ConsultaClienteResponseDto dto = new CESS_ConsultaClienteResponseDto('test','test','test','test',
                                                                                  'test','test','test','test',
                                                                                  'test','test','01/01/1990','test',
                                                                                   new Map<String,String>{'test'=>'test'},
                                                                                   // MMV: CAMBIADO PARA EVITAR DEPENDENCIAS
                                                                                   //'test','test',[SELECT Id FROM Card__c LIMIT 1].Id);
                                                                                   'test','test','test');
        CESS_ConsultaClienteResponseDto.List_document document = new CESS_ConsultaClienteResponseDto.List_document();
        document.document_type = 'A001';
        document.document_number = 'test';
        document.sequence = '0';
        dto.list_document = new List<CESS_ConsultaClienteResponseDto.List_document>{document};

        Test.startTest();
            CESS_ConsultaCESSFromLeadLXCtrl.updateAccountFromOpp([SELECT Id FROM Account LIMIT 1].Id,JSON.serialize(dto));
        Test.stopTest();
    }

    @IsTest static void testGetCESSClientRecords() {
        Test.startTest();
            CESS_ConsultaCESSFromLeadLXCtrl.getCESSClientRecords('A001','test', new Map<String,String>{'A0T0'=>'test'}, 'test', 'test');
        Test.stopTest();
    }

}