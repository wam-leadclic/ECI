/**********************************************************************************
* @author       Maria Dolores Sánchez Meroño
* @date         10/02/2020
* @group        Test
* @description  Clase de test para CESS_ScheduleTaskLWCCtrl
* @Revision
FECHA       AUTOR       DESCRIPCION<br/>
18/05/2022  LCS JCB	   	Se añade prueba testCancelarTaskAndCreateNewLeadWithCM para
						comprobar inserción de Argumentario en Lead con param. Id CampMember
						Se añade System.Assert en las pruebas que no lo tenian
*
*@Revision       LCS-NestorR   31/05/2022  Modificación del testSetup para corregir problemas de validación con los registros
05/08/2022  LCS MKB	    Se añade la posibilidad de registrar una llamada planificada para contactos sin oportunidad asociada
05/08/2022  LCS JCL	    Revisión de código
**********************************************************************************/
@istest
public with sharing class CESS_ScheduleTaskLWCCtrlTest {

    /**
     * @description test setup
     */
    @testSetup
    private static void setup(){
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        SAC_TestDataUtils sacDataUtils = SAC_TestDataUtils.getInstance();

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

        //Lead newLead = orgDataUtils.newLead('test');
       // insert newLead;

        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345', FirstName='ApeTestTask', PersonMobilePhone='632333232',document_type__pc='NIF',personal_document__pc='66573439P');
        insert (acc);
        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);
        Task t2 = new Task(
            WhatId = theOpp.Id,
            Type = CESS_ScheduleTaskLWCCtrl.TASK_TYPE,
            Status = CESS_ScheduleTaskLWCCtrl.TASK_STATUS_NOT_STARTED,
            CESS_Fecha_Planificada__c = System.today().addMonths(1)
        );
        insert t2;
        Task t = new Task();
        t.CESS_Fecha_Planificada__c = System.now().addDays(1);
        t.IsReminderSet  = false;
        t.Priority = CESS_ScheduleTaskLWCCtrl.TASK_PRIORITY_NORMAL;
        t.Status = CESS_ScheduleTaskLWCCtrl.TASK_STATUS_NOT_STARTED;
        t.subject = CESS_ScheduleTaskLWCCtrl.TASK_SUBJECT;
        t.Type = CESS_ScheduleTaskLWCCtrl.TASK_TYPE;
        t.WhoId = lead1.Id;
        insert t;
        PlanificacionLlamadas__c planLunes = orgDataUtils.newPlanLLamadaEstandar('Lunes',2,'Madrid');
        PlanificacionLlamadas__c planMartes = orgDataUtils.newPlanLLamadaEstandar('Martes',2,'Madrid');
        PlanificacionLlamadas__c planMiercoles = orgDataUtils.newPlanLLamadaEstandar('Miercoles',2,'Madrid');
        PlanificacionLlamadas__c planJueves = orgDataUtils.newPlanLLamadaEstandar('Jueves',2,'Madrid');
        PlanificacionLlamadas__c planViernes = orgDataUtils.newPlanLLamadaEstandar('Viernes',2,'Madrid');
        PlanificacionLlamadas__c planSabado = orgDataUtils.newPlanLLamadaEstandar('Sabado',2,'Madrid');
        List<PlanificacionLlamadas__c> lstPlan = new List<PlanificacionLlamadas__c>();
        lstPlan.add(planLunes);
        lstPlan.add(planMartes);
        lstPlan.add(planMiercoles);
        lstPlan.add(planJueves);
        lstPlan.add(planViernes);
        lstPlan.add(planSabado);
        insert lstPlan;

        Campaign campaign = new Campaign(Name = 'campaignCTI', recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('CTI').getRecordTypeId(), Status = 'Planificada' );
        insert campaign;
    }


    @isTest
     static void testObtainRecordTasks() {
        Lead ld = [SELECT Id,contact_attempts__c from Lead];
        List<Task> lstTask = CESS_ScheduleTaskLWCCtrl.obtainRecordTasks(ld.Id, 'Lead');
        System.assert(lstTask.size()>0,'No se han obtenido tareas');
    }
    @isTest
     static void testObtainTasksInCenterForThatDay() {
        Datetime dat = System.now().addMonths(1);
        string dia = string.ValueOf(dat.day());
        if(dia.length()==1){
             dia = '0'+ dia;
        }
       string mes = string.ValueOf(dat.month());
        if(mes.length()==1){
             mes = '0'+ mes;
        }
        String fecha =dat.year()+ '-'  + mes + '-' + dia;
         System.debug('fecha: ' + fecha);
        List<Task> lstTask = CESS_ScheduleTaskLWCCtrl.obtainTasksInCenterForThatDay(fecha,'Madrid');

    }
    @isTest
    static void testGetPlanificacion() {
        List<PlanificacionLlamadas__c> lstPlan = CESS_ScheduleTaskLWCCtrl.getPlanificacion('Madrid');
        System.assertEquals(6, lstPlan.size());
    }
    @isTest
     static void testCancelarTaskAndCreateNewLead() {
        Lead ld = [SELECT Id,contact_attempts__c from Lead];
        Datetime dat = System.now().addDays(1);
        String mes = string.ValueOf(dat.month());
        if(mes.length()==1){
             mes = '0'+ mes;
        }
        Integer mesNumber = integer.valueof(mes);
        test.startTest();
        CESS_ScheduleTaskLWCCtrl.cancelarTask(ld.Id,'Lead');
        CESS_ScheduleTaskLWCCtrl.createTaskFromLead(integer.valueof(dat.year()),mesNumber,integer.valueof(dat.day()), 10, 30,ld.Id,'');
        test.stopTest();
        List<Task> lstTask = [SELECT Id,Status, CampaignMemberId__c from Task where whoId = :ld.Id];
        SYstem.assertEquals(2, lstTask.size());

    }
    //Con Id CampaignMember pasado como parámetro desde argumentario
    @isTest
     static void testCancelarTaskAndCreateNewLeadWithCM() {
        Lead ld = [SELECT Id,contact_attempts__c from Lead];
        Campaign c = [SELECT Id FROM Campaign LIMIT 1];
		CampaignMember cm = new CampaignMember(status='New', CampaignId=c.Id, LeadId = ld.Id);
    	insert (cm);
        Datetime dat = System.now().addDays(1);
        String mes = string.ValueOf(dat.month());
        if(mes.length()==1){
             mes = '0'+ mes;
        }
        Integer mesNumber = integer.valueof(mes);
        test.startTest();
        CESS_ScheduleTaskLWCCtrl.cancelarTask(ld.Id,'Lead');
        CESS_ScheduleTaskLWCCtrl.createTaskFromLead(integer.valueof(dat.year()),mesNumber,integer.valueof(dat.day()), 10, 30,ld.Id,cm.Id);
        test.stopTest();
        List<Task> lstTask = [SELECT Id,Status,CampaignMemberId__c from Task where whoId = :ld.Id];
        Task tCancel = [SELECT Id,Status from Task where whoId = :ld.Id AND Status='Cancelled' LIMIT 1];
        System.assert(tCancel!=null, 'La tarea previa no ha sido cancelada');
        System.assertEquals(2, lstTask.size());

    }
     @isTest
     static void testCancelarTaskAndCreateNewOpp() {
        Opportunity opp = [SELECT Id,Account.personContactId from Opportunity];
        Datetime dat = System.now().addDays(1);
        Integer mes = integer.valueof('0'+ dat.month());
        test.startTest();
        CESS_ScheduleTaskLWCCtrl.cancelarTask(opp.Id,'Opportunity');
        CESS_ScheduleTaskLWCCtrl.createTaskFromOpp(integer.valueof(dat.year()),mes,integer.valueof(dat.day()), 10, 30,opp.Id,opp.Account.personContactId);
        test.stopTest();
        List<Task> lstTask = [SELECT Id,Status from Task where whatId = :opp.Id];
        Task tCancel = [SELECT Id,Status from Task where whatId = :opp.Id AND Status='Cancelled' LIMIT 1];
        System.assert(tCancel!=null, 'La tarea previa no ha sido cancelada');
        SYstem.assertEquals(2, lstTask.size());

    }

    @isTest
    static void testCancelarTaskAndCreateNewContact() {

        Account acc = [ SELECT Id, PersonContactId FROM Account ];
        Datetime dat = System.now().addDays( 1 );
        Test.startTest();
        CESS_ScheduleTaskLWCCtrl.cancelarTask( acc.PersonContactId, 'Contact' );
        CESS_ScheduleTaskLWCCtrl.createTaskFromContact( dat.year(), dat.month(), dat.day(), 10, 30, acc.PersonContactId, '' );
        Test.stopTest();

        List<Task> lstTask = [ SELECT Id, Status FROM Task WHERE WhoId = :acc.PersonContactId ];
        System.assertEquals( 1, lstTask.size() );

    }

    @isTest
    static void testCancelarTaskAndCreateNewContactwithCM() {

        Account acc = [ SELECT Id, PersonContactId FROM Account ];
        Campaign c = [ SELECT Id FROM Campaign LIMIT 1 ];
        CampaignMember cm = new CampaignMember( status = 'New', CampaignId = c.Id, ContactId = acc.PersonContactId );
        insert cm;
        Datetime dat = System.now().addDays( 1 );
        Test.startTest();
        CESS_ScheduleTaskLWCCtrl.cancelarTask( acc.PersonContactId, 'Contact' );
        CESS_ScheduleTaskLWCCtrl.createTaskFromContact( dat.year(), dat.month(), dat.day(), 10, 30, acc.PersonContactId, cm.Id );
        Test.stopTest();

        List<Task> lstTask = [ SELECT Id, Status FROM Task WHERE WhoId = :acc.PersonContactId ];
        System.assertEquals( 1, lstTask.size() );

    }

}