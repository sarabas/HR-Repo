public class certificateAttachmentController 
{
    public Id sobjId; // record id of contact	
    public attachment attName {get; set;} // attachment to add
    List<Contact> updatedContactList = new List<Contact> ();
    String certName;
    //public boolean showError {get; set;}
    //Contact contact;
	// constructor
	public certificateAttachmentController(ApexPages.StandardController controller)
	{
        sobjId = controller.getId();
        attName = new attachment();
        //contact = controller.getRecord();
        
	}	
    	// Save action method
	public PageReference save()
	{ 
        Contact contact = new Contact();
        contact = [select id, Certification__c from Contact where id = :sobjId];
        if( attName.Name != null)
        {
            attName.parentId= sobjId;
       		certName = attName.Name;
 			insert attName;
        Schema.DescribeFieldResult certificationResult = Schema.SObjectType.Contact.fields.Certification__c;
        if(certificationResult != null) 
        {
            certificationResult = certificationResult.getSObjectField().getDescribe();
        }
        //System.debug('Check Point 2 :: certificationResult = ' + certificationResult);
        //Gets the picklist values from Certification field
        List<Schema.PicklistEntry> pickListValues = certificationResult.getpicklistvalues(); 
             certName = attName.Name;
            //Removes the pdf and docx extensions from the attachment name
            if ( certName.contains('.pdf')) 
            {
            	certName = certName.removeEnd('.pdf');
            }
            else if ( certName.contains('.docx'))
            {
            	certName = certName.removeEnd('.docx'); 
            }
             //gets the picklist values from the Certification field
             for(Schema.PicklistEntry setPickListVal : pickListValues)
             {
                 if( certName.equalsIgnoreCase(setPickListVal.getValue()))
                 {
                     //Checks if there are no certificates attached. If so, set the value to the attachment name
                     if(contact.Certification__c == null )
                     {
                         contact.Certification__c = setPickListVal.value;
                    }
                     else
                     {
                         String certVal = contact.Certification__c;
                         //If Picklist value already selected do not update the picklist value
                         if (!certVal.contains(setPickListVal.value))
                         {
                             //For Multiple certifications, concatinate with '; ' after the name. 
                             //Eg: Salesforce Admin; Salesforce Advanced Admin
                             contact.Certification__c = contact.Certification__c + '; '+ setPickListVal.value;
                         }
                     }
                 }
             }
            if( contact != null)
            {
                update contact;
            }
            return new PageReference('/' + sobjId);	
        }
        else{
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