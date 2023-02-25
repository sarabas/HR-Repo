public without sharing class RequestedProjects {

   
  List<RequestedProjectsPL__c> RP{get;set;}
  public string  selPrjId{get;set;}
  // public string selPrjLeadId{get;set;}
  public string contactId {get;set;} 
  // public string candFirstName{get;set;}
  // public string candEmail {get;set;}
  // public string candName {get;set;}
  // public string projectLead {get;set;}
  // public string candSkillset {get;set;}
  // public string projectLeadName {get;set;}
  // public string projectName {get;set;}
  public string selCandidateId {get;set;} 
 
  //Constructor
  Public RequestedProjects(ApexPages.StandardController controller){ 
     
       
     //Initialize from Link parameters
     contactId =  apexpages.currentpage().getparameters().get('cId');
     System.Debug('-- Inside constructor contactId: ' + contactId);
    /*  if (contactId == null) {
       contactId = '0033u000018BvIDAA0'; //HardCoding Mansi's id for debugging.
      }*/
   
      
  }
 //Populate Candidate Requested Projects
 
   public List<RequestedProjectsPL__c>  getCandidateInternalProjects() {
     System.Debug('-- Inside method contactId: ' + contactId);
     RP = [SELECT Project__r.Id, Project__r.Name, RequesterContact__r.Name, Project__r.Project_Lead__c,RequesterContact__r.AVTRRT__AutoPopulate_Skillset__c 
                                     FROM RequestedProjectsPL__c 
                                     where Project__r.Project_Lead__c = :contactId
                                     AND Project__r.TMS__Client__r.Name = 'Mom Relaunch'];      
              
       System.Debug('List count = ' + RP.size());
       return RP;
   }

   public List<RequestedProjectsPL__c>      getCandidateOpenProjects() {
     RP  = [SELECT Project__r.Id, Project__r.Name, RequesterContact__r.Name, Project__r.Project_Lead__c,RequesterContact__r.AVTRRT__AutoPopulate_Skillset__c 
                                      FROM RequestedProjectsPL__c 
                                      where Project__r.Project_Lead__c = :contactId 
                                      AND Project__r.TMS__Client__r.Name != 'Mom Relaunch'
                                      AND Project__r.TMS__Billable__c = false];      
               
        System.Debug('List count = ' + RP.size());
        return RP;
   }
   
    
   
   public void sendApproveEmail() {
     sendEmail('Project_Approved');
     

   }    

   public void sendRejectEmail() {
     sendEmail('Project_Rejected');
    
   }    

   public void sendEmail(String templateName){
     String EmailBody,Subject;
     Contact prjLead;
     Contact InterestedCandidate;
     String prjLeadEmail;
   
     // You don't need to set selPrjId, selCandidateId  explicityly since it will be set by the vfp page 
      
     System.Debug(LoggingLevel.INFO,'--> Inside sendEmail:selPrjId =  ' + selPrjId);
     System.Debug(LoggingLevel.INFO,'--> Inside sendEmail:selCandidateId =  ' + selCandidateId);
     
     //Fetch Email Template Id to be send to Candidate and Project Lead                                        
      List<EmailTemplate> emailTemplateIds = [SELECT Id,Subject,Body
                                              FROM EmailTemplate
                                              WHERE DeveloperName =:templateName  LIMIT 1];                                     
     
     //Fetch the Project name
     TMS__Project__c SelectedProject =[SELECT Id,Name,Project_Lead__r.Name
                                             FROM TMS__Project__c 
                                             WHERE ID =:selPrjId 
                                             LIMIT 1];

     //Fetch the Candidate Details
     InterestedCandidate = [SELECT Id,FirstName,Name,Email 
                                         FROM Contact 
                                         WHERE id=:selCandidateId 
                                         LIMIT 1];
           
     //New instance of a single email message sent to candidate
    Messaging.SingleEmailMessage emailCand = new Messaging.SingleEmailMessage();
    List<String> canEmailList = new List<String>();
    List<String> prjLeadEmailList = new List<String>();
     
     //Fetch the Candidate details
     If(contactId != null){
          
           EmailBody = emailTemplateIds.get(0).Body;
           If(EmailBody !=null){
             EmailBody = EmailBody.replace('Candidate',InterestedCandidate.Name);
             EmailBody = EmailBody.replace('project', SelectedProject.Name);                        
             EmailBody = EmailBody.replace('lead',SelectedProject.Project_Lead__r.Name);
            
            //PMO user id: F0051Q00000GnNgI
            //HR User id:F0053600000857L9
             
            }
           
            MR_Project_Lead_Setting_mdt__mdt PrjListMetaDataPMO = [SELECT PMO_email__c
                                                               FROM MR_Project_Lead_Setting_mdt__mdt
                                                               WHERE DeveloperName = 'PMO_Details'
                                                               LIMIT 1];
           
            MR_Project_Lead__mdt  PrjListMetaDataHR =  [SELECT HR_email__c
                                                          FROM MR_Project_Lead__mdt
                                                          WHERE DeveloperName = 'HR_Details'
                                                          LIMIT 1];
           String[] toAddresses =   new String[] {InterestedCandidate.Email,PrjListMetaDataPMO.PMO_email__c, PrjListMetaDataHR.HR_email__c};
           System.debug('PK: --------> To Addresses :' + toAddresses);                                       
           emailCand.setToAddresses(toAddresses);
           emailCand.setTargetObjectId(contactId);
           Subject = emailTemplateIds[0].Subject;
           emailCand.setSubject(Subject); 
           emailCand.setPlainTextBody(EmailBody);
           // try{            
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailCand });
               system.debug('Candidate,HR and PMO Email Sent Successfully');
           /*    }  catch(exception e){
                   system.debug('Error email');
                   apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
                   system.debug('Error Sending Email '+e.getMessage());
               } */
       
     }


       //PK: Delete the record on Requested Project page once it's Approved/Rejected by Project Leads.
       RequestedProjectsPL__c[] detachRequestedProjects = [select Id, Name from RequestedProjectsPL__c
                          WHERE RequesterContact__c =:selCandidateId AND  Project__C = :selPrjId ];
       // try {
           system.debug('Size of the deleted Object=' + detachRequestedProjects.size());
           delete detachRequestedProjects;
       /* } catch (DmlException e) {
           // Process exception here
           system.debug(' ---> Exception occured ===' + e);
       } */

     
       
       
       /*Remove Requested project from "My Requested Projects" tab from the Project List page,
        once the PL rejects/approves the project */

       apexpages.currentpage().getparameters().put('cId',selCandidateId);
       ApexPages.StandardController controller1 = new ApexPages.StandardController(new TMS__Project__c());
       ProjectsList prjList = new ProjectsList(controller1);

       prjList.removePrjName = SelectedProject.Name;
       prjList.removeProjectInterest();
       
       
   }  
           
     
  
   
   
}