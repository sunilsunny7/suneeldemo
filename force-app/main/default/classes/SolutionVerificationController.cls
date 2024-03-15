/*
About
-----
Description: SolutionVerificationController for the OpportunityRequirement component
Create date: 18.04-2017

Update History
--------------
Created April 2017 - Vahraz Mostajir
Updated April 2017 - SAEN-2135  Associate Reference Solution to Requirements -- Vahraz Mostajir

*/

public class SolutionVerificationController {
    //The JSON Response we return
    public class ActionStatus{
        public String ErrorMessage {get; set;}
        public Boolean IsSuccess {get; set;}
        public Boolean HasApproval {get;set;}
        public String ApprovalID {get; set;}
    }
    
    //Wrapper used to map the Requirement fields to match the table model
    public class RequirementWrapper{
        @AuraEnabled
        public String Id { get; set; }       
        @AuraEnabled
        public String Name { get; set; }        
        @AuraEnabled
        public String Status { get; set; }        
        @AuraEnabled
        public String Description { get; set; }      
        @AuraEnabled
        public String RelatedSolution { get; set; }       
        @AuraEnabled
        public String RelatedSolutionId { get; set; }        
        @AuraEnabled
        public String IsConnected { get; set; }
        @AuraEnabled
        public String ExternalId { get; set; } 
        @AuraEnabled
        public String OwnerAlias { get; set; } 
    }

    //Returns the Solution Verification
    @AuraEnabled
    public static Solution_Verification__c getSolutionVerification(String solutionId){
        Solution_Verification__c sv = [SELECT Id, Name FROM Solution_Verification__c WHERE Id = :solutionId LIMIT 1];
        return sv;
    }
    
    
    //Return the Solution Verification Accounts
    @AuraEnabled
    public static List<Account> getAccounts(String solutionId){
        Set<Id> accIds = new Set<Id>();
        for(Opportunity opp :[SELECT AccountId FROM Opportunity WHERE Id IN (SELECT Opportunity__c FROM Requirement__c WHERE Related_Solution__c = :solutionId )]){
            accIds.add(opp.AccountId);
        }
        List<Account> accs = [SELECT Id, Name, Business_unit__c FROM Account WHERE Id IN :accIds];

        return accs;
    }
    
