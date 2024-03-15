global class TeliaSE_BatchHWProdUpdate implements Database.Batchable<sObject>,Schedulable{
  String query;
    String matrixName = 'PriceMatrix_24M_Hardware';
    List<String> bundleCode = new list<String>();
    List<String> productCodes = new list<String>();
    global TeliaSE_BatchHWProdUpdate(){
        query = 'Select Id,Name,ProductCode from Product2 where ProductCode = \'MOB_HARDWARE_OFFER\' limit 1';
    }    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Product2> Product2List){
        Set<String> sapidSet = new Set<String>();
        Set<String> allSapidSet = new Set<String>();
        vlocity_cmt__CalculationMatrixVersion__c cmv = [select Id from vlocity_cmt__CalculationMatrixVersion__c where vlocity_cmt__CalculationMatrixId__r.Name =: matrixName  and (vlocity_cmt__EndDateTime__c > TODAY or vlocity_cmt__EndDateTime__c = null) order by vlocity_cmt__Priority__c  desc limit 1];
        for (vlocity_cmt__CalculationMatrixRow__c cmr : [Select Id,vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c from vlocity_cmt__CalculationMatrixRow__c where vlocity_cmt__CalculationMatrixVersionId__c =: cmv.Id and vlocity_cmt__OutputData__c != null ]){
            Map<String,object> inputData = (Map<String,object>)Json.deserializeUntyped(cmr.vlocity_cmt__InputData__c);
            sapidSet.add((string)inputData.get('Source Product Code'));
        } 
        List<Product2> prodList = new List<Product2>();
        for(Product2 prod : [Select Id,ProductCode,TeliaSE_MatrixPriceFlag__c from Product2 where TeliaSE_Object_Type_Name__c = 'Mobile Handset Product Specification']){
            prod.TeliaSE_MatrixPriceFlag__c = false;
            for(String s : sapidSet){
                if(prod.ProductCode == s){
                    prod.TeliaSE_MatrixPriceFlag__c = true;
                }
            }
            prodList.add(prod);
        }       
        update prodList;
    }
    global void finish(Database.BatchableContext bc){
        
        for(vlocity_cmt__ProductChildItem__c pr: [select vlocity_cmt__ChildProductId__r.ProductCode from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode like 'HW_MOB%' and Name != 'ROOT PCI']){         
                bundleCode.add(pr.vlocity_cmt__ChildProductId__r.ProductCode);          
        }        
        for(vlocity_cmt__ProductChildItem__c s: [select id,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.TeliaSE_MatrixPriceFlag__c from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode in: bundleCode and Name != 'ROOT PCI' and vlocity_cmt__ChildProductId__r.IsActive = true and vlocity_cmt__ChildProductId__r.TeliaSE_MatrixPriceFlag__c = false]){
                       
            productCodes.add(s.vlocity_cmt__ChildProductId__r.ProductCode);
        }
        system.debug('productCodes ->'+productCodes);
        if(!productCodes.isEmpty()){
            sendEmail(productCodes);
        }
    }
     public static void sendEmail(List<String> productCodes){
         system.debug('productCodes ->'+productCodes);
     
         String messagebody = 'Active products with matrix flag as false : ';
         
         for(String s: productCodes){
            messagebody += s+', ';
         }
         
         messagebody = messagebody.substring(0,messagebody.length()-2);        
         String emailId=System.Label.TeliaSE_AMEmailId;
        String[] emailIds=emailId.Split(';');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailIds;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Exception in price matrix entry';
        message.plainTextBody = messagebody;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
     }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new TeliaSE_BatchHWProdUpdate(), 500);
    }
}