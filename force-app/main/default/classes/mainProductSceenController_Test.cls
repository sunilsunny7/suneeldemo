/**
 * Created by kwn687 on 2022-09-09.
 */
@isTest
public with sharing class mainProductSceenController_Test {
    @isTest
    static void mainProductInsertTest() {
        mainProductSceenController.productWrapper wrapper = new mainProductSceenController.productWrapper();
        wrapper.mainProduct = 'Cygate Hybrid IT';
        wrapper.cygateProduct = 'Consulting';
        wrapper.supplier = 'Annan';
        wrapper.cygateTG = 1;
        wrapper.contractPeriod = 1;
        List<mainProductSceenController.productWrapper> allProducts = new List<mainProductSceenController.productWrapper>();
        allProducts.add(wrapper);
        User sallerUsr;
        Account acc;
        Seller__c seller;
        Opportunity opp;
        Product2 prod;
        Pricebook2 cygatePriceBook;
        System.runAs(Test_DataFactory.getByPassUser()) {
            sallerUsr = Test_DataFactory.createCygateUser();
            insert sallerUsr;
            seller = Test_DataFactory.createSeller(sallerUsr.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = sallerUsr.Id;
            insert acc;
            prod = new Product2(Name = 'Cygate Hybrid IT - Consulting', IsActive = true, productcode = 'CG');
            insert prod;
            Id pbId = Test.getStandardPricebookId();
            PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, prod);
            insert pbe;
            cygatePriceBook = new Pricebook2(Name = 'Cygate Price Book', Developer_Name__c = SEUtility.PRICEBOOK_CYGATE, isActive = true);
            insert cygatePriceBook;
            PriceBookEntry pbeCygate = Test_DataFactory.createPricebookEntry(cygatePriceBook.Id, prod);
            insert pbeCygate;
        }
        Test.StartTest();
        System.runAs(sallerUsr) {
            opp = Test_DataFactory.createSmeOpportunity();
            opp.accountId = acc.id;
            opp.Pricebook2Id = cygatePriceBook.Id;
            insert opp;
            mainProductSceenController.insertProducts(allProducts, opp.id);
        }
        Test.StopTest();
        OpportunityLineItem oppLineItem = [SELECT Id, product2.name FROM OpportunityLineItem WHERE OpportunityId = :opp.Id LIMIT 1];
        system.assertEquals('Cygate Hybrid IT - Consulting', oppLineItem.product2.name, 'Wrong product was added');

    }
}