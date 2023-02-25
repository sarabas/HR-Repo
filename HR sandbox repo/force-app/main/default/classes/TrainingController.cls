public without sharing class TrainingController {

    
    // Create strings to put our values in from the page
    public String trainingForm {get;set;}
    public Id contactId;
      
    public Contact con {get;set;}
    public Training__c tr {get;set;}
        // The extension constructor initializes the private member
    // variable 'con' by using the getRecord method from the standard
    // controller.
    
    public TrainingController(ApexPages.StandardController stdController)
    {   
        this.contactId = apexpages.currentpage().getparameters().get('cId');
         this.trainingForm = apexpages.currentpage().getparameters().get('trainingForm');
        
        if(contactId != null){
        System.debug('contactId :'+contactId);
        this.con = [SELECT Id,firstname,lastname,email,phone,AVTRRT__City__c,AVTRRT__State__c,AVTRRT__Postal_Code__c,
                    Highest_Degree__c,Please_select_your_age_range__c,AVTRRT__Ethnicity__c,Computer_Skills__c,
                    Professional_Skills__c,Prior_IT_Work_Experience__c,Prior_Work_Experience_Please_list_each__c,What_employment_you_are_interested_in__c,
                    AVTRRT__Available_To_Start__c,Interested_in_volunteering_for_MR__c,Interested_in_internship_with_MR__c,
                    Available_in_person_for_Training__c,career_goals__c,Training_Intereste__c,why_would_you_want_to_take_this_Training__c,
                    Training_form_submitted__c
                    FROM Contact where Id=:contactId LIMIT 1];
            
            tr = new Training__c();
            tr.First_Name__c = this.con.FirstName;
            tr.Last_Name__c = this.con.LastName;
            tr.email__c = this.con.Email;
            tr.Phone__c = this.con.Phone;
            tr.City__c = this.con.AVTRRT__City__c;
            tr.State__c = this.con.AVTRRT__State__c;
            tr.Zip_Code__c = this.con.AVTRRT__Postal_Code__c;
            tr.Highest_Degree__c = this.con.highest_degree__c;
            tr.Age_Range__c = this.con.Please_select_your_age_range__c;
            tr.Race_and_Ethnicity__c = this.con.AVTRRT__Ethnicity__c;
            tr.Computer_Skills__c = this.con.Computer_Skills__c;
            tr.Professional_Skills__c = this.con.Professional_Skills__c;
            tr.Prior_IT_Work_Experience__c = this.con.Prior_IT_Work_Experience__c;
            tr.List_Each_Prior_Work_Experience__c = this.con.Prior_Work_Experience_Please_list_each__c;
            tr.Employement_Interested_in__c = this.con.What_employment_you_are_interested_in__c;
            tr.Availability_to_Start__c = this.con.AVTRRT__Available_To_Start__c;
            tr.Interested_in_volunteering_for_MR__c = this.con.Interested_in_volunteering_for_MR__c;
            tr.Interested_in_internship_with_MR__c = this.con.Interested_in_internship_with_MR__c;
            tr.Available_in_person_for_Training__c = this.con.Available_in_person_for_Training__c;
            tr.Career_goals__c = this.con.career_goals__c;
            tr.why_would_you_want_to_take_this_Training__c = this.con.why_would_you_want_to_take_this_Training__c;            
        }
        else {
      // this.con = new Contact();
       this.tr = new Training__c();     
        }     
        System.debug('contact details in constructor:'+con);
        //setCandidateRecordType();
       // con.RecordType = (RecordType)rt[0];
    }

    
    public PageReference saveRecord()
    {
        System.debug('...Training Object Values ... :'+tr);
        List<Contact> retriveExistingContact = [SELECT Id,firstname,lastname,email,phone,AVTRRT__City__c,AVTRRT__State__c,AVTRRT__Postal_Code__c,
                    Highest_Degree__c,Please_select_your_age_range__c,AVTRRT__Ethnicity__c,Computer_Skills__c,
                    Professional_Skills__c,Prior_IT_Work_Experience__c,Prior_Work_Experience_Please_list_each__c,What_employment_you_are_interested_in__c,
                    AVTRRT__Available_To_Start__c,Interested_in_volunteering_for_MR__c,Interested_in_internship_with_MR__c,
                    Available_in_person_for_Training__c,Training_Intereste__c,career_goals__c,why_would_you_want_to_take_this_Training__c,
                    Partner_Contact_Email__c,Training_form_submitted__c                    
                    FROM Contact 
                    where 
                    firstname=:tr.First_Name__c AND
                    lastname=:tr.Last_Name__c AND
                    email=:tr.email__c
                    LIMIT 1];
         System.debug('...Contact Object Values ... :'+this.con);
        if(retriveExistingContact.size()==0){
            this.con = new Contact();
            con.Training_Intereste__c=trainingForm;
        }else{
            this.con = retriveExistingContact.get(0);
            String intrestedTraining = con.Training_Intereste__c;
            system.debug('...Previously Training Intrested assigned to String :' + intrestedTraining);
            if(con.Training_Intereste__c != null && !intrestedTraining.contains(trainingForm)) {
              system.debug('Previously Training Intrested ---- ' + con.Training_Intereste__c);
                con.Training_Intereste__c = con.Training_Intereste__c + ';' + trainingForm;
              system.debug('Updated Training Intrested ---- ' + con.Training_Intereste__c);
            }else{
                system.debug('...Training Entry Already Exist :' + trainingForm);
            }
        }
        
        System.debug('...Training Object Values ... :'+tr);
        this.con.FirstName = tr.First_Name__c;
        this.con.LastName = tr.Last_Name__c;
        this.con.Email = tr.email__c;
        this.con.Phone = tr.Phone__c;
        this.con.AVTRRT__City__c = tr.City__c;
        this.con.AVTRRT__State__c = tr.State__c;
        this.con.AVTRRT__Postal_Code__c = tr.Zip_Code__c;
        this.con.highest_degree__c = tr.Highest_Degree__c;
        this.con.Please_select_your_age_range__c = tr.Age_Range__c;
        this.con.AVTRRT__Ethnicity__c = tr.Race_and_Ethnicity__c;
        this.con.Computer_Skills__c = tr.Computer_Skills__c;
        this.con.Professional_Skills__c = tr.Professional_Skills__c;
        this.con.Prior_IT_Work_Experience__c = tr.Prior_IT_Work_Experience__c;
        this.con.Prior_Work_Experience_Please_list_each__c = tr.List_Each_Prior_Work_Experience__c;
        this.con.What_employment_you_are_interested_in__c = tr.Employement_Interested_in__c;
        this.con.AVTRRT__Available_To_Start__c = tr.Availability_to_Start__c;
        this.con.Interested_in_volunteering_for_MR__c = tr.Interested_in_volunteering_for_MR__c;
        this.con.Interested_in_internship_with_MR__c = tr.Interested_in_internship_with_MR__c;
        this.con.Available_in_person_for_Training__c = tr.Available_in_person_for_Training__c;
        this.con.career_goals__c = tr.Career_goals__c;
        this.con.why_would_you_want_to_take_this_Training__c = tr.why_would_you_want_to_take_this_Training__c;         
        this.con.Training_form_submitted__c = Boolean.valueOf(true);
        this.con.Partner_Contact_Email__c = tr.Partner_Contact_Email__c;
       con.RecordTypeId = '01236000000h5PsAAI';
              
       System.debug('...Con Values ... :'+con);
       upsert con;
        //con.RecordType.DeveloperName = 'Candidate';
        
        PageReference ThankYouPage = new PageReference('/apex/ThankYouPageForTrainingForm?cId='+con.id+'&trainingForm='+trainingForm);
      
        ThankYouPage.setRedirect(true);
       
        return ThankYouPage;
    }
    
}