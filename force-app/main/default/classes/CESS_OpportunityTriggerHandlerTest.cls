@isTest
public  class CESS_OpportunityTriggerHandlerTest {

    @isTest
    public static void modifyRelatedCallsOpp() {

        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345',FirstName='ApeTestTask', PersonMobilePhone='632333232',document_type__pc='NIF',personal_document__pc='66573439P');
        insert (acc);

        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);

        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        System.debug('Task: ' + t);

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
            //System.assertEquals('KO',ts.cti_error__c.left(2), 'Respuesta KO');
        }

    }


    @isTest
    public static void closeOpp() {

        Account acc = new Account(LastName='ApeTestTask', identifier_cess__pc='12345',FirstName='ApeTestTask', PersonMobilePhone='632333232',document_type__pc='NIF',personal_document__pc='66573439P',PersonEmail='testOppTrigger@test.com');
        insert (acc);

        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);

        Task t = new Task (WhatId=theOpp.Id,type = 'Schedule Call',Status = 'Not Started', CESS_Fecha_Planificada__c=System.today().addMonths(1));
        System.debug('Task: ' + t);

        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        List<Id> tasksIds = new List<Id>();
        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        insert (t);

        Test.startTest();
            theOpp.Closed_By__c = userInfo.getUserId();
            theOpp.StageName = 'Perdido';
            theOpp.Loss_Reason__c = 'Prima elevada';
            update (theOpp);

        Test.stopTest();
        
        List<Task> lstTaskAssert = [SELECT Id,Status FROM Task LIMIT 1]; 
        //System.assertEquals('Completed', lstTaskAssert.get(0).Status);

    }

}