public class mobileMigrationJsonUpdate {
    public static void jsonUpdate(Id qliId){
        //qliId=0QL5E000000kpKq

        Map<String,String> oldValueToNewValueMap=new Map<String,String>();
        Map<String,String> oldValueToGlobalKeyMap=new Map<String,String>();
        Map<String,String> oldValueToNewValueMapRes=new Map<String,String>();
        Map<String,String> oldValueToGlobalKeyMapRes=new Map<String,String>();
         oldValueToNewValueMap.put('Standard 89 kr, 49 kr, 19 kr','AM : 89 kr, 49 kr, 19 kr');
         oldValueToNewValueMap.put('69 kr, 49 kr, 19 kr','SM : 69 kr, 49 kr, 19 kr');
         oldValueToNewValueMap.put('59 kr, 39 kr, 19 kr','SM : 59 kr, 39 kr, 19 kr');
         oldValueToNewValueMap.put('69 kr, 49 kr, 15 kr','SM : 69 kr, 49 kr, 15 kr');
         oldValueToNewValueMap.put('59 kr, 39 kr, 15 kr','SM : 59 kr, 39 kr, 15 kr'); 
         oldValueToNewValueMap.put('Europa - alla anv. 49 kr, 49 kr, 19 kr','SD : Europa - alla anv. [49 kr, 49 kr, 19 kr]'); 
         oldValueToNewValueMap.put('Europa - alla anv. 39 kr, 49 kr, 19 kr','SD : Europa - alla anv. [39 kr, 49 kr, 19 kr]'); 
         oldValueToNewValueMap.put('Europa - alla anv. 29 kr, 49 kr, 19 kr','SD : Europa - alla anv. [29 kr, 49 kr, 19 kr]'); 
         oldValueToNewValueMap.put('Europa - alla anv. 0 kr, 49 kr, 19 kr','CM : Europa - alla anv. [0 kr, 49 kr, 19 kr]'); 
         oldValueToNewValueMap.put('Grannland - alla anv. 89 kr, 29 kr, 19 kr','SD : Grannland - alla anv. [89 kr, 29 kr, 19 kr]'); 
         oldValueToNewValueMap.put('Grannland - alla anv. 89 kr, 19 kr, 19 kr','SD : Grannland - alla anv. [89 kr, 19 kr, 19 kr]'); 
         oldValueToNewValueMap.put('Grannland - alla anv. 89 kr, 0 kr, 19 kr','CM : Grannland - alla anv. [89 kr, 0 kr, 19 kr]'); 
         oldValueToNewValueMap.put('Utland - alla anv. 89 kr, 49 kr, 12 kr','SD : Utland - alla anv. [89 kr, 49 kr, 12 kr]'); 
         oldValueToNewValueMap.put('Utland - alla anv. 69 kr, 39 kr, 12 kr','SD : Utland - alla anv. [69 kr, 39 kr, 12 kr]'); 
         oldValueToNewValueMap.put('Utland - alla anv. 89 kr, 49 kr, 9 kr','SD : Utland - alla anv. [89 kr, 49 kr, 9 kr]'); 
         oldValueToNewValueMap.put('Utland - alla anv. 69 kr, 39 kr, 9 kr','SD : Utland - alla anv. [69 kr, 39 kr, 9 kr]'); 
         oldValueToNewValueMap.put('Utland - alla anv. 89 kr, 49 kr, 0 kr','SD : Utland - alla anv. [89 kr, 49 kr, 0 kr]'); 
         oldValueToNewValueMap.put('Utland - alla anv. 69 kr, 39 kr, 0 kr','SD : Utland - alla anv. [69 kr, 39 kr, 0 kr]'); 
         oldValueToNewValueMap.put('Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr','SD : Europa & Utland - alla anv.  [49 kr, 49 kr, 12 kr]'); 
         oldValueToNewValueMap.put('Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr','SD : Europa & Utland - alla anv. [39 kr, 49 kr, 12 kr]'); 
         oldValueToNewValueMap.put('Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr','SD : Europa & Utland - alla anv. [29 kr, 49 kr, 9 kr]'); 
         oldValueToNewValueMap.put('Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr','CM : Europa & Utland - alla anv. [0 kr, 49 kr, 0 kr]'); 
         oldValueToNewValueMap.put('Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr','SD : Grannland & Utland - alla anv. [89 kr, 29 kr, 12 kr]'); 
         oldValueToNewValueMap.put('Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr','SD : Grannland & Utland - alla anv. [89 kr, 19 kr, 9 kr]'); 
         oldValueToNewValueMap.put('Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr','CM : Grannland & Utland - alla anv. [89 kr, 0 kr, 0 kr]'); 


         oldValueToGlobalKeyMap.put('Standard 89 kr, 49 kr, 19 kr','f713a720-7fa6-dcbf-9bba-b75645e490b4');
         oldValueToGlobalKeyMap.put('69 kr, 49 kr, 19 kr','6f7f368f-45ac-42f1-96dc-fd2f2150f33a');
         oldValueToGlobalKeyMap.put('59 kr, 39 kr, 19 kr','f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd');
         oldValueToGlobalKeyMap.put('69 kr, 49 kr, 15 kr','a4fdeaee-1074-5189-ddfd-712b184e7c37');
         oldValueToGlobalKeyMap.put('59 kr, 39 kr, 15 kr','e32ac4bd-6719-f23c-466b-738d35a2d65d');
         oldValueToGlobalKeyMap.put('Europa - alla anv. 49 kr, 49 kr, 19 kr','ad9fcac8-bd33-8736-c1a2-3d18994136de');
         oldValueToGlobalKeyMap.put('Europa - alla anv. 39 kr, 49 kr, 19 kr','183b5d9d-f0d5-f30d-d58c-7a74b0a211c3');
         oldValueToGlobalKeyMap.put('Europa - alla anv. 29 kr, 49 kr, 19 kr','551aee5a-637e-9907-beed-05b0ec37b272');
         oldValueToGlobalKeyMap.put('Europa - alla anv. 0 kr, 49 kr, 19 kr','4d405be4-e94e-b0b5-314d-d4a27ba8f3cc');
         oldValueToGlobalKeyMap.put('Grannland - alla anv. 89 kr, 29 kr, 19 kr','1ba0de8b-b225-49d5-c596-4874b84c4297');
         oldValueToGlobalKeyMap.put('Grannland - alla anv. 89 kr, 19 kr, 19 kr','789c7c6f-df0b-9c54-a865-f4d93215ca88');
         oldValueToGlobalKeyMap.put('Grannland - alla anv. 89 kr, 0 kr, 19 kr','d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8');
         oldValueToGlobalKeyMap.put('Utland - alla anv. 89 kr, 49 kr, 12 kr','f1ef630f-2a9c-9b94-f60b-c78eb4838f99');
         oldValueToGlobalKeyMap.put('Utland - alla anv. 69 kr, 39 kr, 12 kr','e29a3e9f-2db7-3ab0-277d-7f367c7ad038');
         oldValueToGlobalKeyMap.put('Utland - alla anv. 89 kr, 49 kr, 9 kr','be39cb66-6a44-6372-d7bf-438f130eebc3');
         oldValueToGlobalKeyMap.put('Utland - alla anv. 69 kr, 39 kr, 9 kr','19ea1921-cafb-b39d-ec65-ab6c2470dc11');
         oldValueToGlobalKeyMap.put('Utland - alla anv. 89 kr, 49 kr, 0 kr','454ff5e3-64bb-ca6a-6af4-b9810ae53971');
         oldValueToGlobalKeyMap.put('Utland - alla anv. 69 kr, 39 kr, 0 kr','1285c1df-a628-596a-6714-8cb8ad430326');
         oldValueToGlobalKeyMap.put('Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr','98237ae2-732d-d588-66cf-8d75177e88a9');
         oldValueToGlobalKeyMap.put('Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr','5f5bddd6-969a-2ae1-bdc6-6fb564496526');
         oldValueToGlobalKeyMap.put('Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr','296f3be9-3b0e-3155-e177-2b1f466e9b56');
         oldValueToGlobalKeyMap.put('Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr','2eea7313-03cb-9da5-3741-48a98cd2636b');
         oldValueToGlobalKeyMap.put('Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr','c355e733-ee3c-6833-5aa4-c71196e19cdb');
         oldValueToGlobalKeyMap.put('Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr','25190e10-0c3a-419f-7cd9-ed43fe36260c');
         oldValueToGlobalKeyMap.put('Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr','dd5f0a1a-922b-972e-bc15-1fbc36fbb0eb');
        
        
        oldValueToGlobalKeyMapRes.put('Standard 19 kr, 19 kr, 19 kr','143032da-37b3-c5ec-af7f-64c34ac0454a');
        oldValueToGlobalKeyMapRes.put('15 kr, 15 kr, 15 kr','48550f57-a0f1-f0e7-a95d-f5118291bcc6');
        oldValueToGlobalKeyMapRes.put('10 kr, 10 kr, 10 kr','daa79e32-0c91-b449-12f9-5b1e9462336d');
        oldValueToGlobalKeyMapRes.put('Alla användare, alla tjänster. 5 kr, 5 kr, 5 kr','ea4adb3c-8605-824a-b737-0cfea76b87f1');
        oldValueToGlobalKeyMapRes.put('Alla användare, alla tjänster. 0 kr, 0 kr, 0 kr','8cb612bc-5bb4-d606-7193-282affd20504');
        
        oldValueToNewValueMapRes.put('Standard 19 kr, 19 kr, 19 kr','AM : 19 kr, 19 kr, 19 kr');
        oldValueToNewValueMapRes.put('15 kr, 15 kr, 15 kr','SM : 15 kr, 15 kr, 15 kr');
        oldValueToNewValueMapRes.put('10 kr, 10 kr, 10 kr','SM : 10 kr, 10 kr, 10 kr');
        oldValueToNewValueMapRes.put('Alla användare, alla tjänster. 5 kr, 5 kr, 5 kr','SD : Alla användare, alla tjänster. [5 kr, 5 kr, 5 kr]');
        oldValueToNewValueMapRes.put('Alla användare, alla tjänster. 0 kr, 0 kr, 0 kr','CM : Alla användare, alla tjänster. [0 kr, 0 kr, 0 kr]');
        
        QuoteLineItem qli = [Select id, TeliaSE_Product_Code__c ,vlocity_cmt__Product2Id__c ,RoamingResAddOns__c, RoamingTillAddOns__c,vlocity_cmt__JSONAttribute__c from QuoteLineItem where id = :qliId];
        String attributeName;
        String tillValues= '{ "values": [{ "displayText": "AM : 89 kr, 49 kr, 19 kr", "id": "f713a720-7fa6-dcbf-9bba-b75645e490b4", "sequence": 1, "value": "AM : 89 kr, 49 kr, 19 kr" }, { "displayText": "SM : 69 kr, 49 kr, 19 kr", "id": "6f7f368f-45ac-42f1-96dc-fd2f2150f33a", "sequence": 2, "value": "SM : 69 kr, 49 kr, 19 kr" }, { "displayText": "SM : 59 kr, 39 kr, 19 kr", "id": "f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd", "sequence": 3, "value": "SM : 59 kr, 39 kr, 19 kr" }, { "displayText": "SM : 69 kr, 49 kr, 15 kr", "id": "a4fdeaee-1074-5189-ddfd-712b184e7c37", "sequence": 4, "value": "SM : 69 kr, 49 kr, 15 kr" }, { "displayText": "SM : 59 kr, 39 kr, 15 kr", "id": "e32ac4bd-6719-f23c-466b-738d35a2d65d", "sequence": 5, "value": "SM : 59 kr, 39 kr, 15 kr" }, { "displayText": "SD : Europa - alla anv. [49 kr, 49 kr, 19 kr]", "id": "ad9fcac8-bd33-8736-c1a2-3d18994136de", "sequence": 6, "value": "SD : Europa - alla anv. [49 kr, 49 kr, 19 kr]" }, { "displayText": "SD : Europa - alla anv. [39 kr, 49 kr, 19 kr]", "id": "183b5d9d-f0d5-f30d-d58c-7a74b0a211c3", "sequence": 7, "value": "SD : Europa - alla anv. [39 kr, 49 kr, 19 kr]" }, { "displayText": "SD : Europa - alla anv. [29 kr, 49 kr, 19 kr]", "id": "551aee5a-637e-9907-beed-05b0ec37b272", "sequence": 8, "value": "SD : Europa - alla anv. [29 kr, 49 kr, 19 kr]" }, { "displayText": "CM : Europa - alla anv. [0 kr, 49 kr, 19 kr]", "id": "4d405be4-e94e-b0b5-314d-d4a27ba8f3cc", "sequence": 9, "value": "CM : Europa - alla anv. [0 kr, 49 kr, 19 kr]" }, { "displayText": "SD : Grannland - alla anv. [89 kr, 29 kr, 19 kr]]", "id": "1ba0de8b-b225-49d5-c596-4874b84c4297", "sequence": 10, "value": "SD : Grannland - alla anv. [89 kr, 29 kr, 19 kr]" }, { "displayText": "SD : Grannland - alla anv. [89 kr, 19 kr, 19 kr]", "id": "789c7c6f-df0b-9c54-a865-f4d93215ca88", "sequence": 11, "value": "SD : Grannland - alla anv. [89 kr, 19 kr, 19 kr]" }, { "displayText": "CM : Grannland - alla anv. [89 kr, 0 kr, 19 kr]", "id": "d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8", "sequence": 12, "value": "CM : Grannland - alla anv. [89 kr, 0 kr, 19 kr]" }, { "displayText": "SD : Utland - alla anv. [89 kr, 49 kr, 12 kr]", "id": "f1ef630f-2a9c-9b94-f60b-c78eb4838f99", "sequence": 13, "value": "SD : Utland - alla anv. [89 kr, 49 kr, 12 kr]" }, { "displayText": "SD : Utland - alla anv. [69 kr, 39 kr, 12 kr]", "id": "e29a3e9f-2db7-3ab0-277d-7f367c7ad038", "sequence": 14, "value": "SD : Utland - alla anv. [69 kr, 39 kr, 12 kr]" }, { "displayText": "SD : Utland - alla anv. [89 kr, 49 kr, 9 kr]", "id": "be39cb66-6a44-6372-d7bf-438f130eebc3", "sequence": 15, "value": "SD : Utland - alla anv. [89 kr, 49 kr, 9 kr]" }, { "displayText": "SD : Utland - alla anv. [69 kr, 39 kr, 9 kr]", "id": "19ea1921-cafb-b39d-ec65-ab6c2470dc11", "sequence": 16, "value": "SD : Utland - alla anv. [69 kr, 39 kr, 9 kr]" }, { "displayText": "SD : Utland - alla anv. [89 kr, 49 kr, 0 kr]", "id": "454ff5e3-64bb-ca6a-6af4-b9810ae53971", "sequence": 17, "value": "SD : Utland - alla anv. [89 kr, 49 kr, 0 kr]" }, { "displayText": "SD : Utland - alla anv. [69 kr, 39 kr, 0 kr]", "id": "1285c1df-a628-596a-6714-8cb8ad430326", "sequence": 18, "value": "SD : Utland - alla anv. [69 kr, 39 kr, 0 kr]" }, { "displayText": "SD : Europa & Utland - alla anv.  [49 kr, 49 kr, 12 kr]", "id": "98237ae2-732d-d588-66cf-8d75177e88a9", "sequence": 19, "value": "SD : Europa & Utland - alla anv.  [49 kr, 49 kr, 12 kr]" }, { "displayText": "SD : Europa & Utland - alla anv. [39 kr, 49 kr, 12 kr]", "id": "5f5bddd6-969a-2ae1-bdc6-6fb564496526", "sequence": 20, "value": "SD : Europa & Utland - alla anv. [39 kr, 49 kr, 12 kr]" }, { "displayText": "SD : Europa & Utland - alla anv. [29 kr, 49 kr, 9 kr]", "id": "296f3be9-3b0e-3155-e177-2b1f466e9b56", "sequence": 21, "value": "SD : Europa & Utland - alla anv. [29 kr, 49 kr, 9 kr]" }, { "displayText": "CM : Europa & Utland - alla anv. [0 kr, 49 kr, 0 kr]", "id": "2eea7313-03cb-9da5-3741-48a98cd2636b", "sequence": 22, "value": "CM : Europa & Utland - alla anv. [0 kr, 49 kr, 0 kr]" }, { "displayText": "SD : Grannland & Utland - alla anv. [89 kr, 29 kr, 12 kr]", "id": "c355e733-ee3c-6833-5aa4-c71196e19cdb", "sequence": 23, "value": "SD : Grannland & Utland - alla anv. [89 kr, 29 kr, 12 kr]" }, { "displayText": "SD : Grannland & Utland - alla anv. [89 kr, 19 kr, 9 kr]", "id": "25190e10-0c3a-419f-7cd9-ed43fe36260c", "sequence": 24, "value": "SD : Grannland & Utland - alla anv. [89 kr, 19 kr, 9 kr]" }, { "displayText": "CM : Grannland & Utland - alla anv. [89 kr, 0 kr, 0 kr]", "id": "dd5f0a1a-922b-972e-bc15-1fbc36fbb0eb", "sequence": 25, "value": "CM : Grannland & Utland - alla anv. [89 kr, 0 kr, 0 kr]" } ] }';
        String resValues='{"values": [ { "displayText": "AM : 19 kr, 19 kr, 19 kr", "id": "143032da-37b3-c5ec-af7f-64c34ac0454a", "sequence": 1, "value": "AM : 19 kr, 19 kr, 19 kr" }, { "displayText": "SM : 15 kr, 15 kr, 15 kr", "id": "48550f57-a0f1-f0e7-a95d-f5118291bcc6", "sequence": 2, "value": "SM : 15 kr, 15 kr, 15 kr" }, { "displayText": "SM : 10 kr, 10 kr, 10 kr", "id": "daa79e32-0c91-b449-12f9-5b1e9462336d", "sequence": 3, "value": "SM : 10 kr, 10 kr, 10 kr" }, { "displayText": "SD : Alla användare, alla tjänster. [5 kr, 5 kr, 5 kr]", "id": "ea4adb3c-8605-824a-b737-0cfea76b87f1", "sequence": 4, "value": "SD : Alla användare, alla tjänster. [5 kr, 5 kr, 5 kr]" }, { "displayText": "CM : Alla användare, alla tjänster. [0 kr, 0 kr, 0 kr]", "id": "8cb612bc-5bb4-d606-7193-282affd20504", "sequence": 5, "value": "CM : Alla användare, alla tjänster. [0 kr, 0 kr, 0 kr]" } ]}';
        Map<String, Object> tillMap = (Map<String, Object>)JSON.deserializeUntyped(tillValues);
         Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(resValues);

        if((String)qli.TeliaSE_Product_Code__c == 'MOB_MULTI_TOTAL_V2' || (String)qli.TeliaSE_Product_Code__c == 'MOB_MULTI_ALL_IN_PLUS_V2')
            {
                Map<String, Object> rawObj1 = (Map<String, Object>)JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c);
                List<Object> o1 = (List<Object>)rawObj1.get('ATT_CODE_TELIAMOBAGGR'); 
                Map<String,Object> lsstr = new Map<String,Object>();
            For(Object o : o1)
            {
                lsstr = (Map<String,Object>)o;
                attributeName = (String) lsstr.get('attributeuniquecode__c');
                If(attributeName == 'ATT_NEG_ROAMING_TILL')
                {
                    System.debug('Ok till here');
                    String value= (String) lsstr.get('value__c');
                    Map<String,Object> lsstr1 = (Map<String,Object>)lsstr.get('attributeRunTimeInfo');
                    Map<String,Object> selectedItem= (Map<String,Object>) lsstr1.get('selectedItem');
                    List<Object> defaultItemList= (List<Object>) lsstr1.get('default');
                    Map<String,Object> defaultItem= (Map<String,Object>)defaultItemList[0];
               
               /**Updating "value__c" node********************************************/   
                    lsstr.put('value__c',oldValueToNewValueMap.get(value)); 
                    
               /**Updating "values" node********************************************/   
                    lsstr1.put('values',tillMap.get('values'));
                
                  /**Updating "selectedItem" node********************************************/     
                    String newDisplayText= oldValueToNewValueMap.get((String)selectedItem.get('displayText')) ;
                    String newGlobalKey= oldValueToGlobalKeyMap.get((String)selectedItem.get('displayText')) ;
                    selectedItem.put('displayText',newDisplayText);
                    selectedItem.put('value',newDisplayText);
                    selectedItem.put('id',newGlobalKey);
                    lsstr1.put('selectedItem',selectedItem);
                 //  System.debug('global_'+selectedItem.get('id'));
                    
                    /**Updating "defaultItem" node********************************************/ 
                    newDisplayText= oldValueToNewValueMap.get((String)defaultItem.get('displayText')) ;
                    newGlobalKey= oldValueToGlobalKeyMap.get((String)defaultItem.get('displayText')) ;
                    defaultItem.put('displayText',newDisplayText);
                    defaultItem.put('value',newDisplayText);
                    defaultItem.put('id',newGlobalKey);
                    defaultItemList[0]=defaultItem;
                    lsstr1.put('default',defaultItemList);
                   // System.debug('defaultvalue_'+defaultItem.get('displayText'));
                   
                   /**Updating "RoamingTillAddOns__c" filed********************************************/ 
                    qli.RoamingTillAddOns__c= oldValueToNewValueMap.get(qli.RoamingTillAddOns__c);
                    System.debug('qli.RoamingTillAddOns__c_'+qli.RoamingTillAddOns__c);

                  /****************************************************/  
                   lsstr.put('attributeRunTimeInfo',lsstr1);
                   o=(Object)lsstr;
                   // System.debug('Object+_'+o);
                   
                }
      /*****************************Update for Res**********************************************************************/
      If(attributeName == 'ATT_NEG_ROAMING_RES')
                {
                    System.debug('Ok till here');
                    String value= (String) lsstr.get('value__c');
                    Map<String,Object> lsstr1 = (Map<String,Object>)lsstr.get('attributeRunTimeInfo');
                    Map<String,Object> selectedItem= (Map<String,Object>) lsstr1.get('selectedItem');
                    List<Object> defaultItemList= (List<Object>) lsstr1.get('default');
                    Map<String,Object> defaultItem= (Map<String,Object>)defaultItemList[0];
               
               /**Updating "value__c" node********************************************/   
                    lsstr.put('value__c',oldValueToNewValueMapRes.get(value)); 
                    
               /**Updating "values" node********************************************/   
                    lsstr1.put('values',resMap.get('values'));
                
                  /**Updating "selectedItem" node********************************************/     
                    String newDisplayText= oldValueToNewValueMapRes.get((String)selectedItem.get('displayText')) ;
                    String newGlobalKey= oldValueToGlobalKeyMapRes.get((String)selectedItem.get('displayText')) ;
                    selectedItem.put('displayText',newDisplayText);
                    selectedItem.put('value',newDisplayText);
                    selectedItem.put('id',newGlobalKey);
                    lsstr1.put('selectedItem',selectedItem);
                 //  System.debug('global_'+selectedItem.get('id'));
                    
                    /**Updating "defaultItem" node********************************************/ 
                    newDisplayText= oldValueToNewValueMapRes.get((String)defaultItem.get('displayText')) ;
                    newGlobalKey= oldValueToGlobalKeyMapRes.get((String)defaultItem.get('displayText')) ;
                    defaultItem.put('displayText',newDisplayText);
                    defaultItem.put('value',newDisplayText);
                    defaultItem.put('id',newGlobalKey);
                    defaultItemList[0]=defaultItem;
                    lsstr1.put('default',defaultItemList);
                   // System.debug('defaultvalue_'+defaultItem.get('displayText'));
                   
                   /**Updating "RoamingTillAddOns__c" filed********************************************/ 
                    qli.RoamingResAddOns__c= oldValueToNewValueMapRes.get(qli.RoamingResAddOns__c);
                    System.debug('qli.RoamingResAddOns__c'+qli.RoamingResAddOns__c);

                  /****************************************************/  
                   lsstr.put('attributeRunTimeInfo',lsstr1);
                   o=(Object)lsstr;
                   // System.debug('Object+_'+o);
                   
                }
                
      /*****************************End of Res************************************************************************/          
            }
                    rawObj1.put('ATT_CODE_TELIAMOBAGGR',o1);
                    qli.vlocity_cmt__JSONAttribute__c= JSON.serialize(rawObj1);
                            update qli;
                
            }
    }
}