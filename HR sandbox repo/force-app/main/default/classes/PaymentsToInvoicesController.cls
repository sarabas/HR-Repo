public with sharing class PaymentsToInvoicesController {
  @AuraEnabled(cacheable=true)
  public static List<PaymentsToInvoicesController.InvoiceDetailsWrapper> getPaymentsToInvoice(
    String accID
  ) {
    System.debug('Received account ' + accID);

    List<PaymentsToInvoicesController.InvoiceDetailsWrapper> invoiceDetailsWrapperList = new List<PaymentsToInvoicesController.InvoiceDetailsWrapper>();

    List<AVAB__SO_Document__c> invoiceList = [
      SELECT Name, AVAB__Date__c, AVAB__Balance__c, AVAB__Contact__r.Name
      FROM AVAB__SO_Document__c
      WHERE AVAB__Account__c = :accID AND AVAB__Balance__c > 0
    ];

    for (AVAB__SO_Document__c invoice : invoiceList) {
      PaymentsToInvoicesController.InvoiceDetailsWrapper invWrapper = new PaymentsToInvoicesController.InvoiceDetailsWrapper();
      invWrapper.invoice = invoice.Name;
      invWrapper.invoiceDate = invoice.AVAB__Date__c;
      invWrapper.contactName = invoice.AVAB__Contact__r.Name;
      invWrapper.balance = invoice.AVAB__Balance__c;

      invoiceDetailsWrapperList.add(invWrapper);
    }

    return invoiceDetailsWrapperList;
  }

  public class InvoiceDetailsWrapper {
    @AuraEnabled
    public String invoice { get; set; }
    @AuraEnabled
    public Date invoiceDate { get; set; }
    @AuraEnabled
    public String contactName { get; set; }
    @AuraEnabled
    public Decimal balance { get; set; }
  }

  public class PaymentDetailsWrapper {
    @AuraEnabled
    public String paymentID { get; set; }
    @AuraEnabled
    public String invoiceNumber { get; set; }
    @AuraEnabled
    public Decimal applyAmount { get; set; }
  }

  @AuraEnabled
  public static void applyPaymentToInvoice(
    PaymentsToInvoicesController.PaymentDetailsWrapper paymentWrapper
  ) {
    String invoice = paymentWrapper.invoiceNumber;
    String paymentId = paymentWrapper.paymentID;
    Decimal amountToApply = paymentWrapper.applyAmount;

    String invID;

    List<AVAB__Payments_to_Invoice__c> paymentsList = new List<AVAB__Payments_to_Invoice__c>();

    System.debug('Invoice received ' + invoice);
    System.debug('Payment Id received ' + paymentId);

    if (amountToApply > 0) {
      List<AVAB__Payments__c> payments = [
        SELECT AVAB__Amount__c, AVAB__Payments_Applied__c
        FROM AVAB__Payments__c
        WHERE Id = :paymentId
      ];
      List<AVAB__SO_Document__c> selectedInvoices = [
        SELECT Id
        FROM AVAB__SO_Document__c
        WHERE Name = :invoice
      ];

      System.debug('applied payments ' + payments);
      System.debug('List inv ' + selectedInvoices);
      try {
        for (AVAB__Payments__c payment : payments) {
          for (AVAB__SO_Document__c inv : selectedInvoices) {
            if (payment.AVAB__Payments_Applied__c == null) {
              payment.AVAB__Payments_Applied__c = 0;
            }

            if (payment.AVAB__Payments_Applied__c < payment.AVAB__Amount__c) {
              AVAB__Payments_to_Invoice__c newPayment = new AVAB__Payments_to_Invoice__c();
              newPayment.AVAB__Receivable__c = inv.Id;
              newPayment.AVAB__Amount__c = amountToApply;
              newPayment.AVAB__Payment__c = payment.Id;

              //invID = inv.Id;

              payment.AVAB__Payments_Applied__c = amountToApply;
              paymentsList.add(newPayment);
            } else {
              System.debug('You have over applied payments');
            }
          }
        }

        insert paymentsList;
        update payments;
      } catch (Exception e) {
        System.debug('Error occured ' + e.getMessage());
      }
    }
  }
}