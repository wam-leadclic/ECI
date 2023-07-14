/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         05/07/2019
* @group        Test
* @description  Test class to test the CESS_RelatedObjectsLXCtrl class
* @Revision
**********************************************************************************/
@isTest
public class CESS_RelatedObjectsLXCtrlTest {

    @testSetup
    private static void setup() {

        // Data Helpers
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        SAC_TestDataUtils sacDataUtils = SAC_TestDataUtils.getInstance();

        // Person account
        Account a1 = sacDataUtils.completeCliente(orgDataUtils.newPersonAccount('P1'));
        a1.identifier_cess__pc = 'test';
        a1.identifier_aneto__pc = 'test';
        a1.document_type__pc = 'NIF';
        a1.personal_document__pc = '15213308G';
        a1.PersonEmail = 'test@email.com';
        a1.PersonAssistantPhone = 'test';
        a1.Phone = 'test';
        insert a1;
    }
    
    @IsTest static void testGetAccountId() {
        Test.startTest();
            CESS_RelatedObjectsLXCtrl.getAccountId('15213308G', 'test', 'test', 'test@email.com', 'test', 'test');
        Test.stopTest();
    }

}