/**********************************************************************************
* @author       Franciso José Pérez - franciscojose.pere@salesforce.com
* @date         15/06/2020
* @group        Test
* @description  Test class for CESS_BulkifiedCTILogic
* @Revision
  @Revision		LCS-JCB     09/05/2022    Creación de pruebas adaptadas al nuevo modelo, que toma valores del CampaignMember asociado
  @Revision     LCS-NestorR 31/05/2022  Modificación del testsetup para arreglar problemas de validación con los registros
  @Revision     LCS-MKB     05/08/2022  se añade las pruebas del envío de llamadas para contactos sin oportunidad
  @Revision     LCS-MSC     15/11/2022  Se cambian los teléfonos de las cuentas por error en la inserción al comprobar las reglas de duplicidad
  @Revision     LCS-AMT     15/11/2022  se añade las pruebas del envío de llamadas para contactos con oportunidad
**********************************************************************************/
@isTest
public class CESS_BulkifiedCTILogic_Test {

    @testSetup
    private static void setup() {

        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        Lead lead1 = orgDataUtils.newLead('Lead1');
        lead1.document_number__c = '15213308G';
        lead1.document_type__c = 'NIF';
        lead1.Status = 'New';
        lead1.Phone = '911111111';
        lead1.MobilePhone = '611111111';
		lead1.Email = 'testEmail1@leadclic.com';
        lead1.sent_cti__c = false;
        lead1.identifier_cess__c= 'test';
        //lead1.schedulecontact_datetime__c = System.today().addMonths(1);
        lead1.risk_postalcode__c = '28001';
        lead1.gender__c = 'MALE';
        lead1.age__c=29;
        insert lead1;

        Lead lead2 = orgDataUtils.newLead('Lead2');
        lead2.document_number__c = '00000001R';
        lead2.document_type__c = 'NIF';
        lead2.Status = 'New';
        lead2.Phone = '922222222';
        lead2.MobilePhone = '622222222';
		lead2.Email = 'testEmail2@leadclic.com';
        lead2.sent_cti__c = true;
        lead2.identifier_cess__c= 'test';
        insert lead2;
        Campaign campaign1 = new Campaign(Name = 'campaign1', recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('CTI').getRecordTypeId(), Status = 'Planificada', ScriptUrl__c='00v7Z000003RB3GQAW' );
        insert campaign1;
        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345',FirstName='ApeTestTask', PersonMobilePhone='632333232',document_type__pc='NIF',personal_document__pc='66573439P');
   		insert (acc);
    }
    /**
    @description    Método para probar la inserción de  llamada planificada, con una oportunidad relacionada
    @param
    @return
    */
@isTest
public static void insertRelatedCallsOpp() {
    Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12375',FirstName='ApeTestTask', PersonMobilePhone='632333272',document_type__pc='NIF',personal_document__pc='68863487S');
    insert (acc);
    Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, CTI_Campaign__c='CESS-CTI',StageName='Propuesta', Skill__c='12',CloseDate=System.today().addMonths(1));
    insert (theOpp);
    Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
    Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());

    Test.startTest();
        insert (t);
    Test.stopTest();

    List <Task> lstTOutput = [SELECT Id, cti_error__c
                            FROM Task];
    for (Task ts : lstTOutput){
        System.debug('-----insertRelatedCallsOpp-----Task cti_error__c: ' + ts.cti_error__c);
        System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO correcta');
    }
}
    /**
    @description    Método para probar la inserción de  llamada planificada, con una oportunidad relacionada y miembro de campaña relacionado
    @param
    @return
    */
