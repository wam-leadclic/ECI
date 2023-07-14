/**********************************************************************************
* @name         	CESS_helperEmail
* @version			1.0
* @creation date    05/11/2020
* @author       	Maria Dolores Sánchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Apex Class with the functionality of the helper for Email
* @group        	Helper
**********************************************************************************/
public class CESS_helperEmail {

    /* The name of the class */
    private static String CLASS_NAME = CESS_helperEmail.class.getName();
    /*VARIABLES*/ 
    public static final String EMAIL_ADDR_SAC_ECI_NOREPLY = 'No Reply - SAC El Corte Inglés';
    
    
    public static void createAndSendEmail(String emailAdresses, String emailCCAdresses, String subject, String body, String nameCsv, CESS_csvObject csv) {
        String METHOD_NAME = 'createAndSendEmail';
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_INIT));
    	//mail addresses
        List<String> addressesEmail = emailAdresses.split(CESS_Constantes.CESS_SEP);
        List<String> addressesCCEmail = emailCCAdresses.split(CESS_Constantes.CESS_SEP);
        Map<String,String> attachNameContentMap = new Map<String,String>();
        if (nameCsv != null && csv != null) {
            attachNameContentMap.put(nameCsv, csv.toString());
        }
        sendEmail(addressesEmail, addressesCCEmail, subject, body, attachNameContentMap);    
    	System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_END));
    }
    
    /**********************************************************************************
    * @author       	Maria Dolores Sánchez Meroño
    * @creation date    05/11/2020
    * @description  	send an email
    * @param idRecord	
    **********************************************************************************/
    public static void sendEmail(List<String> addresses,List<String> ccAddresses,String subject,String textBody, Map<String,String> attachNameContentMap){
        String METHOD_NAME = 'sendEmail';
       System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_INIT));
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.settoAddresses(addresses);
        if(ccAddresses!=null){
           	mail.setccAddresses(ccAddresses);            
        }
        if(subject!=null){
            mail.setSubject(subject);
        }
        if(textBody!=null){
            mail.setPlainTextBody(textBody);
        }
        if(attachNameContentMap!=null){
            List<Attachment> allAttachment = new List<Attachment>();
            List<Messaging.Emailfileattachment> lstAttachments = new List<Messaging.Emailfileattachment>();
            for(String attName: attachNameContentMap.keySet()){
                Messaging.Emailfileattachment attachContent = new Messaging.Emailfileattachment();
                String attBody = attachNameContentMap.get(attName);
                attachContent.setFileName(attName);
                attachContent.setBody(Blob.valueOf(attBody));
                lstAttachments.add(attachContent);
            }
            if(lstAttachments.size() > 0){
            	mail.setFileAttachments(lstAttachments);
            }
        }
      //  mail.setOrgWideEmailAddressId(ORG_EmailUtils.getOrgWideEmailAddrrIdFromName(EMAIL_ADDR_SAC_ECI_NOREPLY));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        
 		System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME,ORG_Constantes.MSG_END));		
    }
   
}