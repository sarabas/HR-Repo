@isTest
private class CandidateReport_SocialMediaTest {
    public static String selConIdP;
    public static String selConIdN;
    
        
     @testSetup static void setup() {
                       
         //inserting two contacts with Ready_To_Market=TRUE with attachments
         for(integer i=0;i<2;i++){
             Contact  c = new Contact();
             c.FirstName = 'TestRMRP'+i;
       		 c.LastName = 'User'+i;
             c.Email= 'testRMRPemail'+i+'@gmail.com';
             c.MailingState='teststate';
             c.Candidate_Marketing_Summary__c='test tests';
             c.Ready_to_Market__c=true;
       	     c.AVTRRT__Candidate_Status__c = 'Active';
         	 c.MailingCity='testcity';
         	 insert c;
             selConIdP=c.Id;
          
             //database.SaveResult[] results= database.insert(new SObject[] { c, a});
         }
      
         //inserting two contacts with Ready_To_Market=FALSE with attachments 
        for(integer i=2;i<4;i++){
             Contact  c = new Contact();
             c.FirstName = 'TestRMRN'+i;
       		 c.LastName = 'User'+i;
             c.Email= 'testemailRMRN'+i+'@gmail.com';
             c.MailingState='teststate';
             c.Candidate_Marketing_Summary__c='test tests';
             c.Ready_to_Market__c=false;
       	     c.AVTRRT__Candidate_Status__c = 'Active';
         	 c.MailingCity='testcity';
            insert c;
             
            //database.SaveResult[] results= database.insert(new SObject[] { c, a});
         } 
    }
    
    
	@isTest
    static void getMarketingCandidatesTest() {
         boolean displayPopup;
        
        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(new Contact());
        CandidateReport_SocialMedia cr = new CandidateReport_SocialMedia(controller);
        List<Contact> marketingCandidatesList = cr.getMarketingCandidates();
        System.debug('Returned marketingCandidatesList : '+ marketingCandidatesList);
        System.assertEquals(2, marketingCandidatesList.size());
        
        String selMarCandId= marketingCandidatesList[0].Id;
        String selCandMarkSummary=marketingCandidatesList[0].Candidate_Marketing_Summary__c;
                
        //testing positive case
        displayPopup=true;
        cr.selCandId=selMarCandId;
        if(displayPopup){
            cr.showPopup();          
            System.assertEquals(displayPopup, cr.displayPopup);
            system.debug('selCanId: '+selMarCandId);            
            system.debug('selCanId from apex: '+cr.cId);
            System.assertEquals(selMarCandId,cr.selCandId);
            
            system.debug('selCanMArketing Summary : '+selCandMarkSummary);
            system.debug('selCanMArketing Summary from apex: '+cr.selCandMarkSummary);
            System.assertEquals(selCandMarkSummary,cr.selCandMarkSummary  );
        		
        }
        
        //testing the displaypopup = false case
        displayPopup=false;
        if(!displayPopup){
            cr.closePopup();
            System.assertEquals(displayPopup, cr.displayPopup);
        }        
        
        Test.stopTest();
        
}

}