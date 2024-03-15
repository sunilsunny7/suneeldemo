@isTest
public class Test_TeliaSE_SingleCart_CoOfferCreation {
    @isTest
    public static void testprepareRequest(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            test.startTest();
            String jsonString = '{"ProductGroupQuantity":[{"IsRoot":1,"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","ImParentProduct":"","LineNumber":"0001","SequenceNumber":1,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I310sQAB","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Telia Bredband Start"," ProductCode":"CO-BBSTART","ProductObjectType":"Broadband Start Offering Spec","OfferType":"AgreementOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":0,"Product2Id":"01t5E000006tNODQA2","Id":"0QL5E000000kKq4WAE","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC","Groups":[{"GroupId":"a895E000000fyzWQAQ","GroupName":"grp 1","Quantity":""},{"GroupId":"a895E000000fyzXQAQ","GroupName":"grp2","Quantity":""}]},{"IsStand":1,"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0001.0003","SequenceNumber":1,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":599,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tNCUQA2","ImParentProduct":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I30x7QAB","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":2,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Bredband Start 10 Mbit/s"," ProductCode":"CO-BBSTART-10MB","ProductObjectType":"Broadband Start Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":1,"Product2Id":"01t5E000006tNCUQA2","Id":"0QL5E000000kKqjWAE","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC","Groups":[{"GroupId":"a895E000000fyzWQAQ","GroupName":"grp 1","Quantity":2},{"GroupId":"a895E000000fyzXQAQ","GroupName":"grp2","Quantity":""}]},{"IsStand":1,"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0001.0004","SequenceNumber":2,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":649,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tNE5QAM","ImParentProduct":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I30y7QAB","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":3,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Bredband Start 30 Mbit/s"," ProductCode":"CO-BBSTART-30MB","ProductObjectType":"Broadband Start Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":1,"Product2Id":"01t5E000006tNE5QAM","Id":"0QL5E000000kKqoWAE","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC","Groups":[{"GroupId":"a895E000000fyzWQAQ","GroupName":"grp 1","Quantity":1},{"GroupId":"a895E000000fyzXQAQ","GroupName":"grp2","Quantity":2}]},{"IsSub":1,"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0001.0001","SequenceNumber":8,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tNFlQAM","ImParentProduct":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I30ywQAB","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Installation och Övriga Tillval"," ProductCode":"CO-BBSTART-OTHER","ProductObjectType":"Broadband Start Offering Spec","OfferType":"Non-SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":1,"Product2Id":"01t5E000006tNFlQAM","Id":"0QL5E000000kKq5WAE","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC","Groups":[{"GroupId":"a895E000000fyzWQAQ","GroupName":"grp 1","Quantity":""},{"GroupId":"a895E000000fyzXQAQ","GroupName":"grp2","Quantity":""}]},{"InFlag":1,"IsLeaf":1,"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","OfferType":"","LineNumber":"0001.0001.0001","SequenceNumber":9,"TargetPercentage":0,"OneTimePrice":1600,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tNFlQAM<01t5E000006tNEDQA2","ImParentProduct":"01t5E000006tNFlQAM","PriceBookEntryId":"01u5E00000I30yFQAR","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":4,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Lokal-ID sök"," ProductCode":"CO-BBSTART-ID-SOK","ProductObjectType":"Broadband Start Offering Spec","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":2,"Product2Id":"01t5E000006tNEDQA2","Id":"0QL5E000000kLLsWAM","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC","Groups":[{"GroupId":"a895E000000fyzWQAQ","GroupName":"grp 1","Quantity":2},{"GroupId":"a895E000000fyzXQAQ","GroupName":"grp2","Quantity":2}]},{"IsRoot":1,"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","ImParentProduct":"","LineNumber":"0002","SequenceNumber":1,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNOOQA2","PriceBookEntryId":"01u5E00000I310xQAB","ParentItemId":"01t5E000006tNOOQA2","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNOOQA2","Product2Name":"Telia Bredband Pro"," ProductCode":"CO-BBPRO","ProductObjectType":"Broadband Pro Offering Spec","OfferType":"AgreementOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Pro","Level":0,"Product2Id":"01t5E000006tNOOQA2","Id":"0QL5E000000kKqTWAU","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC","Groups":[{"GroupId":"a895E000000fyzWQAQ","GroupName":"grp 1","Quantity":""},{"GroupId":"a895E000000fyzXQAQ","GroupName":"grp2","Quantity":""}]},{"IsStand":1,"ApprovedPercentage":"","RequestedPercentage":"","campaignId":"","LineNumber":"0002.0006","SequenceNumber":1,"TargetPercentage":5,"ApprovedPrice":4345,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":4350,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNOOQA2<01t5E000006tNH0QAM","ImParentProduct":"01t5E000006tNOOQA2","PriceBookEntryId":"01u5E00000I30zSQAR","ParentItemId":"01t5E000006tNOOQA2","FACallOffQuantity":12,"ProductHierarchyPath":"01t5E000006tNOOQA2","Product2Name":"Bredband Pro 100 Mbit/s"," ProductCode":"CO-BBPRO-100MB","ProductObjectType":"Broadband Pro Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Pro","Level":1,"Product2Id":"01t5E000006tNH0QAM","Id":"0QL5E000000kKqeWAE","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC","Groups":[{"GroupId":"a895E000000fyzWQAQ","GroupName":"grp 1","Quantity":12},{"GroupId":"a895E000000fyzXQAQ","GroupName":"grp2","Quantity":""}]}]}';
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<String,Object> outputMap = new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            System.debug('Jsonout'+Json.serialize(inputMap));
            TeliaSE_SingleCart_CoOfferCreation prepReq = new TeliaSE_SingleCart_CoOfferCreation();
            prepReq.invokeMethod('prepareRequestAddtoCart', inputMap,outputMap,options);
            test.stopTest();
        }
    }
    @isTest
    public static void testgetGroups(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            test.startTest();
            String jsonString = '{"DRE1":{"AccountExtracts":[{"ServicePoints":[{"ServicePointId":"a6K5E000000V2YNUA0"}],"PremiseId":"a5f5E000000Id6DQAS","StreetAddress":"Stjärntorget","PostalCode":"16979","City":"solna","SiteName":"a5f5E000000Id6D"},{"ServicePoints":[{"ServicePointId":"a6K5E000000V3lgUAC"}],"PremiseId":"a5f5E000000Id8JQAS","StreetAddress":"Stjärntorget","PostalCode":"16979","City":"solna","SiteName":"a5f5E000000Id8J"},{"ServicePoints":[{"ServicePointId":"a6K5E000000V7IUUA0"}],"PremiseId":"a5f5E000000IdqjQAC","StreetAddress":"Stjärntorget","PostalCode":"16979","City":"solna","SiteName":"a5f5E000000Idqj"},{"ServicePoints":[{"ServicePointId":"a6K5E000000V8SwUAK"}],"PremiseId":"a5f5E000000IeWEQA0","StreetNumber":"11","StreetAddress":"Diktarvägen","PostalCode":"17169","City":"solna","SiteName":"a5f5E000000IeWE"}],"Grouped":[{"StreetNumber":"11","QuoteMemberId":"a965E00000050eLQAQ","GroupName":"grp1","GroupId":"a895E000000fyjWQAQ","City":"solna","StreetAddress":"Diktarvägen","PostalCode":"17169","SiteName":"a5f5E000000IeWE","ServicePointId":"a6K5E000000V8SwUAK"},{"QuoteMemberId":"a965E00000050eMQAQ","GroupName":"grp1","GroupId":"a895E000000fyjWQAQ","City":"solna","StreetAddress":"Stjärntorget","PostalCode":"16979","SiteName":"a5f5E000000Idqj","ServicePointId":"a6K5E000000V7IUUA0"},{"QuoteMemberId":"a965E00000050eOQAQ","GroupName":"grp1","GroupId":"a895E000000fyjWQAQ","City":"solna","StreetAddress":"Stjärntorget","PostalCode":"16979","SiteName":"a5f5E000000Id8J","ServicePointId":"a6K5E000000V3lgUAC"},{"QuoteMemberId":"a965E00000050ePQAQ","GroupName":"grp1","GroupId":"a895E000000fyjWQAQ","City":"solna","StreetAddress":"Stjärntorget","PostalCode":"16979","SiteName":"a5f5E000000Id6D","ServicePointId":"a6K5E000000V2YNUA0"}],"AccountId":"0013E00001CnejOQAR"}}';
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<String,Object> outputMap = new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            TeliaSE_SingleCart_CoOfferCreation prepReq = new TeliaSE_SingleCart_CoOfferCreation();
            prepReq.invokeMethod('getGroups', inputMap,outputMap,options);
            test.stopTest();
        }
    }
    @isTest
    public static void testPremiseLineItems(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            test.startTest();
            String jsonString = '{"DR_ExtAct_getInstallationProductDetails":{"InstallationProduct":{"PriceBookEntryId":"01u5E00000I30yNQAR","Id":"01t5E000006tNEbQAM"}},"UpdatedPremiseData":[{"Input":{"heraNumber":"213","rc":323,"otc":213},"S_name":"4-148573012","P_Name":"a5f5E000000IeVp","P_streetName":"Stjärntorget","P_city":"solna","P_postalcode":"16979","ServicePointId":"a6K5E000000V8P3UAK","P_gatenumber":"","P_streetnumber":"","QuoteMemberId":"","QuoteGroupId":""},{"Input":{"heraNumber":"23","rc":32,"otc":1},"S_name":"5-B-148573013","P_Name":"a5f5E000000IeVp","P_streetName":"Stjärntorget","P_city":"solna","P_postalcode":"16979","ServicePointId":"a6K5E000000V8P4UAK","P_gatenumber":"","P_streetnumber":"","QuoteMemberId":"","QuoteGroupId":""},{"Input":{"heraNumber":"","rc":"","otc":""},"S_name":"145092811","P_Name":"a5f5E000000IfF2","P_streetName":"Stjärntorget","P_city":"solna","P_postalcode":"16979","ServicePointId":"a6K5E000000VBcSUAW","P_gatenumber":"","P_streetnumber":"","QuoteMemberId":"","QuoteGroupId":""},{"Input":{"heraNumber":"","rc":"","otc":""},"S_name":"1-145661978","P_Name":"a5f5E000000IfF2","P_streetName":"Stjärntorget","P_city":"solna","P_postalcode":"16979","ServicePointId":"a6K5E000000VBcTUAW","P_gatenumber":"","P_streetnumber":"","QuoteMemberId":"","QuoteGroupId":""},{"Input":{"heraNumber":"","rc":"","otc":""},"S_name":"1-B-145661977","P_Name":"a5f5E000000IfF2","P_streetName":"Stjärntorget","P_city":"solna","P_postalcode":"16979","ServicePointId":"a6K5E000000VBcUUAW","P_gatenumber":"","P_streetnumber":"","QuoteMemberId":"","QuoteGroupId":""},{"Input":{"heraNumber":"","rc":"","otc":""},"S_name":"1-C-158469563","P_Name":"a5f5E000000IfF2","P_streetName":"Stjärntorget","P_city":"solna","P_postalcode":"16979","ServicePointId":"a6K5E000000VBcVUAW","P_gatenumber":"","P_streetnumber":"","QuoteMemberId":"","QuoteGroupId":""},{"Input":{"heraNumber":"","rc":"","otc":""},"S_name":"1-D-158469564","P_Name":"a5f5E000000IfF2","P_streetName":"Stjärntorget","P_city":"solna","P_postalcode":"16979","ServicePointId":"a6K5E000000VBcWUAW","P_gatenumber":"","P_streetnumber":"","QuoteMemberId":"","QuoteGroupId":""}],"OfferCartId":"0Q05E000001BxAjSAK"}';
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<String,Object> outputMap = new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            System.debug('Jsonout'+Json.serialize(inputMap));
            TeliaSE_SingleCart_CoOfferCreation prepReq = new TeliaSE_SingleCart_CoOfferCreation();
            prepReq.invokeMethod('AddPremiseLineItems', inputMap,outputMap,options);
            test.stopTest();
        }
    }
    @isTest
    public static void testPdtReorder(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            test.startTest();
            String jsonString = '{"DataRaptorExtractAction1":{"QuoteLineItem ":[{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","ImParentProduct":"","LineNumber":"0001","SequenceNumber":1,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I310sQAB","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Telia Bredband Start"," ProductCode":"CO-BBSTART","ProductObjectType":"Broadband Start Offering Spec","OfferType":"AgreementOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":0,"Product2Id":"01t5E000006tNODQA2","Id":"0QL5E000000ki94WAA","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","ImParentProduct":"","LineNumber":"0002","SequenceNumber":1,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I310jQAB","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Telia Datanet"," ProductCode":"CO-DATANET","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"AgreementOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":0,"Product2Id":"01t5E000006tNNuQAM","Id":"0QL5E000000kjIoWAI","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0001.0002","SequenceNumber":1,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":599,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tNCUQA2","ImParentProduct":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I30x7QAB","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":2,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Bredband Start 10 Mbit/s"," ProductCode":"CO-BBSTART-10MB","ProductObjectType":"Broadband Start Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":1,"Product2Id":"01t5E000006tNCUQA2","Id":"0QL5E000000ki99WAA","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0001.0004","SequenceNumber":2,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":649,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tNE5QAM","ImParentProduct":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I30y7QAB","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":4,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Bredband Start 30 Mbit/s"," ProductCode":"CO-BBSTART-30MB","ProductObjectType":"Broadband Start Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":1,"Product2Id":"01t5E000006tNE5QAM","Id":"0QL5E000000ki9EWAQ","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0001.0006","SequenceNumber":3,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":699,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tND2QAM","ImParentProduct":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I30xPQAR","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":1,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Bredband Start 60 Mbit/s"," ProductCode":"CO-BBSTART-60MB","ProductObjectType":"Broadband Start Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":1,"Product2Id":"01t5E000006tND2QAM","Id":"0QL5E000000kiLAWAY","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0001.0007","SequenceNumber":4,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":799,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tNCcQAM","ImParentProduct":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I30xFQAR","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":1,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Bredband Start 100 Mbit/s"," ProductCode":"CO-BBSTART-100MB","ProductObjectType":"Broadband Start Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":1,"Product2Id":"01t5E000006tNCcQAM","Id":"0QL5E000000kiLXWAY","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0001.0001","SequenceNumber":8,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tNFlQAM","ImParentProduct":"01t5E000006tNODQA2","PriceBookEntryId":"01u5E00000I30ywQAB","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Installation och Övriga Tillval"," ProductCode":"CO-BBSTART-OTHER","ProductObjectType":"Broadband Start Offering Spec","OfferType":"Non-SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":1,"Product2Id":"01t5E000006tNFlQAM","Id":"0QL5E000000ki95WAA","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","OfferType":"","LineNumber":"0001.0001.0001","SequenceNumber":9,"TargetPercentage":0,"OneTimePrice":1600,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNODQA2<01t5E000006tNFlQAM<01t5E000006tNEDQA2","ImParentProduct":"01t5E000006tNFlQAM","PriceBookEntryId":"01u5E00000I30yFQAR","ParentItemId":"01t5E000006tNODQA2","FACallOffQuantity":2,"ProductHierarchyPath":"01t5E000006tNODQA2","Product2Name":"Lokal-ID sök"," ProductCode":"CO-BBSTART-ID-SOK","ProductObjectType":"Broadband Start Offering Spec","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Bredband Start","Level":2,"Product2Id":"01t5E000006tNEDQA2","Id":"0QL5E000000ki9JWAQ","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0007","SequenceNumber":1,"TargetPercentage":4,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":3400,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNCiQAM","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I30xLQAR","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":2,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Access Multi 10 Mbit/s"," ProductCode":"CO-DATANET-ACCESS-MULTI-10MB","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNCiQAM","Id":"0QL5E000000klulWAA","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0008","SequenceNumber":2,"TargetPercentage":5,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":4000,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNDkQAM","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I30xrQAB","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":2,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Access Multi 100 Mbit/s"," ProductCode":"CO-DATANET-ACCESS-MULTI-100MB","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNDkQAM","Id":"0QL5E000000kluvWAA","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0010","SequenceNumber":3,"TargetPercentage":5,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":5000,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNEBQA2","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I30yDQAR","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":1,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Access Multi 200 Mbit/s"," ProductCode":"CO-DATANET-ACCESS-MULTI-200MB","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNEBQA2","Id":"0QL5E000000klvAWAQ","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0012","SequenceNumber":4,"TargetPercentage":5,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":6000,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNCQQA2","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I30x3QAB","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Access Multi 300 Mbit/s"," ProductCode":"CO-DATANET-ACCESS-MULTI-300MB","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNCQQA2","Id":"0QL5E000000kmw2WAA","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0013","SequenceNumber":5,"TargetPercentage":5,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":7000,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNDdQAM","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I30xkQAB","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Access Multi 500 Mbit/s"," ProductCode":"CO-DATANET-ACCESS-MULTI-500MB","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNDdQAM","Id":"0QL5E000000kmwCWAQ","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0001","SequenceNumber":15,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNI9QAM","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I30zsQAB","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Tillval Backup"," ProductCode":"CO-DATANET-TILLVAL-BACKUP","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"Non-SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNI9QAM","Id":"0QL5E000000kjIpWAI","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0002","SequenceNumber":16,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNJ9QAM","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I310MQAR","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Tillval Sekundär Access"," ProductCode":"CO-DATANET-SEKUNDAR","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"Non-SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNJ9QAM","Id":"0QL5E000000kjIqWAI","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0003","SequenceNumber":17,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNFFQA2","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I30ylQAB","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Tillval Utökad SLA"," ProductCode":"CO-DATANET-ENHANCED-SLA","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"Non-SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNFFQA2","Id":"0QL5E000000kjIrWAI","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0004","SequenceNumber":18,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNFAQA2","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I30ygQAB","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Tillval Service Center Connection (SCC)"," ProductCode":"CO-DATANET-SSC","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"Non-SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNFAQA2","Id":"0QL5E000000kjIsWAI","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0005","SequenceNumber":19,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNGzQAM","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000I30zRQAR","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Installation och Övriga Tillval"," ProductCode":"CO-DATANET-OTHER","ProductObjectType":"Broadband Datanet Offering Spec","OfferType":"Non-SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000006tNGzQAM","Id":"0QL5E000000kjItWAI","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0006","SequenceNumber":20,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000007HuoRQAS","ImParentProduct":"01t5E000006tNNuQAM","PriceBookEntryId":"01u5E00000NTNgzQAH","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Binding time Startavgiften"," ProductCode":"CO-DATANET-BIND","ProductObjectType":"Binding OTC Offering Spec","OfferType":"Non-SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":1,"Product2Id":"01t5E000007HuoRQAS","Id":"0QL5E000000kjIvWAI","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","OfferType":"","LineNumber":"0002.0001.0001","SequenceNumber":5,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":900,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNI9QAM<01t5E000006tNChQAM","ImParentProduct":"01t5E000006tNI9QAM","PriceBookEntryId":"01u5E00000I30xKQAR","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":2,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Access Basic Wireless 4G Backup"," ProductCode":"CO-DATANET-ACCESS-BASIC-4G","ProductObjectType":"Broadband Datanet Offering Spec","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":2,"Product2Id":"01t5E000006tNChQAM","Id":"0QL5E000000klvUWAQ","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","OfferType":"","LineNumber":"0002.0001.0002","SequenceNumber":10,"TargetPercentage":0,"OneTimePrice":0,"ProductType":"Price","RecurringPrice":300,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNI9QAM<01t5E000006tNCXQA2","ImParentProduct":"01t5E000006tNI9QAM","PriceBookEntryId":"01u5E00000I30xAQAR","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":1,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Access Basic Wireless 4G Backup Combo CPE"," ProductCode":"CO-DATANET-ACCESS-BASIC-4G-COMBO","ProductObjectType":"Broadband Datanet Offering Spec","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":2,"Product2Id":"01t5E000006tNCXQA2","Id":"0QL5E000000klveWAA","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","OfferType":"","LineNumber":"0002.0005.0001","SequenceNumber":20,"TargetPercentage":0,"OneTimePrice":7500,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000006tNGzQAM<01t5E000006tNEdQAM","ImParentProduct":"01t5E000006tNGzQAM","PriceBookEntryId":"01u5E00000I30yPQAR","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Anslutning i fastighetsnät"," ProductCode":"CO-DATANET-ANSLUTNING","ProductObjectType":"Broadband Datanet Offering Spec","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":2,"Product2Id":"01t5E000006tNEdQAM","Id":"0QL5E000000kjIuWAI","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0006.0001","SequenceNumber":20,"TargetPercentage":0,"OneTimePrice":1500,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000007HuoRQAS<01t5E000007aCCrQAM","ImParentProduct":"01t5E000007HuoRQAS","PriceBookEntryId":"01u5E00000Nd31SQAR","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Engångsavgift för Fiber-anslutningar"," ProductCode":"CO-DATANET-BIND-G1-24M","ProductObjectType":"Binding OTC Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":2,"Product2Id":"01t5E000007aCCrQAM","Id":"0QL5E000000kjJEWAY","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"},{"ApprovedPercentage":"","RequestedPercentage":"","ApprovedPrice":"","campaignId":"","LineNumber":"0002.0006.0002","SequenceNumber":50,"TargetPercentage":0,"OneTimePrice":750,"ProductType":"Price","RecurringPrice":0,"ExcludeItem":false,"RecurringManualDiscount":0,"OneTimeManualDiscount":0,"Quantity":1,"ProductHierarchyPathfull":"01t5E000006tNNuQAM<01t5E000007HuoRQAS<01t5E000007aCJ0QAM","ImParentProduct":"01t5E000007HuoRQAS","PriceBookEntryId":"01u5E00000Nd4Q1QAJ","ParentItemId":"01t5E000006tNNuQAM","FACallOffQuantity":0,"ProductHierarchyPath":"01t5E000006tNNuQAM","Product2Name":"Engångsavgift för Mobila anslutningar"," ProductCode":"CO-DATANET-BIND-G2-24M","ProductObjectType":"Binding OTC Offering Spec","OfferType":"SubscriptionOffering","QuoteId":"0Q03E000000Sz9aSAC","ParentProductName":"Telia Datanet","Level":2,"Product2Id":"01t5E000007aCJ0QAM","Id":"0QL5E000000kjJJWAY","AccountId":"0013E00001CnejOQAR","OpportunityId":"0063E000007VbzfQAC"}]}}';
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<String,Object> outputMap = new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            System.debug('Jsonout'+Json.serialize(inputMap));
            TeliaSE_SingleCart_CoOfferCreation prepReq = new TeliaSE_SingleCart_CoOfferCreation();
            prepReq.invokeMethod('PdtReorder', inputMap,outputMap,options);
            test.stopTest();
        }
    }
    @isTest
    public static void teststoreGroups(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            list<recordtype> faQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Contract' AND SobjectType = 'Quote' limit 1];
            list<recordtype> offerQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Offer' AND SobjectType = 'Quote' limit 1];
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced RA';
            acc.Org_Nr__c  = '5564110665';
            acc.Name = 'R21.4_Test_CO_Acc_Grouping';
            insert acc;
            
            Account acc_NonGrouping=Test_DataFactory.createOneSMEAccount();
            acc_NonGrouping.MC_Commercial_Setup__c = 'Forced RA';
            acc_NonGrouping.Org_Nr__c  = '5564110555';
            acc_NonGrouping.Name = 'R21.4_Test_CO_Acc_NonGrouping';
            insert acc_NonGrouping;
            
            //Creating quote for Grouping logic
            //Creating opportunity below
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            //Creating contract below
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.recordtypeId = rt1.id;
            insert contract;
            //Creating contract below
           /* Contract contract_NonGrouping = new Contract();
            contract_NonGrouping.Name = 'Test_NonGrouping';
            contract_NonGrouping.AccountId = acc_NonGrouping.id;
            contract_NonGrouping.Status = 'Active';
            contract_NonGrouping.Solution_Area__c = 'Vxl';
            contract_NonGrouping.StartDate = Date.today();
            contract_NonGrouping.ContractTerm = 24;
            insert contract_NonGrouping;*/
            
            //Create FA quote
            Quote faQuote = new Quote();
            faQuote.Name='Test Quote';
            faQuote.status = 'Draft';
            faQuote.TeliaSE_Type__c='Renegotiation';
            faQuote.opportunityId = opp.id;
            faQuote.Pricebook2ID = stdPriceBookRecId;
            faQuote.TeliaSE_Approval_Flag__c = true; 
            faQuote.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            faQuote.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert faQuote;
            contract.vlocity_cmt__QuoteId__c = faQuote.id;
            update contract;
            //Create FA quote
           /*Quote faQuote_NonGrouping = new Quote();
            faQuote_NonGrouping.Name='Test Quote_NonGrouping';
            faQuote_NonGrouping.status = 'Draft';
            faQuote_NonGrouping.TeliaSE_Type__c='Renegotiation';
            faQuote_NonGrouping.opportunityId = opp_NonGrouping.id;
            faQuote_NonGrouping.Pricebook2ID = stdPriceBookRecId;
            faQuote_NonGrouping.TeliaSE_Approval_Flag__c = true; 
            faQuote_NonGrouping.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            faQuote_NonGrouping.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert faQuote_NonGrouping;
            contract_NonGrouping.vlocity_cmt__QuoteId__c = faQuote_NonGrouping.id;
            update contract_NonGrouping;*/
            
            //Create Offer Quote
            Quote offerQuote = new Quote();
            offerQuote.Name='Test Quote';
            offerQuote.status = 'Draft';
            offerQuote.opportunityId = opp.id;
            offerQuote.Pricebook2ID = stdPriceBookRecId;
            offerQuote.TeliaSE_Approval_Flag__c = false; 
            offerQuote.vlocity_cmt__ParentQuoteId__c  = faQuote.id;
            offerQuote.RecordTypeId = id.valueof((string)offerQuoteRecId[0].get('id'));
            insert offerQuote;
            String ContextId = faQuote.Id;
            String OfferCartId = offerQuote.Id;
            test.startTest();
            String jsonString = '{"ContextId": "'+ ContextId +'", "OfferCartId":"'+OfferCartId+'"}';
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<String,Object> outputMap = new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            System.debug('Jsonout'+Json.serialize(inputMap));
            TeliaSE_SingleCart_CoOfferCreation prepReq = new TeliaSE_SingleCart_CoOfferCreation();
            prepReq.invokeMethod('storeGroups', inputMap,outputMap,options);
            test.stopTest();
        }
    }
  
    @isTest
    public static void testcheckCO(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            list<recordtype> faQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Contract' AND SobjectType = 'Quote' limit 1];
            list<recordtype> offerQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Offer' AND SobjectType = 'Quote' limit 1];
            List<Product2> prodList = new List<product2>();

            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.name = 'Telia Datanet';
            prod.productCode = 'CO-DATANET';
            prodList.add(prod); 
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Telia Bredband Pro';
            prod1.productCode = 'CO-BBPRO';
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'Telia Bredband Plus';
            prod2.productCode = 'CO-BBPLUS';
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.Name = 'Telia Cloud VPN Wifi/Lan';
            prod3.productCode = 'CO-CLOUDVPN-WIFI';
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.Name = 'Installation och Övriga Tillval';
            prod4.productCode = 'CO-BBPRO-SEKUNDAR';
            prodList.add(prod4);

            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.Name = 'HERA XYZ';
            prod5.productCode = 'CO-HERA-ALL';
            prodList.add(prod5);
            
            Product2 prod6 = Test_DataFactory.createProducts(1)[0];
            prod6.name = 'Bredband Pro 100 Mbit/s';
            prod6.productCode = 'CO-BBPRO-100MB';
            prodList.add(prod6);
            
            insert prodList;
            
            pricebookId = stdPriceBookRecId ;
            List<PricebookEntry> pbelist = new List<PricebookEntry>();
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;            
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            pbeList.add(objpricebookentry);
            
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod1.id;
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            pbeList.add(objpricebookentry1);
            
            PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prod2.id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            pbeList.add(objpricebookentry2);
            
            PricebookEntry objpricebookentry3 =new PricebookEntry();
            objpricebookentry3.Product2ID = prod3.id;
            objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry3.UnitPrice=23.50;
            objpricebookentry3.UseStandardPrice=false;
            objpricebookentry3.isActive=true;//Add this line
            pbeList.add(objpricebookentry3); 
            
            PricebookEntry objpricebookentry4 =new PricebookEntry();
            objpricebookentry4.Product2ID = prod4.id;
            objpricebookentry4.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry4.UnitPrice=23.50;
            objpricebookentry4.UseStandardPrice=false;
            objpricebookentry4.isActive=true;//Add this line
            pbeList.add(objpricebookentry4);
            
            PricebookEntry objpricebookentry5 =new PricebookEntry();
            objpricebookentry5.Product2ID = prod5.id;
            objpricebookentry5.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry5.UnitPrice=23.50;
            objpricebookentry5.UseStandardPrice=false;
            objpricebookentry5.isActive=true;//Add this line
            pbeList.add(objpricebookentry5);
            
            PricebookEntry objpricebookentry6 =new PricebookEntry();
            objpricebookentry6.Product2ID = prod6.id;
            objpricebookentry6.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry6.UnitPrice=23.50;
            objpricebookentry6.UseStandardPrice=false;
            objpricebookentry6.isActive=true;//Add this line
            pbeList.add(objpricebookentry6); 
            
            insert pbeList;
            
            //Creating account
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced RA';
            acc.Org_Nr__c  = '5564110665';
            acc.Name = 'R21.4_Test_CO_Acc_Grouping';
            insert acc;
            
            Account acc_NonGrouping=Test_DataFactory.createOneSMEAccount();
            acc_NonGrouping.MC_Commercial_Setup__c = 'Forced RA';
            acc_NonGrouping.Org_Nr__c  = '5564110555';
            acc_NonGrouping.Name = 'R21.4_Test_CO_Acc_NonGrouping';
            insert acc_NonGrouping;
            
            //Creating quote for Grouping logic
            //Creating opportunity below
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            //Creating contract below
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.recordtypeId = rt1.id;
            insert contract;
            //Creating contract below
           /* Contract contract_NonGrouping = new Contract();
            contract_NonGrouping.Name = 'Test_NonGrouping';
            contract_NonGrouping.AccountId = acc_NonGrouping.id;
            contract_NonGrouping.Status = 'Active';
            contract_NonGrouping.Solution_Area__c = 'Vxl';
            contract_NonGrouping.StartDate = Date.today();
            contract_NonGrouping.ContractTerm = 24;
            insert contract_NonGrouping;*/
            
            //Create FA quote
            Quote faQuote = new Quote();
            faQuote.Name='Test Quote';
            faQuote.status = 'Draft';
            faQuote.TeliaSE_Type__c='Renegotiation';
            faQuote.opportunityId = opp.id;
            faQuote.Pricebook2ID = stdPriceBookRecId;
            faQuote.TeliaSE_Approval_Flag__c = true; 
            faQuote.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            faQuote.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert faQuote;
            contract.vlocity_cmt__QuoteId__c = faQuote.id;
            update contract;
            //Create FA quote
           /* Quote faQuote_NonGrouping = new Quote();
            faQuote_NonGrouping.Name='Test Quote_NonGrouping';
            faQuote_NonGrouping.status = 'Draft';
            faQuote_NonGrouping.TeliaSE_Type__c='Renegotiation';
            faQuote_NonGrouping.opportunityId = opp_NonGrouping.id;
            faQuote_NonGrouping.Pricebook2ID = stdPriceBookRecId;
            faQuote_NonGrouping.TeliaSE_Approval_Flag__c = true; 
            faQuote_NonGrouping.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            faQuote_NonGrouping.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert faQuote_NonGrouping;
            contract_NonGrouping.vlocity_cmt__QuoteId__c = faQuote_NonGrouping.id;
            update contract_NonGrouping;*/
            
            //Create Offer Quote
            Quote offerQuote = new Quote();
            offerQuote.Name='Test Quote';
            offerQuote.status = 'Draft';
            offerQuote.opportunityId = opp.id;
            offerQuote.Pricebook2ID = stdPriceBookRecId;
            offerQuote.TeliaSE_Approval_Flag__c = false; 
            offerQuote.vlocity_cmt__ParentQuoteId__c  = faQuote.id;
            offerQuote.RecordTypeId = id.valueof((string)offerQuoteRecId[0].get('id'));
            insert offerQuote;
            //Create Offer Quote
           /* Quote offerQuote_NonGrouping = new Quote();
            offerQuote_NonGrouping.Name='Test Quote Offer_NonGrouping';
            offerQuote_NonGrouping.status = 'Draft';
            offerQuote_NonGrouping.opportunityId = opp_NonGrouping.id;
            offerQuote_NonGrouping.Pricebook2ID = stdPriceBookRecId;
            offerQuote_NonGrouping.TeliaSE_Approval_Flag__c = false; 
            offerQuote_NonGrouping.vlocity_cmt__ParentQuoteId__c  = faQuote.id;
            offerQuote_NonGrouping.RecordTypeId = id.valueof((string)offerQuoteRecId[0].get('id'));
            insert offerQuote_NonGrouping;*/
            
            //Creatting Premisies
            vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
            premise.vlocity_cmt__City__c = 'solna';
            premise.vlocity_cmt__StreetAddress__c = 'Överskärargränd';
            premise.vlocity_cmt__PostalCode__c = '12111';
            premise.vlocity_cmt__Address1__c = '12111';
            premise.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise;
            vlocity_cmt__Premises__c premise1 = new vlocity_cmt__Premises__c();
            premise1.vlocity_cmt__City__c = 'stockholm';
            premise1.vlocity_cmt__StreetAddress__c = 'Stjärntorget';
            premise1.vlocity_cmt__PostalCode__c = '12112';
            premise1.vlocity_cmt__Address1__c = '12112';
            premise1.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise1;
            vlocity_cmt__Premises__c premise2 = new vlocity_cmt__Premises__c();
            premise2.vlocity_cmt__City__c = 'solna';
            premise2.vlocity_cmt__StreetAddress__c = 'Diktarvägen';
            premise2.vlocity_cmt__PostalCode__c = '12113';
            premise2.vlocity_cmt__Address1__c = '12113';
            premise2.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise2;
            vlocity_cmt__Premises__c premise3 = new vlocity_cmt__Premises__c();
            premise3.vlocity_cmt__City__c = 'stockholm';
            premise3.vlocity_cmt__StreetAddress__c = 'Hamngatan';
            premise3.vlocity_cmt__PostalCode__c = '12114';
            premise3.vlocity_cmt__Address1__c = '12114';
            premise3.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise3;
            vlocity_cmt__Premises__c premise4 = new vlocity_cmt__Premises__c();
            premise4.vlocity_cmt__City__c = 'stockholm';
            premise4.vlocity_cmt__StreetAddress__c = 'Kanslikajen';
            premise4.vlocity_cmt__PostalCode__c = '12115';
            premise4.vlocity_cmt__Address1__c = '12115';
            premise4.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise4;
            //Creating service point link between Service point and premises
            vlocity_cmt__ServicePoint__c spoint = new vlocity_cmt__ServicePoint__c();
            spoint.vlocity_cmt__ServicePointNumber__c = '148573009';
            spoint.vlocity_cmt__PremisesId__c = premise.Id;
            insert spoint;
            vlocity_cmt__ServicePoint__c spoint1 = new vlocity_cmt__ServicePoint__c();
            spoint1.vlocity_cmt__ServicePointNumber__c = '1212123';
            spoint1.vlocity_cmt__PremisesId__c = premise1.Id;
            insert spoint1;
            vlocity_cmt__ServicePoint__c spoint2 = new vlocity_cmt__ServicePoint__c();
            spoint2.vlocity_cmt__ServicePointNumber__c = '1212124';
            spoint2.vlocity_cmt__PremisesId__c = premise2.Id;
            insert spoint2;
            vlocity_cmt__ServicePoint__c spoint3 = new vlocity_cmt__ServicePoint__c();
            spoint3.vlocity_cmt__ServicePointNumber__c = '1212125';
            spoint3.vlocity_cmt__PremisesId__c = premise3.Id;
            insert spoint3;
            vlocity_cmt__ServicePoint__c spoint4 = new vlocity_cmt__ServicePoint__c();
            spoint4.vlocity_cmt__ServicePointNumber__c = '1212125';
            spoint4.vlocity_cmt__PremisesId__c = premise4.Id;
            insert spoint4;
            //Creating quote groups
            vlocity_cmt__QuoteGroup__c quoteGroup = new vlocity_cmt__QuoteGroup__c();
            quoteGroup.Name = 'Group 1';
            quoteGroup.vlocity_cmt__Description__c = 'Group 1';
            quoteGroup.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup;
            vlocity_cmt__QuoteGroup__c quoteGroup1 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup1.Name = 'Group 2';
            quoteGroup1.vlocity_cmt__Description__c = 'Group 2';
            quoteGroup1.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup1;
            vlocity_cmt__QuoteGroup__c quoteGroup2 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup2.Name = 'Group 3';
            quoteGroup2.vlocity_cmt__Description__c = 'Group 3';
            quoteGroup2.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup2;
            vlocity_cmt__QuoteGroup__c quoteGroup3 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup3.Name = 'Group 4';
            quoteGroup3.vlocity_cmt__Description__c = 'Group 4';
            quoteGroup3.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup3;
            vlocity_cmt__QuoteGroup__c quoteGroup4 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup4.Name = 'Group 5';
            quoteGroup4.vlocity_cmt__Description__c = 'Group 5';
            quoteGroup4.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup4;
            //Creating quote members
            vlocity_cmt__QuoteMember__c quoteMem = new vlocity_cmt__QuoteMember__c();
            quoteMem.vlocity_cmt__ServicePointId__c = spoint.Id;
            quoteMem.vlocity_cmt__QuoteGroupId__c = quoteGroup.Id;
            quoteMem.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem;
            vlocity_cmt__QuoteMember__c quoteMem1 = new vlocity_cmt__QuoteMember__c();
            quoteMem1.vlocity_cmt__ServicePointId__c = spoint1.Id;
            quoteMem1.vlocity_cmt__QuoteGroupId__c = quoteGroup1.Id;
            quoteMem1.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem1;
            vlocity_cmt__QuoteMember__c quoteMem2 = new vlocity_cmt__QuoteMember__c();
            quoteMem2.vlocity_cmt__ServicePointId__c = spoint2.Id;
            quoteMem2.vlocity_cmt__QuoteGroupId__c = quoteGroup2.Id;
            quoteMem2.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem2;
            vlocity_cmt__QuoteMember__c quoteMem3 = new vlocity_cmt__QuoteMember__c();
            quoteMem3.vlocity_cmt__ServicePointId__c = spoint3.Id;
            quoteMem3.vlocity_cmt__QuoteGroupId__c = quoteGroup3.Id;
            quoteMem3.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem3;
            vlocity_cmt__QuoteMember__c quoteMem4 = new vlocity_cmt__QuoteMember__c();
            quoteMem4.vlocity_cmt__ServicePointId__c = spoint4.Id;
            quoteMem4.vlocity_cmt__QuoteGroupId__c = quoteGroup4.Id;
            quoteMem4.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem4;
            
            
            //Creating line items
            list<QuoteLineItem> offerQLI = new list<QuoteLineItem>();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli1.QuoteId = offerQuote.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.vlocity_cmt__Product2Id__c = prod.id;
            oli1.Product2Id = prod.id;
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_Approved__c = null;
            oli1.vlocity_cmt__RecurringCharge__c  = 200;
            oli1.TeliaSE_Ceiling_Price__c = 400;
            oli1.TeliaSE_Root_Product__c=prod.id;
            oli1.vlocity_cmt__ProductHierarchyPath__c = prod.id;
            oli1.TeliaSE_Base_Quantity__c = '123';
            oli1.vlocity_cmt__OneTimeCharge__c = 200;
            oli1.MC_OT_AM_Mandate_Percentage__c = 10;
            oli1.MC_OT_SM_Mandate_Percentage__c = 10;
            oli1.MC_OT_SD_Mandate_Percentage__c = 10;
            oli1.MC_OT_CM_Mandate_Percentage__c = 10;
            oli1.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli1.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli1.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli1.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli1.vlocity_cmt__QuoteGroupId__c = quoteGroup.id;
            oli1.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli1.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli1.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
           /* insert oli1;
            
            oli1.vlocity_cmt__RootItemId__c = oli1.id;
            oli1.vlocity_cmt__ParentItemId__c = oli1.id;*/
            offerQLI.add(oli1);
            //update oli1;
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry1.Id;
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli2.QuoteId = offerQuote.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.vlocity_cmt__Product2Id__c = prod1.id;
            oli2.Product2Id = prod1.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_Approved__c = null;
            oli2.vlocity_cmt__RecurringCharge__c  = 200;
            oli2.TeliaSE_Ceiling_Price__c = 400;
            oli2.TeliaSE_Root_Product__c=prod1.id;
            oli2.vlocity_cmt__ProductHierarchyPath__c = prod1.id;
            oli2.TeliaSE_Base_Quantity__c = '123';
            oli2.vlocity_cmt__OneTimeCharge__c = 200;
            oli2.MC_OT_AM_Mandate_Percentage__c = 10;
            oli2.MC_OT_SM_Mandate_Percentage__c = 10;
            oli2.MC_OT_SD_Mandate_Percentage__c = 10;
            oli2.MC_OT_CM_Mandate_Percentage__c = 10;
            oli2.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli2.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli2.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli2.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli2.vlocity_cmt__QuoteGroupId__c = quoteGroup1.id;
            oli2.TeliaSE_MC_Binding_Time__c = '24';
            oli2.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli2.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli2.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
           /* insert oli2;
            
            oli2.vlocity_cmt__RootItemId__c = oli2.id;
            oli2.vlocity_cmt__ParentItemId__c = oli2.id;
            update oli2;*/
            offerQLI.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry2.Id;
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli3.QuoteId = offerQuote.id;
            oli3.UnitPrice = 200;
            oli3.Quantity = 4;
            oli3.vlocity_cmt__Product2Id__c = prod2.id;
            oli3.Product2Id = prod2.id;
            oli3.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli3.TeliaSE_Approved__c = null;
            oli3.vlocity_cmt__RecurringCharge__c  = 200;
            oli3.TeliaSE_Ceiling_Price__c = 400;
            oli3.TeliaSE_Root_Product__c=prod2.id;
            oli3.vlocity_cmt__ProductHierarchyPath__c = prod2.id;
            oli3.TeliaSE_Base_Quantity__c = '123';
            oli3.vlocity_cmt__OneTimeCharge__c = 200;
            oli3.MC_OT_AM_Mandate_Percentage__c = 10;
            oli3.MC_OT_SM_Mandate_Percentage__c = 10;
            oli3.MC_OT_SD_Mandate_Percentage__c = 10;
            oli3.MC_OT_CM_Mandate_Percentage__c = 10;
            oli3.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli3.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli3.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli3.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli3.vlocity_cmt__QuoteGroupId__c = quoteGroup2.id;
            oli3.TeliaSE_MC_Binding_Time__c = '12';
            oli3.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli3.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli3.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            /*insert oli3;
            
            oli3.vlocity_cmt__RootItemId__c = oli3.id;
            oli3.vlocity_cmt__ParentItemId__c = oli3.id;
            update oli3;*/
            offerQLI.add(oli3);
            
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.PricebookEntryId = objpricebookentry5.Id;
            oli4.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli4.QuoteId = offerQuote.id;
            oli4.UnitPrice = 200;
            oli4.Quantity = 4;
            oli4.vlocity_cmt__Product2Id__c = prod5.id;
            oli4.Product2Id = prod5.id;
            oli4.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli4.TeliaSE_Approved__c = null;
            oli4.vlocity_cmt__RecurringCharge__c  = 200;
            oli4.TeliaSE_Ceiling_Price__c = 400;
            oli4.TeliaSE_Root_Product__c=prod5.id;
            oli4.vlocity_cmt__ProductHierarchyPath__c = prod5.id;
            oli4.TeliaSE_Base_Quantity__c = '123';
            oli4.vlocity_cmt__OneTimeCharge__c = 200;
            oli4.MC_OT_AM_Mandate_Percentage__c = 10;
            oli4.MC_OT_SM_Mandate_Percentage__c = 10;
            oli4.MC_OT_SD_Mandate_Percentage__c = 10;
            oli4.MC_OT_CM_Mandate_Percentage__c = 10;
            oli4.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli4.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli4.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli4.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli4.vlocity_cmt__QuoteGroupId__c = quoteGroup2.id;
            oli4.TeliaSE_MC_Binding_Time__c = '12';
            oli4.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli4.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli4.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            /*insert oli4;
            
            oli4.vlocity_cmt__RootItemId__c = oli4.id;
            oli4.vlocity_cmt__ParentItemId__c = oli4.id;
            update oli4;*/
            offerQLI.add(oli4);
            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.PricebookEntryId = objpricebookentry6.Id;
            oli5.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli5.QuoteId = offerQuote.id;
            oli5.UnitPrice = 200;
            oli5.Quantity = 4;
            oli5.vlocity_cmt__Product2Id__c = prod6.id;
            oli5.Product2Id = prod6.id;
            oli5.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli5.TeliaSE_Approved__c = null;
            oli5.vlocity_cmt__RecurringCharge__c  = 200;
            oli5.TeliaSE_Ceiling_Price__c = 400;
            oli5.TeliaSE_Root_Product__c=prod6.id;
            oli5.vlocity_cmt__ProductHierarchyPath__c = prod6.id;
            oli5.TeliaSE_Base_Quantity__c = '123';
            oli5.vlocity_cmt__OneTimeCharge__c = 200;
            oli5.MC_OT_AM_Mandate_Percentage__c = 10;
            oli5.MC_OT_SM_Mandate_Percentage__c = 10;
            oli5.MC_OT_SD_Mandate_Percentage__c = 10;
            oli5.MC_OT_CM_Mandate_Percentage__c = 10;
            oli5.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli5.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli5.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli5.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli5.vlocity_cmt__QuoteGroupId__c = quoteGroup2.id;
            oli5.TeliaSE_MC_Binding_Time__c = '12';
            oli5.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli5.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli5.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            /*insert oli5;
            
            oli5.vlocity_cmt__RootItemId__c = '';
            oli5.vlocity_cmt__ParentItemId__c = oli1.id;
            update oli5;*/
            offerQLI.add(oli5);
            
            insert offerQLI;
            String ContextId = offerQuote.Id;
            test.startTest();
            String jsonString = '{"ContextId": "'+ ContextId +'"}';
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<String,Object> outputMap = new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            System.debug('Jsonout'+Json.serialize(inputMap));
            TeliaSE_SingleCart_CoOfferCreation prepReq = new TeliaSE_SingleCart_CoOfferCreation();
            prepReq.invokeMethod('CheckCO', inputMap,outputMap,options);
            test.stopTest();
        }
    }
}