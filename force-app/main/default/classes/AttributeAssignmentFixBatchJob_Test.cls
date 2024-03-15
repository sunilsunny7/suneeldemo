@istest
public class AttributeAssignmentFixBatchJob_Test {
    @testSetup 
    static void initTestData() {
               Product2 prod1 = new Product2 (Name='Office 365', ProductCode = 'Promo_Riksnet_BB', vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Unspecified","id":10,"displayText":"Unspecified"}],"values":[{"value":"Unspecified","id":10,"displayText":"Unspecified"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
       insert prod1;
        
        vlocity_cmt__AttributeCategory__c cat=new vlocity_cmt__AttributeCategory__c();
        cat.Name='Test1';
        cat.vlocity_cmt__Code__c='TEst';
        cat.vlocity_cmt__IsActive__c=true;
        cat.vlocity_cmt__DisplaySequence__c=10;
        insert cat;
        
        vlocity_cmt__Attribute__c att=new vlocity_cmt__Attribute__c();
        att.Name='Test';
        att.vlocity_cmt__ActiveFlg__c=true;
        att.vlocity_cmt__Code__c='Test';
        att.vlocity_cmt__AttributeCategoryId__c=cat.id;
        insert att;
      
        
       vlocity_cmt__Picklist__c pickList=new vlocity_cmt__Picklist__c();
        pickList.Name='Test';
        pickList.vlocity_cmt__Code__c='Test';
        pickList.vlocity_cmt__DataType__c='Text';
        pickList.vlocity_cmt__IsActive__c=true;
        insert pickList;
        
       vlocity_cmt__AttributeAssignment__c attr = new vlocity_cmt__AttributeAssignment__c();
       attr.Name = 'sd';
       attr.vlocity_cmt__AttributeId__c = att.Id;
       attr.vlocity_cmt__ValueDataType__c='Picklist';
       attr.vlocity_cmt__PicklistId__c=pickList.Id;
       attr.vlocity_cmt__ValidValuesData__c=null;
        attr.vlocity_cmt__Value__c=null;
       insert attr; 
      
        
        vlocity_cmt__PicklistValue__c picklistval = new vlocity_cmt__PicklistValue__c();
        picklistval.vlocity_cmt__PicklistId__c = pickList.Id;
        picklistval.Name = '2000-3599';
       picklistval.vlocity_cmt__IsDefault__c = false; 
       picklistval.vlocity_cmt__Sequence__c = 6;
       picklistval.vlocity_cmt__GlobalKey__c = '5'; 
       picklistval.vlocity_cmt__IsActive__c = true; 
        picklistval.vlocity_cmt__Code__c = 'abcd';
        insert picklistval;
        
        
    }
    @istest static void test(){
   Product2 prod1 = new Product2 (Name='Office 365', ProductCode = 'Promo_Riksnet_BB', vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Unspecified","id":10,"displayText":"Unspecified"}],"values":[{"value":"Unspecified","id":10,"displayText":"Unspecified"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
       insert prod1;
       
        String PicklistId = System.Label.QuarantinePeriodPicklistId;
       
        List<vlocity_cmt__AttributeAssignment__c> attr = new List<vlocity_cmt__AttributeAssignment__c>();
      	attr = [Select Name,vlocity_cmt__AttributeId__c,vlocity_cmt__ExcludedPicklistValues__c,vlocity_cmt__UIDisplayType__c,vlocity_cmt__DefaultPicklistValueId__c,vlocity_cmt__Value__c,vlocity_cmt__ObjectId__c,vlocity_cmt__PicklistId__c,vlocity_cmt__AttributeDisplayName__c,vlocity_cmt__ValueDataType__c,vlocity_cmt__ValidValuesData__c from vlocity_cmt__AttributeAssignment__c Where vlocity_cmt__ValueDataType__c = 'Picklist'];     
      	attr.get(0);
        
        List<SObject> objects = new List<SObject>();   
        objects.add(attr.get(0));
        SObject obj;
        vlocity_cmt__AttributeAssignment__c attrAssign = (vlocity_cmt__AttributeAssignment__c)obj;
      List<SObject> scope = new List<SObject>();
        
     scope = AttributeAssignmentFix.updateAttrAssignments(objects);
        
       List<Id> productIds = new List<Id>();
       new AttributeAssignmentFixBatchJob(productIds).execute(null,scope);
        
        new AttributeAssignmentFixBatchJob(productIds).finish(null);
   //     Test.stopTest();
    }
    
          @istest
    static void test1() {
        List<SObject> scope = new List<SObject>();
        List<Id> productIds = new List<Id>();
        AttributeAssignmentFixBatchJob attassign = new AttributeAssignmentFixBatchJob(productIds);
        attassign.filterDraftAssignments(scope);
        
    }
              @istest
    static void test2() {
        List<Id> productIds = new List<Id>();
        AttributeAssignmentFixBatchJob attassign = new AttributeAssignmentFixBatchJob(productIds);
        Database.BatchableContext BC;
     
              Test.startTest();

            AttributeAssignmentFixBatchJob obj = new AttributeAssignmentFixBatchJob(productIds);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
        
    }
    
       @istest
    static void test3() {
        
         List<Id> productIds = new List<Id>();
        Boolean updateJSONAttributes = true;
        AttributeAssignmentFixBatchJob attassign = new AttributeAssignmentFixBatchJob(productIds,updateJSONAttributes);
        Database.BatchableContext BC;
     
              Test.startTest();

            AttributeAssignmentFixBatchJob obj = new AttributeAssignmentFixBatchJob(productIds,updateJSONAttributes);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
 

}