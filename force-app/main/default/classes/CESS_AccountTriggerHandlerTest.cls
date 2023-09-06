/**********************************************************************************
* @name         	CESS_AccountTriggerHandlerTest
* @version			1.0
* @creation date   	04/05/2020
* @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Test to the CESS_AccountTriggerHandlerTest class
* @group        	Helper
**********************************************************************************/
@isTest
private class CESS_AccountTriggerHandlerTest {
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
    private static void testCheckIsNIFValid() {
        Account acc1 = [SELECT Id,personal_document__pc,document_type__pc FROM Account WHERE document_type__pc='NIF' LIMIT 1];  
        acc1.personal_document__pc = '03261550N';
        Test.startTest();
        update acc1;
        Test.stopTest();
        List<Account> lstAccAssert = [SELECT Id,personal_document__pc,document_type__pc FROM Account WHERE document_type__pc ='NIF' LIMIT 1]; 
        System.assertEquals(1, lstAccAssert.size());
    }   
	/**
     * @description 
     */
    @isTest
    private static void testDelete() {
        Account acc1 = [SELECT Id,personal_document__pc,document_type__pc FROM Account WHERE document_type__pc='NIF' LIMIT 1];  
        Test.startTest();
        delete acc1;
        Test.stopTest();
        List<Account> lstAccAssert = [SELECT Id FROM Account WHERE document_type__pc ='NIF' LIMIT 1]; 
        System.assertEquals(0, lstAccAssert.size());
    }  
    
}