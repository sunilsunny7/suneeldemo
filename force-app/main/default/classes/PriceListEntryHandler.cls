/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna
* @version                1.0
* @description            upserts products,price and deletes the product from root offer 
* @modified               16-01-2022
* @modified               13-06-2022 fixed bug sales ples being deactivated for existing prices
******************************************************************************************************************************/
public class PriceListEntryHandler {
    public static void handleEvents(List<vlocity_cmt__PriceListEntry__c> oldEntries,List<vlocity_cmt__PriceListEntry__c> newEntries,Map<Id,vlocity_cmt__PriceListEntry__c> oldMap,Map<Id,vlocity_cmt__PriceListEntry__c> newMap,System.TriggerOperation operation)
    {
        switch on operation
        {
            when AFTER_INSERT
            {
               deactivateOldPLEs(newEntries,newMap); 
            }
        }
    }
    
    private static void deactivateOldPLEs(List<vlocity_cmt__PriceListEntry__c> entries,Map<Id,vlocity_cmt__PriceListEntry__c> newMap)
    {
        Set<Id> productIds=new Set<Id>();
        Set<Id> pricingVarIds=new Set<Id>();
        Set<Id> pricingEleIds=new Set<Id>();
        Set<Id> priceListIds=new Set<Id>();
        for(vlocity_cmt__PriceListEntry__c ple:entries)
        {
            productIds.add(ple.vlocity_cmt__ProductId__c);
            pricingEleIds.add(ple.vlocity_cmt__PricingElementId__c);
            priceListIds.add(ple.vlocity_cmt__PriceListId__c);
        }
        for(vlocity_cmt__PricingElement__c ele:[select id,vlocity_cmt__PricingVariableId__c from vlocity_cmt__PricingElement__c where id=:pricingEleIds])
        {
            pricingVarIds.add(ele.vlocity_cmt__PricingVariableId__c);
        }

        List<vlocity_cmt__PriceListEntry__c> oldPles=[select id,vlocity_cmt__PriceListId__c,vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__c from vlocity_cmt__PriceListEntry__c where vlocity_cmt__ProductId__c =:productIds  and id !=:newMap.keySet()];
        
        for(vlocity_cmt__PriceListEntry__c oldPle:oldPles)
        {
            if(pricingVarIds.contains(oldPle.vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__c) && priceListIds.contains(oldPle.vlocity_cmt__PriceListId__c))
            {
                oldPle.vlocity_cmt__IsActive__c=false;
            }
        }
        if(oldPles.size()>0)
        {
            Database.update(oldPles,false);
        }
        
        
    }

}