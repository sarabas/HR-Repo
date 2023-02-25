trigger Trigger_TimesheetDetailsForMom on AVTRRT__Placement__c (after update) {
     
    Boolean isTriggerDisabled=false;
    AVTRRT__Config_Settings__c settings = AVTRRT__Config_Settings__c.getValues('Default');
    if(settings!=null)
    {
        isTriggerDisabled = settings.Disable_PopulateTimeSheetPortalDet__c;
        System.debug('Trigger value--'+isTriggerDisabled);
    }
    if(isTriggerDisabled)
    {
        System.debug('Trigger is disabled in Custom Settings');

    }
    else
    {
    if(Trigger.isUpdate)
    {
        System.debug('is isUpdate');
        for(AVTRRT__Placement__c plc : Trigger.new)
        {
            if(plc.Project_TMS__c!=trigger.oldMap.get(plc.Id).Project_TMS__c)
               {

                    TimesheetDetPopulateHelper.updatePortalDetails(Trigger.new);
               }    
            
        }
       
    }
    
    }
}