/**********************************************************************************
* @author       Franciso José Pérez - franciscojose.pere@salesforce.com
* @date         5/07/2019
* @group        Test
* @description  Test class for ORG_LeadLogicTest
* @Revision     AUTHOR            DATE          Reason
                MMV - LCS         30/03/2022    Se comentan todas las clases de test que no se usan
                MMV - LCS         22/03/2022    Modificación para la refactorización y cambio del modelo del dato  
**********************************************************************************/
@isTest
public class ORG_LeadLogicTest {

    @testSetup
    private static void setup() {

        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();

        Account pa = orgDataUtils.newPersonAccount('1');
        insert pa;

        Opportunity opp = new Opportunity(
            AccountId = pa.Id,
            Name = 'Opportunity test',
            CloseDate = Date.today(),
            StageName = 'Propuesta'
        );
        insert opp;

        Task ts = new Task(
            WhatId = opp.Id,
            Subject = 'task test',
            CESS_Fecha_Planificada__c = Date.today()
        );
        insert ts;



    }

    /* Se comentan estos métodos porque ya no se usan
    @isTest
    public static void testSentCTI_crlOk1(){

        List <Lead> lstLd = new List <Lead>();        
        lstLd.add(new Lead (
            LastName='TestCTI', 
            source_manualrecord__c='Otros',
            send_cti__c=false,
            document_type__c='PASSPORT',
            document_number__c='11122223D',
            MobilePhone='677777788',
            businesslines_contracted__c = 'Hogar' )
        );        
        
        CESS_ConsultaRapidaResponseDto.line_signed ls = new CESS_ConsultaRapidaResponseDto.line_signed();
        ls.insurance_description = 'Descripción del seguro';

        CESS_ConsultaRapidaResponseDto crData = new CESS_ConsultaRapidaResponseDto();
        crData.return_code = 'OK';
        crData.tasks = 'S';
        crData.age = '33';
        crData.gender ='V';
        crData.cess_identifier ='123223';
        crData.aneto_identifier ='12333323';
        crData.line_forbidden = new List <String>{'Vida', 'Motos Autos'};        
        crData.line_signed = new List<CESS_ConsultaRapidaResponseDto.line_signed>{ls};           

        CESS_ConsultaCESSDto.ConsultaRapidaResponse leadOperationResponse= new CESS_ConsultaCESSDto.ConsultaRapidaResponse();
        leadOperationResponse.crlcustomer_rating = new List <CESS_ConsultaRapidaResponseDto>{crData};

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 
            'OK',
            JSON.serialize(leadOperationResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);   

        Test.startTest();
            insert (lstLd);
        Test.stopTest();

        List <Lead> lstLdOutput = [SELECT Id, lead_number__c, crl_ok__c, isDeleted, Status, result__c, CreatedDate, Email, 
                                   MobilePhone, LastName, cti_error__c, send_cti__c, sent_cti__c 
                                   FROM Lead 
                                   WHERE LastName IN ('TestCTI')];

        Map<String,Lead> leadMap = new Map<String,Lead>();
        for (Lead ld: lstLdOutput){
            leadMap.put(ld.LastName, ld);
        }
        
        //System.assertEquals(true, leadMap.get('TestCTI').crl_ok__c, 'Envío CRL correcto');
       
    }

    @isTest
    public static void testSentCTI_crlOkMultiple(){

        List <Lead> lstLd = new List <Lead>();        
        lstLd.add(new Lead (
            LastName='TestCTI', 
            source_manualrecord__c='Otros',
            send_cti__c=false,
            document_type__c='PASSPORT',
            document_number__c='11122223D',
            MobilePhone='677777788',
            businesslines_contracted__c = 'Hogar' )
        );        
        
        CESS_ConsultaRapidaResponseDto.line_signed ls = new CESS_ConsultaRapidaResponseDto.line_signed();
        ls.insurance_description = 'Descripción del seguro';

        CESS_ConsultaRapidaResponseDto crData = new CESS_ConsultaRapidaResponseDto();
        crData.return_code = 'OK';
        crData.tasks = 'S';
        crData.age = '33';
        crData.gender ='V';
        crData.cess_identifier ='123223';
        crData.aneto_identifier ='12333323';
        crData.line_forbidden = new List <String>{'Vida', 'Motos Autos'};        
        crData.line_signed = new List<CESS_ConsultaRapidaResponseDto.line_signed>{ls};

        CESS_ConsultaRapidaResponseDto crData2 = new CESS_ConsultaRapidaResponseDto();
        crData2.return_code = 'OK';
        crData2.tasks = 'S';
        crData2.age = '33';
        crData2.gender ='';
        crData2.cess_identifier ='123223';
        crData2.aneto_identifier ='12333323';
        crData2.line_forbidden = new List <String>{'Vida', 'Motos Autos'};        
        crData2.line_signed = new List<CESS_ConsultaRapidaResponseDto.line_signed>{ls};  

        CESS_ConsultaCESSDto.ConsultaRapidaResponse leadOperationResponse = new CESS_ConsultaCESSDto.ConsultaRapidaResponse();
        leadOperationResponse.crlcustomer_rating = new List <CESS_ConsultaRapidaResponseDto>{crData,crData2};

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 
            'OK',
            JSON.serialize(leadOperationResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);   

        Test.startTest();
            insert (lstLd);
        Test.stopTest();

        List <Lead> lstLdOutput = [SELECT Id, lead_number__c, crl_ok__c, isDeleted, Status, result__c, CreatedDate, Email, 
                                   MobilePhone, LastName, cti_error__c, send_cti__c, sent_cti__c 
                                   FROM Lead 
                                   WHERE LastName IN ('TestCTI')];

        Map<String,Lead> leadMap = new Map<String,Lead>();
        for (Lead ld: lstLdOutput){
            leadMap.put(ld.LastName, ld);
        }
        
       // System.assertEquals(true, leadMap.get('TestCTI').crl_ok__c, 'Envío CRL correcto');
       
    }

    @isTest
    public static void testSentCTI_crlOkMultiple2(){

        List <Lead> lstLd = new List <Lead>();        
        lstLd.add(new Lead (
            LastName='TestCTI', 
            source_manualrecord__c='Otros',
            send_cti__c=false,
            document_type__c='PASSPORT',
            document_number__c='11122223D',
            MobilePhone='677777788',
            businesslines_contracted__c = 'Hogar' )
        );        
        
        CESS_ConsultaRapidaResponseDto.line_signed ls = new CESS_ConsultaRapidaResponseDto.line_signed();
        ls.insurance_description = 'Descripción del seguro';

        CESS_ConsultaRapidaResponseDto crData = new CESS_ConsultaRapidaResponseDto();
        crData.return_code = 'OK';
        crData.tasks = 'S';
        crData.age = '33';
        crData.gender ='V';
        crData.cess_identifier ='123223';
        crData.aneto_identifier ='12333323';
        crData.line_forbidden = new List <String>{'Vida', 'Motos Autos'};        
        crData.line_signed = new List<CESS_ConsultaRapidaResponseDto.line_signed>{ls};
        crData.message = 'Error';

        CESS_ConsultaRapidaResponseDto crData2 = new CESS_ConsultaRapidaResponseDto();
        crData2.return_code = 'OK';
        crData2.tasks = 'S';
        crData2.age = '33';
        crData2.gender ='';
        crData2.cess_identifier ='123223';
        crData2.aneto_identifier ='12333323';
        crData2.line_forbidden = new List <String>{'Vida', 'Motos Autos'};        
        crData2.line_signed = new List<CESS_ConsultaRapidaResponseDto.line_signed>{ls};  

        CESS_ConsultaCESSDto.ConsultaRapidaResponse leadOperationResponse = new CESS_ConsultaCESSDto.ConsultaRapidaResponse();
        leadOperationResponse.crlcustomer_rating = new List <CESS_ConsultaRapidaResponseDto>{crData,crData2};

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 
            'OK',
            JSON.serialize(leadOperationResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);   

        Test.startTest();
            insert (lstLd);
        Test.stopTest();

        List <Lead> lstLdOutput = [SELECT Id, lead_number__c, crl_ok__c, isDeleted, Status, result__c, CreatedDate, Email, 
                                   MobilePhone, LastName, cti_error__c, send_cti__c, sent_cti__c 
                                   FROM Lead 
                                   WHERE LastName IN ('TestCTI')];

        Map<String,Lead> leadMap = new Map<String,Lead>();
        for (Lead ld: lstLdOutput){
            leadMap.put(ld.LastName, ld);
        }
        
        //System.assertEquals(true, leadMap.get('TestCTI').crl_ok__c, 'Envío CRL correcto');
       
    }

    @isTest
    public static void testSentCTI_crlKO1(){

        List <Lead> lstLd = new List <Lead>();        
        lstLd.add(new Lead (
            LastName='TestCTI', 
            source_manualrecord__c='Otros',
            send_cti__c=false,
            document_type__c='PASSPORT',
            document_number__c='11122223D',
            MobilePhone='677777788',
            businesslines_contracted__c = 'Hogar' )
        );        

        CESS_ConsultaCESSDto.ConsultaRapidaResponse leadOperationResponse = null;

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 
            'OK',
            JSON.serialize(leadOperationResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);   

        Test.startTest();
            insert (lstLd);
        Test.stopTest();

        List <Lead> lstLdOutput = [SELECT Id, lead_number__c, crl_ok__c, isDeleted, Status, result__c, CreatedDate, Email, 
                                   MobilePhone, LastName, cti_error__c, send_cti__c, sent_cti__c 
                                   FROM Lead 
                                   WHERE LastName IN ('TestCTI')];

        Map<String,Lead> leadMap = new Map<String,Lead>();
        for (Lead ld: lstLdOutput){
            leadMap.put(ld.LastName, ld);
        }
        
        //System.assertEquals(true, leadMap.get('TestCTI').crl_ok__c, 'Envío CRL correcto');
       
    }

    @isTest
    public static void testSentCTI_crlMultipleOk1(){

        List <Lead> lstLd = new List <Lead>(); 
        for(Integer i = 0; i < 50; i++){
            lstLd.add(new Lead (
                LastName='TestCTI', 
                source_manualrecord__c='Otros',
                send_cti__c=false,            
                MobilePhone='6777777' + i )
            );   
        }             
        
        CESS_ConsultaRapidaResponseDto.line_signed ls = new CESS_ConsultaRapidaResponseDto.line_signed();
        ls.insurance_description = 'Descripción del seguro';

        CESS_ConsultaRapidaResponseDto crData = new CESS_ConsultaRapidaResponseDto();
        crData.return_code = 'OK';
        crData.tasks = 'N';
        crData.age = '33';
        crData.gender ='M';
        crData.cess_identifier ='123223';
        crData.aneto_identifier ='12333323';
        crData.line_forbidden = new List <String>{'Vida', 'Motos Autos'};        
        crData.line_signed = new List<CESS_ConsultaRapidaResponseDto.line_signed>{ls};           

        CESS_ConsultaCESSDto.ConsultaRapidaResponse leadOperationResponse= new CESS_ConsultaCESSDto.ConsultaRapidaResponse();
        leadOperationResponse.crlcustomer_rating = new List <CESS_ConsultaRapidaResponseDto>{crData};

        ORG_TestDataUtils.SingleRequestMock fakeResponse = new ORG_TestDataUtils.SingleRequestMock(
            200, 'OK',
            JSON.serialize(leadOperationResponse),
            null
        );
        Test.setMock(HttpCalloutMock.class, fakeResponse);   

        Test.startTest();
            insert (lstLd);
        Test.stopTest();

        List <Lead> lstLdOutput = [SELECT Id, lead_number__c, crl_ok__c, isDeleted, Status, result__c, CreatedDate, Email, 
                                   MobilePhone, LastName, cti_error__c, send_cti__c, sent_cti__c 
                                   FROM Lead 
                                   WHERE LastName IN ('TestCTI')];

        Map<String,Lead> leadMap = new Map<String,Lead>();
        for (Lead ld: lstLdOutput){
            leadMap.put(ld.LastName, ld);
        }
        
        //System.assertEquals(true, leadMap.get('TestCTI').crl_ok__c, 'Envío CRL correcto');
       
    }
    */
    
