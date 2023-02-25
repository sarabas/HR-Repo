@IsTest
private class SendMonthlyInvoiceEmailsTest {
  @TestSetup
  static void createData() {
    List<Account> lstAcc = new List<Account>();
    List<Contact> contList = new List<Contact>();
    for (Integer i = 0; i < 50; i++) {
      Account a = new Account();
      a.Name = 'test' + i;
      lstAcc.add(a);
    }

    for (Integer i = 0; i < 50; i++) {
      Contact c = new Contact();
      c.LastName = 'testContact' + i;
      c.AccountId = lstAcc[i].Id;
      c.Email = 'test@test.com';
      contList.add(c);
    }

    List<AVAB__SO_Document__c> invList = new List<AVAB__SO_Document__c>();
    for (Integer i = 0; i < 50; i++) {
      AVAB__SO_Document__c inv = new AVAB__SO_Document__c();
      inv.AVAB__Account__c = lstAcc[i].Id;
      inv.AVAB__Contact__c = contList[i].Id;
      inv.AVAB__Amount__c = 100;
      invList.add(inv);
    }
    try {
      insert lstAcc;
      insert contList;
      insert invList;
      System.debug('Invoices ' + invList.size());
    } catch (Exception e) {
      System.debug('Error occured ' + e.getMessage());
    }
  }
  @IsTest
  private static void sendMonthlyEmailsTest() {
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
    String acc;
    String contEmail;
    String contactID;
    String messageBody;
    String invId;
    Decimal balance;
    String sMessage = '';

    String ccEmail = 'test@test.com';
    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    List<AVAB__SO_Document__c> invLst = [
      SELECT
        Id,
        Name,
        AVAB__Contact__c,
        AVAB__Account__c,
        AVAB__Balance__c,
        AVAB__Contact__r.Name,
        AVAB__Contact__r.Email
      FROM AVAB__SO_Document__c
    ];

    System.assertEquals(50, invLst.size(), 'Incorrect number of invoices');
    List<String> accList = new List<String>();

    for (AVAB__SO_Document__c inv : invLst) {
      accID = inv.Id;
      accList.add(accID);
    }

    Test.startTest();
    Integer invocations = Limits.getEmailInvocations();
    //SendMonthlyInvoiceEmails.sendBatchInvoices(accList);
    //System.debug('Invocations ' + invocations);
    Test.stopTest();
  }
  @IsTest
  static void sendInvoiceFailTest() {
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
    String acc;
    String contEmail;
    String contactID;
    String messageBody;
    String invId;
    Decimal balance;
    String sMessage = '';

    String ccEmail = 'test@test.com';
    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    List<AVAB__SO_Document__c> invLst = [SELECT Name FROM AVAB__SO_Document__c];
    List<String> accList = new List<String>();

    for (AVAB__SO_Document__c inv : invLst) {
      accID = inv.Name;
      accList.add(accID);
    }
    Test.startTest();
    Integer invocations = Limits.getEmailInvocations();
   // SendMonthlyInvoiceEmails.sendBatchInvoices(accList);
    //System.debug('Invocations ' + invocations);
    Test.stopTest();
  }
}