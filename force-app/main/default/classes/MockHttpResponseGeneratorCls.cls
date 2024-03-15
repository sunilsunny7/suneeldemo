@isTest
global class MockHttpResponseGeneratorCls {
    
    global static HTTPResponse testApiresponse() {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token": "570af6f3-c405-39cf-999a-1b7920379999","scope": "am_application_scope default","token_type": "Bearer","expires_in": 3600}');
        res.setStatusCode(200);
        return res;
    }
    // Get the Test C2b data
     global static HTTPResponse testgetdata() {

        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"purposes": [{"purpose": "b2b-consent-td-marketing","legalGround": "ic","category": [],"status": "denied","requested": "2018-05-14T13:42:20.319Z","description": [{"language": "sv-SE","text": "Jag godkänner att Telia hanterar mitt företags trafikuppgifter för att ge oss anpassade och optimerade erbjudanden"}],"version": "1.0.0","collectionMethod": "Salesforce","customerRepresentative": "scu491","customerProxy": "Iron Man,Galaxy"}]}');
        response.setStatusCode(200);
        return response;
    }
    
    // Setthe Test C2b data
     global static HTTPResponse setTestdata() {

        // Create a fake response
        HttpResponse setresponse = new HttpResponse();
        setresponse.setHeader('Content-Type', 'application/json');
        setresponse.setBody('{"status": "SUCCESS","statusDescription": "TaaS request was successfully sent. SNow request added to queue.","transactionId": "8a658109-478b-4a4f-8518-035a858218d2"}');
        setresponse.setStatusCode(200);
        return setresponse;
    }
}