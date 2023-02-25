public without sharing class ProjectsList {

   public List<Project> openInternalProjectLst = new List<Project>{};
   public List<Project> openClientProjectLst = new List<Project>{};
   public List<AggregateResult> PrjInternalResourceCnt = new List<AggregateResult>();
   public List<AggregateResult> PrjClientResourceCnt = new List<AggregateResult>();
   public List<String> candRequestedPrjs = new List<String>();
   public List<TMS__Project__c> CandReqstPrjLst = new List<TMS__Project__c>();
   public List<TMS__Project_Resource__c> CandidatePrjs = new List<TMS__Project_Resource__c>();
   public List <TMS__Project_Resource__c> CandidateCopyPrjs = new List<TMS__Project_Resource__c>();
   //Training Profile
   public string candidateProfileName{get;set;}
    public Boolean isTrainingProfile{get;set;}

   public string  selPrjId{get;set;}
   public string  selPrjName{get;set;}
   public string selPrjLeadId{get;set;}
   public string removePrjName{get;set;}
   public boolean candidateFound{get;set;}
   public boolean displayPopup {get; set;}
   public boolean currentInterest {get;set;}
   public boolean prevPendingInterest {get;set;}
   public boolean removeProjInterest{get;set;}
   public boolean leavePrjRequest{get;set;}
   public boolean sameProjName{get;set;}
   public boolean activeProjInterest{get;set;}
   public string contactId {get;set;}
   public string sessionId {get;set;}
   public string candFirstName{get;set;}
   public string candEmail {get;set;}
   public string candName {get;set;}
   public string projectLead {get;set;}
   public string prjLeadOrManager {get;set;}
   public string candProfile {get;set;}

   //Constructor
    Public ProjectsList(ApexPages.StandardController controller){
      candidateFound = false;
      //Initialize from Link parameters
      contactId =  apexpages.currentpage().getparameters().get('cId');
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

      If(contactId != null){
          candidateFound = true;
      List<Contact> Candidate = [SELECT Id,FirstName,Name,Email,FCMS__CMSProfile__c,FCMS__CMSProfile__r.FCMS__Name__c
                                 FROM Contact
                                 WHERE Id =:contactId LIMIT 1];
        candFirstName = Candidate[0].FirstName;
        candEmail =   Candidate[0].Email;
        candName =    Candidate[0].Name;
        candProfile = Candidate[0].FCMS__CMSProfile__c;
          //Candidate Profile Name
          candidateProfileName = Candidate[0].FCMS__CMSProfile__r.FCMS__Name__c;
           System.debug('Candidate Profile: ' + candidateProfileName);
          if(candidateProfileName == 'Training Profile')
              isTrainingProfile =  false;
          else
              isTrainingProfile = true;
       }
    }

   //Wrapper class
  public class Project{

      TMS__Project__c Prj ;
      public Integer ResourceCnt {get;set;}
      public String PrjType {get;set;}

      Project(TMS__Project__c InpPrj){
      Prj = InpPrj;
      }

      public TMS__Project__c getProject(){
      return Prj;
      }

      public String getPrjDetails(){
         String PrjDetails;
         Decimal MaxTeamSize;

         If(Prj.Project_Lead__c == null ){

             If(PrjType =='Client'){
                 If(Prj.Maximum_Team_Size__c == null){
                     MaxTeamSize = 0;
                 }else{
                   MaxTeamSize =  Prj.Maximum_Team_Size__c;
                 }
                 PrjDetails = 'Project Lead: ' + '\n'+ 'Team Size: ' + ResourceCnt + '/' + MaxTeamSize;
             } else {

                 PrjDetails = 'Project Lead: ' + '\n'+ 'Team Size: ' + ResourceCnt;
             }
         }

         if(Prj.Project_Lead__c != null){

             If(PrjType =='Client'){
                 If(Prj.Maximum_Team_Size__c == null){
                     MaxTeamSize = 0;
                 }else{
                   MaxTeamSize =  Prj.Maximum_Team_Size__c;
                 }
               PrjDetails = 'Project Lead: '+ Prj.Project_Lead__r.Name + '\n' + 'Team Size: ' + ResourceCnt + '/'+ MaxTeamSize;
             }  else{

                 PrjDetails = 'Project Lead: '+ Prj.Project_Lead__r.Name + '\n' + 'Team Size: ' + ResourceCnt;
             }
        }
         return PrjDetails;
      }

      //Fetching Project Name for Client Projects
      public string getProjectName(){
        String PrjName;

          //If Resource Count for a Project = Max Count
          If(ResourceCnt == Prj.Maximum_Team_Size__c){
              PrjName = Prj.Name + '\n' + '* Project cannot accomodate more resources';
          }else {
              PrjName = Prj.Name;
          }

          return PrjName;
      }
      //Addding End
  }

 //Populate Internal Projects Tab
 public List<Project> getOpenInternalProjects(){

    //Getting Project RecordType Id
    Id RecTypeIdProject = Schema.SObjectType.TMS__Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
    openInternalProjectLst.clear();
    PrjInternalResourceCnt.clear();

    //Fetching Active Resource Count for all open internal projects
    PrjInternalResourceCnt = [SELECT TMS__Project__c,count(Name)ResCount
                              FROM TMS__Project_Resource__c
                              WHERE Status__c ='Active'
                                   AND TMS__Project__r.TMS__Project_Status__c  ='Open'
                                   AND TMS__Project__r.Launchpad_Project__c = true
                                   AND TMS__Project__r.RecordTypeId = :RecTypeIdProject
                                   AND TMS__Project__r.TMS__Client__r.Name ='Mom Relaunch'
                              GROUP BY TMS__Project__c];

    //Fetching Open Internal Projects and adding to a List of classes
    for(TMS__Project__c openPrj :[SELECT Id,Name,Project_Lead__c,Project_Lead__r.Name,Launchpad_Project__c,Project_Description__c
                                 FROM TMS__Project__c
                                 WHERE TMS__Project_Status__c ='Open'
                                      AND Launchpad_Project__c = true
                                      AND RecordTypeId = :RecTypeIdProject
                                      AND TMS__Client__r.Name ='Mom Relaunch'
                                 ORDER BY name ASC]){

           Project prj = new Project(openPrj ); //for every element create a new Project object
           for (AggregateResult aggr :PrjInternalResourceCnt){
              If (aggr.get('TMS__Project__c') == openPrj.Id){
                   prj.ResourceCnt = (integer)aggr.get('ResCount');
                   break;
              }
           }

           If(prj.ResourceCnt == null){
              prj.ResourceCnt =0;
           }

           //openInternalProjectLst.add(new Project(openPrj ));
           openInternalProjectLst.add(prj);
   }

   return openInternalProjectLst ;
}

    //Populate Client Projects Tab
    public List<Project> getOpenClientProjects(){

         //Getting Project RecordType Id
         Id RecTypeIdProject = Schema.SObjectType.TMS__Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
         openClientProjectLst.clear();
         PrjClientResourceCnt.clear();

         //Fetching Active Resource Count for all open client projects
         PrjClientResourceCnt =   [SELECT TMS__Project__c,count(Name)ResCount
                                   FROM TMS__Project_Resource__c
                                   WHERE Status__c ='Active'
                                      AND TMS__Project__r.TMS__Project_Status__c  ='Open'
                                      AND TMS__Project__r.Launchpad_Project__c = true
                                      AND TMS__Project__r.RecordTypeId = :RecTypeIdProject
                                      AND TMS__Project__r.TMS__Client__r.Name != 'Mom Relaunch'
                                      AND TMS__Project__r.TMS__Billable__c = false
                                   GROUP BY TMS__Project__c];


          //Fetching Open NonBillable Client Projects and adding to a List of classes
          for(TMS__Project__c clientPrj :[SELECT Id,Name,Project_Lead__c,Project_Lead__r.Name,Launchpad_Project__c,
                                          Project_Description__c,Maximum_Team_Size__c
                                          FROM TMS__Project__c
                                          WHERE TMS__Project_Status__c ='Open'
                                               AND Launchpad_Project__c = true
                                               AND RecordTypeId = :RecTypeIdProject
                                               AND TMS__Client__r.Name != 'Mom Relaunch'
                                               AND TMS__Billable__c = false
                                          ORDER BY name ASC]){


                                    Project prj = new Project(clientPrj);
                                    for (AggregateResult aggr :PrjClientResourceCnt){
                                           If (aggr.get('TMS__Project__c') == clientPrj.Id){
                                                 prj.ResourceCnt = (integer)aggr.get('ResCount');
                                                 break;
                                           }
                                    }

                                    If(prj.ResourceCnt == null){
                                         prj.ResourceCnt =0;
                                    }
                                    //Setting project Type as client
                                    prj.PrjType = 'Client';
                                    openClientProjectLst.add(prj);

          }
          return openClientProjectLst ;
    }


    //Populate Candidate Requested Projects
    public List<TMS__Project__c> getCandidateRequestedProjects(){

      CandReqstPrjLst.clear();
      candRequestedPrjs.clear();

        If(contactId !=null){
            Contact Candidate = [SELECT Id,Project_Interested__c
                                 FROM Contact
                                 WHERE Id =:contactId
                                 LIMIT 1];


             If(Candidate.Project_Interested__c !=null){
                 candRequestedPrjs   = Candidate.Project_Interested__c.split(';');
              }
              else{
                   candRequestedPrjs.add('');
              }

        }
         List<TMS__Project__c> CandReqstPrjLst =[SELECT Id,Name,Project_Description__c,Project_Lead__r.Name
                                                 FROM TMS__Project__c
                                                 WHERE Name in :candRequestedPrjs
                                                 ORDER BY Name];


        return CandReqstPrjLst;
    }

    //Populate  Projects where Candidate is a Active Resource
    public List<TMS__Project_Resource__c> getCandidateProjects(){

       CandidatePrjs.clear();

              List<TMS__Project_Resource__c> CandidatePrjs =[SELECT Id,TMS__Project__c,TMS__Project__r.Name,
                                                            TMS__Project__r.Project_Description__c,
                                                            TMS__Project__r.Project_Lead__c,
                                                            TMS__Project__r.Project_Lead__r.Name,TMS__Project__r.Project_Folder_Link__c
                                                            FROM TMS__Project_Resource__c
                                                             WHERE TMS__Contact__c =:contactId AND
                                                             Status__c ='Active' AND
                                                             TMS__Project__r.TMS__Project_Status__c ='Open'
                                                             ORDER BY TMS__Project__r.Name];
                  CandidateCopyPrjs = CandidatePrjs;
             return CandidatePrjs;
    }


    // Send Email Method

    private void sendEmail(){
        String EmailBody,Subject;
        Contact prjLead;
        String prjLeadEmail;

         //Fetch Email Template Id to be send to Candidate and Project Lead
         List<EmailTemplate> emailTemplateIds = [SELECT Id,Subject,Body
                                                 FROM EmailTemplate
                                                 WHERE DeveloperName='Project_Join_Request' LIMIT 1];

        //Fetch the Project Lead Details
        If(selPrjLeadId != null){
             prjLead = [SELECT Id,FirstName,Name,Email
                                         FROM Contact
                                         WHERE id=:selPrjLeadId
                                         LIMIT 1];
             projectLead = prjLead.Name; // Value referred in VF Page
             prjLeadEmail = prjLead.Email;
             prjLeadOrManager = 'project lead';  //Value referred in VF Page
        } else{
            //If Project Lead not defined, Email fetched from Custom Metadata settings
            MR_Project_List_Setting__mdt PrjListMetaData = [SELECT PMO_Email__c,PMO_Name__c
                                                                  FROM MR_Project_List_Setting__mdt
                                                                  WHERE DeveloperName  ='PMO_Details' LIMIT 1];
            projectLead = PrjListMetaData.PMO_Name__c;
            prjLeadEmail = PrjListMetaData.PMO_Email__c;
            prjLeadOrManager = 'project manager';      //Value referred in VF Page
        }

        //New instance of a single email message sent to candidate
       Messaging.SingleEmailMessage emailCand = new Messaging.SingleEmailMessage();
       List<String> canEmailList = new List<String>();
       List<String> prjLeadEmailList = new List<String>();

        //Fetch the Candidate details
       If(contactId != null){

              EmailBody = emailTemplateIds.get(0).Body;
           If(EmailBody !=null){
               EmailBody = EmailBody.replace('Candidate',candFirstName);
               EmailBody = EmailBody.replace('project', selPrjName);
               EmailBody = EmailBody.replace('lead',projectLead);
               EmailBody = EmailBody.replace('plOrpm', prjLeadOrManager);
               EmailBody = EmailBody.replace('LeadEmail',prjLeadEmail);
           }
              canEmailList.add(candEmail);
              emailCand.toaddresses =canEmailList;
              prjLeadEmailList.add(prjLeadEmail);
              emailCand.ccaddresses = prjLeadEmailList;
              emailCand.setTargetObjectId(contactId);
               Subject = emailTemplateIds[0].Subject;
               emailCand.setSubject(Subject);
                emailCand.setPlainTextBody(EmailBody);
              try{
                  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailCand });
                  system.debug('Candidate & Project Lead Email Sent Successfully');
              }  catch(exception e){
                      system.debug('Error email');
                      apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
                      system.debug('Error Sending Candidate and Project Lead email '+e.getMessage());
               }

        }

 }


    // Update the project name in Candidate Record
    private void updateCandidate(){

        String projectsInterested;

        If(contactId != null && selPrjId !=null ){

            Contact interestedCandidate = [SELECT Id,Project_Interested__c
                                       FROM Contact
                                       WHERE Id =:contactId
                                       LIMIT 1];
             projectsInterested  = interestedCandidate.Project_Interested__c ;

            If(projectsInterested!=null){
               projectsInterested = selPrjName + ';' + projectsInterested;
            }
            If(projectsInterested == null){
               projectsInterested = selPrjName;
            }

            interestedCandidate.Project_Interested__c = projectsInterested ;
            update interestedCandidate;

        }

    }

      //Action Invoked when close option on popup page is selected
      public void closePopup() {
        displayPopup = false;
    }

    //Action invoked when 'Request to Join' button on VF page is clicked
    public void showPopup() {
        Integer CntProjects,MaxPrjReqAllowed;
        prevPendingInterest = false;
        sameProjName = false;//To check if already request to join has been done for the project
        currentInterest = false;
        removeProjInterest = false;
        selPrjName='';
        selPrjLeadId='';
        leavePrjRequest =false;
        activeProjInterest = false;

      Contact  Candidate = [SELECT Id,Project_Interested__c
                                                     FROM Contact
                                                     WHERE Id =:contactId and AVTRRT__Candidate_Status__c ='Active'
                                                     LIMIT 1];
        System.debug('PK:---> Inside showPopup -- contact Id = ' + contactId);
        System.debug('PK:---> Inside showPopup -- Candidate = ' + Candidate);


        If (Candidate.Project_Interested__c != null ){
            //Previous Project Interests have been saved, maximum project interests allowed are fetched from Custom Metadata
            MR_Project_List_Setting__mdt PrjListMetaData = [SELECT Max_Project_Request_Count__c
                                                                  FROM MR_Project_List_Setting__mdt
                                                                  WHERE DeveloperName  ='Requested_Projects_Allowed' LIMIT 1];
           MaxPrjReqAllowed = (integer)PrjListMetaData.Max_Project_Request_Count__c;

            CntProjects = Candidate.Project_Interested__c.countMatches(';');
            //n projects allowed means, n-1 (;)
            If (CntProjects >= (MaxPrjReqAllowed-1)){
                prevPendingInterest = true;
            }
        } else {
            System.debug('PK:---> No Projects interested found');
        }

        //Check if requesting project is already active project
                List<TMS__Project_Resource__c> PrjResource  =    [SELECT Id,TMS__Project__r.Name
                                                            FROM TMS__Project_Resource__c
                                                            WHERE TMS__Contact__c =:contactId AND
                                                            Status__c ='Active' AND TMS__Project__c =:selPrjId LIMIT 1];
        If(PrjResource != null && PrjResource.size()>0){
         activeProjInterest = true; // Is referred in VF Page to show a message
         selPrjName = PrjResource[0].TMS__Project__r.Name;
        }

        System.debug('PK:---> prevPendingInterest = ' + prevPendingInterest + ' - openInternalProjectLst - ' + openInternalProjectLst +
        + ' - openClientProjectLst - ' + openClientProjectLst + ' - activeProjInterest - ' + activeProjInterest);
        If(prevPendingInterest == false
                                && (openInternalProjectLst !=  null || openClientProjectLst !=null)
                                && contactId!= null && activeProjInterest ==false ) {
              //Loop through Internal Projects
              System.debug('PK:--->  Inside IF Looping Through Internal projects, selProjId = ' + selPrjId +
              ' - selPrjName - ' + selPrjName );
              for(Project objPrj : openInternalProjectLst ){

                    if(selPrjId==objPrj.Prj.Id ){
                         selPrjName = objPrj.Prj.Name;
                         // Check if Already Project Interested
                         System.debug('PK:--->  Inside IF selPrjId==objPrj.Prj.Id');
                        If(Candidate.Project_Interested__c!= null && Candidate.Project_Interested__c.contains(selPrjName)){
                            sameProjName = true;
                            System.debug('PK:--->  Breaking out of the loop interested projects = ' + Candidate.Project_Interested__c);
                            break; // Come out of the loop as already same project has been added
                            }
                         selPrjLeadId = objPrj.Prj.Project_Lead__c;

                         //Sending Email to Project Lead and Candidate
                           sendEmail();
                          //Update Project Interested Names in Candidate Record
                         updateCandidate();

                         //PK: Begin Insert Into custom join Object
                        RequestedProjectsPL__c candRequest = new RequestedProjectsPL__c();
                        candRequest.RequesterContact__c = Candidate.Id;
                        candRequest.Project__c = objPrj.Prj.Id;
                        // candRequest.Project_Lead__c = objPrj.Prj.Project_Lead__c;
                        //candRequest.Name = selPrjLeadId;
                         candRequest.Name = selPrjName;

                        insert candRequest;
                        System.debug('PK:---> Inside showPopup after INSERT -- Cand Id = ' + Candidate.Id);
                        System.debug('PK:---> Inside showPopup after INSERT -- Prj Id = ' + objPrj.Prj.Id);
                        System.debug('PK:---> Inside showPopup after INSERT -- Lead C = ' + objPrj.Prj.Project_Lead__c);
                       //PK: End
                         currentInterest = true;
                         break;
                    }
               }
             //Loop through Client projects

             If(selPrjName == ''){

                 for(Project objClientPrj : openClientProjectLst){

                   if(selPrjId==objClientPrj.Prj.Id ){
                        selPrjName = objClientPrj.Prj.Name;
                       // Check if Already Project Interested
                        If(Candidate.Project_Interested__c!= null && Candidate.Project_Interested__c.contains(selPrjName)){
                            sameProjName = true;
                            break; // Come out of the loop as already same project has been added
                            }
                        selPrjLeadId = objClientPrj.Prj.Project_Lead__c;
                        //Sending Email to Candidate and Project lead
                          sendEmail();
                       //Update Project Interested Names in Candidate Record
                        updateCandidate();

                       //PK: Begin Insert Into custom join Object
                       RequestedProjectsPL__c candRequest = new RequestedProjectsPL__c();
                       candRequest.RequesterContact__c = Candidate.Id;
                       candRequest.Project__c = objClientPrj.Prj.Id;
                       //candRequest.Project_Lead__c = objClientPrj.Prj.Project_Lead__c;
                       candRequest.Name = selPrjName;
                       insert candRequest;
                       System.debug('PK:---> Inside showPopup after INSERT(CP) -- Cand Id = ' + Candidate.Id);
                       System.debug('PK:---> Inside showPopup after INSERT(CP) -- Prj Id = ' + objClientPrj.Prj.Id);
                       System.debug('PK:---> Inside showPopup after INSERT(CP) -- Lead C = ' + candRequest.Project__r.Project_Lead__c);

                       //PK: End
                          currentInterest = true;
                          break;
                    }
                }
             }
        }
        displayPopup = true;
        system.debug('Previous pending  interest' + prevPendingInterest);
    }


    //Remove Project Interest
     public void removeProjectInterest() {

         String prjsInterestedString,prjReplacedString;
         boolean prjFound;
         Integer CntSemicolon;
         currentInterest = false;
         removeProjInterest = false;
         sameProjName = false;
         prevPendingInterest = false;
         leavePrjRequest = false;
         activeProjInterest = false;

                contact candidate = [SELECT Id,Project_Interested__c
                                     FROM Contact



                                     WHERE Id =:contactId
                                     LIMIT 1];
                prjsInterestedString  = candidate.Project_Interested__c;
                 //Prj to be removed is in middle of string
                  prjFound =  prjsInterestedString.contains(removePrjName +';');
                 If(prjFound){
                   prjReplacedString = prjsInterestedString.replace(removePrjName+';', '');
                 }
                 //Prj to be removed is in last of string
                 If(!prjFound && prjsInterestedString.contains(';'+ removePrjName)){
                     prjReplacedString = prjsInterestedString.replace(';'+ removePrjName, '');
                     prjFound = true;
                 }
                 //Prj to be removed is the only project
                 If(!prjFound){
                     system.debug('Entering single project' + removePrjName);
                   prjReplacedString = prjsInterestedString.replace(removePrjName, '');


                 }

                candidate.Project_Interested__c = prjReplacedString;
                update candidate;
                displayPopUp = true;
                removeProjInterest = true;
                 //PK: Delete Into custom join Object after 'Remove Interest' is invoked on the Project page.
                RequestedProjectsPL__c[] detachRequestedProjects = [select Id, Name from RequestedProjectsPL__c
                        WHERE RequesterContact__c =:contactId AND  Project__r.Name =: removePrjName];
                try {
                    system.debug('Size of the deleted Object=' + detachRequestedProjects.size());
                    delete detachRequestedProjects;
                } catch (DmlException e) {
                    // Process exception here
                    system.debug(' ---> Exception occured ===' + e);
                }

                //PK: Delete Into custom join Object after 'Remove Interest' is invoked on the Project page.
                       //RequestedProjectsPL__c candRequest = new RequestedProjectsPL__c();
                        //candRequest.RequesterContact__c = Candidate.Id;
                        //candRequest.Project__c = candidate.Project_Interested__c ;
                        //candRequest.Name = selPrjLeadId;
                       //DELETE[SELECT RequestedProjectsPL.Name FROM RequestedProjectsPL__c];
                   //PK: End

          }
}