public class SendSingleVFEmail {
  @AuraEnabled
  public static String sendSingleEmailLWC(Map<String, String> params) {
    System.debug('Received ' + params);

    Map<String, String> emailDetails = new Map<String, String>();
    String acc = params.get('acc');
    String contactName = params.get('contactName');
    String mail = params.get('contEmail');
    String addTo = params.get('addTo');
    String ccEmail = params.get('ccEmail');
    String subject = params.get('subject');
    String body = params.get('body');
    String contactID;
    String bccAddress = '';
    String stripHtmlBody = body.stripHtmlTags();

    List<String> mailList = new List<String>();
    if (mail != null) {
      mailList.add(mail);
    }
    if (!(String.isBlank(addTo))) {
      mailList.add(addTo);
    }

    String sMessage = '';
    String msg = 'Sent sucessfully'; 

    try {
      Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
      //Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();

      PageReference pageref = new PageReference(
        '/apex/Manual_Template_Generator?id=' + acc
      );

      Blob b;
      ContentVersion cv = new ContentVersion();
      if (Test.isRunningTest()) {
        b = blob.valueOf('Unit.Test');
      } else {
        b = pageref.getContent();
      }

      cv.VersionData = b;
      cv.Title = 'Client Invoice';
      cv.PathOnClient = 'Invoice.pdf';
      cv.ContentLocation = 'S';
      cv.Description = 'Customer invoice';
      cv.IsMajorVersion = true;
      insert cv;

      Id contentDocID = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
      ]
      .ContentDocumentId;

      //attach.setFileName('Invoice.pdf');
      //attach.setBody(b);
      semail.setEntityAttachments(new List<Id>{ cv.Id });
      semail.setSubject(subject);
      //semail.setSubject('Account Details');
      if (mailList.size() > 0) {
        semail.setToAddresses(mailList);
      }

      if (!(String.isBlank(ccEmail))) {
        semail.setCcAddresses(new List<String>{ ccEmail });
      }

      semail.setPlainTextBody(stripHtmlBody);
      //semail.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attach });
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ semail });

      System.debug('Email Sent Successfully!');
      System.debug('Contact name '+ contactName);

      //=====================================================================
      //Log email message
      List<Contact> contactDetails = [
        SELECT Id
        FROM Contact
        WHERE Name = :contactName
      ];
      if(contactDetails.size()>0){
      contactID = contactDetails[0].Id;

      emailDetails.put('AccountID', acc);
      emailDetails.put('ContentDocID', contentDocID);
      emailDetails.put('Mail', mail);
      emailDetails.put('ContactID', contactID);
      emailDetails.put('Subject', subject);
      emailDetails.put('CcAddress', ccEmail);
      emailDetails.put('BccAddress', bccAddress);
      emailDetails.put('Body', body);

      System.debug('Map ' + emailDetails.size());
      if(!emailDetails.isEmpty()){
       LogOutboundEmailHandler.createEmailMessage(emailDetails);
       System.debug('Called logOutboundEmailHandler ');
      }else {
        System.debug('Email details map is empty. Nothing to log!');
      }
    }
    } catch (Exception ex) {
      sMessage =
        ex.getMessage() +
        '\n' +
        ex.getLineNumber() +
        '\n' +
        ex.getCause();
      System.debug('Error found is: ' + sMessage);
    }
    return msg;
  }
}