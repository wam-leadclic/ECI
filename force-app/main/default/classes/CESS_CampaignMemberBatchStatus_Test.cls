@isTest
public class CESS_CampaignMemberBatchStatus_Test {
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
        lead1.source_manualrecord__c ='Llamada entrante';
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
    }
    
    @isTest
    public static void Test_UpdateCMWorking(){
        //Query for the Account record types
        List<RecordType> rtypesC = [Select Name, Id From RecordType 
        where sObjectType='Campaign' and isActive=true];
        List<RecordType> rtypesCM = [Select Name, Id From RecordType 
        where sObjectType='CampaignMember' and isActive=true];

        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String,String> cRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypesC)
        cRecordTypes.put(rt.Name,rt.Id);

        Map<String,String> cmRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypesCM)
        cmRecordTypes.put(rt.Name,rt.Id);
        


        Lead l1 = [SELECT Id, Status FROM Lead WHERE LastName = 'Name Lead1' LIMIT 1];
        Campaign campaign1 = new Campaign(Name = 'campaign1',recordTypeId = cRecordTypes.get('CTI'), Status = 'Planificada', CampaignMemberRecordTypeId = cmRecordTypes.get('CTI') );
        insert campaign1;
        Campaign campaign2 = new Campaign();
        campaign2.Name = 'campaign2';
        campaign2.recordTypeId = cRecordTypes.get('Marketing');
        campaign2.CampaignMemberRecordTypeId = cmRecordTypes.get('Marketing');
        campaign2.Status = 'Planificada';
        insert campaign2;
        Campaign campaign3 = new Campaign();
        campaign3.Name = 'campaign3';
        campaign3.recordTypeId = cRecordTypes.get('Marketing');
        campaign3.CampaignMemberRecordTypeId = cmRecordTypes.get('Marketing');
        campaign3.Status = 'Planificada';
        insert campaign3;
        CampaignMember cm = new CampaignMember(status='New', CampaignId=campaign1.Id, LeadId = l1.Id );
        insert cm;
        CampaignMember cm2 = new CampaignMember(status='Working', RelatedCTICampaignMemberId__c=cm.Id, CampaignId=campaign2.Id, LeadId = l1.Id);
        insert cm2;
        CampaignMember cm3 = new CampaignMember(status='New', RelatedCTICampaignMemberId__c=cm.Id, CampaignId=campaign3.Id, LeadId = l1.Id);
        insert cm3;
        List<CampaignMember> lst = [SELECT Id, RecordType.Name, Status, RelatedCTICampaignMemberId__c FROM CampaignMember];
        Test.startTest();
        Database.executeBatch(new CESS_CampaignMemberBatchStatus(), 200);
        Test.stopTest();
        List<CampaignMember> lst2 = [SELECT Id, RecordType.Name, Status, Result__c, RelatedCTICampaignMemberId__c, CTISend__c FROM CampaignMember];
        
    }
}