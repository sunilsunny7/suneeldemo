global class MC_BatchUpdateQLISequence implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = System.Label.UpdateSequenceSOQL;
        if(test.isRunningTest()){
            query = 'select id,product2.name,vlocity_cmt__ProductHierarchyPath__c,product2id,vlocity_cmt__ParentItemId__c, vlocity_cmt__SequenceNumber__c from quotelineitem where TeliaSE_Product_Code__c like \'MOB_%\' and quote.TeliaSE_Record_Type_Name__c = \'Contract\' and quote.status !=\'Cancelled\'';
        } 
        //String query = 'select id,product2.name,product2id,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__ParentItemId__c, vlocity_cmt__SequenceNumber__c from quotelineitem where TeliaSE_Product_Code__c like \'MOB_%\' and quote.TeliaSE_Record_Type_Name__c = \'Contract\' and quote.status !=\'Cancelled\' and (vlocity_cmt__ProductHierarchyPath__c like \'01t3O000005Xy4h%\' OR vlocity_cmt__ProductHierarchyPath__c like \'01t3O000005Xy4S%\')';
        return Database.getQueryLocator(query);
    }
    
        global void execute(Database.BatchableContext BC,List<QuotelineItem> qliList){
        try{
            Map<Id,Id> qliProdMap = new Map<Id,Id>();
            Map<String,Integer> prodChildSeqMap = new Map<String,Integer>();
            Set<Id> prodIdSet = new Set<Id>();
            for(QuoteLineItem qli : qliList){
                qliProdMap.put(qli.Id,qli.product2id);
                prodIdSet.add(qli.Product2Id);
            }
            
            List<vlocity_cmt__ProductChildItem__c> prodChildItemList = [select id,vlocity_cmt__ParentProductId__c,vlocity_cmt__ChildProductId__c,vlocity_cmt__ParentProductId__r.name,vlocity_cmt__SeqNumber__c from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__c IN:prodIdSet and vlocity_cmt__IsOverride__c=false];
            for(vlocity_cmt__ProductChildItem__c prodChildItem :prodChildItemList){
                String key = (String)prodChildItem.vlocity_cmt__ChildProductId__c+(String)prodChildItem.vlocity_cmt__ParentProductId__c;
                // System.debug('key_'+key);
                prodChildSeqMap.put(key,Integer.valueOf(prodChildItem.vlocity_cmt__SeqNumber__c));
            }
            for(QuoteLineItem qli : qliList){
                if(qli.vlocity_cmt__ParentItemId__c != null){
                    List<String> hierarchyList=new List<String>();
                    if(qli.vlocity_cmt__ProductHierarchyPath__c!=null){
                        hierarchyList=qli.vlocity_cmt__ProductHierarchyPath__c.split('<');
                    }
                    Integer hierarchySize= hierarchyList.size();
                    String immediateParent;
                    if(hierarchySize==3){
                        immediateParent=hierarchyList[1];
                    }
                    else if(hierarchySize==2){
                        immediateParent=hierarchyList[0];
                    }
                    else if(hierarchySize==1){
                        immediateParent=hierarchyList[0];
                    }
                    String prodkey = (String)qli.Product2Id+immediateParent;
                    // String prodkey = (String)qli.Product2Id+(String)qliProdMap.get(qli.vlocity_cmt__ParentItemId__c);
                    if(prodChildSeqMap.get(prodkey) != null){
                        qli.vlocity_cmt__SequenceNumber__c = Integer.valueOf(prodChildSeqMap.get(prodkey));
                        System.debug('seq__'+qli.product2.name+'_ '+Integer.valueOf(qli.vlocity_cmt__SequenceNumber__c));
                    }
                }
            }
            update qliList;
        }
        catch(Exception e){
            System.debug('Exception -- >'+ e.getStackTraceString());
            System.debug('Exception Msg -- >'+ e.getMessage());
        }
    }
 	global void finish(Database.BatchableContext BC){}   
}