public without sharing class LeadMgmt {
    //public Id rowId{get;set;}
    //public String jobTitle{get;set;}
   // public String jobLink{get;set;}
    //public Date submittedDate{get;set;}
    //public String jobStatus{get;set;}    
    //public String tabOpt{get;set;}
    public boolean contactFound{get;set;}
    public String contactId{get;set;}
     public string sessionId {get;set;}
    public String candName{get;set;}
    public List<Contact> contactName{get;set;}
    public List<Lead> jobLeads = new List<Lead>{};
    public List<Lead> jobLeads1 = new List<Lead>{};
    public string selectedTab{get;set;}

    public LeadMgmt(ApexPages.StandardController controller)
    {
        jobLeads.clear();
        contactFound = false;
        /*String headerData = ApexPages.currentPage().getHeaders().get('Host');
        String urlValue = Apexpages.currentPage().getUrl();
        System.debug('Header: ' +headerData);
        System.debug('URL: ' +urlValue);
        System.debug('URL1'); */
        
        
        contactId = Apexpages.currentpage().getparameters().get('cId');
        System.debug('Contact Id: ' +contactId);
        
          sessionId =  apexpages.currentpage().getparameters().get('sessionId');

      System.debug('Session id is -> ' + sessionId + ' and ContactId is -> ' + contactId);

      If(contactId == null) {
          If(sessionId != null) {
            List<FCMS__Session__c> mySession = [SELECT FCMS__Session_For__c
                                    FROM FCMS__Session__c where FCMS__SessionId__c =:sessionId];
            //if (mySession.size() > 0) - Do this later
            contactId = mySession[0].FCMS__Session_For__c;

            System.debug('contactId derived from sessionId(' + sessionId + ') is -> ' + contactId);
         }
      }

        
        
        
        
    /*    String str = URL.getCurrentRequestUrl().toExternalform();
         System.debug('URL: ' +str); */
        
        If(contactId != null){
            contactFound = true;
            contactName = [SELECT Name FROM Contact where Id = :contactId LIMIT 1];
            candName = contactName[0].Name;
            /*System.debug('Contact Name: ' +contactName);
            System.debug('Candidate Name: ' +candName);*/
        }
        
    } 
    
    public List<Lead> getJobLeads()   {
        //jobLeads.clear();
       selectedTab = 'AppliedJobs';
        System.debug('Method;; getJobLeads');
        if(candName != null)
        {
            System.debug('inside the condition;; getJobLeads ' + candName);
             jobLeads = [SELECT  Job_Title__c, Job_Link__c, Date_Resume_Submitted__c, Status FROM Lead WHERE Lead_Generator__c = :candName AND Interested_For_Applying_Job__c != 'Sharing a Job Posting' ORDER BY Date_Resume_Submitted__c DESC];
            
         }
        System.debug('Job Leads: ' + jobLeads);
        return jobLeads;
    } 
     public List<Lead> getJobLeads1()   {
        //jobLeads.clear();
       
        
            
            jobLeads1 = [SELECT  name,Job_Title__c, Job_Link__c, Date_Resume_Submitted__c, Status FROM Lead  where oktoshare__c=true];
            
         
        return jobLeads1;
    } 
    public String getWebToLeadURL() {
        LeadMgmtConfigSetting__c mc = LeadMgmtConfigSetting__c.getOrgDefaults();
        String webToLeadURL = mc.Web_To_Lead_URL__c;
        System.debug(webToLeadURL);
        if(String.isBlank(webToLeadURL)){
            return null;
        }
        return webToLeadURL;
    }
    
    public String getReturnURL(){
        if(contactId == null){
            return null;
        }
        LeadMgmtConfigSetting__c mc = LeadMgmtConfigSetting__c.getOrgDefaults();
        String returnURL = mc.Return_URL__c;
        System.debug(returnURL);
        if(String.isBlank(returnURL)){
            return null;
        }
        return returnURL + contactId;
    }
    
    public String getOrganizationId(){
        if(contactId == null){
            return null;
        } 
        LeadMgmtConfigSetting__c mc = LeadMgmtConfigSetting__c.getOrgDefaults();
        String orgId = mc.Organization_Id__c;
        System.debug(orgId);
        if(String.isBlank(orgId)){
            return null;
        }
        return orgId;
    }
}