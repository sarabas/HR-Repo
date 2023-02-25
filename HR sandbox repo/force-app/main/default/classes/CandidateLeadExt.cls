public class CandidateLeadExt {
   
    public Lead cand {get; set;}
    public string leadid {get; set;}    
    
    public CandidateLeadExt(ApexPages.StandardController controller) {
        cand = (Lead)controller.getRecord();
        leadid = Apexpages.currentpage().getparameters().get('cId');
        System.debug(leadid);
        if (leadid != null){
        String leadname = [Select Name from Contact where Id = :leadid].Name;  
        cand.Mom__c =  leadname;
             
        }
    }
       
    public PageReference save(){
      
     Id conrecordtypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Connections').getRecordTypeId();
     cand.RecordTypeId = conrecordtypeid; 
       //cand.RecordTypeId = '012530000008U5bAAE';
       cand.LeadSource = 'Connections';
        cand.CId__c = leadid;
        insert cand;
        leadid = cand.Id;
        PageReference tempPage = ApexPages.currentPage();            
        tempPage.setRedirect(true);
        //return null;
       return Page.Thankyou;
        //redirects to lead page with record id
        //return new PageReference('/' + cand.Id;
        //return setRedirect(true);
       
    }
}