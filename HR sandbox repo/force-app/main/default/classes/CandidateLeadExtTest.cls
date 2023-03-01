@isTest
public class CandidateLeadExtTest {
    static testMethod void candtest(){
     
       Lead testLead = new Lead();
       testLead.FirstName = 'Test Lastname';
       testLead.LastName = 'Test Firstname';
       testLead.Company = 'Test Company';
       testLead.Phone = 'Test Phone';
       testLead.Connection_Name__c ='Connection Name';
       testLead.Connection_Email__c = 'Connection@email.com';
       testLead.Connection_Phone__c = 'Connection Phone';
       testLead.Relationship_to_Connection__c ='Relation to Connection';
       testLead.Title = 'Test Title';
       testLead.Email = 'Test@email.com'; 
       testLead.Mom__c = 'mom name';

       
       Test.startTest();
       ApexPages.StandardController sc = new ApexPages.StandardController(testLead); 
       CandidateLeadExt candLead = new CandidateLeadExt(sc);
       PageReference ref = Page.CandidateLead;
        Test.setCurrentPage(ref);
        candLead.save();
        
        Test.stopTest();
        
         }
    
}