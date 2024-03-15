@isTest
private class ES_LoadCSVFile_Test {
    @isTest 
    static void loadCSVFile_test() {
		
		ES_LoadCSVFile loadInstance = new ES_LoadCSVFile();
		String fileString = 'COL1,COL2,COL3\nCOL1,COL2,COL3';

        Account acc = new Account();
        acc.Name = 'A';
        insert acc;

        Contract contr = new Contract();
        contr.AccountId = acc.Id;
        insert contr;


        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = 'test.csv';
        cVersion.Origin = 'C';//C-Content Origin. H-Chatter Origin.
        //cVersion.OwnerId = attach.OwnerId;//Owner of the file
        cVersion.Title = 'Test Title';//Name of the file
        cVersion.VersionData = Blob.valueOf(fileString);
        insert cVersion;

        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = contr.Id;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        //cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        loadInstance.load('TXT_CatalogCode', 'TXT_OfferCode', 1, conDocument);
    }


    @isTest
    static void invokeMethod_Test(){
        String fileString = 'COL1,COL2,COL3\nCOL1,COL2,COL3';

        Account acc = new Account();
        acc.Name = 'A';
        insert acc;

        Contract contr = new Contract();
        contr.AccountId = acc.Id;
        insert contr;


        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = 'test.csv';
        cVersion.Origin = 'C';//C-Content Origin. H-Chatter Origin.
        //cVersion.OwnerId = attach.OwnerId;//Owner of the file
        cVersion.Title = 'Test Title';//Name of the file
        cVersion.VersionData = Blob.valueOf(fileString);
        insert cVersion;

        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = contr.Id;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        //cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;

        Contentversion cv = new Contentversion();
        cv.Title = 'Doc Title';
        cv.PathOnClient = 'test.csv';
        cv.Origin = 'H';
        cv.VersionData = Blob.valueOf(fileString);
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = contr.Id;
        cdl.ShareType = 'V';
        insert cdl;

        //cv.ContentDocumentId = cdl.Id;
        update cv;



        String methodName = 'load';
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String,Object> batchInput = new Map<String, Object>();
        batchInput.put('TXT_CatalogCode','CatCode');
        batchInput.put('TXT_OfferCode','OfferCode');
        batchInput.put('TXT_Batch_Number','1');

        inputMap.put('S_BatchInput', batchInput);

        
        Map<String, Object> files = (Map<String, Object>)options.remove('vlcFilesMap');
        String fileContent;
        
        Map<String,Object> vlcFilesMap = new Map<String,Object>();
        vlcFilesMap.put('key', conDocument);
        options.put('vlcFilesMap', vlcFilesMap);

        ES_LoadCSVFile loadInstance = new ES_LoadCSVFile();
        loadInstance.invokeMethod(methodName, inputMap, outputMap, options);
    }
    
    @isTest
    static void invokeMethod_Test1(){
        String fileString = 'COL1,COL2,COL3\nCOL1,COL2,COL3';
		
        Account acc = new Account();
        acc.Name = 'A';
        insert acc;

        Contract contr = new Contract();
        contr.AccountId = acc.Id;
        insert contr;


        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = 'test.csv';
        cVersion.Origin = 'C';//C-Content Origin. H-Chatter Origin.
        //cVersion.OwnerId = attach.OwnerId;//Owner of the file
        cVersion.Title = 'Test Title';//Name of the file
        cVersion.VersionData = Blob.valueOf(fileString);
        insert cVersion;

        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = contr.Id;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        //cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;

        Contentversion cv = new Contentversion();
        cv.Title = 'Doc Title';
        cv.PathOnClient = 'test.csv';
        cv.Origin = 'H';
        cv.VersionData = Blob.valueOf(fileString);
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = contr.Id;
        cdl.ShareType = 'V';
        insert cdl;

        //cv.ContentDocumentId = cdl.Id;
        update cv;



        String methodName = 'load';
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String,Object> batchInput = new Map<String, Object>();
        batchInput.put('TXT_CatalogCode','CatCode');
        batchInput.put('TXT_OfferCode','OfferCode');
        batchInput.put('TXT_Batch_Number','1');

        inputMap.put('S_BatchInput', batchInput);

        
        Map<String, Object> files = (Map<String, Object>)options.remove('vlcFilesMap');
        String fileContent;
        
        Map<String,Object> vlcFilesMap = new Map<String,Object>();
        vlcFilesMap.put('key', conDocument);
        options.put('vlcFilesMap', vlcFilesMap);

        ES_LoadCSVFile loadInstance = new ES_LoadCSVFile();
        loadInstance.invokeMethod(methodName, inputMap, outputMap, options);
         
           /* for (String key : files.keySet()) {
                fileContent = String.valueOf(files.get(key));
                System.debug('fileContent: '+ fileContent);
            }*/
        loadInstance.load('TXT_CatalogCode','TXT_OfferCode',1,cv.Id);
    }



}