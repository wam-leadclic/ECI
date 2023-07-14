/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         12/03/2018
* @group        Utils
* @description  Class to deal with 'ORG_ApplicationSettings' custom metadata type
* @Revision
**********************************************************************************/
public with sharing class ORG_AppSettingsUtils {

    //-- CONSTANTS

    //-- ATTRIBUTES
    /**
     * @description Map that stores all kind of configuration settings.
     */
    private Map<String, String> settingsMap;
    private Map<String, String> settingsMapInt;

    //-- CONSTRUCTOR
    /**
     * @description It must be instantiated using singleton pattern.
     */
    private ORG_AppSettingsUtils() {
        this.settingsMap = new Map<String, String>();
		this.settingsMapInt = new Map<String, String>();
        try {
            //Iterate over all SAC_ApplicationSettings__mdt
            for (ORG_ApplicationSettings__mdt appSetting : [SELECT MasterLabel, Value__c,Value_integracion__c
                                                            FROM ORG_ApplicationSettings__mdt
                                                            LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows()]) {
                this.settingsMap.put(appSetting.MasterLabel, appSetting.Value__c);
				this.settingsMapInt.put(appSetting.MasterLabel, appSetting.value_integracion__c);

            }
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            throw new ORG_AppSettingsUtilsException(e);
        }
    }

    //-- SINGLETON PATTERN
    /**
     * @description Instance is only instantiate once per request (thread).
     */
    private static ORG_AppSettingsUtils instance;

    private static ORG_AppSettingsUtils getInstance() {
        if (instance == null) instance = new ORG_AppSettingsUtils();
        return instance;
    }

    //-- PUBLIC STATIC METHODS
    /**
     * @description Returns the value of a setting.
     */
    public static String getSetting(final String key) {
        return getInstance().settingsMap.get(key);
    }
	public static String getSettingInt(final String key) {
        return getInstance().settingsMapInt.get(key);
    }
    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class ORG_AppSettingsUtilsException extends Exception {}

}