@isTest
public class TrainingControllerTest {
    public static Contact c;
    public static Training__c tr;
    public static TrainingController trainingCtrl;
    
     @testSetup static void setup() {
          tr = new Training__c();
        tr.First_Name__c='Test1';
        tr.Last_Name__c='User1';
        tr.Highest_Degree__c='High School';
        
                 
        c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'User';
        c.Highest_Degree__c = 'Bachelors Degree';
         //c.Training_Intereste__c = 'QA Automation Training';
         c.Training_Intereste__c = 'Career Circle';
         c.RecordTypeId = '01236000000h5PsAAI';
          c.email = 'test@gmail.com';
          c.Partner_Contact_Email__c = 'partnertest@gmail.com';
         c.Training_Partners__c = '0013u00000yWdQNAA0';
         try{
        insert c;
         } catch(Exception e){
             System.debug('Insert exception is ' + e.getMessage());
         }
    }

  
    
     @isTest 
    static void saveRecordExistingMomTest() {
        test.startTest();
        Contact testContact = [SELECT Id,firstname,lastname,email,phone,AVTRRT__City__c,AVTRRT__State__c,AVTRRT__Postal_Code__c,
                    Highest_Degree__c,Please_select_your_age_range__c,AVTRRT__Ethnicity__c,Computer_Skills__c,
                    Professional_Skills__c,Prior_Work_Experience_Please_list_each__c,What_employment_you_are_interested_in__c,
                    AVTRRT__Available_To_Start__c,Interested_in_volunteering_for_MR__c,Interested_in_internship_with_MR__c,
                    Available_in_person_for_Training__c,Training_Partners__c,Partner_Contact_Email__c,career_goals__c,why_would_you_want_to_take_this_Training__c,Training_Intereste__c
                    FROM Contact 
                    WHERE FirstName='Test'];
        
        PageReference pageRef = Page.ThankYouPageForTrainingForm;
        pageRef.getParameters().put('cId',testContact.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testContact);
        trainingCtrl = new TrainingController(controller);
        trainingCtrl.trainingForm='Career Circle';
        
        System.debug(' Calling Controller Save Record method----------->');
        trainingCtrl.saveRecord();
        
        Contact fetchContact = [SELECT Id,firstname,lastname,email,phone,AVTRRT__City__c,AVTRRT__State__c,AVTRRT__Postal_Code__c,
                    Highest_Degree__c,Please_select_your_age_range__c,AVTRRT__Ethnicity__c,Computer_Skills__c,
                    Professional_Skills__c,Prior_Work_Experience_Please_list_each__c,What_employment_you_are_interested_in__c,
                    AVTRRT__Available_To_Start__c,Interested_in_volunteering_for_MR__c,Interested_in_internship_with_MR__c,
                    Available_in_person_for_Training__c,Partner_Contact_Email__c,why_would_you_want_to_take_this_Training__c,training_Intereste__c,RecordTypeId
                    FROM Contact 
                    WHERE FirstName='Test'];
        
         System.debug('contact object after save :'+fetchContact);
        System.debug('contact object trainingForm :'+fetchContact.Training_Intereste__c);
         System.debug('contact record typeid :'+fetchContact.RecordTypeId);
       
        RecordType recordType = [SELECT Id,name from RecordType where Id=:fetchContact.RecordTypeId limit 1];
        
        System.assertEquals('Career Circle',String.valueOf(fetchContact.Training_Intereste__c));
        System.assertEquals('Candidate',recordType.Name);
        
        test.stopTest();
    }
    
     @isTest 
    static void saveRecordNewMomTest() {
        test.startTest();
        
        Training__c newTr = new Training__c();
        newTr.First_Name__c='Test1';
        newTr.Last_Name__c='User1';
        newTr.Highest_Degree__c='High School'; 
          newTr.email__c = 'test12@gmail.com';
		 newTr.Partner_Contact_Email__c = 'partnertest@gmail.com';
         newTr.Training_Partners__c = '0013u00000yWdQNAA0';
        Contact con = new Contact();
 
        
        
        //testContact.Training_Intereste__c='Career Circle Training for Admins';
        PageReference pageRef = Page.ThankYouPageForTrainingForm;
        //pageRef.getParameters().put('cId',testContact.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(con);
        trainingCtrl = new TrainingController(controller);
        trainingCtrl.trainingForm='Career Circle';
        trainingCtrl.tr = newTr;
        //trainingCtrl.con.
        trainingCtrl.saveRecord();
        
        Contact fetchContact = [SELECT Id,firstname,lastname,email,phone,AVTRRT__City__c,AVTRRT__State__c,AVTRRT__Postal_Code__c,
                    Highest_Degree__c,Please_select_your_age_range__c,AVTRRT__Ethnicity__c,Computer_Skills__c,
                    Professional_Skills__c,Prior_Work_Experience_Please_list_each__c,What_employment_you_are_interested_in__c,
                    AVTRRT__Available_To_Start__c,Interested_in_volunteering_for_MR__c,Interested_in_internship_with_MR__c,
                    Available_in_person_for_Training__c,Training_Partners__c, Partner_Contact_Email__c,why_would_you_want_to_take_this_Training__c,training_Intereste__c,RecordTypeId
                    FROM Contact 
                    WHERE FirstName='Test1'];
        
         System.debug('contact object after save :'+fetchContact);
        System.debug('contact object trainingForm :'+fetchContact.Training_Intereste__c);
         System.debug('contact record typeid :'+fetchContact.RecordTypeId);
       
        RecordType recordType = [SELECT Id,name from RecordType where Id=:fetchContact.RecordTypeId limit 1];
        
        System.assertEquals('Career Circle',String.valueOf(fetchContact.Training_Intereste__c));
        System.assertEquals('Candidate',recordType.Name);
        
        test.stopTest();
    }
}