/****************************************************************************************************************************

* @author                 Sunita Tudu   <sunita.tudu@capgemini.com>
* @modifiedBy             Sunita Tudu   <sunita.tudu@capgemini.com>
* @maintainedBy           Sunita Tudu
* @version                1.0
* @description            Generates orderunderlag excel file for CRM Fiber
* @modified               05-09-2022

******************************************************************************************************************************/
global with sharing class Orderunderlag_Generator implements vlocity_cmt.VlocityOpenInterface2   {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('generate')) {
                generate(inputMap,outMap);
            } 
            else {
                result = false;
            }     
        } catch(Exception e) {          
            result = false;
            System.debug('except'+ e.getStackTraceString());
            outMap.put('exception',e);
            
        }        
        return result;
    }
    public static void generate(Map<String,Object> inputMap, Map<String,Object> outMap) {
  
        
        Zippex xlszip1 ;
        Zippex xlszip2;
        for(StaticResource resource:[SELECT Body,Name FROM StaticResource WHERE Name IN('FiberOrderunderlagExcelFull','FiberOrderunderlagExcelLight')  LIMIT 2]){
           switch on resource.name{
               WHEN 'FiberOrderunderlagExcelFull'{
                 xlszip1 = new Zippex(resource.Body);   
               }
               WHEN 'FiberOrderunderlagExcelLight' {
                 xlszip2 = new Zippex(resource.Body);   
               }
            }
        }
        ContentVersion cv = new ContentVersion();
       
        String contractId = (String)inputMap.get('ContextId');  
       
        Contract con = [Select id, ContractNumber,Account.name from contract where id=:contractId WITH SECURITY_ENFORCED Limit 1];
        Boolean version = (Boolean)inputMap.get('version');
        String createdDate = String.valueOf(date.Today());
        String num=con.ContractNumber;
        String AccName=con.Account.name;

        if(version){
            //sheet1
            PageReference sheet1xml = page.FiberOrderunderlagFullAllmant;
            sheet1xml.getParameters().put('ContractID',contractId);
 
            Blob sheet1Content;
            if (Test.isRunningtest()) {
                sheet1Content = Blob.valueOf('Sample');
            } else {
               sheet1Content = sheet1xml.getContent();
            }
           // outMap.put('sheet1Content', sheet1Content.toString());
            xlszip1.addFile('xl/worksheets/sheet1.xml', sheet1Content, null);
            //sheet 2
            System.debug('sheet2');
            PageReference sheet2xml = page.FiberOrderunderlagFullProdukter;
            sheet2xml.getParameters().put('ContractID',contractId);
            Blob sheet2Content;
            if (Test.isRunningtest()) {
                sheet2Content = Blob.valueOf('Sample');
            } else {
                sheet2Content = sheet2xml.getContent();
            }
            //outMap.put('sheet2Content', sheet2Content.toString());
            xlszip1.addFile('xl/worksheets/sheet2.xml', sheet2Content, null);
            //sheet 3            
            PageReference sheet3xml = page.FiberOrderunderlagFullFLIT;
            sheet3xml.getParameters().put('ContractID',contractId);
            Blob sheet3Content;
            if (Test.isRunningtest()) {
                sheet3Content = Blob.valueOf('Sample');
            } else {
                sheet3Content = sheet3xml.getContent();
            }
            xlszip1.addFile('xl/worksheets/sheet3.xml', sheet3Content, null);
            
            //Sheet 4
            PageReference sheet4xml = page.FiberOrderunderlagFullServiceavtal;
            sheet4xml.getParameters().put('ContractID',contractId);
            Blob sheet4Content;
            if (Test.isRunningtest()) {
                sheet4Content = Blob.valueOf('Sample');
            } else {
                sheet4Content = sheet4xml.getContent();
            }
            xlszip1.addFile('xl/worksheets/sheet4.xml', sheet4Content, null); 
            
            String title = 'Orderunderlag _Full_'+AccName +'_'+createdDate;
            cv.Title = title;
            cv.PathOnClient = title + '.xlsx';
            cv.VersionData = xlszip1.getZipArchive();
             Database.SaveResult contversion = Database.insert(cv);
        }
        //light version
        else{
            PageReference sheet1xml = page.FiberOrderunderlagLightAllmant;
            sheet1xml.getParameters().put('ContractID',contractId);

            Blob sheet1Content;
            if (Test.isRunningtest()) {
                sheet1Content = Blob.valueOf('Sample');
            } else {
                sheet1Content = sheet1xml.getContent();
            }

            xlszip2.addFile('xl/worksheets/sheet1.xml', sheet1Content, null);
            String title = 'Orderunderlag _Light_'+AccName +'_'+createdDate;
            cv.Title= title;
            cv.PathOnClient = title + '.xlsx';
            cv.VersionData = xlszip2.getZipArchive();
            Database.SaveResult contversion2 = Database.insert(cv);
            
            }
 
        ID contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion  WHERE Id =: cv.id  WITH SECURITY_ENFORCED Limit 1]?.ContentDocumentId;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.contentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = con.id; 
        cdl.ShareType = 'V';
        Database.SaveResult docLink = Database.insert(cdl);
        
        vlocity_cmt__VlocityTrackingEntry__c vte = [Select Id, MCResponseJSON__c from vlocity_cmt__VlocityTrackingEntry__c where vlocity_cmt__ContextId__c =: contractId WITH SECURITY_ENFORCED order by CreatedDate DESC  limit 1 ];
        Database.DeleteResult results  = Database.delete(vte.id) ;

        String downloadLink =  URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentid;
        outMap.put('DocLink', downloadLink);
    }
    
}