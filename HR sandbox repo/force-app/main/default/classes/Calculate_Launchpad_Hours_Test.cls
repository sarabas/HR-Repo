@isTest
private class Calculate_Launchpad_Hours_Test {

      //Setup method to create setup data for test class
      @testSetup static void setup() {
           Id RecTypeIdProject = Schema.SObjectType.TMS__Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
           Id RecTypeIdCandidate = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
           
          //Insert Account
          Account mrAcct = new Account(Name ='Mom Relaunch');
          insert mrAcct;
          
          //Insert Candidates
          List<Contact> candidateLst = new List<Contact>();
          for(integer i=0; i<=5;i++){
              Contact candidate = new Contact();
              candidate.RecordTypeId = RecTypeIdCandidate;
              candidate.LastName ='Test';
              candidate.FirstName = 'Candidate'+i;
              candidate.Highest_Degree__c ='Bachelors Degree';
              candidate.AVTRRT__Candidate_Status__c ='Active';
              candidate.LaunchPad_Assigned__c = true;
              if ( i < 3)
              	candidate.Membership_Type__c = 'Core Team Membership';
              else
                candidate.Membership_Type__c = 'LaunchPad Membership';  
              candidateLst.add(candidate);
          }  
          insert candidateLst;
          
          //Inserting Projects
          List<TMS__Project__c> ProjectLst = new List<TMS__Project__c>();
          for (integer i=0;i<2;i++){
              TMS__Project__c Prj = new TMS__Project__c();
              Prj.RecordTypeId = RecTypeIdProject;
              Prj.Name = 'Test Project'+ i;
              Prj.TMS__Client__c = mrAcct.Id;
              Prj.Project_Description__c ='Test Project Desc';
              Prj.TMS__Project_Status__c ='Open';
              ProjectLst.add(Prj);
          }
          insert ProjectLst;
          
          //Inserting Project Resource
          TMS__Project_Resource__c PrjResource = new TMS__Project_Resource__c(TMS__Project__c = ProjectLst[0].Id,Status__c='Active',
                                                                             TMS__Contact__c =candidateLst[1].Id);
          insert PrjResource;
          
          
     }
    
    
    @isTest
    
    static void calculateLaunchpadHours(){
        Double minReqlaunchPadHrs;
        List<Contact> CandLst = [SELECT id 
                                FROM Contact
                                WHERE LastName='Test' 
                                LIMIT 6];
        TMS__Project__c Project =[SELECT Id 
                                  FROM TMS__Project__c
                                  WHERE Name ='Test Project1' 
                                  LIMIT 1];
            	//Get the minimum of hours to be completed during Launchpad
    	Launchpad_Hours__mdt getLaunchPadHrs = [SELECT Launchpad_Hours__c FROM Launchpad_Hours__mdt WHERE DeveloperName = 'LaunchPadHrs'];    
    	minReqlaunchPadHrs = getLaunchPadHrs.Launchpad_Hours__c;	

        //Adding Timesheet Hours for a candidate
        List<TMS__Timesheet__c> timeSheetLst = new List<TMS__Timesheet__c>();
        for (Integer i =0;i<=5;i++){
           TMS__Timesheet__c timeSheetCand = new TMS__Timesheet__c();
            timeSheetCand.TMS__Candidate__c = CandLst[i].Id;
            timeSheetCand.TMS__Project__c = Project.Id;
            timeSheetCand.TMS__Status__c ='Approved';
            If(i==3){
            timeSheetCand.TMS__Timesheet_Hours__c =150;    
            } else{
            timeSheetCand.TMS__Timesheet_Hours__c =minReqlaunchPadHrs;
            }
            timeSheetLst.add(timeSheetCand);
        }
        insert timeSheetLst;
        
        //Retrieve the updated Contacts
        List <Contact> contactsUpdated = new List<Contact>();
        contactsUpdated = [SELECT Id,LaunchPad_hours_completed__c,
                           LaunchPad_Hours_Completed_Date__c
                           FROM Contact
                           WHERE FirstName in ('Candidate1','Candidate3','Candidate5')
                           ];
        
        //Check values for Candidate1
        system.assertEquals(true, contactsUpdated[0].LaunchPad_hours_completed__c);
        system.assertEquals(Date.today(), contactsUpdated[0].LaunchPad_Hours_Completed_Date__c);
        
        //Check values for Candidate3
        system.assertEquals(false, contactsUpdated[1].LaunchPad_hours_completed__c);
        system.assertEquals(null, contactsUpdated[1].LaunchPad_Hours_Completed_Date__c);
        
        //Check values for Candidate5
         system.assertEquals(true, contactsUpdated[2].LaunchPad_hours_completed__c);
        system.assertEquals(Date.today(), contactsUpdated[2].LaunchPad_Hours_Completed_Date__c); 
        
        //Deleting timesheets for Candidate5
        TMS__Timesheet__c  timeSheetCand = [SELECT Id FROM TMS__Timesheet__c
                                           WHERE Id =: timeSheetLst[5].Id
                                           LIMIT 1];
        delete  timeSheetCand;
        
        Contact contactDelTimeSheet = [SELECT Id,LaunchPad_hours_completed__c,
                                       LaunchPad_Hours_Completed_Date__c
                                       FROM Contact
                                       WHERE FirstName ='Candidate5'
                                       ];
        system.assertEquals(false, contactDelTimeSheet.LaunchPad_hours_completed__c);
        system.assertEquals(null, contactDelTimeSheet.LaunchPad_Hours_Completed_Date__c); 
    }
    
    
     
}