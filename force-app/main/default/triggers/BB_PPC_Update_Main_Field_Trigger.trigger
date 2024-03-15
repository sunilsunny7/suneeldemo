trigger BB_PPC_Update_Main_Field_Trigger on Broadband_PPC__c (before insert, before update)  
{
    //Id RecordTypeIdAddOn = Schema.SObjectType.Broadband_PPC__c.getRecordTypeInfosByName().get('Add-on').getRecordTypeId();
    //Id RecordTypeIdSLA = Schema.SObjectType.Broadband_PPC__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
    
    for (Broadband_PPC__c obj: trigger.new)
    {        
        String for_main_offering = obj.Main_offering_formula__c;
        String for_offering_service_det = obj.Offering_Service_detailed_definition_for__c;
        String for_offering_service = obj.Offering_Service_name_formula__c;
        String for_offering = obj.Offering_formula__c;
        String for_portfolio = obj.Portfolio_formula__c;
                
        if (obj.SLA__c != null && obj.Offering_service_name__c != null)
        {   
            obj.Main_Portfolio__c = for_portfolio;
            obj.Specific_Offering_Service__c = for_offering_service;
            obj.Offering_service_volume__c = for_offering_service_det;
            obj.Offering__c = for_offering;
            obj.Main_offering__c = for_main_offering;
        }
        else if (obj.Add_on__c != null && obj.Offering_service_addon__c != null)
        {
            obj.Main_Portfolio__c = for_portfolio;
            obj.Specific_Offering_Service__c = for_offering_service;
            obj.Offering_service_volume__c = for_offering_service_det;
            obj.Offering__c = for_offering;
            obj.Main_offering__c = for_main_offering;
        }      
    }
}