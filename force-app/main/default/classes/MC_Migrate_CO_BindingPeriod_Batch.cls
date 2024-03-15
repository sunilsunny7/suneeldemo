global class MC_Migrate_CO_BindingPeriod_Batch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){          

        return Database.getQueryLocator([select id,QuoteId,Product2.name,TeliaSE_MC_Binding_Time__c,TeliaSE_Product_Object_Type__c,vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__AttributeMetadataChanges__c 
                                         from quotelineitem where TeliaSE_Product_Object_Type__c in ('Broadband Start Offering Spec','Broadband Pro Offering Spec','Broadband Plus Offering Spec','Broadband Datanet Offering Spec','SD-WAN/Firewall Offering Spec','WIFI/LAN Offering Spec') 
                                        and Quote.status<>'Cancelled'  and TeliaSE_Product_Object_Type__c<>null and Quote.TeliaSE_Record_Type_Name__c='Contract'
                                        and vlocity_cmt__ParentItemId__c =null and TeliaSE_MC_Binding_Time__c=null]);
    }
    global void execute(Database.BatchableContext bc,List<quotelineitem> faQlisList){
        try{
            System.debug('Inside execute');
            Set<Id> parentQuoteIDs=new Set<Id>();
            List<String> faQlisObjectType=new List<String>();
             // MC_PricePlanIdAndAttributeMigrate.roamingPricePlanMigration(roamingQliList);
            for(QuoteLineItem faQli :faQlisList){
              parentQuoteIDs.add(faQli.QuoteId);
              faQlisObjectType.add(faQli.TeliaSE_Product_Object_Type__c);
            }
             List<QuoteLineItem> offerQlisList=[select id,Product2.name,TeliaSE_MC_Binding_Time__c,Quote.vlocity_cmt__ParentQuoteId__c,TeliaSE_Product_Object_Type__c,Quote.TeliaSE_Record_Type_Name__c  from quotelineitem
                                                where TeliaSE_Product_Object_Type__c in ('Broadband Start Offering Spec','Broadband Pro Offering Spec','Broadband Plus Offering Spec','Broadband Datanet Offering Spec','SD-WAN/Firewall Offering Spec','WIFI/LAN Offering Spec')
                                           and (Quote.vlocity_cmt__ParentQuoteId__c in :parentQuoteIDs) and TeliaSE_MC_Binding_Time__c<>null
                                           and Quote.status<>'Cancelled'  and (TeliaSE_Product_Object_Type__c in :faQlisObjectType)
                                           and Quote.TeliaSE_Record_Type_Name__c='Offer'];
            
             System.debug('offer qlis size-'+offerQlisList.size());
        Map<Id,Map<String,String>> prntQtToTypeBndgPrdMap=new Map<Id,Map<String,String>>();
        
        for(QuoteLineItem offerQli :offerQlisList){
            Map<String,String> offerTypeToBindPeriodMap=new Map<String,String>();
            if(prntQtToTypeBndgPrdMap.containsKey(offerQli.Quote.vlocity_cmt__ParentQuoteId__c)){
                offerTypeToBindPeriodMap=prntQtToTypeBndgPrdMap.get(offerQli.Quote.vlocity_cmt__ParentQuoteId__c);
            }
             offerTypeToBindPeriodMap.put(offerQli.TeliaSE_Product_Object_Type__c,offerQli.TeliaSE_MC_Binding_Time__c);

            prntQtToTypeBndgPrdMap.put(offerQli.Quote.vlocity_cmt__ParentQuoteId__c,offerTypeToBindPeriodMap);
        }
         List<QuoteLineItem> updatedFAQliList=new List<QuoteLineItem>();      

            for(QuoteLineItem faQli :faQlisList){
              if(prntQtToTypeBndgPrdMap.containsKey(faQli.QuoteId)){
                    Map<String,String> offerTypeToBindPeriodMap=new Map<String,String>();
                    offerTypeToBindPeriodMap=prntQtToTypeBndgPrdMap.get(faQli.QuoteId);
                 if(offerTypeToBindPeriodMap.containsKey(faQli.TeliaSE_Product_Object_Type__c)){
                    String bindingPeriod=offerTypeToBindPeriodMap.get(faQli.TeliaSE_Product_Object_Type__c);
                    faQli.TeliaSE_MC_Binding_Time__c=bindingPeriod;
                     Map<String,Object> attributeSelectedValues=new Map<String,Object>();
                     if(faQli.vlocity_cmt__AttributeSelectedValues__c<>null){
                       attributeSelectedValues = (Map<String,Object>)(JSON.deserializeUntyped(faQli.vlocity_cmt__AttributeSelectedValues__c));
  
                     }
                    System.debug(faQli.vlocity_cmt__AttributeSelectedValues__c);
                    System.debug(attributeSelectedValues.size());
                    System.debug(attributeSelectedValues);
                    attributeSelectedValues.put('ATTR_BindingTime_CO',bindingPeriod);
                    faQli.vlocity_cmt__AttributeSelectedValues__c=JSON.serialize(attributeSelectedValues);
                    System.debug('new selected values-'+attributeSelectedValues);
                    System.debug('serialized-'+JSON.serialize(attributeSelectedValues));
                   
                }
            }  
                 if(faQli.TeliaSE_Product_Object_Type__c=='Broadband Start Offering Spec'){
                        faQli.vlocity_cmt__AttributeMetadataChanges__c='{"ATTR_BindingTime_CO":{"values":[{"value":"0","selected":null,"rules":[],"readonly":false,"name":null,"label":"0 months","id":"b2e0ea32-036f-efe0-5d61-961aeb7545e7","displaySequence":1,"disabled":false,"defaultValue":null,"defaultSelected":null},{"value":"24","selected":null,"rules":[],"readonly":false,"name":null,"label":"24 months","id":"82b64fd2-c996-7af5-e96a-f233e6a4b0e5","displaySequence":3,"disabled":false,"defaultValue":null,"defaultSelected":null}]}}';
                    
                    }else if(faQli.TeliaSE_Product_Object_Type__c=='Broadband Pro Offering Spec'){
                        faQli.vlocity_cmt__AttributeMetadataChanges__c='{"ATTR_BindingTime_CO":{"values":[{"value":"12","selected":null,"rules":[],"readonly":false,"name":null,"label":"12 months","id":"b61ee0df-d48d-4442-5775-eaefbae028f7","displaySequence":2,"disabled":false,"defaultValue":null,"defaultSelected":null},{"value":"24","selected":null,"rules":[],"readonly":false,"name":null,"label":"24 months","id":"82b64fd2-c996-7af5-e96a-f233e6a4b0e5","displaySequence":3,"disabled":false,"defaultValue":null,"defaultSelected":null},{"value":"36","selected":null,"rules":[],"readonly":false,"name":null,"label":"36 months","id":"dc88ab58-ddfb-1494-1815-214a12dd1121","displaySequence":4,"disabled":false,"defaultValue":null,"defaultSelected":null}]}}';
                    
                    }else if(faQli.TeliaSE_Product_Object_Type__c=='Broadband Plus Offering Spec'){
                     faQli.vlocity_cmt__AttributeMetadataChanges__c='{"ATTR_BindingTime_CO":{"values":[{"value":"0","selected":null,"rules":[],"readonly":false,"name":null,"label":"0 months","id":"b2e0ea32-036f-efe0-5d61-961aeb7545e7","displaySequence":1,"disabled":false,"defaultValue":null,"defaultSelected":null},{"value":"24","selected":null,"rules":[],"readonly":false,"name":null,"label":"24 months","id":"82b64fd2-c996-7af5-e96a-f233e6a4b0e5","displaySequence":3,"disabled":false,"defaultValue":null,"defaultSelected":null}]}}';
                    
                    }else if(faQli.TeliaSE_Product_Object_Type__c=='Broadband Datanet Offering Spec'){                        
                     faQli.vlocity_cmt__AttributeMetadataChanges__c='{"ATTR_BindingTime_CO":{"values":[{"value":"12","selected":null,"rules":[],"readonly":false,"name":null,"label":"12 months","id":"b61ee0df-d48d-4442-5775-eaefbae028f7","displaySequence":2,"disabled":false,"defaultValue":null,"defaultSelected":null},{"value":"24","selected":null,"rules":[],"readonly":false,"name":null,"label":"24 months","id":"82b64fd2-c996-7af5-e96a-f233e6a4b0e5","displaySequence":3,"disabled":false,"defaultValue":null,"defaultSelected":null},{"value":"36","selected":null,"rules":[],"readonly":false,"name":null,"label":"36 months","id":"dc88ab58-ddfb-1494-1815-214a12dd1121","displaySequence":4,"disabled":false,"defaultValue":null,"defaultSelected":null}]}}';

                   
                    }else if(faQli.TeliaSE_Product_Object_Type__c=='SD-WAN/Firewall Offering Spec'){
                        faQli.vlocity_cmt__AttributeMetadataChanges__c='{"ATTR_BindingTime_CO":{"values":[{"value":"12","selected":null,"rules":[],"readonly":false,"name":null,"label":"12 months","id":"b61ee0df-d48d-4442-5775-eaefbae028f7","displaySequence":2,"disabled":false,"defaultValue":null,"defaultSelected":null},{"value":"36","selected":null,"rules":[],"readonly":false,"name":null,"label":"36 months","id":"dc88ab58-ddfb-1494-1815-214a12dd1121","displaySequence":4,"disabled":false,"defaultValue":null,"defaultSelected":null}]}}';
                   
                    }else if(faQli.TeliaSE_Product_Object_Type__c=='WIFI/LAN Offering Spec'){
                     faQli.vlocity_cmt__AttributeMetadataChanges__c='{"ATTR_BindingTime_CO":{"values":[{"value":"12","selected":null,"rules":[],"readonly":false,"name":null,"label":"12 months","id":"b61ee0df-d48d-4442-5775-eaefbae028f7","displaySequence":2,"disabled":false,"defaultValue":null,"defaultSelected":null},{"value":"36","selected":null,"rules":[],"readonly":false,"name":null,"label":"36 months","id":"dc88ab58-ddfb-1494-1815-214a12dd1121","displaySequence":4,"disabled":false,"defaultValue":null,"defaultSelected":null}]}}';
 
                    }
                    
                    updatedFAQliList.add(faQli);
            }
        System.debug('Updated qli size-'+updatedFAQliList.size());
        if(updatedFAQliList.size()>0){
            update updatedFAQliList;
        }
            
        }catch(Exception e){
            system.debug('Exception -- >'+ e);
        }
        
    }
    global void finish(Database.BatchableContext bc){
        
         System.debug('Excecuted-');
    }

}