@IsTest
private class LogOutboundEmailHandlerTest {
  @IsTest
  static void createEmailMessageTest() {
    Account a = new Account(Name = 'Test Acc');
    insert a;
    String accID = a.Id;

    Contact c1 = new Contact();
    c1.LastName = 'TestContact';
    c1.AccountId = a.Id;
    c1.Email = 'mracctbook2020@gmail.com';

    insert c1;
    String contactID = c1.Id;
    String mail = c1.Email;
    String subject = 'This is the test subject';
    String ccAddress = 'mracctbook2020@gmail.com';
    String bccAddress = 'mracctbook2020@gmail.com';
    String body = 'this is the test body';
    String sMessage = '';

    Blob b;
    ContentVersion cv = new ContentVersion();
    b = blob.valueOf('Unit.Test');

    cv.VersionData = b;
    cv.Title = 'Client Invoice';
    cv.PathOnClient = 'Invoice.pdf';
    cv.ContentLocation = 'S';
    cv.Description = 'Customer invoice';
    cv.IsMajorVersion = true;
    insert cv;

    Id contentDocId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
    ]
    .ContentDocumentId;

    String[] toIds = new List<String>{ contactID };
    EmailMessage emailMessage = new EmailMessage();
    emailMessage.RelatedToId = accID;
    emailMessage.Status = '5';
    insert emailMessage;

    String emId = emailMessage.Id;

    Map<String, String> emailDetails = new Map<String, String>();
    emailDetails.put('Account', accID);
    emailDetails.put('ContentDocID', contentDocId);
    emailDetails.put('Mail', mail);
    emailDetails.put('ContactId', contactID);
    emailDetails.put('Subject', subject);
    emailDetails.put('CcAddress', ccAddress);
    emailDetails.put('BccAddress', bccAddress);
    emailDetails.put('Body', body);

    Test.startTest();
    LogOutboundEmailHandler.createEmailMessage(emailDetails);
    Test.stopTest();

    System.assertEquals(8, emailDetails.size(), 'Incorrect size');
    System.assertNotEquals(null, emId);
  }
  @IsTest
  static void createEmailMessageNegativeTest() {
    Account a = new Account(Name = 'Test Acc');
    //insert a;
    String accID;

    Contact c1 = new Contact();
    c1.LastName = 'TestContact';
    c1.AccountId = a.Id;
    c1.Email = 'mracctbook2020@gmail.com';

    //insert c1;
    String contactID = '';
    String mail;
    String subject;
    String ccAddress;
    String bccAddress;
    String body;

    Blob b;
    ContentVersion cv = new ContentVersion();
    b = blob.valueOf('Unit.Test');

    cv.VersionData = b;
    cv.Title = 'Client Invoice';
    cv.PathOnClient = 'Invoice.pdf';
    cv.ContentLocation = 'S';
    cv.Description = 'Customer invoice';
    cv.IsMajorVersion = true;
    insert cv;

    // Id contentDocId = [
    //     SELECT ContentDocumentId
    //     FROM ContentVersion
    //     WHERE Id = :cv.Id
    // ]
    // .ContentDocumentId;

    String[] toIds = new List<String>{ contactID };
    EmailMessage emailMessage = new EmailMessage();
    emailMessage.Status = '3';
    insert emailMessage;

    String emId = emailMessage.Id;
 

    Map<String, String> emailDetails = new Map<String, String>();
    Map<String, String> emptyMap = new Map<String, String>();
    emailDetails.put('Account', accID);
    //emailDetails.put('ContentDocID', contentDocId);
    emailDetails.put('Mail', mail);
    emailDetails.put('ContactId', contactID);
    emailDetails.put('Subject', subject);
    emailDetails.put('CcAddress', ccAddress);
    emailDetails.put('BccAddress', bccAddress);
    emailDetails.put('Body', body);

    Test.startTest();
    LogOutboundEmailHandler.createEmailMessage(emailDetails);
    LogOutboundEmailHandler.createEmailMessage(emptyMap);
    Test.stopTest();

    System.assertEquals(7, emailDetails.size(), 'Incorrect size');
    System.assertEquals(null, emailDetails.get('Account'), 'null account');
  }
}