@isTest
public static void insertRelatedCallsOppCM() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Contact con = [SELECT Id, Account.Name FROM Contact];
  	Campaign c = [SELECT Id FROM Campaign LIMIT 1];
	CampaignMember cm = new CampaignMember(status='New', CampaignId=c.Id, ContactId=con.Id );
    insert (cm);
    Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1), relatedCTICampaignMemberId__c= String.valueOf(cm.Id));
    insert (theOpp);
    Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
    Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());

    Test.startTest();
        insert (t);
    Test.stopTest();

    List <Task> lstTOutput = [SELECT Id, cti_error__c
                            FROM Task];
    for (Task ts : lstTOutput){
        System.debug('-----insertRelatedCallsOppCM-----Task cti_error__c: ' + ts.cti_error__c);
        System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO correcta');
    }
}


@isTest
public static void deleteRelatedCallsOpp() {
        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12645',FirstName='ApeTestTask', PersonMobilePhone='632333262',document_type__pc='NIF',personal_document__pc='70016205L');
        insert (acc);
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);
        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        List<Id> tasksIds = new List<Id>();
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());

        Test.startTest();
            insert (t);
            tasksIds.add(t.Id);
            System.debug('Opp: ' + [Select isClosed, Stagename, id from opportunity]);
            t.status = 'Completed';
            System.debug('Tarea, antes de hacer el update: ' + t);
            update (t);

            bctil.deleteRelatedCalls(tasksIds);

        Test.stopTest();
        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.debug('Task cti_error__c: ' + ts.cti_error__c);
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }
@isTest
public static void deleteRelatedCallsOppCM() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
    	Contact con = [SELECT Id, Account.Name FROM Contact];
  		Campaign c = [SELECT Id FROM Campaign LIMIT 1];
		CampaignMember cm = new CampaignMember(status='New', CampaignId=c.Id, ContactId=con.Id);
    	insert (cm);
    	Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1), relatedCTICampaignMemberId__c= String.valueOf(cm.Id));
    	insert (theOpp);

        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        List<Id> tasksIds = new List<Id>();
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());

        Test.startTest();
            insert (t);
            tasksIds.add(t.Id);
            t.status = 'Completed';
            System.debug('Tarea, antes de hacer el update: ' + t);
            update (t);

            bctil.deleteRelatedCalls(tasksIds);

        Test.stopTest();
        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.debug('Task cti_error__c: ' + ts.cti_error__c);
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }
    }
    /**
    @description    Método para probar la modificación de fecha de una llamada planificada
    @param
    @return
    */
@isTest
public static void modifyRelatedCallsOpp() {
    Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12385',FirstName='ApeTestTask', PersonMobilePhone='632333282',document_type__pc='NIF',personal_document__pc='69999778Z');
    insert (acc);
    Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
    insert (theOpp);
    Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
    Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
    List<Id> tasksIds = new List<Id>();
    CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

    Test.startTest();
        insert (t);
        tasksIds.add(t.Id);
        List <Task> lstTO = [SELECT Id, cti_error__c
                            FROM Task limit 1];
        Task tas = lstTO.get(0);
        tas.CESS_Fecha_Planificada__c = System.today().addDays(2);
        update (tas);

        bctil.updateRelatedCalls(tasksIds);

    Test.stopTest();
    List <Task> lstTOutput = [SELECT Id, cti_error__c
                            FROM Task
                            ];
    for (Task ts : lstTOutput){
        System.debug('Task modify cti_error__c: ' + ts.cti_error__c);
        System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
    }
}
    /**
    @description    Método para probar la modificación de fecha de una llamada planificada, con una oportunidad y miembro de campaña relacionado
    @param
    @return
    */
@isTest
public static void modifyRelatedCallsOppCM() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Contact con = [SELECT Id, Account.Name FROM Contact];
  	Campaign c = [SELECT Id FROM Campaign LIMIT 1];
	CampaignMember cm = new CampaignMember(status='New', CampaignId=c.Id, ContactId=con.Id);
    insert (cm);
    Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1), relatedCTICampaignMemberId__c= String.valueOf(cm.Id));
    insert (theOpp);
    Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
    Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
    List<Id> tasksIds = new List<Id>();
    CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

    Test.startTest();
        insert (t);
        tasksIds.add(t.Id);
        List <Task> lstTO = [SELECT Id, cti_error__c
                            FROM Task limit 1];
        Task tas = lstTO.get(0);
        tas.CESS_Fecha_Planificada__c = System.today().addDays(2);
        update (tas);

        bctil.updateRelatedCalls(tasksIds);

    Test.stopTest();
    List <Task> lstTOutput = [SELECT Id, cti_error__c
                            FROM Task
                            ];
    for (Task ts : lstTOutput){
        System.debug('Task modify cti_error__c: ' + ts.cti_error__c);
        System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
    }
}
    /**
    @description    Método para probar la inserción de  llamada planificada, con un lead relacionado
    @param
    @return
    */
