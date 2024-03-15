global class Fiber_ContractProductMigration implements Database.Batchable<SObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
    global String fiberRecordtype = 'Real Estate Fiber';
   global Database.QueryLocator start(Database.BatchableContext context) 
    {
        String query = 'select Id,vlocity_cmt__ProductCode__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c,vlocity_cmt__Product2Id__c, TeliaSE_Root_Product__c, TeliaSE_RootItemId__c, TeliaSE_ParentItemId__c,vlocity_cmt__Product2Id__r.vlocity_cmt__SpecificationType__c, vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c, vlocity_cmt__Product2Id__r.ProductCode,TeliaSE_Contract_Line_Notes__c from vlocity_cmt__ContractLineItem__c where (vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.RecordType.Name =:fiberRecordtype and TeliaSE_Contract_Line_Notes__c = null) ';
        System.debug('ABC'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);        
    }
     global void execute(Database.BatchableContext context, List<vlocity_cmt__ContractLineItem__c> Clilist) 
    {    
        List<vlocity_cmt__ContractLineItem__c> contractLine = new List<vlocity_cmt__ContractLineItem__c>();
        If(Clilist.size()>0){
              for(vlocity_cmt__ContractLineItem__c cli : Clilist)
            {
                if((cli.vlocity_cmt__Product2Id__r.vlocity_cmt__SpecificationType__c) == 'Product' && (cli.TeliaSE_Contract_Line_Notes__c == null) && (cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_HW_MC_1729' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_CollHW_Fibertray_1738' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_CollHW_SFP20km_1738' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_Coax_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_Service_Invoice_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_1_Fiber_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_NotInstalled_1849' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_2_Fiber_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_3_Fiber_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_3SEK_1617' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_1_Cu_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_2_Cu_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_3_Cu_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_HWIndInst_1750' || cli.vlocity_cmt__Product2Id__r.ProductCode != 'MDU_ServiceAgreement_HWKollInst_1750')){
                    cli.TeliaSE_ParentItemId__c = cli.TeliaSE_RootItemId__c;
                    cli.TeliaSE_Contract_Line_Notes__c = 'Updated';
                    contractLine.add(cli);
                    recordsProcessed = recordsProcessed + 1;
                }
                else if((cli.TeliaSE_Contract_Line_Notes__c == null)&&(cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_HW_MC_1729' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_CollHW_Fibertray_1738' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_CollHW_SFP20km_1738' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_Coax_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_Service_Invoice_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_1_Fiber_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_NotInstalled_1849' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_2_Fiber_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_3_Fiber_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_3SEK_1617' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_1_Cu_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_2_Cu_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_3_Cu_1613' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_HWIndInst_1750' || cli.vlocity_cmt__Product2Id__r.ProductCode == 'MDU_ServiceAgreement_HWKollInst_1750'))
                {
                    QuoteLineItem qline = [select id,vlocity_cmt__Product2Id__c from QuoteLineItem where id =: cli.TeliaSE_ParentItemId__c];
                    cli.TeliaSE_RootItemId__c = cli.TeliaSE_ParentItemId__c;
                    cli.TeliaSE_Root_Product__c = qline.vlocity_cmt__Product2Id__c;
                    cli.TeliaSE_Contract_Line_Notes__c = 'Updated';
                    contractLine.add(cli);
                    recordsProcessed = recordsProcessed + 1;
                }
                else if(((cli.vlocity_cmt__Product2Id__r.ProductCode == 'Property Network Hardware Service Bundle') || (cli.vlocity_cmt__Product2Id__r.ProductCode == 'Landlord_Service_Agreement_Bundle')) && (cli.TeliaSE_Contract_Line_Notes__c == null)){
                    QuoteLineItem qline1 = [select id,vlocity_cmt__Product2Id__c from QuoteLineItem where QuoteId =: cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c and vlocity_cmt__Product2Id__c =: cli.vlocity_cmt__Product2Id__c];
                    cli.TeliaSE_Root_Product__c = cli.vlocity_cmt__Product2Id__c;
                    cli.TeliaSE_ParentItemId__c = null;
                    cli.TeliaSE_RootItemId__c = qline1.Id;
                    cli.TeliaSE_Contract_Line_Notes__c = 'Updated';
                    contractLine.add(cli);
                    recordsProcessed = recordsProcessed + 1;
                }
                else if((cli.vlocity_cmt__Product2Id__r.vlocity_cmt__SpecificationType__c == 'Offer') && (cli.vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c != 'AgreementOffering') && ((cli.vlocity_cmt__Product2Id__r.ProductCode != 'Property Network Hardware Service Bundle') || (cli.vlocity_cmt__Product2Id__r.ProductCode != 'Landlord_Service_Agreement_Bundle')) && (cli.TeliaSE_Contract_Line_Notes__c == null)){
                 delete cli;
                 recordsProcessed = recordsProcessed + 1;
                }
        }
            update contractLine;
    }
        
}
    global void finish(Database.BatchableContext context){
    }  
}