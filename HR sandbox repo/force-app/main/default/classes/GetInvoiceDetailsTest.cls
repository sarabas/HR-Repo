@IsTest
private class GetInvoiceDetailsTest {
   @IsTest static void getInvoiceDetailsTest() {

            
       String invoiceNum;
       String custName;
       String custEmail;
       Map<String,String> mapDetails = new Map<String,String>();

        Account a = new Account();
        a.Name = 'Test acc';

        insert a;

       List<String> contEmail = new List<String>();
    
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

        String invID = invoice1.Id;

        Test.startTest();
        mapDetails = GetInvoiceDetails.getInvoiceDetails(invID);
        Test.stopTest();

        System.assertEquals(3, mapDetails.size(), 'Incorrect number of parameters');
    }
    @IsTest static void getInvoiceDetailsWithMissingDataTest() {
        String invoiceNum;
       String custName;
       String custEmail;
       Map<String,String> mapDetails = new Map<String,String>();

        Account a = new Account();
        a.Name = 'Test acc';

        insert a;

       List<String> contEmail = new List<String>();
    
        Contact c1 = new Contact();
        c1.LastName = 'Test1';
        c1.AccountId = a.Id;
        c1.Email = '';

        Contact c2 = new Contact();
        c2.LastName = 'Test2';
        c2.AccountId = a.Id;
        c2.Email = '';

        List<Contact> contList = new List<Contact>();
        contList.add(c1);
        contList.add(c2);

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

        String invID = invoice1.Id;

        Test.startTest();
        mapDetails = GetInvoiceDetails.getInvoiceDetails(invID);
        Test.stopTest();

        String mail = mapDetails.get('Email');
        

        System.assertEquals(true, String.isBlank(mail), 'Should not return email parameter');
    }
}