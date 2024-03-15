/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna
* @version                1.0
* @description            Runs maintainance jobs Clear cache, maintaining hierarchy and regenerating cache records
* @modified               20-01-2022
******************************************************************************************************************************/


global without sharing class TeliaSE_Maintain_Jobs implements Schedulable {
    String type;
    global TeliaSE_Maintain_Jobs(String type)
    {
        this.type=type;
    }
    global void execute(SchedulableContext SC) {
        switch on type
        {
            when 'LoadBatch'
            {
                Database.executeBatch(new LoadProductBatch('Bundle',new Set<String>()),1);
            }
            when 'LoadAttributes'
            {
                Database.executeBatch(new Load_Attrributes(new Set<String>()),5);    
            }
            when 'checkAttributes'
            {
                TeliaSE_CheckAttributes.checkAttributes();
            }
            when 'RefreshCache'
            {
                runMaintenanceJobs();    
            }
            when 'RegenerateCache'
            {
                runRegenerateCacheJob();
            }
            when 'cacheWarmup'
            {
                cacheWarmup();
            }
        }
     }
    // runRegenerateCacheJob runs the regenerate cache job. Cannot be run in parallel with runMaintenanceJobs, must be run after in series.
    public static void runRegenerateCacheJob(){ 
        try{        
            List<vlocity_cmt__Rule__c> rules=[select id from vlocity_cmt__Rule__c where vlocity_cmt__IsActive__c =true];
            for(vlocity_cmt__Rule__c rule:rules)
            {
                rule.vlocity_cmt__IsActive__c=false;
            }
            Database.update(rules,false);

            List<Object> catalogCodes=new List<Object>();
            List<Object> catalogIds=new List<Object>();
            for(vlocity_cmt__Catalog__c catalog:[select id,vlocity_cmt__CatalogCode__c from vlocity_cmt__Catalog__c where vlocity_cmt__IsActive__c =true and vlocity_cmt__CatalogCode__c in ('MOBILEDEVICE','ACCESSORY','MOBILEDEVICE_NEW')])
            {
                catalogCodes.add(catalog.vlocity_cmt__CatalogCode__c);
                catalogIds.add(catalog.id);
            }
            Map<String, Object> input = new Map<String, Object>{'methodName'=>'cacheProductDefinitions','filters'=>new Map<String,Object>{'Catalogs'=>catalogIds,'catalogCodes'=>catalogCodes,'performCpqNext'=>true}};
            vlocity_cmt.TelcoAdminConsoleController controllerClass = new vlocity_cmt.TelcoAdminConsoleController();
            controllerClass.setParameters(JSON.serialize(input));
            if(!Test.isRunningTest()){            
                controllerClass.invokeMethod();
            }
        }
        catch(Exception e) {}

    }

    // runMaintenanceJobs runs the following jobs in series: Product Hierarchy Maintenance, Clear Managed Platform Cache, Refresh Platform Cache 
    public static void runMaintenanceJobs() { 
        vlocity_cmt.CMTAdminJobService.startProductHierarchyMaintenanceJob(null); 
    }

    private static void cacheWarmup()
    {
        List<vlocity_cmt__Rule__c> rules=[select id from vlocity_cmt__Rule__c where vlocity_cmt__IsActive__c =false];
        for(vlocity_cmt__Rule__c rule:rules)
        {
            rule.vlocity_cmt__IsActive__c=true;
        }
        Database.update(rules,false);
    }
}