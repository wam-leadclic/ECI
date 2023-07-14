/**********************************************************************************
* @author       María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @date         18/05/2019
* @group        Test
* @description  Test class to test the CESS_OppLeadReferentLXCtrlTest class
* @Revision
**********************************************************************************/
@isTest

public class CESS_OppLeadReferentLXCtrlTest {

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
        Opportunity opp = new Opportunity();
        opp.AccountId=a1.Id; 
        opp.Name = 'test1';
        opp.StageName = 'test1';
        opp.CloseDate = System.today();
        insert opp;
       
        Lead ld1 = orgDataUtils.newLead('test1');
        insert ld1;
        Database.LeadConvert lc = new database.LeadConvert();
   		lc.setLeadId(a1.Id);
        Lead ld2 = orgDataUtils.newLead('test2');  	
		ld2.Lead_Referrer__c = ld1.Id;
        insert ld2;
    }
    @IsTest static void testgetReferentAndOpp() {
        Lead ld2 = [SELECT Id,Lead_Referrer__r.Id from Lead WHERE Name = 'Name test2'];
        Test.startTest();
        Lead ld1  = CESS_OppLeadReferentLXCtrl.getReferent(ld2.Lead_Referrer__r.Id);
        List<Opportunity> lstOpp  = CESS_OppLeadReferentLXCtrl.getOpp(ld1.ConvertedOpportunityId);
        Test.stopTest();
    }

}