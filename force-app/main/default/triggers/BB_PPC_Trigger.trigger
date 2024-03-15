trigger BB_PPC_Trigger on Broadband_PPC__c (before insert, before update)  
{
    //Id RecordTypeIdAddOn = Schema.SObjectType.Broadband_PPC__c.getRecordTypeInfosByName().get('Add-on').getRecordTypeId();
    //Id RecordTypeIdSLA = Schema.SObjectType.Broadband_PPC__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
    
    for (Broadband_PPC__c obj: trigger.new)
    {        
        obj.Portfolio_text__c = obj.Main_Portfolio__c; //text_portfolio;
        obj.Offering_text__c = obj.Offering__c; //text_offering;
        obj.Main_offering_text__c = obj.Main_offering__c; //text_main_offering;  
       
                
        if ((obj.SLA__c != null && obj.Offering_service_name__c != null) || obj.Add_on__c != null && obj.Offering_service_addon__c != null)
        {   
            System.debug('in if :' +obj);
            obj.Main_Portfolio__c = obj.Portfolio_formula__c; //for_portfolio;
            obj.Specific_Offering_Service__c = obj.Offering_Service_name_formula__c; //for_offering_service;
            obj.Offering_service_volume__c = obj.Offering_Service_detailed_definition_for__c; //for_offering_service_det;
            obj.Offering__c = obj.Offering_formula__c; //for_offering;
            obj.Main_offering__c = obj.Main_offering_formula__c; //for_main_offering;
        }
       
        
    }
}