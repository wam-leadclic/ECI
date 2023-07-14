/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         12/03/2018
* @group        Utils
* @description  Class that contains util methods for RecordType
* @Revision
**********************************************************************************/
public with sharing class ORG_RecordTypeUtils {

    //-- CONSTANTS
    /**
     * This field is only available when the org has PersonAccount activated
     */
    private static final String PERSON_ACCOUNT_FIELD = 'IsPersonType';

    //-- ATTRIBUTES
    /**
     * Map which stores all RecordTypes group by SObject name.
     */
    public final Map<String, List<RecordTypeWrapper>> rtsBySobject;

    //-- CONSTRUCTOR
    /**
     * Constructor has been set to private to enforce the use of singleton pattern.
     */
    private ORG_RecordTypeUtils() {
        //RecordType Map
        this.rtsBySobject = new Map<String, List<RecordTypeWrapper>>();

        //Template for the query used to get all RecordTypes
        final String queryTemplate = 'select [select_clause] from [from_clause]';

        //Check if PersonAccount exists in this org
        Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get('RecordType').getDescribe();
        Boolean isPersonAccount = sObjectDescribe.fields.getMap().containsKey(PERSON_ACCOUNT_FIELD.toLowerCase());

        //Build query
        String rtQuery = queryTemplate.replace(
                '[select_clause]',
                'Id, Name, DeveloperName, SobjectType' + (isPersonAccount ? (', ' + PERSON_ACCOUNT_FIELD) : '')
        ).replace(
                '[from_clause]', 'RecordType'
        );

        //We don't use RecordTypeInfo Class because we need more info
        for (RecordType rt : Database.query(rtQuery)) {
            //Group RecordTypes by SObject name
            List<RecordTypeWrapper> theList = this.rtsBySobject.get(rt.SobjectType);
            if (theList == null) {
                theList = new List<RecordTypeWrapper>();
                this.rtsBySobject.put(rt.SobjectType, theList);
            }
            theList.add(
                    new RecordTypeWrapper(
                            rt.Id, rt.Name, rt.DeveloperName,
                            rt.SobjectType, isPersonAccount ? Boolean.valueOf(rt.get(PERSON_ACCOUNT_FIELD)) : false
                    )
            );
        }
    }

    //-- SINGLETON PATTERN
    /**
     * Typical singleton pattern implementation.
     */
    private static ORG_RecordTypeUtils instance;
    public static ORG_RecordTypeUtils getInstance() {
        if (instance == null) instance = new ORG_RecordTypeUtils();
        return instance;
    }

    //-- PUBLIC METHODS
    /**
     * Returns the list of RecordTypes for the given sobjectType.
     *
     * @param sobjectType {String} Internal name (NOT the label) of the SObject from which
     *                             you want to retrieve RecordTypes.
     * @return {List<RecordType>} the list of RecordTypes for the given sobjectType.
     */
    public List<RecordTypeWrapper> getRt(final String sobjectType) {
        //Prevalidations
        if (String.isBlank(sobjectType)) return new List<RecordTypeWrapper>();

        return rtsBySobject.containsKey(sobjectType) ?
                rtsBySobject.get(sobjectType) :
                new List<RecordTypeWrapper>();
    }

    /**
     * Returns the Id of a RecordType.
     *
     * @param sobjectType {String} Internal name (NOT the label) of the SObject from which
     *                             you want to retrieve RecordTypes.
     * @param rtDeveloperName {String} the developerName of the RecordType.
     * @return {Id} the Id of the Recordtype.
     */
    public Id getRtId(final String sobjectType, final String rtDeveloperName) {
        final Id rtId = null;
        try {
            for (RecordTypeWrapper rt : this.getRt(sobjectType)) {
                if (rt.Name == rtDeveloperName) {
                    rtId = rt.Id;
                    break;
                }
            }
        } catch(Exception e) {
            rtId = null;
        }

        return rtId;
    }

    /**
     * Returns the Label of a RecordType.
     *
     * @param sobjectType {String} Internal name (NOT the label) of the SObject from which
     *                             you want to retrieve RecordTypes.
     * @param rtId {Id} the RecordType Id.
     * @return {String} the Label of the Recordtype.
     */
    public String getRtLabel(final String sobjectType, final Id rtId) {
        final String rtLabel = null;
        try {
            for (RecordTypeWrapper rt : this.getRt(sobjectType)) {
                if (rt.Id == rtId) {
                    rtLabel = rt.Label;
                    break;
                }
            }
        } catch(Exception e) {
            rtLabel = null;
        }

        return rtLabel;
    }

    /**
     * Returns the DeveloperName of a RecordType.
     *
     * @param sobjectType {String} Internal name (NOT the label) of the SObject from which
     *                             you want to retrieve RecordTypes.
     * @param rtId {Id} the RecordType Id.
     * @return {String} the DeveloperName of the Recordtype.
     */
    public String getRtDeveloperNameById(final String sobjectType, final Id rtId) {
        final String rtDevName = null;
        try {
            for (RecordTypeWrapper rt : this.getRt(sobjectType)) {
                if (rt.Id == rtId) {
                    rtDevName = rt.Name;
                    
                    break;
                }
            }
        } catch(Exception e) {
            rtDevName = null;
        }
        return rtDevName;
    }
    
    /**
     * Returns the DeveloperName of a RecordType.
     *
     * @param sobjectType {String} Internal name (NOT the label) of the SObject from which
     *                             you want to retrieve RecordTypes.
     * @param label {Id} the RecordType label.
     * @return {String} the DeveloperName of the Recordtype.
     */
    public String getRtDeveloperName(final String sobjectType, final string rtLabel) {
        final String rtDevName = null;
        try {
            for (RecordTypeWrapper rt : this.getRt(sobjectType)) {
                if (rt.Label == rtLabel) {
                    rtDevName = rt.Name;
                    break;
                }
            }
        } catch(Exception e) {
            rtDevName = null;
        }
        return rtDevName;
    }       
    /**
     * Class which represents a SFDC RecordType. We've created a separated wrapper
     * because there are some fields like 'IsPersonType' that there are not present
     * in all SFDC platforms.
     */
    public class RecordTypeWrapper {
        //-- ATTRIBUTES
        /**
         * This is the recordtype's eighteen-character identifier code.
         */
        public final String Id {get; set;}

        /**
         * Internal name of the recordtype. NOT the label.
         */
        public final String Name {get; set;}

        /**
         * Recordtype's label.
         */
        public final String Label {get; set;}

        /**
         * SObject where RecordType is related to.
         */
        public final String SobjectType {get; set;}

        /**
         * Whether the RecordType is related to a PersonAccount or not.
         */
        public final Boolean IsPersonAccount {get; set;}

        //-- CONSTRUCTOR
        /**
         * Creates a new RecordTypeWrapper which is a representation of a SFDC RecordType.
         *
         * @param Id {String} recordtype's eighteen-character identifier code.
         * @param Name {String} recordtype's label.
         * @param DeveloperName {String} internal name of the recordtype. NOT the label.
         * @param SobjectType {String} SObject where RecordType is related to.
         * @param IsPersonAccount {Boolean} Whether the RecordType is related to a PersonAccount or not.
         */
        public RecordTypeWrapper(final String Id, final String Name, final String DeveloperName,
                final String SobjectType, final Boolean IsPersonAccount) {
            this.Id = Id;
            this.Name = DeveloperName;
            this.Label = Name;
            this.SobjectType = SobjectType;
            this.IsPersonAccount = IsPersonAccount;
        }
    }
}