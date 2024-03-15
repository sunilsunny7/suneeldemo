@isTest
public class test09 {
 public static testmethod void invokeMethod11(){
       List<Product2> prodList = new List<product2>();
     
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.Name = 'Jobbmobil Total';
            prod.productCode = 'MOB_MULTI_TOTAL';
            insert prod;
                       
         
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod.id;            
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            insert objpricebookentry1;
            
       
        Opportunity opp = new Opportunity();
        opp.Name='opp1';
        opp.CloseDate = System.today();
        opp.StageName='Needs Analysis';  
        opp.Pricebook2Id=Test.getStandardPricebookId();
        opp.TeliaSE_SharingSetting_Flag__c = false;
        //opp.Type_of_Address__c = 'MDU';
        insert opp;
        
       
            
            
            
            
               Quote qut = new Quote();
        qut.Name='Test Quote';
        qut.status = 'Draft';

        qut.opportunityId = opp.id;
        qut.TeliaSE_Type__c='New';
        //qut.Pricebook2ID = objpricebookentry1;
        qut.TeliaSE_Approval_Flag__c = False;        
        qut.TeliaSE_MC_Sales_Flow_Identifier__c='New Sales';
        insert qut;
         
       
       QuoteLineItem oli1 = new QuoteLineItem();
      Map<String,Object> inputmap   = new Map<String,Object>();
       String qliId = (String)inputmap.get('Id');
        oli1.QuoteId = qut.id;
        oli1.UnitPrice = 200;
        oli1.Quantity = 4;
       
        oli1.Product2Id = prod.id;
        oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
        oli1.TeliaSE_MC_Customer_Requested_Price__c = 150;
        oli1.TeliaSE_Approved__c = 1;
     oli1.vlocity_cmt__RootItemId__c ='qliId';
        oli1.TeliaSE_Approved_Price__c = 0;
        oli1.MC_OT_Approved_Price__c = 0;
        oli1.TeliaSE_Nullify_Check__c = true;
        oli1.vlocity_cmt__Product2Id__c = prod.id;
        oli1.vlocity_cmt__RootItemId__c = prod.id;
        insert oli1;
            
 }
}