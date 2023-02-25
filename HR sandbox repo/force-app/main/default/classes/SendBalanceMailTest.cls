@IsTest
private class SendBalanceMailTest {
  @IsTest
  static void sendBalanceMailTest() {
    Account a = new Account();
    a.Name = 'Test acc';
    String accID = a.Id;

    insert a;

    Account b = new Account();
    b.Name = 'Candidate Pool';
    String accID2 = b.Id;

    insert b;

    Contact c1 = new Contact();
    c1.LastName = 'Test1';
    c1.AccountId = a.Id;
    c1.Email = 'mracctbook2020@gmail.com';
    String contactID = c1.Id;
  

    Contact c2 = new Contact();
    c2.LastName = 'Test';
    c2.AccountId = a.Id;
    c2.Email = 'mracctbook@gmail.com';
    String contactID2 = c2.Id;

    Contact c3 = new Contact();
    c3.LastName = 'Test3';
    c3.AccountId = a.Id;
    c3.Email = '';
    String contactID3 = c3.Id;

    Contact b1 = new Contact();
    b1.LastName = 'Test2';
    b1.AccountId = b.Id;
    b1.Email = 'mracctbook2020@gmail.com';
    String contactID4 = b1.Id;
    
    List<Contact> contList = new List<Contact>();
    contList.add(c1);
    contList.add(c2);
    contList.add(c3);
    contList.add(b1);

    Decimal balance = 100;
    Decimal bal = 0;
    String contName = 'Test Contact';
    Map<String,String> emailDetails = new Map<String,String>();

    String subject = 'Test subject!';
    String body = 'Test body';
    String ccAddress = '';
    String bccAddress = '';

    insert contList;

    Test.startTest();
    SendBalanceMail.balanceMail('Test acc', 'Test', balance);
    SendBalanceMail.balanceMail('Candidate Pool', 'Test1', balance);
    SendBalanceMail.balanceMail('Test acc', 'Test1', bal);
    Test.stopTest();
  }
}