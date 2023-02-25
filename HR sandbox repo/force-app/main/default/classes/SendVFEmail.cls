public class SendVFEmail {
  @future(callout=true)
  public static void sendBatchInvoices(List<String> accList) {
    Map<String, String> emailDetails = new Map<String, String>();
    String subject = 'Account Details';
    String contactName;
    String ccAddress = '';
    String bccAddress = '';
    String body = 'Please find the attached Invoice';
    Datetime todaysDate = Datetime.now();
    String month = todaysDate.format('MMMM');
    String dueDate = Date.today().format();

    System.debug('Got the accounts  list' + accList);
    String sMessage = '';

    for (String acc : accList) {
      try {
        AVAB__SO_Document__c rec = [
          SELECT Name, AVAB__Contact__c, AVAB__Account__c
          FROM AVAB__SO_Document__c
          WHERE id = :acc
        ];
        String invoiceNumber = rec.Name;
        String accID = rec.AVAB__Account__c;
        Contact c = [
          SELECT Name, Email
          FROM Contact
          WHERE id = :rec.AVAB__Contact__c
        ];
        String contEmail = c.Email;
        String contactID = c.Id;
        contactName = c.Name;
        System.debug('Current Invoice ' + acc);

        // String messageBody =
        //   '<html><body> Dear ' +
        //   contactName +
        //   ',<br/><br/> Please find the attached invoice for the month of ' +
        //   month +
        //   '.<br/><br/> Thank you for your business! <br/><br/> Mom Relaunch</body>  </html>';

        String messageBody =  '<html><body> Dear ' +  contactName + ',<br/><br/> We hope you are well! <br/><br/> Please see invoice ' + invoiceNumber + ' attached. ' + '<br/><br/> The invoice is due on ' + dueDate + '. <br/><br/>Please don’t hesitate to get in touch if you have any questions, or would like to clarify anything. <br/><br/> <br/> Best regards, <br/> Mom Relaunch Accounting</body>  </html>';

        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        // Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        // Replace Visualforce(AccountDetails) page with your visualforce page

        PageReference pageref = new PageReference(
          '/apex/ManualTemplateGeneratorXX?id=' + acc
        );

        Blob b;
        ContentVersion cv = new ContentVersion();
        if (Test.isRunningTest()) {
          b = blob.valueOf('Unit.Test');
        } else {
          b = pageref.getContentAsPDF();
        }
        //attach.setFileName('Invoice.pdf');
        //attach.setBody(b);
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

        semail.setEntityAttachments(new List<Id>{ cv.Id });
        semail.setSubject(subject);
        semail.setToAddresses(new List<String>{ contEmail });
        semail.setHtmlBody(messageBody);
        //semail.setPlainTextBody(body);

        //semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ semail });

        emailDetails.put('AccountID', accID);
        emailDetails.put('ContentDocID', contentDocID);
        emailDetails.put('Mail', contEmail);
        emailDetails.put('ContactID', contactID);
        emailDetails.put('Subject', subject);
        emailDetails.put('CCAddress', ccAddress);
        emailDetails.put('BccAddress', bccAddress);
        emailDetails.put('Body', messageBody);

        System.debug('Map sent ' + emailDetails.size());

        LogOutboundEmailHandler.createEmailMessage(emailDetails);

        System.debug('Email Sent Successfully!');
      } catch (Exception ex) {
        sMessage =
          ex.getMessage() +
          '\n' +
          ex.getLineNumber() +
          '\n' +
          ex.getCause();
        System.debug('Error ' + sMessage);
      }
    }
  }
}