    @isTest
    public static void testGetErrorCtiResponse(){        

        Test.startTest();

            ORG_LeadLogic.getErrorCtiResponse('');
            
        Test.stopTest();
    }

    @isTest
    public static void testGetCESSDocumentTypeValue(){        

        Test.startTest();

            ORG_LeadLogic.getCESSDocumentTypeValue('NIF');
            ORG_LeadLogic.getCESSDocumentTypeValue('NIE');
            ORG_LeadLogic.getCESSDocumentTypeValue('PASSPORT');
            ORG_LeadLogic.getCESSDocumentTypeValue('Pasaporte');
            ORG_LeadLogic.getCESSDocumentTypeValue('CIF');
            ORG_LeadLogic.getCESSDocumentTypeValue('otros');
            
        Test.stopTest();
    }

    @isTest
    public static void testGetDocumentTypeValue(){        

        Test.startTest();

            ORG_LeadLogic.getDocumentTypeValue('A001');
            ORG_LeadLogic.getDocumentTypeValue('C003');
            ORG_LeadLogic.getDocumentTypeValue('F006');
            ORG_LeadLogic.getDocumentTypeValue('E005');
            ORG_LeadLogic.getDocumentTypeValue('CIF');
            ORG_LeadLogic.getDocumentTypeValue('Pasaporte');
            
        Test.stopTest();
    }

