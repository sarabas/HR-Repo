@isTest
private class CARControllerTest {
    public static Assessment__c a;
    public static Contact c;
    public static CARController carCtrl;
    public static Date selectedAssessmentDate {get;set;}
    public static Id selectedAssessmentId {get;set;}
    
     @testSetup static void setup() {
            //create a new assessment record
        a = new Assessment__c();
        a.Career_Assessment_Date__c = System.Date.today();
        a.Career_Assessment_Taken_By__c = 'Reena Gupta';
        insert a;
        c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'User';
        c.Career_Assessment__c = a.Id;
         c.Highest_Degree__c = 'Post Graduate';
        //c.Name='Test User';
        insert c;
        
       
    }
 
    
    @isTest static void getAssessmentsTest() {
        
        test.startTest();
      
       // System.debug('in getAssessments c.Id :'+c.Id);
        Contact testContact = [Select id,Name,FirstName,LastName from Contact where FirstName='Test'];
        
        System.debug('testContact :'+testContact);
        System.debug('testContact Id:'+testContact.Id);
        PageReference pageRef = Page.DesignForm;
        pageRef.getParameters().put('cId',testContact.Id);
        Test.setCurrentPage(pageRef);
        
         ApexPages.StandardController controller = new ApexPages.StandardController(testContact);
        carCtrl = new CARController(controller);
        carCtrl.candidateName='';
        carCtrl.assessment=a;
        
        List<Assessment__C> asstList = carCtrl.getAssessments();
        
        System.debug('asstList.size : '+asstList.size());
        System.debug('asstList : '+asstList);
        System.assert(asstList.size()==1);
        System.assertEquals('Test User', asstList.get(0).Candidates__r.get(0).Name);
        
        test.stopTest();
    }
    
    
    @isTest 
    static void saveRecord() {
        test.startTest();
          Contact testContact = [Select id,Name,FirstName,LastName,Date_Registered_For_Candidate_Assesment__c from Contact where Name='Test User'];
       
        PageReference pageRef = Page.ThankYouPage;
        pageRef.getParameters().put('cId',testContact.Id);
        Test.setCurrentPage(pageRef);
        
        Date todaysDate = System.Date.today();
        a = [SELECT Id from Assessment__c where Career_Assessment_Date__c=:todaysDate limit 1];
        
         System.debug('assessment object before save :'+a);
         System.debug('testContact in saveRecord method :'+testContact);
        
         ApexPages.StandardController controller = new ApexPages.StandardController(testContact);
        carCtrl = new CARController(controller);
        carCtrl.selectedAssessmentDate=Date.valueOf('2019-11-16 00:00:00');
        carCtrl.selectedAssessmentId=a.Id;
        
        carCtrl.saveRecord();
        
        Contact con = [SELECT Id,Date_Registered_For_Candidate_Assesment__c,Career_Assessment__c from Contact limit 1];
        
         System.debug('contact object after save :'+con);
        System.debug('contact object Date_Registered_For_Candidate_Assesment__c :'+con.Date_Registered_For_Candidate_Assesment__c);
        Date assmtDate = con.Date_Registered_For_Candidate_Assesment__c;
         System.debug('selectedAssessmentDate in Testclass :'+carCtrl.selectedAssessmentDate);
        System.debug('assessment date on contact object after save :'+String.valueOf(assmtDate));
        System.assertEquals('2019-11-16',String.valueOf(con.Date_Registered_For_Candidate_Assesment__c));
        
        test.stopTest();
    }
    
    @isTest 
    static void assessmentDateNull() {
        test.startTest();
          Contact testContact = [Select id,Name,FirstName,LastName,Date_Registered_For_Candidate_Assesment__c from Contact where FirstName='Test'];
       
        PageReference pageRef = Page.ErrorPage;
        pageRef.getParameters().put('cId',testContact.Id);
        Test.setCurrentPage(pageRef);
        
        Date todaysDate = System.Date.today();
        a = [SELECT Id from Assessment__c where Career_Assessment_Date__c=:todaysDate limit 1];
        
         System.debug('assessment object before save :'+a);
         System.debug('testContact in saveRecord method :'+testContact);
        
         ApexPages.StandardController controller = new ApexPages.StandardController(testContact);
        carCtrl = new CARController(controller);
        carCtrl.selectedAssessmentDate=null;
        carCtrl.selectedAssessmentId=a.Id;
        
        carCtrl.saveRecord();
        
    /*    Contact con = [SELECT Id,Date_Registered_For_Candidate_Assesment__c,Career_Assessment__c from Contact limit 1];
        
         System.debug('contact object after save :'+con);
        System.debug('contact object Date_Registered_For_Candidate_Assesment__c :'+con.Date_Registered_For_Candidate_Assesment__c);
        Date assmtDate = con.Date_Registered_For_Candidate_Assesment__c;
         System.debug('selectedAssessmentDate in Testclass :'+carCtrl.selectedAssessmentDate);
        System.debug('assessment date on contact object after save :'+String.valueOf(assmtDate));*/
//      System.assert(condition);
        
        test.stopTest();
    }
}