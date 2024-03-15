public class TeliaSE_QuoteRetentionHandler {
        public static void checkServiceUpgrade(List<Quote> quotes){
        Quote QtList= quotes.get(0);
            if(QtList.Status == 'Price Approved' && QtList.TeliaSE_Previous_Contract_Number__c != null){
         List<QuoteLineItem> qLines=[select QuoteId,TeliaSE_Product_Code__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__OneTimeCharge__c,Fiber_Customer_Requested_Price__c,TeliaSE_Fiber_Frame_Agreement__c FROM QuoteLineItem where QuoteId = :QtList.Id];
         List<Contract> preCon = [select vlocity_cmt__QuoteId__c from Contract where ContractNumber=:QtList.TeliaSE_Previous_Contract_Number__c];
            system.debug(preCon+'preCon');
        List<QuoteLineItem> preQLines = [select TeliaSE_Product_Code__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__OneTimeCharge__c,Fiber_Customer_Requested_Price__c,TeliaSE_Fiber_Frame_Agreement__c FROM QuoteLineItem where QuoteId = :preCon[0].vlocity_cmt__QuoteId__c];
       system.debug('preQLines'+preQLines+'111111111'+QtList.Status+'previous43'+QtList.TeliaSE_Previous_Contract_Number__c);
            system.debug('quotelistsize'+qLines.size());
                     system.debug('prequotelistsize'+preQLines.size());  
              for(integer qListNo=0;qListNo<qLines.size();qListNo++)
            {
                for(integer preQListNo=0;preQListNo<preQLines.size();preQListNo++)
                {  
                    if(qLines[qListNo].TeliaSE_Product_Code__c==preQLines[preQListNo].TeliaSE_Product_Code__c)
                {
                     system.debug('quoteitem'+qLines[qListNo].TeliaSE_Product_Code__c);
                    system.debug('prequoteitem'+preQLines[preQListNo].TeliaSE_Product_Code__c);
                   QtList.TeliaSE_Fiber_Service_Upgrade__c=False;
                    if((qLines[qListNo].vlocity_cmt__RecurringCharge__c !=preQLines[preQListNo].vlocity_cmt__RecurringCharge__c) || (qLines[qListNo].vlocity_cmt__OneTimeCharge__c !=preQLines[preQListNo].vlocity_cmt__OneTimeCharge__c) || (qLines[qListNo].Fiber_Customer_Requested_Price__c !=preQLines[preQListNo].Fiber_Customer_Requested_Price__c) || (qLines[qListNo].TeliaSE_Fiber_Frame_Agreement__c !=preQLines[preQListNo].TeliaSE_Fiber_Frame_Agreement__c))
                    {
                       	QtList.TeliaSE_Fiber_Price_Upgrade__c=True;
                    }
                    else{
                        QtList.TeliaSE_Fiber_Price_Upgrade__c=False;
                    }
                }
                 else{
                  QtList.TeliaSE_Fiber_Service_Upgrade__c=True;  
                }
                }  
        }
           
        }         
    }
}