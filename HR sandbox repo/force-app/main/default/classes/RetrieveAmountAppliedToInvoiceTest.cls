@IsTest
public class RetrieveAmountAppliedToInvoiceTest {
   @IsTest static void retrieveAmountApplied() {

    List<Contact> contList = new List<Contact>();
    List<AVAB__SO_Document__c> invList = new List<AVAB__SO_Document__c>();
    List<AVAB__Payments_to_Invoice__c> listOfPayments = new List<AVAB__Payments_to_Invoice__c>();
    Decimal val = 10;
    Integer i = 0;

    Account acc = new Account(Name = 'Test Account');
    insert acc;

    for(Integer j = 0; j<3; j++){
        Contact c = new Contact();
        c.LastName = 'contTest1' + j;
        c.AccountId = acc.Id;
        contList.add(c);
    }
    insert contList;

    AVAB__Item__c item = new AVAB__Item__c();
        item.Name = 'test item';
        item.AVAB__Sales_Price__c = 30;
    
        insert item;

        for(Contact c : contList){
            AVAB__SO_Document__c invoice = new AVAB__SO_Document__c();
            invoice.AVAB__Account__c = acc.Id;
            invoice.AVAB__Contact__c = c.Id;
            Id recTypeId = Schema.SObjectType.AVAB__SO_Document__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
            invoice.RecordTypeId = recTypeId;

            invList.add(invoice);
           
            }
            insert invList;

            System.debug('Invoice Id ' + invList);

            List<AVAB__SO_Document__c> insertedInvoices = [SELECT Id FROM AVAB__SO_Document__c WHERE Id IN :invList];
            
            for(AVAB__SO_Document__c invoice : insertedInvoices){

                invoice.AVAB__Amount__c = val;
                invoice.AVAB__Status__c = 'Post';
                val = val +10;
               
            }
        
        try{
           
            update insertedInvoices;
        }
        catch(Exception e){
            System.debug('Error found ' + e.getMessage());
        }

        for(AVAB__SO_Document__c inv : insertedInvoices){
            
            AVAB__Payments_to_Invoice__c payment = new AVAB__Payments_to_Invoice__c();
            payment.AVAB__Receivable__c = inv.Id;
            payment.AVAB__Amount__c = 20;
            listOfPayments.add(payment);
            
        }
       Database.SaveResult[] sr = Database.insert(listOfPayments,false);

       for(Database.SaveResult sres : sr)
       {
            if(sres.isSuccess()){
                i = i + 1;
            }
       }
    
       System.debug('Success = ' + i);

       System.assertEquals(3, listOfPayments.size(), 'Did not create 3 payments to invoice');




    }


    
    
}