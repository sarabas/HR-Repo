trigger RetrieveAmountAppliedToInvoice on AVAB__Payments_to_Invoice__c( after insert) {
  Decimal amount;
  String invoiceID;
  for (AVAB__Payments_to_Invoice__c payment : Trigger.new) {
    amount = payment.AVAB__Amount__c;
    invoiceID = payment.AVAB__Receivable__c;
  }
  System.debug('Amount applied ' + amount);
  System.debug('Invoice ID ' + invoiceID);

  try {
    SendThankYouEmailOnPayment.sendThankYouEmail(invoiceID, amount);
  } catch (Exception e) {
    System.debug('Error occured ' + e.getMessage());
  }
}