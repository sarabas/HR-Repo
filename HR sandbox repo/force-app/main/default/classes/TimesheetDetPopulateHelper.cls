public class TimesheetDetPopulateHelper {
    
    public static void updatePortalDetails(List<AVTRRT__Placement__c> placement)
    {
        System.debug('TimesheetDetPopulateHelper is called');
        for(AVTRRT__Placement__c placmnt:placement){            

          String query = 'Select Id,Email,FCMS__UserName__c,FCMS__Password__c,FCMS__Registration_Approved__c,FCMS__CMSProfile__c,FCMS__Job_Site__c from Contact where Id ='+placmnt.AVTRRT__Contact_Candidate__c;
				System.debug('Query'+query);
            List<Contact> contact = [Select Id,Email,FCMS__UserName__c,FCMS__Password__c,FCMS__Registration_Approved__c,FCMS__CMSProfile__c,FCMS__Job_Site__c from Contact where Id =: placmnt.AVTRRT__Contact_Candidate__c];
            System.debug('contatc'+contact.size());
            for(Contact cnt: contact)        
            {
                
                if(cnt.Email!=null)
                {
                    System.debug('Email is not null');
                    if(cnt.FCMS__UserName__c==null)
                    {
                        cnt.FCMS__UserName__c = String.valueOf(cnt.Email);
                    }
                    if( cnt.FCMS__Password__c ==null)
                    {
                        cnt.FCMS__Password__c = getAlphaNumericPwd();
                    }
                    cnt.FCMS__Registration_Approved__c = true;
                    List<FCMS__CMSProfile__c> profileId = [Select Id from FCMS__CMSProfile__c where FCMS__Name__c='Timesheet Employee'];
                    cnt.FCMS__CMSProfile__c = profileId[0].Id;
                    cnt.FCMS__Job_Site__c='Default';

                }
                 update cnt;
            }

           
                }
        
    }
    
    private static String getAlphaNumericPwd()
    {
        System.debug('getAlphaNumericPwd');     
        Integer len = 8;
        Blob blobVal = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobVal);
        String pwd = key.substring(0,len);
        return pwd;
    }
}