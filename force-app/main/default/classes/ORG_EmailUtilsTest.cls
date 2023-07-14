/**********************************************************************************
* @author       Aaron Dominguez Sanchez - giovanni.modica@salesforce.com
* @date         13/08/2018
* @group        Test
* @description  Test trigger to test the ORG_EmailUtils class
* @Revision
**********************************************************************************/
@isTest
private class ORG_EmailUtilsTest {

    /**
     * @description 
     */
	@testSetup
    private static void setup() { 
        
    }
    
    /**
     * @description 
     */
    @isTest
    private static void testsingleMeail1() {

        // MMV: CAMBIADO PARA EVITAR DEPENDENCIAS
        //Id owaId = ORG_EmailUtils.getOrgWideEmailAddrrIdFromName(ORG_CaseTriggerHelper.EMAIL_ADDR_SAC_ECI);
        //Id emtId = ORG_EmailUtils.getEmailTemplateFromName(ORG_CaseTriggerHelper.EMAIL_TEMPL_NOTIFICACION_INFORMATIVA);
        Id owaId = ORG_EmailUtils.getOrgWideEmailAddrrIdFromName('Protección de datos CESS');
        Id emtId = ORG_EmailUtils.getEmailTemplateFromName('CTI_Vida');
        
        Test.startTest();

            Messaging.SingleEmailMessage mes1 = ORG_EmailUtils.createEmailByTemplate(emtId, UserInfo.getUserId(), null, null);
            Messaging.SingleEmailMessage mes2 = ORG_EmailUtils.createEmailByTemplate(emtId, new List<String>{'test@test.com'}, null, null, null);
        
        Test.stopTest();
    } 
    
    /**
     * @description 
     */
    @isTest
    private static void testsingleMeail2() { 

        // MMV: CAMBIADO PARA EVITAR DEPENDENCIAS
        //Id owaId = ORG_EmailUtils.getOrgWideEmailAddrrIdFromName(ORG_CaseTriggerHelper.EMAIL_ADDR_SAC_ECI);
        //Id emtId = ORG_EmailUtils.getEmailTemplateFromName(ORG_CaseTriggerHelper.EMAIL_TEMPL_NOTIFICACION_INFORMATIVA);
        Id owaId = ORG_EmailUtils.getOrgWideEmailAddrrIdFromName('Protección de datos CESS');
        Id emtId = ORG_EmailUtils.getEmailTemplateFromName('CTI_Vida');
        
        Test.startTest();

            Messaging.SingleEmailMessage mes1 = ORG_EmailUtils.createEmailByTemplate(emtId, UserInfo.getUserId(), null, owaId);
            Messaging.SingleEmailMessage mes2 = ORG_EmailUtils.createEmailByTemplate(emtId, new List<String>{'test@test.com'}, null, owaId, null);
            Messaging.SingleEmailMessage mes3 = ORG_EmailUtils.createHtmlEmail(new Set<String>{'test@test.com'},'Test','Test');
        
        Test.stopTest();      
    }     

    /**
     * @description 
     */
    @isTest
    private static void testCreateEmailRecord() {        

        Case theCase = new Case();
        insert theCase;
        
        Test.startTest();

            EmailMessage em = ORG_EmailUtils.createEmailMessage(new List<String>{'test','test'},'test','test',theCase.Id);
        
        Test.stopTest();      
    } 
}