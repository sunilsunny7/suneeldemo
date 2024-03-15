global class Fiber_ProductMigration implements Database.Batchable<SObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
    global string fiberRecordtype = 'Real Estate Fiber';
   global Database.QueryLocator start(Database.BatchableContext context) 
    {
        String query = 'SELECT Id,TeliaSE_Product_Code__c, vlocity_cmt__Product2Id__c,vlocity_cmt__ParentItemId__c, TeliaSE_Root_Product__c, vlocity_cmt__RootItemId__c,Product2.vlocity_cmt__SpecificationType__c,Product2.TeliaSE_Offer_Type__c,Product2.ProductCode,vlocity_cmt__Filter__c FROM QuoteLineItem where (Quote.Opportunity.RecordType.Name =:fiberRecordtype) and (vlocity_cmt__Filter__c = null)';
        System.debug('ABC'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);        
    }
     global void execute(Database.BatchableContext context, List<QuoteLineItem> Qlilist) 
    {  
         List<QuoteLineItem> quoteLine = new List<QuoteLineItem>();
        If(Qlilist.size()>0){
              for(QuoteLineItem qli : Qlilist)
            {
                if((qli.Product2.vlocity_cmt__SpecificationType__c) == 'Product' && (qli.vlocity_cmt__Filter__c == null) && (qli.Product2.ProductCode != 'MDU_HW_MC_1729' || qli.Product2.ProductCode != 'MDU_CollHW_Fibertray_1738' || qli.Product2.ProductCode != 'MDU_CollHW_SFP20km_1738' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_Coax_1613' || qli.Product2.ProductCode != 'MDU_Service_Invoice_1613' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_1_Fiber_1613' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_NotInstalled_1849' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_2_Fiber_1613' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_3_Fiber_1613' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_3SEK_1617' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_1_Cu_1613' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_2_Cu_1613' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_3_Cu_1613' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_HWIndInst_1750' || qli.Product2.ProductCode != 'MDU_ServiceAgreement_HWKollInst_1750')){
                    qli.vlocity_cmt__ParentItemId__c = qli.vlocity_cmt__RootItemId__c;
                    qli.vlocity_cmt__ProductHierarchyPath__c = qli.TeliaSE_Root_Product__c+'<'+qli.vlocity_cmt__Product2Id__c;
                    qli.vlocity_cmt__Filter__c = 'Updated';
                    quoteLine.add(qli);
                    recordsProcessed = recordsProcessed + 1;
                }
                else if((qli.vlocity_cmt__Filter__c == null)&&(qli.Product2.ProductCode == 'MDU_HW_MC_1729' || qli.Product2.ProductCode == 'MDU_CollHW_Fibertray_1738' || qli.Product2.ProductCode == 'MDU_CollHW_SFP20km_1738' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_Coax_1613' || qli.Product2.ProductCode == 'MDU_Service_Invoice_1613' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_1_Fiber_1613' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_NotInstalled_1849' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_2_Fiber_1613' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_3_Fiber_1613' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_3SEK_1617' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_1_Cu_1613' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_2_Cu_1613' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_3_Cu_1613' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_HWIndInst_1750' || qli.Product2.ProductCode == 'MDU_ServiceAgreement_HWKollInst_1750'))
                {
                    QuoteLineItem qline = [select id,vlocity_cmt__Product2Id__c from QuoteLineItem where id =: qli.vlocity_cmt__ParentItemId__c];
                    qli.vlocity_cmt__RootItemId__c = qli.vlocity_cmt__ParentItemId__c;
                    qli.TeliaSE_Root_Product__c = qline.vlocity_cmt__Product2Id__c;
                    qli.vlocity_cmt__ProductHierarchyPath__c = qline.vlocity_cmt__Product2Id__c+'<'+qli.vlocity_cmt__Product2Id__c;
                    qli.vlocity_cmt__Filter__c = 'Updated';
                     quoteLine.add(qli);
                    recordsProcessed = recordsProcessed + 1;
                }
                else if(((qli.Product2.ProductCode == 'Property Network Hardware Service Bundle') || (qli.Product2.ProductCode == 'Landlord_Service_Agreement_Bundle')) && (qli.vlocity_cmt__Filter__c == null)){
                    qli.TeliaSE_Root_Product__c = qli.vlocity_cmt__Product2Id__c;
                    qli.vlocity_cmt__RootItemId__c = qli.Id;
                    qli.vlocity_cmt__ParentItemId__c = null;
                    qli.vlocity_cmt__ProductHierarchyPath__c = qli.vlocity_cmt__Product2Id__c;
                    qli.vlocity_cmt__Filter__c = 'Updated';
                   quoteLine.add(qli);
                    recordsProcessed = recordsProcessed + 1;
                }
                else if((qli.Product2.vlocity_cmt__SpecificationType__c == 'Offer') && (qli.Product2.TeliaSE_Offer_Type__c != 'AgreementOffering') && ((qli.Product2.ProductCode != 'Property Network Hardware Service Bundle') || (qli.Product2.ProductCode != 'Landlord_Service_Agreement_Bundle')) && (qli.vlocity_cmt__Filter__c == null)){
                 delete qli;
                 recordsProcessed = recordsProcessed + 1;
                }
        }
         update quoteLine;   
    }
        
}
    global void finish(Database.BatchableContext context){
    }  
    
}