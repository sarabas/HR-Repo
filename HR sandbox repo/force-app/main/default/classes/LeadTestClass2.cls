@isTest 
public class LeadTestClass2 {
    static LeadMgmt leadMgmt;
    public static void setup(Contact con){
        if(con != null){
        	PageReference pageRef = Page.DesignForm;
        	pageRef.getParameters().put('cId',con.Id);
        	Test.setCurrentPage(pageRef);
        }
        ApexPages.StandardController controller = new ApexPages.StandardController(new Lead());
        leadMgmt = new LeadMgmt(controller);
        
    }
    @isTest
    static void ifCandNameNotExistThenReturnEmptyList(){
        setup(null);
        
        List<Lead> leads = leadMgmt.getJobLeads();
        
       	System.assertEquals(0, leads.size());
    }
    @isTest
    static void ifCandNameIsExistAndInterestForJobIsSharingThenReturnEmptyList(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi', Email = 'arohi.modi@yahoo.com');
        insert con;
        setup(con);
        Contact getContact = [SELECT Id from Contact Where LastName = 'Modi' and FirstName = 'Arohi' and Email = 'arohi.modi@yahoo.com'];
        
        Lead lead = new Lead(FirstName = 'Arohi', LastName = 'Modi', Email = 'arohi.modi@yahoo.com', Company = 'Test', Job_Title__c = 'SFDC Developer', Job_Link__c = 'www.linkedin.com', Date_Resume_Submitted__c = date.parse('11/30/2020'), Status = 'Open', Interested_For_Applying_Job__c = 'Sharing a Job Posting',  Lead_Generator__c = 'Arohi Modi');
        lead.Referred_by_Mom__c = getContact.Id;
        insert lead;
        
        List<Lead> leads = leadMgmt.getJobLeads();
        
       	System.assertEquals(0, leads.size());
    }
    @isTest
    static void ifCandNameIsExistAndInterestForJobIsNotSharingThenReturnListWithOneRecord(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi', Email = 'arohi.modi@yahoo.com');
        insert con;
        setup(con);
        Contact getContact = [SELECT Id from Contact Where LastName = 'Modi' and FirstName = 'Arohi' and Email = 'arohi.modi@yahoo.com'];
        Lead lead = new Lead(FirstName = 'Arohi', LastName = 'Modi', Email = 'arohi.modi@yahoo.com', Company = 'Test', Job_Title__c = 'SFDC Developer', Job_Link__c = 'www.linkedin.com', Date_Resume_Submitted__c = date.parse('11/30/2020'), Status = 'Open', Interested_For_Applying_Job__c = 'Applied',  Lead_Generator__c = 'Arohi Modi');
          lead.Referred_by_Mom__c = getContact.Id;
        insert lead;
        
        List<Lead> leads = leadMgmt.getJobLeads();
        
       	System.assertEquals(1, leads.size());
    }
    @isTest
    static void ifCandNameExistAndInterestForJobIsNotSharingThenReturnListWithMultipleRecords(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi', Email = 'arohi.modi@yahoo.com');
        insert con;
        setup(con);
        Contact getContact = [SELECT Id from Contact Where LastName = 'Modi' and FirstName = 'Arohi' and Email = 'arohi.modi@yahoo.com'];
        Lead lead1 = new Lead(FirstName = 'Arohi', LastName = 'Modi', Email = 'arohi.modi@yahoo.com', Company = 'Test', Job_Title__c = 'SFDC Developer', Job_Link__c = 'www.linkedin.com', Date_Resume_Submitted__c = date.parse('11/30/2020'), Status = 'Open', Interested_For_Applying_Job__c = 'Applied',  Lead_Generator__c = 'Arohi Modi');
        lead1.Referred_by_Mom__c = getContact.Id;
        insert lead1;
        Lead lead2 = new Lead(FirstName = 'Arohi', LastName = 'Modi', Email = 'test@test.com', Company = 'Test', Job_Title__c = 'SFDC Developer', Job_Link__c = 'www.linkedin.com', Date_Resume_Submitted__c = date.parse('11/30/2020'), Status = 'Open', Interested_For_Applying_Job__c = 'Applied',  Lead_Generator__c = 'Arohi Modi');
        lead2.Referred_by_Mom__c = getContact.Id;
        insert lead2;
        
        List<Lead> leads = leadMgmt.getJobLeads();
        
       	System.assertEquals(2, leads.size());
    }
    @isTest
    static void ifCandNameExistAndInterestForJobIsNotSharingThenReturnListWithMultipleRecordsAndDateIsDesc(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi', Email = 'arohi.modi@yahoo.com');
        insert con;
        setup(con);
        Contact getContact = [SELECT Id from Contact Where LastName = 'Modi' and FirstName = 'Arohi' and Email = 'arohi.modi@yahoo.com'];
        Lead lead1 = new Lead(FirstName = 'Arohi', LastName = 'Modi', Email = 'arohi.modi@yahoo.com', Company = 'Test', Job_Title__c = 'SFDC Developer', Job_Link__c = 'www.linkedin.com', Date_Resume_Submitted__c = date.parse('11/01/2020'), Status = 'Open', Interested_For_Applying_Job__c = 'Applied',  Lead_Generator__c = 'Arohi Modi');
        lead1.Referred_by_Mom__c = getContact.Id;
        insert lead1;
        Lead lead2 = new Lead(FirstName = 'Arohi', LastName = 'Modi', Email = 'test@test.com', Company = 'Test', Job_Title__c = 'SFDC Developer', Job_Link__c = 'www.linkedin.com', Date_Resume_Submitted__c = date.parse('12/01/2020'), Status = 'Open', Interested_For_Applying_Job__c = 'Applied',  Lead_Generator__c = 'Arohi Modi');
        lead2.Referred_by_Mom__c = getContact.Id;
        insert lead2;
        
        List<Lead> leads = leadMgmt.getJobLeads();
        
       	System.assertEquals(lead2.Id, leads.get(0).Id);
    }
   
