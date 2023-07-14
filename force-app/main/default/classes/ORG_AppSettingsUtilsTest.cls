/**********************************************************************************
* @author       Giovanni Modica - giovanni.modica@salesforce.com
* @date         22/05/2018
* @group        Test
* @description  Test for the ORG_AppSettingsUtils class
* @Revision
**********************************************************************************/
@isTest
private class ORG_AppSettingsUtilsTest {
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
    private static void testGetSetting() {
        Test.startTest();
        
        String setting = ORG_AppSettingsUtils.getSetting('UNKNOWN'); // we use an UNKNOWN setting key so we don't depend on any specific setting. The test will perform equally
        
        Test.stopTest();
        
        System.assertEquals(null, setting);
    }
}