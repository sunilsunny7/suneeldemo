@isTest
public class MCOnline_AgreementContrlService_V1_Test {
    @testSetup
    static void initTestData() { 
        MCOnline_Agreement_Services_Temp_data__c tempData = new MCOnline_Agreement_Services_Temp_data__c();
        MCOnline_Agreement_Services_Temp_data__c tempData1 = new MCOnline_Agreement_Services_Temp_data__c();
        MCOnline_Agreement_Services_Temp_data__c tempData2 = new MCOnline_Agreement_Services_Temp_data__c();
        MCOnline_Agreement_Services_Temp_data__c tempData3 = new MCOnline_Agreement_Services_Temp_data__c();
        MCOnline_Agreement_Services_Temp_data__c tempData4 = new MCOnline_Agreement_Services_Temp_data__c();
        MCOnline_Agreement_Services_Temp_data__c tempData5 = new MCOnline_Agreement_Services_Temp_data__c();
        Contract contr=new Contract();
        Contract contr1=new Contract();
        Contract contr2=new Contract();
        Contract contr3=new Contract();
        Contract contr4=new Contract();
        Contract contr5=new Contract();
        
        List< MCOnline_Agreement_Services_Temp_data__c> tempDataList = new List<MCOnline_Agreement_Services_Temp_data__c>();
        
        tempData.MCOnline_Agreement_number__c ='20984';
        tempData.MCOnline_Service_code__c = 'GPRS';
        tempData.MCOnline_Service_type__c ='836';
        tempData.MCOnline_Service_availability__c ='VAL';
        tempDataList.add(tempData);
        
        tempData1.MCOnline_Agreement_number__c ='20985';
        tempData1.MCOnline_Service_code__c = 'GHEML';
        tempData1.MCOnline_Service_type__c ='458';
        tempData1.MCOnline_Service_availability__c ='OBL';
        tempDataList.add(tempData1);
        
        tempData2.MCOnline_Agreement_number__c ='5465';
        tempData2.MCOnline_Service_code__c = 'GPRS';
        tempData2.MCOnline_Service_type__c ='555';
        tempData2.MCOnline_Service_availability__c ='DEF';
        tempDataList.add(tempData2);
        
        tempData3.MCOnline_Agreement_number__c ='6579';
        tempData3.MCOnline_Service_code__c = 'DOMRO';
        tempData3.MCOnline_Service_type__c ='545';
        tempData3.MCOnline_Service_availability__c ='E';
        tempDataList.add(tempData3);
        
        tempData4.MCOnline_Agreement_number__c ='53027';
        tempData4.MCOnline_Service_code__c = 'HOME';
        tempData4.MCOnline_Service_type__c ='565';
        tempData4.MCOnline_Service_availability__c ='N';
        tempDataList.add(tempData4);
        
        tempData5.MCOnline_Agreement_number__c ='5465';
        tempData5.MCOnline_Service_code__c = 'GPRS';
        tempData5.MCOnline_Service_type__c ='555';
        tempData5.MCOnline_Service_availability__c ='N';
        tempDataList.add(tempData5);
        Insert tempDataList;
        
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        
        List<Contract> conList = new List<Contract>();
        contr.Name='Test1';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        contr.Agreement_Nr__c = '20984';
        conList.add(contr);
        
        contr1.Name='Test2';
        contr1.AccountId=acc.id;
        contr1.Status='Draft';
        contr1.Contract_Record_Type__c='Teliaavtal';
        contr1.Solution_Area__c='Vxl';
        contr1.StartDate=Date.today();
        contr1.ContractTerm=24;
        contr1.Agreement_Nr__c = '20985';
        conList.add(contr1);
        
        contr2.Name='Test3';
        contr2.AccountId=acc.id;
        contr2.Status='Draft';
        contr2.Contract_Record_Type__c='Teliaavtal';
        contr2.Solution_Area__c='Vxl';
        contr2.StartDate=Date.today();
        contr2.ContractTerm=24;
        contr2.Agreement_Nr__c = '5465';
        conList.add(contr2);
        
        contr3.Name='Test4';
        contr3.AccountId=acc.id;
        contr3.Status='Draft';
        contr3.Contract_Record_Type__c='Teliaavtal';
        contr3.Solution_Area__c='Vxl';
        contr3.StartDate=Date.today();
        contr3.ContractTerm=24;
        contr3.Agreement_Nr__c = '6579';
        conList.add(contr3);
        
        contr4.Name='Test5';
        contr4.AccountId=acc.id;
        contr4.Status='Draft';
        contr4.Contract_Record_Type__c='Teliaavtal';
        contr4.Solution_Area__c='Vxl';
        contr4.StartDate=Date.today();
        contr4.ContractTerm=24;
        contr4.Agreement_Nr__c = '53027';
        conList.add(contr4);
        Insert conList;
        
        
        
    }
    @istest
    static  void MandatoryTest() { 
        List<Contract> con=[select id,Agreement_Nr__c  from contract where Name='Test2'];
        Contract con1 = new Contract();
        con1 = con.get(0);
        system.debug('Agr num ==>'+con1.Agreement_Nr__c);
    Product2 prod = new Product2(Name='testProd1',ProductCode='TP-RS-GRP',TeliaSE_Product_Service_Code__c='GHEML');
        insert prod;
        List<Product2> fetchProd =[select id from Product2 where id=: prod.id AND ProductCode=:prod.ProductCode AND TeliaSE_Product_Service_Code__c=:prod.TeliaSE_Product_Service_Code__c ];
        system.assertEquals(1,fetchProd.size());
        vlocity_cmt__ContractLineItem__c item = new vlocity_cmt__ContractLineItem__c(vlocity_cmt__Product2Id__c =prod.id,vlocity_cmt__ContractId__c = con1.id);
    insert item;
        List<vlocity_cmt__ContractLineItem__c> fetchLineItem =[select id from vlocity_cmt__ContractLineItem__c where id=: item.id];
        system.assertEquals(1,fetchLineItem.size());
        system.debug('TeliaSE_Product_Service_Code__c ==>'+prod.TeliaSE_Product_Service_Code__c);
        
    Test.startTest();
        MCOnline_AgreementContrlService_V1 agrUpdate = new MCOnline_AgreementContrlService_V1();
        Database.executeBatch(agrUpdate);
        Test.stopTest();
    }
    
