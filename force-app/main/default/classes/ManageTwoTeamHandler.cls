//********************************************************************************************************************************************
// Name             : ManageTwoTeamHandlerClass
// Description      : Class is used to provide the access of opportunities when the Sales Team Manager wants to handle two team.(Case no 1466)  
// Created By       : Shruti Singh
// Created Date     : 3rd Dec 2016
//*********************************************************************************************************************************************

public class ManageTwoTeamHandler{

    public static void manageTwoTeams(List<Seller__c> newList, Map<ID, Seller__c> oldMap){

        Set<Id> sellerIds = new Set<Id>();
        Set<Id> oldSalesTeamSellerIds = new Set<Id>();
        Set<String> sellertype = new Set<String>();
        Set<String> salesTeamName = new Set<String>();
        Set<String> oldsalesTeamName = new Set<String>();
        Set<Id> currentsellerIds = new Set<Id>();
        Set<Id> currentsellerrecordIds = new Set<Id>();
        List<Seller__c> listofseller = new List<Seller__c>();
        List<Seller__c> listofsellerofoldsalesteam = new List<Seller__c>();
        List<Seller__c> updateSellerRecord = new List<Seller__C>();
        List<Opportunity> listofOpportunity = new List<Opportunity>();
        List<Opportunity> listofOpportunityofOldSalesTeam = new List<Opportunity>();
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        List<OpportunityShare> shares = new List<OpportunityShare>();
        Set<Id> opptyIds = new Set<Id>();
         
        if(newList !=null && newList.size() > 0 && oldMap != null && oldMap.size() > 0)
        {    
            for(Seller__c seller : newList)
            {
               
                Seller__c oldSeller = oldMap.get(seller.Id);
                if((seller.Manage_Other_Team__c != '' || seller.Manage_Other_Team__c != null) && oldSeller.Manage_Other_Team__c != seller.Manage_Other_Team__c)
                {
                   
                    if(!String.isBlank(seller.Manage_Other_Team__c))
                    {salesTeamName.add(seller.Manage_Other_Team__c);}
                    currentsellerIds.add(seller.User__c);
                    currentsellerrecordIds.add(seller.Id);                    
                    if(!String.isBlank(oldSeller.Manage_Other_Team__c))
                    {oldsalesTeamName.add(oldSeller.Manage_Other_Team__c);}
                }
            }
            if(salesTeamName.size() > 0 )
            {
                listofseller = [Select Id,User__c, Sales_Team_Name__c,Manage_Other_Team__c from Seller__c where Sales_Team_Name__c =: salesTeamName and Start_Date__c <= : Date.today() AND (End_Date__c >= : Date.today() OR End_Date__c = null)];
            }
            if(oldsalesTeamName.size() > 0 )
            {
               
                listofsellerofoldsalesteam = [Select Id,User__c, Sales_Team_Name__c,Manage_Other_Team__c from Seller__c where Sales_Team_Name__c =: oldsalesTeamName  and Start_Date__c <= : Date.today() AND (End_Date__c >= : Date.today() OR End_Date__c = null)];
            }
            
            if(currentsellerrecordIds != null)
            {
               for(Id selId : currentsellerrecordIds)
               {
                    if(listofseller != null && listofseller.size() > 0)
                    {
                       for(Seller__c selrec : listofseller)
                       {
                            sellerIds.add(selrec.Id);
                            Seller__c sellerRec = new Seller__c();
                            sellerRec.Secondary_Manager__c = selId;
                            sellerRec.Id = selrec.Id;
                            updateSellerRecord.add(sellerRec);
                       }
                    }
                    if(listofsellerofoldsalesteam != null && listofsellerofoldsalesteam.size() > 0)
                    {
                        for(Seller__c selrec : listofsellerofoldsalesteam) 
                        {
                            oldSalesTeamSellerIds.add(selrec.Id);
                            Seller__c sellerRec = new Seller__c();
                            sellerRec.Secondary_Manager__c = null;
                            sellerRec.Id = selrec.Id;
                            updateSellerRecord.add(sellerRec);
                        }
                      
                    }
                }
                if(updateSellerRecord != null && updateSellerRecord.size() > 0)
                {
                    Database.SaveResult[] srList = Database.update(updateSellerRecord, false);
                    // Iterate through each returned result
                    for (Database.SaveResult sr : srList) 
                    {
                        if (sr.isSuccess()) {
                            System.debug('Successfully updated seller. Seller ID: ' + sr.getId());
                        }
                        else 
                        {
                            // Operation failed, so get all errors               
                            for(Database.Error err : sr.getErrors()) 
                            {
                                System.debug('The following error has occurred.');                   
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            }
                        }
                    }
                }
            } 
            if(sellerIds != null)
            {                 
                listofOpportunity = [Select Id, Name from Opportunity where Seller__c =: sellerIds and (StageName != 'Vunnen' or StageName != 'Förlorad' or StageName != 'Avbruten' or StageName != 'Avfärdat prospect')];
            }
            if(oldSalesTeamSellerIds != null)
            {
                listofOpportunityofOldSalesTeam = [Select Id, Name from Opportunity where Seller__c =: oldSalesTeamSellerIds ];
            }
            if(listofOpportunity != null && listofOpportunity.size() > 0 && currentsellerIds != null && currentsellerIds.size() > 0)
            {
                for(Id selId : currentsellerIds)
                {
                    for(Opportunity oppty : listofOpportunity)
                    {
                        OpportunityShare opptyshare = new OpportunityShare();
                        opptyshare.OpportunityId = oppty.Id;
                        opptyshare.OpportunityAccessLevel = 'Edit';
                        opptyshare.UserOrGroupId = selId;
                        opptyshare.RowCause = 'Manual';
                        oppShares.add(opptyshare);
                    }
                }
                if(oppShares != null && oppShares.size() > 0)
                {                   
                    Database.SaveResult[] oppsharelist = database.insert(oppShares,false);
                    for (Database.SaveResult sr : oppsharelist) 
                    {
                        if (sr.isSuccess()) {
                            System.debug('Successfully inserted oppty share. OpportunityShare ID: ' + sr.getId());
                        }
                        else 
                        {
                            // Operation failed, so get all errors               
                            for(Database.Error err : sr.getErrors()) 
                            {
                                System.debug('The following error has occurred.');                   
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            }
                        }
                    }
                }
            } 
            if(listofOpportunityofOldSalesTeam != null && listofOpportunityofOldSalesTeam.size() > 0)
            {
                for(Opportunity opp :listofOpportunityofOldSalesTeam)
                {
                    opptyIds.add(opp.Id);
                }
                if(opptyIds != null)
                {
                    shares = [select Id, OpportunityAccessLevel, RowCause from OpportunityShare where OpportunityId IN :opptyIds and RowCause = 'Manual'];
                }
                if(shares != null && shares.size() > 0)  
                {
                    try{
                            delete shares;
                    }
                    catch(Exception e){
                        System.debug('The following error has occured' + ': ' + e.getMessage());
                        
                    }
                    
                }
            }               
        }
    }
}