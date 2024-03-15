global class UpdateCLIBatchJob implements Database.Batchable<sObject> {
    Map<String,Boolean> isValidRecord(List<String> queryList, List<QuoteLineItem> QliList){
        Map<String,Boolean> validityMap = new Map<String,Boolean>();
        for(String str:queryList){
            Boolean Flag= false;
            for(QuoteLineItem qli:QliList){
                if((String)qli.Id == str){
                    Flag = true;
                }
            }
            validityMap.put(str,Flag);
        }
        return validityMap;
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select Id, vlocity_cmt__QuoteLineItem__c,TeliaSE_RootItemId__c, TeliaSE_QuoteItemId__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__r.Status !='Cancelled' and vlocity_cmt__ContractId__r.RecordType.Name ='Ramavtal']);
    }
    global void execute(Database.BatchableContext bc,List<vlocity_cmt__ContractLineItem__c> cliList){
        List<String> QLIlist = new List<String>();
        for(vlocity_cmt__ContractLineItem__c cli: cliList){
            QLIlist.add(cli.TeliaSE_QuoteItemId__c);
        }
        List<QuoteLineItem> extractedQli = [Select Id,Product2.Name from QuoteLineItem where Id in :QLIlist];
        Map<String,Boolean> validityMap =isValidRecord(QLIlist,extractedQli);
        List<vlocity_cmt__ContractLineItem__c> CliToUpdate= new List<vlocity_cmt__ContractLineItem__c>();
        for(vlocity_cmt__ContractLineItem__c cli: cliList){
            if(validityMap.get(cli.TeliaSE_QuoteItemId__c)){
                cli.vlocity_cmt__QuoteLineItem__c = cli.TeliaSE_QuoteItemId__c;
                CliToUpdate.add(cli);
            }
        }
        
        try{
            update CliToUpdate;
        }catch(Exception e){
            system.debug('Exception -- >'+ e);
        }
        
    }
    global void finish(Database.BatchableContext bc){
        
        system.debug('EXECUTED SUCCESSFULLY');
    }
}