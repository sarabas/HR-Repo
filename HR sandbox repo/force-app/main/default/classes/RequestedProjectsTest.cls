@isTest
private class RequestedProjectsTest  {

    //Setup method to create setup data for test class
    @testSetup static void setup() {
        // TestUtil.commonSetup();
        Id RecTypeIdProject = Schema.SObjectType.TMS__Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id RecTypeIdCandidate = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
                
       //Insert Accounts
       
       Account mrAcct = new Account(Name ='Mom Relaunch');
       insert mrAcct;
       Account clientAcct = new Account(Name ='Test Client Account');
       insert clientAcct;
       
       //Insert Candidate for Project Lead //PK: based on ProjectLeadProfile page
       Contact prjLead = new Contact(LastName ='Test',FirstName ='Lead',AVTRRT__Candidate_Status__c ='Active',
                                      Highest_Degree__c ='Bachelors Degree',AVTRRT__AutoPopulate_Skillset__c ='Java',Email='testemail@gmail.com');
       insert prjLead;
       System.Debug('-----> Inside constructor PrjLead.id' + prjLead);
       
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
           candidate.AVTRRT__AutoPopulate_Skillset__c ='Java';
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

       MR_Project_Lead_Setting_mdt__mdt mdataPMO = new MR_Project_Lead_Setting_mdt__mdt();
       mdataPMO.PMO_email__c = 'testPMO@gmail.com';
       //insert mdataPMO; 

       MR_Project_Lead__mdt mdataHR = new MR_Project_Lead__mdt();
       mdataHR.HR_email__c = 'testHR@gmail.com';
       //insert mdataHR;


       //Inserting test metadata.This one is the newly created metadata that includes both HR and PMO emails
       /* MR_Project_Lead__mdt mdataPMO = new MR_Project_Lead__mdt();
        mdataPMO.Email__c = 'testPMO@gmail.com';
        insert mdataPMO; 

        MR_Project_Lead__mdt mdataHR = new MR_Project_Lead__mdt();
        mdataHR.Email__c = 'testHR@gmail.com';
        insert mdataHR; */

       
       

    }

       
    @isTest
       
    static void showPopupInternalPrjTest(){
        
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
      

       TMS__Project__c internalPrj0 = intPrjLst[0].getProject();
       prjLst.selPrjId = internalPrj0.Id;
       prjLst.selPrjName = internalPrj0.Name;
       System.Debug('-----> Inside testCase ProjectName = ' + prjLst.selPrjName);
        prjLst.showPopup();
        
        Contact prjLead = [SELECT FirstName, LastName, Email FROM Contact
                           WHERE LastName ='Test' and FirstName ='Lead'AND Highest_Degree__c ='Bachelors Degree' and
                                        AVTRRT__Candidate_Status__c ='Active' and Email='testemail@gmail.com'
                           LIMIT 1
                          ];

       System.Debug('-----> Inside testCase PrjLead.id' + prjLead.id);

        PageReference pageRef1 = Page.DesignForm;
        pageRef1.getParameters().put('cId',prjLead.id);
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController controller1 = new ApexPages.StandardController(new TMS__Project__c());
        RequestedProjects requestedProjects = new RequestedProjects(controller1);                            
        List<RequestedProjectsPL__c> rpTest = requestedProjects.getCandidateInternalProjects();
        System.Debug('List count = ' + rpTest.size());
        System.assertequals(1,rpTest.size()); 

    }

        
    @isTest
       
    static void showPopupClientPrjTest(){
        
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
        
        //Fetching Client Projects
        List<ProjectsList.Project> clientPrjLst  = prjLst.getOpenClientProjects();  


       TMS__Project__c clientPrj0 = clientPrjLst[0].getProject();
       prjLst.selPrjId = clientPrj0.Id;
       prjLst.selPrjName = clientPrj0.Name;
       System.Debug('-----> Inside testCase ProjectName = ' + prjLst.selPrjName);
       prjLst.showPopup();
        
        Contact prjLead = [SELECT FirstName, LastName, Email FROM Contact
                           WHERE LastName ='Test' and FirstName ='Lead'AND Highest_Degree__c ='Bachelors Degree' and
                                        AVTRRT__Candidate_Status__c ='Active' and Email='testemail@gmail.com'
                           LIMIT 1
                          ];

       System.Debug('-----> Inside testCase PrjLead.id' + prjLead.id);

        PageReference pageRef1 = Page.DesignForm;
        pageRef1.getParameters().put('cId',prjLead.id);
        Test.setCurrentPage(pageRef1);
        ApexPages.StandardController controller1 = new ApexPages.StandardController(new TMS__Project__c());
        RequestedProjects requestedProjects = new RequestedProjects(controller1);                            
        List<RequestedProjectsPL__c> rpTest = requestedProjects.getCandidateOpenProjects();
        System.Debug('List count = ' + rpTest.size());
        System.assertequals(1,rpTest.size()); 

    }

