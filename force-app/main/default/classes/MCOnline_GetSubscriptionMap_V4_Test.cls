@isTest
public class MCOnline_GetSubscriptionMap_V4_Test {
@testSetup
    static void initTestData() { 
               
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        Product2 prod2 = new Product2();
        Product2 prod3 = new Product2();
        Product2 prod4 = new Product2();
        Product2 prod5 = new Product2();
        Product2 prod6 = new Product2();
        Product2 prod7 = new Product2();
        Product2 prod8 = new Product2();

        Product2 prod9 = new Product2();
        Product2 prod10 = new Product2();
        Product2 prod11 = new Product2();
        Product2 prod12 = new Product2();
        Product2 prod13 = new Product2();
        Product2 prod14 = new Product2();

        Product2 prod15 = new Product2();
        Product2 prod16 = new Product2();
        Product2 prod17 = new Product2();
        Product2 prod18 = new Product2();
        Product2 prod19 = new Product2();
        Product2 prod20 = new Product2();
        Product2 prod21 = new Product2();
        Product2 prod22 = new Product2();
        Product2 prod23 = new Product2();
        Product2 prod24 = new Product2();
        Product2 prod25 = new Product2();
        Product2 prod26 = new Product2();
        Product2 prod27 = new Product2();
        Product2 prod28 = new Product2();

        prod1.ProductCode = 'TEST_OFFER1';
        prod1.Name = 'test_offer1';
        prod1.C2BC_Category__c = 'subscriptionbundle';
        prod1.C2BC_Subcategory__c = 'mobilevoicesubscription';
        prod1.IsActive =true;
        prod1.Family = 'Online Order';
        prodList.add(prod1);
        
        prod2.ProductCode = 'TEST_BUNDLE1';
        prod2.Name = 'test_bundle1';
        prod2.C2BC_Category__c = 'subscriptionbundle';
        prod2.C2BC_Subcategory__c = 'mobilevoicesubscription';
        prod2.IsActive =true;
        prod2.Family = 'Online Order';
        prodList.add(prod2);
        
        prod3.ProductCode = 'TEST_BUNDLE2';
        prod3.Name = 'test_bundle12';
        prod3.C2BC_Category__c = 'subscriptionbundle';
        prod3.C2BC_Subcategory__c = 'mobilevoicesubscription';
        prod3.IsActive =true;
        prod3.Family = 'Online Order';
        prodList.add(prod3);
        
    prod4.ProductCode = 'TEST_PROD1';
        prod4.Name = 'test_prod1';
        prod4.C2BC_Category__c = 'mobilevoicesubscription';
        prod4.C2BC_Subcategory__c = 'voice';
        prod4.TeliaSE_Subscription_Type__c = '55' ;
        prod4.IsActive =true;
        prod4.Family = 'Online Order';
        prodList.add(prod4);
        
        prod5.ProductCode = 'TEST_PROD2';
        prod5.Name = 'test_prod2';
        prod5.C2BC_Category__c = 'mobilevoicesubscription';
        prod5.C2BC_Subcategory__c = 'voice';
        prod5.TeliaSE_Subscription_Type__c = '45' ;
        prod5.IsActive =true;
        prod5.Family = 'Online Order';
        prodList.add(prod5);
        
        prod6.ProductCode = 'TEST_OFFER2';
        prod6.Name = 'test_offer2';
        prod6.C2BC_Category__c = 'subscriptionbundle';
        prod6.C2BC_Subcategory__c = 'mobilevoicesubscription';
        prod6.IsActive =true;
        prod6.Family = 'Online Order';
        prodList.add(prod6); 
        
        prod7.ProductCode = 'TEST_BUNDLE3';
        prod7.Name = 'test_bundle13';
        prod7.C2BC_Category__c = 'subscriptionbundle';
        prod7.C2BC_Subcategory__c = 'mobilebroadbandsubscription';
        prod7.IsActive =true;
        prod7.Family = 'Online Order';
        prodList.add(prod7);
        
        prod8.ProductCode = 'TEST_PROD3';
        prod8.Name = 'test_prod3';
        prod8.C2BC_Category__c = 'mobilebroadbandsubscription';
        prod8.C2BC_Subcategory__c = 'broadband';
        prod8.TeliaSE_Subscription_Type__c = '35' ;
        prod8.IsActive =true;
        prod8.Family = 'Online Order';
        prodList.add(prod8);

        prod9.ProductCode = 'Test_virtualOffer1' ;
        prod9.Name = 'test_virtualOffer1' ;
        prod9.C2BC_Category__c = 'offerbundle';
        prod9.C2BC_Subcategory__c  = 'mobilevoicesubscription';

        prod9.IsActive =true;
        prod9.Family = 'Online Order';
        prodList.add(prod9);
        
        prod10.ProductCode = 'Test_virtualOffer2' ;
        prod10.Name = 'test_virtualOffer2' ;
        prod10.C2BC_Category__c = 'offerbundle';

        prod10.C2BC_Subcategory__c  = 'mobilevoicesubscription';

        prod10.IsActive =true;
        prod10.Family = 'Online Order';
        prodList.add(prod10);

        prod11.ProductCode = 'TEST_OFFER3';
        prod11.Name = 'test_offer3';
        prod11.C2BC_Category__c = 'addonbundle';
        prod11.C2BC_Subcategory__c = 'mobilevoicesubscription';
        prod11.IsActive =true;
        prod11.Family = 'Online Order';
        prodList.add(prod11);
        
        prod12.ProductCode = 'TEST_OFFER4';
        prod12.Name = 'test_offer4';
        prod12.C2BC_Category__c = 'addonbundle';
        prod12.C2BC_Subcategory__c = 'mobilevoicesubscription';
        prod12.IsActive =true;
        prod12.Family = 'Online Order';
        prodList.add(prod12);
        
        prod13.ProductCode = 'TEST_PROD4';
        prod13.Name = 'test_prod4';
        prod13.C2BC_Category__c = 'mobilebroadbandsubscription';
        prod13.C2BC_Subcategory__c = 'datasim';
        prod13.TeliaSE_Subscription_Type__c = 'R1' ;
        prod13.IsActive =true;
        prod13.Family = 'Online Order';
        prodList.add(prod13);
        
        prod14.ProductCode = 'TEST_PROD5';
        prod14.Name = 'test_prod5';
        prod14.C2BC_Category__c = 'mobilevoicesubscription';
        prod14.C2BC_Subcategory__c = 'mdsecondary';
        prod14.TeliaSE_Subscription_Type__c = 'AR9' ;
        prod14.IsActive =true;
        prod14.Family = 'Online Order';
        prodList.add(prod14);

        prod15.ProductCode = 'Test_TpVirtualOffer';
        prod15.Name = 'test_TpVirtualOffer';
        prod15.C2BC_Category__c = 'offerbundle';

        prod15.C2BC_Subcategory__c ='touchpoint';

        prod15.IsActive =true;
        prod15.Family = 'Online Order';
        prodList.add(prod15);
        
        prod16.ProductCode = 'TEST_TPOFFER1';
        prod16.Name = 'test_TpOffer1';
        prod16.C2BC_Category__c = 'subscriptionbundle';
        prod16.C2BC_Subcategory__c = 'ucsswitchboards';
        prod16.IsActive =true;
        prod16.Family = 'Online Order';
        prodList.add(prod16);
        
        prod17.ProductCode = 'TEST_TPOFFER2';
        prod17.Name = 'test_TpOffer2';
        prod17.C2BC_Category__c = 'addonbundle';
        prod17.C2BC_Subcategory__c = 'mobilevoicesubscription';
        prod17.IsActive =true;
        prod17.Family = 'Online Order';
        prodList.add(prod17);
        
        prod18.ProductCode = 'TEST_TPBUNDLE1';
        prod18.Name = 'test_Tpbundle1';
        prod18.C2BC_Category__c = 'addonbundle';
        prod18.C2BC_Subcategory__c = 'ucsswitchboards';
        prod18.IsActive =true;
        prod18.Family = 'Online Order';
        prodList.add(prod18);
        
        prod19.ProductCode = 'TEST_TPBUNDLE2';
        prod19.Name = 'test_Tpbundle2';
        prod19.C2BC_Category__c = 'addonbundle';
        prod19.C2BC_Subcategory__c = 'ucsswitchboards';
        prod19.IsActive =true;
        prod19.Family = 'Online Order';
        prodList.add(prod19);
        
        prod20.ProductCode = 'TEST_TPprod1';
        prod20.Name = 'test_TPprod1';
        prod20.C2BC_Category__c = 'ucsswitchboards';
        prod20.IsActive =true;
        prod20.Family = 'Online Order';
        prodList.add(prod20);
        
        prod21.ProductCode = 'TEST_TPprod2';
        prod21.Name = 'test_TPprod2';
        prod21.C2BC_Category__c = 'ucsswitchboards';
        prod21.C2BC_Subcategory__c = 'ucinstance';
        prod21.IsActive =true;
        prod21.Family = 'Online Order';
        prodList.add(prod21);
        
        prod22.ProductCode = 'TEST_TPprod3';
        prod22.Name = 'test_TPprod3';
        prod22.C2BC_Category__c = 'ucsswitchboards';
        prod22.IsActive =true;
        prod22.Family = 'Online Order';
        prodList.add(prod22);
        
        prod23.ProductCode = 'TEST_TPprod4';
        prod23.Name = 'test_TPprod4';
        prod23.C2BC_Category__c = 'switchboardextension';
        prod23.C2BC_Subcategory__c = 'fixednumber';
        prod23.IsActive =true;
        prod23.Family = 'Online Order';
        prodList.add(prod23);
        
        prod24.ProductCode = 'TEST_TPprod5';
        prod24.Name = 'test_TPprod5';
        prod24.C2BC_Category__c = 'switchboardextension';
        prod24.C2BC_Subcategory__c = 'ucuser';
        prod24.IsActive =true;
        prod24.Family = 'Online Order';
        prodList.add(prod24);
        
        prod25.ProductCode = 'TEST_TPBUNDLE3';
        prod25.Name = 'test_Tpbundle3';
        prod25.C2BC_Category__c = 'addonbundle';
        prod25.C2BC_Subcategory__c = 'switchboardextension';
        prod25.IsActive =true;
        prod25.Family = 'Online Order';
        prodList.add(prod25);
        
        prod26.ProductCode = 'TEST_TPBUNDLE4';
        prod26.Name = 'test_Tpbundle4';
        prod26.C2BC_Category__c = 'addonbundle';
        prod26.C2BC_Subcategory__c = 'switchboardextension';
        prod26.IsActive =true;
        prod26.Family = 'Online Order';
        prodList.add(prod26);
        
        prod27.ProductCode = 'TEST_TPprod6';
        prod27.Name = 'test_TPprod6';
        prod27.C2BC_Category__c = 'switchboardextension';
        prod27.IsActive =true;
        prod27.Family = 'Online Order';
        prodList.add(prod27);
        
        prod28.ProductCode = 'TEST_TPprod7';
        prod28.Name = 'test_TPprod7';
        prod28.C2BC_Category__c = 'switchboardextension';
        prod28.C2BC_Subcategory__c = 'autofulfilment';
        prod28.IsActive =true;
        prod28.Family = 'Online Order';
        prodList.add(prod28);
        
        insert prodList;

        List<vlocity_cmt__ProductChildItem__c> childProdList = new List<vlocity_cmt__ProductChildItem__c>();
        vlocity_cmt__ProductChildItem__c child1 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child2 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child3 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child4 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child5 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child6 = new vlocity_cmt__ProductChildItem__c();

        vlocity_cmt__ProductChildItem__c child7 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child8 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child9 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child10 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child11 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child12 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child13 = new vlocity_cmt__ProductChildItem__c(); 
        vlocity_cmt__ProductChildItem__c child14 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child15 = new vlocity_cmt__ProductChildItem__c(); 

        vlocity_cmt__ProductChildItem__c child16 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child17 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child18 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child19 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child20 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child21 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child22 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child23 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child24 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child25 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child26 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child27 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child28 = new vlocity_cmt__ProductChildItem__c();

        child1.vlocity_cmt__ChildProductId__c = prodList.get(1).id;
        child1.vlocity_cmt__ParentProductId__c = prodList.get(0).id;
        child1.vlocity_cmt__ChildLineNumber__c ='1';

        childProdList.add(child1);
        
        child2.vlocity_cmt__ChildProductId__c = prodList.get(2).id;
        child2.vlocity_cmt__ParentProductId__c = prodList.get(0).id;
        child2.vlocity_cmt__ChildLineNumber__c ='2';
        childProdList.add(child2);
        
        child3.vlocity_cmt__ChildProductId__c = prodList.get(3).id;
        child3.vlocity_cmt__ParentProductId__c = prodList.get(1).id;
        child3.vlocity_cmt__ChildLineNumber__c ='3';
        childProdList.add(child3);
        
        child4.vlocity_cmt__ChildProductId__c = prodList.get(4).id;
        child4.vlocity_cmt__ParentProductId__c = prodList.get(2).id;
        child4.vlocity_cmt__ChildLineNumber__c ='4';
        childProdList.add(child4);
        
        child5.vlocity_cmt__ChildProductId__c = prodList.get(6).id;
        child5.vlocity_cmt__ParentProductId__c = prodList.get(5).id;
        child5.vlocity_cmt__ChildLineNumber__c ='5';
        childProdList.add(child5);
        
        child6.vlocity_cmt__ChildProductId__c = prodList.get(7).id;
        child6.vlocity_cmt__ParentProductId__c = prodList.get(6).id;
        child6.vlocity_cmt__ChildLineNumber__c ='6';
        childProdList.add(child6);

        child7.vlocity_cmt__ChildProductId__c = prodList.get(0).id;
        child7.vlocity_cmt__ParentProductId__c = prodList.get(8).id;
        child7.vlocity_cmt__ChildLineNumber__c ='9';
        childProdList.add(child7);
        
        child8.vlocity_cmt__ChildProductId__c = prodList.get(12).id;
        child8.vlocity_cmt__ParentProductId__c = prodList.get(10).id;
        child8.vlocity_cmt__ChildLineNumber__c ='10';
        childProdList.add(child8);
        
        child9.vlocity_cmt__ChildProductId__c = prodList.get(13).id;
        child9.vlocity_cmt__ParentProductId__c = prodList.get(10).id;
        child9.vlocity_cmt__ChildLineNumber__c ='11';
        childProdList.add(child9);
        
        child10.vlocity_cmt__ChildProductId__c = prodList.get(12).id;
        child10.vlocity_cmt__ParentProductId__c = prodList.get(11).id;
        child10.vlocity_cmt__ChildLineNumber__c ='12';
        childProdList.add(child10);
        
        child11.vlocity_cmt__ChildProductId__c = prodList.get(13).id;
        child11.vlocity_cmt__ParentProductId__c = prodList.get(11).id;
        child11.vlocity_cmt__ChildLineNumber__c ='13';
        childProdList.add(child11);
        
        child12.vlocity_cmt__ChildProductId__c = prodList.get(10).id;
        child12.vlocity_cmt__ParentProductId__c = prodList.get(8).id;
        child12.vlocity_cmt__ChildLineNumber__c ='14';
        childProdList.add(child12);
        
        child13.vlocity_cmt__ChildProductId__c = prodList.get(10).id;
        child13.vlocity_cmt__ParentProductId__c = prodList.get(9).id;
        child13.vlocity_cmt__ChildLineNumber__c ='15';
        childProdList.add(child13);

        child16.vlocity_cmt__ChildProductId__c = prodList.get(19).id;
        child16.vlocity_cmt__ParentProductId__c = prodList.get(17).id;
        child16.vlocity_cmt__ChildLineNumber__c ='16';
        childProdList.add(child16);
        
        child17.vlocity_cmt__ChildProductId__c = prodList.get(20).id;
        child17.vlocity_cmt__ParentProductId__c = prodList.get(17).id;
        child17.vlocity_cmt__ChildLineNumber__c ='17';
        childProdList.add(child17);
        
        child18.vlocity_cmt__ChildProductId__c = prodList.get(21).id;
        child18.vlocity_cmt__ParentProductId__c = prodList.get(18).id;
        child18.vlocity_cmt__ChildLineNumber__c ='18';
        childProdList.add(child18);
        
        child19.vlocity_cmt__ChildProductId__c = prodList.get(27).id;
        child19.vlocity_cmt__ParentProductId__c = prodList.get(25).id;
        child19.vlocity_cmt__ChildLineNumber__c ='19';
        childProdList.add(child19);
        
        child20.vlocity_cmt__ChildProductId__c = prodList.get(26).id;
        child20.vlocity_cmt__ParentProductId__c = prodList.get(24).id;
        child20.vlocity_cmt__ChildLineNumber__c ='20';
        childProdList.add(child20);
        
        child21.vlocity_cmt__ChildProductId__c = prodList.get(25).id;
        child21.vlocity_cmt__ParentProductId__c = prodList.get(16).id;
        child21.vlocity_cmt__ChildLineNumber__c ='21';
        childProdList.add(child21);
        
        child22.vlocity_cmt__ChildProductId__c = prodList.get(22).id;
        child22.vlocity_cmt__ParentProductId__c = prodList.get(16).id;
        child22.vlocity_cmt__ChildLineNumber__c ='22';
        childProdList.add(child22);
        
        child23.vlocity_cmt__ChildProductId__c = prodList.get(23).id;
        child23.vlocity_cmt__ParentProductId__c = prodList.get(16).id;
        child23.vlocity_cmt__ChildLineNumber__c ='23';
        childProdList.add(child23);
        
        child24.vlocity_cmt__ChildProductId__c = prodList.get(24).id;
        child24.vlocity_cmt__ParentProductId__c = prodList.get(16).id;
        child24.vlocity_cmt__ChildLineNumber__c ='24';
        childProdList.add(child24);
        
        child25.vlocity_cmt__ChildProductId__c = prodList.get(17).id;
        child25.vlocity_cmt__ParentProductId__c = prodList.get(15).id;
        child25.vlocity_cmt__ChildLineNumber__c ='25';
        childProdList.add(child25);
        
        child26.vlocity_cmt__ChildProductId__c = prodList.get(18).id;
        child26.vlocity_cmt__ParentProductId__c = prodList.get(15).id;
        child26.vlocity_cmt__ChildLineNumber__c ='26';
        childProdList.add(child26);
        
        child27.vlocity_cmt__ChildProductId__c = prodList.get(15).id;
        child27.vlocity_cmt__ParentProductId__c = prodList.get(14).id;
        child27.vlocity_cmt__ChildLineNumber__c ='27';
        childProdList.add(child27);
        
        child28.vlocity_cmt__ChildProductId__c = prodList.get(16).id;
        child28.vlocity_cmt__ParentProductId__c = prodList.get(14).id;
        child28.vlocity_cmt__ChildLineNumber__c ='28';
        childProdList.add(child28);

        Insert childProdList;
        
        vlocity_cmt__Catalog__c cat = new vlocity_cmt__Catalog__c();
        cat.Name = 'SUBSCRIPTIONS';
        insert cat;
        
        List<vlocity_cmt__CatalogProductRelationship__c> catalogProductList = new List<vlocity_cmt__CatalogProductRelationship__c>();
        vlocity_cmt__CatalogProductRelationship__c catalogProduct1 = new vlocity_cmt__CatalogProductRelationship__c();
        catalogProduct1.Name = 'Test_virtualOffer1' ;
        catalogProduct1.vlocity_cmt__CatalogId__c = cat.id;
        catalogProduct1.vlocity_cmt__Product2Id__c = prodList.get(8).id;
        catalogProductList.add(catalogProduct1);
        
        vlocity_cmt__CatalogProductRelationship__c catalogProduct2 = new vlocity_cmt__CatalogProductRelationship__c();
        catalogProduct2.Name = 'Test_virtualOffer2' ;
        catalogProduct2.vlocity_cmt__CatalogId__c = cat.id;
        catalogProduct2.vlocity_cmt__Product2Id__c = prodList.get(9).id;
        catalogProductList.add(catalogProduct2);
 
        vlocity_cmt__CatalogProductRelationship__c catalogProduct3 = new vlocity_cmt__CatalogProductRelationship__c();
        catalogProduct3.Name = 'Test_TpVirtualOffer' ;
        catalogProduct3.vlocity_cmt__CatalogId__c = cat.id;
        catalogProduct3.vlocity_cmt__Product2Id__c = prodList.get(14).id;
        catalogProductList.add(catalogProduct3);
        
        insert catalogProductList;
    }
    
    @istest
    static  void subscriptionMappingTest() {
      Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();

        MCOnline_GetSubscriptionMap_V4 getSub = new MCOnline_GetSubscriptionMap_V4();
        getSub.invokeMethod('getSubscriptionCatalog', input, output, options);
      system.assertEquals(true, output.get('success'));

    }
}