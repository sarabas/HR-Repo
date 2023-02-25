public class SendBalanceMail {
  public static void balanceMail(String accName, String contName, Decimal bal) {
//    public  void balanceMail(String accName, String contName, Decimal bal) {
    String contactName = contName;
    System.debug('Billable Contact  ' + contName);
    //fetch email
    Contact c = [SELECT Email FROM Contact WHERE Name = :contName];
    String contEmail = c.Email;
    String subject = 'Thank you for your payment!';
    String body;
    String ccAddress = '';
    String bccAddress = '';
    String accID;
    String contactID;

    if (accName == 'Candidate Pool') {
      contactName = contName;
    } else {
      contactName = accName;
    }
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //mail.setToAddresses(new String[] {'paulawambui@gmail.com'});
    //mail.setToAddresses(new String[] {'mracctbook2020@gmail.com','paulawambui@gmail.com'});
    mail.setToAddresses(new List<String>{ contEmail });
    mail.setSubject(subject);
    String messageBody =
      '<html><body> Dear ' +
      contactName +
      ',<br/><br/> We have successfully processed your payment.<br/> <br/>Your remaining balance is ' +
      bal +
      '.<br/><br/> Thank you for your business! <br/><br/> Mom Relaunch</body>  </html>';
    String messageBody2 =
      '<html><body> Dear ' +
      contactName +
      ',<br/><br/> We have successfully processed your payment.<br/>  <br/> Thank you for your business! <br/><br/> Mom Relaunch</body>  </html>';

    if (bal > 0) {
      mail.setHtmlBody(messageBody);
      body = messageBody;
    } else {
      mail.setHtmlBody(messageBody2);
      body = messageBody2;
    }

    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });

    //=========================================================================
    //Create email message details for logging purposes

    Map<String,String> emailDetails = new Map<String,String>();

    List<Account> accDetails = [SELECT Id, (SELECT Id FROM Contacts WHERE name = :contName) FROM Account WHERE Name = :accName];

    for(Account a : accDetails){
      accID = a.Id;
      for(Contact cont: a.Contacts){
        contactID = cont.Id;
      }
    }

   System.debug('Account id ' + accID);
   System.debug('contact Id ' + contactID);
   
   emailDetails.put('AccountID', accID);
   emailDetails.put('Mail', contEmail);
   emailDetails.put('ContactID', contactID);
   emailDetails.put('Subject', subject);
   emailDetails.put('CcAddress', ccAddress);
   emailDetails.put('BccAddress', bccAddress);
   emailDetails.put('Body', body);

   LogOutboundEmailHandler.createEmailMessage(emailDetails);

  }
}