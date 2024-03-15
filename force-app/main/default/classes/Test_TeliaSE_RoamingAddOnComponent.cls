@isTest
public class Test_TeliaSE_RoamingAddOnComponent {

    public static testmethod void invokeMethod(){
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
            objClass.Name = 'Mobile Offer Specification';    
            objClass.vlocity_cmt__IsActive__c = True;
            objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass;
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            prod.ProductCode = 'MOB_CALL_TRAVEL_WEST';
            insert prod;	

            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            prod1.ProductCode = 'MOB_CALL_TRAVEL_SOUTH';
            insert prod1;	

            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            prod2.ProductCode = 'MOB_CALL_TRAVEL_EAST';
            insert prod2;	

            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            prod3.ProductCode = 'MOB_CALL_TRAVEL_EUROPE';
            insert prod3;	

            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            prod4.ProductCode = 'MOB_CALL_TRAVEL_OTHER';
            insert prod4;	
            
            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            prod5.ProductCode = 'MOB_CALL_TRAVEL_OVERSEAS';
            insert prod5;	
            
            pricebookId = stdPriceBookRecId ;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
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
            qut.Name='test Quote';
            qut.status = 'Draft';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.TeliaSE_Type__c='New';
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='New Sales';
            insert qut;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.Product2Id = prod.id;
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli1.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli1.TeliaSE_Approved__c = 1;
            oli1.TeliaSE_Approved_Price__c = 0;
            oli1.TeliaSE_Nullify_Check__c = true;
            oli1.vlocity_cmt__Product2Id__c = prod.id;
            oli1.vlocity_cmt__RootItemId__c = prod.id;
            
            insert oli1;
            /*
            TeliaSE_Roaming_Mandate__mdt cusSetting = new TeliaSE_Roaming_Mandate__mdt();
            cusSetting.ResOsterutPris__c	= '%MOBILE_CAMPAIGN_DISC%';
            cusSetting.ResSoderutPris__c = 'Mobile Offer Specification';
            cusSetting.ResVasterutPris__c = 'Mobile Offer Specification'; 
            cusSetting.TillEuropaPris__c = 'Mobile Offer Specification'; 
            cusSetting.TillGrannlandPris__c = 'Mobile Offer Specification'; 
            cusSetting.TillUtlandPris__c = 'Mobile Offer Specification'; 
            cusSetting.Is_SM_Mandate_Price__c = 'Yes'; 
            insert cusSetting;
            
            */
            TeliaSE_RoamingAddOnComponent comp = new TeliaSE_RoamingAddOnComponent();
            comp.resAddOn = '';
            comp.tillAddOn = '';
            comp.productName='';
            comp.productCode = '';
            TeliaSE_RoamingAddOnComponent.getPathStatus(qut.Id);
            TeliaSE_RoamingAddOnComponent.getSMMandatePrice('MOB_CALL_TRAVEL_WEST');
            TeliaSE_RoamingAddOnComponent.getSMMandatePrice('MOB_CALL_TRAVEL_EAST');
            TeliaSE_RoamingAddOnComponent.getSMMandatePrice('MOB_CALL_TRAVEL_SOUTH');
            TeliaSE_RoamingAddOnComponent.getSMMandatePrice('MOB_CALL_TRAVEL_OTHER');
            TeliaSE_RoamingAddOnComponent.getSMMandatePrice('MOB_CALL_TRAVEL_EUROPE');
            TeliaSE_RoamingAddOnComponent.getSMMandatePrice('MOB_CALL_TRAVEL_OVERSEAS');
            TeliaSE_RoamingAddOnComponent.generateApproverName('ProdNameWithTill', 'Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr', '');
            TeliaSE_RoamingAddOnComponent.generateApproverName('ProdNameWithTill', 'Europa - alla anv. 29 kr, 49 kr, 19 kr', '');
            TeliaSE_RoamingAddOnComponent.generateApproverName('ProdNameWithTill', '59 kr, 39 kr, 19 kr', '');
            TeliaSE_RoamingAddOnComponent.getQuotecartVal(qut.Id);
        }
    }
    
}