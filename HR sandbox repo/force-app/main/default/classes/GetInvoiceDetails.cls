public  class GetInvoiceDetails {
   @AuraEnabled(cacheable=true)

    public static Map<String,String> getInvoiceDetails(String accID) {

        System.debug('Called' + accID);

        AVAB__SO_Document__c rec = [SELECT Name, AVAB__Contact__r.Name FROM AVAB__SO_Document__c where Id = :accID];
        String invoiceNum = rec.Name;
        String customerName = rec.AVAB__Contact__r.Name;

        Contact c = [SELECT Email FROM Contact WHERE Name = :customerName];

        String custEmail = c.Email;

        Map<String,String> mapDetails = new Map<String,String>();
        mapDetails.put('Email', custEmail);
        mapDetails.put('Contact', customerName);
        mapDetails.put('Invoice', invoiceNum);        


        System.debug('Invoice Num ' + invoiceNum);
        System.debug('Contact Name ' + customerName);
        System.debug('Email ' + custEmail);

        return mapDetails;
    }
    
}