@IsTest
public class TestDataFactory {
    public static List<AVAB__SO_Document__c> createInvoicesBasedOnNumOfContacts(Integer numOfContacts) {
        
        //Decimal bal = 100;
        List<Contact> contList = new List<Contact>();
        List<AVAB__SO_Document__c> invList = new List<AVAB__SO_Document__c>();
        List<AVAB__Transaction_Line_Items__c> transLItemList  = new List<AVAB__Transaction_Line_Items__c>();

        
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        for(Integer j = 0; j<numOfContacts; j++){
            Contact c = new Contact();
            c.LastName = 'contTest1' + j;
            c.AccountId = acc.Id;
            c.Email = 'mracctbook2020@gmail.com';
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

                invoice.AVAB__Amount__c = 50;
                invoice.AVAB__Status__c = 'Post';
               
            }
        
        try{
           
            update insertedInvoices;
        }
        catch(Exception e){
            System.debug('Error found ' + e.getMessage());
        }
  
        return insertedInvoices;
    }
}