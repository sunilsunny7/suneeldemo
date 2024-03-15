/**
 * @Author:      Shubham Kundu
 * @Company:     Capgemini
 * @Date:        3rd April 2019
 * @Description: Test Class for TeliaSE_AttachPdf
 *
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------
*/
@isTest
public with sharing class TeliaSE_AttachPdf_Test {

    class SingleRequestMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map < String, String > responseHeaders;

        public SingleRequestMock(Integer code, String status, String body, Map < String, String > responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }

        public SingleRequestMock(Integer code, String status, Blob body, Map < String, String > responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsBlob = body;
            this.bodyAsString = null;
            this.responseHeaders = responseHeaders;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);
            resp.setStatus(status);
            if (bodyAsBlob != null) {
                resp.setBodyAsBlob(bodyAsBlob);
            } else {
                resp.setBody(bodyAsString);
            }

            if (responseHeaders != null) {
                for (String key: responseHeaders.keySet()) {
                    resp.setHeader(key, responseHeaders.get(key));
                }
            }
            return resp;
        }
    }

    @testSetup
    static void testData() {
        Account acc = new Account();
        acc.name = 'testAccount';
        insert acc;

        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;  

        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);
        System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
        System.assertEquals(documents[0].Title, contentVersion_2.Title);

        Contract contr = new Contract();
        contr.AccountId = acc.Id;
        contr.StartDate = date.today();
        contr.Actionneeded__c = false;
        contr.Large_dataload__c = false;
        contr.vlocity_cmt__IsAutoRenew__c = false;
        contr.vlocity_cmt__IsFrameContract__c = false;
        insert contr;

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=contr.id;
        contentlink.ShareType= 'I';
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
    }

    @isTest
    static void attachPdf_Scenario() {
        
        Contract con = [Select Id,AccountId,ContractNumber from Contract Limit 1];
        TeliaSE_AttachPdf ap = new TeliaSE_AttachPdf();
        String methodName = 'attachPdf';
        Map<String,Object> inputMap = new  Map<String,Object>();
        inputMap.put('ContextId',con.Id);
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();

        Blob testBlob = Blob.valueOf('Unit Test Attachment Body');
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'Complete', testBlob, null);
        System.Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        ap.invokeMethod(methodName,inputMap,outMap,options);
        Test.stopTest();
    }   
}