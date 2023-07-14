/**********************************************************************************
* @author       Francisco José Pérez
* @date         25/06/2020
* @description  Test  class fot the Task trigger entity.
* @Revision

FECHA       AUTOR		DESCRIPCION<br/>
13/05/2022  LCS JCB  	Modificación. Se modifican pruebas para adaptar al nuevo modelo
						y se añaden nuevas pruebas para cubrir el código de CESS_TaskHandler > CESS_TaskTriggerHelper
*
* @Revision     LCS-NestorR    31/05/2022  Modificación de creación de registros para corregir problemas de validación
05/08/2022  LCS MKB	   	Se añade las pruebas por la planificación de las tareas con contacto
05/08/2022  LCS JCL	   	Revisión
15/11/2022  LCS-MSC	   	Se cambian los teléfonos de las cuentas por error en la inserción al comprobar las reglas de duplicidad
**********************************************************************************/

@isTest
public class CESS_TaskHandlerTest {
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
        insert lead1;
        Account acc = new Account(
            LastName = 'ApeTestTask',
            Identifier_cess__pc = '12345',
            FirstName = 'ApeTestTask',
            PersonMobilePhone = '632333232',
            Document_type__pc = 'NIF',
            Personal_document__pc = '66573439P'
        );
        insert acc;
    }
