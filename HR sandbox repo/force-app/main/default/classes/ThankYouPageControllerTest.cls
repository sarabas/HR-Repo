@isTest
private class ThankYouPageControllerTest {
    public static Assessment__c a;
    public static Contact c;
    public Date ConfirmedAssessmentDate {get;set;}
    
    @testSetup static void setup() {
         	//create a new assessment record
        a = new Assessment__c();
        a.Career_Assessment_Date__c = System.Date.today();
        a.Career_Assessment_Taken_By__c = 'Reena Gupta';
        insert a;
        c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'User';
        c.Date_Registered_For_Candidate_Assesment__c=Date.valueOf('2020-11-16 00:00:00');
        c.Career_Assessment__c = a.Id;
        c.Highest_Degree__c = 'Post Graduate';
        //c.Name='Test User';
        insert c;
       
    }
    
     @isTest 
    static void fetchDetailsTest() {
        test.startTest();
          Contact testContact = [Select id,Name,FirstName,LastName,Date_Registered_For_Candidate_Assesment__c from Contact where Name='Test User'];
       
        PageReference pageRef = Page.ThankYouPage;
        pageRef.getParameters().put('cId',testContact.Id);
        Test.setCurrentPage(pageRef);
        
         System.debug('testContact in ThankYouPage Testclass :'+testContact);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testContact);
        ThankYouPageController typctrl = new ThankYouPageController(controller);
        ThankYouPageController returnedTypctrl = typctrl.fetchDetails();
        
        System.debug('returned typctrl in Testclass :'+typctrl);
        System.debug('Name in Testclass :'+typctrl.name);
		System.debug('ConfirmedAssessmentDate in Testclass :'+String.valueOf(typctrl.ConfirmedAssessmentDate));
        
        System.assertEquals('Test User', typctrl.name);
        System.assertEquals('2020-11-16',String.valueOf(typctrl.ConfirmedAssessmentDate));
        
        test.stopTest();
    }
}