@isTest
public static void insertRelatedCallsLead() {
    Lead ld = [SELECT Id FROM Lead LIMIT 1];
    Task t = new Task (WhoId=ld.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
    Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
    Test.startTest();
        insert (t);
    Test.stopTest();
    List <Task> lstTOutput = [SELECT Id, cti_error__c
                            FROM Task];
    for (Task ts : lstTOutput){
        System.debug('Task cti_error__c: ' + ts.cti_error__c);
        System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO correcta');
    }
}
    /**
    @description    Método para probar la inserción de  llamada planificada, con un lead y miembro de campaña relacionado
    @param
    @return
    */
@isTest
public static void insertRelatedCallsLeadCM() {
    Lead ld = [SELECT Id FROM Lead LIMIT 1];
  	Campaign c = [SELECT Id FROM Campaign LIMIT 1];
	CampaignMember cm = new CampaignMember(status='New', CampaignId=c.Id, LeadId = ld.Id );
    insert (cm);
    Task t = new Task (WhoId=ld.Id, CampaignMemberId__c=cm.Id, type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
    Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
    Test.startTest();
        insert (t);
    Test.stopTest();
    List <Task> lstTOutput = [SELECT Id, cti_error__c
                            FROM Task];
    for (Task ts : lstTOutput){
        System.debug('Task cti_error__c: ' + ts.cti_error__c);
        System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO correcta');
    }
}
@isTest
public static void deleteRelatedCallsLead() {
    Lead ld = [SELECT Id FROM Lead LIMIT 1];
    Task t = new Task (WhoId=ld.Id,type = 'Schedule Call', Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));

        List<Id> tasksIds = new List<Id>();
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());

        Test.startTest();
            insert (t);
            tasksIds.add(t.Id);
            //System.debug('Opp: ' + [Select isClosed, Stagename, id from opportunity]);
            t.status = 'Completed';
            System.debug('Tarea, antes de hacer el update: ' + t);
            update (t);

            bctil.deleteRelatedCalls(tasksIds);

        Test.stopTest();

        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.debug('Task cti_error__c: ' + ts.cti_error__c);
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }
@isTest
public static void deleteRelatedCallsLeadCM() {
    Lead ld = [SELECT Id FROM Lead LIMIT 1];
    Campaign c = [SELECT Id FROM Campaign LIMIT 1];
	CampaignMember cm = new CampaignMember(status='New', CampaignId=c.Id, LeadId = ld.Id);
    insert (cm);
    Task t = new Task (WhoId=ld.Id,CampaignMemberId__c=cm.Id,type = 'Schedule Call', Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));

        List<Id> tasksIds = new List<Id>();
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());

        Test.startTest();
            insert (t);
            tasksIds.add(t.Id);
            //System.debug('Opp: ' + [Select isClosed, Stagename, id from opportunity]);
            t.status = 'Completed';
            System.debug('Tarea, antes de hacer el update: ' + t);
            update (t);

            bctil.deleteRelatedCalls(tasksIds);

        Test.stopTest();
        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.debug('Task cti_error__c: ' + ts.cti_error__c);
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

}
@isTest
public static void modifyRelatedCallsLead() {
    Lead ld = [SELECT Id FROM Lead LIMIT 1];

    Task t = new Task (WhoId=ld.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));

    Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
    List<Id> tasksIds = new List<Id>();
    CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

    Test.startTest();
        insert (t);
        tasksIds.add(t.Id);
        List <Task> lstTO = [SELECT Id, cti_error__c
                            FROM Task limit 1];
        Task tas = lstTO.get(0);
        tas.CESS_Fecha_Planificada__c = System.today().addDays(2);
        System.debug('Task modify antes de update: ' + tas);
        update (tas);

        bctil.updateRelatedCalls(tasksIds);

    Test.stopTest();

    List <Task> lstTOutput = [SELECT Id, cti_error__c
                            FROM Task
                            ];
    for (Task ts : lstTOutput){
        System.debug('Task modify cti_error__c: ' + ts.cti_error__c);
        System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
    }

}
@isTest
    public static void modifyRelatedCallsLeadCM() {
    Lead ld = [SELECT Id FROM Lead LIMIT 1];
	Campaign c = [SELECT Id FROM Campaign LIMIT 1];
	CampaignMember cm = new CampaignMember(status='New', CampaignId=c.Id, LeadId = ld.Id);
    insert (cm);
    Task t = new Task (WhoId=ld.Id,CampaignMemberId__c=cm.Id, type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));

    Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
    List<Id> tasksIds = new List<Id>();
    CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

    Test.startTest();
        insert (t);
        tasksIds.add(t.Id);
        List <Task> lstTO = [SELECT Id, cti_error__c
                            FROM Task limit 1];
        Task tas = lstTO.get(0);
        tas.CESS_Fecha_Planificada__c = System.today().addDays(2);
        System.debug('Task modify antes de update: ' + tas);
        update (tas);

        bctil.updateRelatedCalls(tasksIds);

    Test.stopTest();

    List <Task> lstTOutput = [SELECT Id, cti_error__c
                            FROM Task
                            ];
    for (Task ts : lstTOutput){
        System.debug('Task modify cti_error__c: ' + ts.cti_error__c);
        System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
    }

	}

    // -------------------------- CONTACT WITHOUT OPPORTUNITY TESTS --------------------------

    /**
    @description    Método para probar la inserción de  llamada planificada, con un Contacto relacionado
    */
    @isTest
    public static void insertRelatedCallsContact() {

        Account acc = [ SELECT Id, PersonContactId FROM Account LIMIT 1 ];
        Task t = new Task( WhoId = acc.PersonContactId, Type = 'Schedule Call', Status = 'Not Started', CESS_Fecha_Planificada__c = System.today().addMonths( 1 ) );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );
        Test.startTest();

        insert t;

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO', ts.cti_error__c.left( 2 ), 'Respuesta KO correcta' );
        }

    }

    /**
    @description    Método para probar la inserción de llamada planificada, con un Contacto y miembro de campaña relacionado
    */
    @isTest
    public static void insertRelatedCallsContactCM() {

        Account acc = [ SELECT Id, PersonContactId FROM Account ];
        Campaign c = [ SELECT Id FROM Campaign LIMIT 1 ];
        CampaignMember cm = new CampaignMember( Status = 'New', CampaignId = c.Id, ContactId = acc.PersonContactId );
        insert cm;
        Task t = new Task(
            WhoId = acc.PersonContactId,
            CampaignMemberId__c = cm.Id,
            Type = 'Schedule Call',
            Status = 'Not Started',
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );
        Test.startTest();

        insert t;

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO', ts.cti_error__c.left( 2 ), 'Respuesta KO correcta' );
        }

    }

    /**
    @description    Método para probar el borrado de llamada planificada, con un Contacto
    */
    @isTest
    public static void deleteRelatedCallsContact() {

        Account acc = [ SELECT Id, PersonContactId FROM Account ];
        Task t = new Task( WhoId = acc.PersonContactId, Type = 'Schedule Call', Status = 'Not Started', CESS_Fecha_Planificada__c = System.today().addMonths( 1 ) );

        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );

        insert t;
        t.status = 'Completed';
        update t;

        Test.startTest();

        bctil.deleteRelatedCalls( new List<Id>{ t.Id } );

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO', ts.cti_error__c.left( 2 ), 'Respuesta KO correcta' );
        }

    }

    /**
    @description    Método para probar el borrado de llamada planificada, con un Contacto y un miembro de campaña
    */
    @isTest
    public static void deleteRelatedCallsContactCM() {

        Account acc = [ SELECT Id, PersonContactId FROM Account ];
        Campaign c = [ SELECT Id FROM Campaign LIMIT 1 ];
        CampaignMember cm = new CampaignMember( Status = 'New', CampaignId = c.Id, ContactId = acc.PersonContactId );
        insert cm;
        Task t = new Task(
            WhoId = acc.PersonContactId,
            CampaignMemberId__c = cm.Id,
            Type = 'Schedule Call',
            Status = 'Not Started',
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );

        insert t;
        t.status = 'Completed';
        update t;

        Test.startTest();

        bctil.deleteRelatedCalls( new List<Id>{ t.Id } );

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO', ts.cti_error__c.left( 2 ), 'Respuesta KO correcta' );
        }

    }

    /**
    @description    Método para probar la modificación de llamada planificada, con un Contacto
    */
    @isTest
    public static void modifyRelatedCallsContact() {

        Account acc = [ SELECT Id, PersonContactId FROM Account ];
        Task t = new Task( WhoId = acc.PersonContactId, Type = 'Schedule Call', Status = 'Not Started', CESS_Fecha_Planificada__c = System.today().addMonths( 1 ) );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );

        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        insert t;
        t.CESS_Fecha_Planificada__c = System.today().addDays( 2 );
        update t;

        Test.startTest();

        bctil.updateRelatedCalls( new List<Id>{ t.Id } );

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO', ts.cti_error__c.left( 2 ), 'Respuesta KO correcta' );
        }

    }

    /**
    @description    Método para probar la modificación de llamada planificada, con un Contacto y un miembro de campaña
    */
    @isTest
    public static void modifyRelatedCallsContactCM() {

        Account acc = [ SELECT Id, PersonContactId FROM Account ];
        Campaign c = [ SELECT Id FROM Campaign LIMIT 1 ];
        CampaignMember cm = new CampaignMember( Status = 'New', CampaignId = c.Id, ContactId = acc.PersonContactId );
        insert cm;
        Task t = new Task(
            WhoId = acc.PersonContactId,
            CampaignMemberId__c = cm.Id,
            Type = 'Schedule Call',
            Status = 'Not Started',
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );

        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        insert t;
        t.CESS_Fecha_Planificada__c = System.today().addDays( 2 );
        update t;

        Test.startTest();

        bctil.updateRelatedCalls( new List<Id>{ t.Id } );

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO', ts.cti_error__c.left( 2 ), 'Respuesta KO correcta' );
        }

	}
 // -------------------------- CONTACT WITH OPPORTUNITY TESTS --------------------------

    /**
    @description    Método para probar la inserción de llamada planificada, con un Contacto y miembro de campaña relacionado y una oportunidad asociada al Contacto
    */
    @isTest
    public static void insertRelatedCallsContactCMOpp() {

        Account acc = [ SELECT Id, PersonContactId FROM Account ];
        Campaign c = [ SELECT Id FROM Campaign LIMIT 1 ];
        CampaignMember cm = new CampaignMember( Status = 'New', CampaignId = c.Id, ContactId = acc.PersonContactId, LineInsurance__c = 'Salud');
        insert cm;
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1), relatedCTICampaignMemberId__c = cm.Id, line_insurance__c = 'Salud');
        insert theOpp;
        Task t = new Task(
            WhoId = acc.PersonContactId,
            CampaignMemberId__c = cm.Id,
            Type = 'Schedule Call',
            Status = 'Not Started',
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );
        Test.startTest();

        insert t;

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO', ts.cti_error__c.left( 2 ), 'Respuesta KO correcta' );
        }

    }

    /**
    @description    Método para probar la modificación de llamada planificada, con un Contacto y un miembro de campaña y una oportunidad asociada al Contacto
    */
    @isTest
    public static void modifyRelatedCallsContactCMOpp() {

        Account acc = [ SELECT Id, PersonContactId FROM Account ];
        Campaign c = [ SELECT Id FROM Campaign LIMIT 1 ];
        CampaignMember cm = new CampaignMember( Status = 'New', CampaignId = c.Id, ContactId = acc.PersonContactId, LineInsurance__c = 'Salud');
        insert cm;
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1), relatedCTICampaignMemberId__c = cm.Id, line_insurance__c = 'Salud');
        insert theOpp;
        Task t = new Task(
            WhoId = acc.PersonContactId,
            CampaignMemberId__c = cm.Id,
            Type = 'Schedule Call',
            Status = 'Not Started',
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );

        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        insert t;
        t.CESS_Fecha_Planificada__c = System.today().addDays( 2 );
        update t;

        Test.startTest();

        bctil.updateRelatedCalls( new List<Id>{ t.Id } );

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO', ts.cti_error__c.left( 2 ), 'Respuesta KO correcta' );
        }

	}