//Modificación de la fecha planificada de la tarea
    @isTest
    public static void modifyRelatedCallOpp() {
        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345', FirstName='ApeTestTask', PersonMobilePhone='632233232',document_type__pc='NIF',personal_document__pc='06010769H');
        insert (acc);
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(2));
        insert (theOpp);
        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Open', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        insert (t);

        Test.startTest();
            t.CESS_Fecha_Planificada__c = System.today().addDays(2);
            update (t);

        Test.stopTest();

        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }
 //Modificación del estado de una tarea ya programada
    @isTest
    public static void modifyRelatedCallStatusOpp() {
        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345', FirstName='ApeTestTask', PersonMobilePhone='632393232',document_type__pc='NIF',personal_document__pc='16635995A');
        insert (acc);
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(2));
        insert (theOpp);
        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Open', CESS_Fecha_Planificada__c=System.today().addMonths(1));

        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        insert (t);

        Test.startTest();
            t.Status = 'Cancelled';
            update (t);
        Test.stopTest();

        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }

    // Test para comprobar la CANCELACIÓN de tareas cuando la Opp relacionada se actualiza a Closed
 @isTest
    public static void updateOppWithCall() {
        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345', PersonEmail='mail@mail.com',document_type__pc='NIF', personal_document__pc='89558024A', FirstName='ApeTestTask', PersonMobilePhone='632383232' );
        insert (acc);
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta',line_insurance__c='Hogar', interest_level__c='Medio',CloseDate=System.today().addMonths(1));
        insert (theOpp);
        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        insert (t);
        List <Task> lstTOutput1 = [SELECT Id, cti_error__c, status
                                FROM Task
                                ];
        Test.startTest();
        	theOpp.Closed_By__c = userInfo.getUserId();
        	theOpp.StageName='Perdido';
        	theOpp.Loss_Reason__c='Prima elevada';
        	update(theOpp);
        Test.stopTest();
        Task task1 = [SELECT Id, cti_error__c, status FROM Task LIMIT 1];
            System.assertEquals('Cancelled', task1.status, 'Task not cancelled');
    }
    //Comprobación de imposibilidad de crear tareas en una opp Cerrada
     @isTest
    public static void insertCallOnOppClosed() {
        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345', PersonEmail='mail@mail.com',document_type__pc='NIF', personal_document__pc='07035702W', FirstName='ApeTestTask', PersonMobilePhone='632373232');
        insert (acc);
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta',line_insurance__c='Hogar', interest_level__c='Medio',CloseDate=System.today().addMonths(1));
        insert (theOpp);
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        Test.startTest();
        	theOpp.Closed_By__c = userInfo.getUserId();
        	theOpp.StageName='Perdido';
        	theOpp.Loss_Reason__c='Prima elevada';
        	update(theOpp);
            Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        try{insert (t);
        }catch(Exception e){
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.stopTest();
    }


	//Test para la inserción de tareas con Oportunidad relacionada
    @isTest
    public static void insertRelatedCallOpp() {
        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345', FirstName='ApeTestTask', PersonMobilePhone='632343232',document_type__pc='NIF',personal_document__pc='33917902D');
        insert (acc);
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);
        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        Test.startTest();
            insert (t);
        Test.stopTest();

        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }
    //Test para verificar que no se insertan tareas duplicadas
    @isTest
    public static void insertRelatedCallOppDuplicated() {
        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345', FirstName='ApeTestTask', PersonMobilePhone='632353232',document_type__pc='NIF',personal_document__pc='05430945R');
        insert (acc);
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id ,StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);
        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Task t1 = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        Test.startTest();
        try{
            insert (t);
            insert (t1);
        }
        catch(Exception e){
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.stopTest();

    }

    @isTest
    public static void deleteRelatedCallOpp() {
        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345', FirstName='ApeTestTask', PersonMobilePhone='632363232',document_type__pc='NIF',personal_document__pc='38783626Z');
        insert (acc);
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);
        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        insert (t);

        Test.startTest();
            t.status = 'Completed';
            update(t);
        Test.stopTest();

        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }

    @isTest
    public static void modifyRelatedCallLead() {
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        Task t = new Task (WhoId=ld.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));

        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        insert (t);

        Test.startTest();
            t.CESS_Fecha_Planificada__c = System.today().addDays(2);
            update (t);

        Test.stopTest();

        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }

    @isTest
    public static void insertRelatedCallLead() {
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        Task t = new Task (WhoId=ld.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        System.debug('Task: ' + t);
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        Test.startTest();
            insert (t);
        Test.stopTest();

        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }
//Test para verificar que no se insertan tareas duplicadas en Lead
    @isTest
    public static void insertRelatedCallLeadDuplicated() {
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        Task t = new Task (WhoId=ld.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Task t1 = new Task (WhoId=ld.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));

        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        Test.startTest();
        try{
            insert (t);
            insert (t1);
        }
        catch(Exception e){
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.stopTest();
    }
    @isTest
    public static void deleteRelatedCallLead() {
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        Task t = new Task (WhoId=ld.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        insert (t);

        Test.startTest();
            t.status = 'Completed';
            update(t);
        Test.stopTest();

        List <Task> lstTOutput = [SELECT Id, cti_error__c
                                FROM Task
                                ];
        for (Task ts : lstTOutput){
            System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }

    @isTest
    public static void insertCallCloseLead() {
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        ld.Status = 'Unqualified';
        ld.result__c = 'No colabora';
        update (ld);
        Task t = new Task (WhoId=ld.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        Test.startTest();
            try{
                insert (t);
            }catch (Exception e){
                System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            }
        Test.stopTest();

    }
//Test para verificar que una tarea planificada no se puede borrar
    @isTest
    public static void deleteCallTaskLead() {
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        Task t = new Task (WhoId=ld.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        insert (t);

        Test.startTest();
            try{
                delete(t);
            }catch (Exception e){
                System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            }
        Test.stopTest();

    }

    // -------------------------- CONTACT WITHOUT OPPORTUNITY TESTS --------------------------

    // Test para verificar la creación de llamadas planificadas para contactos sin oportunidad
    @isTest
    public static void insertRelatedCallContact() {

        Account acc = [ SELECT Id, PersonContactId FROM Account LIMIT 1 ];
        Task t = new Task(
            WhoId = acc.PersonContactId,
            Type = CESS_TaskTriggerHelper.TASK_TYPE,
            Status = CESS_TaskTriggerHelper.TASK_STATUS_NOT_STARTED,
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        Test.startTest();

        insert t;

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO' , ts.cti_error__c.left( 2 ), 'Respuesta KO' );
        }

    }

    // Test para verificar la modificación de llamadas planificadas para contactos sin oportunidad
    @isTest
    public static void modifyRelatedCallContact() {

        Account acc = [ SELECT Id, PersonContactId FROM Account LIMIT 1 ];
        Task t = new Task(
            WhoId = acc.PersonContactId,
            Type = CESS_TaskTriggerHelper.TASK_TYPE,
            Status = CESS_TaskTriggerHelper.TASK_STATUS_NOT_STARTED,
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        insert t;

        Test.startTest();

        t.CESS_Fecha_Planificada__c = System.today().addDays( 2 );
        CESS_TaskHandler.hasInsert = false;
        update t;

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO' , ts.cti_error__c.left( 2 ), 'Respuesta KO' );
        }

    }

    // Test para verificar el borrado de llamadas planificadas para contactos sin oportunidad
    @isTest
    public static void deleteRelatedCallContact() {

        Account acc = [ SELECT Id, PersonContactId FROM Account LIMIT 1 ];
        Task t = new Task(
            WhoId = acc.PersonContactId,
            Type = CESS_TaskTriggerHelper.TASK_TYPE,
            Status = CESS_TaskTriggerHelper.TASK_STATUS_NOT_STARTED,
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        insert t;

        Test.startTest();

        t.status = CESS_TaskTriggerHelper.TASK_STATUS_COMPLETED;
        CESS_TaskHandler.hasInsert = false;
        update t;

        Test.stopTest();

        for( Task ts : [ SELECT Id, cti_error__c FROM Task ] ) {
            System.assertEquals( 'KO' , ts.cti_error__c.left( 2 ), 'Respuesta KO' );
        }

    }

    // Test para verificar que no se insertan tareas duplicadas en Contacto
    @isTest
    public static void insertRelatedCallContactDuplicated() {

        Account acc = [ SELECT Id, PersonContactId FROM Account LIMIT 1 ];
        Task t = new Task(
            WhoId = acc.PersonContactId,
            Type = CESS_TaskTriggerHelper.TASK_TYPE,
            Status = CESS_TaskTriggerHelper.TASK_STATUS_NOT_STARTED,
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );
        Task t1 = new Task(
            WhoId = acc.PersonContactId,
            Type = CESS_TaskTriggerHelper.TASK_TYPE,
            Status = CESS_TaskTriggerHelper.TASK_STATUS_NOT_STARTED,
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        insert t;

        Test.startTest();

        Database.SaveResult result = Database.insert( t1, false );

        Test.stopTest();

        System.assertEquals( CESS_TaskTriggerHelper.CALL_ALREADY_SCHEDULED, result.getErrors()[0].getMessage() );

    }

    // Test para verificar que no se puede planificar una tarea si el contacto está inactivo
    @isTest
    public static void insertCallInactiveContact() {

        Account acc = [ SELECT Id, PersonContactId, Customer_Status__pc FROM Account LIMIT 1 ];
        acc.Customer_Status__pc = CESS_TaskTriggerHelper.CUSTOMER_STATUS_INACTIVE;
        update acc;

        Task t = new Task(
            WhoId = acc.PersonContactId,
            Type = CESS_TaskTriggerHelper.TASK_TYPE,
            Status = CESS_TaskTriggerHelper.TASK_STATUS_NOT_STARTED,
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        Test.startTest();

        Database.SaveResult result = Database.insert( t, false );

        Test.stopTest();

        System.assertEquals( CESS_TaskTriggerHelper.NO_NEW_CALLS + ' contactos inactivos.', result.getErrors()[0].getMessage() );

    }

    // Test para verificar que una tarea planificada no se puede borrar
    @isTest
    public static void deleteCallTaskContact() {

        Account acc = [ SELECT Id, PersonContactId, Customer_Status__pc FROM Account LIMIT 1 ];
        Task t = new Task(
            WhoId = acc.PersonContactId,
            Type = CESS_TaskTriggerHelper.TASK_TYPE,
            Status = CESS_TaskTriggerHelper.TASK_STATUS_NOT_STARTED,
            CESS_Fecha_Planificada__c = System.today().addMonths( 1 )
        );

        Test.setMock( HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock() );
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();

        insert t;

        String errorMessage;

        Test.startTest();

        Database.DeleteResult result = Database.delete( t, false );

        Test.stopTest();

        System.assertEquals( CESS_TaskTriggerHelper.NO_DELETE_SCHEDULED_CALLS, result.getErrors()[0].getMessage() );

    }

}