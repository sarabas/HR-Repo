public with sharing class LogOutboundEmailHandler {
     public static void createEmailMessage(Map<String,String> emailDetails) {
        
        System.debug('received map '+ emailDetails);
        String accID = emailDetails.get('AccountID');
        String contentDocID = emailDetails.get('ContentDocID');
        String mail = emailDetails.get('Mail');
        String contactID = emailDetails.get('ContactID');
        String subject = emailDetails.get('Subject');
        String ccAddress = emailDetails.get('CCAddress');
        String bccAddress = emailDetails.get('BccAddress');
        String body = emailDetails.get('Body');
        
        String sMessage = '';

        EmailMessage emailMessage = new EmailMessage();
        ContentDocumentLink cdLink = new ContentDocumentLink();
        EmailMessageRelation emr = new EmailMessageRelation();

        try{
            if(String.isNotBlank(accID)){
                emailMessage.RelatedToId = accID;
            }
            if(String.isNotBlank(subject)){
                emailMessage.Subject = subject;
            }
            if(String.isNotBlank(ccAddress)){
                emailMessage.CcAddress = ccAddress;
            }
            if(String.isNotBlank(bccAddress)){
                emailMessage.BccAddress = bccAddress;
            }
            if(String.isNotBlank(body)){
                emailMessage.HtmlBody = body;
            }

            if(String.isNotBlank(contactID)){
                String[] toIds = new List<String>{ contactID };
                emailMessage.toIds = toIds;
                emr.relationId = contactID;
            }
            if(String.isNotBlank(mail)){
                emailMessage.ToAddress = mail;
            }

            insert emailMessage;

            String emId = emailMessage.Id;

            if(String.isNotBlank(contentDocID)){
                cdLink.ContentDocumentId = contentDocID;
                cdLink.ShareType = 'V';
                if(String.isNotBlank(contactID)){
                    cdLink.LinkedEntityId = contactID;
                    insert cdLink;
                }
               
            }       
           
 
            emr.emailMessageId = emailMessage.id;
            emr.relationType = 'FromAddress';
            insert emr;

            EmailMessage insertedEmail = [
            SELECT status
            FROM EmailMessage
            WHERE Id = :emId];

            insertedEmail.status = '3';

            update insertedEmail;
        }
        catch (Exception ex) {
            sMessage =
              ex.getMessage() +
              '\n' +
              ex.getLineNumber() +
              '\n' +
              ex.getCause();
            System.debug('Error occured ' + sMessage);
          }
    }
}