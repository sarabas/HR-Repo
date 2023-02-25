@IsTest
private class ChangeMailCountryTest {
    
    @IsTest
    static void testUpdateMailCountryTest() {

        List<Contact> updateList = new List<Contact>();
        Account a = new Account();
        a.Name = 'test account';

        insert a;

        
        for(Integer i = 0;i<10; i++)
        {
            Contact c =  new Contact();
            c.LastName = 'test'+i;
            c.MailingCountry = 'u s a';
            c.AccountId = a.Id;
            
        }
        for(Integer i = 0;i<10; i++)
        {
            Contact c =  new Contact();
            c.LastName = 'testing'+i;
            c.MailingCountry = 'United States of America';
            c.AccountId = a.Id;
            
           
            updateList.add(c);
        }

        for(Integer i = 0;i<10; i++)
        {
            Contact c =  new Contact();
            c.LastName = 'test contact'+i;
            c.MailingCountry = 'USA';
            c.AccountId = a.Id;
            
            updateList.add(c);
        }
        for(Integer i = 0;i<10; i++)
        {
            Contact c =  new Contact();
            c.LastName = 'testy contact'+i;
            c.MailingCountry = 'United States';
            c.AccountId = a.Id;
            
            updateList.add(c);
        }
        insert updateList;

        List<Contact> mlist = [SELECT Id FROM Contact];
        //System.assertEquals(40, mlist.size());
        Test.startTest();
        ChangeMailCountry.standardizeMailCountry();
        Test.stopTest();
    }
}