/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_CLIAgreementControlMigrateBatch 
**Created By  :        Abhishek Agrawal
**Date      :          27 Oct 2022
**Description :        Contains Apex Migration Agreement Control Service on CLIs

-----------------------------------------------------------------------------------------------------------*/
global class MC_CLIAgreementControlMigrateBatch implements Database.Batchable<sObject>{
      global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select id,name,vlocity_cmt__ProductCode__c,vlocity_cmt__QuoteLineItem__r.MC_Sales_FrameworkPricingMaster__c,vlocity_cmt__ContractId__r.RecordType.name,vlocity_cmt__ContractId__c,MC_Agreement_Control_Service__c, TeliaSE_QuoteItemId__c,vlocity_cmt__QuoteLineItem__c,vlocity_cmt__QuoteLineItem__r.MC_Sales_FrameworkPricingMaster__r.MC_Sales_FrameworkPricePlanMaster__r.MC_Agreement_Control_Service__c
                                         from vlocity_cmt__ContractLineItem__c where  vlocity_cmt__ProductCode__c like 'MOB_CALL_TRAVEL%' and vlocity_cmt__Product2Id__r.Family <> 'Online Order' 
                                         and vlocity_cmt__ContractId__r.Status <>'Cancelled' and vlocity_cmt__ContractId__r.Status <>'Rejected' and vlocity_cmt__QuoteLineItem__c<>'' and vlocity_cmt__QuoteLineItem__r.Quote_Status__c <>'Cancelled' 
                                         and vlocity_cmt__QuoteLineItem__r.TeliaSE_Quote_RecordType__c ='Contract' and vlocity_cmt__ContractId__r.RecordType.Name='Ramavtal' and (vlocity_cmt__QuoteLineItem__r.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c='Framework' or vlocity_cmt__QuoteLineItem__r.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c='Hybrid')and vlocity_cmt__QuoteLineItem__r.MC_Sales_FrameworkPricingMaster__c <>'' and MC_Agreement_Control_Service__c='']);
    }//Rejected status
    global void execute(Database.BatchableContext bc,List<vlocity_cmt__ContractLineItem__c> agreementClis){
        try{ 
            if(agreementClis.size()>0){
                List<vlocity_cmt__ContractLineItem__c> clisToUpdate=new  List<vlocity_cmt__ContractLineItem__c>();
            for(vlocity_cmt__ContractLineItem__c cl:agreementClis){
                if(cl.vlocity_cmt__QuoteLineItem__r.MC_Sales_FrameworkPricingMaster__r.MC_Sales_FrameworkPricePlanMaster__r.MC_Agreement_Control_Service__c!=''){
                    System.debug(cl.name);
                    System.debug(cl.vlocity_cmt__ProductCode__c);
                    String a=cl.vlocity_cmt__QuoteLineItem__r.MC_Sales_FrameworkPricingMaster__r.MC_Sales_FrameworkPricePlanMaster__r.MC_Agreement_Control_Service__c;
                        List<String> agreementcontrol=a.split(';');
                        if (agreementcontrol.size()>0){
                            if(cl.vlocity_cmt__ProductCode__c == 'MOB_CALL_TRAVEL_EUROPE'){
                                cl.MC_Agreement_Control_Service__c = agreementcontrol[0];
                            }
                            if(cl.vlocity_cmt__ProductCode__c == 'MOB_CALL_TRAVEL_OTHER'){
                                cl.MC_Agreement_Control_Service__c = agreementcontrol[1];
                            }
                            if(cl.vlocity_cmt__ProductCode__c == 'MOB_CALL_TRAVEL_OVERSEAS'){
                                cl.MC_Agreement_Control_Service__c = agreementcontrol[2];
                            }
                            if(cl.vlocity_cmt__ProductCode__c == 'MOB_CALL_TRAVEL_SOUTH'){
                                cl.MC_Agreement_Control_Service__c = agreementcontrol[0];
                            }
                            if(cl.vlocity_cmt__ProductCode__c == 'MOB_CALL_TRAVEL_EAST'){
                                cl.MC_Agreement_Control_Service__c = agreementcontrol[1];
                            }
                            if(cl.vlocity_cmt__ProductCode__c == 'MOB_CALL_TRAVEL_WEST'){
                                cl.MC_Agreement_Control_Service__c = agreementcontrol[2];
                            }
                            clisToUpdate.add(cl);
                        }    
                    
                }
            }
                 update clisToUpdate;
           }
           
        }catch(Exception e){
            system.debug('Exception -- >'+ e);
        }
      
    }
    global void finish(Database.BatchableContext bc){
        
         System.debug('Excecuted-');
    }

}