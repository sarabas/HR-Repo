public class AutoCreateInvoices {
    public static List<String> generateInvoices() {

       String invoiceNumber;
        
       List<AVAB__SO_Document__c> recList =  new List<AVAB__SO_Document__c>();     
       
       List<String> invoiceNumbers = new List<String>();    
       
       List<AVAB__Transaction_Line_Items__c> transLItemList  = new List<AVAB__Transaction_Line_Items__c>();

       List<Contact> contList = [SELECT Id, AccountId, Membership_Product__c FROM Contact WHERE 
                                                                                        Membership_Type__c IN ('Training Membership','LaunchPad Membership')
                                                                                        AND Launchpad_Membership_Fees_Waived__c = false
                                                                                        AND AVTRRT__Candidate_Status__c = 'Active'];
       
       List<AVAB__Item__c>  itemIDs = new List<AVAB__Item__c>();

       for(Contact c: contList){
           AVAB__Item__c item = new AVAB__Item__c();
           item.Id = c.Membership_Product__c;
           itemIDs.add(item);
       }
       System.debug(' list from contacts '+itemIDs);

       List<AVAB__Item__c> items =  [SELECT Name, AVAB__Sales_Price__c FROM AVAB__Item__c where Id IN :itemIDs];                                                                                             
      
       for(Contact c: contList){
            
           
            AVAB__SO_Document__c rec = new AVAB__SO_Document__c();
            rec.AVAB__Account__c = c.AccountId;
            rec.AVAB__Contact__c = c.Id; 
            rec.AVAB__Due_Date__c = Date.today();
            rec.AVAB__Terms__c  = 'Due on receipt';
            
            Id recType = Schema.SObjectType.AVAB__SO_Document__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
            rec.RecordTypeId = recType;
            recList.add(rec);
        }
              
        
        try{
            insert recList;

            List<AVAB__SO_Document__c> insertedInvoices = [SELECT Name,AVAB__Contact__c,AVAB__Amount__c FROM AVAB__SO_Document__c WHERE Id IN :recList];

            for(AVAB__SO_Document__c inv : insertedInvoices)
            {   
                invoiceNumber = inv.Name;
                invoiceNumbers.add(invoiceNumber);

                for(Contact c: contList){
                    
                    if(inv.AVAB__Contact__c == c.Id)
                    {
                        for(AVAB__Item__c item :items){

                            if(item.Id == c.Membership_Product__c){
                                System.debug('found item');

                                AVAB__Transaction_Line_Items__c tLItem = new AVAB__Transaction_Line_Items__c();
                                tLItem.AVAB__Product__c = item.Id;
                                tLItem.AVAB__Quantity__c = 1;
                                tLItem.AVAB__AR_Transaction__c = inv.Id;
                                tLItem.AVAB__Sales_Price__c = item.AVAB__Sales_Price__c;

                                transLItemList.add(tLItem);

                                inv.AVAB__Amount__c = item.AVAB__Sales_Price__c;
                                inv.AVAB__Status__c = 'Post';
                            }
                        }
      
                        

                     }
                }
            }
            
            insert transLItemList;
            update insertedInvoices;

            System.debug('Trans '+ transLItemList);
            
   
        }
        catch(Exception e)
        {
            System.debug('Error ' + e.getMessage());
        }
        
            System.debug('Invoice List '+ invoiceNumbers);
         return invoiceNumbers;

    }
}