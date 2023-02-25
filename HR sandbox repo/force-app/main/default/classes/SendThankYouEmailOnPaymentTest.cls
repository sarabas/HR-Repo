@IsTest
private with sharing class SendThankYouEmailOnPaymentTest {
   @IsTest static void sendThankYouEmailTest() {

    String accName;
    String contName;
    Decimal balance;
    List<AVAB__SO_Document__c> invoiceList = new List<AVAB__SO_Document__c>();
    invoiceList = TestDataFactory.createInvoicesBasedOnNumOfContacts(3);

    List<AVAB__SO_Document__c> createdInvoices  = [SELECT Id, AVAB__Account__c, AVAB__Contact__c, AVAB__Balance__c  FROM AVAB__SO_Document__c WHERE Id IN :invoiceList];
    
    Test.startTest();
    for(AVAB__SO_Document__c inv : createdInvoices){
        accName = inv.AVAB__Account__c;
        contName = inv.AVAB__Contact__c;
        balance = inv.AVAB__Balance__c;
        String invoiceID = inv.Id;        
        SendThankYouEmailOnPayment.sendThankYouEmail(invoiceID, balance);
       
    }
    Test.stopTest();
    System.assertEquals(3, invoiceList.size(), 'Incorrect number of invoices created');
    System.assertEquals(3, createdInvoices.size(), 'Incorrect number of invoices retrieved');
  }
}