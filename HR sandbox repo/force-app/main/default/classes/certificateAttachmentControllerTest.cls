@isTest
public class certificateAttachmentControllerTest {
    static testMethod void certAttach()
    {
        //Insert Candidate Record
        Id RecTypeIdCandidate = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Contact con = new Contact(RecordTypeId =RecTypeIdCandidate,LastName ='LastNameTest',FirstName ='FirstNameTest',Highest_Degree__c ='Bachelors Degree');
         insert con;
        
        //Insert both Attachments
        Attachment attach1=new Attachment();       
        attach1.Name='Salesforce Advanced Admin.pdf';
        Blob bodyBlob=Blob.valueOf('Salesforce Advanced Admin');
        attach1.body=bodyBlob;
        attach1.parentId=con.id;
        
        Attachment attach2=new Attachment();       
        attach2.Name='Salesforce Admin.docx';
        Blob bodyBlob1=Blob.valueOf('Salesforce Admin');
        attach2.body=bodyBlob1;
        attach2.parentId=con.id;
        
        Attachment attach3=new Attachment();       

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(con);
        certificateAttachmentController ctr = new certificateAttachmentController(stdCtr);
        ctr.attName = attach1;
        ctr.save(); 
        
        certificateAttachmentController ctr1 = new certificateAttachmentController(stdCtr);
        ctr1.attName = attach2;
        ctr1.save(); 
        
        certificateAttachmentController ctr2 = new certificateAttachmentController(stdCtr);
        ctr2.attName = attach3;
        ctr2.save(); 
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:con.id];
      	System.assertEquals(2, attachments.size());
        ctr.close();
        
    }
}