/**********************************************************************************
* @name         	CESS_AccountTriggerHelper
* @version			1.0
* @creation date    30/04/2020
* @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Apex Class with the functionality of the helper for Account
* @group        	Helper
**********************************************************************************/
public class CESS_AccountTriggerHelper {

    /* The name of the class */
    private static String CLASS_NAME = CESS_AccountTriggerHelper.class.getName();
    /**********************************************************************************
    * @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
    * @creation date    30/04/2020
    * @description  	Validate documentation
    * @param header		the header for csv out
    * @param issuedAccount	Account
    *********************************************************************************/
	
    public static void checkIsNIFCIFNIEValid(final Account issuedAccount) {
        String myUser = UserInfo.getUserName();
        String usersNotValidateDoc = ORG_AppSettingsUtils.getSetting('CESS_notValidateDoc');
        Set<String> setUsers = new Set<String>();
        if(usersNotValidateDoc!='' && usersNotValidateDoc!=null){
            List<String> lstUsers = usersNotValidateDoc.split(';');
        	setUsers = new Set<String>(lstUsers);
        }
        Boolean validar = issuedAccount.Bypass_ValidacionConsultaCESS__c;
        if(!validar && String.isEmpty(issuedAccount.identifier_cuc__pc) && (setUsers.size()==0 || (setUsers.size()>0 &&!setUsers.contains(myUser)))){
            if (!String.isEmpty(issuedAccount.personal_document__pc) && 
                    !String.isEmpty(issuedAccount.document_type__pc ) &&
                    issuedAccount.document_type__pc  == 'NIF' &&
                    !ORG_helperObjects.isNifValid(issuedAccount.personal_document__pc ) &&
                    !ORG_helperObjects.isNCValid(issuedAccount.personal_document__pc ) ) {
                    issuedAccount.addError('Número de NIF incorrecto.');
            }
            else if (!String.isEmpty(issuedAccount.personal_document__pc) && 
                       !String.isEmpty(issuedAccount.document_type__pc ) &&
                       issuedAccount.document_type__pc == 'CIF' &&
                       !ORG_helperObjects.isCifValid(issuedAccount.personal_document__pc)) {
                issuedAccount.addError('Número de CIF incorrecto.');
            }
            else if (!String.isEmpty(issuedAccount.personal_document__pc) && 
                       !String.isEmpty(issuedAccount.document_type__pc ) &&
                       issuedAccount.document_type__pc == 'NIE' &&
                       !ORG_helperObjects.isNieValid(issuedAccount.personal_document__pc)) {
                issuedAccount.addError('Número de NIE incorrecto.');
            }
        } else if(validar) {
            issuedAccount.Bypass_ValidacionConsultaCESS__c = false;
        }      
    }
	
	
	
}