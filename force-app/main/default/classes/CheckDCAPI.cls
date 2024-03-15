global class CheckDCAPI implements Database.Batchable<sObject>,Database.Stateful,Database.allowscallouts{
    List<String> failedGetOfferDetails=new List<String>();
    List<String> failedAddtoBasket=new List<String>();
    Set<String> codes;
    global CheckDCAPI(Set<String> codes)
    {
        this.codes=codes;
    }
    String query='select id,vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c,vlocity_cmt__Product2Id__r.productcode from vlocity_cmt__CatalogProductRelationship__c where vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c =:codes';
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator(query);            
    }

    global void execute(Database.BatchableContext context,List<vlocity_cmt__CatalogProductRelationship__c> items)
    {
        try
        {
            Map<String,Object> data;
            List<Object> prodConfigs=new List<Object>();
            String code=items[0].vlocity_cmt__Product2Id__r.productcode;
            Map<String, Object> output=getOfferDetails(items[0].vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c,items[0].vlocity_cmt__Product2Id__r.productcode);
            if(!output.containsKey('result'))
            {
                failedGetOfferDetails.add(items[0].vlocity_cmt__Product2Id__r.productcode);
                return;
            }
            prodConfigs.add(output.get('result'));
            
            Map<String, Object> output1 = new Map<String, Object>();
            Map<String, Object> input1 = new Map<String, Object>();
            Map<String, Object> options1 = new Map<String, Object>();
            input1.put('apiName','basketOperations');
            input1.put('catalogCode', items[0].vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c);
            input1.put('responseFormat', 'trimResponse');
            input1.put('productConfig', prodConfigs);
            input1.put('methodName', 'addAfterConfig');
            
                input1.put('requestURL', '/v3/catalogs/'+items[0].vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c+'/basket');
            
            input1.put('contextKey', '99914b932bd37a50b983c5e7c90ae93b');
            input1.put('validate','false');
            input1.put('price', false);
            
            if(!Test.isRunningTest())
            {
                new vlocity_cmt.CpqAppHandler().invokeMethod('addAfterConfig', input1, output1, options1);
                data=(Map<String,Object>)JSON.deserializeUntyped(output1.get('result')+'');
            }else {
                data=new Map<String,Object>();
            }          
            if(data==null || !data.containsKey('cartContextKey'))
            {
                failedAddtoBasket.add(items[0].vlocity_cmt__Product2Id__r.productcode);
            }
        }catch(Exception e)
        {
            failedAddtoBasket.add(items[0].vlocity_cmt__Product2Id__r.productcode);
        }
        
    }

    
    global void finish(Database.BatchableContext context)
    {
        if(failedAddtoBasket.size()>0 || failedGetOfferDetails.size()>0)
        {
            String body='GetOfferDetails = '+JSON.serialize(failedGetOfferDetails)+' \n'+'AddToBasket = '+JSON.serialize(failedAddtoBasket);
            List<String> emailIds=new List<String>{'suneel.g-shivanna@capgemini.com'};	
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = emailIds;
            message.optOutPolicy = 'FILTER';
            message.subject = 'Exception in product import';
            message.plainTextBody = body;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    } 


    private static Map<String,Object> getOfferDetails(String catalog,String offerCode)
    {
        HttpRequest req=new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(URL.getOrgDomainURL().toExternalForm()+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalog+'/offers/'+offerCode);
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());  
        if(!Test.isRunningTest())
        {
            HttpResponse res=new Http().send(req);
            return (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        }
        else{
            return new Map<String,Object>{'result'=>'test'};
        }
    }


}