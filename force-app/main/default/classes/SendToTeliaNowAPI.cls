global with sharing class SendToTeliaNowAPI {
    public static final Map<String, Integration_Endpoints__mdt> integrationEndpointsMap = Integration_Endpoints__mdt.getAll();
    public static final Boolean isSandbox = [SELECT IsSandbox, Id FROM Organization].IsSandbox;
    global static void teliaNowAPIConnection(Id recordId) {
        Case caseToSync = [
            SELECT
                Id,
                Assignment_group_to_TNOW__c,
                Account.TSCID__c,
                ContactEmail,
                CreatedBy.Telia_Id__c,
                Contact.FirstName,
                Contact.LastName,
                Contact.Account.TSCID__c,
                Description,
                Subject,
                Internal_case__c
            FROM Case
            WHERE Id = :recordId
        ];
        String token = getAPIGardenToken();
        if (token != null) {
            if (caseToSync.ContactEmail != null) {
                HTTPResponse response = retrieveTeliaNowContact(token, caseToSync.ContactEmail);
                Integer contactCount = TeliaNowAPIWrappers.parseTeliaNowContact(response.getBody()).Result.count;
                if (contactCount == 1) {
                    createTeliaNowCase(caseToSync, token, TeliaNowAPIWrappers.parseTeliaNowContact(response.getBody()).Result.Contacts[0].sysId);
                } else if (contactCount == 0) {
                    String sysId = createTeliaNowContact(caseToSync, token);
                    createTeliaNowCase(caseToSync, token, sysId);
                } else {
                    throw new AuraHandledException('More than one contact was found');
                }
            } else {
                createTeliaNowCase(caseToSync, token, null);
            }
        } else {
            throw new AuraHandledException('Bad Token');
        }
    }
    global static string createTeliaNowContact(Case caseToSync, String token) {
        TeliaNowAPIWrappers.TeliaNowNewContact contactJson = new TeliaNowAPIWrappers.TeliaNowNewContact();
        contactJson.firstName = caseToSync.Contact.FirstName;
        contactJson.lastName = caseToSync.Contact.LastName;
        contactJson.tscId = caseToSync.Contact.Account.TSCID__c;
        contactJson.email = caseToSync.ContactEmail;
        HTTPResponse response;
        if (!isSandbox) {
            response = callAPI(integrationEndpointsMap.get('TNOWCreateContact').Endpoint__c, 'POST', token, JSON.serialize(contactJson));
        } else {
            response = callAPI(integrationEndpointsMap.get('TNOWCreateContactUAT').Endpoint__c, 'POST', token, JSON.serialize(contactJson));
        }

        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        String sysId = (String) ((Map<String, Object>) ((Map<String, Object>) jsonMap.get('result')).get('contact')).get('sysId');
        return sysId;
    }
    global static void createTeliaNowCase(Case caseToSync, String token, String sysId) {
        Map<String, String> tnowQueueIdMap = new Map<String, String>();
        for (TNOW_Queue__mdt tnowQueue : TNOW_Queue__mdt.getAll().values()) {
            tnowQueueIdMap.put(tnowQueue.Current_TNOW_Queue__c, tnowQueue.Current_TNOW_Queue_ID__c);
        }
        // Geting newest version of attached files
        List<ContentDocumentLink> documentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :caseToSync.Id
        ];

        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : documentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }
        List<ContentVersion> contentVersions = [
            SELECT Id, Title, VersionData, FileExtension, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            ORDER BY ContentDocumentId, CreatedDate DESC
        ];
        Map<Id, ContentVersion> newestVersions = new Map<Id, ContentVersion>();
        for (ContentVersion contentVersion : contentVersions) {
            if (!newestVersions.containsKey(contentVersion.ContentDocumentId)) {
                newestVersions.put(contentVersion.ContentDocumentId, contentVersion);
            }
        }
        // Creating case json
        TeliaNowAPIWrappers.NewCase caseJson = new TeliaNowAPIWrappers.NewCase();
        caseJson.description = caseToSync.Description;
        caseJson.name = caseToSync.subject;
        caseJson.category = 'Beställning';
        caseJson.internal = caseToSync.Internal_case__c;
        caseJson.ticketType = 'order_case';
        caseJson.severity = '2';
        caseJson.impact = '2';
        caseJson.assignmentGroupId = tnowQueueIdMap.get(caseToSync.Assignment_group_to_TNOW__c);
        TeliaNowAPIWrappers.Channel channelJson = new TeliaNowAPIWrappers.Channel();
        channelJson.id = 'web';
        caseJson.channel = channelJson;
        List<TeliaNowAPIWrappers.RelatedParty> relatedPartyJsonList = new List<TeliaNowAPIWrappers.RelatedParty>();
        TeliaNowAPIWrappers.RelatedParty relatedPartyJsonOrganisation = new TeliaNowAPIWrappers.RelatedParty();
        relatedPartyJsonOrganisation.id = caseToSync.Account.TSCID__c;
        relatedPartyJsonOrganisation.role = 'customer';
        relatedPartyJsonOrganisation.referredType = 'Organisation';
        relatedPartyJsonOrganisation.type = 'RelatedParty';
        relatedPartyJsonList.add(relatedPartyJsonOrganisation);
        TeliaNowAPIWrappers.RelatedParty relatedPartyJsonIndividual = new TeliaNowAPIWrappers.RelatedParty();
        relatedPartyJsonIndividual.id = caseToSync.CreatedBy.Telia_Id__c;
        relatedPartyJsonIndividual.role = 'opener';
        relatedPartyJsonIndividual.referredType = 'Individual';
        relatedPartyJsonIndividual.type = 'RelatedParty';
        relatedPartyJsonList.add(relatedPartyJsonIndividual);
        if (sysId != null) {
            TeliaNowAPIWrappers.RelatedParty relatedPartyJsonContact = new TeliaNowAPIWrappers.RelatedParty();
            relatedPartyJsonContact.id = sysId;
            relatedPartyJsonContact.role = 'originator';
            relatedPartyJsonContact.referredType = 'Individual';
            relatedPartyJsonContact.type = 'RelatedParty';
            relatedPartyJsonList.add(relatedPartyJsonContact);
        }
        caseJson.relatedParty = relatedPartyJsonList;
        List<TeliaNowAPIWrappers.ThirdPartyReference> thirdPartyReferenceJsonList = new List<TeliaNowAPIWrappers.ThirdPartyReference>();
        TeliaNowAPIWrappers.ThirdPartyReference thirdPartyReferenceJson = new TeliaNowAPIWrappers.ThirdPartyReference();
        thirdPartyReferenceJson.id = 'SF';
        thirdPartyReferenceJson.source = 'SalesForce';
        thirdPartyReferenceJsonList.add(thirdPartyReferenceJson);
        caseJson.thirdPartyReference = thirdPartyReferenceJsonList;
        List<TeliaNowAPIWrappers.Attachment> attachmentJsonList = new List<TeliaNowAPIWrappers.Attachment>();
        for (ContentVersion newestVersion : newestVersions.values()) {
            TeliaNowAPIWrappers.Attachment attachmentJson = new TeliaNowAPIWrappers.Attachment();
            attachmentJson.name = newestVersion.title + '.' + newestVersion.FileExtension;
            attachmentJson.mimeType = FileTypeConverter.convertFileTypeToMimeType(newestVersion.FileExtension);
            attachmentJson.content = EncodingUtil.base64Encode(newestVersion.VersionData);
            attachmentJsonList.add(attachmentJson);
        }
        // Sending case to TNOW

        HTTPResponse response;
        if (!isSandbox) {
            response = callAPI(
                integrationEndpointsMap.get('TNOWCreateCase').Endpoint__c,
                'POST',
                token,
                JSON.serialize(caseJson).replaceAll('\"type\"', '\"@type\"').replaceAll('\"referredType\"', '\"@referredType\"').removeEnd('}') +
                    ',"attachment":' +
                    JSON.serialize(attachmentJsonList).removeStart('{') +
                    '}'
            );
        } else {
            response = callAPI(
                integrationEndpointsMap.get('TNOWCreateCaseUAT').Endpoint__c,
                'POST',
                token,
                JSON.serialize(caseJson).replaceAll('\"type\"', '\"@type\"').replaceAll('\"referredType\"', '\"@referredType\"').removeEnd('}') +
                    ',"attachment":' +
                    JSON.serialize(attachmentJsonList).removeStart('{') +
                    '}'
            );
        }
        // Updating Case in Salesforce
        caseToSync.TNOW_Case_Id__c = (String) ((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('id');
        caseToSync.Last_Modified_in_TNOW__c = Datetime.valueOf(
            ((String) ((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('lastUpdate')).replace('T', ' ').substringBefore('.')
        );
        caseToSync.TNOW_Status__c = (String) ((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('status');
        caseToSync.Current_TNOW_Queue_Id__c = (String) ((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('assignmentGroupId');
        try {
            update caseToSync;
        } catch (Exception ex) {
            Application_Logs__c newError = new Application_Logs__c();
            newError.Debug_Level__c = 'Error';
            newError.Source__c = 'SendToTeliaNowAPI';
            newError.Source_Function__c = 'createTeliaNowCase';
            newError.Message__c = ex.getDmlMessage(0);
            newError.Stack_Trace__c = ex.getMessage();
            insert newError;
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
    }
    global static HTTPResponse retrieveTeliaNowContact(String token, String contactEmail) {
        String namedCredentialURL;
        if (!isSandbox) {
            namedCredentialURL = integrationEndpointsMap.get('TNOWGetContact').Endpoint__c + contactEmail;
        } else {
            namedCredentialURL = integrationEndpointsMap.get('TNOWGetContactUAT').Endpoint__c + contactEmail;
        }
        return callAPI(namedCredentialURL, 'GET', token, null);
    }
    global static String getAPIGardenToken() {
        String environment;
        String username;
        String password;
        if (!isSandbox) {
            environment = 'callout:API_Garden_Token' + integrationEndpointsMap.get('APIGardenAccenToken').Endpoint__c;
            username = '{!$Credential.API_Garden_Token.Username}';
            password = '{!$Credential.API_Garden_Token.Password}';
        } else {
            environment = 'callout:API_Garden_Token_UAT' + integrationEndpointsMap.get('APIGardenAccenToken').Endpoint__c;
            username = '{!$Credential.API_Garden_Token_UAT.Username}';
            password = '{!$Credential.API_Garden_Token_UAT.Password}';
        }
        HttpRequest request = new HttpRequest();
        request.setEndpoint(environment);
        request.setMethod('POST');
        request.setBody('grant_type=password&username=' + username + '&password=' + password);
        Http http = new Http();
        try {
            HTTPResponse response = http.send(request);
            return (String) ((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('access_token');
        } catch (Exception ex) {
            Application_Logs__c newError = new Application_Logs__c();
            newError.Debug_Level__c = 'Error';
            newError.Source__c = 'SendToTeliaNowAPI';
            newError.Source_Function__c = 'getAPIGardenToken';
            newError.Message__c = ex.getDmlMessage(0);
            newError.Stack_Trace__c = ex.getMessage();
            insert newError;
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
    }
    global static HTTPResponse callAPI(String endPoint, String method, String token, String body) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(method);
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        if (body != null) {
            request.setBody(body);
        }
        Http http = new Http();
        HTTPResponse response = http.send(request);
        if (!(response.getStatusCode() >= 200 && response.getStatusCode() < 300)) {
            Application_Logs__c newError = new Application_Logs__c();
            newError.Debug_Level__c = 'Error';
            newError.Source__c = 'SendToTeliaNowAPI';
            newError.Source_Function__c = 'callAPI';
            newError.Message__c = response.getStatus();
            newError.Stack_Trace__c = String.valueOf(response.getStatusCode());
            insert newError;
            throw new AuraHandledException(errorMessage(response.getBody()));
        }
        return response;
    }
    global static String errorMessage(String responseBody) {
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> errorMap = (Map<String, Object>) jsonMap.get('error');
        return (String) errorMap.get('detail');
    }
}