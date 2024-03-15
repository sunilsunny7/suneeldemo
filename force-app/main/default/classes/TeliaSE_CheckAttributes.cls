/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna
* @version                1.0
* @description            Check whether any attribute is missing for products belong to HW_MOBILEDEVICE and HW_ACCESSORY
* @modified               
******************************************************************************************************************************/
public class TeliaSE_CheckAttributes {
    public static void checkAttributes()
    {
        Set<String> bundleCodes=new Set<String>();
        List<Id> newIds=new List<Id>();
        Map<String,String> productCodes=new Map<String,String>();
        List<vlocity_cmt__AttributeAssignment__c> attributeAssignments=new List<vlocity_cmt__AttributeAssignment__c>();
        vlocity_cmt__AttributeAssignment__c newAttribute;
        for(vlocity_cmt__ProductChildItem__c item:[select vlocity_cmt__ChildProductId__r.productcode from vlocity_cmt__ProductChildItem__c where (vlocity_cmt__ParentProductId__r.productcode like 'HW_MOBILEDEVICE%' or vlocity_cmt__ParentProductId__r.productcode like 'HW_ACCESSORIES%') and (NOT vlocity_cmt__ParentProductId__r.ProductCode like '%OLD')  and name !='Root PCI'])
        {
            bundleCodes.add(item.vlocity_cmt__ChildProductId__r.productcode);
        }
        for(vlocity_cmt__ProductChildItem__c item:[select id,vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.productcode from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.productcode =:bundleCodes and name !='Root PCI'])
        {
            productCodes.put(item.vlocity_cmt__ChildProductId__c,item.vlocity_cmt__ChildProductId__r.productcode);        
        }
        
        for(vlocity_cmt__AttributeAssignment__c attAss:[select vlocity_cmt__ObjectId__c,vlocity_cmt__Value__c from vlocity_cmt__AttributeAssignment__c where vlocity_cmt__ObjectId__c =:productCodes.keySet() and  vlocity_cmt__AttributeId__r.vlocity_cmt__Code__c ='ATT_HW_SAP_ID'])
        {
            if(attAss.vlocity_cmt__Value__c!=null && productCodes.containsKey(attAss.vlocity_cmt__ObjectId__c))
            {
                productCodes.remove(attAss.vlocity_cmt__ObjectId__c);
            }
        }
        String codes='';
        for(String value:productCodes.values())
        {
            codes+=value+',';
        }
        if(productCodes.size()>0)
        {
            Set<String> sapIds=new Set<String>(productCodes.values());
            Database.executeBatch(new Load_Attrributes(sapIds),5);
        }
        Id attCatId=[select id from vlocity_cmt__AttributeCategory__c  where vlocity_cmt__Code__c ='ATT_CODE_TELIAMOBAGGR']?.id;
        Id attId=[select id from vlocity_cmt__Attribute__c where vlocity_cmt__Code__c ='Relation_Id']?.id;
        for(Product2 prod:[select id,vlocity_cmt__JSONAttribute__c,productcode from Product2 where (productcode like 'HW_ACC%' or productcode like 'HW_MOB%')])
        {
            if(String.isBlank(prod.vlocity_cmt__JSONAttribute__c))
            {
                if(prod.productCode.contains('MOBILEDEVICE'))
                {
                        newAttribute=new vlocity_cmt__AttributeAssignment__c();
                        newAttribute.vlocity_cmt__AttributeCategoryId__c=attCatId;
                        newAttribute.vlocity_cmt__ObjectId__c=prod.Id;
                        newAttribute.vlocity_cmt__AttributeId__c=attId;
                        newAttribute.vlocity_cmt__ValueDataType__c='Text';
                        newAttribute.vlocity_cmt__Value__c=null;
                        newAttribute.vlocity_cmt__AttributeDisplayNameOverride__c='Relation_Id';
                        newAttribute.vlocity_cmt__ObjectType__c='vlocity_cmt__ObjectClass__c';
                        newAttribute.vlocity_cmt__IsReadOnly__c=false;
                        newAttribute.Name='Cloned_'+prod.Id;
                        attributeAssignments.add(newAttribute);
                }
                newIds.add(prod.id);
            }
        }
        if(attributeAssignments.size()>0)
        {
            Database.insert(attributeAssignments,false);
        }
        if(newIds.size()>0)
        {
            Database.executeBatch(new vlocity_cmt.EPCProductAttribJSONBatchJob(newIds),2);
        }

    }

}