public class ReturLCActionController {
    
    //Class for Picklist options
    public class pSelectOption{
        @AuraEnabled
        public String Label {get; set;}
        @AuraEnabled
        public String Value {get; set;}
        @AuraEnabled
        public Boolean IsDefault {get; set;}
        
    }
    
    public Lead LeadRecord {get; set;}
    
    public ReturLCActionController(){
        General_Lead_Settings__c settings = General_Lead_Settings__c.getValues('General Settings');
        String parameter = ApexPages.currentPage().getParameters().get('leadId');
        if(parameter != null){
            LeadRecord = [SELECT Id, OwnerId, Lead_Close_Reason__c, Other_reason__c, Status FROM Lead WHERE Id = :parameter LIMIT 1];
            LeadRecord.OwnerId = settings.Retur_LC_OwnerId__c;
            LeadRecord.Status = settings.Retur_LC_Status__c;
        }
    }
    
       
    //Send Lead to LC
    @AuraEnabled
    public static string sendLeadToLC(String leadId, String closeReason, String otherReason){
        General_Lead_Settings__c settings = General_Lead_Settings__c.getValues('General Settings');
        
        Lead lead = [SELECT Id FROM Lead WHERE ID = :leadId LIMIT 1];
        lead.OwnerId = settings.Retur_LC_OwnerId__c;
        lead.Status = settings.Retur_LC_Status__c;
        lead.Lead_Close_Reason__c = closeReason;
        if(otherReason != null){
            lead.Other_reason__c =  otherReason;
        }
        
        try{
            update lead;
            return 'Success';
        } catch(Exception e){
            return e.getMessage();
        }
    }
    
    public PageReference sendLeadToLCVF(){
        try{
            update LeadRecord;
            PageReference leadPage = new PageReference('/' + LeadRecord.Id);
            leadPage.setRedirect(true);
            return leadPage;
        } catch(Exception e){
            System.debug('error:' + e.getMessage());
            return null;
        }
    }
    
    //Get Lead
    @AuraEnabled
    public static Lead getLeadRecord(String leadId){
        System.debug(leadId);
        Lead lead = [SELECT Id, OwnerId, Lead_Close_Reason__c, Other_reason__c, Status FROM Lead WHERE Id = :leadId LIMIT 1];
        
        return lead;
    }
    
    //Create the picklist
    @AuraEnabled
    public static List<pSelectOption> getPickListValues()
    { 
        General_Lead_Settings__c settings = General_Lead_Settings__c.getValues('General Settings');
        List<pSelectOption> options = new List<pSelectOption>();
        List<String> picklistValues =  settings.Retur_LC_Picklist_Values__c.split(';');
        
        for( String f : picklistValues){
            System.debug(f);
            pSelectOption pso = new pSelectOption();
            pso.Value = f.trim();
            pso.Label = f.trim();
            options.add(pso);
            
        }    
        return options;  
        
    }
}