    @isTest
    public static void testGetAccountId(){        

        Test.startTest();

            ORG_LeadLogic.getAccountId('nif', 'cessId', 'anetoId', 'email','123','456');
            ORG_LeadLogic.getAccountId('nif', null, 'anetoId', 'email','123','456');
            ORG_LeadLogic.getAccountId('nif', null, null, 'email','123','456');
            ORG_LeadLogic.getAccountId(null, null, null, 'email','123','456');
            ORG_LeadLogic.getAccountId(null, null, null, null,'123','456');
            ORG_LeadLogic.getAccountId(null, null, null, null,null,'456');
            
        Test.stopTest();
    }

    @isTest
    public static void testGetDGRecords(){        

        Test.startTest();

            ORG_LeadLogic.getDGRecords('cessId', 'anetoId');
            
        Test.stopTest();
    }

    @isTest
    public static void testGetCESSPolicyRecords(){        

        Test.startTest();

            ORG_LeadLogic.getCESSPolicyRecords('cessId', 'anetoId');
            
        Test.stopTest();
    }

    @isTest
    public static void testReplanificaLlamadaCTI(){ 
        
        Task ts = [SELECT Id, WhatId, CESS_Fecha_Planificada__c, Account.PersonMobilePhone, 
                   Account.Phone, owner_ctiuser__c
                   FROM Task LIMIT 1];
        
        Test.startTest();

            ORG_LeadLogic.replanificaLlamadaCTI(ts);
            
        Test.stopTest();
    }


    @isTest
    public static void testSendEmail(){

        Lead ld = new Lead (
            LastName='TestCTI1', 
            source_manualrecord__c='Otros', 
            Email = 'test1@email.com',
            MobilePhone='123',
            sent_cti__c=true,
            identifier_cess__c='12345',
            campaign__c='t2o',
            source_type__c = 'Adwords', 
            source_cess__c = 'lead_autos' 
        );
        insert (ld);

        Test.startTest();

            ORG_LeadLogic.sendEmail(ld.id, 'fromAddress@test.com', 'CTI_Salud');
            ORG_LeadLogic.sendEmail(ld.id, null, 'CTI_Salud');
            
        Test.stopTest();
    }



}