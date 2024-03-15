public class Testing {

	@future(callout=true)
	public static void test()
    {
        Set<String> prodCodes=new Set<String>();
        List<Product2> prods=[select id,productcode from product2 where C2BC_Subcategory__c ='mobiledevice' and productcode like '9%'];
        for(Product2 prod:prods)
        {
            prodCodes.add(prod.productcode);
        }
	    HttpRequest req=new HttpRequest();
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setEndpoint('https://testaditi.free.beeceptor.com/test');
        HttpResponse res=new Http().send(req);
    	List<SubscriptionProduct__c> datas=new List<SubscriptionProduct__c>();
        SubscriptionProduct__c subProd;

		System.JSONParser parser = JSON.createParser(res.getBody());

        while (parser.nextToken() != null) {
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
        {
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    Data inv = (Data)parser.readValueAs(Data.class);
                    if(prodCodes.contains(inv.hardware.abcNumber))
                    {
                        subProd=new SubscriptionProduct__c();
                        subProd.commitmentPeriod__c=inv.commitment;
                        subProd.Product_Name__c=inv.hardware.productName;
                        subProd.subscriptionCode__c=inv.subscription.extProdId;
                        subProd.discountedPrice__c=inv.imeiDiscountAmountExclVAT;
                        subProd.sapId__c=inv.hardware.abcNumber;
                    	datas.add(subProd);    
                    }
                    parser.skipChildren();
                    
                }
            }
        }
    }
        if(datas.size()>0)
        {
            insert datas;
        }
        System.debug(Limits.getHeapSize());
        System.debug(datas.size());
} 



public class Data {
    public Integer id;
    public DateTime statementDate;
    public Long invoiceNumber;
    public Double imeiDiscountAmountExclVAT;
    public Double basicDiscountAmountExclVAT;
    public Integer commitment;
    public Hardware hardware;
    public Subscription subscription;
    
}  

public class Hardware {
    public String abcNumber;
    public Double retailPriceExclVAT;
    public String productName;
}

public class Subscription {
    public String productName;
    public String extProdId;
}
    
}