//////////////////////////////////
@isTest
    public static void insertCallsFromIntegrationEvPlanificada() {
       Campaign c = [SELECT Id FROM Campaign LIMIT 1];
       Lead ld = [SELECT Id FROM Lead WHERE document_number__c = '15213308G' LIMIT 1 ];
       ld.schedulecontact_datetime__c = System.today().addMonths(1);
       update ld;
       CampaignMember cm = new CampaignMember(status='New', CampaignId=c.Id, LeadId = ld.Id, CampaignCess__c='campaña_autos',
                                             SourceCess__c='cotizacion_autos', SourceType__c='WEB', LineInsurance__c='Autos/Motos',CTISkill__c='13'	);
       insert (cm);

       List<CESS_Integration_Event__e> events = new List<CESS_Integration_Event__e>();
       CESS_Integration_Event__e ev1 = new CESS_Integration_Event__e();
       ev1.Object_Id__c = cm.Id;
       events.add(ev1);

       Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClientEvent_Mock());
       CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
       Test.startTest();
       		bctil.insertCallsFromIntegrationEvents(events);
       Test.stopTest();
       List <CampaignMember> lstTOutput = [SELECT Id, CTIError__c, CTISent__c
                            FROM CampaignMember
                            ];
       for (CampaignMember campM : lstTOutput){
            System.assertEquals(true,campM.CTISent__c, 'No enviado a CTI');
        }
    }
