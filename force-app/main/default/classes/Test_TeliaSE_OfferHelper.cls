@isTest
public with sharing class Test_TeliaSE_OfferHelper {   
     @testSetup static void setup(){
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(Test_DataFactory.getByPassUser())
        {
            List<FiberDiscountMandate__c> fiberDiscounts = new List<FiberDiscountMandate__c>();
            FiberDiscountMandate__c fb = new FiberDiscountMandate__c();
            fb.Role__c = 'Manager';
            fb.Name = 'Manager';
            fb.EBIT_Max_Mandate__c = 12;
            fb.EBIT_Min_Mandate__c = 1;
            fb.ProductDiscountMaxMandate__c = 12;
            fb.ProductDiscountMinMandate__c = 12;
            fiberDiscounts.add(fb);
            
            FiberDiscountMandate__c fb1 = new FiberDiscountMandate__c();
            fb1.Role__c = 'Director';
            fb1.Name = 'Director';
            fb1.EBIT_Max_Mandate__c = 12;
            fb1.EBIT_Min_Mandate__c = 1;
            fb1.ProductDiscountMaxMandate__c = 12;
            fb1.ProductDiscountMinMandate__c = 12;
            fiberDiscounts.add(fb1);
            
            FiberDiscountMandate__c fdm = new FiberDiscountMandate__c();
            fdm.Name = 'SalesRep';
            fdm.EBIT_Max_Mandate__c = 30;
            fdm.ProductDiscountMaxMandate__c = 11;
            fdm.Role__c = 'Fiber Sales Rep New Sales';
            fiberDiscounts.add(fdm);
            insert fiberDiscounts;
            
            List<sObject> types=new List<sObject>();
            SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
            vlocity_cmt__ObjectClass__c touchpointType = new vlocity_cmt__ObjectClass__c(Name = 'Touch Point Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c officeObjType = new vlocity_cmt__ObjectClass__c(Name = 'OFFICE365 Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c mobileType = new vlocity_cmt__ObjectClass__c(Name = 'Mobile Offer Specification', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c insuranceType = new vlocity_cmt__ObjectClass__c(Name = 'Insurance Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c broadBandType = new vlocity_cmt__ObjectClass__c(Name = 'Broadband Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c personalTechType = new vlocity_cmt__ObjectClass__c(Name = 'Personal Technician Offer Specification', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c smartsecType = new vlocity_cmt__ObjectClass__c(Name = 'Smart Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c tppType = new vlocity_cmt__ObjectClass__c(Name = 'TouchPoint Plus Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c wifiLan = new vlocity_cmt__ObjectClass__c(Name = 'WIFI/LAN Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c sdWanFirewall = new vlocity_cmt__ObjectClass__c(Name = 'SD-WAN/Firewall Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c bbStart = new vlocity_cmt__ObjectClass__c(Name = 'Broadband Start Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c bbPro = new vlocity_cmt__ObjectClass__c(Name = 'Broadband Pro Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c bbPlus = new vlocity_cmt__ObjectClass__c(Name = 'Broadband Plus Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c dataNet = new vlocity_cmt__ObjectClass__c(Name = 'Broadband Datanet Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c ICT = new vlocity_cmt__ObjectClass__c(Name = 'ICT Offer Specification', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c itdaas = new vlocity_cmt__ObjectClass__c(Name = 'ITDaaS Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c smartCon = new vlocity_cmt__ObjectClass__c(Name = 'Smart Connect Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c oc = new vlocity_cmt__ObjectClass__c(Name = 'Operator Connect Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            
            types.add(touchpointType);
            types.add(officeObjType);
            types.add(mobileType);
            types.add(insuranceType);
            types.add(broadBandType);
            types.add(personalTechType);
            types.add(smartsecType);
            types.add(tppType);
            types.add(wifiLan);
            types.add(sdWanFirewall);
            types.add(bbStart);
            types.add(bbPro);
            types.add(bbPlus);
            types.add(dataNet);
            types.add(ICT);
            types.add(itdaas);
            types.add(smartCon);
            types.add(oc);
            
            insert types;
            
            List<MC_CommercialNegotiation__c> cnegList = new List<MC_CommercialNegotiation__c>();
            //InvoiceFee
            MC_CommercialNegotiation__c cneg = new MC_CommercialNegotiation__c();
            cneg.Name = 'Invoice Fee';
            cneg.Approval_Required__c = true;
            cneg.Approved_By__c = 'SalesManager'; 
            cneg.Default_Value__c = 'Ja';
            cnegList.add(cneg);
            //Payment Terms
            MC_CommercialNegotiation__c cneg1 = new MC_CommercialNegotiation__c();
            cneg1.Name = 'Payment Terms';
            cneg1.Approval_Required__c = true;
            cneg1.Approved_By__c = 'SalesDirector';
            cneg1.Default_Value__c = '30';
            cnegList.add(cneg1);
            //MinimumCommitment
            MC_CommercialNegotiation__c cneg2 = new MC_CommercialNegotiation__c();
            cneg2.Name = 'MinimumCommitment';
            cneg2.Approval_Required__c = true;
            cneg2.Approved_By__c = 'SalesManager';
            cneg2.Default_Value__c = '75';
             cnegList.add(cneg2);
            //Benchmarking Agreements
            MC_CommercialNegotiation__c cneg3 = new MC_CommercialNegotiation__c();
            cneg3.Name = 'Benchmarking Agreements';
            cneg3.Approval_Required__c = true;
            cneg3.Approved_By__c = 'SalesRep';
            cneg3.Default_Value__c = 'Nej';
             cnegList.add(cneg3);
            //TimeToReachBaseLevel
            MC_CommercialNegotiation__c cneg4 = new MC_CommercialNegotiation__c();
            cneg4.Name = 'TimeToReachBaseLevel';
            cneg4.Approval_Required__c = true;
            cneg4.Approved_By__c = 'SalesRep';
            cneg4.Default_Value__c = '3';
             cnegList.add(cneg4);
            
            MC_CommercialNegotiation__c cneg6 = new MC_CommercialNegotiation__c();
            cneg6.Name = 'IndexationClause';
            cneg6.Approval_Required__c = true;
            cneg6.Approved_By__c = 'SalesRep';
            cneg6.Default_Value__c = 'ja';
             cnegList.add(cneg6);
            
            insert cnegList;
            
            List<Product2> prod = Test_DataFactory.createProducts(19);
            prod[0].name='Microsoft 365';
            prod[0].ProductCode ='OFFICE365_Offer_spec';
            prod[0].vlocity_cmt__ObjectTypeId__c=officeObjType.Id;
            prod[0].TeliaSE_Offer_Type__c = 'AgreementOffering';
            
            prod[1].name='Mobilt Bredband';
            prod[1].ProductCode ='OFFICE365_Offer_spec';
            prod[1].vlocity_cmt__ObjectTypeId__c=broadBandType.id;
            
            prod[2].name='Jobbmobil';
            prod[2].ProductCode ='MOB_CALL_TRAVEL';
            prod[2].vlocity_cmt__ObjectTypeId__c=mobileType.id;
            prod[2].TeliaSE_Offer_Type__c = 'AgreementOffering';   
            prod[3].name='Smart Säkerhet';
            prod[3].ProductCode ='Sakernet';
            prod[3].vlocity_cmt__ObjectTypeId__c=smartsecType.id;    
            prod[4].name='Touch';   
            prod[4].ProductCode ='touchpoint';
            prod[4].vlocity_cmt__ObjectTypeId__c=touchpointType.id;    
            prod[5].name='Personlig';
            prod[5].ProductCode ='Personalig';
            prod[5].vlocity_cmt__ObjectTypeId__c=personalTechType.id;    
            prod[6].name='Försäkring';
            prod[6].ProductCode ='Forsakrng';
            prod[6].vlocity_cmt__ObjectTypeId__c=insuranceType.id;    
            prod[7].name='Exchange Online Plan 1';
            prod[7].ProductCode ='Exchange_Online_Plan';
            prod[8].name='Touch Point Plus';
            prod[8].ProductCode ='TPP_ACD_LIGHT';
            prod[8].vlocity_cmt__ObjectTypeId__c=tppType.id;  
            prod[9].name='BBStart';
            prod[9].ProductCode ='BB_Start';
            prod[9].vlocity_cmt__ObjectTypeId__c=bbStart.id; 
            prod[10].name='BBPlus';
            prod[10].ProductCode ='CO-BBPLUS';
            prod[10].vlocity_cmt__ObjectTypeId__c=bbPlus.id;
            prod[11].name='BBPro';
            prod[11].ProductCode ='BB_Pro';
            prod[11].vlocity_cmt__ObjectTypeId__c=bbPro.id; 
            prod[12].name='ICT_Telia';
            prod[12].ProductCode ='ICT_Telia';
            prod[12].vlocity_cmt__ObjectTypeId__c=ICT.id;    
            prod[13].name='Datanet';
            prod[13].ProductCode ='BB_Datanet';
            prod[13].vlocity_cmt__ObjectTypeId__c=datanet.id;
            prod[14].name='ITDaaSTelia';
            prod[14].ProductCode ='ITDaaS_Telia';
            prod[14].vlocity_cmt__ObjectTypeId__c=itdaas.id;
            prod[15].name='wifiLan_Telia';
            prod[15].ProductCode ='wifiLan_Telia';
            prod[15].vlocity_cmt__ObjectTypeId__c=wifiLan.id;
            prod[16].name='sdWanFirewall_Telia';
            prod[16].ProductCode ='sdWanFirewall_Telia';
            prod[16].vlocity_cmt__ObjectTypeId__c=sdWanFirewall.id;
            prod[17].name='smartCon_Telia';
            prod[17].ProductCode ='smartCon_Telia';
            prod[17].vlocity_cmt__ObjectTypeId__c=smartCon.id;
            prod[18].name='oc_Telia';
            prod[18].ProductCode ='oc_Telia';
            prod[18].vlocity_cmt__ObjectTypeId__c=oc.id;

            
            insert prod;   
            
            pricebookId = stdPriceBookRecId ;      
            Account acc=Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod[0].id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            pbeList.add(objpricebookentry);
            
            PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prod[1].id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            pbeList.add(objpricebookentry2);
            
            PricebookEntry objpricebookentry3 =new PricebookEntry();
            objpricebookentry3.Product2ID = prod[2].id;
            objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry3.UnitPrice=23.50;
            objpricebookentry3.UseStandardPrice=false;
            objpricebookentry3.isActive=true;//Add this line
            pbeList.add(objpricebookentry3);
            insert pbeList;
            
            //Test.startTest();
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;    
            qut.MC_Payment_Term__c = 75;
            insert qut;
            
            /*Quote qut1 = new Quote();
            qut1.Name='quotetest1';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.Pricebook2ID = stdPriceBookRecId;
            qut1.TeliaSE_Approval_Flag__c = False;    
            qut1.TeliaSE_Invoice_Fee__c = 'Nej';
            insert qut1;
            
            Quote qut2 = new Quote();
            qut2.Name='quotetest2';
            qut2.status = 'Draft';
            qut2.opportunityId = opp.id;
            qut2.Pricebook2ID = stdPriceBookRecId;
            qut2.TeliaSE_Approval_Flag__c = False;    
            qut2.MC_Commercial_Benchmark__c = 'Ja';
            insert qut2;
            
            Quote qutNoChild = new Quote();
            qutNoChild.Name='qutNoChild';
            qutNoChild.status = 'Draft';
            qutNoChild.opportunityId = opp.id;
            qutNoChild.Pricebook2ID = stdPriceBookRecId;
            qutNoChild.TeliaSE_Approval_Flag__c = False;    
            qutNoChild.MC_Commercial_Benchmark__c = 'Ja';
            insert qutNoChild;*/
          
            vlocity_cmt__Promotion__c campaign = new vlocity_cmt__Promotion__c();
            campaign.Name = '3 fria månader';
            campaign.MC_Product_Name_Eng__c = '3 Month Free';
            campaign.vlocity_cmt__Code__c='MOBILE_CAMPAIGN_DISC_100_3   ';
            insert campaign;
            
            List<QuoteLineItem> oliList = new List<QuoteLineItem>();
            QuoteLineItem oli = new QuoteLineItem();
            oli.PricebookEntryId = objpricebookentry2.Id;
            oli.QuoteId = qut.id;
            oli.UnitPrice = 200;
            oli.Quantity = 4;   
            oli.TeliaSE_MC_Campaign_Id__c = campaign.Id;
            oli.Product2Id = prod[1].id;
            oli.vlocity_cmt__Product2Id__c = prod[1].id;
            oli.vlocity_cmt__RecurringCharge__c  = 200;
            oli.vlocity_cmt__OneTimeCharge__c  = 200;
            oli.TeliaSE_Ceiling_Price__c = 400;
            oli.TeliaSE_Root_Product__c=prod[1].id;
            oli.vlocity_cmt__ParentItemId__c=null;
            oliList.add(oli);
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;   
            oli1.Product2Id = prod[0].id;
            oli1.TeliaSE_MC_Campaign_Id__c = campaign.Id;
            oli1.vlocity_cmt__Product2Id__c = prod[0].id;
            oli1.vlocity_cmt__RecurringCharge__c  = 200;
            oli1.vlocity_cmt__OneTimeCharge__c  = 200;
            oli1.TeliaSE_Ceiling_Price__c = 400;
            oli1.TeliaSE_Root_Product__c=prod[0].id;
            oli1.vlocity_cmt__ParentItemId__c=null;
            oliList.add(oli1);
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry2.Id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;    
            oli2.QuoteId = qut.id;
            oli2.Product2Id = prod[2].id;
            oli2.vlocity_cmt__Product2Id__c = prod[2].id;
            oli2.vlocity_cmt__RecurringCharge__c  = 200;
            oli2.vlocity_cmt__OneTimeCharge__c  = 200;
            oli2.TeliaSE_Ceiling_Price__c = 400;
            oli2.TeliaSE_Root_Product__c=prod[2].id;
            oli2.vlocity_cmt__ParentItemId__c=null;
            oliList.add(oli2);
            
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.PricebookEntryId = objpricebookentry2.Id;
            oli4.QuoteId = qut.id;
            oli4.UnitPrice = 200;
            oli4.Quantity = 4;  
            oli4.Product2Id = prod[3].id;
            oli4.vlocity_cmt__Product2Id__c = prod[3].id;
            oli4.vlocity_cmt__RecurringCharge__c  = 200;
            oli4.TeliaSE_MC_Customer_Requested_Price__c = 700;
            oli4.vlocity_cmt__OneTimeCharge__c  = 200;
            oli4.TeliaSE_Ceiling_Price__c = 400;
            oli4.TeliaSE_Root_Product__c=prod[3].id;
            oli4.vlocity_cmt__ParentItemId__c=null;
            oli4.TeliaSE_fiber_Rabatt__c = 12;
            oliList.add(oli4);
            
            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.PricebookEntryId = objpricebookentry.Id;
            oli5.QuoteId = qut.id;
            oli5.UnitPrice = 200;
            oli5.Quantity = 4;  
            oli5.Product2Id = prod[4].id;
            oli5.vlocity_cmt__Product2Id__c = prod[4].id;
            oli5.vlocity_cmt__RecurringCharge__c  = 200;
            oli5.vlocity_cmt__OneTimeCharge__c  = 100;
            oli5.TeliaSE_Ceiling_Price__c = 400;
            oli5.TeliaSE_Root_Product__c=prod[4].id;
            oli5.vlocity_cmt__ParentItemId__c=null;
            oli5.TeliaSE_fiber_Rabatt__c = 12;
            oliList.add(oli5);
            
            QuoteLineItem oli6 = new QuoteLineItem();
            oli6.PricebookEntryId = objpricebookentry.Id;
            oli6.QuoteId = qut.id;
            oli6.UnitPrice = 200;
            oli6.Quantity = 4;    
            oli6.Product2Id = prod[5].id;
            oli6.vlocity_cmt__Product2Id__c = prod[5].id;
            oli6.vlocity_cmt__RecurringCharge__c  = 200;
            oli6.vlocity_cmt__OneTimeCharge__c  = 200;
            oli6.TeliaSE_MC_Customer_Requested_Price__c = 400;
            oli6.TeliaSE_Ceiling_Price__c = 400;
            oli6.TeliaSE_Root_Product__c=prod[5].id;
            oli6.vlocity_cmt__ParentItemId__c=null;
            oliList.add(oli6);
            
            QuoteLineItem oli7 = new QuoteLineItem();
            oli7.PricebookEntryId = objpricebookentry.Id;
            oli7.QuoteId = qut.id;
            oli7.UnitPrice = 200;
            oli7.Quantity = 4;  
      		oli7.Product2Id = prod[6].id;
            oli7.vlocity_cmt__Product2Id__c = prod[6].id;
            oli7.vlocity_cmt__RecurringCharge__c  = 200;
            oli7.vlocity_cmt__OneTimeCharge__c  = 200;
            oli7.TeliaSE_Ceiling_Price__c = 400;
            oli7.TeliaSE_Root_Product__c=prod[6].id;
            oli7.vlocity_cmt__ParentItemId__c=null;
            oliList.add(oli7);
            
            QuoteLineItem oli8 = new QuoteLineItem();
            oli8.PricebookEntryId = objpricebookentry.Id;
            oli8.QuoteId = qut.id;
            oli8.UnitPrice = 200;
            oli8.Quantity = 4;    
            oli8.Product2Id = prod[8].id;
            oli8.vlocity_cmt__Product2Id__c = prod[8].id;
            oli8.vlocity_cmt__RecurringCharge__c  = 200;
            oli8.vlocity_cmt__OneTimeCharge__c  = 200;
            oli8.TeliaSE_Ceiling_Price__c = 400;
            oli8.TeliaSE_Root_Product__c=prod[8].id;
            oli8.vlocity_cmt__ParentItemId__c=null;
            oliList.add(oli8);
            
            QuoteLineItem oli9 = new QuoteLineItem();
            oli9.PricebookEntryId = objpricebookentry.Id;
            oli9.QuoteId = qut.id;
            oli9.UnitPrice = 200;
            oli9.Quantity = 4;    
            oli9.Product2Id = prod[9].id;
            oli9.vlocity_cmt__Product2Id__c = prod[9].id;
            oli9.vlocity_cmt__RecurringCharge__c  = 200;
            oli9.vlocity_cmt__OneTimeCharge__c  = 200;
            oli9.TeliaSE_Ceiling_Price__c = 400;
            oli9.TeliaSE_Root_Product__c=prod[9].id;
            oli9.vlocity_cmt__ParentItemId__c=null;
            oli9.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli9);
            
            QuoteLineItem oli10 = new QuoteLineItem();
            oli10.PricebookEntryId = objpricebookentry.Id;
            oli10.QuoteId = qut.id;
            oli10.UnitPrice = 200;
            oli10.Quantity = 4;    
            oli10.Product2Id = prod[10].id;
            oli10.vlocity_cmt__Product2Id__c = prod[10].id;
            oli10.vlocity_cmt__RecurringCharge__c  = 200;
            oli10.vlocity_cmt__OneTimeCharge__c  = 200;
            oli10.TeliaSE_Ceiling_Price__c = 400;
            oli10.TeliaSE_Root_Product__c=prod[10].id;
            oli10.vlocity_cmt__ParentItemId__c=null;
            //oli10.vlocity_cmt__ParentItemId__c=oli2.Id;
            //oli10.vlocity_cmt__RootItemId__c = oli2.Id;    
            oli10.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli10);   
            
            QuoteLineItem oli14 = new QuoteLineItem();
            oli14.PricebookEntryId = objpricebookentry.Id;
            oli14.QuoteId = qut.id;
            oli14.UnitPrice = 200;
            oli14.Quantity = 4;    
            oli14.Product2Id = prod[11].id;
            oli14.vlocity_cmt__Product2Id__c = prod[11].id;
            oli14.vlocity_cmt__RecurringCharge__c  = 200;
            oli14.vlocity_cmt__OneTimeCharge__c  = 200;
            oli14.TeliaSE_Ceiling_Price__c = 400;
            oli14.TeliaSE_Root_Product__c=prod[11].id;
            oli14.vlocity_cmt__ParentItemId__c=null;
            //oli10.vlocity_cmt__ParentItemId__c=oli2.Id;
            //oli10.vlocity_cmt__RootItemId__c = oli2.Id;    
            oli14.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli14);
            
            QuoteLineItem oli15 = new QuoteLineItem();
            oli15.PricebookEntryId = objpricebookentry.Id;
            oli15.QuoteId = qut.id;
            oli15.UnitPrice = 200;
            oli15.Quantity = 4;
            oli15.Product2Id = prod[12].id;
            oli15.vlocity_cmt__Product2Id__c = prod[12].id;
            oli15.vlocity_cmt__RecurringCharge__c  = 200;
            oli15.vlocity_cmt__OneTimeCharge__c  = 200;
            oli15.TeliaSE_Ceiling_Price__c = 400;
            oli15.TeliaSE_Root_Product__c=prod[12].id;
            oli15.vlocity_cmt__ParentItemId__c=null;    
            oli15.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli15);
            
            QuoteLineItem oli16 = new QuoteLineItem();
            oli16.PricebookEntryId = objpricebookentry.Id;
            oli16.QuoteId = qut.id;
            oli16.UnitPrice = 200;
            oli16.Quantity = 4;
            oli16.Product2Id = prod[13].id;
            oli16.vlocity_cmt__Product2Id__c = prod[13].id;
            oli16.vlocity_cmt__RecurringCharge__c  = 200;
            oli16.vlocity_cmt__OneTimeCharge__c  = 200;
            oli16.TeliaSE_Ceiling_Price__c = 400;
            oli16.TeliaSE_Root_Product__c=prod[13].id;
            oli16.vlocity_cmt__ParentItemId__c=null;
            oli16.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli16);
            
            QuoteLineItem oli17 = new QuoteLineItem();
            oli17.PricebookEntryId = objpricebookentry.Id;
            oli17.QuoteId = qut.id;
            oli17.UnitPrice = 200;
            oli17.Quantity = 4;
            oli17.Product2Id = prod[14].id;
            oli17.vlocity_cmt__Product2Id__c = prod[14].id;
            oli17.vlocity_cmt__RecurringCharge__c  = 200;
            oli17.vlocity_cmt__OneTimeCharge__c  = 200;
            oli17.TeliaSE_Ceiling_Price__c = 400;
            oli17.TeliaSE_Root_Product__c=prod[14].id;
            oli17.vlocity_cmt__ParentItemId__c=null;
            //oli10.vlocity_cmt__ParentItemId__c=oli2.Id;
            //oli10.vlocity_cmt__RootItemId__c = oli2.Id;    
            oli17.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli17);
            
            /*QuoteLineItem oli2mob = new QuoteLineItem();
            oli2mob.PricebookEntryId = objpricebookentry.Id;
            oli2mob.UnitPrice = 200;
            oli2mob.Quantity = 4;    
            oli2mob.QuoteId = qut1.id;
            oli2mob.Product2Id = prod[2].id;
            oli2mob.vlocity_cmt__Product2Id__c = prod[2].id;
            oli2mob.vlocity_cmt__RecurringCharge__c  = 200;
            oli2mob.vlocity_cmt__OneTimeCharge__c  = 200;
            oli2mob.TeliaSE_Ceiling_Price__c = 400;
            oli2mob.TeliaSE_MC_Customer_Requested_Price__c = 400;
            oli2mob.TeliaSE_Root_Product__c=prod[2].id;
            oli2mob.vlocity_cmt__ParentItemId__c=null;
            oliList.add(oli2mob);
            
            QuoteLineItem oli2mob2 = new QuoteLineItem();
            oli2mob2.PricebookEntryId = objpricebookentry.Id;
            oli2mob2.UnitPrice = 200;
            oli2mob2.Quantity = 4;    
            oli2mob2.QuoteId = qut2.id;
            oli2mob2.Product2Id = prod[2].id;
            oli2mob2.vlocity_cmt__Product2Id__c = prod[2].id;
            oli2mob2.vlocity_cmt__OneTimeCharge__c  = 200;
            oli2mob2.vlocity_cmt__RecurringCharge__c  = 200;
            oli2mob2.TeliaSE_Ceiling_Price__c = 400;
            oli2mob2.TeliaSE_Root_Product__c=prod[2].id;
            oli2mob2.vlocity_cmt__ParentItemId__c=null;
            oliList.add(oli2mob2);
            
            QuoteLineItem oli11 = new QuoteLineItem();
            oli11.PricebookEntryId = objpricebookentry.Id;
            oli11.QuoteId = qut1.id;
            oli11.UnitPrice = 200;
            oli11.Quantity = 4;    
            oli11.vlocity_cmt__Product2Id__c = prod[9].id;
            oli11.vlocity_cmt__RecurringCharge__c  = 200;
            oli11.vlocity_cmt__OneTimeCharge__c  = 200;
            oli11.TeliaSE_Ceiling_Price__c = 400;
            oli11.TeliaSE_Root_Product__c=prod[9].id;    
            oli11.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli11);
            
            QuoteLineItem oli12 = new QuoteLineItem();
            oli12.PricebookEntryId = objpricebookentry.Id;
            oli12.QuoteId = qut1.id;
            oli12.UnitPrice = 200;
            oli12.Quantity = 4;            
            oli12.Product2Id = prod[7].id;
            oli12.vlocity_cmt__Product2Id__c = prod[7].id;
            oli12.vlocity_cmt__RecurringCharge__c  = 200;
            oli12.vlocity_cmt__OneTimeCharge__c  = 200;
            oli12.TeliaSE_Ceiling_Price__c = 400;
            oli12.TeliaSE_Root_Product__c=prod[2].id;    
            oli12.vlocity_cmt__EffectiveQuantity__c=1;
            oli12.TeliaSE_Flag__c = '/resource/1555137213000/TeliaSE_Sad_Face';
            oliList.add(oli12);
            
            QuoteLineItem oli13 = new QuoteLineItem();
            oli13.PricebookEntryId = objpricebookentry.Id;
            oli13.QuoteId = qut1.id;
            oli13.UnitPrice = 200;
            oli13.Quantity = 4;
            oli13.Product2Id = prod[7].id;
            oli13.vlocity_cmt__Product2Id__c = prod[7].id;
            oli13.vlocity_cmt__RecurringCharge__c  = 200;
            oli13.vlocity_cmt__OneTimeCharge__c  = 200;
            oli13.TeliaSE_Ceiling_Price__c = 400;
            oli13.TeliaSE_Root_Product__c=prod[2].id;    
            oli13.vlocity_cmt__EffectiveQuantity__c=1;
            oli13.TeliaSE_Flag__c = '/resource/1555137213000/TeliaSE_Sad_Face';
            oliList.add(oli13);*/

            QuoteLineItem oli20 = new QuoteLineItem();
            oli20.PricebookEntryId = objpricebookentry.Id;
            oli20.QuoteId = qut.id;
            oli20.UnitPrice = 200;
            oli20.Quantity = 4;    
            oli20.Product2Id = prod[10].id;
            oli20.vlocity_cmt__Product2Id__c = prod[10].id;
            oli20.vlocity_cmt__RecurringCharge__c  = 200;
            oli20.vlocity_cmt__OneTimeCharge__c  = 200;
            oli20.TeliaSE_Ceiling_Price__c = 400;
            oli20.TeliaSE_Root_Product__c=prod[10].id;
            oli20.vlocity_cmt__ParentItemId__c=null;
            oli20.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli20);

            QuoteLineItem oli21 = new QuoteLineItem();
            oli21.PricebookEntryId = objpricebookentry.Id;
            oli21.QuoteId = qut.id;
            oli21.UnitPrice = 200;
            oli21.Quantity = 4;    
            oli21.Product2Id = prod[15].id;
            oli21.vlocity_cmt__Product2Id__c = prod[15].id;
            oli21.vlocity_cmt__RecurringCharge__c  = 200;
            oli21.vlocity_cmt__OneTimeCharge__c  = 200;
            oli21.TeliaSE_Ceiling_Price__c = 400;
            oli21.TeliaSE_Root_Product__c=prod[15].id;
            oli21.vlocity_cmt__ParentItemId__c=null;
            oli21.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli21);

            QuoteLineItem oli23 = new QuoteLineItem();
            oli23.PricebookEntryId = objpricebookentry.Id;
            oli23.QuoteId = qut.id;
            oli23.UnitPrice = 200;
            oli23.Quantity = 4;    
            oli23.Product2Id = prod[17].id;
            oli23.vlocity_cmt__Product2Id__c = prod[17].id;
            oli23.vlocity_cmt__RecurringCharge__c  = 200;
            oli23.vlocity_cmt__OneTimeCharge__c  = 200;
            oli23.TeliaSE_Ceiling_Price__c = 400;
            oli23.TeliaSE_Root_Product__c=prod[17].id;
            oli23.vlocity_cmt__ParentItemId__c=null;
            oli23.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli23);

            QuoteLineItem oli22 = new QuoteLineItem();
            oli22.PricebookEntryId = objpricebookentry.Id;
            oli22.QuoteId = qut.id;
            oli22.UnitPrice = 200;
            oli22.Quantity = 4;    
            oli22.Product2Id = prod[16].id;
            oli22.vlocity_cmt__Product2Id__c = prod[16].id;
            oli22.vlocity_cmt__RecurringCharge__c  = 200;
            oli22.vlocity_cmt__OneTimeCharge__c  = 200;
            oli22.TeliaSE_Ceiling_Price__c = 400;
            oli22.TeliaSE_Root_Product__c=prod[16].id;
            oli22.vlocity_cmt__ParentItemId__c=null;
            oli22.vlocity_cmt__EffectiveQuantity__c=1;
            oliList.add(oli22);
            
            insert oliList;           
            oli10.vlocity_cmt__ParentItemId__c=oli2.Id;
            oli10.vlocity_cmt__RootItemId__c = oli2.Id; 
            update oli10;
            
            List<TeliaSE_SimplifiedQuoteLineItem__c> sliList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            TeliaSE_SimplifiedQuoteLineItem__c sqli1 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli1.Product__c=prod[1].id;
            sqli1.QuoteId__c=qut.id;            
            sqli1.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli1.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli1.TeliaSE_MC_Binding_Time__c= '12';
            sqli1.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli1.TeliaSE_Aggregated_Quantity__c=5;
            sqli1.TeliaSE_Root_Product__c=null;
            sqli1.MC_TeliaExcludeQuoteItem__c=false;  
            sqli1.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli1);
            Id newId;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli2 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli2.Product__c=prod[2].id;
            sqli2.QuoteId__c=qut.id;
            sqli2.Quote_Member__c=null;
            sqli2.Quote_Group__c=null;            
            sqli2.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli2.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli2.TeliaSE_MC_Binding_Time__c= '12';
            sqli2.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli2.TeliaSE_Aggregated_Quantity__c=1;
            sqli2.TeliaSE_Root_Product__c=null;
            sqli2.MC_TeliaExcludeQuoteItem__c=true;  
            sqli2.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli2);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli3 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli3.Product__c=prod[3].id;
            sqli3.QuoteId__c=qut.id;
            sqli3.Quote_Member__c=null;
            sqli3.Quote_Group__c=null;            
            sqli3.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli3.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli3.TeliaSE_MC_Binding_Time__c= '12';
            sqli3.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli3.TeliaSE_Aggregated_Quantity__c=1;
            sqli3.TeliaSE_Root_Product__c=null;
            sqli3.MC_TeliaExcludeQuoteItem__c=true;  
            sqli3.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli3);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli4 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli4.Product__c=prod[4].id;
            sqli4.QuoteId__c=qut.id;
            sqli4.Quote_Member__c=null;
            sqli4.Quote_Group__c=null;            
            sqli4.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli4.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli4.TeliaSE_MC_Binding_Time__c= '12';
            sqli4.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli4.TeliaSE_Aggregated_Quantity__c=1;
            sqli4.TeliaSE_Root_Product__c=null;
            sqli4.MC_TeliaExcludeQuoteItem__c=false;  
            sqli4.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli4);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli5 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli5.Product__c=prod[5].id;
            sqli5.QuoteId__c=qut.id;          
            sqli5.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli5.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli5.TeliaSE_MC_Binding_Time__c= '12';
            sqli5.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli5.TeliaSE_Aggregated_Quantity__c=1;
            sqli5.TeliaSE_Root_Product__c=null;
            sqli5.MC_TeliaExcludeQuoteItem__c=false;  
            sqli5.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli5);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli6 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli6.Product__c=prod[6].id;
            sqli6.QuoteId__c=qut.id;            
            sqli6.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli6.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli6.TeliaSE_MC_Binding_Time__c= '12';
            sqli6.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli6.TeliaSE_Aggregated_Quantity__c=1;
            sqli6.TeliaSE_Root_Product__c=null;
            sqli6.MC_TeliaExcludeQuoteItem__c=false;  
            sqli6.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli6);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli7 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli7.Product__c=prod[14].id;
            sqli7.QuoteId__c=qut.id;            
            sqli7.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli7.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli7.TeliaSE_MC_Binding_Time__c= '12';
            sqli7.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli7.TeliaSE_Aggregated_Quantity__c=1;
            sqli7.TeliaSE_Root_Product__c=null;
            sqli7.MC_TeliaExcludeQuoteItem__c=false;  
            sqli7.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli7);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli8 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli8.Product__c=prod[8].id;
            sqli8.QuoteId__c=qut.id;          
            sqli8.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli8.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli8.TeliaSE_MC_Binding_Time__c= '12';
            sqli8.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli8.TeliaSE_Aggregated_Quantity__c=1;
            sqli8.TeliaSE_Root_Product__c=null;
            sqli8.MC_TeliaExcludeQuoteItem__c=false;  
            sqli8.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli8);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli9 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli9.Product__c=prod[9].id;
            sqli9.QuoteId__c=qut.id;           
            sqli9.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli9.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli9.TeliaSE_MC_Binding_Time__c= '12';
            sqli9.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli9.TeliaSE_Aggregated_Quantity__c=1;
            sqli9.TeliaSE_Root_Product__c=null;
            sqli9.MC_TeliaExcludeQuoteItem__c=false;  
            sqli9.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli9);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli10 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli10.Product__c=prod[10].id;
            sqli10.QuoteId__c=qut.id;          
            sqli10.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli10.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli10.TeliaSE_MC_Binding_Time__c= '12';
            sqli10.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli10.TeliaSE_Aggregated_Quantity__c=1;
            sqli10.TeliaSE_Root_Product__c=null;
            sqli10.MC_TeliaExcludeQuoteItem__c=false;  
            sqli10.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli10);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli11 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli11.Product__c=prod[11].id;
            sqli11.QuoteId__c=qut.id;            
            sqli11.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli11.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli11.TeliaSE_MC_Binding_Time__c= '12';
            sqli11.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli11.TeliaSE_Aggregated_Quantity__c=1;
            sqli11.TeliaSE_Root_Product__c=null;
            sqli11.MC_TeliaExcludeQuoteItem__c=false;  
            sqli11.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli11);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli12 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli12.Product__c=prod[12].id;
            sqli12.QuoteId__c=qut.id;           
            sqli12.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli12.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli12.TeliaSE_MC_Binding_Time__c= '12';
            sqli12.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli12.TeliaSE_Aggregated_Quantity__c=1;
            sqli12.TeliaSE_Root_Product__c=null;
            sqli12.MC_TeliaExcludeQuoteItem__c=false;  
            sqli12.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli12);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli13 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli13.Product__c=prod[13].id;
            sqli12.QuoteId__c=qut.id;            
            sqli13.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli13.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli13.TeliaSE_MC_Binding_Time__c= '12';
            sqli13.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli13.TeliaSE_Aggregated_Quantity__c=1;
            sqli13.TeliaSE_Root_Product__c=null;
            sqli13.MC_TeliaExcludeQuoteItem__c=false;  
            sqli13.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli13);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli14 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli14.Product__c=prod[14].id; 
            sqli12.QuoteId__c=qut.id;
            sqli14.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli14.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli14.TeliaSE_MC_Binding_Time__c= '12';
            sqli14.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli14.TeliaSE_Aggregated_Quantity__c=1;
            sqli14.TeliaSE_Root_Product__c=null;
            sqli14.MC_TeliaExcludeQuoteItem__c=false;  
            sqli14.TeliaSE_Parent_ItemId__c= null;
            sliList.add(sqli14);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli15 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli15.Product__c=prod[15].id;
            sqli15.QuoteId__c=qut.id;
            sqli15.Quote_Member__c=null;
            sqli15.Quote_Group__c=null;
            //sqli15.Product_Code__c = 'MOB_SP_ADDON_ABROAD_SURF';            
            sqli15.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli15.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli15.TeliaSE_MC_Binding_Time__c= '12';
            sqli15.MC_Initial_Order_Quantity__c= 2;
            sqli15.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli15.TeliaSE_Aggregated_Quantity__c=1;
            sqli15.TeliaSE_Root_Product__c=null;
            sqli15.MC_TeliaExcludeQuoteItem__c=false;  
            sqli15.TeliaSE_Parent_ItemId__c= null;
            //sqli15.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            sqli15.TeliaSE_Product_Hierarchy__c=prod[5].id;
            sliList.add(sqli15);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli153 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli153.Product__c=prod[16].id;
            sqli153.QuoteId__c=qut.id;
            sqli153.Quote_Member__c=null;
            sqli153.Quote_Group__c=null;
            //sqli15.Product_Code__c = 'MOB_SP_ADDON_ABROAD_SURF';            
            sqli153.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli153.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli153.TeliaSE_MC_Binding_Time__c= '12';
            sqli153.MC_Initial_Order_Quantity__c= 2;
            sqli153.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli153.TeliaSE_Aggregated_Quantity__c=1;
            sqli153.TeliaSE_Root_Product__c=null;
            sqli153.MC_TeliaExcludeQuoteItem__c=false;  
            sqli153.TeliaSE_Parent_ItemId__c= null;
            //sqli15.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            sqli153.TeliaSE_Product_Hierarchy__c=prod[5].id;
            sliList.add(sqli153);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli16 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli16.Product__c=prod[17].id;
            sqli16.QuoteId__c=qut.id;
            sqli16.Quote_Member__c=null;
            sqli16.Quote_Group__c=null; 
            //sqli16.Product_Code__c = 'MOB_SP_ADDON_ABROAD_SURF';
            sqli16.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli16.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli16.TeliaSE_MC_Binding_Time__c= '12';
            sqli16.MC_Initial_Order_Quantity__c= 2;
            sqli16.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli16.TeliaSE_Aggregated_Quantity__c=1;
            sqli16.TeliaSE_Root_Product__c=null;
            sqli16.MC_TeliaExcludeQuoteItem__c=false;  
            sqli16.TeliaSE_Parent_ItemId__c= null;
            sqli16.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            sliList.add(sqli16);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli17 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli17.Product__c=prod[0].id;
            sqli17.QuoteId__c=qut.id;
            sqli17.Quote_Member__c=null;
            sqli17.Quote_Group__c=null;            
            sqli17.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli17.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli17.TeliaSE_MC_Binding_Time__c= '12';
            sqli17.MC_Initial_Order_Quantity__c= 2;
            sqli17.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli17.TeliaSE_Aggregated_Quantity__c=1;
            sqli17.TeliaSE_Root_Product__c=null;
            sqli17.MC_TeliaExcludeQuoteItem__c=false;  
            sqli17.TeliaSE_Parent_ItemId__c= null;
            sqli17.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            sliList.add(sqli17);
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli18 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli18.Product__c=prod[18].id;
            sqli18.QuoteId__c=qut.id;
            sqli18.Quote_Member__c=null;
            sqli18.Quote_Group__c=null;            
            sqli18.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli18.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli18.TeliaSE_MC_Binding_Time__c= '12';
            sqli18.MC_Initial_Order_Quantity__c= 2;
            sqli18.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli18.TeliaSE_Aggregated_Quantity__c=1;
            sqli18.TeliaSE_Root_Product__c=null;
            sqli18.MC_TeliaExcludeQuoteItem__c=false;  
            sqli18.TeliaSE_Parent_ItemId__c= newId;
            sqli18.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            sliList.add(sqli18);
            insert sliList;
          
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger';      
            cv.PathOnClient ='test';           
            cv.VersionData =beforeblob;          
            insert cv;  
            
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=qut.id;
            contentlink.ShareType= 'V';
            contentlink.ContentDocumentId=testcontent.ContentDocumentId;
            insert contentlink;
            
            //Test.stopTest();
        }
    }
    
    /*@isTest()
    static void test_validateOfferData(){
        String JsonResponse = '{"FamilyOfferingQLIlist":[{"ProductId":"01t0Q000004jXuZQAU","PriceEntryID":"01u0Q00000ApaWSQAZ","SFDCProductName":"Personlig tekniker Plus","Name":"Personlig Tekniker Plus","ProductType":"Personal Technician Offer Specification","$$hashKey":"object:189","NewSalesEngangsavgift":12,"NewSalesAngesnittmanadsavgift":12,"NewSalesAntal":6,"NewSalesType":"New Sales - Nya tjÃ¤nster","ContinuousSalesAngesnittmanadsavgift":23,"ContinuousSalesAntal":8,"ContinuousSalesType":"Continuation Sales - Migrering av tjÃ¤nst"},{"ProductId":"01t0Q000004jQAU","PriceEntryID":"01u0Q00000AAZ","SFDCProductName":"Personlig tekniker Plus","Name":"Personlig Tekniker Plus","ProductType":"Personal Technician Offer Specification","$$hashKey":"object:189"},{"ProductId":"01t0Q0000","PriceEntryID":"01u0Q00000A","SFDCProductName":"Personlig tekniker Plus","Name":"Personlig Tekniker Plus","ProductType":"Personal Technician Offer Specification","$$hashKey":"object:189","NewSalesEngangsavgift":12,"NewSalesAngesnittmanadsavgift":12,"NewSalesAntal":0,"ContinuousSalesAngesnittmanadsavgift":23,"ContinuousSalesAntal":8,"ContinuousSalesType":"Continuation Sales - Migrering av tjÃ¤nst"},{"ProductId":"01t0Q0000","PriceEntryID":"01u0Q00000A","SFDCProductName":"Personlig tekniker Plus","Name":"Personlig Tekniker Plus","ProductType":"Personal Technician Offer Specification","$$hashKey":"object:189","NewSalesEngangsavgift":12,"NewSalesAngesnittmanadsavgift":12,"NewSalesAntal":6,"ContinuousSalesAngesnittmanadsavgift":23,"ContinuousSalesAntal":8}]}';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        TeliaSE_Offerhelper toffer = new TeliaSE_Offerhelper();
        toffer.invokeMethod('validateOfferData',inputMap,outMap,optionsMap);
    }*/
    
    @isTest()
    static void test_withdrawQuote(){
        Quote quote=[select id from Quote where name='Test Quote'];
        
        String methodname = 'WithdrawQuote';
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>(); 
        inputMap.put('ContextId',quote.Id);
        
        quote.TeliaSE_Locked__c=false;
        quote.status='Draft';
        update quote;
        
        TeliaSE_Offerhelper obj2 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj2.invokeMethod(methodname,inputMap,outMap,options);
        Test.stopTest();
    }
    
    @isTest()
    static void test_discount(){
        Quote  quo=[select Id,TeliaSE_Fiber_EBIT_Percentage__c from Quote where name = 'Test Quote'];
        TeliaSE_Offerhelper obj1=new TeliaSE_Offerhelper();
        String methodname = 'discount';
        Map<String,Object> inputMap = new  Map<String,Object>();
        inputMap.put('ContextId',quo.Id);
        
        Map<String,Object> outMap = new  Map<String,Object>();        
        Map<String,Object> options = new  Map<String,Object>(); 
        
        Test.startTest();
        obj1.invokeMethod('discount',inputMap,outMap,options);
        //obj1.invokeMethod('WithdrawQuote',inputMap,outMap,options);
        obj1.invokeMethod('',inputMap,outMap,options);
        Test.stopTest();
    }
    
    @isTest()
    static void test_isRecordLocked(){
        Quote quote =[select Id from Quote where name = 'Test Quote'];
        
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();        
        Map<String,Object> options = new  Map<String,Object>(); 
        
        inputMap.put('ContextId',quote.Id);
        
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('isRecordLocked',inputMap,outMap,options);
        Test.stopTest();
    }

     @isTest()
    static void test_getCampaignDetails(){
        Quote quote =[select Id from Quote where name = 'Test Quote'];
        
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();        
        Map<String,Object> options = new  Map<String,Object>(); 
        String campaignInputJSON = '{"CampaignQLIs":[{"ProductName":"E-simkloka","CampaignName":"TestCampaignName","RootItemId":"875943","CommercialTerms":{"campaignExist":"true"}},{"ProductName":"E-simkloka","CampaignName":"TestCampaignName","RootItemId":"875943","CommercialTerms":{"paymentTerms":"20"}}]}';
        inputMap= ((Map<String,Object>)json.deserializeUntyped(campaignInputJSON));
        
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('getCampaignDetails',inputMap,outMap,options);
        Test.stopTest();
    }
    
     @isTest()
    static void test_commercialTermsChangeCheck(){
        Quote quote =[select Id from Quote where name = 'Test Quote'];
        
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();        
        Map<String,Object> options = new  Map<String,Object>(); 
        String commercialTermsInputJSON = '{"Quote":{"ApprovalCount":2,"Volume":"10","SalesFlowIdentifier":"Omforhandling","Status":"Draft","Type":"Contract","Benchmark":"Nej","InvoiceFee":"Nej","CommericalTerms":{"Payment Terms":30,"Invoice Fee":"Ja","Benchmarking Agreements":"Nej","IndexationClause":"ja"},"PaymentTerms":"30","InvoiceFee":"Ja","Benchmark":"Nej","IndexationClause":"Ja"},"CommercialTermsQLIs":[{"ObjectType":"Mobile Offer Specification","RootItemId":"0QL3H000001vzyMWAQ","MinimumCommit":"75"},{"ObjectType":"Broadband Start Offering Spec","RootItemId":"0QL3H000001vzyMWAQ","OCNDiscount":"60"}],"PaymentTerms":"90","InvoiceFee":"Nej","Benchmark":"Ja","IndexationClause":"Nej"}';
        inputMap= ((Map<String,Object>)json.deserializeUntyped(commercialTermsInputJSON));
        
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('commercialTermsChangeCheck',inputMap,outMap,options);
        Test.stopTest();
    }
    
     @isTest()
    static void test_getIncludedOffers(){
        Quote quote =[select Id from Quote where name = 'Test Quote'];
        
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();        
        Map<String,Object> options = new  Map<String,Object>(); 
        inputMap.put('OpportunityId','dummyId');
        inputMap.put('ContextId',quote.Id);
        inputMap.put('parentQuote',quote.Id);
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('includedOffers',inputMap,outMap,options);
        Test.stopTest();
    }
    
    @isTest()
    static void test_approval(){
        Quote quote =[select Id from Quote where name = 'Test Quote'];
        
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();        
        Map<String,Object> options = new  Map<String,Object>(); 
        inputMap.put('RenegotiationIdentifier','Renegotiation');
        inputMap.put('options',quote.id);
        inputMap.put('ContextId',quote.id);
        
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('Approval',inputMap,outMap,options);
        Test.stopTest();
    }
    
    @isTest()
    static void test_approval2(){
        Quote quote =[SELECT Id FROM Quote WHERE Name = 'Test Quote'];
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();        
        Map<String,Object> options = new Map<String,Object>(); 
        inputMap.put('options',quote.id);
        inputMap.put('ContextId',quote.id);
        
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('Approval',inputMap,outMap,options);
        Test.stopTest();
    }
    
    @isTest()
    static void test_fiberApproval(){
        Quote quote =[SELECT Id FROM Quote WHERE Name = 'Test Quote'];
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();        
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('RenegotiationIdentifier','Renegotiation');
        inputMap.put('options',quote.id);
        inputMap.put('ContextId',quote.id);
        
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('FiberApproval',inputMap,outMap,options);
        Test.stopTest();
    }
    
     @isTest()
    static void test_fiberApproval2(){
        Quote quote =[SELECT Id FROM Quote WHERE Name = 'Test Quote'];
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();        
        Map<String,Object> options = new Map<String,Object>(); 
        inputMap.put('options',quote.id);
        inputMap.put('ContextId',quote.id);
        
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('FiberApproval',inputMap,outMap,options);
        Test.stopTest();
    }
    
     @isTest()
    static void test_putSelectedOffers(){
        Quote quote =[SELECT Id FROM Quote WHERE Name = 'Test Quote'];
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();        
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('ContextId',quote.id);
        
        List<Map<String,String>> lines=new List<Map<String,String>>();
        Map<String,Object> quoteMap=new Map<String,Object>();
        Map<String,String> line=new Map<String,String>();
        
        line.put('Name','Office');
        lines.add(line);
        quoteMap.put('Line',lines);
        inputMap.put('Offer',quoteMap);
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('putSelectedOffers',inputMap,outMap,options);
        Test.stopTest();
    }
    
    @isTest()
    static void test_simplifiedItems(){
        Quote quote =[SELECT Id FROM Quote WHERE Name = 'Test Quote'];
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();        
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('ContextId',quote.id);
        
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('SimplifiedItems',inputMap,outMap,options);
        obj1.invokeMethod('ReCalculate',inputMap,outMap,options);
        Test.stopTest();
    }
    
    @isTest()
    static void test_updateRootApprovalFlag(){
        Quote quote =[SELECT Id FROM Quote WHERE Name = 'Test Quote'];
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();        
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('ContextId',quote.id);
        String commercialTermsInputJSON = '{ "CampaignRootItemsSet": "", "commercialTermsRootsSet": "", "QuoteLineItems": [{ "RootProductId": "01t3H000002eZx7QAE", "ObjectType": "Binding OTC Offering Spec", "ParentItemId": "0QL3H000001wJoXWAU", "RootItemId": "0QL3H000001wJoTWAU", "ApprovalFlag": "/resource/1555137213000/TeliaSE_Happy_Face", "RootPriceFlag": false }, { "RootProductId": "01t3H000002eZx7QAE", "ObjectType": "Binding OTC Offering Spec", "ParentItemId": "0QL3H000001wJoXWAU", "RootItemId": "0QL3H000001wJoTWAU", "ApprovalFlag": "/resource/1549883728000/TeliaSE_Happy_Face", "RootPriceFlag": false } ] }';
        inputMap= ((Map<String,Object>)json.deserializeUntyped(commercialTermsInputJSON));
        
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('updateRootApprovalFlag',inputMap,outMap,options);
        Test.stopTest();
    }
    
    @isTest()
    static void test_getProductsList(){
        Quote quote =[select Id from Quote where name = 'Test Quote'];
        
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();        
        Map<String,Object> options1 = new  Map<String,Object>(); 
        Map<String,Object> options2 = new  Map<String,Object>();
        options1.put('AccountType','Enterprise SME');
        options2.put('AccountType','Enterprise Large');
        TeliaSE_Offerhelper obj1 = new TeliaSE_Offerhelper();
        Test.startTest();
        obj1.invokeMethod('getProductsList',inputMap,outMap,options1);
        obj1.invokeMethod('getProductsList',inputMap,outMap,options2);
        Test.stopTest();
    }
}