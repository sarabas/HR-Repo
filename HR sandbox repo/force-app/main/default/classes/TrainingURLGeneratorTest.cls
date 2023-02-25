@isTest
public class TrainingURLGeneratorTest {
    public static Contact c = new Contact();
    public static Training__c tr;
    public static TrainingController trainingCtrl;
    
    @testSetup 
    static void setup() {
          tr = new Training__c();
        tr.First_Name__c='Test1';
        tr.Last_Name__c='User1';
        tr.Highest_Degree__c='High School';


         
       // c = new Contact();
        c.FirstName = 'Test123';
        c.LastName = 'User';
        c.Highest_Degree__c = 'Bachelors Degree';
         c.Training_Intereste__c = 'QA Automation Training';
         c.RecordTypeId = '01236000000h5PsAAI';
        c.email = 'test@gmail.com';
        c.Partner_Contact_Email__c ='partnertest@gmail.com';
        
        try{
        insert c;
        } catch(Exception e){
            System.debug('Insert contact Exception' + e.getMessage());
        }
    }

    @isTest
    static void generateURLTest(){
         test.startTest();
        
        Contact con = [SELECT Id,FirstName,Training_Intereste__c,Training_Links__c
                    FROM Contact 
                    WHERE FirstName='Test123'];
        
        
        
        System.debug('fetched contact : '+con);
      
        /* As we have defined process builder "Update Training Interested" on the Training_Interested filed, we need not to call the generateURL part of TrainingURLGenerator. */
       /* As part of setup method when we create contact, training url will be generated. */
      /*  List<Id> conIds = new List<Id>();
        conIds.add(con.Id);
        TrainingURLGenerator.generateURL(conIds);*/

        String expectedGeneratedURL = '1. '+con.Training_Intereste__c+' : '+TrainingURLGenerator.trainingURL_Domain+'?trainingForm='+EncodingUtil.urlEncode(con.Training_Intereste__c,'UTF-8')+'&cId='+con.Id; 
        
        System.debug('ExpectedURL:'+expectedGeneratedURL);
        System.debug('ActualURL:'+con.Training_Links__c);
        System.assertEquals(expectedGeneratedURL,con.Training_Links__c);
        System.assertEquals(con.FirstName,'Test123');
        
        test.stopTest();
    }
}