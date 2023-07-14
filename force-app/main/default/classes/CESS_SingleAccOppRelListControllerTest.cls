/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         08/07/2019
* @group        Test
* @description  Test class to test the CESS_singleAccOppRelList Lightning Component
* @Revision
**********************************************************************************/
@isTest
public class CESS_SingleAccOppRelListControllerTest {

    @testSetup
    private static void setup() {
        
        ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
        
        Account acc = new Account(LastName='ApeTestTask', PersonMobilePhone = '677777777', FirstName='ApeTestTask',document_type__pc='NIF',personal_document__pc='66573439P');
        insert (acc);

        Opportunity theOpp = new Opportunity (Name='TheOpp',AccountId=acc.Id, StageName='Propuesta', CloseDate=System.today().addMonths(1));
        insert (theOpp);
    }

    @IsTest static void testControllerMethods() {

        Id theId = (Id)[SELECT Id FROM Opportunity LIMIT 1].Id;

        Test.startTest();
            CESS_SingleAccOppRelListController.initData('{\"fields\":\"Id\",' +
                                                         '\"numberOfRecords\":1,' +
                                                         '\"recordId\":\"'+ theId + '\",' +
                                                         '\"relatedFieldApiName\":\"AccountId\",' +
                                                         '\"sobjectApiName\":\"Opportunity\",' +
                                                         '\"sortedBy\":\"CreatedDate\",' +
                                                         '\"sortedDirection\":\"DESC\"' +
                                                         '}');
            CESS_SingleAccOppRelListController.deleteRecord([SELECT Id FROM Opportunity LIMIT 1].Id);
            CESS_SingleAccOppRelListController.getIconName('OrderItem');
        Test.stopTest();

    }

}