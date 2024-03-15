trigger BB_PPC_Update_Search_Trigger on Broadband_PPC__c (before insert, before update) 
{
    for (Broadband_PPC__c obj: trigger.new)
    {        
        String text_main_offering = obj.Main_offering__c;
        String text_offering = obj.Offering__c;
        String text_portfolio = obj.Main_Portfolio__c;
                    
        obj.Portfolio_text__c = text_portfolio;
        obj.Offering_text__c = text_offering;
        obj.Main_offering_text__c = text_main_offering;  
    }
}