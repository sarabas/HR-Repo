/**
UnsubscribeController
Created: 04/06/10
Updated: 04/08/10
*/

public with sharing class UnsubscribeController {

    public PageReference handleUnsubscribe() {
        
        System.debug('*** Starting handleUnsubscribe()');
        
        // Retrieve the "secret" code for the page
        String code = getCode();
        System.debug('*** Code = ' + code);
        
        // Check the "security code" to make (somewhat) sure the request
        // is from our MailChimp WebHook
        String requestCode = ApexPages.currentPage().getParameters().get('code');
        if (requestCode == null || !code.equals(requestCode)) {
            // Missing or wrong security code - fail silently so we don't reveal anything to the caller
            System.debug('*** Invalid security code: ' + requestCode);
            return null;
        }
        
        // Get email address from posted parameters
        String email = ApexPages.currentPage().getParameters().get('data[email]');
        if (email == null || email.length() <= 0) {
            System.debug('*** Missing email parameter');
            return null;
        }
        else {
            System.debug('*** Email to unsubscribe: ' + email);
        }
        
        // "Neutralize" characters in the email which could be used maliciously in search query
        String saferEmail = String.escapeSingleQuotes(email);
        saferEmail.replace('*', '\\*');
        saferEmail.replace('?', '\\?');
        
        // Search for any lead(s) and contact(s) record(s) with the email address
        List<List<SObject>> searchList = [FIND :saferEmail IN EMAIL FIELDS RETURNING Contact(id), Lead(id) ];      
        List<Contact> contacts = ((List<Contact>)searchList[0]);
        List<Lead> leads = ((List<Lead>)searchList[1]);
        
        // Update the opt-out field of record(s) (make sure the
        // current user has permission to view and update the opt-out field)
        for (Contact c : contacts) {
            c.HasOptedOutOfEmail = true;
        }
        for (Lead l : leads) {
            l.HasOptedOutOfEmail = true;
        }
        
        // Save the updates
        if (contacts.size() > 0) {
            update contacts;
        }
        if (leads.size() > 0) {
            update leads;
        }
        
        return null;
    } 
    
    private String getCode() {
    
        try {
            StaticResource sr = [ SELECT Body, Name FROM StaticResource WHERE Name = 'WebHooksConfig' LIMIT 1 ];
           	
            String xml = sr.Body.toString();
            System.debug('**** XML: \n' + xml);
            
            Dom.Document doc = new Dom.Document();
			doc.load(xml);
			Dom.XMLNode webhooks = doc.getRootElement();
			for (Dom.XMLNode node : webhooks.getChildElements()) {
				String id = node.getAttribute('id', '');
				if (id.equalsIgnoreCase('unsubscribe')) {
					return node.getAttribute('code', '');
				}
			}
        }
        catch (Exception e) {
            System.debug('*** Error: ' + e);
        }
        
        return null;
    }
    
    public static testMethod void testHandleUnsubscribe() {
        
        // Create lead and contact for testing 
        Lead myLead = new Lead( firstName = 'John', lastName = 'Tester', company = 'Test Corp.', email = 'tester@test.com');
        Contact myContact = new Contact( firstName = 'Jane', lastName = 'Tester', email = 'jtester@coolcorp.com');
        insert myLead;
        insert myContact;
        
        // Verify that lead has not opted out
        myLead = [ SELECT Id, Name, email, HasOptedOutOfEmail FROM Lead WHERE Id = :myLead.id ];
        System.assert(!myLead.HasOptedOutOfEmail, '*** Lead should not have opted out!');
        
        // Set up fixed SOSL search results (otherwise SOSL returns empty in testing)
        Id[] fixedSearchResults = new Id[2];
        fixedSearchResults[0] = myLead.Id;
        fixedSearchResults[1] = myContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        // Instantiate controller
        UnsubscribeController controller = new UnsubscribeController();         
        
        // Verify that we have a "secret" code and can read it
        String code = controller.getCode();
        System.assert(code != NULL && code.length() > 0, 'Code is null!');
        
        // Set up page context and parameters
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);   
        ApexPages.currentPage().getParameters().put('type', 'unsubscribe');
        ApexPages.currentPage().getParameters().put('data[email]', myLead.Email);
        ApexPages.currentPage().getParameters().put('code', code);
        
        // Call controller and verify that lead has now opted out
        controller.handleUnsubscribe();
        myLead = [ SELECT Id, Name, HasOptedOutOfEmail FROM Lead WHERE Id = :myLead.id ];
        System.assert(myLead.HasOptedOutOfEmail, '*** Lead should have opted out!');
        
        // Try again, but without the right security code
        myLead.HasOptedOutOfEmail = false;
        update myLead;
        ApexPages.currentPage().getParameters().remove('code');
        controller.handleUnsubscribe();
        myLead = [ SELECT Id, Name, HasOptedOutOfEmail FROM Lead WHERE Id = :myLead.Id ];
        System.assert(!myLead.HasOptedOutOfEmail, '*** Lead should not have opted out!');
        
        // Try again with correct code and contact's email
        ApexPages.currentPage().getParameters().put('data[email]', myContact.Email);
        ApexPages.currentPage().getParameters().put('code', code);
        controller.handleUnsubscribe();
        myContact = [ SELECT Id, Name, HasOptedOutOfEmail FROM Contact WHERE Id = :myContact.Id ];
        System.assert(myContact.HasOptedOutOfEmail, '*** Contact should have opted out!');
        
        // Try again without email parameter
        ApexPages.currentPage().getParameters().remove('data[email]');
        controller.handleUnsubscribe();
    }
}