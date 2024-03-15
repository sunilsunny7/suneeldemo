@isTest
public class Test_HardwareController {
	    testMethod public static void buttonMethods(){
        List<TeliaSE_MC_SubscriptionBrand__c> brandlist = new List<TeliaSE_MC_SubscriptionBrand__c>();
        TeliaSE_MC_SubscriptionBrand__c brand = new TeliaSE_MC_SubscriptionBrand__c();
        brand.Name = 'apple';
        brand.Brand_Tag__c = 'apple;iphone';
        brandlist.add(brand);
        TeliaSE_MC_SubscriptionBrand__c brand1 = new TeliaSE_MC_SubscriptionBrand__c();
        brand1.Name = 'samsung';
        brand1.Brand_Tag__c = 'samsung';
        brandlist.add(brand1);
        TeliaSE_MC_SubscriptionBrand__c brand2 = new TeliaSE_MC_SubscriptionBrand__c();
        brand2.Name = 'sony';
        brand2.Brand_Tag__c = 'sony;xperia';
        brandlist.add(brand2);
        insert brandlist;
        String JsonResponse = '{"ProductNames":[{"Name":"Apple iPhone 8 64GB Rymdgrå"},{"Name":"Samsung Galaxy S10 128GB Prism White"},{"Name":"Apple iPhone 11 Pro 512GB Rymdgrå"},{"Name":"Apple iPhone 11 128GB Svart"},{"Name":"Samsung Galaxy Xcover Pro 64GB Svart"},{"Name":"Samsung Galaxy S20 Ultra 5G Ready 128GB Cosmic Grey"},{"Name":"Apple Iphone 11 64GB Svart"},{"Name":"Apple iPhone 11 Pro 64GB Silver"},{"Name":"Apple iPhone XS Max 256GB Silver"},{"Name":"Apple iPhone 11 Pro Max 256GB Rymdgrå"},{"Name":"Apple iPhone 11 Pro 256 GB Rymdgrå"},{"Name":"Apple iPhone SE 64GB Svart"},{"Name":"Apple iPhone SE 128GB RED"},{"Name":"Apple iPhone XS Max 256GB Rymdgrå"},{"Name":"Apple iPhone SE 256GB Vit"},{"Name":"Apple iPhone 11 Pro  64GB Rymdgrå"},{"Name":"Apple iPhone 11 Pro Max 64GB Midnattsgrön"},{"Name":"Apple iPhone XS Max 512GB Silver"},{"Name":"Apple iPhone SE 32GB Rymdgrå"},{"Name":"Apple iPhone 11 128GB Vit"},{"Name":"Apple iPhone XS 256GB Rymdgrå"},{"Name":"Apple iPhone SE 256GB Svart"},{"Name":"Apple iPhone 11 Pro Max 256GB Guld"},{"Name":"Apple iPhone SE 128GB Vit"},{"Name":"Apple iPhone 11 Pro Max 512GB Midnattsgrön"},{"Name":"Apple iPhone 11 Pro Max 64GB Silver"},{"Name":"Apple iPhone 11 Pro 256GB Midnattsgrön"},{"Name":"Apple iPhone SE 128GB Svart"},{"Name":"Apple iPhone 11 Pro 256GB Guld"},{"Name":"Apple iPhone SE 64GB Vit"},{"Name":"Apple iPhone 11 Pro Max 64GB Guld"},{"Name":"Apple iPhone SE 64GB RED"},{"Name":"Apple iPhone 11 Pro 256GB Silver"},{"Name":"Apple iPhone 11 Pro Max 64GB Rymdgrå"},{"Name":"Apple iPhone 11 Pro Max 512GB Rymdgrå"},{"Name":"Apple Iphone 11 64GB RED"},{"Name":"Samsung Galaxy S10+ 128GB Prism Black"},{"Name":"Samsung Galaxy S20 5G Ready 128GB Cloud Pink"},{"Name":"Apple iPhone 11 256GB Svart"},{"Name":"Xiaomi Mi Note 10 128GB Aurora Green"},{"Name":"Samsung Galaxy Fold 512GB Cosmos Black"},{"Name":"Samsung Galaxy A51 128GB Svart"},{"Name":"Samsung Galaxy S10e 128GB Prism Black"},{"Name":"Apple iPhone 8 Plus 64GB Rymdgrå"},{"Name":"Apple iPhone 11 Pro 64GB Guld"},{"Name":"Apple iPhone XR 128GB Svart"},{"Name":"Apple Iphone 11 64GB Gul"},{"Name":"Samsung Galaxy S10e 128GB Prism White"},{"Name":"Apple iPhone 7 128GB Svart"},{"Name":"Xiaomi Mi Note 10 128GB Glacier White"},{"Name":"Apple iPhone 7 32GB Svart"},{"Name":"Apple iPhone XS 64GB Guld"},{"Name":"Samsung Galaxy A51 128GB Blå"},{"Name":"Apple iPhone 11 128GB Lila"},{"Name":"Apple iPhone XS Max 64GB Rymdgrå"},{"Name":"Apple iPhone 8 64GB Guld"},{"Name":"Samsung Galaxy S20 5G Ready 128GB Cosmic Grey"},{"Name":"Apple iPhone XS Max 64GB Silver"},{"Name":"Samsung Xcover 4s 32GB Svart"},{"Name":"Apple iPhone 11 Pro Max 256GB Midnattsgrön"},{"Name":"Apple iPhone 11 128GB Gul"},{"Name":"Samsung Galaxy S20 5G Ready 128GB Cloud Blue"},{"Name":"Samsung Galaxy S10+ 128GB Prism White"},{"Name":"Samsung Galaxy A51 128GB Vit"},{"Name":"Samsung Galaxy Z Flip 256GB Svart"},{"Name":"Apple iPhone XR 64GB Svart"},{"Name":"Samsung Galaxy S10 128GB Prism Black"},{"Name":"Apple iPhone XS 64GB Rymdgrå"},{"Name":"Apple iPhone SE 256GB RED"},{"Name":"Samsung Galaxy A50 128GB Svart"},{"Name":"Sony Xperia1 128GB Svart"},{"Name":"Apple Iphone 11 64GB Vit"},{"Name":"Apple iPhone XR 64GB Vit"},{"Name":"Samsung Galaxy Z Flip 256GB Lila"},{"Name":"Apple iPhone 11 128GB Grön"},{"Name":"Apple iPhone 11 128GB RED"},{"Name":"Sony Xperia L4 64 GB Svart"},{"Name":"Sony Xperia 10 II 128 GB Svart"},{"Name":"Sony Xperia 10 II 128 GB Vit"},{"Name":"Xperia 5 128GB Svart"},{"Name":"Xperia 10 64GB Marin"},{"Name":"Xperia 10 64GB Svart"},{"Name":"Sony Xperia L4 64 GB Blå"},{"Name":"Xperia L3 32GB Svart"}],"NewAccessories":[{"Name":"Apple iPhone XS Tempered Glass"},{"Name":"Samsung Note 10 Back Cover (Black)"},{"Name":"Apple iPhone 7 Back Cover (Black)"},{"Name":"Samsung Note 10+ Tempered Glass"},{"Name":"Xperia 5 128GB Röd"},{"Name":"Copter Exoglass Curved Galaxy S10"},{"Name":"Tech21 Pure Clear Apple iPhone 7/8"},{"Name":"Copter Displayfilm Galaxy S20"},{"Name":"Studio Colour Iphone 11(Red)"},{"Name":"Krusell Sandby Covers iPhone XS Max(Pink)"},{"Name":"Studio Colour Iphone 11(Black)"},{"Name":"Ercko Fixed Wallet Case iPhone XS Max(Brown)"},{"Name":"Tech21 Pure Clear iPhone XR(Transparent)"},{"Name":"Xqisit Slim Wallet iPhone 11"},{"Name":"Copter Exoglass Sony Xperia 5"}]}';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = new Map<String, Object>();   
        
        
        HardwareController hc = new HardwareController(); 
        hc.invokeMethod('GenerateButton',inputMap,outMap,outMap);
        hc.invokeMethod('GenerateButtonForAccessories',inputMap,outMap,outMap);
        //for covering exceptions GenerateButton
        hc.invokeMethod('GenerateButton',outMap,outMap,outMap);
        hc.invokeMethod('GenerateButtonForAccessories',outMap,outMap,outMap);
        hc.invokeMethod('Ge',outMap,outMap,outMap);
        hc.invokeMethod('GetSubscriptionPickValue',outMap,outMap,outMap);   
            
    }
    testMethod public static void subscriptionMethodMadam(){
        
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
                
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        	    
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.TeliaSE_Subscription_Type__c = '99';
        insert prod;
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.TeliaSE_Subscription_Type__c = '98';
        insert prod1;
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod2.TeliaSE_Subscription_Type__c = '97';
        insert prod2;
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod3.TeliaSE_Subscription_Type__c = '96';
        insert prod3;
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod4.TeliaSE_Subscription_Type__c = '95';
        insert prod4;
		
		SubscriptionFilter__c sfilter = new SubscriptionFilter__c();
		sfilter.Name = prod.Name;
        insert sfilter;     
       	HardwareController hc = new HardwareController(); 	
       	System.runAs(new User(Id = Userinfo.getUserId())){
        	salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
        	salesManager.Bypass_VR__c = true;
        	insert salesManager;
        }
        System.runAs(salesManager){
            Opportunity opp = new Opportunity();
        	opp.Name='opp1';
        	opp.CloseDate = System.today();
        	opp.StageName='Kvalificera';  
        	opp.Pricebook2Id=Test.getStandardPricebookId();
        	opp.TeliaSE_SharingSetting_Flag__c = false;
       		insert opp;
            
			PricebookEntry objpricebookentry =new PricebookEntry();
         	objpricebookentry.Product2ID = prod.id;
         	objpricebookentry.Pricebook2ID = stdPriceBookRecId;
         	objpricebookentry.UnitPrice=23.50;
         	objpricebookentry.UseStandardPrice=false;
         	objpricebookentry.isActive=true;//Add this line
        	insert objpricebookentry;
            
            Quote qut = new Quote();
        	qut.Name='Test Quote';
        	qut.status = 'Draft';  
        	qut.opportunityId = opp.id;
       	 	qut.Pricebook2ID = stdPriceBookRecId;
        	qut.TeliaSE_Approval_Flag__c = False;        
        	insert qut;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Product2Id = prod.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.UnitPrice = 0;
        	oli1.Quantity = 1;
            insert oli1;            
            
            Account acc = Test_DataFactory.createOneAccount();
          	insert acc; 
            
            Contract contract = new Contract();
            contract.AccountId = acc.Id;
            contract.Agreement_Nr__c = '123456';
            insert contract;
            
            vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
            cli.vlocity_cmt__ContractId__c = contract.Id;
            cli.TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification';
			cli.vlocity_cmt__Product2Id__c = prod1.Id;
            cli.TeliaSE_MC_Customer_Requested_Price__c = 213.00;
            insert cli;
            
            vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
            cli1.vlocity_cmt__ContractId__c = contract.Id;
            cli1.TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification';
			cli1.vlocity_cmt__Product2Id__c = prod.Id;
            insert cli1;
            
        	String JsonResponse = '{"EFS":[{"pricePlanFee":"76","Subscriptions":"96"},{"pricePlanFee":"","Subscriptions":"97"},{"pricePlanFee":"77","Subscriptions":"98"},{"pricePlanFee":"70","Subscriptions":"99"},{"pricePlanFee":"76","Subscriptions":"90"}],"Madam":{"AgreementId":"123456","sfAgreement":"Y"},"product":[{"Subscription":"99","Listprice":"77"},{"Subscription":"99","Listprice":"77"},{"Subscription":"98","Listprice":"77"},{"Subscription":"97","Listprice":"77"},{"Subscription":"96","Listprice":"77"},{"Subscription":"95","Listprice":"77"}]}';
        	Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        	Map<String, Object> outMap = new Map<String, Object>();
                   
            
            hc.invokeMethod('getSubscriptions',inputMap,outMap,outMap);
        	        
       		SubscriptionEFSServices.SubscriptionWrappper subwrap= new SubscriptionEFSServices.SubscriptionWrappper();
        	subwrap.Subscriptioncode = ' ';
        	subwrap.SubscriptionId = ' ';
    	    subwrap.SubscriptionName = ' ';
    	    subwrap.SubscriptionPrice = ' ';        
        }
        String JsonResponse = '{"EFS":[{"pricePlanFee":"76","Subscriptions":"96"},{"pricePlanFee":"","Subscriptions":"97"},{"pricePlanFee":"77","Subscriptions":"98"},{"pricePlanFee":"70","Subscriptions":"99"},{"pricePlanFee":"76","Subscriptions":"90"}],"Madam":{"AgreementId":"123456","sfAgreement":"N"},"product":[{"Subscription":"99","Listprice":"77"},{"Subscription":"99","Listprice":"77"},{"Subscription":"98","Listprice":"77"},{"Subscription":"97","Listprice":"77"},{"Subscription":"96","Listprice":"77"},{"Subscription":"95","Listprice":"77"}]}';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = new Map<String, Object>();
        
        hc.invokeMethod('getSubscriptions',inputMap,outMap,outMap);        
        hc.invokeMethod('getSubscriptions',outMap,outMap,outMap);  
    
    }
    /*
	testMethod public static void hierarachyPath(){    	
     	User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();

       	System.runAs(new User(Id = Userinfo.getUserId())){
        	salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
        	salesManager.Bypass_VR__c = true;
        	insert salesManager;
        }
        System.runAs(salesManager){
     		vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
            objClass.Name = 'Mobile Handset Product Specification';    
            objClass.vlocity_cmt__IsActive__c = True;
            objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass;
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
        	prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        	insert prod;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        	prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        	insert prod1;
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        	prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        	insert prod2;
        	pricebookId = stdPriceBookRecId ;
        
        	Opportunity opp = new Opportunity();
        	opp.Name='opp1';
        	opp.CloseDate = System.today();
        	opp.StageName='Kvalificera';  
        	opp.Pricebook2Id=Test.getStandardPricebookId();
        	opp.TeliaSE_SharingSetting_Flag__c = false;
       		insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
         	objpricebookentry.Product2ID = prod.id;
         	objpricebookentry.Pricebook2ID = stdPriceBookRecId;
         	objpricebookentry.UnitPrice=23.50;
         	objpricebookentry.UseStandardPrice=false;
         	objpricebookentry.isActive=true;//Add this line
        	insert objpricebookentry;
            
            Quote qut = new Quote();
        	qut.Name='Test Quote';
        	qut.status = 'Draft';  
        	qut.opportunityId = opp.id;
       	 	qut.Pricebook2ID = stdPriceBookRecId;
        	qut.TeliaSE_Approval_Flag__c = False;        
        	insert qut;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Product2Id = prod.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.UnitPrice = 0;
        	oli1.Quantity = 1;
            insert oli1;
            
            vlocity_cmt__ProductChildItem__c pci = new vlocity_cmt__ProductChildItem__c();
        	pci.vlocity_cmt__ParentProductId__c = prod.Id;
        	pci.vlocity_cmt__ChildProductId__c = prod1.Id;
     		pci.vlocity_cmt__ChildLineNumber__c = '2';
        	insert pci;
            
     		vlocity_cmt__ProductChildItem__c pci1 = new vlocity_cmt__ProductChildItem__c();
        	pci1.vlocity_cmt__ParentProductId__c = prod1.Id;
        	pci1.vlocity_cmt__ChildProductId__c = prod2.Id;
     		pci1.vlocity_cmt__ChildLineNumber__c = '2';
        	insert pci1;
            
           	String JsonResponse = '{'+
				'\"SelectedHardwareProductList\": [{'+
				'\"Name\": \"'+prod2.Name+'\",'+
				'\"Id\": \"'+prod2.Id+'\",'+
            	'\"ProductId\": \"'+prod2.Id+'\",'+
            	'\"Code\": \"'+prod2.ProductCode+'\"'+
				'}],'+
            	'\"BundleAndCart\": {'+
				'\"QuoteId\": \"'+qut.Id+'\",'+
				'\"BundleId\": \"'+oli1.Id+'\"'+
				'},'+
                '\"AccessoriesList\": [{'+
				'\"Name\": \"'+prod2.Name+'\",'+
				'\"Id\": \"'+prod2.Id+'\",'+
            	'\"ProductId\": \"'+prod2.Id+'\",'+
            	'\"Code\": \"'+prod2.ProductCode+'\"'+
				'}],'+
            	'\"AccessoryBundleAndCart\": {'+
				'\"QuoteId\": \"'+qut.Id+'\",'+
				'\"BundleId\": \"'+oli1.Id+'\"'+
				'}'+
			'}';
            Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
            Map<String, Object> outMap = new Map<String, Object>();
            
            HardwareController hc = new HardwareController(); 
        	hc.invokeMethod('getproductPath',inputMap,outMap,outMap);
            hc.invokeMethod('getAccessorypath',inputMap,outMap,outMap);
          //  Hardware_ProductHierarchyPath.hierarachyPathProducts(inputMap,outMap);
          //  Hardware_ProductHierarchyPath.hierarachyPathAccessory(inputMap,outMap);
        }
 	}*/
    testMethod public static void Wrappers(){
        
        List<Mobilabonnemang__c> mobsub = new List<Mobilabonnemang__c>();
        HardwareController.ResponseWrapper responsewrap = new HardwareController.ResponseWrapper(); 
   		responsewrap.mobilabonnemangList = mobsub;
        responsewrap.numberOfRecords = 1;
        responsewrap.accountName = 'abc';
        /*        
        Hardware_ProductHierarchyPath.SubscriptionAndProductMapWrapper sandpwrap = new Hardware_ProductHierarchyPath.SubscriptionAndProductMapWrapper();
        sandpwrap.productId = '01t5E000003vglFQAQ';
        Hardware_ProductHierarchyPath.heirarchypathwrapper hwrap = new Hardware_ProductHierarchyPath.heirarchypathwrapper();
        hwrap.prodId = '01t5E000003vglFQAQ';
        hwrap.parentId = '';
        hwrap.path = '';
        List<Hardware_ProductHierarchyPath.Recordswrap> rlist = new List<Hardware_ProductHierarchyPath.Recordswrap>();
        Hardware_ProductHierarchyPath.Recordswrap rwrap = new Hardware_ProductHierarchyPath.Recordswrap();
        rwrap.parentHierarchyPath = '';
        rwrap.productHierarchyPath = '';
        rlist.add(rwrap);
        Hardware_ProductHierarchyPath.ParentRecordwrap pwrap = new Hardware_ProductHierarchyPath.ParentRecordwrap();
        
        pwrap.records = rlist;
        List<Hardware_ProductHierarchyPath.Itemswrap> itemwrapList = new List<Hardware_ProductHierarchyPath.Itemswrap>();
        Hardware_ProductHierarchyPath.Itemswrap itemwrap = new Hardware_ProductHierarchyPath.Itemswrap();
        itemwrap.itemId = '';
        itemwrap.parentId = '';
        itemwrap.parentRecord = pwrap;
        itemwrapList.add(itemwrap);
        Hardware_ProductHierarchyPath.SubscriptionAndProductMapResponseWrap sandpresponsewrap = new Hardware_ProductHierarchyPath.SubscriptionAndProductMapResponseWrap();
        sandpresponsewrap.cartId = '';
        sandpresponsewrap.methodName = '';
        sandpresponsewrap.price = false;
        sandpresponsewrap.validate = false;
        sandpresponsewrap.items = itemwrapList;
        Hardware_ProductHierarchyPath.SubscriptionAndProductMapwrap sandprodwrap = new Hardware_ProductHierarchyPath.SubscriptionAndProductMapwrap();
        sandprodwrap.cartId = '';
        sandprodwrap.items = itemwrapList;
        sandprodwrap.methodName = '';
        sandprodwrap.price = false;
        sandprodwrap.validate = false;
        sandprodwrap.productId = '';*/
    }
	
