/**********************************************************************************
* @author       Giovanni Modica - giovanni.modica@salesforce.com
* @date         22/05/2018
* @group        Test
* @description  Test for the ORG_RecordTypeUtilsTest class
* @Revision
**********************************************************************************/
@isTest
private class ORG_RecordTypeUtilsTest {
	/**
     * @description Test setup
     */    
	@testSetup
    private static void setup() {
        
    }
    
    /**
     * @description
     */    
	@isTest
    private static void testObjectWithoutRecordTypes() {
        Test.startTest();
              
        List<ORG_RecordTypeUtils.RecordTypeWrapper> recordTypes = ORG_RecordTypeUtils.getInstance().getRt('UNKNOWN');
        
        Test.stopTest();
        
        System.assertEquals(0, recordTypes.size());
    }
    
    /**
     * @description
     * This test assumes that the Account object has some RecordTypes created, which will be the case if person accounts are activated
     */    
	@isTest
    private static void testObjectWithRecordTypes() {
        Test.startTest();        
        
        List<ORG_RecordTypeUtils.RecordTypeWrapper> recordTypes = ORG_RecordTypeUtils.getInstance().getRt(SObjectType.Account.name);
        
        Test.stopTest();
        
        System.assert(recordTypes.size() > 0);
    }
    
    /**
     * @description
     * This test assumes that the Account object has some RecordTypes created, which will be the case if person accounts are activated
     */    
	@isTest
    private static void testGetRecordTypeAttributes() {
        ORG_RecordTypeUtils rtUtils = ORG_RecordTypeUtils.getInstance();
        List<ORG_RecordTypeUtils.RecordTypeWrapper> recordTypes = rtUtils.getRt(SObjectType.Account.name);
        System.assert(recordTypes.size() > 0);
        
        ORG_RecordTypeUtils.RecordTypeWrapper rt = recordTypes[0];
        
        Test.startTest();       
        
        String label = rtUtils.getRtLabel(SObjectType.Account.name, rt.Id); 
        String developerName = rtUtils.getRtDeveloperNameById(SObjectType.Account.name, rt.Id);
        String developerNameLabel = rtUtils.getRtDeveloperName(SObjectType.Account.name, rt.Label);
        String id = rtUtils.getRtId(SObjectType.Account.name, rt.Name);
        
        Test.stopTest();
        
		System.assertEquals(rt.Label, label);
        System.assertEquals(rt.Name, developerName);
        System.assertEquals(rt.Id, id);
    }
}