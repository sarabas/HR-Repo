@isTest
public class TestCheckWordCount {
    @isTest static void TestBeforeInsertWithOneWord(){
        //Create Test Leads
        Lead leads = new Lead(LastName='LN10', FirstName='FN10', Company='Test Company', Status='Open', Email ='1@abc.com', Phone='1111111111', Notes_Comments__c ='Test');
        try{
        if(Test.isRunningTest())
        {
            insert leads;
        }
        }
        catch(DMLException e){
          
                System.assert(e.getMessage().contains('The word count is 1')); 
        }    
    }
   
    @isTest static void TestBeforeUpdateWithOneWord(){
        //Update Test Lead 
        Lead leads = new Lead(LastName='LN20', FirstName='FN20', Company='Test Company', Status='Open', Email ='1@abc.com', Phone='1111111111');
        insert leads;
        leads.Notes_Comments__c ='Test';
       
        Test.startTest();
        try{
        if(Test.isRunningTest())
        {
            update leads;
        }
        }
        catch(DMLException e){
          
                System.assert(e.getMessage().contains('The word count is 1')); 
        }    
        Test.stopTest();        
    }    
}