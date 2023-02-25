public without sharing class CandidatesReport {
    public List<Contact> marketingCandidates = new List<Contact>();
    public List<attachment> conAttchmnts = new List<attachment>();
    public string selCandId {get;set;}
	public string selCandMarkSummary {get;set;}
    public String selCandName {get;set;}
    public String selCandEmail {get;set;}
    public String selCandPhone {get;set;}
    public String selCandLinkedIn {get;set;}
    public String selCandTwitter {get;set;}
    public Id AttachId {get;set;}
    public Id cId {get;set;}
    public boolean displayPopup {get; set;} 
    public CandidatesReport(){}
    Public CandidatesReport(ApexPages.StandardController controller){
    }   
    public List<Contact> getMarketingCandidates() {
        marketingCandidates =  [SELECT Id,Name,Email,Phone,Certification__c,
                                			mailingcity,mailingstate,
                                         	AVTRRT__Candidate_Status__c,
                                            Candidate_Marketing_Summary__c,Twitter_Handle__c,
                                         	LinkedIn_URL__c,Trailhead_Profile_Link__c,
                               				 (select attachment.id, attachment.name from attachments 
                                              where (attachment.name like 'tr__%resume%') and 
                                              (attachment.contenttype='application/pdf')  
                                              order by attachment.CreatedDate Desc limit 1 )
                               			    FROM Contact WHERE ((Ready_to_Market__c = True) 
                                            AND (AVTRRT__Candidate_Status__c = 'Active')) order by name asc]; 
             

       system.debug('attachmentname:'+conAttchmnts);
        System.debug('candidatesList:'+marketingCandidates);
        return marketingCandidates;
    }

    
    public void closePopup() {        
        displayPopup = false;     
    }     
    
    public void showPopup() {  
       	 for(contact c : marketingCandidates){
             if(selCandId==c.Id){
                 selCandMarkSummary=c.Candidate_Marketing_Summary__c;
                 selCandName=c.Name;
                 selCandEmail=c.Email;
                 selCandPhone=c.Phone;
                 selCandLinkedIn=c.LinkedIn_URL__c;
                 selCandTwitter=c.Twitter_Handle__c;
                 for(attachment a :c.attachments ){
           		 AttachId = a.Id;
                 conAttchmnts.add(a);
        		}
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