    testMethod public static void getMobilRecords(){
        User user; 
        System.runAs(new User(Id = Userinfo.getUserId())){
        	user = Test_DataFactory.createAdminUser();
        	user.Bypass_VR__c = true;
        	insert user;
        }
        System.runAs(user){
            Account acc = Test_DataFactory.createOneAccount();
          	insert acc;
            Account acc1 = Test_DataFactory.createOneAccount();
          	insert acc1;
            Mobilabonnemang__c mobilsubs = new Mobilabonnemang__c();
            mobilsubs.Account__c = acc.Id;
            mobilsubs.Allowed_To_Bind__c = 'yes';
            insert mobilsubs;
            HardwareController.getMobilRecordsWithParam(acc.Id);
            HardwareController.getMobilRecordsWithParam(acc1.Id);
        }        
    }/*
     testMethod public static void updateStatusColt(){
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
                
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        	    
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.TeliaSE_Subscription_Type__c = '99';
        insert prod;
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.TeliaSE_Subscription_Type__c = '98';
        insert prod1;
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod2.TeliaSE_Subscription_Type__c = '97';
        insert prod2;
            
        System.runAs(new User(Id = Userinfo.getUserId())){
        	salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
        	salesManager.Bypass_VR__c = true;
        	insert salesManager;
        }
        System.runAs(salesManager){
			Opportunity opp = new Opportunity();
        	opp.Name='opp1';
        	opp.CloseDate = System.today();
        	opp.StageName='Kvalificera';  
        	opp.Pricebook2Id=Test.getStandardPricebookId();
        	opp.TeliaSE_SharingSetting_Flag__c = false;
       		insert opp;
            
			PricebookEntry objpricebookentry =new PricebookEntry();
         	objpricebookentry.Product2ID = prod.id;
         	objpricebookentry.Pricebook2ID = stdPriceBookRecId;
         	objpricebookentry.UnitPrice=23.50;
         	objpricebookentry.UseStandardPrice=false;
         	objpricebookentry.isActive=true;//Add this line
        	insert objpricebookentry;
            
            Quote qut = new Quote();
        	qut.Name='Test Quote';
        	qut.status = 'Draft';  
        	qut.opportunityId = opp.id;
       	 	qut.Pricebook2ID = stdPriceBookRecId;
        	qut.TeliaSE_Approval_Flag__c = False;        
        	insert qut;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Product2Id = prod.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.UnitPrice = 0;
        	oli1.Quantity = 1;
            insert oli1;
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.QuoteId = qut.Id;
            oli2.Product2Id = prod1.Id;
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.UnitPrice = 0;
        	oli2.Quantity = 1;
            insert oli2;
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.QuoteId = qut.Id;
            oli3.Product2Id = prod2.Id;
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.UnitPrice = 0;
        	oli3.Quantity = 1;
            insert oli3;
            
		String JsonResponse = '{'+
		'	\"QLIToBeUpdated\": ['+
		'		{'+
		'			\"SapId\": \"9087055\",'+
		'			\"Id\":\"'+oli1.Id+'\"'+
		'		},'+
		'		{'+
		'			\"SapId\": \"9086894\",'+
		'			\"Id\": \"'+oli2.Id+'\"'+
		'		},'+
		'		{'+
		'			\"SapId\": \"9087067\",'+
		'			\"Id\": \"'+oli3.Id+'\"'+
		'		} '+
		'	],'+
		'	\"IPStatus\": ['+
		'		{'+
		'			\"Status\": \"OUT_OF_STOCK\",'+
		'			\"SapId\": \"9087055\"'+
		'		},'+
		'		{'+
		'			\"Status\": \"IN_STOCK\",'+
		'			\"SapId\": \"9086894\"'+
		'		},'+
		'		{'+
		'			\"Status\": \"MISSING_ARTICLE\",'+
		'			\"SapId\": \"9087067\"'+
		'		}'+
		'	]'+
		'}';
            
        	Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        	Map<String, Object> outMap = new Map<String, Object>();
            
            HardwareController hc = new HardwareController();            
         	hc.invokeMethod('updateStatusColt',inputMap,outMap,outMap);
        }
    }*/
    testMethod public static void testIp(){
        User salesManager;         
        
        System.runAs(new User(Id = Userinfo.getUserId())){
        	salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
        	salesManager.Bypass_VR__c = true;
        	insert salesManager;
        }
        System.runAs(salesManager){
            
            Account acc = Test_DataFactory.createOneAccount();
            insert acc;   
        	String JsonResponse = '{"Response2":{"data":{"Subscriptions":{"select":[{"customeridentificationnumber":"165590335476","subscriptionid":"0705076687","msisdn":"46705076687","categoryname":"Mobila talabonnemang","productsubcategory":"voice","mainagreementid":"78000311","agreementnumber":null,"commitmentstartdate":"2020-04-30","commitmentenddate":"20230430","commitmentlength":"36","subscriptiontypecategory":"VOICE","startdate":"20200429","offeringnameofferingcode":"95","offeringname":"Jobbmobil 25 GB Ram","customername":"HILLSTA HUS OCH FASTIGHETER, AB","last_used_model_by_imei":"Iphone X","mobileservices":[{"servicevalue":"0","servicecode":"BND","attributes":[{"attributename":"CommitmentLength","attributevalue":"36"},{"attributename":"CommitmentStartDate","attributevalue":"20200430"},{"attributename":"CommitmentEndDate","attributevalue":"20230430"}]}]},{"customeridentificationnumber":"165590335476","subscriptionid":"0705076686","msisdn":"46705076686","categoryname":"Mobila talabonnemang","productsubcategory":"voice","mainagreementid":"78000311","agreementnumber":null,"commitmentstartdate":"2020-04-30","commitmentenddate":"20220430","commitmentlength":"24","subscriptiontypecategory":"VOICE","startdate":"20200429","offeringnameofferingcode":"96","offeringname":"Jobbmobil 40 GB Ram","customername":"Test 4, AB","last_used_model_by_imei":"Iphone XS","mobileservices":[{"servicevalue":"26","servicecode":"BND","attributes":[{"attributename":"CommitmentLength","attributevalue":"24"},{"attributename":"CommitmentStartDate","attributevalue":"20200430"},{"attributename":"CommitmentEndDate","attributevalue":"20220430"}]}]},{"customeridentificationnumber":"165590335476","subscriptionid":"0705076685","msisdn":"46705076685","categoryname":"Mobila talabonnemang","productsubcategory":"voice","mainagreementid":"78000311","agreementnumber":null,"commitmentstartdate":"2020-04-29","commitmentenddate":"20220429","commitmentlength":"24","subscriptiontypecategory":"VOICE","startdate":"20200429","offeringnameofferingcode":"97","offeringname":"Jobbmobil 120 GB Ram","customername":"Test 3, AB","last_used_model_by_imei":"Iphone 8","mobileservices":[{"servicevalue":"1","servicecode":"BND","attributes":[{"attributename":"CommitmentLength","attributevalue":"24"},{"attributename":"CommitmentStartDate","attributevalue":"20200429"},{"attributename":"CommitmentEndDate","attributevalue":"20220429"}]}]},{"customeridentificationnumber":"165590335476","subscriptionid":"0705076684","msisdn":"46705076684","categoryname":"Mobila talabonnemang","productsubcategory":"voice","mainagreementid":"78000311","agreementnumber":null,"commitmentstartdate":"2020-04-20","commitmentenddate":"20230420","commitmentlength":"36","subscriptiontypecategory":"VOICE","startdate":"20200429","offeringnameofferingcode":"98","offeringname":"Jobbmobil Obegränsad","customername":"Test 2, AB","last_used_model_by_imei":"Iphone X1","mobileservices":[{"servicevalue":"0","servicecode":"BND","attributes":[{"attributename":"CommitmentLength","attributevalue":"36"},{"attributename":"CommitmentStartDate","attributevalue":"20200420"},{"attributename":"CommitmentEndDate","attributevalue":"20220420"}]}]},{"customeridentificationnumber":"165590335476","subscriptionid":"0705076683","msisdn":"46705076683","categoryname":"Mobila talabonnemang","productsubcategory":"voice","mainagreementid":"78000311","agreementnumber":null,"commitmentstartdate":"2019-07-10","commitmentenddate":"20200710","commitmentlength":"12","subscriptiontypecategory":"VOICE","startdate":"20190710","offeringnameofferingcode":"91","offeringname":"Jobbmobil 1 GB Ram","customername":"Test 1, AB","last_used_model_by_imei":"Iphone X","mobileservices":[{"servicevalue":"1","servicecode":"BND","attributes":[{"attributename":"CommitmentLength","attributevalue":"12"},{"attributename":"CommitmentStartDate","attributevalue":"2019-07-10"},{"attributename":"CommitmentEndDate","attributevalue":"20200710"},{"attributename":"NextCommitmentEndDate","attributevalue":"20210710"}]}]},{"customeridentificationnumber":"165590335476","subscriptionid":"0705076682","msisdn":"46705076682","categoryname":"Mobila talabonnemang","productsubcategory":"voice","mainagreementid":"78000311","agreementnumber":null,"commitmentstartdate":"2019-06-11","commitmentenddate":"20200611","commitmentlength":"12","subscriptiontypecategory":"VOICE","startdate":"20190611","offeringnameofferingcode":"92","offeringname":"Jobbmobil 3 GB Ram","customername":"Test 7, AB","last_used_model_by_imei":"Iphone 7","mobileservices":[{"servicevalue":"1","servicecode":"BND","attributes":[{"attributename":"CommitmentLength","attributevalue":"12"},{"attributename":"CommitmentStartDate","attributevalue":"2019-06-11"},{"attributename":"CommitmentEndDate","attributevalue":"20200611"}]}]}]}},"errors":[],"dataPresent":true,"extensions":null},"BundleAndCart":{"BundleId":"oli1.Id","QuoteId":"qut.Id"}}';
            Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        	HardwareServices.invokeGetSubscriptionsIntegrationProcedure(acc.Id,inputMap);            
          	HardwareServices.invokeIntegrationProcedure('Hardware_GetSubscriptions',inputMap,inputMap,inputMap,inputMap);
        }
    }
    testMethod public static void getSubscriptionsPricestest(){
    	User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
                
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        	    
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.Name = 'Jobbmobil 15 GB';
        prod.TeliaSE_Subscription_Type__c = '99';
        insert prod;
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Jobbmobil 40 GB';
        prod1.TeliaSE_Subscription_Type__c = '98';
        insert prod1;
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        insert prod2;
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        insert prod3;
        		
		SubscriptionFilter__c sfilter = new SubscriptionFilter__c();
		sfilter.Name = prod.Name;
        insert sfilter;     
       	HardwareController hc = new HardwareController(); 	
       	System.runAs(new User(Id = Userinfo.getUserId())){
        	salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
        	salesManager.Bypass_VR__c = true;
        	insert salesManager;
        }
        System.runAs(salesManager){
            Opportunity opp = new Opportunity();
        	opp.Name='opp1';
        	opp.CloseDate = System.today();
        	opp.StageName='Kvalificera';  
        	opp.Pricebook2Id=Test.getStandardPricebookId();
        	opp.TeliaSE_SharingSetting_Flag__c = false;
       		insert opp;
            
			PricebookEntry objpricebookentry =new PricebookEntry();
         	objpricebookentry.Product2ID = prod.id;
         	objpricebookentry.Pricebook2ID = stdPriceBookRecId;
         	objpricebookentry.UnitPrice=23.50;
         	objpricebookentry.UseStandardPrice=false;
         	objpricebookentry.isActive=true;//Add this line
        	insert objpricebookentry;
                       
            Quote qut = new Quote();
        	qut.Name='Test Quote';
        	qut.status = 'Draft';  
        	qut.opportunityId = opp.id;
       	 	qut.Pricebook2ID = stdPriceBookRecId;
        	qut.TeliaSE_Approval_Flag__c = False;        
        	insert qut;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Subscription__c = prod1.Name;
            oli1.Product2Id = prod2.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.UnitPrice = 0;
        	oli1.Quantity = 1;
            insert oli1;
            
            String JsonResponse = '{'+
				'\"ContextId\": \"'+qut.Id+'\",'+
				'\"Subscription\": ['+
				'{'+
				'\"Price\": 345,'+
				'\"Name\": \"'+prod.Name+'\"'+
				'},'+
				'{'+
				'\"Price\": 395,'+
				'\"Name\": \"'+prod1.Name+'\"'+
				'}'+
				'],'+
				'\"EFS\": ['+
				'{'+
				'\"pricePlanFee\": \"30.0\",'+
				'\"Subscriptions\": \"99\"'+
				'},'+
				'{'+
				'\"pricePlanFee\": \"30.0\",'+
				'\"Subscriptions\": \"98\"'+
				'}'+
				']'+
				'}';
        	Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        	Map<String, Object> outMap = new Map<String, Object>();   
        	//EFSCheckCallOfQuote.getSubscriptionsPrices(inputMap,outMap);
            HardwareController hcontroller = new HardwareController();
            hcontroller.invokeMethod('UpdateEFSPrices',inputMap,outMap,outMap); 
        }
	}
}