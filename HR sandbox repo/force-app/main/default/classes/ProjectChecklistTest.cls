@isTest
public class ProjectChecklistTest {
 
    @TestSetup
    static void ChecklistSetup(){
         String Category1,Category2;
         Id RecTypeIdProject = Schema.SObjectType.TMS__Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
         Account mrAcct = new Account(Name ='Mom Relaunch');
         insert mrAcct;
       
         //Inserting internal project with Mom Relaunch Account record id
         List<TMS__Project__c> InternalPrjs = new List<TMS__Project__c>();
          for (integer i=0;i<2;i++){
              TMS__Project__c intPrj = new TMS__Project__c();
              intPrj.RecordTypeId =RecTypeIdProject;
              intPrj.Name = 'Test Internal Prj'+ i;
              intPrj.TMS__Client__c = mrAcct.Id;
              intPrj.Project_Description__c ='Test Internal Prj Desc';
              intPrj.TMS__Project_Status__c ='Open';
              intPrj.Launchpad_Project__c =true;
              intPrj.TMS__Billable__c = false;
              InternalPrjs.add(intPrj);
          }
          insert InternalPrjs;
       
        //Fetch checklist categories from custom metadata types
        List<Project_Checklist_Setting__mdt> ChecklistSettings = [SELECT Checklist_Categories__c 
                                                                  FROM Project_Checklist_Setting__mdt 
                                                                  WHERE developername ='Project_Checklist' LIMIT 1];
        If(ChecklistSettings != null){
          String[] Categories = ChecklistSettings[0].Checklist_Categories__c.split(';');
          Category1 = Categories[0];
          Category2 = Categories[1];   
        }    
           
        //Insert Project Checklists        
        List<AVTRRT__Checklist__c> Checklists = new List<AVTRRT__Checklist__c>();
        for (integer i=0;i<5;i++){
            AVTRRT__Checklist__c Checklist = new AVTRRT__Checklist__c();
            If(i<3){
               Checklist.AVTRRT__Checklist_Category__c = Category1;
            } else{
               Checklist.AVTRRT__Checklist_Category__c = Category2;   
            }
            Checklist.AVTRRT__Checklist_Name__c ='Project Checklist';
            Checklist.AVTRRT__Checklist_Type__c ='Project';
            Checklist.AVTRRT__Subject__c ='Checklist Subject'+i;
            Checklist.AVTRRT__Description__c ='Checklist Description'+i;
            Checklists.add(Checklist);
        }
        insert Checklists;       
    }

 @isTest
    static void searchTest(){
       
        String Category1;
        List <TMS__Project__c> PrjLst = [SELECT Id FROM TMS__Project__c WHERE Name ='Test Internal Prj0'];
        
        //Fetching Checklist Categories from Custom Metadata settings
        List<Project_Checklist_Setting__mdt> ChecklistSettings = [SELECT Checklist_Categories__c 
                                                                  FROM Project_Checklist_Setting__mdt 
                                                                  WHERE developername ='Project_Checklist' LIMIT 1];
        If(ChecklistSettings !=null){
         String[] Categories = ChecklistSettings[0].Checklist_Categories__c.split(';');
         Category1 = Categories[0];   
        }    
        PageReference pageRef = Page.DesignForm;
        pageRef.getParameters().put('Id',PrjLst[0].Id);
        Test.setCurrentPage(pageRef);
        ProjectsChecklist prjChecklist = new ProjectsChecklist();
        prjChecklist.getcategoryNames();
        
        //Setting a incorrect search text and invoking the Search method
        prjChecklist.searchText ='Test';
        prjChecklist.selectedCategoryName = Category1;
        prjChecklist.Search();
        //Verify that Search method returns 0 results, for category type - New Project
        system.assertEquals(0, prjChecklist.PrjChecklistLst.size());

        //Setting the Search text and category Name and invoking Search method
        prjChecklist.searchText ='';
        prjChecklist.selectedCategoryName = Category1;
        prjChecklist.Search();
        //Verify that Search method returns 3 results, for category type - New Project
        system.assertEquals(3, prjChecklist.PrjChecklistLst.size());
      
        //Selecting first checklist
        prjChecklist.wrapChecklistLst[0].selected = true;
        prjChecklist.Save();
        
        Integer TaskCnt = [SELECT Count() FROM Task WHERE WhatId =:PrjLst[0].Id];
        //Verify that Save method creates 1 task
        system.assertEquals(1, TaskCnt);
        
        //Selecting 2 checklist items
        prjChecklist.wrapChecklistLst[0].selected = false;
        prjChecklist.wrapChecklistLst[1].selected = true;
        prjChecklist.wrapChecklistLst[2].selected = true;
        prjChecklist.SaveAndComplete();
        
        Integer ComplTaskCnt = [SELECT Count() FROM Task WHERE WhatId =:PrjLst[0].Id AND Status ='Completed'];
        //Verify that Save and Complete method creates 2 tasks with Status as completed
        system.assertEquals(2, ComplTaskCnt);
        
        prjChecklist.Cancel();
    }    
  
}