public class TrainingURLGenerator{
    // Sandbox URL
     //public static String trainingURL_Domain = 'https://momssandbo-mompreneur.cs171.force.com/TrainingInfoForm';
    // PROD URL
     public static String trainingURL_Domain='https://mompreneur.secure.force.com/TrainingInfoForm';
    
    @InvocableMethod
    public static void generateURL(List<Id> conIds) {
        List<Contact> conList = [SELECT Id,Training_Intereste__c
                                 FROM Contact
                                 WHERE Id IN: conIds];
        System.debug('Retrieved List ---' + conList);
        if(ContactTriggerHandler.isFirstTime)
        {
            ContactTriggerHandler.isFirstTime = false;
            for(Contact c : conList) {
                if(c.Training_Intereste__c != NULL) {
                    System.debug('Training Interested --- ' + c.Training_Intereste__c);
                    String trainingInfo = c.Training_Intereste__c;
                    List<String> interestedTrainingList = trainingInfo.split(';');
                    String trainingUrls = '';
                    System.debug('After Split interestedTrainingList --- '+interestedTrainingList);
                    Integer count=0;
                    for(String interestedTraining : interestedTrainingList) {
                        count++;
                        
                         String trainingURL = trainingURL_Domain+'?trainingForm='+EncodingUtil.urlEncode(interestedTraining,'UTF-8')+'&cId='+c.Id;
                        
                        String tempURL = count+'. '+ EncodingUtil.urlDecode(interestedTraining,'UTF-8')+' : ' +trainingURL;
                  		trainingUrls = trainingUrls + tempURL +'\n\n';
                        
                    }
                    System.debug('updated trainingUrls --- '+trainingUrls);
                    c.Training_Links__c = trainingUrls;
                } 
                system.debug('Training Url -- '+ c.Training_Links__c);
            }
            if(conList.size()>0) {
                update conList;
                
            }
            
            
        }
    }
    
    
}