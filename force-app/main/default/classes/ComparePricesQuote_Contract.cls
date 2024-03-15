/**
* @Author:      Ananya Patra
* @Company:     Capgemini
* @Date:        2nd September 2020
* @Description: This class will:
                -compare Quote Line Item prices with its respective Contract Line Item prices
                -validate the FA Quote
                -lock the FA Quote

* History
* <Date>           <Authors Name>      <Brief Description of Change>
* -------------------------------------------------------------------
                    Ananya Patra       Sprint-2: MCSTO-4768:Compare CLI and QLI prices and commercial terms
  10-09-2020        Ananya Patra       Sprint-5: MCSTO-5147:Moving Validations from OS level to Apex Class
*/

global class ComparePricesQuote_Contract implements vlocity_cmt.VlocityOpenInterface2 {
    @TestVisible
    private static String jsonString;
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('comparePrices')) {
                comparePrices(inputMap);
            }
            else if(methodName.equalsIgnoreCase('validateFAQuote')) {
              //  updateCartPrice(inputMap, outMap);
              	 validateFAQuote(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('getQuoteLocked')) {
                getQuoteLocked(inputMap, outMap);
            }//UpdateContractStatusAndDeleteCase
            else if(methodName.equalsIgnoreCase('UpdateContractStatusAndDeleteCase')) {
                UpdateContractStatusAndDeleteCase(inputMap);
            }
            else {
                result = false;
            }   
            
        } catch(Exception e) {          
            result = false;
        }        
        return result;
    }
  public static void updateCartPrice(Map<String,Object> inputMap, Map<String,Object> outMap){
        String quoteId;
    boolean callRepriceFlag = false;
       
        Map<String,Object> inMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        if (inputMap.containsKey('ContextId')){
            quoteId = String.valueof(inputMap.get('ContextId')); 
            inMap.put('cartId', quoteId);
        }
        if (inputMap.containsKey('FAQuoteFlag') ) {
            callRepriceFlag = (boolean)inputMap.get('FAQuoteFlag'); 
        } 
        string quotetype = (String) inputMap.get('type');
        if(quoteType != 'New Sales')
        {            
            List<QuoteLineItem> qliItem = [Select id,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c,MC_RootPriceFlag__c from quoteLineItem where Quoteid=: quoteId];
            List<String> parentItemId = new List<String>();
            List<Id> pricingItemIds = new List<Id>();
            boolean allUpdated = true;
            for(QuoteLineItem qli:qliItem) 
            {
                if(qli.vlocity_cmt__ParentItemId__c == null && qli.MC_RootPriceFlag__c == true)
                {
                    parentItemId.add(qli.vlocity_cmt__RootItemId__c);
                }
                else if(qli.vlocity_cmt__ParentItemId__c == null && qli.MC_RootPriceFlag__c == false)
                {
                    allUpdated = false;
                }
            }
    
            if(parentItemId != null && parentItemId.size()>0 && allUpdated == false)
            {
        


                for(QuoteLineItem qliChild : qliItem)
                {
                    if(parentItemId.contains(qliChild.vlocity_cmt__RootItemId__c))
                    {
                        pricingItemIds.add(qliChild.id);
                    }
                }
                inMap.put('items',pricingItemIds);
            }
        }
        Quote qt = [select id, TeliaSE_locked__c from Quote where Id =: quoteId];       


      if(!Test.isRunningTest() && !qt.TeliaSE_locked__c && !callRepriceFlag){
           new vlocity_cmt.CpqAppHandler().invokeMethod('priceCart', inMap, outputMap, outputMap);
        }
    }        
    public static Boolean validateFAQuote(Map<String, object>inputMap,Map<String, object>outMap){
        //Validation 1: FAQuoteStatus == 'Draft' AND No Valid Contract Exists(<>'Cancelled',<>'Rejected')
        //Validation 2: FAQuoteStatus == 'Approved' AND No Valid Contract Exists(<>'Cancelled',<>'Rejected') AND ApprovalCount <> 0
        //Validation 3: FAQuoteStatus == 'Draft' AND Yes Valid Contract Exists AND (ApprovalCount <> 0 OR foundChangeFlag == true)
        //Validation 4: FAQuoteStatus == 'Approved' AND Yes Valid Contract Exists AND (ApprovalCount <> 0 OR foundChangeFlag == true)
        String quoteId;
        Boolean validContractExists;   
        if (inputMap.containsKey('ContextId')){
            quoteId = String.valueof(inputMap.get('ContextId'));            
        }
        else {            
            outMap.put('Error','QuoteId not found');
            return false;
        }
		List<QuoteLineItem> offerCallOffList = new List<QuoteLineItem>();
        List<Quote> faQuoteList = [Select Id, Status, TeliaSE_Approval_Count__c  from Quote where Id =: quoteId];
        List<Contract> contractList = [Select Id from Contract where vlocity_cmt__QuoteId__c =: quoteId and Status<>'Rejected' and Status<>'Cancelled'];
		if(System.label.MC_QuantityCapture=='false'){
        offerCallOffList = [SELECT Id, TeliaSE_MC_FACallOffQuantity__c,MC_Line_Status__c FROM QuoteLineItem WHERE quoteId =: quoteId AND TeliaSE_MC_FACallOffQuantity__c >=0 AND ((Quote.TeliaSE_MC_Sales_Flow_Identifier__c != 'Tilläggsförhandling') OR (Quote.TeliaSE_MC_Sales_Flow_Identifier__c = 'Tilläggsförhandling' AND MC_Line_Status__c != 'Existing'))];
        }
        //Calling DR from Apex
        String DRName = 'DR_ExtractQuoteLineItemsContractLineItems';        
        Map<String, Object> myInputData = new Map<String, Object>{'qid'=> quoteId};
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(myInputData, DRName); 
        List<Map<String, Object>> myOutputResult = (List<Map<String, Object>>)result.toJsonList(); 
        
        if(Test.isRunningTest()){
            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            //myOutputResult = (List<Map<String, Object>>)JSON.deserialize(jsonString, List<Object>.class);
            myOutputResult.add(mapResult);
        }
       
        Map<String, Object> quoteMap = new Map<String, Object>();
        Map<String, Object> contractMap = new Map<String, Object>();
        Double approvalCount;
        String quoteCommercialTerms, contractCommercialTerms;
        
        if(myOutputResult.size()>0 && myOutputResult[0].containsKey('Quote')){
            quoteMap = ( Map<String, Object>)myOutputResult[0].get('Quote');
            approvalCount = Double.valueOf(quoteMap.get('ApprovalCount'));
            quoteCommercialTerms = (String)quoteMap.get('CommercialBenchmark')+(String)quoteMap.get('InvoiceFee')+(Double)quoteMap.get('PaymentTerm');
        }
        if(myOutputResult.size()>0 && myOutputResult[0].containsKey('Contract')){
            contractMap = ( Map<String, Object>)myOutputResult[0].get('Contract');
            contractCommercialTerms = (String)contractMap.get('CommercialBenchmark')+(String)contractMap.get('InvoiceFee')+(Double)contractMap.get('PaymentTerm');   
        } 
            
        if (contractList.size()>0){ 
            validContractExists = true;             
             Map<String, Object> compareInputMap = new Map<String, Object>();
             //compareInputMap.put('CLI',( List<Object>)myOutputResult[0].get('CLI'));
             //compareInputMap.put('QLI',( List<Object>)myOutputResult[0].get('QLI'));
             compareInputMap = ( Map<String, Object>)myOutputResult[0];
             
             Boolean compareResult = comparePrices(compareInputMap); 
            if (compareResult || approvalCount <> 0 || quoteCommercialTerms != contractCommercialTerms){
                 if(faQuoteList[0].status <> 'Approved'){
                     outMap.put('Error','Innan du kan generera offertdokumentet krävs ett nytt godkännande på prisförhandlingen samt att avtalet skapas om på nytt. Var vänlig skicka prisförhandlingen för godkännande samt skapa om avtalet.');
                     return false;
                 }
                 else if (faQuoteList[0].status == 'Approved'){
                     //outMap.put('Error','Innan du kan generera offertdokumentet krävs det att avtalet skapas om på nytt. Var vänlig skapa om avtalet först.');
                     outMap.put('Error','Vid ändringar i pris/ produkt så kommer ditt tidigare avtal att avbrytas och ett nytt avtal måste skapas när offerten är godkänd av kund.');
                    outMap.put('Success','confirmation to continue');
                     return false;
                 }
             }
             if (compareResult == false){
                 outMap.put('Success','Continue with Flow');
                 return true;
             }
        } 
        else if(faQuoteList[0].status <> 'Approved'){
            validContractExists = false;
            outMap.put('Error','Innan du kan generera offertdokumentet krävs att prisförhandlingen är godkänd. Var vänlig skicka prisförhandlingen för godkännande först.');
           return false;
        }
        else if(faQuoteList[0].status == 'Approved' && approvalCount <> 0){
            validContractExists = false;
            //outMap.put('Error','Vid ändringar i pris/ produkt så kommer ditt tidigare avtal att avbrytas och ett nytt avtal måste skapas när offerten är godkänd av kund.');
            outMap.put('Error','Innan du kan generera offertdokumentet krävs det att avtalet skapas om på nytt. Var vänlig skapa om avtalet först.');
            return false;
        }
        else if(faQuoteList[0].status == 'Approved' && offerCallOffList.size() == 0 && System.label.MC_QuantityCapture=='false'){
            validContractExists = false;
            outMap.put('Error','Du kan inte skapa en offert utan produktkvantitet');
            return false;
        } 
        outMap.put('Success','Continue with Flow');
        return true;
    }
        
    public static Boolean comparePrices(Map<String, object>inputMap){
        
        Object cli = (Object)inputMap.get('CLI');
        String clijson = JSON.serialize(cli);
        List<CLI> cliList = (List<CLI>)JSON.deserialize(clijson, List<CLI>.class);        
        Object qli = (Object)inputMap.get('QLI');
        String qlijson = JSON.serialize(qli);
        List<QLI> qliList = (List<QLI>)JSON.deserialize(qlijson, List<QLI>.class); 
        
        Boolean foundChange = false;   
        
        if (qliList.size() != cliList.size()){
            foundChange = true;
        }
        else{
            Integer matchCount=0;
            for(CLI c : cliList){
                
                for(QLI q : qliList){
                    
                    
                    if(c.Product.Name == q.Name){ 
                        matchCount++;
                        if(c.Product.RecurringCharge != q.RecurringCharge){
                            foundChange = true;
                            break;               
                        }
                        
                        if(c.Product.OneTimeCharge != q.OneTimeCharge){
                            foundChange = true;
                            break;  
                        }
                        
                        if(c.Product.RequestedPrice==null && q.RequestedPrice==null){
                            if(c.Product.RequestedPercentage != q.RequestedPercentage || c.Product.ApprovedPercentage != q.ApprovedPercentage){
                                foundChange = true;
                                break;  
                            }
                        }
                        if(c.Product.RequestedPercentage==null && q.RequestedPercentage==null){
                            if(c.Product.RequestedPrice != q.RequestedPrice || c.Product.ApprovedPrice != q.ApprovedPrice){
                                foundChange = true;
                               break;  
                            }
                        }
                        if(c.Product.QuarantineTime != null && q.QuarantineTime != null) {
                            if(c.Product.QuarantineTime != q.QuarantineTime){
                                foundChange = true;
                                break;  
                            }
                        }
                        if(c.Product.MinValueCommit != null && q.MinValueCommit != null) {
                            if(c.Product.MinValueCommit != q.MinValueCommit){
                                foundChange = true;
                                break;  
                            }
                        }
                        if(c.Product.Campaign != null || q.Campaign != null) {
                            if(c.Product.Campaign != q.Campaign){
                                foundChange = true;
                                break;  
                            }
                        }
                        
                        break;
                    }
                }
                if(foundChange == true){
                    break;
                }
            } 
            if (foundChange == false && cliList.size() != matchCount){
                foundChange = true;
            }
        }
       
       // outMap.put('foundChange',foundChange);
        return foundChange;
    }
    
    //  Added new Method to lock Quote
    public static void getQuoteLocked(Map<String, object>inputMap,Map<String, object>outMap){
        String quoteId = String.valueOf(inputMap.get('ContextId'));
        lockFAQuote(quoteId);
    }
    @future
    public static void lockFAQuote(Id quoteId){
        Quote quote=[select id,TeliaSE_locked__c from Quote where id=:quoteId Limit 1];
         if(quote != null){
              quote.TeliaSE_locked__c =true;
              quote.Status = 'Approved';
              if(TeliaSE_checkRecursive.runOnce())
                {
                 update quote;
                }
         }
         Approval.lock(quoteId, false);
    }
    
    public static void UpdateContractStatusAndDeleteCase(Map<String, object>inputMap){
        String quoteId = String.valueof(inputMap.get('ContextId')); 
        Contract contract = [Select Id,Status,TeliaSE_Case_Id__c from Contract where vlocity_cmt__QuoteId__c =: quoteId and Status<>'Rejected' and Status<>'Cancelled' limit 1];
        Contract con = new Contract();
        con.Id = contract.Id;
        con.Reason_for_Cancellation__c = 'Rejected'; 
        con.TeliaSE_Reason_for_Cancellation__c = 'Rejected';
        con.Status = 'Cancelled';
        update con;
    }
    
    
    public class Product {
        public Double RecurringCharge;
        public String Name;
        public String minimumcomnit;
        public Double OneTimeCharge;
        public Integer RequestedPrice;
        public Integer RequestedPercentage;
        public Integer QuarantineTime;
        public Integer MinValueCommit;
        public Integer ApprovedPercentage;
        public Integer ApprovedPrice;
        public String Campaign;
    }
    public class CLI {
        public Product Product {get; set;}
        public String ContractId {get; set;}
    }
    public class QLI {
        public Double RecurringCharge;
        public String Name;
        public String minimumcomnit;
        public Double OneTimeCharge;
        public Integer RequestedPrice;
        public Integer RequestedPercentage;
        public Integer QuarantineTime;
        public Integer MinValueCommit;
        public Integer ApprovedPercentage;
        public Integer ApprovedPrice;
        public String Campaign;
        
    }
}