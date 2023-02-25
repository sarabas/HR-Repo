public with sharing class ChangeMailCountry {
    public static void standardizeMailCountry() {
        List<Contact> updateList =  [SELECT MailingCountry FROM Contact where MailingCountry IN ('USA', 'u s a', 'United States', 'United States of America')];
        for(Contact c : updateList){
            c.MailingCountry = 'US';
        }
        update updateList;
    }
}