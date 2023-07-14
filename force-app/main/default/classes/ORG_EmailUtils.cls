/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         10/08/2018
* @group        Utils
* @description  Utility class for Emails
* @Revision
**********************************************************************************/
public class ORG_EmailUtils {

    //-- ATTRIBUTES
    /**
     * @description Map that stores all Org Wide Email Addresses
     */
    private Map<Id, OrgWideEmailAddress> orgWideEmailAddrMap;

    /**
     * @description Map that stores all active Email Templates
     */
    private Map<Id, EmailTemplate> emailTemplateMap;

    //-- CONSTRUCTORS
    /**
    * @description Enforce non-instantiability.
    */
    private ORG_EmailUtils() {
        this.orgWideEmailAddrMap = new Map<Id, OrgWideEmailAddress>([select Id, Address, DisplayName from OrgWideEmailAddress]);
        this.emailTemplateMap = new Map<Id, EmailTemplate>([select Id, Name, DeveloperName from EmailTemplate where IsActive = true]);
    }

    //-- SINGLETON PATTERN
    /**
     * @description Instance is only instantiate once per request (thread).
     */
    private static ORG_EmailUtils instance;
    private static ORG_EmailUtils getInstance() {
        if (instance == null) instance = new ORG_EmailUtils();
        return instance;
    }

    //-- UTILITY METHODS
    /**
     * @description Returns the Id of an org wide email address
     */
    public static Id getOrgWideEmailAddrrIdFromName(final String orgWideEmailAddress) {
        for (Id owaId : getInstance().orgWideEmailAddrMap.KeySet()) {
            if (getInstance().orgWideEmailAddrMap.get(owaId).DisplayName == orgWideEmailAddress) {
                return owaId;
            }   
        }
        return null;
    }

    /**
     * @description Returns the Id of an email template
     */
    public static Id getEmailTemplateFromName(final String emailTemplateDevName) {
        for (Id emId : getInstance().emailTemplateMap.KeySet()) {
            if (getInstance().emailTemplateMap.get(emId).DeveloperName == emailTemplateDevName) {
                return emId;
            }   
        }
        return null;
    }

    /**
     * @description 
     * @param templateId 
     * @param whoId
     * @param whatId
     * @param orgWideId
   * @return 
     */
    public static Messaging.SingleEmailMessage createEmailByTemplate(final Id templateId, final Id whoId, 
																	 final Id whatId, final Id orgWideId) {
        //Local vars
        final Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        //Email template specific fields
        email.setTemplateId(templateId);
        email.setTargetObjectId(whoId);
        if (!String.isEmpty(whatId)) email.setWhatId(whatId);

        //Save as activity
        email.setSaveAsActivity(true);

        //Generic fields
        if (!String.isEmpty(orgWideId)) {
      		email.setOrgWideEmailAddressId(orgWideId);
        }
        else {
            email.setReplyTo('sac@elcorteingles.es');
            email.setSenderDisplayName('SAC El Corte Inglés');
        }

        email.setBccSender(false);
        email.setUseSignature(false);

        //Return email
        return email;
    }

    /**
     * @description 
     * @param templateId 
     * @param toAddresses
     * @param whatId
     * @param orgWideId
     * @return 
     */
    public static Messaging.SingleEmailMessage createEmailByTemplate(final Id templateId, final List<String> toAddresses, 
																	 final Id whatId, final Id orgWideId, final List<Id> docsToAttach) {
        //Local vars
        final Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, null, whatId);

        //Optional/not needed
        email.setWhatId(whatId);
        email.setSubject(email.getSubject());
        email.setHtmlBody(email.getHtmlBody());
        email.setTargetObjectId(UserInfo.getUserId());
        email.setTreatTargetObjectAsRecipient(false);

        //Save as activity
        email.setSaveAsActivity(false);

        //To Addresses
        email.setToAddresses(toAddresses);

        //Generic fields
        if (!String.isEmpty(orgWideId)) {
            email.setOrgWideEmailAddressId(orgWideId);
        }
        else {
            email.setReplyTo('sac@elcorteingles.es');
            email.setSenderDisplayName('SAC El Corte Inglés');
        }

        email.setBccSender(false);
        email.setUseSignature(false);

        //Attach documents
        if (docsToAttach <> null && !docsToAttach.isEmpty())
            email.setFileAttachments(ContentDocumentAsAttachement(docsToAttach));

        //Return email
        return email;
    }

    /**
     * @description 
     * @param toAddresses 
     * @param subject
     * @param htmlBody
     * @return 
     */
    public static Messaging.SingleEmailMessage createHtmlEmail(final Set<String> toAddresses, final String subject, 
                                                               final String htmlBody) {
        //Local vars
        final Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        //Save as activity
        email.setSaveAsActivity(false);

        email.setOrgWideEmailAddressId(ORG_EmailUtils.getOrgWideEmailAddrrIdFromName('SAC El Corte Inglés'));

        //Generic HTML fields
        email.setToAddresses(new List<String>(toAddresses));
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(htmlBody.stripHtmlTags());

        email.setBccSender(false);
        email.setUseSignature(false);

        //Return email
        return email;
    }

    /**
     * @description 
     * @param toAddresses 
     * @param subject
     * @param htmlBody
     * @return 
     */
    public static EmailMessage createEmailMessage(final List<String> toAddresses, final String subject, 
                                                  final String htmlBody, final Id parentId) {
        //Local vars
        final EmailMessage emailMessage = new EmailMessage();
        emailMessage.ToAddress = string.join(toAddresses,',');
        emailMessage.Subject = subject;
        emailMessage.HtmlBody = htmlBody;
        emailMessage.ParentId = parentId;
        emailMessage.MessageDate = system.now();
        emailMessage.Status = '0';

        //Return emailMessage
        return emailMessage;
    }

    /**
     * @description 
     * @param contentDocumentIds
     * @return 
     */
    public static List<Messaging.EmailFileAttachment> ContentDocumentAsAttachement(Id[] contentDocumentIds) {
    
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
        List<ContentVersion> documents = new List<ContentVersion>{};
            
        documents.addAll([SELECT Id, Title, FileExtension, VersionData, isLatest, ContentDocumentId
                          FROM ContentVersion
                          WHERE isLatest = true
                          // MMV: COMENTADO PARA EVITAR DEPENDENCIAS
                          //AND private_file__c = false 
                          AND ContentDocumentId IN :contentDocumentIds]);

        for (ContentVersion document: documents) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(document.VersionData);
            attachment.setFileName(document.Title+'.'+document.FileExtension);
            attachments.add(attachment);
        }        

        for (Attachment document: [SELECT Id, Body,Name
                        FROM Attachment WHERE
                        Id IN :contentDocumentIds]) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(document.Body);
            attachment.setFileName(document.Name);
            attachments.add(attachment);
        }         

        return attachments;
    }

	//-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class ORG_EmailUtilsException extends Exception {}
}