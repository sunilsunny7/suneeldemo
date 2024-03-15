global class RefreshCacheJobs  implements Queueable  {
    
    global void execute(QueueableContext  qc)
    {
       List<Id> catalogCodes=new List<Id>();
        String catalogCode='MOBILEDEVICE';
                Id catalogId=[select id from vlocity_cmt__Catalog__c where name =:catalogCode]?.Id;    
                catalogCodes.add(catalogId); 

            
            Map<String, Object> input = new Map<String, Object>{'methodName' => 'populateCacheCAJob', 'selectedList' => 
            new List<Object>{'ContextEligibilityGenerator','GetOffersHierarchyHelper','GetOffers','GetPrices','GetOfferDetails'},'filters'=> new Map<String,List<Object>>{'Catalogs'=> catalogCodes}};
            
            vlocity_cmt.TelcoAdminConsoleController controllerClass = new  vlocity_cmt.TelcoAdminConsoleController();
            controllerClass.setParameters(JSON.serialize(input));
            controllerClass.invokeMethod();
    }

}