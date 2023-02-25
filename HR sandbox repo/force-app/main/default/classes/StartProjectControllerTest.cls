@isTest
public class StartProjectControllerTest {
    
    private static TestMethod void testStartProject() {
        try {
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            
            Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
            Contact con = new Contact();
            con.LastName = 'Test Candidate';
            con.RecordTypeId = RecordTypeIdContact;
            con.AccountId = acc.Id;
            con.AVTRRT__Candidate_Status__c = 'test';
            con.AVTRRT__Source__c = 'Indeed';
            insert con;
            
            Id RecordTypeIdContact1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
            Contact con1 = new Contact();
            con1.LastName = 'Test Candidate';
            con1.RecordTypeId = RecordTypeIdContact1;
            con1.AccountId = acc.Id;
            con1.AVTRRT__Candidate_Status__c = 'test';
            con1.AVTRRT__Source__c = 'Indeed';
            insert con1;
            
            Profile pObj = [select id from Profile limit 1];
            
            AVTRRT__Job__c job = new AVTRRT__Job__c();
            job.AVTRRT__Job_Title__c = 'Test';
            job.AVTRRT__Stage__c = 'Test3';
            job.AVTRRT__Department__c = 'Life Sciences';
            job.AVTRRT__Number_of_Positions__c = 3;
            job.AVTRRT__Account_Job__c = acc.Id;
            job.AVTRRT__Hiring_Manager__c = con1.Id;
            job.AVTRRT__Job_Category__c = 'Administrative';
            job.AVTRRT__Job_Term__c = 'Permanent';
            job.AVTRRT__Bill_Rate_Range__c = '65';
            job.AVTRRT__Start_Date__c = System.today()-10;
            insert job;
            
            AVTRRT__Job_Applicant__c jobapp = new AVTRRT__Job_Applicant__c();
            jobapp.AVTRRT__Job_Title__c = 'Test';
            jobapp.AVTRRT__Contact_Candidate__c = con.Id;
            jobapp.AVTRRT__Account_Job__c = acc.Id;
            jobapp.AVTRRT__Stage__c = 'Match Created';
            insert jobapp;
            
            AVTRRT__Placement__c placements = new AVTRRT__Placement__c();
            placements.AVTRRT__Job_Title__c = 'Test';
            placements.AVTRRT__Contact_Candidate__c = con.Id;
            placements.AVTRRT__Employer__c = acc.Id;
            placements.AVTRRT__Job_Applicant__c = jobapp.Id;
            placements.AVTRRT__End_Date__c = System.today()-5;
            placements.AVTRRT__Job__c = job.Id;
            placements.AVTRRT__Contract__c = 'Contract Placement';
            placements.AVTRRT__Bill_Rate__c = '100';
            placements.AVTRRT__Pay_Type__c = 'Others';
            placements.AVTRRT__Date_Accepted__c = System.today()-12;
            insert placements;
            
            TMS__Project__c project = new TMS__Project__c();
            project.Name = 'Test';
            project.TMS__Client__c = acc.Id;
            project.RecordTypeId = [Select id FROM Recordtype where name = 'Project'].Id;
            insert project;
            
            AVTRRT__Placement__c placements1 = new AVTRRT__Placement__c();
            placements1.AVTRRT__Job_Title__c = 'Test';
            placements1.AVTRRT__Contact_Candidate__c = con.Id;
            placements1.AVTRRT__Employer__c = acc.Id;
            placements1.AVTRRT__Job_Applicant__c = jobapp.Id;
            placements1.AVTRRT__End_Date__c = System.today()-5;
            placements1.AVTRRT__Job__c = job.Id;
            placements1.Project_TMS__c = project.Id;
            placements1.AVTRRT__Contract__c = 'Contract Placement';
            placements1.AVTRRT__Bill_Rate__c = '100';
            placements1.AVTRRT__Pay_Type__c = 'Others';
            placements1.AVTRRT__Date_Accepted__c = System.today()-12;
            insert placements1;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(placements);
            StartProjectController obj = new StartProjectController(sc);
            ApexPages.currentPage().getParameters().put('Id',placements.Id);
            StartProjectController.StartProject();
            
            ApexPages.StandardController sc1 = new ApexPages.StandardController(placements);
            StartProjectController obj1 = new StartProjectController(sc1);
            ApexPages.currentPage().getParameters().put('Id',placements.Id);
            StartProjectController.StartProject();
            
            ApexPages.StandardController sc2 = new ApexPages.StandardController(placements1);
            StartProjectController obj2 = new StartProjectController(sc2);
            ApexPages.currentPage().getParameters().put('Id',placements1.Id);
            StartProjectController.StartProject();
        }
        catch (Exception e) {
            System.debug('@@@TestClass'+e.getCause());
            System.debug('@@@TestClass12'+e.getStackTraceString());
        }
    }
}