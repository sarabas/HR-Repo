@isTest
public class XMLFeedControllerTest {

    public static testMethod void test() {
        addJobs();
        XMLFeedController controller = new XMLFeedController();
        controller.xmlFeed();     
    }    
    
    private static void addJobs() {
        Account account = new Account();
        account.Name = 'Job Account';
        insert account;
        
        User u = new User(
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
        LastName = 'last',
        Email = 'test@gmail.com',
        Phone = '1234567890',
        Username = 'test@gmail.com' + System.currentTimeMillis(),
        CompanyName = 'Jordan Search Consultants',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        //UserRoleId = r.Id
        );
        insert u;
    
        AVTRRT__Job__c job = new AVTRRT__Job__c();
        job.AVTRRT__Job_Board_City__c = 'Nashville';
        job.AVTRRT__State__c = 'Tennessee=TN';
        job.AVTRRT__Job_Postal_Code__c = '37030';
        job.AVTRRT__Job_Country__c = 'US=US';
        job.AVTRRT__Job_Description_Rich__c = 'The best job ever';
        job.AVTRRT__Job_Description__c = 'description';
      //  job.AVTRRT__Job_Publish_Tiny_Url__c = 'job.com';
        job.AVTRRT__Recruiter__c = u.Id;
        job.AVTRRT__Account_Job__c = account.id;
        job.AVTRRT__Job_Category__c = 'Computers,Other';
        job.AVTRRT__Stage__c = 'Open';
        job.AVTRRT__Publish__c = true;
        job.AVTRRT__Job_Title__c = 'Test';
        job.AVTRRT__Job_State__c = 'AL';
       // job.AVTRRT__Job_Application_Tiny_URL__c = 'http://test';
        insert job;
    }
    
}