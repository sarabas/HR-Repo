@IsTest
 class ScheduleSendRecurrentInvoiceTest {
@TestSetup
static void createData(){
    Account a = new Account();
        a.Name = 'Test Account';
        
        List<AVAB__Item__c> itemList = new List<AVAB__Item__c>();

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

        AVAB__SO_Document__c invoice1 = new AVAB__SO_Document__c();
        invoice1.AVAB__Account__c = c1.AccountId;
        invoice1.AVAB__Contact__c = c1.Id;

        AVAB__SO_Document__c invoice2 = new AVAB__SO_Document__c();
        invoice2.AVAB__Account__c = c2.AccountId;
        invoice2.AVAB__Contact__c = c2.Id;
        Id recType = Schema.SObjectType.AVAB__SO_Document__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        invoice1.RecordTypeId = recType;
        invoice2.RecordTypeId = recType;

        List<AVAB__SO_Document__c> invList = new List<AVAB__SO_Document__c>();
        invList.add(invoice1);
        invList.add(invoice2);

        insert invList;

}

    @IsTest 
    static void sendRecurrentInvoicePositiveTest() {
        String accId;
        List<String> accList = new List<String>();
        List<AVAB__SO_Document__c> invList = [SELECT Id, Name FROM AVAB__SO_Document__c];
        System.debug('inv size ' + invList.size());
        
        Test.startTest();
        ScheduleSendRecurrentInvoice schedClass = new ScheduleSendRecurrentInvoice();
        String cronExp = '0 0 8 1 * ?';
     
        String jobId = System.schedule('TestInvoiceSchedule', cronExp, schedClass);
        
        Test.stopTest();
        System.assertEquals(2, invList.size());
        System.assertNotEquals(!(String.isBlank(jobId)), String.isBlank(jobId));
        


    }

    
}