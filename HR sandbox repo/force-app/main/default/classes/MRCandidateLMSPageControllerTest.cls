@isTest
private class MRCandidateLMSPageControllerTest {
@testSetup    static void setup(){
        //Insert Candidate Record
        Id RecTypeIdCandidate = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Contact con = new Contact(RecordTypeId =RecTypeIdCandidate,LastName ='LastNameTest',FirstName ='FirstNameTest',Highest_Degree__c ='Bachelors Degree');
        List<Contact> contactList = new List<Contact>{};
 		contactList.add(con);
        insert contactList;
		
		//Insert Learning Paths
        List<Learning_Path__c> allLearningPath = new List<Learning_Path__c>{};
		for(integer i=0;i<5;i++){
            Learning_Path__c learnPath = new Learning_Path__c();
            learnPath.Description__c = 'Learn Salesforce through trailhead';
            learnPath.Status__c = 'Active';
            if(i<4){
                learnPath.Name = 'Salesforce Platform Developer' + i;
            }
            else{
                learnPath.Status__c = 'Draft';
                learnPath.Name = 'Salesforce Administration' + i;
            }
            allLearningPath.add(learnPath);
        }
        System.debug('allLep' +allLearningPath);
        insert allLearningPath;
		
        //Insert Candidate Learning Paths
        List<Candidate_Learning_Path__c> candLearningPath = new List<Candidate_Learning_Path__c>{};
		for(integer i=0;i<2;i++){
            Candidate_Learning_Path__c candLP = new Candidate_Learning_Path__c();
            candLP.Candidate__c = con.Id;
            candLP.Learning_Path__c = allLearningPath[i].Id;
            candLP.Start_Date__c = Date.today();
            //candLP.End_Date__c = Date.today() + 20;
			candLearningPath.add(candLP);
            
        }
        System.debug('candLP' +candLearningPath);
        insert candLearningPath;
        
        //Insert Resources
        List<Resource__c> resourList = new List<Resource__c>{};
        for(integer i=0;i<6;i++){
            Resource__c res1 = new Resource__c();
            res1.URL__c = 'www.google.com';
            res1.Active__c = true;
			if(i<2){
                res1.Name = 'Salesforce Developer' +i;
                res1.Description__c = 'Salesforce Dev through career circle';
                res1.Resource_Type__c = 'Webinar';
            }
            else if (i==3){
                res1.Name = 'Salesforce Sales Cloud';
                res1.Description__c = 'Salesforce Sales Cloud through Udacity';
                res1.Resource_Type__c = 'Online Resource';
            }
            else{
                res1.Name = 'Salesforce Administrator' +i;
                res1.Description__c = 'Salesforce Admin through career circle';
                res1.Resource_Type__c = 'Hybrid';

            }
            resourList.add(res1);
        }
        insert resourList;
         //Insert Learning Path Resource
        List<Learning_Path_Resource__c> resourcesLP = new List<Learning_Path_Resource__c>{};
		for(integer i=0;i<3;i++){
            Learning_Path_Resource__c resources = new Learning_Path_Resource__c();
            resources.Learning_Path__c = allLearningPath[i].Id;
            resources.Resource__c = resourList[i].Id;        
            resourcesLP.add(resources) ;
        }
        insert resourcesLP;
        
        List<Candidate_Achievement__c> candAchievements = new List<Candidate_Achievement__c>{};
		for(integer i=0;i<2;i++){
            Candidate_Achievement__c candAchievement = new Candidate_Achievement__c();
            //candAchievement.Achievement__c = ach[i].Id;
            //System.debug('achievement' +candAchievement.Achievement__c );
            candAchievement.Achievement_Name__c = 'Salesforce Admin';
            candAchievement.Achievement_Type__c = 'Superbadge';
            candAchievement.Date__c = Date.today();
            candAchievement.Description__c = 'Careercircle badge';
            candAchievement.Candidate__c = con.Id;
            candAchievements.add(candAchievement);
         }
       insert candAchievements;
        List<Learning_Path_Access_Request__c> lprequest = new List<Learning_Path_Access_Request__c>{};
        Learning_Path_Access_Request__c accessReq = new Learning_Path_Access_Request__c();
        accessReq.Candidate__c = con.Id;
        accessReq.Learning_Path__c = allLearningPath[2].Id;
        accessReq.Requested_On__c = Date.today();
        lprequest.add(accessReq);
        insert lprequest;
    }
    
