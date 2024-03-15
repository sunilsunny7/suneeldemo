Global class MC_UpdateMobileClusterCode Implements Database.batchable<sobject>{
    String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        //set<String> interfaces = new set<String>{'AgreementCreateEvent','AgreementAttributeValueChangeEvent','AgreementStateChangeEvent'};
        query = 'select id, QuoteId , Product2.name,Product2.ProductCode, TeliaSE_Product_Object_Type__c, TeliaSE_ParentClusterCode__c , vlocity_cmt__AttributeSelectedValues__c from QuoteLineItem where TeliaSE_ParentClusterCode__c = null and (product2.productcode =\'MOB_MULTI_BAS_V3\' or product2.productcode =\'MOB_MULTI_LARGE_V3\' or product2.productcode =\'MOB_MULTI_MEDIUM_V3\' or product2.productcode =\'MOB_MULTI_PLUS_V3\' or product2.productcode =\'MOB_MULTI_SMLL_V3\' or product2.productcode =\'MOB_MULTI_XLARGE_V3\' ) and TeliaSE_Product_Code__c  like \'MOB%\'';
        //query = 'select id, QuoteId , Product2.name,Product2.ProductCode, TeliaSE_Product_Object_Type__c, TeliaSE_ParentClusterCode__c , vlocity_cmt__AttributeSelectedValues__c from QuoteLineItem where quoteid=\'0Q00Q000000xRF0SAM\'';

        return Database.getQueryLocator(query);
    }
    global  void execute(Database.BatchableContext BC,List<QuotelineItem> scope){
        try{
        List<QuotelineItem> updatedFAQliList = new List<QuotelineItem>();
        if(scope.size() >0){
            
            for(QuotelineItem ql: scope){
                if(ql.product2.productcode =='MOB_MULTI_BAS_V3'){
                    ql.TeliaSE_ParentClusterCode__c ='bas';
                    ql.vlocity_cmt__AttributeSelectedValues__c='{"ATT_CPC":"bas"}';
                }
                else if(ql.product2.productcode =='MOB_MULTI_LARGE_V3'){
                    ql.TeliaSE_ParentClusterCode__c ='large';
                    ql.vlocity_cmt__AttributeSelectedValues__c='{"ATT_CPC":"large"}';
                }
                else if(ql.product2.productcode =='MOB_MULTI_MEDIUM_V3'){
                    ql.TeliaSE_ParentClusterCode__c ='medium';
                    ql.vlocity_cmt__AttributeSelectedValues__c='{"ATT_CPC":"medium"}';
                }
                else if(ql.product2.productcode =='MOB_MULTI_XLARGE_V3'){
                    ql.TeliaSE_ParentClusterCode__c ='xlarge';
                    ql.vlocity_cmt__AttributeSelectedValues__c='{"ATT_CPC":"xlarge"}';
                }
                else if(ql.product2.productcode =='MOB_MULTI_PLUS_V3'){
                    ql.TeliaSE_ParentClusterCode__c ='plus';
                    ql.vlocity_cmt__AttributeSelectedValues__c='{"ATT_CPC":"plus"}';
                }
                else if(ql.product2.productcode =='MOB_MULTI_SMLL_V3'){
                    ql.TeliaSE_ParentClusterCode__c ='small';
                    ql.vlocity_cmt__AttributeSelectedValues__c='{"ATT_CPC":"small"}';
                }
             
                	updatedFAQliList.add(ql);
                    }
                }
            System.debug('Updated qli size-'+updatedFAQliList.size());
        if(updatedFAQliList.size()>0){
            update updatedFAQliList;
        }
            
        }
        catch(Exception e){
            system.debug('Exception -- >'+ e);
        }
    }
        
    
    global void finish(Database.BatchableContext BC){}
   
}