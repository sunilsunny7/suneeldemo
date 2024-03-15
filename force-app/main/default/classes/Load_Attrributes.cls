/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna
* @version                1.0
* @description            Maps the attribute values to products from load product object 
* @modified               
******************************************************************************************************************************/

global class Load_Attrributes implements Database.Batchable<sObject>,Database.Stateful {
    List<vlocity_cmt__Attribute__c> attributes;
    List<Id> productIds;
    Map<String,Product2> productMap;
    Set<String> codes;
    Id pickListId;
    String query;
    public Load_Attrributes(Set<String> codes)
    {
        this.codes=codes;
        attributes=[select id,vlocity_cmt__Code__c,Name,vlocity_cmt__AttributeCategoryId__c from vlocity_cmt__Attribute__c where vlocity_cmt__Code__c in ('ATT_HW_SAP_ID','ATT_HW_COLOR','ATT_HW_MEMORY','ATT_HW_BRAND','ATT_HW_CATEGORY','ATT_HW_CATEGORY_SV')];
        pickListId=[select id from vlocity_cmt__Picklist__c where vlocity_cmt__Code__c ='PKL_HW_MEMORY']?.id;
        productIds=new List<Id>();
        productMap=new Map<String,Product2>();
        if(codes.size()>0){
            query='select id,SAPID__c,Attribute__c from Load_Product__c where sapId__c =:codes and sapId__c != null and  Action__c =\'import\' and Attribute__c !=null';
        }
        else{
            query='select id,SAPID__c,Attribute__c from Load_Product__c where Type__c =\'Product\' and Status__c in (\'Aktuell\',\'Slutförsäljning\') and isAttributeLoaded__c=false and Attribute__c !=null and Success__c=true';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext context, List<Load_Product__c> prods)
    {
        try{
        List<vlocity_cmt__AttributeAssignment__c> attributeAssignments=new List<vlocity_cmt__AttributeAssignment__c>();
        List<vlocity_cmt__AttributeAssignment__c> existingAttributeAssignments=new List<vlocity_cmt__AttributeAssignment__c>();
        vlocity_cmt__AttributeAssignment__c newAttribute;
        List<String> sapIds=new List<String>();
        Map<String,Map<String,vlocity_cmt__AttributeAssignment__c>> existingAttributes=new Map<String,Map<String,vlocity_cmt__AttributeAssignment__c>>();
        for(Load_Product__c prod:prods)
        {
            sapIds.add(prod.SAPID__c);
        }
        for(Product2 prod2:[select id,ProductCode  from Product2 where productcode=:sapIds]){
            productMap.put(prod2.ProductCode,prod2);
            existingAttributes.put(prod2.id,new Map<String,vlocity_cmt__AttributeAssignment__c>());
        }
        for(vlocity_cmt__AttributeAssignment__c attributeAssignment:[select id,vlocity_cmt__ObjectId__c,vlocity_cmt__AttributeId__r.vlocity_cmt__Code__c from vlocity_cmt__AttributeAssignment__c where vlocity_cmt__ObjectId__c =:existingAttributes.keySet() and vlocity_cmt__ObjectId__c!=null])
        {
            existingAttributes.get(attributeAssignment.vlocity_cmt__ObjectId__c).put(attributeAssignment.vlocity_cmt__AttributeId__r.vlocity_cmt__Code__c,attributeAssignment);
        }
        for(Load_Product__c prod:prods)
        {
            Product2 product=productMap.get(prod.sapId__c);
            if(prod.Attribute__c == null){
                continue;
            }
            Map<String,Object> attributesImported=(Map<String,Object>)JSON.deserializeUntyped(prod.Attribute__c);
            if(product!=null)
            {
                for(vlocity_cmt__Attribute__c attribute:attributes)
                {
                    productIds.add(product.Id);
                    if(existingAttributes.get(product.Id).containsKey(attribute.vlocity_cmt__Code__c))
                    {
                        vlocity_cmt__AttributeAssignment__c existingAttribute=existingAttributes.get(product.Id).get(attribute.vlocity_cmt__Code__c);
                        existingAttribute.vlocity_cmt__Value__c=attributesImported.get(attribute.vlocity_cmt__Code__c)!=null?attributesImported.get(attribute.vlocity_cmt__Code__c)+'':null;
                        existingAttributeAssignments.add(existingAttribute);
                    }
                    else
                    {
                        newAttribute=new vlocity_cmt__AttributeAssignment__c();
                        newAttribute.vlocity_cmt__AttributeCategoryId__c=attribute.vlocity_cmt__AttributeCategoryId__c;
                        newAttribute.vlocity_cmt__ObjectId__c=product.Id;
                        newAttribute.vlocity_cmt__AttributeId__c=attribute.Id;
                        newAttribute.vlocity_cmt__ValueDataType__c=attribute.vlocity_cmt__Code__c == 'ATT_HW_MEMORY'?'Picklist':'Text';
                        newAttribute.vlocity_cmt__Value__c=attributesImported.get(attribute.vlocity_cmt__Code__c)!=null?attributesImported.get(attribute.vlocity_cmt__Code__c)+'':null;
                        newAttribute.vlocity_cmt__AttributeDisplayNameOverride__c=attribute.Name;
                        newAttribute.vlocity_cmt__ObjectType__c='vlocity_cmt__ObjectClass__c';
                        newAttribute.vlocity_cmt__IsReadOnly__c=true;
                        newAttribute.vlocity_cmt__PicklistId__c=attribute.vlocity_cmt__Code__c == 'ATT_HW_MEMORY'?pickListId:null;
                        newAttribute.Name='Cloned_'+product.Id;
                        
                        attributeAssignments.add(newAttribute);    
                    }
                }
                prod.isAttributeLoaded__c=true;
            }
        }
        if(attributeAssignments.size()>0)
        {
           	Database.SaveResult[] res=Database.insert(attributeAssignments,false);   
        }
        if(existingAttributes.size()>0){
            Database.SaveResult[] res=Database.update(existingAttributeAssignments,false);   
        }
        update prods;
        }catch(Exception e)
        {
            LoadProduct_Handler.sendEmail('Exception occurred at '+e.getLineNumber()+' ' +e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        //Database.executeBatch(new vlocity_cmt.EPCProductAttribJSONBatchJob(productIds),2); 
        Database.executeBatch(new AttributeAssignmentFixBatchJob(productIds, true));       
    }

}