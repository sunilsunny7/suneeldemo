/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* This is a schedular class invoked by ES_LoadCSVFile class which Invokes the Queueable job that parses the document.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
*/
global class loadClass Implements Schedulable{
    String sequence;
    global loadClass(String sequence){
    system.debug('Sequence'+sequence);
        this.sequence = sequence;
        
    }
    global void execute(SchedulableContext SC){
    system.debug('Sequence inside execute'+sequence);
        WarmupDetail__c  temp = [select ProductCode__c,CatalogCode__c,BatchNumber__c,FileContent__c from WarmupDetail__c where Sequence__c =:sequence limit 1][0];
        if(temp.FileContent__c != null){
            List<ContentVersion> contentVersions = (List<ContentVersion>)Database.query('SELECT FileType, VersionData FROM ContentVersion WHERE ContentDocumentId=\'' + temp.FileContent__c + '\' AND IsLatest=true LIMIT 1');
                try{
                    String contentString = contentVersions.get(0).VersionData.toString();
                    contentVersions = null;
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new ES_AsyncParseCSVFile(temp.ProductCode__c, temp.CatalogCode__c, contentString, Integer.valueOf(temp.BatchNumber__c)));
                    }
                }catch(Exception e){
                    system.debug('Error: '+e);
                    
                }
            
        }
        //delete temp;
    }
}