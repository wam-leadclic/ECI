/**********************************************************************************
* @name         	CESS_LeadTriggerHandlerTest
* @version			1.0
* @creation date   	30/04/2020
* @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Test to the CESS_LeadTriggerHandlerTest class
* @group        	Helper
* @revision         AUTHOR          DATE        Reason
                    MMV - LCS       17/05/2022  Revisión y subida del test
**********************************************************************************/
@isTest
private class CESS_LeadTriggerHandlerTest {
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
        lead1.MobilePhone = '911231234';
        lstLeads.add(lead1);

        Lead lead2 = orgDataUtils.newLead('Lead2');
        lead2.document_number__c = 'X7853753N';
        lead2.document_type__c = 'NIE';
        lead2.MobilePhone = '911231235';
        lstLeads.add(lead2);

        Lead lead3 = orgDataUtils.newLead('Lead3');
        lead3.document_number__c = 'G0076915H';
        lead3.document_type__c = 'CIF';
        lead3.MobilePhone = '911231236';
        lstLeads.add(lead3);

        insert lstLeads;
    }
    /**
     * @description 
     */
    @isTest
    private static void testCheckIsNIFValid() {

        Lead lead1 = [SELECT Id,document_number__c,document_type__c FROM Lead WHERE document_type__c='NIF' LIMIT 1];  
        lead1.document_number__c = '03261550N';

        Test.startTest();
        update lead1;
        Test.stopTest();

        List<Lead> lstLeadAssert = [SELECT Id,document_number__c,document_type__c FROM Lead WHERE document_type__c ='NIF' LIMIT 1]; 
        System.assertEquals(1, lstLeadAssert.size());
    }   
	/**
     * @description 
     */
    @isTest
    private static void testDelete() {

        Lead lead1 = [SELECT Id,document_number__c,document_type__c FROM Lead WHERE document_type__c='NIF' LIMIT 1];  

        Test.startTest();
        delete lead1;
        Test.stopTest();

        List<Lead> lstLeadAssert = [SELECT Id,document_number__c,document_type__c FROM Lead WHERE document_type__c ='NIF' LIMIT 1]; 
        System.assertEquals(0, lstLeadAssert.size());
    }      
    		
    /**	
     * @description 	
     */	
    @isTest	
    private static void testTaskToDelete() {

        Lead ld = new Lead (
            LastName='TestDup1',
            source_manualrecord__c='Otros',
            Email = 'test1@email.com', 
            MobilePhone='666778899'
        );	
        insert (ld);

        Task t = new Task (
            WhoId=ld.Id,type = 'Schedule Call',
            Status = 'Not Started', 
            CESS_Fecha_Planificada__c=System.today().addMonths(1)
        );	
        insert (t);	

        ld.Status = 'Unqualified';	
        ld.result__c = 'No Interesado';	

        Test.startTest();	
        update ld;	
        Test.stopTest();

        List<Lead> lstLeadAssert = [SELECT Id,Status FROM Lead WHERE Email = 'test1@email.com' LIMIT 1]; 	
        System.assertEquals('Unqualified', lstLeadAssert.get(0).Status);	
        	
    }  	

}