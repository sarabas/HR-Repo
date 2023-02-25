@IsTest
private class PaymentsToInvoicesControllerTest {
  @IsTest
  static void getPaymentsToInvoiceTest() {
    PaymentsToInvoicesController.InvoiceDetailsWrapper wrapper = new PaymentsToInvoicesController.InvoiceDetailsWrapper();
    wrapper.invoice = '007684';
    wrapper.invoiceDate = Date.today();
    wrapper.contactName = 'Test contact';
    wrapper.balance = 100;

    List<PaymentsToInvoicesController.InvoiceDetailsWrapper> wrapperList = new List<PaymentsToInvoicesController.InvoiceDetailsWrapper>();
    List<String> listOfInvoices = new List<String>();

    wrapperList.add(wrapper);

    List<Contact> contList = new List<Contact>();
    List<AVAB__SO_Document__c> invList = new List<AVAB__SO_Document__c>();
    Decimal val = 500;

    Account acc = new Account();
    acc.Name = 'Test acc';

    insert acc;
    String accID = acc.Id;

    for (Integer j = 0; j < 3; j++) {
      Contact c = new Contact();
      c.LastName = 'contTest1' + j;
      c.AccountId = acc.Id;
      contList.add(c);
    }
    insert contList;

    for (Contact c : contList) {
      AVAB__SO_Document__c invoice = new AVAB__SO_Document__c();
      invoice.AVAB__Account__c = acc.Id;
      invoice.AVAB__Contact__c = c.Id;
      invoice.AVAB__Date__c = Date.Today();
      Id recTypeId = Schema.SObjectType.AVAB__SO_Document__c.getRecordTypeInfosByName()
        .get('Invoice')
        .getRecordTypeId();
      invoice.RecordTypeId = recTypeId;

      invList.add(invoice);
    }
    insert invList;

    List<AVAB__SO_Document__c> insertedInvoices = [
      SELECT Id
      FROM AVAB__SO_Document__c
      WHERE Id IN :invList
    ];

    for (AVAB__SO_Document__c invoice : insertedInvoices) {
      invoice.AVAB__Amount__c = val;
      invoice.AVAB__Status__c = 'Post';
      val = val + 10;
    }

    try {
      update insertedInvoices;
      System.debug('invoices ' + insertedInvoices);

      List<AVAB__SO_Document__c> retrievedInvoices = [
        SELECT Id, Name, AVAB__Balance__c
        FROM AVAB__SO_Document__c
        WHERE Id IN :insertedInvoices
      ];
    
      
      for(AVAB__SO_Document__c invoice : retrievedInvoices){
        String invNum = invoice.Name;
        listOfInvoices.add(invNum);
      }
      System.debug('number of invoices ' + retrievedInvoices.size());
    } catch (Exception e) {
      System.debug('Error found ' + e.getMessage());
    }

    //====================================================================================================

    List<AVAB__Payments_to_Invoice__c> paymentsList = new List<AVAB__Payments_to_Invoice__c>();
    PaymentsToInvoicesController.PaymentDetailsWrapper paymentWrapper = new PaymentsToInvoicesController.PaymentDetailsWrapper();
    PaymentsToInvoicesController.PaymentDetailsWrapper paymentWrapper2 = new PaymentsToInvoicesController.PaymentDetailsWrapper();
    paymentWrapper.paymentID = 'a280m000001GdQU';
    paymentWrapper.invoiceNumber = listOfInvoices[0];
    paymentWrapper.applyAmount = 90;

    paymentWrapper2.paymentID = 'a280m000001GdQU';
    paymentWrapper2.invoiceNumber = listOfInvoices[1];
    paymentWrapper2.applyAmount = 0;

    System.debug('Invoice 1 is' + paymentWrapper.invoiceNumber);
    System.debug('Invoice 2 is ' + paymentWrapper2.invoiceNumber);


    String paymentID = paymentWrapper.paymentID;
    String invoiceNumber = paymentWrapper.invoiceNumber;
    Decimal amountToApply = paymentWrapper.applyAmount;

    String paymentID2 = paymentWrapper2.paymentID;
    String invoiceNumber2 = paymentWrapper2.invoiceNumber;
    Decimal amountToApply2 = paymentWrapper2.applyAmount;

    AVAB__GL_Account__c glAcc = new AVAB__GL_Account__c();
    glAcc.Name = 'Test GLAccount';

    insert glAcc;

    AVAB__Payments__c pay = new AVAB__Payments__c();
    pay.AVAB__Account_Name__c = acc.Id;
    pay.AVAB__Transaction_Date_Time__c = Datetime.now();
    pay.AVAB__GL_Account__c = glAcc.Id;
    pay.AVAB__Date__c = Date.today();
    pay.AVAB__Amount__c = 500;
    pay.AVAB__Payments_Applied__c = null;

    insert pay;
    System.debug('applied pay1 ' + pay);

    AVAB__Payments__c pay2 = new AVAB__Payments__c();
    pay2.AVAB__Account_Name__c = acc.Id;
    pay2.AVAB__Transaction_Date_Time__c = Datetime.now();
    pay2.AVAB__GL_Account__c = glAcc.Id;
    pay2.AVAB__Date__c = Date.today();
    pay2.AVAB__Amount__c = 100;
    pay2.AVAB__Payments_Applied__c = 90;

    insert pay2;
    System.debug('applied pay2 ' + pay2);

    AVAB__Payments__c pay3 = new AVAB__Payments__c();
    pay3.AVAB__Account_Name__c = acc.Id;
    pay3.AVAB__Transaction_Date_Time__c = Datetime.now();
    pay3.AVAB__GL_Account__c = glAcc.Id;
    pay3.AVAB__Date__c = Date.today();
    pay3.AVAB__Amount__c = 100;
    pay3.AVAB__Payments_Applied__c = 100;

    insert pay3;
    System.debug('applied pay3 ' + pay3);

    Test.startTest();
    List<PaymentsToInvoicesController.invoiceDetailsWrapper> paymentTest = PaymentsToInvoicesController.getPaymentsToInvoice(
      acc.Id
    );
    PaymentsToInvoicesController.applyPaymentToInvoice(paymentWrapper);
    PaymentsToInvoicesController.applyPaymentToInvoice(paymentWrapper2);
    Test.stopTest();

    System.assertEquals(3, invList.size(), 'Incorrect number of invoices');
  }
}