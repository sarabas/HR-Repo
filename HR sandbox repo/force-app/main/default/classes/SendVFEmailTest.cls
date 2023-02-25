@IsTest
private class SendVFEmailTest {
  @IsTest
  static void sendInvoiceEmailTest() {
    String ccAddress = '';
    String bccAddress = '';
    String body = 'Please find the attached Invoice';
    Datetime todaysDate = Datetime.now();
    String month = todaysDate.format('MMMM');
    String dueDate = Date.today().format();


    Account a = new Account();
    a.Name = 'Test acc';

    insert a;

    List<String> contEmail = new List<String>();
    String sMessage = '';

    Contact c1 = new Contact();
    c1.LastName = 'Test1';
    c1.AccountId = a.Id;
    c1.Email = 'mracctbook2020@gmail.com';

    Contact c2 = new Contact();
    c2.LastName = 'Test2';
    c2.AccountId = a.Id;
    c2.Email = 'mracctbook@gmail.com';

    List<Contact> contList = new List<Contact>();
    contList.add(c1);
    contList.add(c2);

    contEmail.add(c1.Email);
    contEmail.add(c2.Email);

    insert contList;

    List<AVAB__SO_Document__c> invList = new List<AVAB__SO_Document__c>();

    AVAB__SO_Document__c invoice1 = new AVAB__SO_Document__c();
    invoice1.AVAB__Account__c = a.Id;
    invoice1.AVAB__Contact__c = c1.Id;

    AVAB__SO_Document__c invoice2 = new AVAB__SO_Document__c();
    invoice2.AVAB__Account__c = a.Id;
    invoice2.AVAB__Contact__c = c2.Id;

    invList.add(invoice1);
    invList.add(invoice2);

    insert invList;

    String invID;
    List<String> invIDList = new List<String>();

    for (AVAB__SO_Document__c rec : invList) {
      invID = rec.Id;
      invIDList.add(invID);
    }

    System.debug('Invoice ID List ' + invIDList);

    Test.startTest();
    Integer invocations = Limits.getEmailInvocations();
    SendVFEmail.sendBatchInvoices(invIDList);
    //System.debug('Invocations ' + invocations);
    Test.stopTest();

    System.assertEquals(2, invIDList.size(), 'Incorrect number of invoice IDs');
  }
  @IsTest
  static void sendInvoiceEmailNoDataTest() {
    Account a = new Account();
    a.Name = 'Test acc';

    //insert a;

    List<String> contEmail = new List<String>();
    String sMessage = '';

    Contact c1 = new Contact();
    c1.LastName = 'Test1';
    c1.AccountId = a.Id;
    c1.Email = 'mracctbook2020@gmail.com';

    Contact c2 = new Contact();
    c2.LastName = 'Test2';
    c2.AccountId = a.Id;
    c2.Email = 'mracctbook@gmail.com';

    List<Contact> contList = new List<Contact>();
    contList.add(c1);
    contList.add(c2);

    contEmail.add(c1.Email);
    contEmail.add(c2.Email);

    //insert contList;

    List<AVAB__SO_Document__c> invList = new List<AVAB__SO_Document__c>();

    AVAB__SO_Document__c invoice1 = new AVAB__SO_Document__c();
    invoice1.AVAB__Account__c = a.Id;
    invoice1.AVAB__Contact__c = c1.Id;

    AVAB__SO_Document__c invoice2 = new AVAB__SO_Document__c();
    invoice2.AVAB__Account__c = a.Id;
    invoice2.AVAB__Contact__c = c2.Id;

    invList.add(invoice1);
    invList.add(invoice2);

    //insert invList;

    String invID;
    List<String> invIDList = new List<String>();

    for (AVAB__SO_Document__c rec : invList) {
      invID = rec.Id;
      invIDList.add(invID);
    }

    // System.debug('Invoice ID List ' + invIDList.size());

    Test.startTest();

    List<AVAB__SO_Document__c> invoices = [
      SELECT Id
      FROM AVAB__SO_Document__c
      WHERE Id IN :invIDList
    ];

    Integer invocations = Limits.getEmailInvocations();
    SendVFEmail.sendBatchInvoices(invIDList);
    Test.stopTest();

    System.assertEquals(0, invoices.size(), 'List should be empty ');
  }
}