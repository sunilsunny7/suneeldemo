@isTest
public class Test_RestService {
    @isTest static void testhelixservice() {
        Account Acc = Test_DataFactory.createOneLargeStandardAccount();
        Acc.Org_Nr__c = '1234567890';
        insert Acc;
        RequestClassWrapper testwrapper = new RequestClassWrapper();
        List<RequestClassWrapper.purposes> rlist = new List<RequestClassWrapper.purposes>();
        RequestClassWrapper.purposes purpose1 = new RequestClassWrapper.purposes();
        RequestClassWrapper.purposes purpose2 = new RequestClassWrapper.purposes();
        testwrapper.collectionMethod = 'Salesforce';
        testwrapper.requested = '2018-05-08T09:30:41.754Z';
        testwrapper.customerRepresentative = 'CVF123';
        testwrapper.customerIdentificationNumber = '1234567890';
        testwrapper.customerProxy = 'Jane Doe';
        purpose1.purpose = 'b2b-consent-td-marketing';
        purpose1.status = 'approved';
        purpose1.version = '1.0.0';
        purpose2.purpose = 'b2b-consent-td-service-improvement';
        purpose2.status = 'approved';
        purpose2.version = '1.0.0';
        rlist.add(purpose1);
        rlist.add(purpose2);
        testwrapper.purposes = rlist;
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://telia--test.cs80.my.salesforce.com/services/apexrest/postrequestSFApi/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(JSON.serialize(testwrapper));
        RestContext.request = request;
        RESTservice.ResponseData testresponse = RESTservice.resultsDisplay();
    }
    @isTest static void testhelixserviceNodata() {
        Account Acc = Test_DataFactory.createOneLargeStandardAccount();
        Acc.Org_Nr__c = '1224567890';
        insert Acc;
        RequestClassWrapper testwrapper1 = new RequestClassWrapper();
        List<RequestClassWrapper.purposes> rlist1 = new List<RequestClassWrapper.purposes>();
        RequestClassWrapper.purposes purpose11 = new RequestClassWrapper.purposes();
        RequestClassWrapper.purposes purpose22 = new RequestClassWrapper.purposes();
        testwrapper1.collectionMethod = 'Salesforce';
        testwrapper1.requested = '2018-05-08T09:30:41.754Z';
        testwrapper1.customerRepresentative = 'CVF123';
        testwrapper1.customerIdentificationNumber = '1224567890';
        testwrapper1.customerProxy = 'Jane Doe';
        purpose11.purpose = 'b2b-consent-td-marketing';
        purpose11.status = 'approved';
        purpose11.version = '1.0.0';
        purpose22.purpose = 'b2b-consent-td-service-improvement';
        purpose22.status = 'approved';
        purpose22.version = '1.0.0';
        rlist1.add(purpose11);
        testwrapper1.purposes = rlist1;
        RestRequest request1 = new RestRequest();
        request1.requestUri =
            'https://telia--test.cs80.my.salesforce.com/services/apexrest/postrequestSFApi/';
        request1.httpMethod = 'POST';
      //  request.requestBody = Blob.valueof(JSON.serialize(testwrapper));
        RestContext.request = request1;
        RESTservice.ResponseData testresponse1 = RESTservice.resultsDisplay();
    }
}