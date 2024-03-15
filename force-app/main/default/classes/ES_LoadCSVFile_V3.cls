/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class implements the VlocityOpenInterface2 interface. It is invoked by the Omniscript 
* WarmupDCApiCache/LoadConfiguration. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Andrea Premarini <apremarini@salesforce.com>
* @modifiedBy    Simran Gupta <simran.gupta@capgemini.com> 
* @maintainedBy   

* @version        3.0
* @created        2021-06-01
* @modified       2021-10-15

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global with sharing class ES_LoadCSVFile_V3 implements vlocity_cmt.VlocityOpenInterface2 {
    
    public class ParsingException extends Exception {}

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        if (methodName == 'load') {
            Map<String,Object> batchInput = (Map<String,Object>) inputMap.get('S_BatchInput');
            String catalogCode = (String) batchInput.get('TXT_CatalogCode');
            String productCode = (String) batchInput.get('TXT_OfferCode');
            Integer batchNumber = Integer.valueOf((String) batchInput.get('TXT_Batch_Number'));
            Map<String, Object> files = (Map<String, Object>)options.remove('vlcFilesMap');
            String fileContent;
            String sequence = '';
         
            for (String key : files.keySet()) {
                fileContent = String.valueOf(files.get(key));
                System.debug('fileContent: '+ fileContent);
            }
            if(Label.CacheWarmupScheduled == 'false'){
                load(catalogCode, productCode, batchNumber, fileContent);
                return true;
            }
            else{
                if(fileContent != null){
                List<ContentVersion> contentVersions = (List<ContentVersion>)Database.query('SELECT FileType, VersionData FROM ContentVersion WHERE ContentDocumentId=\'' + fileContent + '\' AND IsLatest=true LIMIT 1');
                 
                    if (!contentVersions.isEmpty()) {
                        
                        ContentVersion version = contentVersions.get(0);
                        contentVersions = null;
                        
                        /*If file type is CSV then schedule the job else throw an error*/
                        if (version.FileType.equalsIgnoreCase('CSV')) {
                           
                            WarmupDetail__c details = new WarmupDetail__c();
                            details.CatalogCode__c = catalogCode;
                            details.ProductCode__c = productCode;
                            details.BatchNumber__c = batchNumber;
                            details.FileContent__c = fileContent;
                            
                            insert details;      
                            if(!Test.isRunningTest()){ 
                                sequence = [select Sequence__c from WarmupDetail__c where Id =: details.Id]?.Sequence__c;      
                                loadClass_V3 batch = new loadClass_V3(sequence);
                                String sch = Label.CacheWarmupExecutionTime;
                                String jobIDNew = system.schedule(Label.CacheWarmupBatchName, sch, batch);
                            }
                            
                        }
                        else throw new ParsingException('Unable to parse file type "' + version.FileType + '".');
                    }
                }
            
       
            return true;
            }
        }
        return false;
    }

    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * load method, retrieves the blob of the ContentDocument and converts it into a String. Invokes
    * the Queueable job that parses the document.
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  catalogCode                       catalog code of the offer
    * @param  productCode                       product code of the current offer
    * @param  batchNumber                       number of batches that are launched in parallel by the Queueable job
    * @param  fileContent                       Id of the ContentDocument
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    @TestVisible 
    private void load(String catalogCode, String productCode, Integer batchNumber, String fileContent ) {
        System.debug('catalogCode ' + catalogCode);
        System.debug('productCode ' + productCode);
        System.debug('batchNumber ' + batchNumber);
             
        if(fileContent != null){
            List<ContentVersion> contentVersions = (List<ContentVersion>)Database.query('SELECT FileType, VersionData FROM ContentVersion WHERE ContentDocumentId=\'' + fileContent + '\' AND IsLatest=true LIMIT 1');
             
            if (!contentVersions.isEmpty()) {
                
                ContentVersion version = contentVersions.get(0);
                contentVersions = null;
                
                if (version.FileType.equalsIgnoreCase('CSV')) {
                    String contentString = version.VersionData.toString();
                    version = null;
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new ES_AsyncParseCSVFile_V3(productCode, catalogCode, contentString, batchNumber));
                    }
                }
                else throw new ParsingException('Unable to parse file type "' + version.FileType + '".');
            }
        }
    }
}