    @istest
    static  void OptionalTest() { 
        List<Contract> con=[select id,Agreement_Nr__c  from contract where Name='Test1'];
        Contract con1 = new Contract();
        con1 = con.get(0);
        system.debug('Agr num ==>'+con1.Agreement_Nr__c);
    Product2 prod = new Product2(Name='testProd2',ProductCode='MOB_SURF_40_V2',TeliaSE_Product_Service_Code__c='GPRS-836');
        insert prod;
        List<Product2> fetchProd =[select id from Product2 where id=: prod.id AND ProductCode=:prod.ProductCode AND TeliaSE_Product_Service_Code__c=:prod.TeliaSE_Product_Service_Code__c ];
        system.assertEquals(1,fetchProd.size());
        vlocity_cmt__ContractLineItem__c item = new vlocity_cmt__ContractLineItem__c(vlocity_cmt__Product2Id__c =prod.id,vlocity_cmt__ContractId__c = con1.id);
    insert item;
        List<vlocity_cmt__ContractLineItem__c> fetchLineItem =[select id from vlocity_cmt__ContractLineItem__c where id=: item.id];
        system.assertEquals(1,fetchLineItem.size());
        system.debug('TeliaSE_Product_Service_Code__c ==>'+prod.TeliaSE_Product_Service_Code__c);
        
    Test.startTest();
        MCOnline_AgreementContrlService_V1 agrUpdate = new MCOnline_AgreementContrlService_V1();
        Database.executeBatch(agrUpdate);
        Test.stopTest();
    }
        
    @istest
    static  void multipleAgreementTest() { 
        List<Contract> con=[select id,Agreement_Nr__c  from contract where Name='Test1'];
        Contract con1 = new Contract();
        con1 = con.get(0);
        system.debug('Agr num ==>'+con1.Agreement_Nr__c);
    Product2 prod = new Product2(Name='testProd2',ProductCode='MOB_SURF_40_V2',TeliaSE_Product_Service_Code__c='GPRS-836');
        insert prod;
        Product2 prod1 = new Product2(Name='testProd3',ProductCode='MOB_SURF_120_V2',TeliaSE_Product_Service_Code__c='GPRS-838');
        insert prod1;
        List<Product2> fetchProd =[select id from Product2 where id=: prod.id AND ProductCode=:prod.ProductCode AND TeliaSE_Product_Service_Code__c=:prod.TeliaSE_Product_Service_Code__c ];
        system.assertEquals(1,fetchProd.size());
        vlocity_cmt__ContractLineItem__c item = new vlocity_cmt__ContractLineItem__c(vlocity_cmt__Product2Id__c =prod.id,vlocity_cmt__ContractId__c = con1.id);
    insert item;
        vlocity_cmt__ContractLineItem__c item1 = new vlocity_cmt__ContractLineItem__c(vlocity_cmt__Product2Id__c =prod1.id,vlocity_cmt__ContractId__c = con1.id);
    insert item1;
        List<vlocity_cmt__ContractLineItem__c> fetchLineItem =[select id from vlocity_cmt__ContractLineItem__c where id=: item.id];
        system.assertEquals(1,fetchLineItem.size());
        system.debug('TeliaSE_Product_Service_Code__c ==>'+prod.TeliaSE_Product_Service_Code__c);
        
    Test.startTest();
        MCOnline_AgreementContrlService_V1 agrUpdate = new MCOnline_AgreementContrlService_V1();
        Database.executeBatch(agrUpdate);
        Test.stopTest();
    }
    
    

}