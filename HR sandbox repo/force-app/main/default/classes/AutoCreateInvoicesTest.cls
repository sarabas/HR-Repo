@IsTest
private class AutoCreateInvoicesTest {
    @IsTest static void generateInvoicesTest() {

        String invoiceNumber;
        List<String> invoiceNumbers = new List<String>(); 
        List<AVAB__Item__c> itemList = new List<AVAB__Item__c>();

        Account a =  new Account();
        a.Name = 'Candidate Pool';   
        
        AVAB__Item__c item1 = new AVAB__Item__c();
        item1.Name = 'Launch Pad Fees';
        item1.AVAB__Sales_Price__c = 79;
        
        AVAB__Item__c item2 = new AVAB__Item__c();
        item2.Name = 'Training Fees';
        item2.AVAB__Sales_Price__c = 79;

        AVAB__Item__c item3 = new AVAB__Item__c();
        item3.Name = 'Test';
        item3.AVAB__Sales_Price__c = 20;

        itemList.add(item1);
        itemList.add(item2);
        itemList.add(item3);

        insert itemList;

        Contact c1 = new Contact();
        c1.AccountId = a.Id;
        c1.LastName = 'Priya';
        c1.Membership_Type__c = 'LaunchPad Membership';
        c1.Launchpad_Membership_Fees_Waived__c = false;
        c1.AVTRRT__Candidate_Status__c = 'Active';
        c1.Membership_Product__c = item1.Id;
      

        Contact c2 = new Contact();
        c2.AccountId = a.Id;
        c2.LastName = 'Brie';
        c2.Membership_Type__c = 'Training Membership';
        c2.Launchpad_Membership_Fees_Waived__c = false;
        c2.AVTRRT__Candidate_Status__c = 'Active';
        c2.Membership_Product__c = item2.Id;

        Contact c3 = new Contact();
        c3.AccountId = a.Id;
        c3.LastName = 'Shashank';
        c3.Membership_Type__c = 'Alumni Membership';
        c3.Launchpad_Membership_Fees_Waived__c = true;
        
        Contact c4 = new Contact();
        c4.AccountId = a.Id;
        c4.LastName = 'Priyanka';
        c4.Membership_Type__c = 'LaunchPad Membership';
        c4.Launchpad_Membership_Fees_Waived__c = true;
        c4.AVTRRT__Candidate_Status__c = 'Active';
        c1.Membership_Product__c = item3.Id;
        

        List<Contact> contList = new List<Contact>();
        contList.add(c1);
        contList.add(c2);
        contList.add(c3);
        contList.add(c4);

        insert contList;
        

        
        Test.startTest();  
        List<String> invList =  AutoCreateInvoices.generateInvoices();
       
        List<AVAB__SO_Document__c> invoiceIDs = [SELECT Id FROM AVAB__SO_Document__c where Name  IN : invList];
        System.debug('invoices ' + invoiceIDs);
        //List<AVAB__Transaction_Line_Items__c> transLItemList = [SELECT AVAB__AR_Transaction__c FROM AVAB__Transaction_Line_Items__c where  AVAB__AR_Transaction__c IN :invoiceIDs];


        Test.stopTest();

        System.assertEquals(2, invList.size(), 'Incorrect number of invoices created');
        //System.assertEquals(2, transLItemList.size(), 'Incorrect number of AVAB__Transaction_Line_Items__c created');

        System.assert(invList.size() != null);

        

          
    }
}