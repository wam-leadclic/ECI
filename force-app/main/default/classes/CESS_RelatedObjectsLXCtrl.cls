/**********************************************************************************
* @author       Francisco Pérez - franciscojose.perez@salesforce.com
* @date         23/05/2018
* @group        Lead
* @description  Controller class for CESS_RelatedObjects component.
* @Revision
**********************************************************************************/

public with sharing class CESS_RelatedObjectsLXCtrl {

    //-- PUBLIC METHODS
    /**
     * @description Retrieves the Lead information about acccount.
            The search order is 
                1.-Id Cess
                2.-Id Aneto
                3.- Nif
                4.- tlf + email
     * @param Document Number, Id cess, Id aneto, email, Mobile Phone and Phone.
     * @return The account Id. 
     */

  @AuraEnabled
    public static String getAccountId (String nif, String cessId, String anetoId, String email, String mphone, String phone) {
        return ORG_LeadLogic.getAccountId(nif, cessId, anetoId, email, mphone, phone);
    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class CESS_RelatedObjectsLXCtrlException extends Exception {}

}