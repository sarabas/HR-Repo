public class CandidateReport_SocialMedia {
   
    public List<Contact> marketingCandidates = new List<Contact>();
    public List<Contact> marketingCandidatesSocial = new List<Contact>();
    public List<attachment> conAttchmnts = new List<attachment>();
    public string selCandId {get;set;}
	public string selCandMarkSummary {get;set;}
    public String selCandName {get;set;}
    public Id cId {get;set;}
    public boolean displayPopup {get; set;} 
    Public CandidateReport_SocialMedia(ApexPages.StandardController controller){
    }   
    public List<Contact> getMarketingCandidates() {
      marketingCandidatesSocial =  [SELECT Id,Name,Email,Phone,Certification__c,
                                			mailingcity,mailingstate,
                                         	AVTRRT__Candidate_Status__c,
                                            Candidate_Marketing_Summary__c,Twitter_Handle__c,
                                         	LinkedIn_URL__c,Trailhead_Profile_Link__c
                               				 FROM Contact WHERE ((Ready_to_Market__c = True) 
                                            AND (AVTRRT__Candidate_Status__c = 'Active')) order by name asc]; 
        marketingcandidates.clear();
                          
            integer i =1;
            for(contact c:marketingCandidatesSocial){                               
              contact temp= new contact();
                temp.Id=c.Id;
                temp.LastName='Candidate '+i;
                temp.Certification__c=c.Certification__c;
                temp.mailingcity=c.mailingcity;
                temp.mailingstate=c.mailingstate;
                temp.Candidate_Marketing_Summary__c=c.Candidate_Marketing_Summary__c;
                marketingCandidates.add(temp);
                 i++;
                //system.debug('temp'+temp.Name);
            }
       
      system.debug('candidatesListSocial:'+marketingCandidatesSocial);
       // System.debug('candidatesList:'+marketingCandidates);
        return marketingCandidates;
    }

    
    public void closePopup() {        
        displayPopup = false;     
    }     
    
    public void showPopup() {  
       	 for(contact c : marketingCandidates){
             if(selCandId==c.Id){
                 selCandMarkSummary=c.Candidate_Marketing_Summary__c;
                 selCandName=c.LastName;
             }       		
          }
        displayPopup = true;     
            
    }
    
   /* public String clickedCellValue { get; set; } 
    public  PageReference readCellMethod(){
    
    System.debug('#### clickedCellValue: ' + clickedCellValue);
    
    return null;
}*/


}