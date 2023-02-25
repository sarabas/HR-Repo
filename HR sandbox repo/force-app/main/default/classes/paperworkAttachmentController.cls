public class paperworkAttachmentController {
    public Id sobjId; // record id of contact	
    public attachment att1 {get; set;} // attachment to add
    public attachment att2 {get; set;} // attachment to add   
    
	// constructor
	public paperworkAttachmentController(ApexPages.StandardController controller)
	{
        sobjId = controller.getId();
        att1 = new attachment();
        att2 = new attachment();       
	}	
	
	// Save action method
	public PageReference save()
	{          
        boolean containsSOP = false;
   		boolean containsAgreement = false;
        Contact con = new contact();
        
        if (att1.name.touppercase().contains('SOP'))
	       containsSOP = true;            	
        if (att2.name.touppercase().contains('AGREEMENT'))
    	   containsAgreement = true;
        
        if(containsSOP && containsAgreement)
        {
            //insert attachments with parent id as contact id
            att1.parentId=sobjId;
			insert att1;            
            att2.parentId=sobjId;
            insert att2;        	
            
            //update MR Agreement Signed and MR Agreement Signed date values for parent contact
           	con = [select firstname from Contact where id = :sobjId];
        	con.MR_Agreement_Signed__c = true;
        	con.MR_Agreement_Signed_Date__c = date.today();
        	update con;            
            
            return new PageReference('/' + sobjId);			
        } else {            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'One of the files seems missing. Please upload both the files.'));          
            return null;
        }		        
    }     
    
    // Close action method
    public PageReference close()
	{
		// send the user to the detail page for the sobject
		return new PageReference('/' + sobjId);		
	}
}