@isTest
public with sharing class MCONL_GetRules_Test {

@TestSetup
static void makeData(){
    SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];
    vlocity_cmt__ObjectClass__c objectClass = new vlocity_cmt__ObjectClass__c(Name = 'Mobile Handset Product Specification', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
    
    insert objectClass;

    Product2 prod = new Product2(); 
    prod.Name='testProduct1'; 
    prod.ProductCode = '1';
    prod.IsActive=true;
    prod.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Offer' LIMIT 1]?.Id;
    insert prod;

    Product2 prod2 = new Product2(); 
    prod2.Name='testProduct2'; 
    prod2.ProductCode = '2';
    prod2.IsActive=true;
    prod2.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Offer' LIMIT 1]?.Id;
    insert prod2;

    vlocity_cmt__ProductRelationship__c item =new vlocity_cmt__ProductRelationship__c();
    item.Name='Test';
    item.vlocity_cmt__Family__c='Online';
    item.vlocity_cmt__DefaultQuantity__c=1;
    item.vlocity_cmt__MaxQuantity__c=2;
    item.vlocity_cmt__MinQuantity__c=0;
    item.vlocity_cmt__Product2Id__c =[select id from Product2 where productcode='1']?.Id;
    item.vlocity_cmt__RelatedProductId__c=[select id from Product2 where productcode='2']?.Id;
    item.vlocity_cmt__RelationshipType__c='Compatible';
    insert item;

    vlocity_cmt__ProductRelationship__c item2 =new vlocity_cmt__ProductRelationship__c();
    item2.Name='Test2';
    item.vlocity_cmt__Family__c='Online';
    item2.vlocity_cmt__DefaultQuantity__c=1;
    item2.vlocity_cmt__MaxQuantity__c=2;
    item2.vlocity_cmt__MinQuantity__c=0;
    item2.vlocity_cmt__Product2Id__c =[select id from Product2 where productcode='1']?.Id;
    item2.vlocity_cmt__RelatedProductId__c=[select id from Product2 where productcode='2']?.Id;
    item2.vlocity_cmt__RelationshipType__c='Excludes';
    insert item2;
}

@isTest
public static void testgetRules()
{
    Map<String,Object> outMap=new Map<String,Object>();
    new MCONL_GetRules().invokeMethod('getRules', new Map<String,Object>{'ruleType'=>'All'}, outMap, null);
    System.assertEquals(2, ((List<Object>)outMap.get('rules')).size());
    new MCONL_GetRules().invokeMethod('getRules', new Map<String,Object>{'ruleType'=>'Compatible'}, new Map<String,Object>(), null);
    System.assertEquals(1, ((List<Object>)outMap.get('rules')).size());
    new MCONL_GetRules().invokeMethod('', new Map<String,Object>{'ruleType'=>'Compatible'}, new Map<String,Object>(), null);
    System.assertEquals(null, (List<Object>)outMap.get('rules'));
}
}