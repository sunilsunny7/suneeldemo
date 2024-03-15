@isTest
public class TeliaSE_QuoteRetentionHandler_Test {

    public static testMethod void test(){
        FiberDiscountMandate__c fb = new FiberDiscountMandate__c();
        fb.Role__c = 'Manager';
        fb.Name = 'Manager';
        fb.EBIT_Max_Mandate__c = 12;
        fb.EBIT_Min_Mandate__c = 1;
        fb.ProductDiscountMaxMandate__c = 12;
        fb.ProductDiscountMinMandate__c = 12;
        insert fb;
        
        FiberDiscountMandate__c fb1 = new FiberDiscountMandate__c();
        fb1.Role__c = 'Director';
        fb1.Name = 'Director';
        fb1.EBIT_Max_Mandate__c = 12;
        fb1.EBIT_Min_Mandate__c = 1;
        fb1.ProductDiscountMaxMandate__c = 12;
        fb1.ProductDiscountMinMandate__c = 12;
        insert fb1;
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
         Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account acc = new Account(Name='Test Account', recordtypeid = AccRtid);
        insert acc;
        
        Id OppRtid =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='opp1',AccountId=acc.Id,CloseDate=system.today(),stageName='01 Prospect',recordtypeid = OppRtid);
        insert opp;
 
        ID rtd=[select Id from RecordType where sObjectType = 'Quote' And Name = 'Offer Quote'].Id;
        Quote qut = new Quote();
        qut.RecordTypeId=rtd;
        qut.Name='Test Quote';
        qut.status = 'Price Approved';
        qut.opportunityId = opp.id;
        qut.Pricebook2ID = stdPriceBookRecId;
        qut.TeliaSE_Approval_Flag__c = False;     
        insert qut;
            
     List<sObject> types=new List<sObject>();
         SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
         vlocity_cmt__ObjectClass__c FiberType = new vlocity_cmt__ObjectClass__c(Name = 'Fiber Base Product Spec Type', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            
            types.add(FiberType);
 
            insert types;
        List<Product2> prod = Test_DataFactory.createProducts(10);
	 	prod[0].name='Promo_BB_LL';
        prod[0].ProductCode='Promo_BB_LL';
		prod[0].vlocity_cmt__ObjectTypeId__c=FiberType.Id;
        
     	prod[1].name='Promo_XLAN_LL';
        prod[0].ProductCode='Promo_XLAN_LL';
        prod[1].vlocity_cmt__ObjectTypeId__c=FiberType.id;

        prod[2].name='Promo_COAX_TV';
        prod[0].ProductCode='Promo_COAX_TV';
        prod[2].vlocity_cmt__ObjectTypeId__c=FiberType.id;
            
        prod[3].name='Promo_IPTV_LL';
            prod[0].ProductCode='Promo_IPTV_LL';
        prod[3].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[4].name='Promo_Open_Fiber_LL';
            prod[0].ProductCode='Promo_Open_Fiber_LL';
        prod[4].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[5].name='Promo_Landlord';
            prod[0].ProductCode='Promo_Landlord';
        prod[5].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[6].name='Promo_VoIP_LL';
            prod[0].ProductCode='Promo_VoIP_LL';
        prod[6].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[7].name='Promo_Riksnet_BB';
            prod[0].ProductCode='Promo_Riksnet_BB';
           insert prod;   
        
         PricebookEntry objpricebookentry =new PricebookEntry();
         objpricebookentry.Product2ID = prod[0].id;
         objpricebookentry.Pricebook2ID = stdPriceBookRecId;
         objpricebookentry.UnitPrice=23.50;
         objpricebookentry.UseStandardPrice=false;
         objpricebookentry.isActive=true;//Add this line
         insert objpricebookentry;
     
        List<QuoteLineItem> preQLines = new List<QuoteLineItem>();
        QuoteLineItem oli = new QuoteLineItem();
        oli.PricebookEntryId = objpricebookentry.Id;
        oli.QuoteId = qut.id;
        oli.UnitPrice = 200;
        oli.Quantity = 4;    
        oli.vlocity_cmt__Product2Id__c = prod[1].id;
        oli.TeliaSE_Ceiling_Price__c = 400;
        oli.TeliaSE_Root_Product__c=prod[1].id;
        oli.vlocity_cmt__ParentItemId__c=null;
        insert oli;
        preQLines.add(oli);
     //qut.Status='Price Approved';
        //update qut;
        
            //qut.status='Customer Approved';
            //update qut;
        ID contractRtid=[select Id from RecordType where sObjectType = 'Contract' And Name = 'Connected & Smart Building'].Id;
     //Id contractRtid ='0121p000000wsYbAAI';
        Contract contr = new Contract();
        contr.RecordTypeId=contractRtid;
        contr.vlocity_cmt__QuoteId__c=qut.Id;
        contr.Status='Draft';
        contr.AccountId = acc.Id;
        contr.StartDate = date.today();
        contr.Actionneeded__c = false;
        contr.Large_dataload__c = false;
        contr.vlocity_cmt__IsAutoRenew__c = false;
        contr.vlocity_cmt__IsFrameContract__c = false;
        contr.TeliaSE_Fiber_Installation_Date__c=system.today();
        insert contr;
        
        Contract con=new Contract();
        con =[select ContractNumber from Contract where id=:contr.id];
        system.debug('pravs'+contr+'tran'+con);
     
        //contr.Status='Active';
        //update contr;
            
        Quote qut2 = new Quote();
        qut2.Name='Retention Quote';
        qut2.RecordTypeId=rtd;
        qut2.status = 'Price Approved';
        qut2.opportunityId = opp.id;
        qut2.Pricebook2ID = stdPriceBookRecId;
        qut2.TeliaSE_Approval_Flag__c = False;
        qut2.TeliaSE_Previous_Contract_Number__c=con.ContractNumber;
                  insert qut2;
     
        List<QuoteLineItem> qLines= new List<QuoteLineItem>();
     
        QuoteLineItem oli5 = new QuoteLineItem();
        oli5.PricebookEntryId = objpricebookentry.Id;
        oli5.QuoteId = qut2.id;
        oli5.UnitPrice = 200;
        oli5.Quantity = 4;                
        oli5.vlocity_cmt__Product2Id__c = prod[1].id;
        oli5.TeliaSE_Ceiling_Price__c = 400;
        oli5.TeliaSE_Root_Product__c=prod[1].id;
        oli5.vlocity_cmt__ParentItemId__c=null;
        insert oli5;
         qLines.add(oli5);
     
           qut2.Status = 'Price Approved';
            //update qut2;
      List<Quote> qlist=new List<Quote>();
       qlist.add(qut);
        TeliaSE_QuoteRetentionHandler.checkServiceUpgrade(qlist);
       //TeliaSE_QuoteRetentionHandler.checkServiceUpgrade(qLines);
       //obj.
    }
    
}