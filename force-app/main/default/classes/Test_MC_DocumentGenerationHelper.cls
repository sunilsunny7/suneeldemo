@isTest
public with sharing class Test_MC_DocumentGenerationHelper 
{
    @isTest
    public static void testMethod1()
    {
       Map<String,Object> inputmap = new Map<String,object>();
       Map<String,Object> outputMap = new Map<String,object>();
       Map<String,Object> optionsMap = new Map<String,object>();
       string jsonString = '{"cdl":[{"contentdocumentId":"0699E000001ot3TQAQ","id":"06A9E000002uoz9UAA"},{"contentdocumentId":"0699E000001ot4qQAA","id":"06A9E000002up0gUAA"}]}';
       inputMap = (Map<String,Object>) json.deserializeuntyped(jsonString);
       MC_DocumentGenerationHelper ob = new MC_DocumentGenerationHelper();
       boolean flag = ob.invokeMethod('deleteOldInitialOrderDocuments',inputMap,outputMap,outputMap);
       flag = ob.invokeMethod('dummyMethod',inputMap,outputMap,outputMap);
       flag = ob.invokeMethod('deleteOldInitialOrderDocuments',outputMap,outputMap,outputMap);
           
    }

    
    @isTest
    public static void testMethod2()
    {
        Map<String,Object> inputmap = new Map<String,object>();
        Map<String,Object> outputMap = new Map<String,object>();
        Map<String,Object> optionsMap = new Map<String,object>();
        
        Test.startTest();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method
            Account acc = new Account();
            acc.Name='TestAccount';
            acc.Org_Nr__c =  '1234567890';
            Insert acc;
            
            Case cse = new Case();
            cse.Recordtypeid = SEUTility.getRecordTypeId('Enterprise_Subcase');
            cse.Account=acc;
            cse.Subject='TestCase1';
            cse.Origin='Salesforce';
            cse.Status='New';
            insert (cse);
            
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='test', 
                PathOnClient ='test',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;          
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.id];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = cse.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
           
            string jsonString = '{"cdl":[{"id":"06A5E000004x7V6UAI","contentdocumentId":"0695E000003D4p2QAC","Lastmodified":"2022-02-02T16:11:20.000Z","Name":"Initial beställning för 02053500"},{"id":"06A5E000004x7UwUAI","contentdocumentId":"0695E000003D4oxQAC","Lastmodified":"2022-02-02T16:11:14.000Z","Name":"Initial beställning för 02053500"}]}';
            inputMap = (Map<String,Object>) json.deserializeuntyped(jsonString);
            system.debug(inputMap);
            
            Map<String,Object> cdlMob = new Map<String,Object>();
            cdlMob.put('Lastmodified','2022-02-02T16:10:43.000Z');
            cdlMob.put('Name','Avtal RA-02053500_Telia_Almbys Bil AB_2022-02-02_05-10-44');
            cdlMob.put('contentdocumentId',contentVersion_2.contentdocumentid);
            cdlMob.put('id',contentlink.id);
            
            
            List<Object> cdList = (List<Object>) inputMap.get('cdl');
            cdList.add((Object)cdlMob);
            inputMap.put('cdl',cdList);
            MC_DocumentGenerationHelper ob = new MC_DocumentGenerationHelper();
            boolean flag = ob.invokeMethod('changeOrderOfDocument',inputMap,outputMap,outputMap);
        }
        Test.stopTest();    
    }
    
        @isTest
    public static void testMethod3()
    {
       Map<String,Object> inputmap = new Map<String,object>();
       Map<String,Object> outputMap = new Map<String,object>();
       Map<String,Object> optionsMap = new Map<String,object>();
       string jsonString = '{"CDLTPP":[{"id":"06A5E000004x7V6UAI","contentdocumentId":"0695E000003D4p2QAC","Lastmodified":"2022-02-02T16:11:20.000Z","Name":"Initial beställning för 02053500"},{"id":"06A5E000004x7UwUAI","contentdocumentId":"0695E000003D4oxQAC","Lastmodified":"2022-02-02T16:11:14.000Z","Name":"oldInitial beställning för 02053500"},{"id":"06A5E000004x7UmUAI","contentdocumentId":"0695E000003D4osQAC","Lastmodified":"2022-02-02T16:10:43.000Z","Name":"Avtal RA-02053500_Telia_Almbys Bil AB_2022-02-02_05-10-44"}]}';
       inputMap = (Map<String,Object>) json.deserializeuntyped(jsonString);
       MC_DocumentGenerationHelper ob = new MC_DocumentGenerationHelper();
       boolean flag = ob.invokeMethod('deleteOldTPPExcelDocuments',inputMap,outputMap,outputMap);
           
    }
}