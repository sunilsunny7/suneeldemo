public class APIMocks implements HttpCalloutMock {
    public HTTPResponse respond(HttpRequest request) {
        String responseBody;
        HttpResponse res = new HttpResponse();
        if (request.getEndpoint().contains('client_credential/accesstoken')) {
            List<StaticResource> staticResources = [SELECT Id, Body FROM StaticResource WHERE Name = 'accessTokenResponse' LIMIT 1];
            responseBody = (staticResources.size() == 1) ? staticResources.get(0).Body.toString() : null;
            res.setStatusCode(200);
        } else if (request.getEndpoint().contains('b2x_global_telianow_tmf621')) {
            List<StaticResource> staticResources = [SELECT Id, Body FROM StaticResource WHERE Name = 'newCaseResponse' LIMIT 1];
            responseBody = (staticResources.size() == 1) ? staticResources.get(0).Body.toString() : null;
            res.setStatusCode(200);
        } else if (request.getEndpoint().contains('servicenow/teab/contacts/enterprise/create')) {
            List<StaticResource> staticResources = [SELECT Id, Body FROM StaticResource WHERE Name = 'newContactResponse' LIMIT 1];
            responseBody = (staticResources.size() == 1) ? staticResources.get(0).Body.toString() : null;
            res.setStatusCode(200);
        } else if (request.getEndpoint().contains('servicenow/teab/contacts/enterprise/read?email=test3345@test.lt')) {
            List<StaticResource> staticResources = [SELECT Id, Body FROM StaticResource WHERE Name = 'existingTNOWContact' LIMIT 1];
            responseBody = (staticResources.size() == 1) ? staticResources.get(0).Body.toString() : null;
            res.setStatusCode(200);
        } else if (request.getEndpoint().contains('servicenow/teab/contacts/enterprise/read?email=test.empty@test.lt')) {
            List<StaticResource> staticResources = [SELECT Id, Body FROM StaticResource WHERE Name = 'notExistingTNOWContact' LIMIT 1];
            responseBody = (staticResources.size() == 1) ? staticResources.get(0).Body.toString() : null;
            res.setStatusCode(200);
        } else if (request.getEndpoint().contains('servicenow/teab/contacts/enterprise/read?email=error.error@error.error')) {
            List<StaticResource> staticResources = [SELECT Id, Body FROM StaticResource WHERE Name = 'newCaseResponseError' LIMIT 1];
            responseBody = (staticResources.size() == 1) ? staticResources.get(0).Body.toString() : null;
            res.setStatusCode(400);
        }

        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseBody);

        return res;
    }
}