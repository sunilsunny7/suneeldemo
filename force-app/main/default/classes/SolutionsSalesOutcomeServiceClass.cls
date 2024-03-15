/**
About
-----
Description: Service Class for Solution Sales Outcome
Create date: October 2015

Update History
--------------
Created Oct 2015 - V.I 
Updated Mar 2016 - R.L Added that Solution team 26528 CAAS/the UMC North get bonus for all solution areas - R.L
Updated Jun 2016 - Solution team 26528 CAAS/UMC North don't get bonus for Cygate. This is mainly solved by Product_Factor_Solutions__c formula as this is set to 0 for Cygate.
                   Updated the code so that if the sum of the Opportunity Line Items Sales_Outcome_Solution__c is 0 (aalways true for Cygate rec types), do not create records.
Updated Sep 2016 - A.N Refactored the createNewRecords method. Restructured the way data is queried. Created separate helper methods for code that was repeated in the old class.

Issues / TODOs
--------------  

*/
public class SolutionsSalesOutcomeServiceClass {

    private static Map<Id, List<Seller__c>> sellerMap;
    
    public static void deleteExistingRecords(List<Opportunity> opps){
        List<Sales_Outcome_Solutions__c> recordsForDeletion = [SELECT Id FROM Sales_Outcome_Solutions__c WHERE Opportunity__c in : opps];
        if(!recordsForDeletion.isEmpty()) delete recordsForDeletion;
    }

