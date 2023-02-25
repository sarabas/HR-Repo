trigger Calculate_Project_Hours on TMS__Timesheet__c (after insert,after update,after delete) {
    List<Contact> CandidateList = new List<Contact>();
    List<Contact> candidatesToUpdate = new List<Contact>();
    List<TMS__Project_Resource__c> ProjectResourceList= new List<TMS__Project_Resource__c>();
    String singleProjData;
     Set<Id> CandidateIds = new Set<Id>();
    Map<Id,String> projectHoursforCand= new Map<Id,String>();
     List<AggregateResult> canProjHoursAggr = new List<AggregateResult>();
     List<String> projList;
     Decimal percentHoursSpent;
String percentHoursSpentString;
     
     //Timesheet record update or inserted
    If(trigger.isUpdate || trigger.isInsert){
        
        //Loop through all the Trigger.New records
        for(TMS__Timesheet__c Timesheet :trigger.new){
         
           //Check for Approved Status Timesheet records and store the corresponding Candidate Id's
           If (Timesheet.TMS__Status__c =='Approved'){
             CandidateIds.add(Timesheet.TMS__Candidate__c);  
           }   
        }
    }
    
    //Timesheet record deleted
    If(trigger.isDelete){
        
        //Loop through all the Trigger.Old records
        for(TMS__Timesheet__c Timesheet :trigger.old){
        
           CandidateIds.add(Timesheet.TMS__Candidate__c);  
             
        }
    }

//Fetch the candidates records to be updated 

        CandidateList = [SELECT Id, Projects_Worked__c, LaunchPad_Total_Hours__c
                         FROM Contact 
                         WHERE (Id in:CandidateIds
                         AND LaunchPad_Assigned__c = true ) AND (Membership_Type__c = 'Core Team Membership' OR Membership_Type__c = 'LaunchPad Membership')];
        

 //Fetching project Hrs for candidates to be updated
        canProjHoursAggr = [SELECT TMS__Project__r.Name ProjectName,sum(TMS__Time_Spent__c) HrsSpent ,
                            max(TMS__Task__r.TMS__Project_Resource__r.TMS__Contact__r.CandidateSFID__c) CandidateId,
                            max(TMS__Task__r.TMS__Project_Resource__r.TMS__Contact__r.LaunchPad_Total_Hours__c) TotalLaunchpadHrs
                             FROM TMS__Time__c
                             WHERE TMS__Task__r.TMS__Project_Resource__r.TMS__Contact__r.CandidateSFID__c in :CandidateIds
                             AND TMS__Timesheet__r.TMS__Status__c = 'Approved' 
                             AND TMS__Task__r.TMS__Project_Resource__r.TMS__Contact__r.LaunchPad_Assigned__c = true
                             GROUP BY TMS__Project__r.Name];

//Loop through the Aggregate Result and populate Map
        for (AggregateResult candProjTime :canProjHoursAggr ){
            //first get the id
             Id candidateId =   (Id)candProjTime.get('CandidateId');
             system.debug('Candidate Id' + candidateId );
percentHoursSpent  = ((((Decimal)candProjTime.get('HrsSpent'))/((Decimal)candProjTime.get('TotalLaunchpadHrs'))) *100);
        percentHoursSpent = (((Decimal)candProjTime.get('HrsSpent'))/((Decimal)candProjTime.get('TotalLaunchpadHrs'))) *100;
        percentHoursSpentString = String.valueOf(percentHoursSpent.setScale(2, RoundingMode.HALF_UP));
             //check if the id already exists in the map
             if(projectHoursforCand.containsKey(candidateId)){
             //if exists, add the project info to the map    
                 singleProjData = projectHoursforCand.get(candidateId ) +  string.valueOf(candProjTime.get('ProjectName'))+ '-'+ string.valueOf(percentHoursSpentString  ) + '% ' + ' <br> ';                           
             } else {                
                 singleProjData = string.valueOf(candProjTime.get('ProjectName')) +'-' + string.valueOf(percentHoursSpentString  ) + '% ' +  ' <br> ';                
             }
             system.debug('Project Info' + singleProjData );
             //projList.add(singleProjData);  
             //update the map
             projectHoursforCand.put(candidateId , singleProjData);         
        }
        
         //Update the candidate projects Worked on field
         //Update LaunchPad Hours for the candidate
        if(CandidateList != null && CandidateList.size() >0){ 
          for(Contact candidate : CandidateList){
              if (projectHoursforCand.containsKey(candidate.Id)) {
                  candidate.Projects_Worked__c = projectHoursforCand.get(candidate.Id);
                  candidatesToUpdate.add(candidate); //Add candidate to collection to be updated
              }
            }
           }
           update  candidatesToUpdate;  
}