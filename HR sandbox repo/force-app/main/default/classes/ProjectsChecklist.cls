public class ProjectsChecklist {

    public List<AVTRRT__Checklist__c> PrjChecklistLst = new List<AVTRRT__Checklist__c>();
    public List<wrapChecklist> wrapChecklistLst {get; set;}
    public String selectedCategoryName {get;set;}
    public String searchText {get;set;}
    public String ProjectId {get;set;}
    public String[] Categories;
    
    //Constructor
    public ProjectsChecklist(){
        
        //Fetching the Checklist Category on the VF page from the metadata settings 
        List<Project_Checklist_Setting__mdt> ChecklistSettings = [SELECT Checklist_Categories__c 
                                                                  FROM Project_Checklist_Setting__mdt 
                                                                  WHERE developername ='Project_Checklist' LIMIT 1];
        If(ChecklistSettings != null){
          Categories = ChecklistSettings[0].Checklist_Categories__c.split(';'); 
          selectedCategoryName = Categories[0]; 
        }    
        //Initialize from Link parameters
        This.ProjectId =  apexpages.currentpage().getparameters().get('Id');
    }
    
    //Wrapper Class for Wrapping Checklist with other task information
    public class wrapChecklist {
        
        public AVTRRT__Checklist__c checklist {get; set;}
        public Boolean selected {get; set;}
        public Task task {get;set;}
        
        //This is the contructor method. When we create a new wrapChecklist object we pass a Checklist Record 
        //that is set to the checklist  property. We also set the selected value to false
        public wrapChecklist(AVTRRT__Checklist__c chcklst, String prjId) {
            checklist = chcklst;
            task = new Task(Priority ='Normal',Status ='Not Started',OwnerId = UserInfo.getUserId(),
                            ActivityDate = Date.today(),WhatId =prjId);
            selected = false;
        }
    }
   
   //Method used to populate Checklist Category Picklist on the VF page
   public SelectOption[] getcategoryNames(){
        
        List<SelectOption> Options = New List<SelectOption>();
        for(Integer i=0;i<Categories.size();i++){
            Options.add(New SelectOption(Categories[i],Categories[i]));
      }
        return Options;
   }
    
    //Called on click of Save button from VF Page. Used to Create a task for all the selected checklists
    public PageReference Save(){
      
      List<Task> TasksList = new List<Task>();
      If (wrapChecklistLst != null){  
        //Loop through all the wrapper checklist objects
        for (wrapChecklist wrapChcklstobj :wrapChecklistLst){
            
            //If Checklist selected
            If(wrapChcklstobj.selected == true){
                TasksList.add(new Task(Subject = wrapChcklstobj.checklist.AVTRRT__Subject__c,
                                       Description = wrapChcklstobj.checklist.AVTRRT__Description__c,
                                       OwnerId = wrapChcklstobj.task.OwnerId,
                                       Status = wrapChcklstobj.task.Status,
                                       Priority = wrapChcklstobj.task.Priority,
                                       WhatId = wrapChcklstobj.task.WhatId,
                                       ActivityDate = wrapChcklstobj.task.ActivityDate));
            }
        }
        //Inserting Tasks
        If(TasksList != null && TasksList.size()>0){
            insert TasksList;
        }
      }     
      //Return Control back to the Record page
      return new PageReference('/' + ProjectId);
    }
    
    //Called on click of Save And Complete button from VF Page. Used to Create a task with completed status for all the selected checklists.
    public PageReference SaveAndComplete(){
      
      List<Task> TasksList = new List<Task>();
      If(wrapChecklistLst !=null){   
        //Loop through all the wrapper checklist objects
        for (wrapChecklist wrapChcklstobj :wrapChecklistLst){
            //If Checklist selected
            If(wrapChcklstobj.selected == true){
                TasksList.add(new Task(Subject = wrapChcklstobj.checklist.AVTRRT__Subject__c,
                                       Description = wrapChcklstobj.checklist.AVTRRT__Description__c,
                                       OwnerId = wrapChcklstobj.task.OwnerId,
                                       Status = 'Completed',
                                       Priority = wrapChcklstobj.task.Priority,
                                       WhatId = wrapChcklstobj.task.WhatId,
                                       ActivityDate = wrapChcklstobj.task.ActivityDate));
            }
          }
        
        //Inserting Tasks
        If(TasksList != null && TasksList.size()>0){
            insert TasksList;
        }
      }  
      //Return Control back to the Record page
      return new PageReference('/' + ProjectId);
   }
   
   //Called on click of Cancel button from VF page    
   public PageReference  Cancel(){
        
     //Return Control back to the Record page
     return new PageReference('/' + ProjectId);
   }
    
   //Called on click of Search button from VF page 
   public void Search(){
        
        String SearchStr;
        wrapChecklistLst = new List<wrapChecklist>();
        
        SearchStr =  searchText +'%';     
        //Fetching all the project checklists for the category name passed
        PrjChecklistLst = [SELECT AVTRRT__Checklist_Name__c,AVTRRT__Subject__c,AVTRRT__Description__c 
                           FROM AVTRRT__Checklist__c
                           WHERE AVTRRT__Checklist_Type__c  ='Project' AND AVTRRT__Checklist_Category__c =:selectedCategoryName 
                           AND AVTRRT__Checklist_Name__c LIKE :SearchStr];
                                   
        If (PrjChecklistLst != null && PrjChecklistLst.size() >0){
            for (AVTRRT__Checklist__c PrjChecklistObj :PrjChecklistLst){
                wrapChecklistLst.add(new wrapChecklist(PrjChecklistObj,ProjectId));
            }
        } 
    }
       
}