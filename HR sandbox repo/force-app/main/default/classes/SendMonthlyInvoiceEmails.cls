public with sharing class SendMonthlyInvoiceEmails {
  @future(callout=true)
  public static void sendBatchInvoices(List<String> accList) {
    Map<String, String> emailDetails = new Map<String, String>();
    String subject = 'Invoice Details';
    String contactName;
    String ccAddress = '';
    String bccAddress = '';
    String body = 'Please find the attached Invoice';
    Datetime todaysDate = Datetime.now();
    String month = todaysDate.format('MMMM');
    String dueDate = Date.today().format();
    String invoiceNumber;
    String accID;
    String contEmail;
    String contactID;
    String messageBody;
    String invId;
    Decimal balance;

    String ccEmail = 'mraccounting@momrelaunch.com';

    List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
    List<ContentVersion> lstCov = new List<ContentVersion>();

    System.debug('Got the accounts  list' + accList);
    String sMessage = '';

    try {
      List<AVAB__SO_Document__c> invoiceList = [
        SELECT
          Id,
          Name,
          AVAB__Contact__c,
          AVAB__Account__c,
          AVAB__Balance__c,
          AVAB__Contact__r.Name,
          AVAB__Contact__r.Email
        FROM AVAB__SO_Document__c
        WHERE Id IN :accList
      ];

      for (AVAB__SO_Document__c inv : invoiceList) {
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        invoiceNumber = inv.Name;
        System.debug('Invoice Number ' + invoiceNumber);
        accID = inv.AVAB__Account__c;
        contEmail = inv.AVAB__Contact__r.Email;
        contactID = inv.AVAB__Contact__c;
        contactName = inv.AVAB__Contact__r.Name;
        System.debug('Candidate ' + contactName);
        invId = inv.Id;
        balance = inv.AVAB__Balance__c;
        messageBody =
          '<html><body> Dear ' +
          contactName +
          ',<br/><br/> We hope you are well! <br/><br/> Please see invoice ' +
          invoiceNumber +
          ' attached. ' +
          '<br/><br/> The invoice with a balance of $' +
          balance +
          ' is due on ' +
          dueDate +
          '. <br/><br/>Please don’t hesitate to get in touch if you have any questions, or would like to clarify anything. <br/><br/> <br/> Best regards, <br/> Mom Relaunch Accounting</body>  </html>';

        PageReference pageref = new Pagereference(
          '/apex/Manual_Template_Generator?id=' + invId
        );

        Blob b;
        if (Test.isRunningTest()) {
          b = blob.valueOf('Unit.Test');
        } else {
          b = pageref.getContentAsPDF();
        }

        attach.setFileName('Invoice.pdf');
        attach.setBody(b);
        semail.setFileAttachments(
          new List<Messaging.EmailFileAttachment>{ attach }
        );
        semail.setSubject(subject);
        semail.setTargetObjectId(contactID);
        semail.setToAddresses(new List<String>{ contEmail });
        semail.setHtmlBody(messageBody);
        semail.setSaveAsActivity(true);
        semail.setWhatId(accID);
        semail.setCcAddresses(new List<String>{ ccEmail });

        lstMails.add(semail);
      }

      Messaging.sendEmail(lstMails);
    } catch (Exception e) {
      System.debug('Error occured ' + e.getMessage());
      System.debug('Line where error occured ' + e.getLineNumber());
    }
  }
}