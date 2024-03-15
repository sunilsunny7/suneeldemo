/**
About
-----
Description: SATController for Upsell Opportunity Lightning Action Components
Create date: 18.04-2017

Update History
--------------
Created April 2017 - Vahraz Mostajir
Updated April 2017 - SAEN-2312 CrossAndUpsell: Custom UI for selecting Cross&Up Prospect Targeted Accounts  -- Vahraz Mostajir
Updated April 2017 - SAEN-2261 CrossAndUpsell: Convert Cross&Up Prospect to CallActivity Campaign           -- Vahraz Mostajir

*/

public class SATController {
    
    //The JSON Response we return
    public class ActionStatus{
        public String ErrorMessage {get; set;}
        public Boolean IsSuccess {get; set;}
        public Integer Size {get; set;}
        public Integer AlreadyCreatedSize {get; set;}
        public string UpsellName { get; set; }
    } 
    
    
    ///Used to create a map between selected Account and the List of Orgs in the table
    public class SelectedAccountWrapper{
        @AuraEnabled
        public Account KeyAccount { get; set; }       
        @AuraEnabled
        public List<Account> Accounts { get; set; }  
    }
    
    //Fetches the Orgs of a Parent Account
    @AuraEnabled
    public static SelectedAccountWrapper getSelectedAccounts(String accountId){
        SelectedAccountWrapper saw = new SelectedAccountWrapper();
        
        Account acc = [SELECT Id, Name, Org_Nr__c, Aregion__c, ParentId, Parent.Name, RecordTypeId FROM Account WHERE Id =:accountId];
        acc.Aregion__c = acc.Aregion__c == null ? '' : acc.Aregion__c;
        saw.KeyAccount = acc;
        
        List<Account> orgList;
        if(SEUtility.getRecordTypeDevName(acc.RecordTypeId) == 'Sales_Aggregation_Account'){
            orgList = new List<Account>();
            for(Account accObj : [SELECT Id, Name, Org_Nr__c, Aregion__c, ParentId, Parent.Name FROM Account WHERE ParentId =:acc.Id]){
                accObj.Aregion__c = accObj.Aregion__c == null ? '' : accObj.Aregion__c;
                orgList.add(accObj);
            }
            
        }else{
            orgList = new List<Account>();
            orgList.add(acc);
        }
        
        saw.Accounts = orgList;
        
        System.debug(saw);
        return saw;
    }
    
    //Creates the targe accounts
    @AuraEnabled
    public static String createTargetAccounts(String keyAccIds, String excludedAccIds, String opportunityId){
        List<String> accIds = (List<String>)System.JSON.deserialize(keyAccIds, List<String>.class);
        Set<String> exAccIds = (Set<String>)System.JSON.deserialize(excludedAccIds, Set<String>.class);
        
        ActionStatus result = new ActionStatus();
      
        List<Upsell_Target_Account__c> utaList = new List<Upsell_Target_Account__c>();
        
        //AccountId
        Set<Id> createdTASet = new Set<Id>();
        for(Upsell_Target_Account__c uta :[SELECT Account__c, Account__r.Name FROM Upsell_Target_Account__c WHERE Opportunity__c = :opportunityId] ){
            createdTASet.add(uta.Account__c);
        }
        
        Integer count = 0;
        
        for(Account acc : [SELECT Id FROM Account WHERE (ParentId IN :accIds OR Id IN :accIds) 
                           AND RecordTypeId != :SEUtility.getRecordTypeId('Sales_Aggregation_Account')
                           /*AND RecordTypeId != :SEUtility.getRecordTypeId('Cygate_Sub_Account')*/]){
            //Chec if it's excluded
            if(!exAccIds.contains(acc.Id)){
                //Check if it has already been created
                if(!createdTASet.contains(acc.Id)){
                    Upsell_Target_Account__c uta = new Upsell_Target_Account__c();
                    uta.Account__c = acc.Id;
                    uta.Opportunity__c = opportunityId;   
                    utaList.add(uta);
                }else{
                    count++;
                } 
            }
        }
        
        try{
            insert utaList;
        }catch(System.DmlException ex){
            result.ErrorMessage = ex.getMessage();
            result.IsSuccess = False;
            return JSON.serialize(result);
        }
        
        result.ErrorMessage = '';
        result.IsSuccess = true;
        result.Size = utaList.size();
        result.AlreadyCreatedSize = count;
        System.debug(result);
        return JSON.serialize(result); 
    }
    
