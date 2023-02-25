public class ThankYouPageController {
    public Contact con {get;set;}
    public string name {get;set;}
    public Date ConfirmedAssessmentDate {get;set;}
    Public ThankYouPageController(ApexPages.StandardController controller){
    //  this.con = (Contact)controller.getRecord(); 
    String cId =  apexpages.currentpage().getparameters().get('cId');
      con = [select id,FirstName,Name,Date_Registered_For_Candidate_Assesment__c from contact where id =:cId limit 1];
      System.debug('Contact in constructor :'+con);
        fetchDetails();
    }
    
    public ThankYouPageController fetchDetails() {
     	
        Id cId = Apexpages.currentPage().getParameters().get('cId');
      //  System.debug('cId :'+cId);
        con = [select id,FirstName,Name,Date_Registered_For_Candidate_Assesment__c from contact where id =:cId limit 1];
        this.name=con.Name;
        this.ConfirmedAssessmentDate = con.Date_Registered_For_Candidate_Assesment__c;
        System.debug('Contact in getFirstName :'+con);
        return this;
    }
  /*  public String fetchFirstName() {
     	
        Id cId = Apexpages.currentPage().getParameters().get('cId');
      //  System.debug('cId :'+cId);
        con = [select id,FirstName,Date_Registered_For_Candidate_Assesment__c from contact where id =:cId limit 1];
        this.FirstName=con.FirstName;
        return FirstName;
    }
    public Date fetchDate() {
     	
        Id cId = Apexpages.currentPage().getParameters().get('cId');
      //  System.debug('cId :'+cId);
        con = [select id,FirstName,Date_Registered_For_Candidate_Assesment__c from contact where id =:cId limit 1];
        this.FirstName=con.FirstName;
        this.ConfirmedAssessmentDate = con.Date_Registered_For_Candidate_Assesment__c;
        return ConfirmedAssessmentDate;
    }*/
   
}