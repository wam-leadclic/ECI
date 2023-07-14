/**********************************************************************************
* @author       
* @date         
* @group        Test
* @description  Test class to test the ConvertLeadsInvocableTest class
* @revision
* @revision     LCS-NestorR    31/05/2022   Modificación de creación de registros para corregir problemas de validación
* @revision     LCS-MHG        22/11/2022   Agregar campo Medio (source_type__c) en la creación de leads (Validation Rules)
* y sustitución de creación de contacto por query en el método test_convert_lead_no_opportunity()
**********************************************************************************/

@isTest
private class ConvertLeadsInvocableTest {

    @isTest
    static void test_convert_lead_yes_opportunity() {
        Lead ld = new Lead(
            firstName = 'Marc',
            lastName = 'Benioff',
            document_number__c = '15213308G',
            document_type__c = 'NIF',
            result__c = 'Gestión Comercial',
            MobilePhone='632333232',
            show_cessinfo__c = false,
            source_type__c = 'Telefono'
        );

        insert ld;

        Test.startTest();

        ConvertLeadsInvocable.LeadConvertRequest request = new ConvertLeadsInvocable.LeadConvertRequest();
        request.leadId = ld.id;
        request.convertedStatus = [ SELECT id, ApiName FROM LeadStatus WHERE isConverted = true LIMIT 1 ].ApiName;
        request.createOpportunity = true;
        request.opportunityName = 'Test Opportunity';
        request.ownerId = UserInfo.getUserId();
        request.sendEmailToOwner = true;

        List<ConvertLeadsInvocable.LeadConvertResult> results = ConvertLeadsInvocable.convertLeads( new List<ConvertLeadsInvocable.LeadConvertRequest>{ request } );

        Test.stopTest();

        System.assert( results != null );
        System.assertEquals( 1, results.size() );

        ConvertLeadsInvocable.LeadConvertResult result = results[0];

        System.assertEquals( 1, [ SELECT count() FROM Account WHERE id = :result.accountId ] );
        System.assertEquals( 1, [ SELECT count() FROM Contact WHERE id = :result.contactId ] );
        System.assertEquals( 1, [ SELECT count() FROM Opportunity WHERE id = :result.opportunityId ] );

    }

    @isTest
    static void test_convert_lead_no_opportunity() {
		
       
        Account acct = new Account(
            LastName = 'Salesforce',
            FirstName='ApeTestTask', 
            PersonMobilePhone='632333232',
            document_type__pc='NIF',
            personal_document__pc='66573439P'
        );

        insert acct;

        Contact cont = [SELECT id FROM Contact WHERE AccountId=:acct.id];

        Lead ld = new Lead(
            firstName = 'Marc',
            lastName = 'Benioff',
            document_number__c = '15213308G',
            document_type__c = 'NIF',
            result__c = 'Gestión Comercial',
            mobilePhone = '632323233',
            show_cessinfo__c = false,
            source_type__c = 'Telefono'
        );

        insert ld;

        Test.startTest();

        ConvertLeadsInvocable.LeadConvertRequest request = new ConvertLeadsInvocable.LeadConvertRequest();
        request.leadId = ld.id;
        request.convertedStatus = [ SELECT id, ApiName FROM LeadStatus WHERE isConverted = true LIMIT 1 ].ApiName;
        request.createOpportunity = false;
        request.accountId = acct.id;
        request.contactId = cont.id;
        request.overwriteLeadSource = true;

        List<ConvertLeadsInvocable.LeadConvertResult> results = ConvertLeadsInvocable.convertLeads( new List<ConvertLeadsInvocable.LeadConvertRequest>{ request } );

        Test.stopTest();

        System.assert( results != null );
        System.assertEquals( 1, results.size() );

        ConvertLeadsInvocable.LeadConvertResult result = results[0];

        System.assertEquals( 1, [ SELECT count() FROM Account WHERE id = :result.accountId AND id = :acct.id ] );
        System.assertEquals( 1, [ SELECT count() FROM Contact WHERE id = :result.contactId AND id = :cont.id ] );
        System.assertEquals( 0, [ SELECT count() FROM Opportunity WHERE id = :result.opportunityId ] );

    }

}