@IsTest
public class TestTimesheetPortalDetForMom {
    
    static testMethod void testInsertCandidateDetail(){
        
        AVTRRT__Config_Settings__c settings =new AVTRRT__Config_Settings__c();
        settings.name='Default';
        settings.Disable_PopulateTimeSheetPortalDet__c=false;
        //  settings.AVTRRT__Trigger_Placement__c = true;
        AVTRRT__ConfigSettingsHierarchy__c settings1 =	AVTRRT__ConfigSettingsHierarchy__c.getInstance();
        settings1.AVTRRT__Opportunity_Stage_for_Placement_Creation__c ='Prospecting';
        
        
        FCMS__CMSProfile__c profile = new FCMS__CMSProfile__c(FCMS__Name__c='Timesheet Employee');
        
        AVTRRT__Config__c cnfg = new  AVTRRT__Config__c();
        cnfg.AVTRRT__Name__c ='Close Job on Placement';
        cnfg.AVTRRT__Value__c='Close Job on Placement';
        Account accnt = new Account(Name='TestAccount');
        Test.startTest();
        insert settings;
        insert settings1;
        insert cnfg;
        insert profile;
        
        insert accnt;
        
        Account accnt1 = new Account(Name='TestAccountval');
        insert accnt1;
        
        Opportunity  opp = new  Opportunity();
        opp.Name='Opp1';
        opp.account=accnt1;
        opp.StageName='Prospecting';
        opp.CloseDate = Date.today();
        
        insert opp;
        
        Contact cnt = new Contact();
        cnt.LastName = 'Elise';
        cnt.AccountId=accnt.Id;
        cnt.Email='elise@gmail.com';
        cnt.FCMS__CMSProfile__c=profile.Id;
        cnt.FCMS__Job_Site__c='Default';
        insert cnt;
        
        AVTRRT__Job__c job = new AVTRRT__Job__c();
       job.AVTRRT__Job_Title__c ='TesttR Job';
        job.AVTRRT__Account_Job__c =accnt.Id;
        job.AVTRRT__Opportunity__c = opp.Id;
        
        insert job;
        
        opp.AVTRRT__Job__c = job.Id;
        update opp;
        
        AVTRRT__Job_Applicant__c appln = new AVTRRT__Job_Applicant__c();
        appln.AVTRRT__Contact_Candidate__c = cnt.Id;
        appln.AVTRRT__Job__c = job.id;
        
        insert appln;
        
        AVTRRT__Interview__c inter = new AVTRRT__Interview__c();
        inter.AVTRRT__Type_Of_Interview__c ='Phone';
        
        insert inter;
        
        AVTRRT__Placement__c placement = new AVTRRT__Placement__c();
        placement.AVTRRT__Employer__c=accnt.id;
        placement.AVTRRT__Hiring_Manager__c=job.AVTRRT__Hiring_Manager__c;
        placement.AVTRRT__Account_Manager__c=job.AVTRRT__Account_Manager__c;
        placement.AVTRRT__Account_Manager_Email__c = job.AVTRRT__Account_Manager__r.Email;
        placement.AVTRRT__Assigned_Recruiter__c=job.AVTRRT__Recruiter__c;
        placement.AVTRRT__Assigned_Recruiter_Email__c=job.AVTRRT__Recruiter__r.Email;
        
        placement.AVTRRT__Start_Date__c =Date.newInstance(2018,12,9);
        placement.AVTRRT__Contact_Candidate__c = cnt.Id;
        placement.AVTRRT__No_Of_Days_Taken__c  =7;      
        placement.AVTRRT__Job__c = job.Id;
        
        

        insert placement;
        
        
        TMS__Project__c proj = new TMS__Project__c();
        
        proj.TMS__Client__c = accnt.Id;
        proj.TMS__Opportunity__c=opp.id;
        proj.TMS__Start_Date__c =Date.today();
        insert proj;

		placement.Project_TMS__c = proj.Id;
        update placement;
        Test.stopTest();
    }
}