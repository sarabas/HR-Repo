trigger Calculate_Launchpad_Hours on TMS__Timesheet__c (after insert,after update,after delete) {
    
    List<Contact> CandidateList = new List<Contact>();
    List<Contact> candidatesToUpdate  = new List<Contact>();
    List<AggregateResult> candTimeSheetAggr = new List<AggregateResult>();
    Set<Id> CandidateIds = new Set<Id>();
    Map<Id,Double> candTimeSheetHrs = new Map<Id,Double>();
    Double timesheetHrs;
    Double minReqlaunchPadHrs;
    //Timesheet record update or inserted
    If(trigger.isUpdate || trigger.isInsert){
        
        //Loop through all the Trigger.New records
        for(TMS__Timesheet__c Timesheet :trigger.new){
         
           //Check for Approved Status records
           If (Timesheet.TMS__Status__c =='Approved' || Timesheet.TMS__Status__c =='Rejected'){
             CandidateIds.add(Timesheet.TMS__Candidate__c);  
           }   
        }
    }
    
    //Timesheet record deleted
    If(trigger.isDelete){
        
        //Loop through all the Trigger.New records
        for(TMS__Timesheet__c Timesheet :trigger.old){
        
           CandidateIds.add(Timesheet.TMS__Candidate__c);  
             
        }
    }

    
        //Fetch all candidate records to be updated 
        CandidateList = [SELECT Id,LaunchPad_Total_Hours__c,LaunchPad_hours_completed__c
                         FROM Contact 
                         WHERE (Id in:CandidateIds
                         AND LaunchPad_Assigned__c = true ) AND (Membership_Type__c = 'Core Team Membership' OR Membership_Type__c = 'LaunchPad Membership')];
        
        //Fetching Timesheet Hrs for candidates to be updated
        candTimeSheetAggr = [SELECT TMS__Candidate__c CandidateId,sum(TMS__Timesheet_Hours__c) HrsCompleted
                             FROM TMS__Timesheet__c
                             WHERE TMS__Candidate__c in :CandidateIds
                             AND TMS__Status__c ='Approved'
                             GROUP BY TMS__Candidate__c];
        
        //Loop through the Aggregate Result and populate Map
        for (AggregateResult candTimeSheet :candTimeSheetAggr ){
             Id candidateId =   (Id)candTimeSheet.get('CandidateId');
             Double candidateHrs = (Double)candTimeSheet.get('HrsCompleted');
             candTimeSheetHrs.put(candidateId,candidateHrs);
        }
            
        system.debug('Cand List Size' +CandidateList.size() );
        //Get the minimum of hours to be completed during Launchpad
        Launchpad_Hours__mdt getLaunchPadHrs = [SELECT Launchpad_Hours__c FROM Launchpad_Hours__mdt WHERE DeveloperName = 'LaunchPadHrs'];    
        minReqlaunchPadHrs = getLaunchPadHrs.Launchpad_Hours__c;    
    
        //Update LaunchPad Hours for the candidate
        If(CandidateList != null && CandidateList.size() >0){ 
          for(Contact candidate : CandidateList){
              
              If (candTimeSheetHrs.containsKey(candidate.Id)) {
                  timesheetHrs = candTimeSheetHrs.get(candidate.Id);
              }

            //Determine if launchpad hours have Changed
            if (candidate.LaunchPad_Total_Hours__c != timesheetHrs) {
                candidate.LaunchPad_Total_Hours__c = timesheetHrs;
                
                 //When minimum required Launchpad Hours are completed for the first time, update the Launchpad Completed checkbox and date
                  If(candidate.LaunchPad_Total_Hours__c >= minReqlaunchPadHrs && !(candidate.LaunchPad_hours_completed__c)){
                       candidate.LaunchPad_hours_completed__c = true;
                       candidate.LaunchPad_Hours_Completed_Date__c = Date.today();
                  } 
                
                  //When timesheet hours are deleted and number of hours get below the minimum required hours, uncheck the launchpad completed checkbox
                  If((candidate.LaunchPad_Total_Hours__c < minReqlaunchPadHrs || candidate.LaunchPad_Total_Hours__c ==null )
                                                                                    && (candidate.LaunchPad_hours_completed__c)){
                       candidate.LaunchPad_hours_completed__c = false;
                       candidate.LaunchPad_Hours_Completed_Date__c = null;
                  } 
               
                candidatesToUpdate.add(candidate); //Add candidate to collection to be updated
            }
              
          }
        update  candidatesToUpdate;  
        }    

}