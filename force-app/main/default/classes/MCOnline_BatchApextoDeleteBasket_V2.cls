Global class MCOnline_BatchApextoDeleteBasket_V2 Implements Database.batchable<sobject>,Schedulable, Database.Stateful, Database.AllowsCallouts{
    
    List<String> errorList = new List<String>();
    Integer numberOfRecordAvailable;
    DateTime lastNthDays;
    List<String> successList = new List<String>();
    
    global List<MCOnline_Basket__c> start(Database.BatchableContext BC){
        Integer numberOfDays;
        if(Label.BasketDeletion_NumberOfDays != null){
            numberOfDays = Integer.valueOf(Label.BasketDeletion_NumberOfDays);           
            lastNthDays = DateTime.Now().addDays(numberOfDays);            
            List<MCOnline_Basket__c> basketList = [SELECT id, Name from MCOnline_Basket__c WHERE (MCOnline_ParentBasket__r.Is_Processed__c = false AND MCOnline_ParentBasket__r.CreatedDate <= :lastNthDays) OR (MCOnline_Is_Processed__c = false AND MCOnline_Message__c != null AND MCOnline_ParentBasket__r.CreatedDate <= :lastNthDays) ];
            system.debug('basketList'+basketList.size());
            if(basketList != null && basketList.size() > 0){
                numberOfRecordAvailable = basketList.size();
            }
            return basketList;
        }else{
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC,List<MCOnline_Basket__c> basketList){
        try{
            
            if(basketList != null && basketList.size() > 0){                
                    if(basketList[0] != null && basketList[0].Name != null){
                        system.debug('basketList[0].Name'+basketList[0].Name);
                        MCOnline_NumberUnReservationFromBatch_V2.unreserveMSISDN(basketList[0].Name);                       
                        //MCONL_NumberUnReservationFromBatch.deleteBasket(basketList[0].Name);
                    }                
            }
            successList.add(String.valueOf(basketList[0].Name));
            
            system.debug('successList'+successList);
        }catch(Exception e){
            system.debug('Exception : '+e.getStackTraceString());
            errorList.add(e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        String message = '';
        String details = '';
        if(successList != null && errorList != null){
            message = 'Records succussfully processed = '+successList.size()+', records processed with error = '+errorList.size();
            details = 'Records succussfully processed = '+JSON.serialize(successList)+', records processed with error = '+JSON.serialize(errorList);
        }else if(successList != null && errorList == null){
            message = 'Records succussfully processed - '+successList.size();
            details = 'Records succussfully processed = '+JSON.serialize(successList);
        }else if(successList == null && errorList != null){
            message = 'Number of record not succussfully processed - '+errorList.size();
            details = 'Records processed with error = '+JSON.serialize(errorList);
        }
        string inputData = '{"NumberOfReords":"'+numberOfRecordAvailable+'", "SourceObject":"MCOnline_Basket__c", "LastNthDay":"'+lastNthDays+'"}';
        MCOnline_Utility.logErrorWithoutFuture('Error summary = '+message+', In Details = '+details,'500','MCOnline_BatchApextoDeleteBasket_V1','Apex Batch Class', 'Log',inputData,'','');
    }
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new MCOnline_BatchApextoDeleteBasket_V2(), 1);
        //Database.executeBatch(new MCOnline_BatchApexDelParentBskt_V1(), 200);
    }
}