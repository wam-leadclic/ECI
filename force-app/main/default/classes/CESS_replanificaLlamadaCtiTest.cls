/**********************************************************************************
* @author       Franciso José Pérez - franciscojose.pere@salesforce.com
* @date         5/07/2019
* @group        Test
* @description  Test class to test the CESS_replanificaLlamadaCtiBatch and CESS_replanificaLlamadaCtiScheludable class
* @Revision
**********************************************************************************/
@isTest
public class CESS_replanificaLlamadaCtiTest {
    
	@testSetup
    private static void setup() {
        
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        
        Account acc = new Account(LastName='ApeTestTask', PersonMobilePhone = '677777777', FirstName='ApeTestTask', document_type__pc='NIF',personal_document__pc='66573439P');
        insert (acc);

        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);

        List <Task> lstT = new List <Task>();
        
        lstT.add(new Task (Status='Not Started', Type = 'Schedule Call',
                            CESS_Fecha_Planificada__c=Datetime.now() + (0.024305), WhatId = theOpp.Id ));
        lstT.add(new Task (Status='Not Started', Type = 'Schedule Call',
                            CESS_Fecha_Planificada__c=Datetime.now() + (0.02), WhatId = theOpp.Id ));

        insert (lstT);


    }
    
	@isTest
	public static void testScheduleBatch() {
		
        CESS_ConsultaCTIDto.ctiResponse ctiResponse = new CESS_ConsultaCTIDto.ctiResponse();
        CESS_ctiResponseDto data = new CESS_ctiResponseDto();

        data.message = 'Processed correctly';
        ctiResponse.error = data;

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            JSON.serialize(ctiResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
		//Schedule the test job
		final String minuteString = System.now().addMinutes(1).minute().format();
		Schedulable sch = new CESS_replanificaLlamadaCtiSchedulable();
		final String cron = '05 '+ minuteString + ' * * * ?';
		
		Test.startTest();
			String jobId = System.schedule('CESS_replanificaLlamadaCtiSchedulable '+system.now(), cron, sch);
		Test.stopTest();

		//Get the information from the CronTrigger API object
		CronTrigger ct = [
			SELECT Id, CronExpression, TimesTriggered, NextFireTime
			FROM CronTrigger
			WHERE Id = :jobId
		];

		//Verify the expressions are the same
		System.assertEquals(
			cron,
			ct.CronExpression
		);

		//Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);	
	}
    
    @isTest
	public static void testExecuteBatch() {
		
        CESS_ConsultaCTIDto.ctiResponse ctiResponse = new CESS_ConsultaCTIDto.ctiResponse();
        CESS_ctiResponseDto data = new CESS_ctiResponseDto();

        data.message = 'Processed correctly';
        ctiResponse.error = data;

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            JSON.serialize(ctiResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        
        Test.startTest();        
            if ([SELECT count() FROM AsyncApexJob WHERE status = 'Queued' OR status = 'Processing' OR status = 'Preparing' OR status = 'Holding'] < 5){
               Database.Batchable<sObject> batchable = new CESS_replanificaLlamadaCtiBatch();
               Id batchProcessId = Database.executeBatch(batchable);
            } else {
                Schedulable sc2 = new CESS_replanificaLlamadaCtiSchedulable();
                Datetime dt = Datetime.now() + (0.024305); // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('CESS_replanificaLlamadaCtiSchedulable'+timeForScheduler,timeForScheduler,sc2);
            }
        Test.stopTest();

	}

    @isTest
    public static void testExecuteBatchWithError() {
		
        CESS_ConsultaCTIDto.ctiResponse ctiResponse = new CESS_ConsultaCTIDto.ctiResponse();
        CESS_ctiResponseDto data = new CESS_ctiResponseDto();

        data.message = 'Error. no processed';
        ctiResponse.error = data;

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            JSON.serialize(ctiResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        
        Test.startTest();        
            if ([SELECT count() FROM AsyncApexJob WHERE status = 'Queued' OR status = 'Processing' OR status = 'Preparing' OR status = 'Holding'] < 5){
               Database.Batchable<sObject> batchable = new CESS_replanificaLlamadaCtiBatch();
               Id batchProcessId = Database.executeBatch(batchable);
            } else {
                Schedulable sc2 = new CESS_replanificaLlamadaCtiSchedulable();
                Datetime dt = Datetime.now() + (0.024305); // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('CESS_replanificaLlamadaCtiSchedulable'+timeForScheduler,timeForScheduler,sc2);
            }
        Test.stopTest();

	}
}