    //Creates a new Campaign with Call Activities
    @AuraEnabled
    public static String createCallActivityCampaign(string upsellOppId, string campaignName){
        Campaign camp = new Campaign();
        camp.Name = campaignName;
        camp.IsActive = true;
        camp.StartDate = Date.today();
        camp.Upsell_Opportunity__c = upsellOppId;
        camp.RecordTypeId = SEUtility.getRecordTypeId('Call_Activity_Campaign');
        
        //Check if the Volume Sales checkbox is checked, if it is then we make the owner of the Call Activites to Volume Sales
        Opportunity opp = [SELECT Id, CA_Campaign__c, Send_to_Volume_Sales__c FROM Opportunity WHERE Id = :upsellOppId LIMIT 1];
        Group grp;
        if(opp.Send_to_Volume_Sales__c){
            grp = [SELECT Id FROM Group WHERE Name = 'Public Sector Leads' LIMIT 1];
        }
        
        ActionStatus result = new ActionStatus();
        
        try{
            insert camp;
            List<Call_Activity__c> caList = new  List<Call_Activity__c>();
            List<CampaignMember> campaignMembers = new List<CampaignMember>();
                        
            //We create the Call Activities and Campaign Members if the Target Account Main Contact is set
            for(Upsell_Target_Account__c uta : [SELECT Id, Account__c, Main_Contact__c FROM Upsell_Target_Account__c WHERE Opportunity__c = :upsellOppId]){
                Call_Activity__c ca = new Call_Activity__c();
                ca.Account__c = uta.Account__c;
                ca.Campaign__c = camp.Id;
                if(opp.Send_to_Volume_Sales__c){
                      ca.OwnerId = grp.Id;
                }
                if(uta.Main_Contact__c != null){
                    CampaignMember cm = New CampaignMember(CampaignId = camp.Id, ContactId = uta.Main_Contact__c); 
                    campaignMembers.add(cm);
                }
                
                caList.add(ca);
            }
            
            if(!caList.isEmpty()){
                insert caList;
                if(!campaignMembers.isEmpty()){
                    insert campaignMembers;
                }
                opp.CA_Campaign__c = camp.Id;
                update opp;
            }
            
            //Return a succesful Action Status
            result.IsSuccess = true;
            result.Size = caList.size();
            System.debug(result);
            return JSON.serialize(result);
            
        }catch(System.DmlException ex){
            //Return a non succesful Action Status
            result.ErrorMessage = ex.getMessage();
            result.IsSuccess = False;
            return JSON.serialize(result);
        }
        
    }
    
    //Gets the Create Campaign components initial data 
    @AuraEnabled
    public static String getViewData(string upsellOppId){
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id = :upsellOppId LIMIT 1];
        
        Boolean hasCampaign = [SELECT COUNT() FROM Campaign WHERE Upsell_Opportunity__c = :upsellOppId LIMIT 1] > 0 ? true : false;        
        Integer size = [SELECT COUNT() FROM Upsell_Target_Account__c WHERE Opportunity__c = :upsellOppId];
        
        ActionStatus result = new ActionStatus(); 
        
        //Validates if the user can create a new Campaign or not
        if(hasCampaign){
            result.ErrorMessage = Label.SAT_Error_Has_Campaign;
            result.IsSuccess = false;         
        }else if(size == 0){
            result.ErrorMessage = Label.SAT_Error_Campaign_No_Target;
            result.IsSuccess = false;
        } else{
            result.Size = size;
            result.IsSuccess = true;
            result.UpsellName = opp.Name; 
        }
        
        System.debug(result);
        return JSON.serialize(result);
    }
}