    @isTest
    static void ifContactIdIsNULLThenReturnNull(){
        setup(null);
        String url = leadMgmt.getReturnURL();
      	System.assert(String.isBlank(url));
    }
    @isTest
    static void ifContactIdExistAndReturnURLExistThenReturnURL(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi');
        insert con;
        setup(con);
      	LeadMgmtConfigSetting__c  setting = new LeadMgmtConfigSetting__c();
        setting.Name = 'Test Setting';
        //setting.Return_URL__c  = 'https://www.google.com?';
        setting.Return_URL__c  = 'https://www.google.com?cId=';
        setting.Web_To_Lead_URL__c = 'https://www.test.com';
        insert setting;
        
        String url = leadMgmt.getReturnURL();
        
        System.assertEquals('https://www.google.com?cId=' + con.Id , url);
	}
    
    @isTest
    static void ifReturnURLNotExistThenReturnNull(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi');
        insert con;
        setup(con);
        
        String url = leadMgmt.getReturnURL();
        
        System.assert(String.isBlank(url));
    }
    
    @isTest
    static void ifURLNotExistThenReturnNull(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi');
        insert con;
        setup(con);
        
        String url = leadMgmt.getWebToLeadURL();
        
        System.assert(String.isBlank(url));
    }
    
    @isTest
    static void ifOrganizationIdNotExistThenReturnNull(){
        contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi');
        insert con;
        setup(con);
        
        String orgId = leadMgmt.getOrganizationId();
        
        System.assert(string.isBlank(orgId));
    }
    
    @isTest
    static void ifContactIdExistAndURLExistThenReturnURL(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi');
        insert con;
        setup(con);
      	LeadMgmtConfigSetting__c  setting = new LeadMgmtConfigSetting__c();
        setting.Name = 'Test Setting';
        setting.Web_To_Lead_URL__c = 'https://www.test.com';
        setting.Return_URL__c = 'https://www.google.com?cId=';
        insert setting;
        
        String url = leadMgmt.getWebToLeadURL();
        
        System.assertEquals('https://www.test.com', url);
	}
    
    @isTest
    static void ifContactIdExistAndURLExistAndReturnURLExistThenReturnURL(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi');
        insert con;
        setup(con);
        LeadMgmtConfigSetting__c setting = new LeadMgmtConfigSetting__c();
        setting.Name = 'Test Setting';
        setting.Web_To_Lead_URL__c = 'https://www.test.com';
        setting.Return_URL__c  = 'https://www.google.com?cId=';
        insert setting;
        
        String url = leadMgmt.getWebToLeadURL();
        
        System.assertEquals('https://www.test.com', url);
    }
    
    @isTest
    static void ifContactIdExistAndURLExistAndReturnURLExistAndOrgIdExistThenReturnURL(){
        Contact con = new Contact(FirstName = 'Arohi', LastName = 'Modi');
        insert con;
        setup(con);
        LeadMgmtConfigSetting__c setting = new LeadMgmtConfigSetting__c();
        setting.Name = 'Test Setting';
        setting.Web_To_Lead_URL__c = 'https://www.test.com';
        setting.Return_URL__c = 'https://www.google.com?cId=';
        setting.Organization_Id__c = '000000000000000';
        insert setting;
        
        String url = leadMgmt.getWebToLeadURL();
        System.assertEquals('https://www.test.com', url);
    }
	
}