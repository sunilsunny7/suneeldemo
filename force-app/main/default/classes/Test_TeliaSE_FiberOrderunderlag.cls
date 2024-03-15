@isTest
public with sharing class Test_TeliaSE_FiberOrderunderlag {
    @isTest
    public static void FunctionEval(){
        //User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        //salesManager = Test_DataFactory.createAdminUser();
        //salesManager.ForecastEnabled = true;
        //salesManager.Bypass_VR__c = true;
        //insert salesManager;
        System.runAs(Test_DataFactory.getByPassUser()){
            Map<String,Object> inputs=new Map<String,Object>();
            Map<String,Object> inputMap=new Map<String,Object>();
            Map<String,Object> output=new Map<String,Object>();
            Map<String,Object> outputMap=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            
            List<Product2> prodList = new List<product2>();
            
            vlocity_cmt__ObjectClass__c newObj=new vlocity_cmt__ObjectClass__c();
            newObj.Name = 'Fiber Base Product Spec Type';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Fastighetsstyrning Internet 2 Mbit/s';
            prod1.productCode = 'MDU_FS_Internet_2_2019';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod1);
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.name = 'Fastighetsstyrning Internet 10 Mbit/s';
            prod2.productCode = 'MDU_FS_Internet_10_2019';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.name = 'Fastighetsstyrning Internet 100 Mbit/s';
            prod3.productCode = 'MDU_FS_Internet_100_2019';
            prod3.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.name = 'Fastighetsstyrning Internet 1000 Mbit/s';
            prod4.productCode = 'MDU_FS_Internet_1000_2019';
            prod4.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod4);
            
            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.name = 'Fastighetsstyrning IP-VPN 2 Mbit/s';
            prod5.productCode = 'MDU_FS_IP-VPN_2_2019';
            prod5.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod5);
            
            Product2 prod6 = Test_DataFactory.createProducts(1)[0];
            prod6.name = 'Fastighetsstyrning IP-VPN 10 Mbit/s';
            prod6.productCode = 'MDU_FS_IP-VPN_10_2019';
           prod6.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod6);
            
            Product2 prod7 = Test_DataFactory.createProducts(1)[0];
            prod7.name = 'Fastighetsstyrning IP-VPN 100 Mbit/s';
            prod7.productCode = 'MDU_FS_IP-VPN_100_2019';
            prod7.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod7);
            
            Product2 prod8 = Test_DataFactory.createProducts(1)[0];
            prod8.name = 'Fastighetsstyrning IP-VPN 1000 Mbit/s';
            prod8.productCode = 'MDU_FS_IP-VPN_1000_2019';
            prod8.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod8);
            
            Product2 prod9 = Test_DataFactory.createProducts(1)[0];
            prod9.name = 'Fastighetsstyrning VPN 2 Mbit/s';
            prod9.productCode = 'MDU_FS_VPN_2_2019';
            prod9.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod9);
            
            Product2 prod10 = Test_DataFactory.createProducts(1)[0];
            prod10.name = 'Fastighetsstyrning VPN 10 Mbit/s';
            prod10.productCode = 'MDU_FS_VPN_10_2019';
            prod10.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod10);
            
            Product2 prod11 = Test_DataFactory.createProducts(1)[0];
            prod11.name = 'Fastighetsstyrning VPN 100 Mbit/s';
            prod11.productCode = 'MDU_FS_VPN_100_2019';
            prod11.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod11);
            
            Product2 prod12 = Test_DataFactory.createProducts(1)[0];
            prod12.name = 'Fastighetsstyrning VPN 1000 Mbit/s';
            prod12.productCode = 'MDU_FS_VPN_1000_2019';
            prod12.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod12);
            
            Product2 prod13 = Test_DataFactory.createProducts(1)[0];
            prod13.name = 'Fastighetsstyrning Etableringsport 100';
            prod13.productCode = 'FS_Etableringsport_100_2019';
            prod13.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod13);
            
            Product2 prod14 = Test_DataFactory.createProducts(1)[0];
            prod14.name = 'Fastighetsstyrning Etableringsport 1000';
            prod14.productCode = 'FS_Etableringsport_1000_2019';
            prod14.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod14);
            
            Product2 prod15 = Test_DataFactory.createProducts(1)[0];
            prod15.name = 'Fastighetsstyrning Etableringsport 10000';
            prod15.productCode = 'FS_Etableringsport_10000_2019';
            prod15.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod15);
            
            Product2 prod16 = Test_DataFactory.createProducts(1)[0];
            prod16.name = 'Fastighetsstyrning Etableringsport VPN 100';
            prod16.productCode = 'FS_Etableringsport-VPN_100_2019';
            prod16.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod16);
            
            Product2 prod17 = Test_DataFactory.createProducts(1)[0];
            prod17.name = 'Fastighetsstyrning Etableringsport VPN 1000';
            prod17.productCode = 'FS_Etableringsport-VPN_1000_2019';
            prod17.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod17);
            
            Product2 prod18 = Test_DataFactory.createProducts(1)[0];
            prod18.name = 'Fastighetsstyrning Etableringsport VPN 10000';
            prod18.productCode = 'FS_Etableringsport-VPN_10000_2019';
            prod18.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod18);
            
            Product2 prod19 = Test_DataFactory.createProducts(1)[0];
            prod19.name = 'Fastighetsstyrning Nationellt tillägg';
            prod19.productCode = 'FS_Nationellt-tillagg_2019';
            prod19.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod19);
            
            Product2 prod20 = Test_DataFactory.createProducts(1)[0];
            prod20.name = 'Installationsavgift för Fastighetstyrningsport';
            prod20.productCode = 'MDU_FS_InstallationFee_2019';
            prod20.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod20);
            
            Product2 prod21 = Test_DataFactory.createProducts(1)[0];
            prod21.name = 'Halebop 100';
            prod21.productCode = 'HalebopBB_100';
            prod21.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod21);
            
            Product2 prod22 = Test_DataFactory.createProducts(1)[0];
            prod22.name = 'Halebop 250';
            prod22.productCode = 'HalebopBB_250';
            prod22.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod22);
            
            Product2 prod23 = Test_DataFactory.createProducts(1)[0];
            prod23.name = 'Halebop 500';
            prod23.productCode = 'HalebopBB_500';
            prod23.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod23);
            
            Product2 prod24 = Test_DataFactory.createProducts(1)[0];
            prod24.name = 'Halebop 1000';
            prod24.productCode = 'HalebopBB_1000';
            prod24.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod24);
            
            Product2 prod25 = Test_DataFactory.createProducts(1)[0];
            prod25.name = 'Tv - Allmänna utrymmen - Start';
            prod25.productCode = 'MDU_CollIPTVB2B_Start_2143';
            prod25.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod25);
            
            Product2 prod26 = Test_DataFactory.createProducts(1)[0];
            prod26.name = 'Tv - Allmänna utrymmen - Bas';
            prod26.productCode = 'MDU_CollIPTVB2B_Bas_2143';
            prod26.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod26);
            
            Product2 prod27 = Test_DataFactory.createProducts(1)[0];
            prod27.name = 'Tv - Allmänna utrymmen - Lagom';
            prod27.productCode = 'MDU_CollIPTVB2B_Lagom_2143';
            prod27.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod27);
            
            insert prodList;
            
            List<PricebookEntry> pbelist = new List<PricebookEntry>();

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
            
            PricebookEntry objpricebookentry7 =new PricebookEntry();
            objpricebookentry7.Product2ID = prod7.id;
            objpricebookentry7.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry7.UnitPrice=23.50;
            objpricebookentry7.UseStandardPrice=false;
            objpricebookentry7.isActive=true;//Add this line
            pbeList.add(objpricebookentry7);
            
            PricebookEntry objpricebookentry8 =new PricebookEntry();
            objpricebookentry8.Product2ID = prod8.id;
            objpricebookentry8.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry8.UnitPrice=23.50;
            objpricebookentry8.UseStandardPrice=false;
            objpricebookentry8.isActive=true;//Add this line
            pbeList.add(objpricebookentry8); 
            
            PricebookEntry objpricebookentry9 =new PricebookEntry();
            objpricebookentry9.Product2ID = prod9.id;
            objpricebookentry9.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry9.UnitPrice=23.50;
            objpricebookentry9.UseStandardPrice=false;
            objpricebookentry9.isActive=true;//Add this line
            pbeList.add(objpricebookentry9);
            
            PricebookEntry objpricebookentry10 =new PricebookEntry();
            objpricebookentry10.Product2ID = prod10.id;
            objpricebookentry10.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry10.UnitPrice=23.50;
            objpricebookentry10.UseStandardPrice=false;
            objpricebookentry10.isActive=true;//Add this line
            pbeList.add(objpricebookentry10);
            
            PricebookEntry objpricebookentry11 =new PricebookEntry();
            objpricebookentry11.Product2ID = prod11.id;
            objpricebookentry11.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry11.UnitPrice=23.50;
            objpricebookentry11.UseStandardPrice=false;
            objpricebookentry11.isActive=true;//Add this line
            pbeList.add(objpricebookentry11);
            
            PricebookEntry objpricebookentry12 =new PricebookEntry();
            objpricebookentry12.Product2ID = prod12.id;
            objpricebookentry12.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry12.UnitPrice=23.50;
            objpricebookentry12.UseStandardPrice=false;
            objpricebookentry12.isActive=true;//Add this line
            pbeList.add(objpricebookentry12);
            
            PricebookEntry objpricebookentry13 =new PricebookEntry();
            objpricebookentry13.Product2ID = prod13.id;
            objpricebookentry13.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry13.UnitPrice=23.50;
            objpricebookentry13.UseStandardPrice=false;
            objpricebookentry13.isActive=true;//Add this line
            pbeList.add(objpricebookentry13); 
            
            PricebookEntry objpricebookentry14 =new PricebookEntry();
            objpricebookentry14.Product2ID = prod14.id;
            objpricebookentry14.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry14.UnitPrice=23.50;
            objpricebookentry14.UseStandardPrice=false;
            objpricebookentry14.isActive=true;//Add this line
            pbeList.add(objpricebookentry14);
            
            PricebookEntry objpricebookentry15 =new PricebookEntry();
            objpricebookentry15.Product2ID = prod15.id;
            objpricebookentry15.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry15.UnitPrice=23.50;
            objpricebookentry15.UseStandardPrice=false;
            objpricebookentry15.isActive=true;//Add this line
            pbeList.add(objpricebookentry15);
            
            PricebookEntry objpricebookentry16 =new PricebookEntry();
            objpricebookentry16.Product2ID = prod16.id;
            objpricebookentry16.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry16.UnitPrice=23.50;
            objpricebookentry16.UseStandardPrice=false;
            objpricebookentry16.isActive=true;//Add this line
            pbeList.add(objpricebookentry16);
            
            PricebookEntry objpricebookentry17 =new PricebookEntry();
            objpricebookentry17.Product2ID = prod17.id;
            objpricebookentry17.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry17.UnitPrice=23.50;
            objpricebookentry17.UseStandardPrice=false;
            objpricebookentry17.isActive=true;//Add this line
            pbeList.add(objpricebookentry17);
            
            PricebookEntry objpricebookentry18 =new PricebookEntry();
            objpricebookentry18.Product2ID = prod18.id;
            objpricebookentry18.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry18.UnitPrice=23.50;
            objpricebookentry18.UseStandardPrice=false;
            objpricebookentry18.isActive=true;//Add this line
            pbeList.add(objpricebookentry18); 
            
            PricebookEntry objpricebookentry19 =new PricebookEntry();
            objpricebookentry19.Product2ID = prod19.id;
            objpricebookentry19.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry19.UnitPrice=23.50;
            objpricebookentry19.UseStandardPrice=false;
            objpricebookentry19.isActive=true;//Add this line
            pbeList.add(objpricebookentry19);
            
            PricebookEntry objpricebookentry20 =new PricebookEntry();
            objpricebookentry20.Product2ID = prod20.id;
            objpricebookentry20.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry20.UnitPrice=23.50;
            objpricebookentry20.UseStandardPrice=false;
            objpricebookentry20.isActive=true;//Add this line
            pbeList.add(objpricebookentry20);
            
            PricebookEntry objpricebookentry21 =new PricebookEntry();
            objpricebookentry21.Product2ID = prod21.id;
            objpricebookentry21.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry21.UnitPrice=23.50;
            objpricebookentry21.UseStandardPrice=false;
            objpricebookentry21.isActive=true;//Add this line
            pbeList.add(objpricebookentry21);
            
            PricebookEntry objpricebookentry22 =new PricebookEntry();
            objpricebookentry22.Product2ID = prod22.id;
            objpricebookentry22.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry22.UnitPrice=23.50;
            objpricebookentry22.UseStandardPrice=false;
            objpricebookentry22.isActive=true;//Add this line
            pbeList.add(objpricebookentry22);
            
            PricebookEntry objpricebookentry23 =new PricebookEntry();
            objpricebookentry23.Product2ID = prod23.id;
            objpricebookentry23.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry23.UnitPrice=23.50;
            objpricebookentry23.UseStandardPrice=false;
            objpricebookentry23.isActive=true;//Add this line
            pbeList.add(objpricebookentry23);
            
            PricebookEntry objpricebookentry24 =new PricebookEntry();
            objpricebookentry24.Product2ID = prod24.id;
            objpricebookentry24.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry24.UnitPrice=23.50;
            objpricebookentry24.UseStandardPrice=false;
            objpricebookentry24.isActive=true;//Add this line
            pbeList.add(objpricebookentry24);
            
            PricebookEntry objpricebookentry25 =new PricebookEntry();
            objpricebookentry25.Product2ID = prod25.id;
            objpricebookentry25.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry25.UnitPrice=23.50;
            objpricebookentry25.UseStandardPrice=false;
            objpricebookentry25.isActive=true;//Add this line
            pbeList.add(objpricebookentry25);
            
            PricebookEntry objpricebookentry26 =new PricebookEntry();
            objpricebookentry26.Product2ID = prod26.id;
            objpricebookentry26.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry26.UnitPrice=23.50;
            objpricebookentry26.UseStandardPrice=false;
            objpricebookentry26.isActive=true;//Add this line
            pbeList.add(objpricebookentry26);
            
            PricebookEntry objpricebookentry27 =new PricebookEntry();
            objpricebookentry27.Product2ID = prod27.id;
            objpricebookentry27.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry27.UnitPrice=23.50;
            objpricebookentry27.UseStandardPrice=false;
            objpricebookentry27.isActive=true;//Add this line
            pbeList.add(objpricebookentry27);
            
            insert pbeList;
            
            //Creating account
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced RA';
            acc.Org_Nr__c  = '5564110665';
            acc.Name = 'R21.4_Test_CO_Acc_Grouping';
            insert acc;
            
            //Creating opportunity below
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            
           	RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name = 'Connected & Smart Building' and SobjectType = 'Contract'];
            //Creating contract below
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.RecordTypeId = rt1.Id;
            contract.ContractTerm=24;
            contract.Type_of_Address__c = 'MDU';
            contract.Region__c = 'MDU Väst';
            insert contract;
            contract.Status = 'Sent for Signing';
            update contract;
            contract.Status = 'Signed';
            update contract;
            contract.Status = 'Active';
            update contract;
                     
            //Creating contract line items
            List<vlocity_cmt__ContractLineItem__c> cliList = new List<vlocity_cmt__ContractLineItem__c>();

            vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
            cli1.vlocity_cmt__ContractId__c = contract.id;
            cli1.vlocity_cmt__Product2Id__c = prod1.Id;
            cli1.Name ='Fastighetsstyrning Internet 2 Mbit/s';
            cli1.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli1.TeliaSE_Base_Quantity__c =5;
            cli1.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli1);
            
            vlocity_cmt__ContractLineItem__c cli2 = new vlocity_cmt__ContractLineItem__c();
            cli2.vlocity_cmt__ContractId__c = contract.id;
            cli2.vlocity_cmt__Product2Id__c = prod2.Id;
            cli2.Name ='Fastighetsstyrning Internet 10 Mbit/s';
            cli2.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli2.TeliaSE_Base_Quantity__c =5;
            cli2.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli2);
            
            vlocity_cmt__ContractLineItem__c cli3 = new vlocity_cmt__ContractLineItem__c();
            cli3.vlocity_cmt__ContractId__c = contract.id;
            cli3.vlocity_cmt__Product2Id__c = prod3.Id;
            cli3.Name ='Fastighetsstyrning Internet 100 Mbit/s';
            cli3.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli3.TeliaSE_Base_Quantity__c =5;
            cli3.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli3);
            
            vlocity_cmt__ContractLineItem__c cli4 = new vlocity_cmt__ContractLineItem__c();
            cli4.vlocity_cmt__ContractId__c = contract.id;
            cli4.vlocity_cmt__Product2Id__c = prod4.Id;
            cli4.Name ='Fastighetsstyrning Internet 1000 Mbit/s';
            cli4.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli4.TeliaSE_Base_Quantity__c =5;
            cli4.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli4);
            
            vlocity_cmt__ContractLineItem__c cli5 = new vlocity_cmt__ContractLineItem__c();
            cli5.vlocity_cmt__ContractId__c = contract.id;
            cli5.vlocity_cmt__Product2Id__c = prod5.Id;
            cli5.Name ='Fastighetsstyrning IP-VPN 2 Mbit/s';
            cli5.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli5.TeliaSE_Base_Quantity__c =5;
            cli5.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli5);
            
            vlocity_cmt__ContractLineItem__c cli6 = new vlocity_cmt__ContractLineItem__c();
            cli6.vlocity_cmt__ContractId__c = contract.id;
            cli6.vlocity_cmt__Product2Id__c = prod6.Id;
            cli6.Name ='Fastighetsstyrning IP-VPN 10 Mbit/s';
            cli6.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli6.TeliaSE_Base_Quantity__c =5;
            cli6.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli6);
            
            vlocity_cmt__ContractLineItem__c cli7 = new vlocity_cmt__ContractLineItem__c();
            cli7.vlocity_cmt__ContractId__c = contract.id;
            cli7.vlocity_cmt__Product2Id__c = prod7.Id;
            cli7.Name ='Fastighetsstyrning IP-VPN 100 Mbit/s';
            cli7.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli7.TeliaSE_Base_Quantity__c =5;
            cli7.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli7);
            
            vlocity_cmt__ContractLineItem__c cli8 = new vlocity_cmt__ContractLineItem__c();
            cli8.vlocity_cmt__ContractId__c = contract.id;
            cli8.vlocity_cmt__Product2Id__c = prod8.Id;
            cli8.Name ='Fastighetsstyrning IP-VPN 1000 Mbit/s';
            cli8.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli8.TeliaSE_Base_Quantity__c =5;
            cli8.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli8);
            
            vlocity_cmt__ContractLineItem__c cli9 = new vlocity_cmt__ContractLineItem__c();
            cli9.vlocity_cmt__ContractId__c = contract.id;
            cli9.vlocity_cmt__Product2Id__c = prod9.Id;
            cli9.Name ='Fastighetsstyrning VPN 2 Mbit/s';
            cli9.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli9.TeliaSE_Base_Quantity__c =5;
            cli9.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli9);
            
            vlocity_cmt__ContractLineItem__c cli10 = new vlocity_cmt__ContractLineItem__c();
            cli10.vlocity_cmt__ContractId__c = contract.id;
            cli10.vlocity_cmt__Product2Id__c = prod10.Id;
            cli10.Name ='Fastighetsstyrning VPN 10 Mbit/s';
            cli10.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli10.TeliaSE_Base_Quantity__c =5;
            cli10.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli10);
            
            vlocity_cmt__ContractLineItem__c cli11 = new vlocity_cmt__ContractLineItem__c();
            cli11.vlocity_cmt__ContractId__c = contract.id;
            cli11.vlocity_cmt__Product2Id__c = prod11.Id;
            cli11.Name ='Fastighetsstyrning VPN 100 Mbit/s';
            cli11.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli11.TeliaSE_Base_Quantity__c =5;
            cli11.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli11);
            
            vlocity_cmt__ContractLineItem__c cli12 = new vlocity_cmt__ContractLineItem__c();
            cli12.vlocity_cmt__ContractId__c = contract.id;
            cli12.vlocity_cmt__Product2Id__c = prod12.Id;
            cli12.Name ='Fastighetsstyrning VPN 1000 Mbit/s';
            cli12.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli12.TeliaSE_Base_Quantity__c =5;
            cli12.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli12);
            
            vlocity_cmt__ContractLineItem__c cli13 = new vlocity_cmt__ContractLineItem__c();
            cli13.vlocity_cmt__ContractId__c = contract.id;
            cli13.vlocity_cmt__Product2Id__c = prod13.Id;
            cli13.Name ='Fastighetsstyrning Etableringsport 100';
            cli13.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli13.TeliaSE_Base_Quantity__c =5;
            cli13.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli13);
            
            vlocity_cmt__ContractLineItem__c cli14 = new vlocity_cmt__ContractLineItem__c();
            cli14.vlocity_cmt__ContractId__c = contract.id;
            cli14.vlocity_cmt__Product2Id__c = prod14.Id;
            cli14.Name ='Fastighetsstyrning Etableringsport 1000';
            cli14.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli14.TeliaSE_Base_Quantity__c =5;
            cli14.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli14);
            
            vlocity_cmt__ContractLineItem__c cli15 = new vlocity_cmt__ContractLineItem__c();
            cli15.vlocity_cmt__ContractId__c = contract.id;
            cli15.vlocity_cmt__Product2Id__c = prod15.Id;
            cli15.Name ='Fastighetsstyrning Etableringsport 10000';
            cli15.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli15.TeliaSE_Base_Quantity__c =5;
            cli15.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli15);
            
            vlocity_cmt__ContractLineItem__c cli16 = new vlocity_cmt__ContractLineItem__c();
            cli16.vlocity_cmt__ContractId__c = contract.id;
            cli16.vlocity_cmt__Product2Id__c = prod16.Id;
            cli16.Name ='Fastighetsstyrning Etableringsport VPN 100';
            cli16.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli16.TeliaSE_Base_Quantity__c =5;
            cli16.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli16);
            
            vlocity_cmt__ContractLineItem__c cli17 = new vlocity_cmt__ContractLineItem__c();
            cli17.vlocity_cmt__ContractId__c = contract.id;
            cli17.vlocity_cmt__Product2Id__c = prod17.Id;
            cli17.Name ='Fastighetsstyrning Etableringsport VPN 1000';
            cli17.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli17.TeliaSE_Base_Quantity__c =5;
            cli17.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli17);
            
            vlocity_cmt__ContractLineItem__c cli18 = new vlocity_cmt__ContractLineItem__c();
            cli18.vlocity_cmt__ContractId__c = contract.id;
            cli18.vlocity_cmt__Product2Id__c = prod18.Id;
            cli18.Name ='Fastighetsstyrning Etableringsport VPN 10000';
            cli18.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli18.TeliaSE_Base_Quantity__c =5;
            cli18.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli18);
            
            vlocity_cmt__ContractLineItem__c cli19 = new vlocity_cmt__ContractLineItem__c();
            cli19.vlocity_cmt__ContractId__c = contract.id;
            cli19.vlocity_cmt__Product2Id__c = prod19.Id;
            cli19.Name ='Fastighetsstyrning Nationellt tillägg';
            cli19.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli19.TeliaSE_Base_Quantity__c =5;
            cli19.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli19);
            
            vlocity_cmt__ContractLineItem__c cli20 = new vlocity_cmt__ContractLineItem__c();
            cli20.vlocity_cmt__ContractId__c = contract.id;
            cli20.vlocity_cmt__Product2Id__c = prod20.Id;
            cli20.Name ='Installationsavgift för Fastighetstyrningsport';
            cli20.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli20.TeliaSE_Base_Quantity__c =5;
            cli20.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli20);
            
            vlocity_cmt__ContractLineItem__c cli21 = new vlocity_cmt__ContractLineItem__c();
            cli21.vlocity_cmt__ContractId__c = contract.id;
            cli21.vlocity_cmt__Product2Id__c = prod21.Id;
            cli21.Name ='Halebop 100';
            cli21.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli21.TeliaSE_Base_Quantity__c =5;
            cli21.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli21);
            
            vlocity_cmt__ContractLineItem__c cli22 = new vlocity_cmt__ContractLineItem__c();
            cli22.vlocity_cmt__ContractId__c = contract.id;
            cli22.vlocity_cmt__Product2Id__c = prod22.Id;
            cli22.Name ='Halebop 250';
            cli22.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli22.TeliaSE_Base_Quantity__c =5;
            cli22.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli22);
            
            vlocity_cmt__ContractLineItem__c cli23 = new vlocity_cmt__ContractLineItem__c();
            cli23.vlocity_cmt__ContractId__c = contract.id;
            cli23.vlocity_cmt__Product2Id__c = prod23.Id;
            cli23.Name ='Halebop 500';
            cli23.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli23.TeliaSE_Base_Quantity__c =5;
            cli23.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli23);
            
            vlocity_cmt__ContractLineItem__c cli24 = new vlocity_cmt__ContractLineItem__c();
            cli24.vlocity_cmt__ContractId__c = contract.id;
            cli24.vlocity_cmt__Product2Id__c = prod24.Id;
            cli24.Name ='Halebop 1000';
            cli24.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli24.TeliaSE_Base_Quantity__c =5;
            cli24.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli24);
            
            vlocity_cmt__ContractLineItem__c cli25 = new vlocity_cmt__ContractLineItem__c();
            cli25.vlocity_cmt__ContractId__c = contract.id;
            cli25.vlocity_cmt__Product2Id__c = prod25.Id;
            cli25.Name ='Tv - Allmänna utrymmen - Start';
            cli25.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli25.TeliaSE_Base_Quantity__c =5;
            cli25.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli25);
            
            vlocity_cmt__ContractLineItem__c cli26 = new vlocity_cmt__ContractLineItem__c();
            cli26.vlocity_cmt__ContractId__c = contract.id;
            cli26.vlocity_cmt__Product2Id__c = prod26.Id;
            cli26.Name ='Tv - Allmänna utrymmen - Bas';
            cli26.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli26.TeliaSE_Base_Quantity__c =5;
            cli26.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli26);
            
            vlocity_cmt__ContractLineItem__c cli27 = new vlocity_cmt__ContractLineItem__c();
            cli27.vlocity_cmt__ContractId__c = contract.id;
            cli27.vlocity_cmt__Product2Id__c = prod27.Id;
            cli27.Name ='Tv - Allmänna utrymmen - Lagom';
            cli27.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli27.TeliaSE_Base_Quantity__c =5;
            cli27.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli27);
            
            insert cliList;
            
            ID rtd=[select Id from RecordType where sObjectType = 'Quote' And Name = 'Offer Quote'].Id;
            Quote qut = new Quote();
            qut.RecordTypeId=rtd;
            qut.Name='Test Quote';
            qut.status = 'Price Approved';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.Type_of_Address__c = 'MDU';
            //qut.Region__c = 'MDU Väst';

            insert qut;
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry23.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4; 
            oli1.TeliaSE_Approved__c = 12.12; 
            oli1.TeliaSE_Nullify_Check__c = false; 
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli1.vlocity_cmt__Product2Id__c = prod23.id;
            oli1.Fiber_Customer_Requested_Price__c = 400;
            oli1.vlocity_cmt__RecurringCharge__c = 200;       
            qliList.add(oli1);
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry24.Id;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4; 
            oli2.TeliaSE_Approved__c = 12.12; 
            oli2.TeliaSE_Nullify_Check__c = false; 
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli2.vlocity_cmt__Product2Id__c = prod24.id;
            oli2.vlocity_cmt__RecurringCharge__c = 200;       
            qliList.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry21.Id;
            oli3.QuoteId = qut.id;
            oli3.UnitPrice = 200;
            oli3.Quantity = 4; 
            oli3.TeliaSE_Approved__c = 12.12; 
            oli3.TeliaSE_Nullify_Check__c = false; 
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli3.vlocity_cmt__Product2Id__c = prod21.id;
            oli3.Fiber_Customer_Requested_Price__c = 400;  
            qliList.add(oli3);
            
            insert qliList;
            
            //Invocation of class
            
            List<Object> arguments = new List<Object>();
            List<Object> argumentsNew = new List<Object>();
            String cid = contract.id;
            
            arguments.add(cid);
            inputs.put('arguments',arguments);
            
            TeliaSE_FiberOrderunderlag data1 = new TeliaSE_FiberOrderunderlag();
            boolean resOutput = data1.invokeMethod('generateOrderunderlagExtract', inputs, output, options);
            
            cid = qut.id;
            argumentsNew.add(cid);
            inputMap.put('arguments',argumentsNew);
            TeliaSE_FiberOrderunderlag data2 = new TeliaSE_FiberOrderunderlag();
            boolean resOutput2 = data2.invokeMethod('getMRCForHousehold', inputMap, outputMap, options);
            
        }
    }
}