trigger CheckWordCount on Lead (before insert, before update) {
    for(Lead record: Trigger.new) {
        Integer count;
        if(record.Notes_Comments__c != null && (count = record.Notes_Comments__c
            .normalizeSpace() // Don't count duplicate spaces
            .stripHtmlTags() // Remove all HTML
            .replaceAll('\\S','') // Remove all non-spaces
            .length()) == 0) { // Check if the word count is 1
            record.Notes_Comments__c.addError('The word count is 1');
        }
    }
}