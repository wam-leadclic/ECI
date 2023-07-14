/**********************************************************************************
* @name         	CESS_AccountTriggerHelperTest
* @version			1.0
* @creation date   	04/05/2020
* @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Test to the CESS_AccountTriggerHelperTest class
* @group        	Helper
**********************************************************************************/
@isTest
private class CESS_AccountTriggerHelperTest {
	/**
     * @description 
     */
	@testSetup
    private static void setup() {
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        List<Account> lstAccs = new List<Account>();
        Account acc1 = orgDataUtils.newPersonAccount('acc1');
        acc1.personal_document__pc = '15213308G';
        acc1.document_type__pc = 'NIF';
        lstAccs.add(acc1);
        Account acc2 = orgDataUtils.newPersonAccount('acc2');
        acc2.personal_document__pc = 'X7853753N';
        acc2.document_type__pc = 'NIE';
        lstAccs.add(acc2);
        Account acc3 = orgDataUtils.newPersonAccount('acc3');
        acc3.personal_document__pc = 'G0076915H';
        acc3.document_type__pc = 'CIF';
        lstAccs.add(acc3);
        insert lstAccs;
    }
    /**
     * @description 
     */
    @isTest
    private static void checkIsNIEValidTest() {
        Account acc1 = [SELECT Id,personal_document__pc,document_type__pc,Bypass_ValidacionConsultaCESS__c,identifier_cuc__pc FROM Account WHERE document_type__pc='NIE' LIMIT 1];  
        acc1.personal_document__pc = 'X1234567P';
        Test.startTest();
        CESS_AccountTriggerHelper.checkIsNIFCIFNIEValid(acc1);
        Test.stopTest();
    }   
     /**
     * @description 
     */
    @isTest
    private static void checkIsNIFValidTest() {
        Account acc1 = [SELECT Id,personal_document__pc,document_type__pc,Bypass_ValidacionConsultaCESS__c,identifier_cuc__pc FROM Account WHERE document_type__pc='NIF' LIMIT 1];  
        acc1.personal_document__pc = 'G0076915H';
        Test.startTest();
        CESS_AccountTriggerHelper.checkIsNIFCIFNIEValid(acc1);
        Test.stopTest();
    }
     /**
     * @description 
     */
    @isTest
    private static void checkIsCIFValidTest() {
        Account acc1 = [SELECT Id,personal_document__pc,document_type__pc,Bypass_ValidacionConsultaCESS__c,identifier_cuc__pc FROM Account WHERE document_type__pc='CIF' LIMIT 1];  
        acc1.personal_document__pc = '10076915H';
        Test.startTest();
        CESS_AccountTriggerHelper.checkIsNIFCIFNIEValid(acc1);
        Test.stopTest();
    }   
}