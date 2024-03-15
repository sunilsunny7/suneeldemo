@isTest
public class TeliaSE_LoadUtilizersFromCSV_Test {
    @isTest static void testUtilizerWrongMethod(){
        User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            String methodName = 'getMethodWrong';
            Map<String,Object> inputMap = new Map<String, Object>();
            Map<String,Object> outMap = new Map<String, Object>();
            Map<String,Object> options = new Map<String, Object>();
            
            
            TeliaSE_LoadUtilizersFromCSV helperClass = new TeliaSE_LoadUtilizersFromCSV();
            Boolean returnValue = helperClass.invokeMethod(methodName,inputMap,outMap, options);
        }
    }
    
    
    @isTest static void testSingleUtlizer(){
        
        String methodName = 'addSingleUtilizer';
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
        User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
        
            Account acc = New Account();
            acc.Name = 'Test';
            acc.Org_Nr__c = '14321432';
            insert acc;
            
            Contract cont = New Contract();
            cont.AccountId = acc.Id;
            cont.Status = 'Approved';
            cont.RecordTypeId = RecordTypeIdContact;
            insert cont;
            
            Map<String,Object> addSingleUtilizerInput=new Map<String,Object>();
            addSingleUtilizerInput.put('orgNumberBySearch','14321432');
            addSingleUtilizerInput.put('AccountId1',String.valueOf(acc.id));
            addSingleUtilizerInput.put('FAId','8005E000000wl3bQAA');
            TeliaSE_LoadUtilizersFromCSV helperClass = new TeliaSE_LoadUtilizersFromCSV();
            Boolean returnValue = helperClass.invokeMethod(methodName,addSingleUtilizerInput,outMap,options);
        }
     }
    
    @isTest static void testBuilkLoad() {
        Map<String,Object> attaData=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        TeliaSE_LoadUtilizersFromCSV instance=new TeliaSE_LoadUtilizersFromCSV();
        User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
        
            Account acc = New Account();
            acc.Name = 'Test';
            acc.Org_Nr__c = '1432143223';
            insert acc;
            
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            
            Contract cont = New Contract();
            cont.AccountId = acc.Id;
            cont.Status = 'Approved';
            cont.RecordTypeId = RecordTypeIdContact;
            insert cont;
            
            /*  Utilizer_Contract_Relationship__c  utlr = New Utilizer_Contract_Relationship__c();
    utlr.AccountId__c = acc.Id;
    utlr.ContractNumber__c = cont.Id;
    utlr.Org_Number__c = '1432143223';
    insert utlr;
    */
            
            
            String[] csvFileLines;
            //String csvFileBody = '"Name,AccountNumber,Type,Accountsource,Industry,Esha Patharabe,10001\\s\n,Prospect,Test,Banking\\s\n,1432143223,10002,Prospect,Test,Banking,Prospect,Test,Banking\\s\n,1432143223,10002,Prospect,Test,Banking,Prospect,Test,Banking\\s\n,1432143223\\s+,10002,Prospect,Test,Banking,Prospect,Test,Banking\\s\n,"1432143223\\s+,10002,Prospect,Test,Banking"';
            String csvFileBody = '"OBS! Båda kolumnerna måste vara ifyllda.\n Lista med nyttjare för KRIBO-BYGG, AB [5564011210]\n Name, Org_Nr__c,\n Test,123456779\n test2, 123456778\n TestUtilizer3, 123456777"';
            Blob csvBlobData = Blob.valueOf(csvFileBody);
            //system.debug('blob======'+b);
            String csvAsString = csvBlobData.toString();
            csvFileLines = csvAsString.split('\n'); 
            
            Attachment attachment = new Attachment();
            attachment.ParentId = cont.Id;
            attachment.Name = 'utilizers list With Null Org Number.csv';
            attachment.Body = csvBlobData;
            
            insert(attachment);
            
            Map<String,Object> addBulkUtilizerInput=new Map<String,Object>();
            addBulkUtilizerInput.put('ContractId',String.valueOf(cont.Id));
            addBulkUtilizerInput.put('UtilizerFileName','utilizers list With Null Org Number.csv');
            Boolean returnValue = instance.invokeMethod('parseCSVFile',addBulkUtilizerInput,outMap,options);

        }
    }
    
    
    @isTest static void testBuilkLoadWithWrongFileFormat() {
        Map<String,Object> attaData=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        TeliaSE_LoadUtilizersFromCSV instance=new TeliaSE_LoadUtilizersFromCSV();
        User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
        
            Map<String,Object> addBulkUtilizerInput=new Map<String,Object>();
            addBulkUtilizerInput.put('ContractId','8005E000000wyJPQAY');
            addBulkUtilizerInput.put('UtilizerFileName','utilizers list With Null Org Number.Xls');
            
            //utilizers list With Null Org Number.csv
            
            Boolean returnValue = instance.invokeMethod('parseCSVFile',addBulkUtilizerInput,outMap,options);

        }
    }
    
    @isTest static void testBuilkLoadWithEmptyFileFormat() {
        Map<String,Object> attaData=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        TeliaSE_LoadUtilizersFromCSV instance=new TeliaSE_LoadUtilizersFromCSV();
        User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
        
            Map<String,Object> addBulkUtilizerInput=new Map<String,Object>();
            addBulkUtilizerInput.put('ContractId','8005E000000wyJPQAY');
            addBulkUtilizerInput.put('UtilizerFileName','Empty File.csv');
            
            //utilizers list With Null Org Number.csv
            
            Boolean returnValue = instance.invokeMethod('parseCSVFile',addBulkUtilizerInput,outMap,options);
            
        }        
    }
    
    @isTest static void testSingleUtlizer1(){
        
        User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
        
            String methodName = 'addSingleUtilizer';
            Map<String,Object> inputMap = new Map<String, Object>();
            Map<String,Object> outMap = new Map<String, Object>();
            Map<String,Object> options = new Map<String, Object>();
            Account acc = New Account();
            acc.Name = 'Test';
            acc.Org_Nr__c = '1432143223';
            insert acc;
            
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            
            Contract cont = New Contract();
            cont.AccountId = acc.Id;
            cont.Status = 'Approved';
            cont.RecordTypeId = RecordTypeIdContact;
            insert cont;
            
            blob csvBlobData = blob.valueOf('testing data');
            
            Attachment attachment = new Attachment();
            attachment.ParentId = cont.Id;
            attachment.Name = 'utilizers list With Null Org Number.csv';
            attachment.Body = csvBlobData;
            
            insert(attachment);
            
            
            Map<String,Object> addSingleUtilizerInput=new Map<String,Object>();
            addSingleUtilizerInput.put('orgNumberBySearch','14321432');
            addSingleUtilizerInput.put('AccountId1',String.valueOf(acc.id));
            addSingleUtilizerInput.put('FAId','8005E000000wl3bQAA');
            addSingleUtilizerInput.put('salesIdentifier','New Sales');
            addSingleUtilizerInput.put('isMobileExists',true);
            addSingleUtilizerInput.put('isMobileChanged',true);
            addSingleUtilizerInput.put('isTPExists',false);
            TeliaSE_LoadUtilizersFromCSV helperClass = new TeliaSE_LoadUtilizersFromCSV();
            Boolean returnValue = helperClass.invokeMethod(methodName,addSingleUtilizerInput,outMap,options);
            Map<String,Object> addBulkUtilizerInput=new Map<String,Object>();
            addBulkUtilizerInput.put('ContractId',String.valueOf(cont.Id));
            addBulkUtilizerInput.put('UtilizerFileName','utilizers list With Null Org Number.csv');
            Boolean returnValue1 = helperClass.invokeMethod('parseCSVFile',addBulkUtilizerInput,outMap,options);
        }
    }
    @isTest static void testBuilkLoad1() {
        Map<String,Object> attaData=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        TeliaSE_LoadUtilizersFromCSV instance=new TeliaSE_LoadUtilizersFromCSV();
        User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
        
            Account acc = New Account();
            acc.Name = 'Test';
            acc.Org_Nr__c = '123456779';
            insert acc;
            
            Account acc1 = New Account();
            acc1.Name = 'Testutilizer1';
            acc1.Org_Nr__c = '123456778';
            insert acc1;
            
            Account acc2 = New Account();
            acc2.Name = 'TestUtilizer3';
            acc2.Org_Nr__c = '123456777';
            insert acc2;
            
            Account acc3 = New Account();
            acc3.Name = 'Testutilizer3';
            acc3.Org_Nr__c = '1432143223';
            insert acc3;
            
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            
            Contract cont = New Contract();
            cont.AccountId = acc.Id;
            cont.Status = 'Approved';
            cont.RecordTypeId = RecordTypeIdContact;
            insert cont;
            
            Utilizer_Contract_Relationship__c  utlr = New Utilizer_Contract_Relationship__c();
            utlr.AccountId__c = acc.Id;
            utlr.ContractNumber__c = cont.Id;
            utlr.Org_Number__c = '1432143224';
            insert utlr;
              
            String[] csvFileLines;
            //String csvFileBody = '"Name,AccountNumber,Type,Accountsource,Industry,Esha Patharabe,10001\r\n,Prospect,Test,Banking\r\n,123456777,10002,Prospect,Test,Banking,Prospect,Test,Banking\r\n,123456778,10002,Prospect,Test,Banking,Prospect,Test,Banking\r\n,123456779\\s+,10002,Prospect,Test,Banking,Prospect,Test,Banking\r\n,"1432143223\\s+,10002,Prospect,Test,Banking"';
            String str = '"OBS! Båda kolumnerna måste vara ifyllda.\n Lista med nyttjare för KRIBO-BYGG AB [5564011210]\n Name; Org_Nr__c\n Test;123456779\n test2; 123456778\n TestUtilizer3; 123456777"';
            Blob csvBlobData = Blob.valueOf(str);
            //system.debug('blob======'+b);
            String csvAsString = csvBlobData.toString();
            csvFileLines = csvAsString.split('\n'); 
            
            Attachment attachment = new Attachment();
            attachment.ParentId = cont.Id;
            attachment.Name = 'utilizers list With Null Org Number.csv';
            attachment.Body = csvBlobData;
            
            insert(attachment);
            
            Map<String,Object> addBulkUtilizerInput=new Map<String,Object>();
            addBulkUtilizerInput.put('ContractId',String.valueOf(cont.Id));
            addBulkUtilizerInput.put('UtilizerFileName','utilizers list With Null Org Number.csv');
            addBulkUtilizerInput.put('salesIdentifier','New Sales');
            addBulkUtilizerInput.put('isMobileExists',true);
            addBulkUtilizerInput.put('isMobileChanged',true);
            addBulkUtilizerInput.put('isTPExists',false);
            Boolean returnValue = instance.invokeMethod('parseCSVFile',addBulkUtilizerInput,outMap,options);

        }
    }
    @isTest static void testBuilkLoad2() {
        Map<String,Object> attaData=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        TeliaSE_LoadUtilizersFromCSV instance=new TeliaSE_LoadUtilizersFromCSV();
             User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
   
            Account acc = New Account();
            acc.Name = 'Test';
            acc.Org_Nr__c = '1432142212';
            insert acc;
            
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            
            Contract cont = New Contract();
            cont.AccountId = acc.Id;
            cont.Status = 'Approved';
            cont.RecordTypeId = RecordTypeIdContact;
            insert cont;
            
            Utilizer_Contract_Relationship__c  utlr = New Utilizer_Contract_Relationship__c();
            utlr.AccountId__c = acc.Id;
            utlr.ContractNumber__c = cont.Id;
            utlr.Org_Number__c = '1432143225';
            insert utlr;
            
            
            /*
            String[] csvFileLines;
            String csvFileBody = '"Name,AccountNumber,Type,Accountsource,Industry,Esha Patharabe,10001\r\n,Prospect,Test,Banking\r\n,1432143221,10002,Prospect,Test,Banking,Prospect,Test,Banking\r\n,1432143222,10002,Prospect,Test,Banking,Prospect,Test,Banking\r\n,1432143229\\s+,10002,Prospect,Test,Banking,Prospect,Test,Banking\r\n,"1432143223\\s+,10002,Prospect,Test,Banking"';
            String str = '"OBS! Båda kolumnerna måste vara ifyllda.\n Lista med nyttjare för KRIBO-BYGG AB [5564011210]\n Name; Org_Nr__c\n Test;123456779\n test2; 123456778\n TestUtilizer3; 123456777"';
            Blob csvBlobData = Blob.valueOf(str);
            //system.debug('blob======'+b);
            String csvAsString = csvBlobData.toString();
            csvFileLines = csvAsString.split('\n'); 
            
            Attachment attachment = new Attachment();
            attachment.ParentId = cont.Id;
            attachment.Name = 'utilizers list With Null Org Number.csv';
            attachment.Body = csvBlobData;
            
            insert(attachment);
      */
            Blob bodyBlob=Blob.valueOf('"OBS! Båda kolumnerna måste vara ifyllda.\n Lista med nyttjare för KRIBO-BYGG AB [5564011210]\n Name; Org_Nr__c\n Test;123456779\n test2; 123456778\n TestUtilizer3; 123456777"'); 
                ContentVersion contentVersion_1 = new ContentVersion(
                    Title='test', 
                    PathOnClient ='test.csv',
                    VersionData = bodyBlob, 
                    origin = 'H'
                );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.id];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = cont.id;
            contentlink.contentdocumentid = contentVersion_2.ContentDocumentId;   
            contentlink.ShareType = 'V';
            insert contentlink; 
            
            Map<String,Object> addBulkUtilizerInput=new Map<String,Object>();
            addBulkUtilizerInput.put('ContractId',String.valueOf(cont.Id));
            addBulkUtilizerInput.put('UtilizerFileName','utilizers list With Null Org Number.csv');
            addBulkUtilizerInput.put('salesIdentifier','New Sales');
            addBulkUtilizerInput.put('isMobileExists',true);
            addBulkUtilizerInput.put('isMobileChanged',true);
            addBulkUtilizerInput.put('isTPExists',false);
            Boolean returnValue = instance.invokeMethod('parseCSVFile',addBulkUtilizerInput,outMap,options);

        }
    }    
    @isTest
    public static void testMethod12()
    { 
        Map<String,Object> attaData=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        TeliaSE_LoadUtilizersFromCSV instance=new TeliaSE_LoadUtilizersFromCSV();
             User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
       
            Account acc = New Account();
            acc.Name = 'Test';
            acc.Org_Nr__c = '1432143223';
            insert acc;
            
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            
            Contract cont = New Contract();
            cont.AccountId = acc.Id;
            cont.Status = 'Approved';
            cont.RecordTypeId = RecordTypeIdContact;
            insert cont;
            
            List<Map<String,String>> listOfNonExistingOrgNum = new list<Map<String,String>>();
            Map<String, String> errorMap = new Map<String, String>();
            errorMap.put('Organisationsnamn','12345678');
            errorMap.put('Organisationsnr','16276736136');
            errorMap.put('ErrorMessages','hello');
            listOfNonExistingOrgNum.add(errorMap);
            String fileName = TeliaSE_LoadUtilizersFromCSV.attachFile(listOfNonExistingOrgNum,cont.id);

        }
    }
    @istest
    public static void testAddInaktivSingleutilizer(){
        String methodName = 'addSingleUtilizer';
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
             User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){

            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            
            Account acc = New Account();
            acc.Name = 'Test';
            acc.Org_Nr__c = '14321432';
            insert acc;
            
            Account acc1 = New Account();
            acc1.Name = 'Testutilizer';
            acc1.Org_Nr__c = '1432143223';
            insert acc1;
            
            Contract cont = New Contract();
            cont.AccountId = acc.Id;
            cont.Status = 'Approved';
            cont.RecordTypeId = RecordTypeIdContact;
            insert cont;
            
            Utilizer_Contract_Relationship__c  utlr = New Utilizer_Contract_Relationship__c();
            utlr.AccountId__c = acc1.Id;
            utlr.ContractNumber__c = cont.Id;
            utlr.Org_Number__c = '1432143223';
            utlr.status__c = 'Inaktiv';
            insert utlr;
            
            
            Map<String,Object> addSingleUtilizerInput=new Map<String,Object>();
            addSingleUtilizerInput.put('orgNumberBySearch','1432143223');
            addSingleUtilizerInput.put('AccountId1',String.valueOf(acc.id));
            addSingleUtilizerInput.put('FAId',cont.id);
            addSingleUtilizerInput.put('salesIdentifier','New Sales');
            addSingleUtilizerInput.put('isMobileExists',true);
            addSingleUtilizerInput.put('isMobileChanged',true);
            addSingleUtilizerInput.put('isTPExists',false);
            TeliaSE_LoadUtilizersFromCSV helperClass = new TeliaSE_LoadUtilizersFromCSV();
            Boolean returnValue = helperClass.invokeMethod(methodName,addSingleUtilizerInput,outMap,options);

        }
    }
    @istest
    public static void testAddSingleutilizerErrors(){
        String methodName = 'addSingleUtilizer';
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){

            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            
            Account acc = New Account();
            acc.Name = 'Test';
            acc.Org_Nr__c = '14321432';
            insert acc;
            
            Account acc1 = New Account();
            acc1.Name = 'Testutilizer';
            insert acc1;
            
            Contract cont = New Contract();
            cont.AccountId = acc.Id;
            cont.Status = 'Approved';
            cont.RecordTypeId = RecordTypeIdContact;
            insert cont;
            
            Contract cont1 = New Contract();
            cont1.AccountId = acc.Id;
            cont1.Status = 'Approved';
            cont1.RecordTypeId = RecordTypeIdContact;
            insert cont1;
            
            Utilizer_Contract_Relationship__c  utlr = New Utilizer_Contract_Relationship__c();
            utlr.AccountId__c = acc1.Id;
            utlr.ContractNumber__c = cont1.Id;
            utlr.Org_Number__c = '1236566798';
            utlr.status__c = 'Aktiv';
            insert utlr;
    
            Utilizer_Contract_Relationship__c  utlr2 = New Utilizer_Contract_Relationship__c();
            utlr2.AccountId__c = acc1.Id;
            utlr2.ContractNumber__c = cont.Id;
            utlr2.Org_Number__c = '1432143223';
            utlr2.status__c = 'Aktiv';
            insert utlr2;
            
            List<Utilizer_Contract_Relationship__c> utilList = new List<Utilizer_Contract_Relationship__c>();
            
            Map<String,Object> addSingleUtilizerInput=new Map<String,Object>();
            addSingleUtilizerInput.put('orgNumberBySearch',null);
            addSingleUtilizerInput.put('AccountId1',String.valueOf(acc1.id));
            addSingleUtilizerInput.put('FAId',cont.id);
            addSingleUtilizerInput.put('salesIdentifier','New Sales');
            addSingleUtilizerInput.put('isMobileExists',true);
            addSingleUtilizerInput.put('isMobileChanged',true);
            addSingleUtilizerInput.put('isTPExists',false);
            TeliaSE_LoadUtilizersFromCSV helperClass = new TeliaSE_LoadUtilizersFromCSV();
            Boolean returnValue = helperClass.invokeMethod(methodName,addSingleUtilizerInput,outMap,options);
            
            Map<String,Object> addSingleUtilizerInput1=new Map<String,Object>();
            addSingleUtilizerInput1.put('orgNumberBySearch',null);
            addSingleUtilizerInput1.put('AccountId1',null);
            addSingleUtilizerInput1.put('FAId',cont.id);
            addSingleUtilizerInput.put('salesIdentifier','New Sales');
            addSingleUtilizerInput.put('isMobileExists',true);
            addSingleUtilizerInput.put('isMobileChanged',true);
            addSingleUtilizerInput.put('isTPExists',false);
            returnValue = helperClass.invokeMethod(methodName,addSingleUtilizerInput1,outMap,options);
            
            Map<String,Object> addSingleUtilizerInput3=new Map<String,Object>();
            addSingleUtilizerInput3.put('orgNumberBySearch','1432143223');
            addSingleUtilizerInput3.put('AccountId1',acc.id);
            addSingleUtilizerInput3.put('FAId',cont.id);
            addSingleUtilizerInput.put('salesIdentifier','New Sales');
            addSingleUtilizerInput.put('isMobileExists',true);
            addSingleUtilizerInput.put('isMobileChanged',true);
            addSingleUtilizerInput.put('isTPExists',false);

            returnValue = helperClass.invokeMethod(methodName,addSingleUtilizerInput3,outMap,options);
            
            integer i = 0;
            for(i=0;i<200;i++)
            {
                Utilizer_Contract_Relationship__c  utlr1 = New Utilizer_Contract_Relationship__c();
                utlr1.AccountId__c = acc.Id;
                utlr1.ContractNumber__c = cont.Id;
                utlr1.Org_Number__c = String.valueOf(i);
                utlr1.status__c = 'Aktiv';
                utilList.add(utlr1);
            }
            insert utilList;
            
            Map<String,Object> addSingleUtilizerInput2=new Map<String,Object>();
            addSingleUtilizerInput2.put('orgNumberBySearch','1236566798');
            addSingleUtilizerInput2.put('AccountId1',acc1.id);
            addSingleUtilizerInput2.put('FAId',cont.id);
            returnValue = helperClass.invokeMethod(methodName,addSingleUtilizerInput2,outMap,options);
            addSingleUtilizerInput2.put('ContractId',cont.id);
            addSingleUtilizerInput2.put('UtilizerFileName','');
            returnvalue = helperClass.invokeMethod('parseCSVFile',addSingleUtilizerInput2,outMap,options);
        }
    }
    
    @isTest static void testBuilkLoad3() {
        Map<String,Object> attaData=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        TeliaSE_LoadUtilizersFromCSV instance=new TeliaSE_LoadUtilizersFromCSV();
             User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
       List<Account> accList = new List<Account>();  
            Account acc = New Account();
            acc.Name = 'Test';
            acc.Org_Nr__c = '1432142212';
            insert acc;
            
            for(Integer i=0; i<10;i++)
            {
                Account acc1 = New Account();
              acc1.Name = 'Test' + i;
              acc1.Org_Nr__c = '12345678'+i;
              accList.add(acc1);
            }
            insert accList;
            
            Id RecordTypeIdContact = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            
            Contract cont = New Contract();
            cont.AccountId = acc.Id;
            cont.Status = 'Approved';
            cont.RecordTypeId = RecordTypeIdContact;
            insert cont;
            
            Utilizer_Contract_Relationship__c  utlr = New Utilizer_Contract_Relationship__c();
            utlr.AccountId__c = acc.Id;
            utlr.ContractNumber__c = cont.Id;
            utlr.Org_Number__c = '123456789';
            insert utlr;
            
            
            /*
            String[] csvFileLines;
            String csvFileBody = '"Name,AccountNumber,Type,Accountsource,Industry,Esha Patharabe,10001\r\n,Prospect,Test,Banking\r\n,1432143221,10002,Prospect,Test,Banking,Prospect,Test,Banking\r\n,1432143222,10002,Prospect,Test,Banking,Prospect,Test,Banking\r\n,1432143229\\s+,10002,Prospect,Test,Banking,Prospect,Test,Banking\r\n,"1432143223\\s+,10002,Prospect,Test,Banking"';
            String str = '"OBS! Båda kolumnerna måste vara ifyllda.\n Lista med nyttjare för KRIBO-BYGG AB [5564011210]\n Name; Org_Nr__c\n Test;123456779\n test2; 123456778\n TestUtilizer3; 123456777"';
            Blob csvBlobData = Blob.valueOf(str);
            //system.debug('blob======'+b);
            String csvAsString = csvBlobData.toString();
            csvFileLines = csvAsString.split('\n'); 
            
            Attachment attachment = new Attachment();
            attachment.ParentId = cont.Id;
            attachment.Name = 'utilizers list With Null Org Number.csv';
            attachment.Body = csvBlobData;
            
            insert(attachment);
      */
            Blob bodyBlob=Blob.valueOf('"OBS! Båda kolumnerna måste vara ifyllda.\n Lista med nyttjare för KRIBO-BYGG AB [5564011210]\n Name; Org_Nr__c\n Test;123456781\n test2; 123456782\n TestUtilizer3; 123456789"'); 
                ContentVersion contentVersion_1 = new ContentVersion(
                    Title='test', 
                    PathOnClient ='test.csv',
                    VersionData = bodyBlob, 
                    origin = 'H'
                );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.id];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = cont.id;
            contentlink.contentdocumentid = contentVersion_2.ContentDocumentId;   
            contentlink.ShareType = 'V';
            insert contentlink; 
            
            Map<String,Object> addBulkUtilizerInput=new Map<String,Object>();
            addBulkUtilizerInput.put('ContractId',String.valueOf(cont.Id));
            addBulkUtilizerInput.put('UtilizerFileName','utilizers list With Null Org Number.csv');
            Boolean returnValue = instance.invokeMethod('parseCSVFile',addBulkUtilizerInput,outMap,options);

        }
    }
    
 }