@isTest
    public static void insertCallsFromIntegrationEvInsert() {
       Campaign c = [SELECT Id FROM Campaign LIMIT 1];
       Lead ld = [SELECT Id FROM Lead WHERE document_number__c = '15213308G' LIMIT 1 ];
       CampaignMember cm = new CampaignMember(status='New', CampaignId=c.Id, LeadId = ld.Id, CampaignCess__c='campaña_autos',
                                             SourceCess__c='cotizacion_autos', SourceType__c='WEB', LineInsurance__c='Autos/Motos', CTISkill__c='12'	);
       insert (cm);

       List<CESS_Integration_Event__e> events = new List<CESS_Integration_Event__e>();
       CESS_Integration_Event__e ev1 = new CESS_Integration_Event__e();
       ev1.Object_Id__c = cm.Id;
       events.add(ev1);


       Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClientEvent_Mock());
       CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
       Test.startTest();
       		bctil.insertCallsFromIntegrationEvents(events);
       Test.stopTest();
       List <CampaignMember> lstTOutput = [SELECT Id, CTIError__c, CTISent__c
                            FROM CampaignMember
                            ];
       for (CampaignMember campM : lstTOutput){
            System.assertEquals(true,campM.CTISent__c, 'No enviado a CTI');
        }
    }



}