    @isTest    
    static void candidateLMSPageEnd2EndTest(){
        Contact cand = [SELECT id,Name,FirstName,LastName 
                        FROM Contact 
                        WHERE FirstName='FirstNameTest' 
                        LIMIT 1];

        PageReference pageRef = Page.DesignForm;
        pageRef.getParameters().put('cId',cand.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller = new ApexPages.StandardController(new Candidate_Learning_Path__c());
        MRCandidateLMSPageController mrLMSPage = new MRCandidateLMSPageController(controller);
        
        //Update the My Learning Path table
        List<Candidate_Learning_Path__c> candLearPath = mrLMSPage.getCandidateLearningPath();
        System.assertequals(2,candLearPath.size());
        
        //Update the resources table based on the selected learning path 
        mrLMSPage.selLPName = candLearPath[0].Learning_Path__r.Name;
        List<Learning_Path_Resource__c> lpRes = mrLMSPage.getResources();
    	System.assertequals(1,lpRes.size());
        
        //Update Available learning paths
        List<Learning_Path__c> allLearPath = mrLMSPage.getAllLearningPaths();
        System.debug('all' +allLearPath);
        System.assertequals(2,candLearPath.size());
        
        //Update the Achievements table
        List<Candidate_Achievement__c> achievement = mrLMSPage.getAchievements();
        System.assertEquals(2, achievement.size());
        
        //Check if Resources section is visible
        mrLMSPage.openResources();
        
        //Check if the Status update is saved
        candLearPath[0].My_Training__c = 'Completed';
        mrLMSPage.saveStatus();
        
        //Show the popup for getting feedback
        mrLMSPage.selLPName = candLearPath[0].Learning_Path__r.Name;
        mrLMSPage.showPopup();
        mrLMSPage.getFeedbackAnswerOptions();
        
        //Check with all answers
        mrLMSPage.feedback = new Feedbacks__c(X1_Answer__c = 'Yes',X2_Answer__c ='No',X3_Answer__c ='No',X4_Answer__c ='No',X5_Answer__c ='Maybe');
        mrLMSPage.saveFeedback();
        
        //Check with partially filled answers
        mrLMSPage.feedback = new Feedbacks__c(X1_Answer__c = 'Yes',X4_Answer__c ='No',X5_Answer__c ='Maybe');
        mrLMSPage.saveFeedback();
        System.assertEquals(true, mrLMSPage.displayError);
        
        //Check for Learning Path requests
        List<Learning_Path_Access_Request__c> access = mrLMSPage.getrequestedLearningPaths();
        System.assertEquals(1, access.size());
        
        //Request a learning path
        mrLMSPage.selLPName = allLearPath[0].Name;
        mrLMSPage.RequestforNewLearningPath();
		mrLMSPage.showThankYouPopup();
        system.assertEquals(true, mrLMSPage.sameLPName);
        
        //Diff LP Name
        mrLMSPage.selLPName = allLearPath[1].Name;
        mrLMSPage.showThankYouPopup();
        System.assertEquals(true, mrLMSPage.newLPName);
        
        //close pop up
        mrLMSPage.closePopup();
        System.assertEquals(false, mrLMSPage.displayPopUp);
        
        //Close Thank you pop up
        mrLMSPage.closePopupThankYou();
        System.assertEquals(false, mrLMSPage.displayThankyouPopUp);
        
        //New Achievement
        mrLMSPage.showAchievementPopup();
        Candidate_Achievement__c candAchievement = new Candidate_Achievement__c();
        candAchievement.Achievement_Name__c = 'Salesforce Dev';
        candAchievement.Achievement_Type__c = 'Superbadge';
        candAchievement.Date__c = Date.today();
        candAchievement.Description__c = 'Careercircle badge';
        candAchievement.Candidate__c = cand.Id;
        mrLMSPage.addNewAchievement = candAchievement;
        mrLMSPage.addNewAchievement();
        system.assertEquals(false, mrLMSPage.displayAchievementPopup);
        
        //Close the pop up
        mrLMSPage.closeAchievementPopup();
        system.assertEquals(false, mrLMSPage.displayAchievementPopup);
    }
}