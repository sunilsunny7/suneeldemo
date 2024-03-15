/**
About
-----
Description: OpportunityLineItemTriggerHandler on OpportunityLineItem
Create date: 22.09-2016

Update History
--------------
Created Sep 2016 - A.N Merged functionality from OpportunityProductAfter into trigger handler. (OpportunityProductAfter.trigger has been renamed to OpportunityLineItem.trigger)

Issues / TODOs
--------------  
Oct 2019- Y.K - SALEF 2388 and SALEF 2389- added methods to check and uncheck 'Has MC Product' and 'ESM KPI:er' checkboxes on opportunity
*/



public class OpportunityLineItemTriggerHandler {
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * */
    /* * OpportunityLineItemTriggerHandler Trigger Calls * */
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    private Boolean m_isExecuting = false;
    private Integer batchSize = 0;
    
    public OpportunityLineItemTriggerHandler(Boolean isExecuting, Integer size){
        m_isExecuting = isExecuting;
        batchSize = size;
    }
    
    public void OnBeforeInsert(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> newMap){
        System.debug('OpportunityLineItemTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + batchSize);
        setBuyInterest(newList);
        checkMCProducts(newList);
    }
    
    public void OnAfterInsert(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> newMap){
        System.debug('OpportunityLineItemTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + batchSize);
        updateSalesOutcome(newList, null);
        updateSolutionSalesOutcomeRecords(newList, null);
        checkESMKPI(newList);
        updateproductItems(newList);
    }
    
    public void OnBeforeUpdate(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> newMap){
        System.debug('OpportunityLineItemTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + batchSize);
        setBuyInterest(newList);
        
    }
    
    public void OnAfterUpdate(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> newMap, List<OpportunityLineItem> oldList, Map<Id, OpportunityLineItem> oldMap){
        System.debug('OpportunityLineItemTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + batchSize);
        updateSalesOutcome(newList, oldMap);
        updateSolutionSalesOutcomeRecords(newList, oldMap);
        
    }
    
    
    public void OnAfterDelete(List<OpportunityLineItem> oldList, Map<Id, OpportunityLineItem> oldMap){
        System.debug('OpportunityLineItemTriggerHandler.OnAfterDelete starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + batchSize);
        updateSalesOutcome(oldList, null);
        updateSolutionSalesOutcomeRecords(oldList, null);
        CygateProductDelete(oldList);
        UncheckMCCheckBox(oldList);
        updateproductItems(oldList);
    }  
    
    // Author A.N merged filters from old OpportunityProductAfter.
   // - Added to filters so that opps are only updated if the Sales_Outcome__c value has changed.
    // - Removed check Sales_Outcome__c != null. As this is a formula field the value will never be null.
    private static void updateSalesOutcome(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap){
        Set<Id> oppIds = new Set<Id>();
        
        // If insert, oldMap is null and all opp Ids will be added to set. If delete/undelete input for oldMap is set to null as this should also add all opp Ids to set. (Note: on delete the "oldList" is sent as input "newList" to the method as the newList doesn't exist on delete)
        // If update, the opp is only added to set if Sales_Outcome__c or Sales_Outcome_Large__c is changed
        for(OpportunityLineItem oli : newList){
            if(oldMap == null || oli.Sales_Outcome__c != oldMap.get(oli.Id).Sales_Outcome__c || oli.Sales_Outcome_Large__c != oldMap.get(oli.Id).Sales_Outcome_Large__c){
                oppIds.add(oli.OpportunityId);
            }
        }
        
        if(oppIds.isEmpty()) return;
        
        List<Opportunity> oppList = [SELECT Id, Sales_Outcome__c, Sales_Outcome_Large__c, 
                                     (SELECT Sales_Outcome__c, Sales_Outcome_Large__c FROM OpportunityLineItems)
                                     FROM Opportunity WHERE Id in : oppIds];
        /*  List<Opportunity> oppList1 = [SELECT Id, Sales_Outcome__c, Sales_Outcome_Large__c, 
(SELECT Sales_Outcome__c, Sales_Outcome_Large__c FROM OpportunityLineItems)
FROM Opportunity WHERE Id in : oppIds];
for(Opportunity opp : oppList1){
opp.Sales_Outcome__c = 0;
}*/
        
        for(Opportunity opp : oppList){
            opp.Sales_Outcome__c = 0;
            opp.Sales_Outcome_Large__c = 0;
            
            if(!opp.OpportunityLineItems.isEmpty()){
                for(OpportunityLineItem oli : opp.OpportunityLineItems){
                    if(oli.Sales_Outcome__c != null)
                        opp.Sales_Outcome__c += oli.Sales_Outcome__c;
                    opp.Sales_Outcome_Large__c += oli.Sales_Outcome_Large__c;
                }
            } else {
                
                OpportunityTriggerHandler.addOppWithLastProductDeleted(opp.Id);
            }
        }
        try
        {
            update oppList;
        }
        catch(Exception e)
        {
            system.debug(''+e.getmessage());
        }
        
    }
    // Author A.N merged filters from old OpportunityProductAfter.
    // - Added to filters so that opps are only updated if the Sales_Outcome_Solution__c value has changed.
    private static void updateSolutionSalesOutcomeRecords(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap){
        Set<Id> oppIds = new Set<Id>();
        
        // If insert, oldMap is null and all opp Ids will be added to set. If delete/undelete input for oldMap is set to null as this should also add all opp Ids to set. (Note: on delete the "oldList" is sent as input "newList" to the method as the newList doesn't exist on delete)
        for(OpportunityLineItem oli : newList){
            System.debug('oli.Sales_Outcome_Solution__c ' + oli.Sales_Outcome_Solution__c);
            System.debug('oldMap.get(oli.Id).Sales_Outcome_Solution__c' + (oldMap == null ? 0.0 : oldMap.get(oli.Id).Sales_Outcome_Solution__c));
            if(oldMap == null || oli.Sales_Outcome_Solution__c != oldMap.get(oli.Id).Sales_Outcome_Solution__c){
                oppIds.add(oli.OpportunityId);
            }
        }
        
        if(oppIds.isEmpty()) return;
        
        // Only Won opportunities needs to have the Sales Outcome Solution-records updated (recreated)
        List<Opportunity> closedWonOpps = [SELECT Id, CloseDate, OwnerId, AccountId FROM Opportunity WHERE Id in : oppIds AND IsWon = true];
        if(!closedWonOpps.isEmpty()){
            SolutionsSalesOutcomeServiceClass.deleteExistingRecords(closedWonOpps);
            SolutionsSalesOutcomeServiceClass.createNewRecords(closedWonOpps);
        }
    }
    
    // Author Vahraz
    // Sets Buy Interest if there is only one AF Buy Interest on the 
    private static void setBuyInterest(List<OpportunityLineItem> newList){
        
        //OpportunityId, OpportunityLineItem
        Map<Id, List<OpportunityLineItem>> checkedOlis = new Map<Id, List<OpportunityLineItem>>();
        
        for(OpportunityLineItem oli : newList){
            if(oli.From_reseller_lead__c == True){
                if(checkedOlis.get(oli.OpportunityId) == null){
                    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                    oliList.add(oli);
                    checkedOlis.put(oli.OpportunityId, oliList);
                }else{
                    checkedOlis.get(oli.OpportunityId).add(oli);
                }  
            }
        }
        
        if(!checkedOlis.isEmpty()){
            Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Id IN :checkedOlis.keySet()]);
            
            //OpportunityId, Buy_Interest__c
            Map<Id, Buy_Interest__c> buyInterests = new Map<Id, Buy_Interest__c>();
            
            for(Buy_Interest__c bi : [SELECT Id, Opportunity__c FROM Buy_Interest__c WHERE Lead_Source__c = :LeadTriggerHandler.LEAD_SOURCE_RESELLER AND Opportunity__c IN :opportunities.keySet()]){
                if(buyInterests.get(bi.Opportunity__c) == null){
                    buyInterests.put(bi.Opportunity__c, bi);
                    for(OpportunityLineItem oli :checkedOlis.get(bi.Opportunity__c)){
                        oli.Buy_Interest__c = bi.Id;
                    }
                    
                }else {
                    for(OpportunityLineItem oli :checkedOlis.get(bi.Opportunity__c)){
                        oli.addError(Label.LP_Opp_Many_BI_Error);
                    }
                }
            }         
        }
    }
    
    
    private static void CygateProductDelete(List<OpportunityLineItem> oldlist){
        Set<Id> oppIds = new Set<Id>();
        Integer currentSubProductCount=0;
        Integer currentmainProductCount=0;
        Integer oldmainProductCount=0;
        for(OpportunityLineItem oli : oldList){
            if(oli.Product_Family__c != null && oli.Product_Family__c.contains('Cygate')){   
                
                if(oli.By_Pass_Cygate_Sub_Product__c==false){
                    oppIds.add(oli.OpportunityId);
                    //oldmainProductCount+=1;
                }
            }
        }
        List<Opportunity> oppList = new List<Opportunity>();
        if(!oppIds.isEmpty()){
            oppList = [SELECT Id,
                       (SELECT By_Pass_Cygate_Sub_Product__c,Product_Family__c FROM OpportunityLineItems where By_Pass_Cygate_Sub_Product__c=false)
                       FROM Opportunity WHERE Id in : oppIds];
        }                                   
        
        for(Opportunity opp : oppList){ 
            for (OpportunityLineItem oli : opp.OpportunityLineItems){           
                /*if(oli.By_Pass_Cygate_Sub_Product__c==true && oli.Product_Family__c.contains('Cygate'))
{
currentSubProductCount+=1;                     
}*/
                if(oli.By_Pass_Cygate_Sub_Product__c==false && oli.Product_Family__c.contains('Cygate'))
                {
                    currentmainProductCount+=1;                    
                }
                
            }
            if((currentmainProductCount==0) || opp.OpportunityLineItems.isEmpty())
            {
                OpportunityTriggerHandler.addOppWithLastCygateProductDeleted(opp.Id);
            }         
        }      
        
    }
    
    // Y.K - SALEF-2388 - Checks the 'Has MC Product' checkbox on opportunity, if attached opportunity product contains any of the mentioned MC Products
    private static void checkMCProducts(List<OpportunityLineItem> newList){
        SET<Id> opptyID = new SET<Id>();
        List<Opportunity> opptyList = new LIST<Opportunity>();
        List<Has_MC_Products__mdt> prods = new List<Has_MC_Products__mdt>([select id,Product_ID__c,Product_Name__c from Has_MC_Products__mdt]);
        List<String> prodIdsFromMetadata = new List<String>();
        for(Has_MC_Products__mdt prodId :prods){
        prodIdsFromMetadata.add(prodId.Product_ID__c);
        }
        for(OpportunityLineItem oli : newList){
            
             system.debug('oli.Product2Id' + oli.Product2Id);
              if(oli.Product2Id != null && prodIdsFromMetadata.contains(String.valueOf(oli.Product2Id).substring(0, 15))){
              system.debug('oli.Product2Id' + oli.Product2Id);
                opptyID.add(oli.OpportunityId);
            }
        }
        if(!opptyID.isEmpty()){
            for (Id opty :opptyID){
                Opportunity oppObj = new Opportunity();
                oppObj.Id =opty;
                oppObj.Has_MC_Products__c = true;
                opptyList.add(oppObj);
            }
        }
        try{
            database.update (opptyList);
        }catch(Exception e){
            system.debug('Exception:-'+e.getmessage());
        }
    }
    // Y.K - SALEF-2389 - Checks the 'ESM KPI:er' checkbox on opportunity, if attached opportunity product contains all of the mentioned Products
    private static void checkESMKPI(List<OpportunityLineItem> newList){
        //OpportunityId, OpportunityLineItem
        SET<Id> IdsOppty = new SET<Id>();
        Set<String> oliListProducts = new Set<String>();
        List<Opportunity> listoppty = new List<Opportunity>();
        List<Products_for_ESM_KPI_er_checkbox__mdt> prods = new List<Products_for_ESM_KPI_er_checkbox__mdt>([select id,Product_ID__c,Product_Name__c from Products_for_ESM_KPI_er_checkbox__mdt]);
        List<String> prodIdsFromMetadata = new List<String>();
        //Set<String> ProdIds = new Set<String>();
        
        for(Products_for_ESM_KPI_er_checkbox__mdt prodId :prods){
        prodIdsFromMetadata.add(prodId.Product_ID__c);
        }
        for(OpportunityLineItem oli : newList){
        if(prodIdsFromMetadata.contains(String.valueOf(oli.Product2Id).substring(0, 15)))
            {
                IdsOppty.add(oli.OpportunityId);
            }
        }
        if(!IdsOppty.isEmpty()){
            for (Opportunity opty :[SELECT Id, (Select Id,Product2Id, Product_Name__c From OpportunityLineItems) FROM Opportunity WHERE Id IN :IdsOppty]){
                for(OpportunityLineItem objOli: opty.OpportunityLineItems) {
                    oliListProducts.add(String.valueOf(objOli.Product2Id).substring(0, 15));
                }
                system.debug('Product Name List:-' + oliListProducts);
                if(oliListProducts.containsAll(prodIdsFromMetadata)){
                    Opportunity opp = new Opportunity();
                    opp.Id = opty.Id;
                    opp.ESM_KPI_er__c= true;
                    listoppty.add(opp);
                }
            }
            try{
                database.update (listoppty);
            }catch(Exception e){
                system.debug('Exception:-'+e.getmessage());
            }
        }
    } 
    // Y.K - SALEF-2388 and SALEF-2389 - UnChecks the 'Has MC Products' and 'ESM KPI:er' checkbox on opportunity, if attached opportunity does not contains any of the mentioned product
    private static void UncheckMCCheckBox(List<OpportunityLineItem> oldList){
        SET<Id> OpptyIds = new SET<Id>();
        //List<String> oliListProducts = new List<String>();
        Set<String> oliListProducts = new Set<String>();
        List<Opportunity> UpdateOppty = new List<Opportunity>();
        List<Has_MC_Products__mdt> MCprods = new List<Has_MC_Products__mdt>([select id,Product_ID__c,Product_Name__c from Has_MC_Products__mdt]);
        List<String> prodsFromMetadataHasMC = new List<String>();
        List<String> MCProdNamesList = new List<String>();
        
        for(Has_MC_Products__mdt prodId :MCprods){
        prodsFromMetadataHasMC.add(prodId.Product_Name__c);
        }
        List<Products_for_ESM_KPI_er_checkbox__mdt> ESMKPIprods = new List<Products_for_ESM_KPI_er_checkbox__mdt>([select id,Product_ID__c,Product_Name__c from Products_for_ESM_KPI_er_checkbox__mdt]);
        List<String> prodsFromMetadataESMKPI = new List<String>();
        
        for(Products_for_ESM_KPI_er_checkbox__mdt prodId :ESMKPIprods){
        prodsFromMetadataESMKPI.add(prodId.Product_Name__c);
        }
        
        for(OpportunityLineItem oli : oldList){
            OpptyIds.add(oli.opportunityId);
        }        
        if(!OpptyIds.isEmpty()){
            for (Opportunity oppObj :[SELECT Id, (Select Id, name,Product2Id, Product_Name__c From OpportunityLineItems) FROM Opportunity WHERE Id IN :OpptyIds]){
                for(OpportunityLineItem objOli: oppObj.OpportunityLineItems) {
                    oliListProducts.add(objOli.Product_Name__c);
                }
                Opportunity opp = new Opportunity();
                opp.Id = oppObj.Id;
                 if(!oliListProducts.containsAll(prodsFromMetadataESMKPI)){
                    opp.ESM_KPI_er__c= false;
                }
                system.debug('oliListProducts'+ oliListProducts);
                if(oliListProducts.isEmpty()){
                opp.Has_MC_Products__c= false;
                }
                else{
                for(String ProdNames :prodsFromMetadataHasMC) {
               if(oliListProducts.contains(ProdNames)){
               MCProdNamesList.add(ProdNames);
               }
               }
                 if(MCProdNamesList.isEmpty()){
                 opp.Has_MC_Products__c= false;
                 }
                }
                UpdateOppty.add(opp);
                }
            }
        
        try{
            database.update(UpdateOppty);
        }catch(Exception e){
            system.debug('Exception:-'+e.getmessage());
        }
    }
    
    private static void updateproductItems(List<OpportunityLineItem> listItems){
        SET<Id>opptyIds = new SET<Id>();
        List<Opportunity>updateoppty = new List<opportunity>();
        for(OpportunityLineItem oli : listItems){
            opptyIds.add(oli.OpportunityId);
        }
        try{
            for(Opportunity opp :[SELECT id,(SELECT Id,Product2.Name,OpportunityId FROM OpportunityLineItems) from Opportunity where Id in : opptyIds]){
                String itemValueCode;
                Set<String>productnames = new Set<String>();
                productnames.clear();
                for(OpportunityLineItem oli : opp.OpportunityLineItems){
                    productnames.add(oli.Product2.Name);
                    system.debug('((('+productnames);
                    itemValueCode = SEUtility.writeMultiSelectPicklist(productnames);
                }
                system.debug('((('+itemValueCode);
                Opportunity tempopty = new opportunity();
                tempopty.Id = opp.Id;
                tempopty.Product_Items__c = itemValueCode;
                updateoppty.add(tempopty);
            }
            if(!updateoppty.isEmpty())
                database.update(updateoppty);
        }
        catch(Exception ex){
            system.debug(ex);
        }
    }
}