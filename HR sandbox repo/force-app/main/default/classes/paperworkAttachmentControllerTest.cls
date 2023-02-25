@isTest
public class paperworkAttachmentControllerTest {
    static testMethod void paperworkCorrectAttach(){
        
        //Insert Candidate Record
        Id RecTypeIdCandidate = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        Contact con = new Contact(RecordTypeId =RecTypeIdCandidate,LastName ='LastNameTest',FirstName ='FirstNameTest',Highest_Degree__c ='Bachelors Degree');
         insert con;
        
        //Insert both Attachments
        Attachment attach1=new Attachment();       
        attach1.Name='MOM Relaunch Program - SOP';
        Blob bodyBlob=Blob.valueOf('MOM Relaunch Program - SOP');
        attach1.body=bodyBlob;
        attach1.parentId=con.id;
        
        Attachment attach2=new Attachment();     
        attach2.Name = 'Job Training and Placement Services Agreement';
        Blob bodyBlob2=Blob.valueOf('Job Training and Placement Services Agreement Body');
        attach2.body=bodyBlob2;
        attach2.parentId=con.id;
      
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(con);
        paperworkAttachmentController ctr = new paperworkAttachmentController(stdCtr);
        ctr.att1 = attach1;
        ctr.att2 = attach2;
        ctr.save(); 
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:con.id];
        System.assertEquals(2, attachments.size());
        ctr.close();
    }
    
    static testMethod void paperworkIncorrectAttach(){
        
        Id RecTypeIdCand = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
       
         //Insert Candidate Record
        Contact con2 = new Contact(RecordTypeId = RecTypeIdCand,LastName ='Test2',FirstName ='Test2',Highest_Degree__c ='Bachelors Degree');
         insert con2;

        Attachment attach3=new Attachment();       
        attach3.Name='MOM Relaunch Program';
        Blob bodyBlob3=Blob.valueOf('MOM Relaunch Program');
        attach3.body=bodyBlob3;
        attach3.parentId=con2.id;
        
         // Insert Incorrect Attachments
        ApexPages.StandardController stdCtr2 = new ApexPages.StandardController(con2);
        paperworkAttachmentController ctr2 = new paperworkAttachmentController(stdCtr2);
        ctr2.att1 = attach3;
        ctr2.att2 = attach3;
        ctr2.save(); 
         List<Attachment> attachfail=[select id, name from Attachment where parent.id=:con2.id];
        System.assertEquals(0, attachfail.size());
    }
}