@isTest
private class ProjectsListTest {

    //Setup method to create setup data for test class
      @testSetup static void setup() {
             
           Id RecTypeIdProject = Schema.SObjectType.TMS__Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
           Id RecTypeIdCandidate = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
                   
          //Insert Accounts
          
          Account mrAcct = new Account(Name ='Mom Relaunch');
          insert mrAcct;
          Account clientAcct = new Account(Name ='Test Client Account');
          insert clientAcct;
          
          //Insert Candidate for Project Lead
          Contact prjLead = new Contact(LastName ='Test',FirstName ='Lead',Highest_Degree__c ='Bachelors Degree',
                                        AVTRRT__Candidate_Status__c ='Active',Email='testemail@gmail.com');
          insert prjLead;
          
          //Inserting internal project - Mom Relaunch Account record id
          List<TMS__Project__c> InternalPrjs = new List<TMS__Project__c>();
          for (integer i=0;i<6;i++){
              TMS__Project__c intPrj = new TMS__Project__c();
              intPrj.RecordTypeId =RecTypeIdProject;
              intPrj.Name = 'Test Internal Prj'+ i;
              intPrj.TMS__Client__c = mrAcct.Id;
              intPrj.Project_Description__c ='Test Internal Prj Desc';
              If(i==5){
               intPrj.TMS__Project_Status__c ='Completed';   
              } else{
                intPrj.TMS__Project_Status__c ='Open';
              }
              If(i<4){
              intPrj.Project_Lead__c =prjLead.Id;
              }   
              intPrj.Launchpad_Project__c =true;
              intPrj.TMS__Billable__c = false;
              InternalPrjs.add(intPrj);
          }
          insert InternalPrjs;
          
          //Inserting Client Projects which are non billable
          List<TMS__Project__c> ClientPrjs = new List<TMS__Project__c>();
          for (integer i=0;i<6;i++){
              TMS__Project__c clientPrj = new TMS__Project__c();
              clientPrj.RecordTypeId =RecTypeIdProject;
              clientPrj.Name = 'Test Client Prj'+ i;
              clientPrj.TMS__Client__c = clientAcct.Id;
              If(i ==3){
                clientPrj.Maximum_Team_Size__c = 4;  
              }
              If(i ==0){
               clientPrj.Maximum_Team_Size__c = 1;   
              }
              clientPrj.Project_Description__c ='Test Client Prj Desc';
              If(i==5){
               clientPrj.TMS__Project_Status__c ='Completed';   
              } else{
                clientPrj.TMS__Project_Status__c ='Open';
              }
              If(i<3){
              clientPrj.Project_Lead__c =prjLead.Id;
              }
             
              clientPrj.Launchpad_Project__c =true;
              clientPrj.TMS__Billable__c = false;
              ClientPrjs.add(clientPrj);
          }
          insert ClientPrjs;
           

          //Insert Candidates
          List<Contact> candidateLst = new List<Contact>();
          for(integer i=0; i<=5;i++){
            Contact candidate = new Contact();
              candidate.LastName ='Test'+i;
              candidate.FirstName = 'Candidate'+i;
              candidate.Highest_Degree__c ='Bachelors Degree';
              candidate.AVTRRT__Candidate_Status__c ='Active';
              If (i==1){
                 candidate.Project_Interested__c ='Test Internal Prj1;Test Client Prj2';
              }
              If(i==2){
                  candidate.Project_Interested__c ='Test Internal Prj1;Test Internal Prj2';
              }  
              If(i==3){
                  candidate.Project_Interested__c ='Test Internal Prj1;Test Internal Prj2;Test Internal Prj3';
              } 
              If(i==4 || i==5){
               candidate.Project_Interested__c ='Test Client Prj2';    
              }
              
             candidate.Email ='testemail'+ i+'@gmail.com';
              If (i==5){
                  candidate.Email ='';
              }
             candidateLst.add(candidate);
          }
          insert candidateLst;
          
          //Insert Internal Project Resource
          TMS__Project_Resource__c intPrjResource = new TMS__Project_Resource__c(TMS__Project__c = InternalPrjs[0].Id,Status__c='Active',
                                                                             TMS__Contact__c =candidateLst[1].Id);
          insert intPrjResource;
          
          //Insert Client Project Resource - This proj has maximum resource count allowed as 1
       
          TMS__Project_Resource__c clientPrjResource = new TMS__Project_Resource__c(TMS__Project__c = ClientPrjs[0].Id,Status__c='Active',
                                                                             TMS__Contact__c =candidateLst[1].Id);
          insert clientPrjResource;
          
           //Insert Client Project resource, candidate has no email         
          TMS__Project_Resource__c clientPrjResource1 = new TMS__Project_Resource__c(TMS__Project__c = ClientPrjs[1].Id,Status__c='Active',
                                                                             TMS__Contact__c =candidateLst[5].Id);
          insert clientPrjResource1;
          
      }
    
         @isTest
    
