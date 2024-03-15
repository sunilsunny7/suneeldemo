Global class MCOnline_BatchApexDelParentBskt_V1 Implements Database.batchable<sobject>, Database.Stateful{
    
    List<String> errorList = new List<String>();
    Integer numberOfRecordAvailable;
    DateTime lastNthDays;
    List<String> successList = new List<String>();
    
    global List<MCOnline_ParentBasket__c> start(Database.BatchableContext BC){
        Integer numberOfDays;
        if(Label.ProcessedBasketDeletion_NumberOfDays != null){
            numberOfDays = Integer.valueOf(Label.ProcessedBasketDeletion_NumberOfDays);
            lastNthDays = DateTime.Now().addDays(numberOfDays);
            List<MCOnline_ParentBasket__c> basketList = [SELECT id, Name from MCOnline_ParentBasket__c WHERE Is_Processed__c = true AND CreatedDate <= :lastNthDays ];
            if(basketList != null && basketList.size() > 0){
                numberOfRecordAvailable = basketList.size();
            }
            return basketList;
        }else{
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC,List<MCOnline_ParentBasket__c> basketList){
        try{
            Set<Id> parentIdSet = new Set<Id>();
            system.debug('basketList==>'+basketList);
            for(MCOnline_ParentBasket__c basketObj : basketList){
                
                if(basketObj != null && basketObj.Id != null){
                    parentIdSet.add(basketObj.Id);
                    successList.add(String.valueOf(basketObj.Id));
                }
            }
            if(basketList != null && basketList.size() > 0){
                List<MCOnline_Basket__c> basketLineList = [SELECT id, Name from MCOnline_Basket__c WHERE MCOnline_ParentBasket__r.id in :parentIdSet ];
                delete basketLineList;
                delete basketList;
            }
        }catch(Exception e){
            system.debug('Exception : '+e.getStackTraceString());
            errorList.add(e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        String message = '';
        String details = '';
        System.debug('errorList'+errorList);
        System.debug('successList'+successList);
        if(successList != null && errorList != null){
            message = 'ParentBasket Records succussfully processed = '+successList.size()+', records processed with error = '+errorList.size();
            details = 'ParentBasket Records succussfully processed = '+JSON.serialize(successList)+', records processed with error = '+JSON.serialize(errorList);
        }else if(successList != null && errorList == null){
            message = 'ParentBasket Records succussfully processed - '+successList.size();
            details = 'ParentBasket Records succussfully processed = '+JSON.serialize(successList);
        }else if(successList == null && errorList != null){
            message = 'ParentBasket Number of record not succussfully processed - '+errorList.size();
            details = 'ParentBasket Records processed with error = '+JSON.serialize(errorList);
        }
        string inputData = '{"NumberOfReords":"'+numberOfRecordAvailable+'", "SourceObject":"MCOnline_ParentBasket__c", "LastNthDay":"'+lastNthDays+'"}';
        MCOnline_Utility.logErrorWithoutFuture('Error summary = '+message+', In Details = '+details,'500','MCOnline_BatchApexDelParentBskt_V1','Apex Batch Class', 'Log',inputData,'','');
    }
}