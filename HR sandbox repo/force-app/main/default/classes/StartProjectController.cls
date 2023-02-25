public class StartProjectController {
    private static AVTRRT.Logger logger = new AVTRRT.Logger('StartProjectController');
    
    public StartProjectController(ApexPages.StandardController controller) { }
    
    public static PageReference StartProject() {
        try {
            Id placementId = ApexPages.currentPage().getParameters().get('Id');
            AVTRRT__Placement__c placement = [
                SELECT Name, AVTRRT__Employer__r.Id
                FROM AVTRRT__Placement__c
                WHERE Id=:placementId
            ];
            List<String> success =
                TMS.CreateProjectFromPlacementOrOpportunity.createProject(placement.AVTRRT__Employer__r.Id, placement.Name, placement.Id);
            
            if (Boolean.valueOf(success[0]) == true) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,
                                                           'Project already exists for this placement'));
                return null;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,
                                                           'Project created'));
                PageReference page = new PageReference('/' + success[1]);
                page.setRedirect(true);
                return page;
            }
        } catch (Exception e) {
            logger.catchBlockMethodNew(e);
            return null;
        }
    }
}