    static void showPopupInternalPrjTest(){
        boolean displayPopup;
        //Fetch candidate with 1 project interest
        Contact testCand1 = [SELECT id,Name,FirstName,LastName 
                            FROM Contact 
                            WHERE FirstName='Candidate1' 
                            LIMIT 1];
        
        PageReference pageRef = Page.DesignForm;
        pageRef.getParameters().put('cId',testCand1.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst = new ProjectsList(controller);
        
        //Fetching Internal Projects
        List<ProjectsList.Project> intPrjLst  = prjLst.getOpenInternalProjects();
        TMS__Project__c internalPrj = intPrjLst[1].getProject();
       String intPrjDetails1 = intPrjLst[1].getPrjDetails();
        String intPrjDetails5 = intPrjLst[4].getPrjDetails();//Testing for scenario where Prj Lead is blank
       System.assertequals(5,intPrjLst.size());
        
        //Fetching Client Projects
         List<ProjectsList.Project> clientPrjLst  = prjLst.getOpenClientProjects();
        TMS__Project__c clientPrj = clientPrjLst[0].getProject();
        String prjDetails = clientPrjLst[0].getPrjDetails();
        String prjNameMax = clientPrjLst[0].getProjectName(); // Fetching project name for client proj where max resource capacity is reached
        String prjName = clientPrjLst[1].getProjectName();//Fetching project name where max resource capacity is not reached
        String prjDetails5 = clientPrjLst[4].getPrjDetails(); //Testing for scenario where Prj Lead is blank
        String prjDetails3 = clientPrjLst[3].getPrjDetails();
        String prjDetails1 = clientPrjLst[1].getPrjDetails();
       System.assertequals(5,clientPrjLst.size());
        
        //Setting  internal proj where request already exists
        prjLst.selPrjId = internalPrj.Id;
        prjLst.showPopup();
        
        //Setting Internal project 
        prjLst.selPrjId = intPrjLst[0].getProject().Id;
        prjLst.showPopup();
        
        //Setting Internal Project where no project lead defined
        prjLst.selPrjId = intPrjLst[4].getProject().Id;
        prjLst.showPopup();
        
         //Testing the close popup method
         displayPopup =false;
         prjLst.closePopup();
         System.assertEquals(displayPopup, prjLst.displayPopup);
          
          }
    
    
       // @isTest
        static void removeProjectInterestTest(){
        List<Contact> testCand = [SELECT id,Name,FirstName,LastName 
                            FROM Contact 
                            WHERE FirstName in('Candidate1','Candidate2','Candidate3','Candidate4')
                            LIMIT 4];
        //Setting candidate with 1 project request and removing that
        PageReference pageRef = Page.DesignForm;
        pageRef.getParameters().put('cId',testCand[3].Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst = new ProjectsList(controller);
        List<TMS__Project__c> clientReqstPrjLst  = prjLst.getCandidateRequestedProjects();
        System.assertequals(1,clientReqstPrjLst.size());
        prjLst.removePrjName = clientReqstPrjLst[0].Name;
        prjLst.removeProjectInterest();
        Contact Candidate = [SELECT Project_Interested__c 
                             FROM Contact 
                             WHERE Id =:testCand[3].Id];
         System.assertEquals(null, Candidate.Project_Interested__c);
            
        //Setting Candidate With 2 project interests and removing last project    
        PageReference pageRef2 = Page.DesignForm;
        pageRef2.getParameters().put('cId',testCand[1].Id);
        Test.setCurrentPage(pageRef2);
        ApexPages.StandardController controller2 = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst2 = new ProjectsList(controller2);
        List<TMS__Project__c> candReqstPrjLst2  = prjLst2.getCandidateRequestedProjects();
        System.assertequals(2,candReqstPrjLst2.size());
        prjLst2.removePrjName = candReqstPrjLst2[1].Name;
        prjLst2.removeProjectInterest();
        Contact Candidate2 = [SELECT Project_Interested__c 
                             FROM Contact 
                             WHERE Id =:testCand[1].Id];
         System.assertEquals('Test Internal Prj1', Candidate2.Project_Interested__c);
            
         //Setting Candidate With 3 project interests and removing middle project    
        PageReference pageRef3 = Page.DesignForm;
        pageRef3.getParameters().put('cId',testCand[2].Id);
        Test.setCurrentPage(pageRef3);
        ApexPages.StandardController controller3 = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst3 = new ProjectsList(controller3);
        List<TMS__Project__c> candReqstPrjLst3  = prjLst3.getCandidateRequestedProjects();
        System.assertequals(3,candReqstPrjLst3.size());
        prjLst3.removePrjName = candReqstPrjLst2[1].Name;
        prjLst3.removeProjectInterest();
        Contact Candidate3 = [SELECT Project_Interested__c 
                             FROM Contact 
                             WHERE Id =:testCand[2].Id];
         System.assertEquals('Test Internal Prj1;Test Internal Prj3', Candidate3.Project_Interested__c);    
            
    }
    
    
    @isTest
        static void requestToLeaveProjectTest(){
        Contact testCand = [SELECT id,Name,FirstName,LastName 
                            FROM Contact 
                            WHERE FirstName='Candidate1' 
                            LIMIT 1];
        
        PageReference pageRef = Page.DesignForm;
        pageRef.getParameters().put('cId',testCand.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst = new ProjectsList(controller);
        List<TMS__Project_Resource__c> candActivePrjLst  = prjLst.getCandidateProjects();
        System.assertequals(2,candActivePrjLst.size());
       // prjLst.leavePrjId = candActivePrjLst[0].TMS__Project__c;
      //  prjLst.requestToLeaveProject();
        
    }
    
    @isTest
    
    static void fetchCandRequestedPrjTest(){
        boolean displayPopup;
        //Fetch candidate with no project interest
        List<Contact> testCandLst = [SELECT id,Name,FirstName,LastName 
                            FROM Contact 
                            WHERE FirstName in('Candidate0','Candidate3')
                            LIMIT 2];
        
        PageReference pageRef1 = Page.DesignForm;
        pageRef1.getParameters().put('cId',testCandLst[0].Id);
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController controller = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst1 = new ProjectsList(controller);
         List<TMS__Project__c> clientReqstPrjLst  = prjLst1.getCandidateRequestedProjects();
         System.assertequals(0,clientReqstPrjLst.size());
         List<ProjectsList.Project> intPrjLst  = prjLst1.getOpenInternalProjects();
        TMS__Project__c internalPrj = intPrjLst[1].getProject();
        
        //Setting Internal project for a candidate with no previous requests
        prjLst1.selPrjId = intPrjLst[0].getProject().Id;
        prjLst1.showPopup();
        
        //requesting to join a project when max count is reached for a candidate
        PageReference pageRef2 = Page.DesignForm;
        pageRef2.getParameters().put('cId',testCandLst[1].Id);
        Test.setCurrentPage(pageRef2);
        ApexPages.StandardController controller2 = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst2 = new ProjectsList(controller2);
        List<ProjectsList.Project> intPrjLst2  = prjLst2.getOpenInternalProjects();
        prjLst2.selPrjId = intPrjLst[3].getProject().Id;
        prjLst2.showPopup();
    }
    
    
    
    @isTest
    
    static void showPopupClientPrjTest(){
       
        //Fetch candidate with 1 project interest
        List<Contact> testCandLst = [SELECT id,Name,FirstName,LastName 
                            FROM Contact 
                            WHERE FirstName in ('Candidate1','Candidate4') 
                            LIMIT 2];
        
        PageReference pageRef1 = Page.DesignForm;
        pageRef1.getParameters().put('cId',testCandLst[0].Id);
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController controller1 = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst1 = new ProjectsList(controller1);
        
        //Fetching Internal Projects
        List<ProjectsList.Project> intPrjLst  = prjLst1.getOpenInternalProjects();
          
        //Fetching Client Projects
         List<ProjectsList.Project> clientPrjLst  = prjLst1.getOpenClientProjects();
       
        //Setting Client project
        prjLst1.selPrjId = clientPrjLst[3].getProject().Id;
        prjLst1.showPopup();
        
        //Setting a different candidate 
         PageReference pageRef2 = Page.DesignForm;
        pageRef2.getParameters().put('cId',testCandLst[1].Id);
        Test.setCurrentPage(pageRef2);
        ApexPages.StandardController controller2 = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst2 = new ProjectsList(controller2);
        
        //Fetching Internal Projects
       List<ProjectsList.Project> intPrjLst2  = prjLst2.getOpenInternalProjects();
          
        //Fetching Client Projects
       List<ProjectsList.Project> clientPrjLst2  = prjLst2.getOpenClientProjects();
        //Setting client project request which already exists
        prjLst2.selPrjId = clientPrjLst2[2].getProject().Id;
        prjLst2.showPopup();
        
          }
    
    @isTest
    static void emailFailTest(){
      
         //Fetch candidate having no email id defined
        Contact testCand = [SELECT id,Name,FirstName,LastName 
                            FROM Contact 
                            WHERE FirstName ='Candidate5' 
                            LIMIT 1];
        
        PageReference pageRef1 = Page.DesignForm;
        pageRef1.getParameters().put('cId',testCand.Id);
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController controller1 = new ApexPages.StandardController(new TMS__Project__c());
        ProjectsList prjLst1 = new ProjectsList(controller1);
        
        //Fetching Internal Projects
        List<ProjectsList.Project> intPrjLst  = prjLst1.getOpenInternalProjects();
          
        //Fetching Client Projects
         List<ProjectsList.Project> clientPrjLst  = prjLst1.getOpenClientProjects();
       
        //Setting Client project
        prjLst1.selPrjId = clientPrjLst[3].getProject().Id;
        prjLst1.showPopup();
        
         List<TMS__Project_Resource__c> candActivePrjLst  = prjLst1.getCandidateProjects();
        System.assertequals(1,candActivePrjLst.size());
     
        
    }

}