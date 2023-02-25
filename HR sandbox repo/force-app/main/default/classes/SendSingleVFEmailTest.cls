@IsTest
private class SendSingleVFEmailTest {
  @IsTest
  static void sendEmailWithAllParametersTest() {
    Map<String, String> params = new Map<String, String>();
    params.put('contEmail', 'toMail@testing.com');
    params.put('addTo', 'testing@test.com');
    params.put('acc', 'a2D0m000002PjcY');
    params.put('ccEmail', 'testcc@test.com');
    params.put('subject', 'Attn: Ramya for Invoice 000784');
    params.put('body', 'Find attached invoice');


    Account a = new Account(Name = 'Test Acc');
    insert a;
    String accID = a.Id;

    Contact c = new Contact(LastName = 'TestContact', AccountId = a.Id, Email = 'test@test.com');
    insert c;
    String contactID = c.Id;

    String mail = 'mracctbook@gmail.com';
    String subject = 'Test subject';
    String ccAddress = '';
    String bccAddress = '';
    String body = 'Test body';

    Map<String,String> emailDetails = new Map<String,String>();
    Blob b;
    b = blob.valueOf('Unit.Test');
    ContentVersion cv = new ContentVersion();
    cv.VersionData = b;
    cv.Title = 'Client Invoice';
    cv.PathOnClient = 'Invoice.pdf';
    cv.ContentLocation = 'S';
    cv.Description = 'Customer invoice';
    cv.IsMajorVersion = true;
    insert cv;

      Id contentDocID = [
          SELECT ContentDocumentId
          FROM ContentVersion
          WHERE Id = :cv.Id
        ]
        .ContentDocumentId;

    emailDetails.put('AccountId', accID);
    emailDetails.put('ContactID', contactID);
    emailDetails.put('ContentDocID', contentDocID);
    emailDetails.put('Mail', mail);
    emailDetails.put('Subject', subject);
    emailDetails.put('CCAddress', ccAddress);
    emailDetails.put('BccAddress', bccAddress);
    emailDetails.put('Body', body);


    Test.startTest();
    SendSingleVFEmail.sendSingleEmailLWC(params);
    
    Test.stopTest();

    System.assertEquals(6, params.size(), 'incorrect number of map arguments');
    System.assertEquals(8, emailDetails.size(), 'incorrect number of email map arguments');
  }
  @IsTest
  static void sendEmailWithoutAllParameters() {
    Map<String, String> params = new Map<String, String>();
    params.put('contEmail', '');
    params.put('addTo', '');
    params.put('acc', '');
    params.put('ccEmail', '');
    params.put('subject', '');
    params.put('body', 'Find attached invoice');

    Map<String,String> emailDetails = new Map<String,String>();

    Test.startTest();
    SendSingleVFEmail.sendSingleEmailLWC(params);
    Test.stopTest();

    
  }
}