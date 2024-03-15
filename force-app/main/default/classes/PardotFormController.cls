public class PardotFormController {
    public String TeliaId { get;set; }
    public String LeadAgentUrl { get;set; }
    public String SalesRepUrl { get;set; }
    
    public PardotFormController(){
        User u = [SELECT Telia_Id__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        TeliaId = u.Telia_Id__c;
        
        General_Lead_Settings__c settings = General_Lead_Settings__c.getValues('General Settings');
        LeadAgentUrl = settings.Lead_Agent_Url__c;
        SalesRepUrl = settings.Sales_Rep_Url__c;
    }
}