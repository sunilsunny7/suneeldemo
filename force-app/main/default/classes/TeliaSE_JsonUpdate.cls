global class TeliaSE_JsonUpdate 
{
    
    global static QuoteLineItem quarantineTimeNode(QuoteLineItem qli)
    {
        //Declaring environment Variables
        String attributeId = System.Label.QuarantinePeriodAttributeId;
        String categoryAttributeId = System.Label.AttributeCategoryId;
        String PicklistId = System.Label.QuarantinePeriodPicklistId;
        String quoteLineItem = qli.id;
        Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c);    
        List<Object> o1 = (List<Object>)rawObj.get('ATT_CODE_TELIAMOBAGGR');
        Map<String,Object> lsstr = new Map<String,Object>();
        List<Object> o3 = new List<Object>();
        string attributeName;
        Boolean flag = false;
        for(Object o2: o1)
        {
            
            lsstr = (Map<String,Object>)o2;
            
            attributeName = (String) lsstr.get('attributeuniquecode__c');
            o3.add(lsstr);
            if(attributeName == 'ATT_QUARANTINE_PERIOD')
            {
                flag=true;
            }  
        }
        System.debug('Flag :' + flag);
        if(flag == false)
        {
            
            
            vlocity_cmt__AttributeAssignment__c quarantinePeriod = new vlocity_cmt__AttributeAssignment__c();
            // Environment Dynamic Values
            quarantinePeriod.vlocity_cmt__AttributeCategoryId__c=categoryAttributeId;  
            quarantinePeriod.vlocity_cmt__AttributeId__c=attributeId;  
            quarantinePeriod.vlocity_cmt__ObjectId__c=quoteLineItem;  
            quarantinePeriod.vlocity_cmt__PicklistId__c=PicklistId;
            //Picklist Id - BaseTime - Environment Specific(Quarantine Period)
            quarantinePeriod.vlocity_cmt__ValidValuesData__c='[{"displayText":"3 månader","id":"7e2d3a6a-20e4-1eca-684d-d2302218d798","isDefault":true,"isEditable":false,"sequence":10,"value":"3"},{"displayText":"6 månader","id":"872b31b5-0782-c189-583f-13eade73dee5","isDefault":false,"isEditable":false,"sequence":20,"value":"6"}]';  
            
            quarantinePeriod.vlocity_cmt__AttributeDisplayNameOverride__c = 'Tid för att uppfylla basnivå';
            quarantinePeriod.vlocity_cmt__AttributeDisplaySequence__c = '40';
            quarantinePeriod.vlocity_cmt__ObjectType__c='Product2';
            quarantinePeriod.vlocity_cmt__UIDisplayType__c='Dropdown';
            quarantinePeriod.vlocity_cmt__Value__c='3';
            quarantinePeriod.vlocity_cmt__ValueDataType__c='Picklist';
            quarantinePeriod.vlocity_cmt__DisplaySequence__c='null';
            quarantinePeriod.vlocity_cmt__IsConfigurable__c = true;
            quarantinePeriod.vlocity_cmt__IsRequired__c =true;
            insert quarantinePeriod;
            system.debug(quarantinePeriod.id);
            
            Map<String,Object> value3 = new Map<String,Object>();
            value3.put('displayText','3 månader');
            value3.put('id','7e2d3a6a-20e4-1eca-684d-d2302218d798');
            value3.put('isDefault',true);
            value3.put('isEditable',false);
            value3.put('sequence',10);
            value3.put('value','3');
            
            Map<String,Object> value6 = new Map<String,Object>();
            value6.put('displayText','6 månader');
            value6.put('id','872b31b5-0782-c189-583f-13eade73dee5');
            value6.put('isDefault',false);
            value6.put('isEditable',false);
            value6.put('sequence',20);
            value6.put('value','6');
            
            List<Map<String,Object>> default1 = new List<Map<String,Object>>();
            default1.add(value3);
            
            List<Map<String,Object>> totalValues = new List<Map<String,Object>>();
            totalValues.add(value3);
            totalValues.add(value6);
            
            Map<String,Object> runtimeAttribute = new Map<String,Object>();
            runtimeAttribute.put('values',totalValues);
            runtimeAttribute.put('selectedItem',value3);
            runtimeAttribute.put('default',default1);
            runtimeAttribute.put('uiDisplayType',quarantinePeriod.vlocity_cmt__UIDisplayType__c);
            runtimeAttribute.put('dataType',quarantinePeriod.vlocity_cmt__ValueDataType__c);
            
            vlocity_cmt__AttributeAssignment__c quarantineAttribute =[select vlocity_cmt__IsActive__c,vlocity_cmt__DisplaySequence__c,vlocity_cmt__ObjectId__c,vlocity_cmt__ObjectType__c,vlocity_cmt__HasRule__c, vlocity_cmt__FormatMask__c,vlocity_cmt__AttributeAdjustmentComments__c, vlocity_cmt__AttributeAdjustmentUnits__c, vlocity_cmt__AttributeCategoryId__c, vlocity_cmt__AttributeCloneable__c, vlocity_cmt__AttributeConfigurable__c, vlocity_cmt__AttributeDisplayName__c, vlocity_cmt__AttributeDisplayNameOverride__c, vlocity_cmt__AttributeDisplaySequence__c, vlocity_cmt__AttributeFilterable__c, vlocity_cmt__AttributeGroupType__c, vlocity_cmt__AttributeId__c, vlocity_cmt__AttributeName__c, vlocity_cmt__AttributeUniqueCode__c, vlocity_cmt__CategoryCode__c, vlocity_cmt__CategoryDisplaySequence__c, vlocity_cmt__CategoryName__c, vlocity_cmt__ConfigurationDetail__c, vlocity_cmt__ConfigurationStages__c, vlocity_cmt__CustomConfigUiTemplate__c, vlocity_cmt__Data__c, vlocity_cmt__DefaultPicklistEntryId__c, vlocity_cmt__IsActiveAssignment__c, vlocity_cmt__IsConfigurable__c, vlocity_cmt__IsDynamic__c, vlocity_cmt__IsEncrypted__c, vlocity_cmt__IsHidden__c, vlocity_cmt__IsNotAssetizable__c, vlocity_cmt__IsNotTranslatable__c, vlocity_cmt__IsOverride__c, vlocity_cmt__IsQueryDriven__c, vlocity_cmt__IsReadOnly__c, vlocity_cmt__IsRequired__c, vlocity_cmt__LookupFilter__c, vlocity_cmt__RemoveDate__c, vlocity_cmt__QueryLabel__c, vlocity_cmt__QueryCode__c, vlocity_cmt__PicklistId__c, vlocity_cmt__ObjectLink__c, vlocity_cmt__LookupObjectTypeId__c, vlocity_cmt__LookupObjectId__c, vlocity_cmt__RemovedFlag__c, vlocity_cmt__RuleData__c, vlocity_cmt__RuleMessage__c, vlocity_cmt__StyleClass__c, vlocity_cmt__UIDisplayType__c, vlocity_cmt__ValidValuesData__c, vlocity_cmt__Value__c, vlocity_cmt__ValueDataType__c, vlocity_cmt__ValueDecoder__c, vlocity_cmt__ValueDescription__c, vlocity_cmt__ValueInNumber__c  from vlocity_cmt__AttributeAssignment__c where Id=: quarantinePeriod.id];
            //Adding Node to JSON of QuoteLineItem
            Map<String,Object> QuarantineNode = new Map<String,Object>();
            QuarantineNode.put('$$AttributeDefinitionStart$$',null);
            QuarantineNode.put('attributecategoryid__c',quarantineAttribute.vlocity_cmt__AttributeCategoryId__c);
            QuarantineNode.put('isnottranslatable__c',quarantineAttribute.vlocity_cmt__IsNotTranslatable__c);
            QuarantineNode.put('valuedescription__c',quarantineAttribute.vlocity_cmt__ValueDescription__c);
            QuarantineNode.put('valuedatatype__c',quarantineAttribute.vlocity_cmt__ValueDataType__c);
            QuarantineNode.put('value__c',quarantineAttribute.vlocity_cmt__Value__c);
            QuarantineNode.put('uidisplaytype__c',quarantineAttribute.vlocity_cmt__UIDisplayType__c);
            QuarantineNode.put('rulemessage__c',quarantineAttribute.vlocity_cmt__RuleMessage__c);
            QuarantineNode.put('isrequired__c',quarantineAttribute.vlocity_cmt__IsRequired__c);
            QuarantineNode.put('id',quarantineAttribute.id);
            QuarantineNode.put('querylabel__c',quarantineAttribute.vlocity_cmt__QueryLabel__c);
            QuarantineNode.put('isquerydriven__c',quarantineAttribute.vlocity_cmt__IsQueryDriven__c);
            QuarantineNode.put('isreadonly__c',quarantineAttribute.vlocity_cmt__IsReadOnly__c);
            QuarantineNode.put('querycode__c',quarantineAttribute.vlocity_cmt__QueryCode__c);
            QuarantineNode.put('objecttype__c',quarantineAttribute.vlocity_cmt__ObjectType__c);
            QuarantineNode.put('valueinnumber__c',quarantineAttribute.vlocity_cmt__ValueInNumber__c);
            QuarantineNode.put('ishidden__c',quarantineAttribute.vlocity_cmt__IsHidden__c);
            QuarantineNode.put('isconfigurable__c',quarantineAttribute.vlocity_cmt__IsConfigurable__c);
            QuarantineNode.put('hasrule__c',quarantineAttribute.vlocity_cmt__HasRule__c);
            QuarantineNode.put('formatmask__c',quarantineAttribute.vlocity_cmt__FormatMask__c);
            QuarantineNode.put('customconfiguitemplate__c',quarantineAttribute.vlocity_cmt__CustomConfigUiTemplate__c);
            QuarantineNode.put('categorydisplaysequence__c',quarantineAttribute.vlocity_cmt__CategoryDisplaySequence__c);
            QuarantineNode.put('displaysequence__c',quarantineAttribute.vlocity_cmt__DisplaySequence__c);
            QuarantineNode.put('attributedisplayname__c',quarantineAttribute.vlocity_cmt__AttributeDisplayName__c);
            QuarantineNode.put('isactive__c',quarantineAttribute.vlocity_cmt__IsActive__c);
            QuarantineNode.put('attributecloneable__c',quarantineAttribute.vlocity_cmt__AttributeCloneable__c);
            QuarantineNode.put('attributefilterable__c',quarantineAttribute.vlocity_cmt__AttributeFilterable__c);
            QuarantineNode.put('attributedisplaysequence__c',quarantineAttribute.vlocity_cmt__AttributeDisplaySequence__c);
            QuarantineNode.put('attributeconfigurable__c',quarantineAttribute.vlocity_cmt__AttributeConfigurable__c);
            QuarantineNode.put('attributeuniquecode__c',quarantineAttribute.vlocity_cmt__AttributeUniqueCode__c);
            QuarantineNode.put('categoryname__c',quarantineAttribute.vlocity_cmt__CategoryName__c);
            QuarantineNode.put('categorycode__c',quarantineAttribute.vlocity_cmt__CategoryCode__c);
            QuarantineNode.put('attributecategoryid__c',quarantineAttribute.vlocity_cmt__AttributeCategoryId__c);
            QuarantineNode.put('attributeid__c',quarantineAttribute.vlocity_cmt__AttributeId__c);
            QuarantineNode.put('objectid__c',quarantineAttribute.vlocity_cmt__ObjectId__c);
            QuarantineNode.put('attributegrouptype__c',quarantineAttribute.vlocity_cmt__AttributeGroupType__c);
            QuarantineNode.put('attributeRunTimeInfo',runtimeAttribute);
            QuarantineNode.put('$$AttributeDefinitionEnd$$',null);
            o3.add(QuarantineNode);
            Map<String,Object> newMap = new Map<String,Object>();
            newMap.put('ATT_CODE_TELIAMOBAGGR',o3);
            
            String jsonMap=JSON.serialize(newMap);
            
            qli.vlocity_cmt__JSONAttribute__c = jsonMap;
            qli.MC_Quarantine_Time__c = quarantineAttribute.vlocity_cmt__Value__c;
            return qli;
        }
        return null;
    }
    
    global static QuoteLineItem quarantineTimeNodeTouchpoint(QuoteLineItem qli)
    {
        //Declaring environment Variables
        String attributeId = System.Label.QuarantinePeriodAttributeId;
        String categoryAttributeId = System.Label.AttributeCategoryId;
        String PicklistId = System.Label.QuarantinePeriodPicklistId;
        
        String quoteLineItem = qli.id;
        Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c);    
        List<Object> o1 = (List<Object>)rawObj.get('ATT_CODE_TELIAMOBAGGR');
        Map<String,Object> lsstr = new Map<String,Object>();
        List<Object> o3 = new List<Object>();
        string attributeName;
        Boolean flag = false;
        for(Object o2: o1)
        {
            lsstr = (Map<String,Object>)o2;
            system.debug('node :' + lsstr );
            attributeName = (String) lsstr.get('attributeuniquecode__c');
            o3.add(lsstr);
            if(attributeName == 'ATT_QUARANTINE_PERIOD')
            {
                flag=true;
            }  
        }
        System.debug('Flag :' + flag);
        if(flag == false)
        {     
            vlocity_cmt__AttributeAssignment__c quarantinePeriod = new vlocity_cmt__AttributeAssignment__c();
            // Environment Dynamic Values
            quarantinePeriod.vlocity_cmt__AttributeCategoryId__c= categoryAttributeId;  
            quarantinePeriod.vlocity_cmt__AttributeId__c= attributeId;  
            quarantinePeriod.vlocity_cmt__ObjectId__c=quoteLineItem;  
            quarantinePeriod.vlocity_cmt__PicklistId__c= PicklistId;  //Picklist Id - BaseTime - Environment Specific(Quarantine Period)
            quarantinePeriod.vlocity_cmt__ValidValuesData__c='[{"displayText":"3 månader","id":"7e2d3a6a-20e4-1eca-684d-d2302218d798","isDefault":true,"isEditable":false,"sequence":10,"value":"3"},{"displayText":"6 månader","id":"872b31b5-0782-c189-583f-13eade73dee5","isDefault":false,"isEditable":false,"sequence":20,"value":"6"}]';  
            
            quarantinePeriod.vlocity_cmt__AttributeDisplayNameOverride__c = 'Tid för att uppfylla basnivå';
            quarantinePeriod.vlocity_cmt__AttributeDisplaySequence__c = '110';
            quarantinePeriod.vlocity_cmt__ObjectType__c='Product2';
            quarantinePeriod.vlocity_cmt__UIDisplayType__c='Dropdown';
            quarantinePeriod.vlocity_cmt__Value__c='3';
            quarantinePeriod.vlocity_cmt__ValueDataType__c='Picklist';
            quarantinePeriod.vlocity_cmt__DisplaySequence__c='null';
            quarantinePeriod.vlocity_cmt__IsConfigurable__c = true;
            quarantinePeriod.vlocity_cmt__IsRequired__c =true;
            insert quarantinePeriod;
            system.debug(quarantinePeriod.id);
            
            Map<String,Object> value3 = new Map<String,Object>();
            value3.put('displayText','3 månader');
            value3.put('id','7e2d3a6a-20e4-1eca-684d-d2302218d798');
            value3.put('isDefault',true);
            value3.put('isEditable',false);
            value3.put('sequence',10);
            value3.put('value','3');
            
            Map<String,Object> value6 = new Map<String,Object>();
            value6.put('displayText','6 månader');
            value6.put('id','872b31b5-0782-c189-583f-13eade73dee5');
            value6.put('isDefault',false);
            value6.put('isEditable',false);
            value6.put('sequence',20);
            value6.put('value','6');
            
            List<Map<String,Object>> default1 = new List<Map<String,Object>>();
            default1.add(value3);
            
            List<Map<String,Object>> totalValues = new List<Map<String,Object>>();
            totalValues.add(value3);
            totalValues.add(value6);
            
            Map<String,Object> runtimeAttribute = new Map<String,Object>();
            runtimeAttribute.put('values',totalValues);
            runtimeAttribute.put('selectedItem',value3);
            runtimeAttribute.put('default',default1);
            runtimeAttribute.put('uiDisplayType',quarantinePeriod.vlocity_cmt__UIDisplayType__c);
            runtimeAttribute.put('dataType',quarantinePeriod.vlocity_cmt__ValueDataType__c);
            
            vlocity_cmt__AttributeAssignment__c quarantineAttribute =[select vlocity_cmt__IsActive__c,vlocity_cmt__DisplaySequence__c,vlocity_cmt__ObjectId__c,vlocity_cmt__ObjectType__c,vlocity_cmt__HasRule__c, vlocity_cmt__FormatMask__c,vlocity_cmt__AttributeAdjustmentComments__c, vlocity_cmt__AttributeAdjustmentUnits__c, vlocity_cmt__AttributeCategoryId__c, vlocity_cmt__AttributeCloneable__c, vlocity_cmt__AttributeConfigurable__c, vlocity_cmt__AttributeDisplayName__c, vlocity_cmt__AttributeDisplayNameOverride__c, vlocity_cmt__AttributeDisplaySequence__c, vlocity_cmt__AttributeFilterable__c, vlocity_cmt__AttributeGroupType__c, vlocity_cmt__AttributeId__c, vlocity_cmt__AttributeName__c, vlocity_cmt__AttributeUniqueCode__c, vlocity_cmt__CategoryCode__c, vlocity_cmt__CategoryDisplaySequence__c, vlocity_cmt__CategoryName__c, vlocity_cmt__ConfigurationDetail__c, vlocity_cmt__ConfigurationStages__c, vlocity_cmt__CustomConfigUiTemplate__c, vlocity_cmt__Data__c, vlocity_cmt__DefaultPicklistEntryId__c, vlocity_cmt__IsActiveAssignment__c, vlocity_cmt__IsConfigurable__c, vlocity_cmt__IsDynamic__c, vlocity_cmt__IsEncrypted__c, vlocity_cmt__IsHidden__c, vlocity_cmt__IsNotAssetizable__c, vlocity_cmt__IsNotTranslatable__c, vlocity_cmt__IsOverride__c, vlocity_cmt__IsQueryDriven__c, vlocity_cmt__IsReadOnly__c, vlocity_cmt__IsRequired__c, vlocity_cmt__LookupFilter__c, vlocity_cmt__RemoveDate__c, vlocity_cmt__QueryLabel__c, vlocity_cmt__QueryCode__c, vlocity_cmt__PicklistId__c, vlocity_cmt__ObjectLink__c, vlocity_cmt__LookupObjectTypeId__c, vlocity_cmt__LookupObjectId__c, vlocity_cmt__RemovedFlag__c, vlocity_cmt__RuleData__c, vlocity_cmt__RuleMessage__c, vlocity_cmt__StyleClass__c, vlocity_cmt__UIDisplayType__c, vlocity_cmt__ValidValuesData__c, vlocity_cmt__Value__c, vlocity_cmt__ValueDataType__c, vlocity_cmt__ValueDecoder__c, vlocity_cmt__ValueDescription__c, vlocity_cmt__ValueInNumber__c  from vlocity_cmt__AttributeAssignment__c where Id=: quarantinePeriod.id];
            //Adding Node to JSON of QuoteLineItem
            Map<String,Object> QuarantineNode = new Map<String,Object>();                 
            QuarantineNode.put('$$AttributeDefinitionStart$$',null);            
            QuarantineNode.put('objectid__c',quarantineAttribute.vlocity_cmt__ObjectId__c);
            QuarantineNode.put('attributeid__c',quarantineAttribute.vlocity_cmt__AttributeId__c);
            QuarantineNode.put('attributecategoryid__c',quarantineAttribute.vlocity_cmt__AttributeCategoryId__c);                   
            QuarantineNode.put('categorycode__c',quarantineAttribute.vlocity_cmt__CategoryCode__c);
            QuarantineNode.put('categoryname__c',quarantineAttribute.vlocity_cmt__CategoryName__c);                   
            QuarantineNode.put('attributeuniquecode__c',quarantineAttribute.vlocity_cmt__AttributeUniqueCode__c);                  
            QuarantineNode.put('attributeconfigurable__c',quarantineAttribute.vlocity_cmt__AttributeConfigurable__c);
            QuarantineNode.put('attributedisplaysequence__c',quarantineAttribute.vlocity_cmt__AttributeDisplaySequence__c);
            QuarantineNode.put('attributefilterable__c',quarantineAttribute.vlocity_cmt__AttributeFilterable__c);
            QuarantineNode.put('attributecloneable__c',quarantineAttribute.vlocity_cmt__AttributeCloneable__c);                   
            QuarantineNode.put('isactive__c',quarantineAttribute.vlocity_cmt__IsActive__c);
            QuarantineNode.put('attributedisplayname__c',quarantineAttribute.vlocity_cmt__AttributeDisplayName__c);
            QuarantineNode.put('displaysequence__c',quarantineAttribute.vlocity_cmt__DisplaySequence__c);
            QuarantineNode.put('categorydisplaysequence__c',quarantineAttribute.vlocity_cmt__CategoryDisplaySequence__c);
            QuarantineNode.put('customconfiguitemplate__c',quarantineAttribute.vlocity_cmt__CustomConfigUiTemplate__c);
            QuarantineNode.put('formatmask__c',quarantineAttribute.vlocity_cmt__FormatMask__c); 
            QuarantineNode.put('hasrule__c',quarantineAttribute.vlocity_cmt__HasRule__c);                         
            QuarantineNode.put('isconfigurable__c',quarantineAttribute.vlocity_cmt__IsConfigurable__c);
            QuarantineNode.put('ishidden__c',quarantineAttribute.vlocity_cmt__IsHidden__c);
            QuarantineNode.put('valueinnumber__c',quarantineAttribute.vlocity_cmt__ValueInNumber__c);
            QuarantineNode.put('objecttype__c',quarantineAttribute.vlocity_cmt__ObjectType__c);                   
            QuarantineNode.put('querycode__c',quarantineAttribute.vlocity_cmt__QueryCode__c);                   
            QuarantineNode.put('isreadonly__c',quarantineAttribute.vlocity_cmt__IsReadOnly__c);
            QuarantineNode.put('isquerydriven__c',quarantineAttribute.vlocity_cmt__IsQueryDriven__c);                  
            QuarantineNode.put('querylabel__c',quarantineAttribute.vlocity_cmt__QueryLabel__c);
            QuarantineNode.put('id',quarantineAttribute.id);                   
            QuarantineNode.put('isrequired__c',quarantineAttribute.vlocity_cmt__IsRequired__c);                   
            QuarantineNode.put('rulemessage__c',quarantineAttribute.vlocity_cmt__RuleMessage__c); 
            QuarantineNode.put('uidisplaytype__c',quarantineAttribute.vlocity_cmt__UIDisplayType__c);
            QuarantineNode.put('value__c',quarantineAttribute.vlocity_cmt__Value__c);                   
            QuarantineNode.put('valuedatatype__c',quarantineAttribute.vlocity_cmt__ValueDataType__c);                   
            QuarantineNode.put('valuedescription__c',quarantineAttribute.vlocity_cmt__ValueDescription__c);
            QuarantineNode.put('isnottranslatable__c',quarantineAttribute.vlocity_cmt__IsNotTranslatable__c);
            QuarantineNode.put('attributegrouptype__c',quarantineAttribute.vlocity_cmt__AttributeGroupType__c);
            QuarantineNode.put('attributeRunTimeInfo',runtimeAttribute);
            QuarantineNode.put('$$AttributeDefinitionEnd$$',null);
            
            o3.add(QuarantineNode);
            Map<String,Object> newMap = new Map<String,Object>();
            newMap.put('ATT_CODE_TELIAMOBAGGR',o3);
            
            String jsonMap=JSON.serialize(newMap);
            
            qli.vlocity_cmt__JSONAttribute__c = jsonMap;
            qli.MC_Quarantine_Time__c = quarantineAttribute.vlocity_cmt__Value__c;
            return qli;
        }
        return null;
    }
    
    global static QuoteLineItem minimumCommitNode(QuoteLineItem qli)
    {
        // Declaring environment dependent values
        String attributeId =    System.label.MinimumCommitAttributeId;
        String categoryAttributeId =  System.label.AttributeCategoryId;
        String PicklistId = System.label.MinimumCommitPicklistId;
        
        String quoteLineItem = qli.id;
        Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c);        
        List<Object> o1 = (List<Object>)rawObj.get('ATT_CODE_TELIAMOBAGGR');        
        Map<String,Object> lsstr = new Map<String,Object>();
        List<Object> o3 = new List<Object>();
        string attributeName;
        Boolean flag = false;    
        for(Object o2: o1)
        {
            lsstr = (Map<String,Object>)o2;
            attributeName = (String) lsstr.get('attributeuniquecode__c');
            o3.add(lsstr);
            if(attributeName == 'ATT_RT_MINC')
            {
                flag=true;
            }  
        }
        System.debug('Flag :' + flag);
        if(flag == false)
        {
            
            vlocity_cmt__AttributeAssignment__c minimumCommit = new vlocity_cmt__AttributeAssignment__c();
            // Environment Dynamic Values
            minimumCommit.vlocity_cmt__AttributeCategoryId__c=categoryAttributeId;  //Attribute Category Id-Environment Specific
            minimumCommit.vlocity_cmt__AttributeId__c= attributeId;  //Attribute ID-Minimum Commit - Environment Specific
            minimumCommit.vlocity_cmt__ObjectId__c=quoteLineItem;  //QuoteLineItemId
            minimumCommit.vlocity_cmt__PicklistId__c=PicklistId;  //Picklist Id - Minimum Commit - Environment Specific
            minimumCommit.vlocity_cmt__ValidValuesData__c='[{"displayText":"75%","id":"aec826dc-a3fd-6d83-8910-7f8da79f8615","isDefault":true,"isEditable":false,"sequence":1,"value":"75"},{"displayText":"50%","id":"fde6a488-a095-8c45-c80c-9f419a1c9c12","isDefault":false,"isEditable":false,"sequence":2,"value":"50"},{"displayText":"0%","id":"0890f600-a12e-a509-9e4f-ce9aacfb255a","isDefault":false,"isEditable":false,"sequence":3,"value":"0"}]';  //ValidValue Set- Extract From Exisiting minimum commit node - Environment Specific 
            
            //Static Values- No change for inserting 75% minimum commit node
            minimumCommit.vlocity_cmt__AttributeDisplayNameOverride__c = 'Basnivå (%)';
            minimumCommit.vlocity_cmt__AttributeDisplaySequence__c = '30';
            minimumCommit.vlocity_cmt__ObjectType__c='Product2';
            minimumCommit.vlocity_cmt__UIDisplayType__c='Dropdown';
            minimumCommit.vlocity_cmt__Value__c='0';
            minimumCommit.vlocity_cmt__ValueDataType__c='Picklist';
            minimumCommit.vlocity_cmt__DisplaySequence__c='10';
            minimumCommit.vlocity_cmt__IsConfigurable__c = true;
            minimumCommit.vlocity_cmt__IsRequired__c =true;
            insert minimumCommit;
            system.debug(minimumCommit.id);
            //-----------------------------------------//
            //-----------------------------------------//
            //RUNTIME NODE
            
            Map<String,Object> value75 = new Map<String,Object>();
            value75.put('value','75');
            value75.put('sequence',1);
            value75.put('id','aec826dc-a3fd-6d83-8910-7f8da79f8615');
            value75.put('displayText','75%');
            
            Map<String,Object> value50 = new Map<String,Object>();
            value50.put('value','50');
            value50.put('sequence',2);
            value50.put('id','fde6a488-a095-8c45-c80c-9f419a1c9c12');
            value50.put('displayText','50%');
            
            Map<String,Object> value0 = new Map<String,Object>();
            value0.put('value','0');
            value0.put('sequence',3);
            value0.put('id','0890f600-a12e-a509-9e4f-ce9aacfb255a');
            value0.put('displayText','0%');
            
            List<Map<String,Object>> default1 = new List<Map<String,Object>>();
            default1.add(value75);
            
            List<Map<String,Object>> totalValues = new List<Map<String,Object>>();
            totalValues.add(value75);
            totalValues.add(value50);
            totalValues.add(value0);
            
            Map<String,Object> runtimeAttribute = new Map<String,Object>();
            runtimeAttribute.put('values',totalValues);
            runtimeAttribute.put('selectedItem',value0);
            runtimeAttribute.put('default',default1);
            runtimeAttribute.put('uiDisplayType',minimumCommit.vlocity_cmt__UIDisplayType__c);
            runtimeAttribute.put('dataType',minimumCommit.vlocity_cmt__ValueDataType__c);
            system.debug('runtimeAttribute: '+ Json.serialize(runtimeAttribute));
            //-----------------------------------------//
            //-----------------------------------------//
            vlocity_cmt__AttributeAssignment__c minimumCommitAttribute =[select vlocity_cmt__IsActive__c,vlocity_cmt__DisplaySequence__c,vlocity_cmt__ObjectId__c,vlocity_cmt__ObjectType__c,vlocity_cmt__HasRule__c, vlocity_cmt__FormatMask__c,vlocity_cmt__AttributeAdjustmentComments__c, vlocity_cmt__AttributeAdjustmentUnits__c, vlocity_cmt__AttributeCategoryId__c, vlocity_cmt__AttributeCloneable__c, vlocity_cmt__AttributeConfigurable__c, vlocity_cmt__AttributeDisplayName__c, vlocity_cmt__AttributeDisplayNameOverride__c, vlocity_cmt__AttributeDisplaySequence__c, vlocity_cmt__AttributeFilterable__c, vlocity_cmt__AttributeGroupType__c, vlocity_cmt__AttributeId__c, vlocity_cmt__AttributeName__c, vlocity_cmt__AttributeUniqueCode__c, vlocity_cmt__CategoryCode__c, vlocity_cmt__CategoryDisplaySequence__c, vlocity_cmt__CategoryName__c, vlocity_cmt__ConfigurationDetail__c, vlocity_cmt__ConfigurationStages__c, vlocity_cmt__CustomConfigUiTemplate__c, vlocity_cmt__Data__c, vlocity_cmt__DefaultPicklistEntryId__c, vlocity_cmt__IsActiveAssignment__c, vlocity_cmt__IsConfigurable__c, vlocity_cmt__IsDynamic__c, vlocity_cmt__IsEncrypted__c, vlocity_cmt__IsHidden__c, vlocity_cmt__IsNotAssetizable__c, vlocity_cmt__IsNotTranslatable__c, vlocity_cmt__IsOverride__c, vlocity_cmt__IsQueryDriven__c, vlocity_cmt__IsReadOnly__c, vlocity_cmt__IsRequired__c, vlocity_cmt__LookupFilter__c, vlocity_cmt__RemoveDate__c, vlocity_cmt__QueryLabel__c, vlocity_cmt__QueryCode__c, vlocity_cmt__PicklistId__c, vlocity_cmt__ObjectLink__c, vlocity_cmt__LookupObjectTypeId__c, vlocity_cmt__LookupObjectId__c, vlocity_cmt__RemovedFlag__c, vlocity_cmt__RuleData__c, vlocity_cmt__RuleMessage__c, vlocity_cmt__StyleClass__c, vlocity_cmt__UIDisplayType__c, vlocity_cmt__ValidValuesData__c, vlocity_cmt__Value__c, vlocity_cmt__ValueDataType__c, vlocity_cmt__ValueDecoder__c, vlocity_cmt__ValueDescription__c, vlocity_cmt__ValueInNumber__c  from vlocity_cmt__AttributeAssignment__c where Id=: minimumCommit.id];
            //Adding Node to JSON of QuoteLineItem
            Map<String,Object> minimumCommitNode = new Map<String,Object>();
            minimumCommitNode.put('$$AttributeDefinitionStart$$',null);
            minimumCommitNode.put('attributecategoryid__c',minimumCommitAttribute.vlocity_cmt__AttributeCategoryId__c);
            minimumCommitNode.put('isnottranslatable__c',minimumCommitAttribute.vlocity_cmt__IsNotTranslatable__c);
            minimumCommitNode.put('valuedescription__c',minimumCommitAttribute.vlocity_cmt__ValueDescription__c);
            minimumCommitNode.put('valuedatatype__c',minimumCommitAttribute.vlocity_cmt__ValueDataType__c);
            minimumCommitNode.put('value__c',minimumCommitAttribute.vlocity_cmt__Value__c);
            minimumCommitNode.put('uidisplaytype__c',minimumCommitAttribute.vlocity_cmt__UIDisplayType__c);
            minimumCommitNode.put('rulemessage__c',minimumCommitAttribute.vlocity_cmt__RuleMessage__c);
            minimumCommitNode.put('isrequired__c',minimumCommitAttribute.vlocity_cmt__IsRequired__c);
            minimumCommitNode.put('id',minimumCommitAttribute.id);
            minimumCommitNode.put('querylabel__c',minimumCommitAttribute.vlocity_cmt__QueryLabel__c);
            minimumCommitNode.put('isquerydriven__c',minimumCommitAttribute.vlocity_cmt__IsQueryDriven__c);
            minimumCommitNode.put('isreadonly__c',minimumCommitAttribute.vlocity_cmt__IsReadOnly__c);
            minimumCommitNode.put('querycode__c',minimumCommitAttribute.vlocity_cmt__QueryCode__c);
            minimumCommitNode.put('objecttype__c',minimumCommitAttribute.vlocity_cmt__ObjectType__c);
            minimumCommitNode.put('valueinnumber__c',minimumCommitAttribute.vlocity_cmt__ValueInNumber__c);
            minimumCommitNode.put('ishidden__c',minimumCommitAttribute.vlocity_cmt__IsHidden__c);
            minimumCommitNode.put('isconfigurable__c',minimumCommitAttribute.vlocity_cmt__IsConfigurable__c);
            minimumCommitNode.put('hasrule__c',minimumCommitAttribute.vlocity_cmt__HasRule__c);
            minimumCommitNode.put('formatmask__c',minimumCommitAttribute.vlocity_cmt__FormatMask__c);
            minimumCommitNode.put('customconfiguitemplate__c',minimumCommitAttribute.vlocity_cmt__CustomConfigUiTemplate__c);
            minimumCommitNode.put('categorydisplaysequence__c',minimumCommitAttribute.vlocity_cmt__CategoryDisplaySequence__c);
            minimumCommitNode.put('displaysequence__c',minimumCommitAttribute.vlocity_cmt__DisplaySequence__c);
            minimumCommitNode.put('attributedisplayname__c',minimumCommitAttribute.vlocity_cmt__AttributeDisplayName__c);
            minimumCommitNode.put('isactive__c',minimumCommitAttribute.vlocity_cmt__IsActive__c);
            minimumCommitNode.put('attributecloneable__c',minimumCommitAttribute.vlocity_cmt__AttributeCloneable__c);
            minimumCommitNode.put('attributefilterable__c',minimumCommitAttribute.vlocity_cmt__AttributeFilterable__c);
            minimumCommitNode.put('attributedisplaysequence__c',minimumCommitAttribute.vlocity_cmt__AttributeDisplaySequence__c);
            minimumCommitNode.put('attributeconfigurable__c',minimumCommitAttribute.vlocity_cmt__AttributeConfigurable__c);
            minimumCommitNode.put('attributeuniquecode__c',minimumCommitAttribute.vlocity_cmt__AttributeUniqueCode__c);
            minimumCommitNode.put('categoryname__c',minimumCommitAttribute.vlocity_cmt__CategoryName__c);
            minimumCommitNode.put('categorycode__c',minimumCommitAttribute.vlocity_cmt__CategoryCode__c);
            minimumCommitNode.put('attributecategoryid__c',minimumCommitAttribute.vlocity_cmt__AttributeCategoryId__c);
            minimumCommitNode.put('attributeid__c',minimumCommitAttribute.vlocity_cmt__AttributeId__c);
            minimumCommitNode.put('objectid__c',minimumCommitAttribute.vlocity_cmt__ObjectId__c);
            minimumCommitNode.put('attributegrouptype__c',minimumCommitAttribute.vlocity_cmt__AttributeGroupType__c);
            minimumCommitNode.put('attributeRunTimeInfo',runtimeAttribute);
            minimumCommitNode.put('$$AttributeDefinitionEnd$$',null);
            
            
            o3.add(minimumCommitNode);
            Map<String,Object> newMap = new Map<String,Object>();
            newMap.put('ATT_CODE_TELIAMOBAGGR',o3);
            System.debug(newMap);
            String jsonMap=JSON.serialize(newMap);
            System.debug(jsonMap);
            qli.vlocity_cmt__JSONAttribute__c = jsonMap;
            qli.TeliaSE_Minimum_Value_Commit__c = minimumCommitAttribute.vlocity_cmt__Value__c;
            return qli;
        }
        
        return null;
    }
    
    global static QuoteLineItem unhideMinimumCommitNode(QuoteLineItem qli)
    {
        String quoteLineItem = qli.id;
        Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c);
        List<Object> o1 = (List<Object>)rawObj.get('ATT_CODE_TELIAMOBAGGR');
        Map<String,Object> lsstr = new Map<String,Object>();
        List<Object> o3 = new List<Object>();
        string attributeName;
        Boolean flag = false;  
        System.debug('unhide minimum');
        for(Object o2: o1)
        {
            lsstr = (Map<String,Object>)o2;
            attributeName = (String) lsstr.get('attributeuniquecode__c');
            system.debug('AttributeName :'+attributeName +'  status:'+lsstr.get('ishidden__c'));
            If(attributeName == 'ATT_RT_MINC')
            {
                if(lsstr.get('ishidden__c') == true)
                {
                    System.debug('inside loop');
                    lsstr.put('ishidden__c',false);
                    flag = true;
                }
            }
            If(attributeName == 'ATTR_INVOICE')
            {
                System.debug('Invoice Fee Loop');
                lsstr.put('ishidden__c',true);
            }           
            o3.add(lsstr);
        }
        if(flag == true)
        {
            System.debug('Object 3 :' + o3);
            Map<String,Object> newMap = new Map<String,Object>();
            newMap.put('ATT_CODE_TELIAMOBAGGR',o3);
            System.debug(newMap);
            String jsonMap=JSON.serialize(newMap);
            System.debug(jsonMap);
            qli.vlocity_cmt__JSONAttribute__c = jsonMap;
            return qli;
        }
        else
        {
            return null;
        }
        
    }
    
    
    /*Script for adding nodes
*****Change the quotelineitem query for querying mobile products******************

Set<Id> roamingProdSet = new Set<Id>();
List<QuoteLineItem> qliList = [Select id, TeliaSE_Product_Code__c,vlocity_cmt__Product2Id__c ,RoamingResAddOns__c, RoamingTillAddOns__c,vlocity_cmt__JSONAttribute__c from QuoteLineItem where quoteId in ('0Q03N000000L2LfSAK') and TeliaSE_Product_Code__c in ('MOB_MULTI_ALL_IN_PLUS_V2','MOB_MULTI_TOTAL_V2','MOB_CALL_TRAVEL_EAST','MOB_CALL_TRAVEL_EUROPE','MOB_CALL_TRAVEL_OTHER','MOB_CALL_TRAVEL_OVERSEAS','MOB_CALL_TRAVEL_SOUTH','MOB_CALL_TRAVEL_WEST')];
for(QuoteLineItem qli : qliList)
{
if(qli.TeliaSE_Product_Code__c !='MOB_MULTI_ALL_IN_PLUS_V2' && qli.TeliaSE_Product_Code__c != 'MOB_MULTI_TOTAL_V2')
{
roamingProdSet.add(qli.vlocity_cmt__Product2Id__c);
}
}
List<vlocity_cmt__AttributeAssignment__c> attributeids = [Select id,vlocity_cmt__ObjectId__c, name from vlocity_cmt__AttributeAssignment__c where vlocity_cmt__ObjectId__c in: roamingProdList and (vlocity_cmt__AttributeId__c=:Label.TeliaSE_ResAttributeId OR vlocity_cmt__AttributeId__c=:Label.TeliaSE_TillAttributeId)];
Map<Id,Id> attributeIdObjectIdMap = new Map<Id,Id>();
for(vlocity_cmt__AttributeAssignment__c att : attributeids)
{
attributeIdObjectIdMap.put(att.vlocity_cmt__ObjectId__c,att.Id);    
}
system.debug('attributeMap'+attributeIdObjectIdMap);
List<QuoteLineItem> updateQliList = new List<QuoteLineItem>();
For(QuoteLineItem qli : qliList)
{
if(roamingProdSet.contains(qli.vlocity_cmt__Product2Id__c))
{
quotelineItem qli3 = TeliaSE_JsonUpdate.updateRoamingAddOns(qli,attributeIdObjectIdMap,true);
if(qli3 != null)
{
updateQliList.add(qli3);
} 
}
else
{
quotelineItem qli2 = TeliaSE_JsonUpdate.updateRoamingAddOns(qli,attributeIdObjectIdMap,false);

if(qli2 != null)
{
updateQliList.add(qli2);
}
}


}

system.debug('updateQliList size: '+updateQliList.size());
if(updateQliList.size()>0 && updateQliList.size()<50000)
{
update updateQliList;
}
**********************************************************************************

*/
    
    global static QuoteLineItem updateRoamingAddOns(QuoteLineItem qli,Map<Id,Id> attributeIdObjectIdMap,Boolean RoamingAddOn,Boolean isTotal)
    {
        Boolean flag = false;
        String attributeName;
        //QuoteLineItem qli = [Select id, vlocity_cmt__Product2Id__c ,RoamingResAddOns__c, RoamingTillAddOns__c,vlocity_cmt__JSONAttribute__c from QuoteLineItem where id = '0QL1w000000BRH9'];
        if(RoamingAddOn != true)
        {          
            
            String resAttributeNode= '{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000003h58PAAQ","attributeid__c":"a364E000000M2chQAC","attributecategoryid__c":"a354E0000002E2zQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_RES","attributeconfigurable__c":true,"attributedisplaysequence__c":"91","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Res Söderut, Res Västerut, och Res Österut","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a331w0000002603AAA","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 19 kr, 19 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 19 kr, 19 kr, 19 kr","sequence":1,"id":"143032da-37b3-c5ec-af7f-64c34ac0454a","displayText":"Standard 19 kr, 19 kr, 19 kr"}],"values":[{"value":"Standard 19 kr, 19 kr, 19 kr","sequence":1,"id":"143032da-37b3-c5ec-af7f-64c34ac0454a","displayText":"Standard 19 kr, 19 kr, 19 kr"},{"value":"15 kr, 15 kr, 15 kr","sequence":2,"id":"48550f57-a0f1-f0e7-a95d-f5118291bcc6","displayText":"15 kr, 15 kr, 15 kr"},{"value":"10 kr, 10 kr, 10 kr","sequence":3,"id":"daa79e32-0c91-b449-12f9-5b1e9462336d","displayText":"10 kr, 10 kr, 10 kr"},{"value":"Alla användare, alla tjänster. 5 kr, 5 kr, 5 kr","sequence":4,"id":"ea4adb3c-8605-824a-b737-0cfea76b87f1","displayText":"Alla användare, alla tjänster. 5 kr, 5 kr, 5 kr"},{"value":"Alla användare, alla tjänster. 0 kr, 0 kr, 0 kr","sequence":5,"id":"8cb612bc-5bb4-d606-7193-282affd20504","displayText":"Alla användare, alla tjänster. 0 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 19 kr, 19 kr, 19 kr","sequence":1,"id":"143032da-37b3-c5ec-af7f-64c34ac0454a","displayText":"Standard 19 kr, 19 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null}';
            Map<String,Object> resAttributeMap = (Map<String,Object>) JSON.deserializeUntyped(resAttributeNode);
            resAttributeMap.put('objectid__c',qli.vlocity_cmt__Product2Id__c);
            resAttributeMap.put('attributecategoryid__c',Label.AttributeCategoryId);
            resAttributeMap.put('attributeid__c',Label.TeliaSE_ResAttributeId);
            resAttributeMap.put('id',label.TeliaSE_ResNodeId);
            
            String tillAtribute= '{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000003h58PAAQ","attributeid__c":"a364E000000M2ciQAC","attributecategoryid__c":"a354E0000002E2zQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Till Europa, Till Grannland Företag, och Till Utland Företag","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a331w0000002604AAA","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"27651873-594f-6909-ca87-388bb5761e2c","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"dd5f0a1a-922b-972e-bc15-1fbc36fbb0eb","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"c8993e51-e2a0-41b9-d241-2daa15bbe74a","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null}';
            system.debug('till Attribute:'+tillAtribute);
            Map<String,Object> tillAttributeMap = (Map<String,Object>) JSON.deserializeUntyped(tillAtribute);
            tillAttributeMap.put('objectid__c',qli.vlocity_cmt__Product2Id__c);
            tillAttributeMap.put('attributecategoryid__c',Label.AttributeCategoryId);
            tillAttributeMap.put('attributeid__c',Label.TeliaSE_TillAttributeId);
            tillAttributeMap.put('id',label.TeliaSE_TillNodeId);
            
            if((String)qli.TeliaSE_Product_Code__c == 'MOB_MULTI_TOTAL_V2')
            {
                system.debug('Total Product found');
                resAttributeMap.put('id',label.TeliaSE_ResNodeId_Total);
                tillAttributeMap.put('id',label.TeliaSE_TillNodeId_Total);      
            }
            Map<String,Object> rawObj1 = (Map<String,Object>) JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c);        
            List<Object> o1 = (List<Object>)rawObj1.get('ATT_CODE_TELIAMOBAGGR'); 
            Map<String,Object> lsstr = new Map<String,Object>();
            For(Object o : o1)
            {
                lsstr = (Map<String,Object>)o;
                attributeName = (String) lsstr.get('attributeuniquecode__c');
                If(attributeName == 'ATT_NEG_ROAMING_RES' || attributeName == 'ATT_NEG_ROAMING_TILL')
                {
                    flag = true;
                }
            }
            system.debug('Flag:'+flag);
            if(flag == false)
            {
                o1.add(resAttributeMap);
                o1.add(tillAttributeMap);
                Map<String,Object> newMap = new Map<String,Object>();
                newMap.put('ATT_CODE_TELIAMOBAGGR',o1);
                String jsonMap=JSON.serialize(newMap);
                if((String)qli.TeliaSE_Product_Code__c == 'MOB_MULTI_TOTAL_V2')
                {
                    Map<String,Object> rawObj2 = (Map<String,Object>) JSON.deserializeUntyped(jsonMap);
                    jsonMap=JSON.serialize(rawObj2);
                }
                qli.vlocity_cmt__JSONAttribute__c = jsonMap;
                qli.RoamingResAddOns__c = 'Standard 19 kr, 19 kr, 19 kr';
                qli.RoamingTillAddOns__c= 'Standard 89 kr, 49 kr, 19 kr';
                return qli;
            }
            else
            {
                return null;
            }
        }
        
        else
        {
            Id nodeId = attributeIdObjectIdMap.get(qli.vlocity_cmt__Product2Id__c);
            String resAttributeNode= '{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yN6AAI","attributeid__c":"a360Q000000DhLpQAK","attributecategoryid__c":"a350Q000000EKa9QAG","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_RES","attributeconfigurable__c":true,"attributedisplaysequence__c":"91","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Res AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q000000DqNZQA0","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 19 kr, 19 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"Standard 19 kr, 19 kr, 19 kr","id":"143032da-37b3-c5ec-af7f-64c34ac0454a","sequence":1,"value":"Standard 19 kr, 19 kr, 19 kr"}],"values":[{"displayText":"Standard 19 kr, 19 kr, 19 kr","id":"143032da-37b3-c5ec-af7f-64c34ac0454a","sequence":1,"value":"Standard 19 kr, 19 kr, 19 kr"},{"displayText":"15 kr, 15 kr, 15 kr","id":"48550f57-a0f1-f0e7-a95d-f5118291bcc6","sequence":2,"value":"15 kr, 15 kr, 15 kr"},{"displayText":"10 kr, 10 kr, 10 kr","id":"daa79e32-0c91-b449-12f9-5b1e9462336d","sequence":3,"value":"10 kr, 10 kr, 10 kr"},{"displayText":"Alla användare, alla tjänster. 5 kr, 5 kr, 5 kr","id":"ea4adb3c-8605-824a-b737-0cfea76b87f1","sequence":4,"value":"Alla användare, alla tjänster. 5 kr, 5 kr, 5 kr"},{"displayText":"Alla användare, alla tjänster. 0 kr, 0 kr, 0 kr","id":"8cb612bc-5bb4-d606-7193-282affd20504","sequence":5,"value":"Alla användare, alla tjänster. 0 kr, 0 kr, 0 kr"}],"selectedItem":{"displayText":"Standard 19 kr, 19 kr, 19 kr","id":"143032da-37b3-c5ec-af7f-64c34ac0454a","sequence":1,"value":"Standard 19 kr, 19 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null}';
            Map<String,Object> resAttributeMap = (Map<String,Object>) JSON.deserializeUntyped(resAttributeNode);
            resAttributeMap.put('objectid__c',qli.vlocity_cmt__Product2Id__c);
            resAttributeMap.put('attributecategoryid__c',Label.AttributeCategoryId);
            resAttributeMap.put('attributeid__c',Label.TeliaSE_ResAttributeId);
            resAttributeMap.put('id',nodeId);
            
            String tillAtribute= '{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a360Q000000DhLqQAK","attributecategoryid__c":"a350Q000000EKa9QAG","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q000000DqNKQA0","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"Standard 89 kr, 49 kr, 19 kr","id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","sequence":1,"value":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"displayText":"Standard 89 kr, 49 kr, 19 kr","id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","sequence":1,"value":"Standard 89 kr, 49 kr, 19 kr"},{"displayText":"69 kr, 49 kr, 19 kr","id":"a63eccc4-e18f-75ec-42fb-2200074c064b","sequence":2,"value":"69 kr, 49 kr, 19 kr"},{"displayText":"59 kr, 39 kr, 19 kr","id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","sequence":3,"value":"59 kr, 39 kr, 19 kr"},{"displayText":"69 kr, 49 kr, 15 kr","id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","sequence":4,"value":"69 kr, 49 kr, 15 kr"},{"displayText":"59 kr, 39 kr, 15 kr","id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","sequence":5,"value":"59 kr, 39 kr, 15 kr"},{"displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr","id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","sequence":6,"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr","id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","sequence":7,"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr","id":"551aee5a-637e-9907-beed-05b0ec37b272","sequence":8,"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr","id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","sequence":9,"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","id":"1ba0de8b-b225-49d5-c596-4874b84c4297","sequence":10,"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","sequence":11,"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","sequence":12,"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr","id":"ccf729aa-485a-311b-a010-cd6727d8f27a","sequence":13,"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr","id":"be39cb66-6a44-6372-d7bf-438f130eebc3","sequence":14,"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr","id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","sequence":15,"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr","id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","sequence":16,"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr","id":"97d75109-a29f-8b72-96d0-e84149d77339","sequence":17,"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr","id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","sequence":18,"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","id":"2eea7313-03cb-9da5-3741-48a98cd2636b","sequence":19,"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","id":"e4b437ac-32bb-b61f-708a-43f3923d0723","sequence":20,"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","sequence":21,"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","sequence":22,"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","sequence":23,"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","sequence":24,"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","sequence":25,"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"displayText":"Standard 89 kr, 49 kr, 19 kr","id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","sequence":1,"value":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null}';
            system.debug('till Attribute:'+tillAtribute);
            Map<String,Object> tillAttributeMap = (Map<String,Object>) JSON.deserializeUntyped(tillAtribute);
            tillAttributeMap.put('objectid__c',qli.vlocity_cmt__Product2Id__c);
            tillAttributeMap.put('attributecategoryid__c',Label.AttributeCategoryId);
            tillAttributeMap.put('attributeid__c',Label.TeliaSE_TillAttributeId);
            tillAttributeMap.put('id',nodeId);
            
            Map<String,Object> rawObj1 = (Map<String,Object>) JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c);        
            List<Object> o1 = (List<Object>)rawObj1.get('ATT_CODE_TELIAMOBAGGR'); 
            Map<String,Object> lsstr = new Map<String,Object>();
            For(Object o : o1)
            {
                lsstr = (Map<String,Object>)o;
                attributeName = (String) lsstr.get('attributeuniquecode__c');
                If(attributeName == 'ATT_NEG_ROAMING_RES' || attributeName == 'ATT_NEG_ROAMING_TILL')
                {
                    flag = true;
                }
            }
            if(flag == false)
            {
                if((String)qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_EAST' || (String)qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_SOUTH' || (String)qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_WEST')
                {
                    o1.add(resAttributeMap);    
                }
                else 
                {
                    o1.add(tillAttributeMap);
                    if((String)qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_OVERSEAS')
                    {
                        qli.TeliaSE_Ceiling_Price__c = 19;
                        qli.vlocity_cmt__RecurringCharge__c =19;
                    }
                }
                Map<String,Object> newMap = new Map<String,Object>();
                newMap.put('ATT_CODE_TELIAMOBAGGR',o1);
                String jsonMap=JSON.serialize(newMap);
                if(isTotal)
                {
                    Map<String,Object> rawObj2 = (Map<String,Object>) JSON.deserializeUntyped(jsonMap);
                    jsonMap=JSON.serialize(rawObj2);
                }
                qli.vlocity_cmt__JSONAttribute__c = jsonMap;
                return qli;
            }
            else
            {
                return null;
            }
        }
    }
    
    
    
}