    //Returns the Solution Verification Opportunities
    @AuraEnabled
    public static List<Opportunity> getOpportunities(String solutionId){
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE Id IN (SELECT Opportunity__c FROM Requirement__c WHERE Related_Solution__c = :solutionId )];
        return opps;
    }
        
    //Returns the Solution Verification Requirements
    @AuraEnabled
    public static List<Requirement__C> getRequirements(String solutionId){
        List<Requirement__C> reqs = [SELECT Id, Name, Opportunity__c FROM Requirement__C WHERE Related_Solution__c = :solutionId];
        return reqs;
    }
    
    //Connects the Requirements to a Solution Verification
    @AuraEnabled
    public static String connect(String reqIds, String solutionVerId){
        List<String> reqIdList = (List<String>)System.JSON.deserialize(reqIds, List<String>.class);
        
        ActionStatus result = new ActionStatus();
        result.HasApproval = false;
        
        //Fetches the Selected Requirements
        List<Requirement__c> reqs = [SELECT Id, Approval_Decision_Date_Time__c, 
                                     Approval_Decision_Made_By__c, Article_Title__c,
                                     Article_Version_Number__c, Reference_Solution__c,
                                     Platform__c, Area__c, Related_Solution__c,
                                     Status__c, Requirement_Approval_Set__c, Article_Summary__c, Article_Description__c
                                     FROM Requirement__c 
                                     WHERE Id IN :reqIdList];
        
        if(reqs.isEmpty()){
            result.ErrorMessage = 'No Requirements selected';
            result.IsSuccess = False;
            return JSON.serialize(result);
        }
        
        //We need to fetch the Knowledge Article to get the DataCategories and Version
        Knowledge__kav knowledge;
        try{
            knowledge = [SELECT Id, VersionNumber, Title, Status__c, Reference_Solution_Approver__c, Reference_Solution__c, Summary, Description__c FROM Knowledge__kav WHERE PublishStatus = 'Online' AND Language = 'sv' AND Related_Solution__c = :solutionVerId LIMIT 1];
        }catch(System.Exception ex){
            result.ErrorMessage = 'No Published Knowledge Article related to Solution Verification';
            result.IsSuccess = False;
            return JSON.serialize(result);
        }
        
        //Turn the Categories into a string
        String platforms = '';
        String area = '';
        for(Knowledge__DataCategorySelection kdcs : [SELECT Id, toLabel(DataCategoryName), DataCategoryGroupName, ParentId 
                                                     FROM Knowledge__DataCategorySelection 
                                                     WHERE ParentId = :knowledge.Id ]){
                                                         if(kdcs.DataCategoryGroupName == 'Area'){
                                                             area  +=  kdcs.DataCategoryName + '; ';
                                                         }
                                                         if(kdcs.DataCategoryGroupName == 'Platform'){
                                                             platforms += kdcs.DataCategoryName + '; ';
                                                         } 
                                                     }
        
        //Update the Requirements if they are a Reference Solution
        if(knowledge.Reference_Solution__c){           
            for(Requirement__c req : reqs){                
                req.Approval_Decision_Date_Time__c = DateTime.now();
                req.Approval_Decision_Made_By__c = UserInfo.getUserId();
                req.Article_Title__c = knowledge.Title;
                req.Article_Version_Number__c = knowledge.VersionNumber;
                req.Reference_Solution__c = True;
                req.Platform__c = platforms;
                req.Area__c = area;
                req.Related_Solution__c = solutionVerId;
                req.Status__c = 'Klar'; 
                req.Requirement_fullfiled__c = 'Ja';
                req.Article_Summary__c = knowledge.Summary;
                req.Article_Description__c = knowledge.Description__c;
            }
        }else{
            //Else we create a new Requirement Approval Set and update the Requirements with otheer values
            Requirement_Approval_Set__c ras = new Requirement_Approval_Set__c();
            ras.Knowledge_Article_Version_Hyperlink__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + knowledge.Id;
            ras.Knowledge_Article_Title__c = knowledge.Title;
            ras.Knowledge_Article_Version_ID__c = knowledge.Id;
            ras.Status__c = 'Not Submitted for Approval';
            ras.Solution_for_Approval__c = solutionVerId;
  	          
            try{
                insert ras;
                result.ApprovalId = ras.Id;
                result.HasApproval = true;
                System.debug(result.ApprovalId);
            }catch(System.Exception ex){
                result.ErrorMessage = ex.getMessage();
                result.IsSuccess = False;
                return JSON.serialize(result);
            }

            for(Requirement__c req : reqs){
                req.Article_Title__c = knowledge.Title;
                req.Article_Version_Number__c = knowledge.VersionNumber;
                req.Reference_Solution__c = False;
                req.Platform__c = platforms;
                req.Area__c= area;
                req.Related_Solution__c = solutionVerId;
                req.Requirement_Approval_Set__c = ras.Id;
                req.Article_Summary__c = knowledge.Summary;
                req.Article_Description__c = knowledge.Description__c;
            }
        }
        
        try{
            update reqs;
        }catch(System.DmlException ex){
            result.ErrorMessage = ex.getMessage();
            result.IsSuccess = False;
            return JSON.serialize(result);
        }
        result.ErrorMessage = '';
        result.IsSuccess = true;
        return JSON.serialize(result);
    }
    
    //Returns the Requirements for the selected Opportunity, only those that are not already on the Solution Verification
    @AuraEnabled
    public static List<RequirementWrapper> getOppRequirements(String opportunityId, String solutionVerId){
        List<Requirement__c> oppReqs = [SELECT Id, Owner.Name, External_ID__c, Name, Related_Solution__r.Name, Related_Solution__c, Status__c, Description__c  FROM Requirement__c WHERE Opportunity__c = :opportunityId];
        Map<Id, Requirement__c> vsReqs = new Map<Id, Requirement__c>([SELECT Id FROM Requirement__c WHERE Related_Solution__c  = :solutionVerId]);
        
        List<RequirementWrapper> requirements = new List<RequirementWrapper>();
        
        
        //Check if the Solution Verification already have them connected, if not then add them to the requirements list
        for(Requirement__c req : oppReqs){
            if(vsReqs.get(req.Id) == null){
                RequirementWrapper rw = new RequirementWrapper();
                rw.Id = req.Id;
                rw.Name = req.Name;
                rw.RelatedSolution = req.Related_Solution__r.Name != null ? req.Related_Solution__r.Name : '';
                rw.RelatedSolutionId = req.Related_Solution__c; 
                rw.Status = req.Status__c; 
                rw.Description = req.Description__c;
                rw.IsConnected = vsReqs.get(req.Id) == null ? 'false' : 'true';
                rw.OwnerAlias = req.Owner.Name;
                rw.ExternalId = req.External_ID__c;
                requirements.add(rw);
            }
        }
        return requirements;
    } 
}