@isTest
public with sharing class Test_TeliaSE_FileAttachment 
{
    public static testMethod void testFileApprovalFlow(){
        System.runAs(Test_DataFactory.getByPassUser()){
            
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Org_Nr__c = label.Account_Org_N;
            //acc.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales_Organisation_Account').getRecordTypeId();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
            acc.Telia_Service_Manager__c = userInfo.getUserId();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            Quote qut1 = new Quote();
            qut1.Name='Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False; 
            qut1.TeliaSE_Type__c='Renegotiation';
            insert qut1;
            
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='test', 
                PathOnClient ='test',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion_1.id];
            
            Map<String,Object> files = new Map<String,Object>();
            files.put('data',contentVersion_2.ContentDocumentId);
            List<Map<String,Object>> filesList = new List<Map<String,Object>>();
            filesList.add(files);
            Map<String,Object> approvalStep = new Map<String,Object>();
            approvalStep.put('Input_File',filesList);
            Map<String,Object> inputs = new Map<String,Object>();
            inputs.put('Approval',approvalStep);
            inputs.put('ContextId',qut1.id);
            Map<String,Object> outputMap = new Map<String,object>();
            TeliaSE_FileAttachment ts = new TeliaSE_FileAttachment();
            ts.invokeMethod('copyContentVersionApprovalFlow', inputs, outputMap, outputMap);        
        }
    }
    
    public static testMethod void testFileUtilizerFlow(){
        System.runAs(Test_DataFactory.getByPassUser()){
            
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Org_Nr__c = label.Account_Org_N;
            //acc.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales_Organisation_Account').getRecordTypeId();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
            acc.Telia_Service_Manager__c = userInfo.getUserId();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            Quote qut1 = new Quote();
            qut1.Name='Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False; 
            qut1.TeliaSE_Type__c='Renegotiation';
            insert qut1;
            
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='test', 
                PathOnClient ='test',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion_1.id];
            
            Map<String,Object> files = new Map<String,Object>();
            files.put('data',contentVersion_2.ContentDocumentId);
            List<Map<String,Object>> filesList = new List<Map<String,Object>>();
            filesList.add(files);
            Map<String,Object> approvalStep = new Map<String,Object>();
            approvalStep.put('File',filesList);
            Map<String,Object> inputs = new Map<String,Object>();
            inputs.put('AddUtilizerAccount',approvalStep);
            inputs.put('ContextId',qut1.id);
            Map<String,Object> outputMap = new Map<String,object>();
            TeliaSE_FileAttachment ts = new TeliaSE_FileAttachment();
            ts.invokeMethod('copyContentVersionUtilizerFlow', inputs, outputMap, outputMap);        
        }        
    }
    
    public static testMethod void test(){   
        Map<String,Object> inputs = new Map<String,Object>();
        TeliaSE_FileAttachment ts = new TeliaSE_FileAttachment();
        ts.invokeMethod('wrongMethod', inputs, inputs, inputs);        
    }
       
    
}