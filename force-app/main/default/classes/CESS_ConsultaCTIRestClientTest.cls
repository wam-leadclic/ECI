@isTest
public class CESS_ConsultaCTIRestClientTest {


    @testSetup
    private static void setup() {
        
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        
        Account acc = new Account(LastName='ApeTestTask', FirstName='ApeTestTask', PersonMobilePhone='632333232',document_type__pc='NIF',personal_document__pc='66573439P');
        insert (acc);

        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);

        List <Task> lstT = new List <Task>();
        
        lstT.add(new Task (Status='Not Started', Type = 'Schedule Call',
        CESS_Fecha_Planificada__c=Datetime.now() + (0.024305), WhatId = theOpp.Id ));

        insert (lstT);


    }

    @IsTest
    public static void testReplanificaLlamadaOk(){
		
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

        CESS_ctiResponseDto response;

        Test.startTest();
            for (Task t : [SELECT Id, WhoId, WhatId, Status, Type, AccountId, CESS_Fecha_Planificada__c, OwnerId, owner_ctiuser__c, cti_error__c, Account.Phone, Account.PersonMobilePhone 
                          FROM Task WHERE Status = 'Not Started' and Type = 'Schedule Call' and CESS_Fecha_Planificada__c = TODAY]) {
                response = ORG_LeadLogic.replanificaLlamadaCTI(t);
            }//for
        Test.stopTest();

        System.assertEquals(response.message, 'Processed correctly','Task completadas');
        
    }

   @IsTest
    public static void testReplanificaLlamadaKO(){
		
        CESS_ConsultaCTIDto.ctiResponse ctiResponse = new CESS_ConsultaCTIDto.ctiResponse();
        CESS_ctiResponseDto data = new CESS_ctiResponseDto();

        data.message = 'No procesada correctamente';
        ctiResponse.error = data;

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            JSON.serialize(ctiResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
            for (Task t : [SELECT Id, WhoId, WhatId, Status, Type, AccountId, ReminderDateTime, OwnerId, owner_ctiuser__c, cti_error__c, Account.Phone, Account.PersonMobilePhone 
                           FROM Task WHERE Status = 'Not Started' and Type = 'Schedule Call' and ReminderDateTime = TODAY]) {
                CESS_ctiResponseDto response = ORG_LeadLogic.replanificaLlamadaCTI(t);
            }//for
        Test.stopTest();

       // System.assertEquals(1, [SELECT count() FROM Task WHERE Status = 'Not Started' and Type = 'Schedule Call' and ReminderDateTime = TODAY],'Error en tasks y no completada');
        
    }
    
}