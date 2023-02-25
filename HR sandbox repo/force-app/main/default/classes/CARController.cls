public without sharing class CARController {
    public List<Assessment__c> AssessmentList = new List<Assessment__c>();
    public Assessment__c assessment {get;set;}
    public String candidateName {get;set;}
 //   public String comments {get;set;}
    public Contact con;
   public Id contactId;
   
     public string sessionId {get;set;}
    public Date selectedAssessmentDate {get;set;}
    public Id selectedAssessmentId {get;set;}
    public Boolean refreshPage {get; set;}
    public String currentYear{get;set;}
    
    Public CARController(ApexPages.StandardController controller){
        this.contactId = apexpages.currentpage().getparameters().get('cId');
        
        this.con = (Contact)controller.getRecord(); 
        
       
        
        
        
        
        Contact tempContact = [SELECT Id,Name,FirstName,LastName FROM Contact where id=:this.contactId LIMIT 1];
        System.debug('tempContact :'+tempContact);
        this.candidateName = tempContact.Name;
        currentYear = String.valueOf(System.today().year());
        refreshPage=true;
    }
    public List<Assessment__C> getAssessments() {
        AssessmentList = [SELECT Name, Career_Assessment_Date__c, (SELECT Id,Name,FirstName,LastName,Career_Assessment__c FROM Candidates__r) 
                          FROM Assessment__c 
                          WHERE Career_Assessment_Date__c >= 2023-03-07
                          ORDER BY Career_Assessment_Date__c];
        System.debug('AssessmentList :'+AssessmentList);
        for(Assessment__c a: AssessmentList) {
            System.debug('Career Assessment Date : '+ a.Career_Assessment_Date__c);
            for(Contact c : a.Candidates__r) {
                System.debug('Candidates List : '+ c.Name);
            }
        }
        
        String cId =  apexpages.currentpage().getparameters().get('cId');
        
        System.debug('cId :'+cId);
        
      /*  Contact candidate = [select id,Name from contact where id =:cId limit 1];
        System.debug('Contact in constructor :'+con);
        this.CandidateName = candidate.Name;
        system.debug('###### currentPage contactId :'+contactId); */       
        return AssessmentList;
    }
    public PageReference saveRecord(){
        
        validate(selectedAssessmentDate);
        system.debug('###### selectedAssessmentDate :'+selectedAssessmentDate);
        system.debug('###### selectedAssessmentId :'+selectedAssessmentId);
        system.debug('###### update contact :'+con);
        con.Date_Registered_For_Candidate_Assesment__c=selectedAssessmentDate;
        //con.Career_Assessment__c = new Assessment__c();
        assessment= [select id from assessment__C where id=: selectedAssessmentId limit 1];
        //  selectedAssessmentId = con.Career_Assessment__c ;
        
     /*   if(this.comments!=null){
         con.AVTRRT__Notes_and_Comments__c=this.comments;   
        }else{
            this.comments=con.AVTRRT__Notes_and_Comments__c;
        }  */
        
        con.Career_Assessment__c = assessment.Id;
        system.debug('###### before update :'+con);
        system.debug('###### currentPage contactId :'+contactId);
        con.id=contactId;
        
        
        
        // update assessment;
     

        update con;
        
        
       
        PageReference ThankYouPage = new PageReference('/apex/ThankYouPage?cId='+con.id);
      //   if(ThankYouPage!=null){
      //       refreshPage=true;
      //  } 
        ThankYouPage.setRedirect(true);
       
        return ThankYouPage;
    }
    
    private PageReference validate(Date selectedAssessmentDate){
        PageReference returnPage= null;
        System.debug('validate method');
        if(selectedAssessmentDate==null){
            returnPage = new PageReference('/apex/ErrorPage');
            returnPage.setRedirect(true);
            return returnPage;
        }
        
        return returnPage;
    }
}