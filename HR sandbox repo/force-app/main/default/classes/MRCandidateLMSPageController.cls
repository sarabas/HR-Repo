public class MRCandidateLMSPageController {
    public List<Contact> contactList = new List<Contact>{};
    public List<Candidate_Learning_Path__c> candLearningPath = new List<Candidate_Learning_Path__c>{};
    public List<Learning_Path__c> allLearningPath = new List<Learning_Path__c>{};
    public List<Learning_Path_Resource__c> resources = new List<Learning_Path_Resource__c>{};
    public List<Candidate_Achievement__c> candAchievements = new List<Candidate_Achievement__c>{};
    public Feedbacks__c  feedback{get;set;}
    public Candidate_Achievement__c addNewAchievement{get;set;}
    public boolean candidateFound{get;set;}
    public string contactId {get;set;}   
    public string candFirstName{get;set;}
    public string candEmail {get;set;}
    public string candName {get;set;}
    public string selLPName{get;set;}
    public boolean showResforLP{get;set;}
    public String resourcesName{get;set;}
    public boolean hideResources{get;set;}
    public boolean displayPopUp{get;set;}
    public boolean displayError{get;set;}
    public Learning_Path_Access_Request__c requestLearningPath{get;set;}
    public boolean displayThankyouPopUp{get;set;}
    public List<Learning_Path_Access_Request__c> learningPathRequests = new List<Learning_Path_Access_Request__c>{};
    public boolean sameLPName{get;set;}
    public boolean newLPName{get;set;}
    public boolean displayAchievementPopup{get;set;}
    public string selectedTab{get;set;}
    
    public MRCandidateLMSPageController(ApexPages.StandardController controller){
        candidateFound = false;
        //Initialize from Link parameters
        contactId =  apexpages.currentpage().getparameters().get('cId');
        resourcesName = 'Resources';
        showResforLP = false;
        hideResources = true;
        feedback = new Feedbacks__c();
        displayError = true;
        selectedTab = 'mylearningPath';
        If(contactId != null){
            //Get the Candidate details
            candidateFound = true;
            List<Contact> Candidate = [SELECT Id,FirstName,Name,Email
                                       FROM Contact
                                       WHERE Id =:contactId LIMIT 1];
            candFirstName = Candidate[0].FirstName;
            candEmail =   Candidate[0].Email;
            candName =    Candidate[0].Name;
        }   
    }
    
    //Method to get the list of Learning paths assigned to a candidate
    public List<Candidate_Learning_Path__c> getCandidateLearningPath(){
        selectedTab = 'mylearningPath';
        hideResources = true;
        candLearningPath.clear();
        //Get the list of learning paths assigned to the candidate using the Candidate learning path object
        candLearningPath = [SELECT Learning_Path__r.Name,Name, Start_Date__c, 
                                 End_Date__c,My_Training__c FROM Candidate_Learning_Path__c WHERE Candidate__c = :contactId]; 
        System.debug('GetCandidateLearningPath' +candLearningPath);
        return candLearningPath;
    }
    
    //Method to get all the available learning paths
    public List<Learning_Path__c> getAllLearningPaths(){
        selectedTab = 'allLearningPathTab';
        allLearningPath.clear();
        List<String> availLPName = new List<String>{};
            if(candLearningPath != null){
                for(Candidate_Learning_Path__c clp : candLearningPath) {
                    availLPName.add(clp.Learning_Path__r.Name);
                }
            }
            allLearningPath = [SELECT Name,Description__c, Status__c FROM Learning_Path__c WHERE Name NOT in :availLPName AND Status__c != 'Draft'  ];
		System.debug('getAllLearningPaths' +allLearningPath);
        return allLearningPath;
    }
    
    //Method to get the resources associated with a learning path
    public List<Learning_Path_Resource__c> getResources(){
           resources.clear();
           if(selLPName != null) {
               //showResforLP = true;//boolean to show/hide the resources table
                resourcesName = selLPName + ' >> ' + 'Resources';
                resources = [SELECT Name, Description__c, Resource__r.Name, Resource__r.URL__c, Resource__r.Resource_Type__c, Resource__r.Source__c FROM Learning_Path_Resource__c 
                     WHERE Learning_Path__r.Name = :selLPName];

          }
        System.debug('getResources' +resources);
        return resources;
    }
    
    //Method to get the list of achievements done by the candidate
    public List<Candidate_Achievement__c> getAchievements(){
        selectedTab = 'achievementsTab';
        candAchievements.clear();
        candAchievements = [Select Name,  Achievement_Name__c, Achievement_Type__c,Candidate__c, Date__c, Description__c From Candidate_Achievement__c WHERE Candidate__c = :contactId];
        System.debug('getAchievements' +candAchievements);
        return candAchievements;
    }
    
    //Method invoked when a learning path name link is clicked. When clicked, the resources table is shown
    public void openResources(){
        showResforLP = true;//boolean to show/hide the resources table
        selectedTab = 'mylearningPath';
    }
    
    //Update the status of the learning path when the user changes the status.
    public PageReference saveStatus(){
        update candLearningPath;
        selectedTab = 'mylearningPath';
        System.debug('Update candLearningPath' +candLearningPath);
        return null;
        //return System.currentPageReference().setRedirect(false);    
    }
	
    //Method invoked when Feedback button is clicked. The list of 
    public void showPopup(){
        feedback = new Feedbacks__c();
        displayError = false;
        displayPopup = true;
    }
    
    public void showThankYouPopup(){
        newLPName = true;
        sameLPName = false;
        if( learningPathRequests!= null ){
            for(Learning_Path_Access_Request__c acReq : learningPathRequests ){
                if( selLPName!= null && acReq.Learning_Path__r.Name == selLPName){
                    sameLPName = true;
                    newLPName = false;
                    break;
                }
            }
        }
        if(newLPName){
            RequestforNewLearningPath();
        }
        displayThankyouPopUp = true;
    }
    
    public void closePopup() {
        displayPopup = false;
    }
    
    public PageReference closePopupThankYou(){
        displayThankyouPopUp = false;
        /*selectedTab = 'allLearningPathTab';
        //PageReference page = new PageReference('/apex/MRCandidateLMSPage');//pageReference ('/apex/OpportunityPage');
        PageReference page = ApexPages.currentPage();
        page.getParameters().put('cId',+contactId);
        page.setRedirect(true);
        return page;*/
        return null;
    }
        public PageReference closeAchievementPopup(){
        displayAchievementPopup = false;
        selectedTab = 'achievementsTab';
            return null;
    }
    public void saveFeedback(){
        if(feedback.X1_Answer__c == null || feedback.X2_Answer__c == null || feedback.X3_Answer__c == null || feedback.X4_Answer__c == null || feedback.X5_Answer__c == null){
            displayError = true;//Show error message if all the answers are not selected. Error message is displayed using a outputLable in VFPage
        }
        else{
            //Create a new feedback object with the infomration provided by the candidate and insert/update the feedback object
            //feedback = new Feedbacks__c();
            if (candLearningPath != null){
                for(Candidate_Learning_Path__c clp : candLearningPath) {
                    if (selLPName!= null && clp.Learning_Path__r.Name == selLPName){//get the selected learning path 
                        feedback.Learning_Path__c = clp.Learning_Path__c;
                        feedback.Contact_Candidate__c = contactId;
                        break;
                    }
                }
            }
            System.debug('New Feedback'+feedback);
            upsert feedback;
            displayPopup = false;//hide the pop up after save operation is done
        }
    }
    
    //Method to get the feedback answer questions. All the five answers follow the same set of answers. So we are just getting the options from one field
    public List<SelectOption> getFeedbackAnswerOptions(){
            Schema.sObjectType sobject_type = Feedbacks__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
          
            List<Schema.PicklistEntry> pick_list_values = field_map.get('X1_Answer__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();//get the list of picklist values as options to show as a radio button

           for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
          }
        System.debug('Feedback Options' +options);
      return options;//Used to show the radio buttons in the feedback page
    }
    
    public List<Learning_Path_Access_Request__c> getrequestedLearningPaths(){
        learningPathRequests.clear();
        learningPathRequests = [SELECT Id, Learning_Path__r.Name, Requested_On__c, Status__c, Comments__c,Candidate__c FROM Learning_Path_Access_Request__c WHERE Candidate__c = :contactId];
        System.debug('Get Requested Learning Paths' +learningPathRequests);
        return learningPathRequests;
    }
    
    //Method to request for a new learning path when 'Request' button is clicked under 'Available learning paths'.
    public void RequestforNewLearningPath(){
        requestLearningPath = new Learning_Path_Access_Request__c();
        String para = ApexPages.CurrentPage().getParameters().get('reqLPName');
        if (allLearningPath != null){
         for(Learning_Path__c lp : allLearningPath) {
             if (selLPName!= null && lp.Name == selLPName){//get the selected learning path 
                    requestLearningPath.Learning_Path__c = lp.Id;
                    requestLearningPath.Candidate__c = contactId;
                    requestLearningPath.Requested_On__c = Date.today();
                    System.debug('Requested Learning Path'+requestLearningPath);
        			insert requestLearningPath;
                    break;
                }
            }
        }
    }
    //Method to show Achievement Pop up to add new achievement
    public void showAchievementPopup(){
       addNewAchievement = new Candidate_Achievement__c();
       displayAchievementPopup = true;
    }
    //Method to add new achievement
    public PageReference addNewAchievement(){
        addNewAchievement.Candidate__c = contactId;
        System.debug('New Achievement'+addNewAchievement);
        insert addNewAchievement;
        displayAchievementPopup = false;
        selectedTab = 'achievementsTab';
        return null;
    }
}