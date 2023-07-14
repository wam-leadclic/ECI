/**
@description
<pre>
Clase de test para cubrir la clas CESS_BulkifiedCTIIntegrationQueueable</br>

FECHA       AUTOR       DESCRIPCION<br/>
18/05/2022  LCS - MMV   Cobertura
</pre>
@author Leadclic Solutions
@date 18/05/2022
*/

@IsTest
public class CESS_BulkifiedCTIIntegrationQueue_Test {

    @testSetup
    private static void setup() {

        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();

        //Test data
        List<Lead> lLeads = new List<Lead>();        
        lLeads.add(orgDataUtils.newLead('1'));
        
        Lead l2 = orgDataUtils.newLead('2');
        l2.risk_postalcode__c = '22111';
        l2.gender__c = 'MALE';
        l2.age__c = 22;
        l2.source_manualrecord__c = 'Referencia';
        l2.schedulecontact_datetime__c = System.today().addDays(2);
        lLeads.add(l2);
        
        insert lLeads;

    }

    @IsTest static void testQueueable() {
        
        List<Lead> leads = [SELECT Id FROM Lead];
        
        List<CESS_Integration_Event__e> events = new List<CESS_Integration_Event__e>();
        
        CESS_Integration_Event__e ev1 = new CESS_Integration_Event__e();
        ev1.Object_Id__c = leads[0].Id;
        events.add(ev1);
        
        CESS_Integration_Event__e ev2 = new CESS_Integration_Event__e();
        ev2.Object_Id__c = leads[1].Id;
        events.add(ev2);
        
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        
        //Test Execution
        Test.startTest();
		System.enqueueJob(new CESS_BulkifiedCTIIntegrationQueueable(events));
        Test.stopTest();
    }

    @isTest
    static void testTriggerEventsCESS() {

        List<Lead> leads = [SELECT Id FROM Lead];
        
        List<CESS_Integration_Event__e> events = new List<CESS_Integration_Event__e>();
        
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());

        Test.startTest();
            CESS_Integration_Event__e ev1 = new CESS_Integration_Event__e();
            ev1.Object_Id__c = leads[0].Id;
            events.add(ev1);
        Test.stopTest();

    }

    
}