    @isTest
        static void removeProjectInterestTest(){

            Contact testCand = [SELECT id,Name,FirstName,LastName 
                              FROM Contact 
                              WHERE FirstName = 'Candidate1'
                              LIMIT 1];
          
            //Setting candidate with 1 project request and removing that
            PageReference pageRef = Page.DesignForm;
            pageRef.getParameters().put('cId',testCand.id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController controller = new ApexPages.StandardController(new TMS__Project__c());
            ProjectsList prjLst = new ProjectsList(controller);
            List<TMS__Project__c> clientReqstPrjLst  = prjLst.getCandidateRequestedProjects();
            prjLst.removePrjName = clientReqstPrjLst[0].Name;
            System.Debug('-----> Display Candidate requested Project)' + prjLst.removePrjName);
            prjLst.removeProjectInterest();
            Contact Candidate = [SELECT Project_Interested__c 
                                FROM Contact 
                                WHERE Id =:testCand.id];
            //System.assertEquals(null, Candidate.Project_Interested__c);
            System.Debug('-----> Check the Project INteretsted' + Candidate.Project_Interested__c);
            
            PageReference pageRef1 = Page.DesignForm;
            pageRef1.getParameters().put('cId',	clientReqstPrjLst[0].Project_Lead__c);
            Test.setCurrentPage(pageRef1);
            ApexPages.StandardController controller1 = new ApexPages.StandardController(new TMS__Project__c());
            RequestedProjects requestedProjects = new RequestedProjects(controller1);                            
            List<RequestedProjectsPL__c> rpTest = requestedProjects.getCandidateOpenProjects();
            System.Debug('List count = ' + rpTest.size());
            System.assertequals(0,rpTest.size()); 

          
        }   
      
      @isTest
      static void sendRejectEmail(){
        //Calling this testcase from RequestedProjectsTest.cls controller

          Contact testCand = [SELECT id,Name,FirstName,LastName, Project_Interested__c
                              FROM Contact 
                              WHERE FirstName = 'Candidate1'
                              LIMIT 1];

          Contact prjLead = [SELECT FirstName, LastName, Email FROM Contact
                            WHERE LastName ='Test' and FirstName ='Lead'AND Highest_Degree__c ='Bachelors Degree' and
                            AVTRRT__Candidate_Status__c ='Active' and Email='testemail@gmail.com'
                            LIMIT 1];

          PageReference pageRef = Page.DesignForm;
          pageRef.getParameters().put('cId',testCand.Id);
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController controller = new ApexPages.StandardController(new TMS__Project__c());
          ProjectsList prjLst = new ProjectsList(controller);
          
          //Fetching Internal Projects
          List<ProjectsList.Project> intPrjLst  = prjLst.getOpenInternalProjects();
          TMS__Project__c internalPrj1 = intPrjLst[1].getProject();
          
                    
          PageReference pageRef1 = Page.DesignForm;
          pageRef1.getParameters().put('cId',prjLead.Id	);
          Test.setCurrentPage(pageRef1);
          ApexPages.StandardController controller1 = new ApexPages.StandardController(new TMS__Project__c());
          RequestedProjects requestedProjects = new RequestedProjects(controller1);
          requestedProjects.selPrjId = internalPrj1.Id;
          requestedProjects.selCandidateId = testCand.Id;                           
          requestedProjects.sendRejectEmail();

          List<RequestedProjectsPL__c> rpTest = [SELECT Project__r.Id, Project__r.Name, RequesterContact__r.Name, Project__r.Project_Lead__c,RequesterContact__r.AVTRRT__AutoPopulate_Skillset__c 
                                      FROM RequestedProjectsPL__c 
                                      where Project__r.Project_Lead__c = :prjLead.Id
                                      AND Project__r.TMS__Client__r.Name = 'Mom Relaunch'
                                      AND RequesterContact__c = :testCand.Id
                                      AND Project__c = :testCand.Project_Interested__c];
          
          System.Debug('List count = ' + rpTest.size());
          System.assertequals(0,rpTest.size()); 


    }

    @isTest
      static void sendApproveEmail(){
      //Calling this testcase from RequestedProjectsTest.cls controller

          Contact testCand = [SELECT id,Name,FirstName,LastName, Project_Interested__c
                              FROM Contact 
                              WHERE FirstName = 'Candidate1'
                              LIMIT 1];

          Contact prjLead = [SELECT FirstName, LastName, Email FROM Contact
                            WHERE LastName ='Test' and FirstName ='Lead'AND Highest_Degree__c ='Bachelors Degree' and
                            AVTRRT__Candidate_Status__c ='Active' and Email='testemail@gmail.com'
                            LIMIT 1];

          PageReference pageRef = Page.DesignForm;
          pageRef.getParameters().put('cId',testCand.Id);
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController controller = new ApexPages.StandardController(new TMS__Project__c());
          ProjectsList prjLst = new ProjectsList(controller);
          
          //Fetching Internal Projects
          List<ProjectsList.Project> intPrjLst  = prjLst.getOpenInternalProjects();
          TMS__Project__c internalPrj1 = intPrjLst[1].getProject();
          
                    
          PageReference pageRef1 = Page.DesignForm;
          pageRef1.getParameters().put('cId',prjLead.Id	);
          Test.setCurrentPage(pageRef1);
          ApexPages.StandardController controller1 = new ApexPages.StandardController(new TMS__Project__c());
          RequestedProjects requestedProjects = new RequestedProjects(controller1);
          requestedProjects.selPrjId = internalPrj1.Id;
          requestedProjects.selCandidateId = testCand.Id;                           
          requestedProjects.sendApproveEmail();

          List<RequestedProjectsPL__c> rpTest = [SELECT Project__r.Id, Project__r.Name, RequesterContact__r.Name, Project__r.Project_Lead__c,RequesterContact__r.AVTRRT__AutoPopulate_Skillset__c 
                                      FROM RequestedProjectsPL__c 
                                      where Project__r.Project_Lead__c = :prjLead.Id
                                      AND Project__r.TMS__Client__r.Name = 'Mom Relaunch'
                                      AND RequesterContact__c = :testCand.Id
                                      AND Project__c = :testCand.Project_Interested__c];
          
          System.Debug('List count = ' + rpTest.size());
          System.assertequals(0,rpTest.size()); 


  }

       
   

}