    public static void createNewRecords(List<Opportunity> oppList){
        List<Sales_Outcome_Solutions__c> newRecords = new List<Sales_Outcome_Solutions__c>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> allUserIds = new Set<Id>();

        for(Opportunity opp : oppList){
            accIds.add(opp.AccountId);
            allUserIds.add(opp.OwnerId); 
        }

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id,
                        (SELECT UserId FROM OpportunityTeamMembers),
                        (SELECT Sales_Outcome_Solution__c, UnitPrice, Product2.Family FROM OpportunityLineItems)
                        FROM Opportunity WHERE Id in :oppList]);

        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, RecordTypeId,
                        (SELECT UserId FROM AccountTeamMembers)
                        FROM Account WHERE Id in : accIds]);

        // Add all Opportunity/Account Team Member User Ids to the allUserIds set
        for(Opportunity opp : oppMap.values()) for(OpportunityTeamMember otm : opp.OpportunityTeamMembers) allUserIds.add(otm.UserId);
        for(Account acc : accMap.values()) for(AccountTeamMember atm : acc.AccountTeamMembers) allUserIds.add(atm.UserId);

        sellerMap = new Map<Id, List<Seller__c>>();
        for(Seller__c s : [SELECT User__c, User__r.UserRole.Name, Sales_Unit_Name__c, Business_Unit_Name__c, Sales_Team_Number__c, Start_Date__c, End_Date__c FROM Seller__c WHERE User__c in : allUserIds]){
            if(!sellerMap.containsKey(s.User__c)){
                sellerMap.put(s.User__c, new List<Seller__c>());
            }
            sellerMap.get(s.User__c).add(s);
        }
        
        for(Opportunity opp : oppList){
            // Only for opportunities that belongs to Large Accounts. If not, skip to next opp in loop
            if(accMap.get(opp.AccountId) == null || !SEUtility.isLargeAccountRecordType(accMap.get(opp.AccountId).RecordTypeId)) continue;
            // If the opp does not have any Line Items we do not need to create any Sales_Outcome_Solutions records, so skipping to the next opp in loop
            if(oppMap.get(opp.Id) == null || oppMap.get(opp.Id).OpportunityLineItems.isEmpty()) continue;

            // To ensure that we don't create duplicate SOS-records for a user (i.e if the user is both Opp Owner and in the Opportunity/Account team)
            Set<Id> userIdsWithSosRecords = new Set<Id>();

            //Opportunity Owner
            Seller__c ownerSeller = getActiveSeller(opp.OwnerId, opp.CloseDate);
            if(ownerSeller != null && (ownerSeller.Sales_Unit_Name__c == 'Solutions' || ownerSeller.Business_Unit_Name__c == 'Solutions')){
                userIdsWithSosRecords.add(opp.OwnerId);
                Sales_Outcome_Solutions__c sos = createNewSalesOutcomeSolutions(opp.Id, ownerSeller, 'Ägare affärsmöjlighet');
                for(OpportunityLineItem oli : oppMap.get(opp.Id).OpportunityLineItems){
                    // Team CAAS (UMC North) get bonus for all Solution areas. The others for their "own" Solution Area and Services
                    if(sos.Team_nr__c == '26528' || SEUtility.getSolutionAreaName(oli.Product2.Family) == sos.Solution_Area__c || SEUtility.getSolutionAreaName(oli.Product2.Family) == 'Services'){
                        sos.Sales_Outcome__c += oli.Sales_Outcome_Solution__c;
                    }
                }
                if(sos.Sales_Outcome__c > 0) newRecords.add(sos);
            }
            
            //Opportunity Team Members
            for(OpportunityTeamMember otm : oppMap.get(opp.Id).OpportunityTeamMembers){
                Seller__c memberSeller = getActiveSeller(otm.UserId, opp.CloseDate);
                if(!userIdsWithSosRecords.contains(otm.UserId) && memberSeller != null && (memberSeller.Sales_Unit_Name__c == 'Solutions' || memberSeller.Business_Unit_Name__c == 'Solutions')){
                    userIdsWithSosRecords.add(otm.UserId);
                    Sales_Outcome_Solutions__c sos = createNewSalesOutcomeSolutions(opp.Id, memberSeller, 'Tillhör affärmöjlighetsteamet');
                    for(OpportunityLineItem oli : oppMap.get(opp.Id).OpportunityLineItems){
                        if(sos.Team_nr__c == '26528' || SEUtility.getSolutionAreaName(oli.Product2.Family) == sos.Solution_Area__c){ // Team CAAS (UMC North) get bonus for all Solution areas. The others for their "own" Solution Area
                            sos.Sales_Outcome__c += oli.Sales_Outcome_Solution__c;
                        }
                    }
                    if(sos.Sales_Outcome__c > 0) newRecords.add(sos);
                }
            }
            
            //Account Team Members
            for(AccountTeamMember atm : accMap.get(opp.AccountId).AccountTeamMembers){
                Seller__c memberSeller = getActiveSeller(atm.UserId, opp.CloseDate);
                if(!userIdsWithSosRecords.contains(atm.UserId) && memberSeller != null && (memberSeller.Sales_Unit_Name__c == 'Solutions' || memberSeller.Business_Unit_Name__c == 'Solutions')){
                    String solutionArea = SEUtility.getSolutionAreaFromRole(memberSeller.User__r.UserRole.Name);
                    if(solutionArea == 'Unified and Mobile Communications' || solutionArea == 'Cloud Networking'){
                        Sales_Outcome_Solutions__c sos = createNewSalesOutcomeSolutions(opp.Id, memberSeller, 'Tillhör kontoteamet');                            
                        for(OpportunityLineItem oli : oppMap.get(opp.Id).OpportunityLineItems){
                            if(sos.Team_nr__c == '26528' || SEUtility.getSolutionAreaName(oli.Product2.Family) == sos.Solution_Area__c){ // Team CAAS (UMC North) get bonus for all Solution areas. The others for their "own" Solution Area
                                sos.Sales_Outcome__c += oli.Sales_Outcome_Solution__c;
                            }
                        }
                        if(sos.Sales_Outcome__c > 0) newRecords.add(sos);
                    }
                }
            }
        }
        System.debug('SolutionsSalesOutcomeServiceClass.createNewRecords ends ' + newRecords); 
        if(newRecords.size() > 0) insert newRecords;
    }

    private static Seller__c getActiveSeller(Id userId, Date closeDate){
        if(sellerMap.containsKey(userId)){
            for(Seller__c s : sellerMap.get(userId)){
                if(s.Start_Date__c <= closeDate && (s.End_Date__c >= closeDate || s.End_Date__c == null)){
                    return s;
                }
            }
        }
        return null;
    }

    private static Sales_Outcome_Solutions__c createNewSalesOutcomeSolutions(Id oppId, Seller__c seller, String reason){
        Sales_Outcome_Solutions__c sos = new Sales_Outcome_Solutions__c();
        sos.Solution_Area__c = SEUtility.getSolutionAreaFromRole(seller.User__r.UserRole.Name);
        sos.User__c = seller.User__c;
        sos.Seller__c = seller.Id;
        sos.Opportunity__c = oppId;
        sos.Reason__c = reason;
        sos.Team_nr__c = seller.Sales_Team_Number__c;
        sos.Sales_Outcome__c = 0;
        return sos;
    }
}