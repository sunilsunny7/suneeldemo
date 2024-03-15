global with sharing class XLSTesttemplateGenerator implements vlocity_cmt.VlocityOpenInterface2   {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('generate')) {//for header buttons
                XLSTesttemplateGenerator.generate(inputMap);
            } 
            
            else {
                result = false;
            }   
            
        } catch(Exception e) {          
            result = false;
        }        
        return result;
    }
    public static String generate(Map<String,Object> inputMap) {
        StaticResource xlsxTemplateFrame = [SELECT Body FROM StaticResource WHERE Name = 'TPPExcelWorkbook' LIMIT 1];
        
        Zippex xlszip = new Zippex(xlsxTemplateFrame.Body);
        
        system.debug('ContractId :'+inputMap.get('Id'));
        String contractId = (String)inputMap.get('Id');
        
        //Sheet1
        PageReference sheet1xml = page.XLS_InstTPP;
        sheet1xml.getParameters().put('ContractID',contractId);
        Blob sheet1Content;
        if (Test.isRunningtest()) {
            sheet1Content = Blob.valueOf('Sample');
        } else {
            sheet1Content = sheet1xml.getContent();
        }
        xlszip.addFile('xl/worksheets/sheet1.xml', sheet1Content, null);
        
        //Sheet2
        PageReference sheet2xml = page.XLS_Kundupgifter;
        sheet2xml.getParameters().put('ContractID',contractId);
        Blob sheet2Content;
        if (Test.isRunningtest()) {
            sheet2Content = Blob.valueOf('Sample');
        } else {
            sheet2Content = sheet2xml.getContent();
        }
        xlszip.addFile('xl/worksheets/sheet2.xml', sheet2Content, null);
        
        //Sheet3
        
        PageReference sheet3xml = page.XLS_IngaendeOrgnr;
        sheet3xml.getParameters().put('ContractID',contractId);
        Blob sheet3Content;
        if (Test.isRunningtest()) {
            sheet3Content = Blob.valueOf('Sample');
        } else {
            sheet3Content = sheet3xml.getContent();
        }
        xlszip.addFile('xl/worksheets/sheet3.xml', sheet3Content, null);
        
        //Sheet4
        PageReference sheet4xml = page.XLS_OrderTPP;
        sheet4xml.getParameters().put('ContractID',contractId);
        Blob sheet4Content;
        if (Test.isRunningtest()) {
            sheet4Content = Blob.valueOf('Sample');
        } else {
            sheet4Content = sheet4xml.getContent();
        }
        xlszip.addFile('xl/worksheets/sheet4.xml', sheet4Content, null);
        
        contract con = [Select id, ContractNumber from contract where id=:contractId];
        
        String ContractNumber = con.ContractNumber;
        ContentVersion cv = new ContentVersion();
        String title = 'TesttemplateUpdated222';
        cv.Title = title;
        cv.PathOnClient = title + ' - ' + DateTime.now() + '.xlsm';
        cv.VersionData = xlszip.getZipArchive();
        insert cv;
        
        ContentVersion cv2 = cv.clone();
        cv2.Title= 'Pris- och beställningsunderlag Touchpoint Plus '+ ContractNumber;        
        insert cv2;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: cv2.id];
        Id contentDocumentid = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id].Id;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentVersion_2.ContentDocumentId;
        cdl.LinkedEntityId = con.id; 
        cdl.ShareType = 'V';
        insert cdl;
        
        System.debug('ContentDocId ==>'+URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentid);
        return URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentid; 
        
    }
    
}